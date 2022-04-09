import common
import hardware/[hardware, cr]
type
  PDE* {.bycopy.} = object
    P* {.bitsize: 1.}: uint32
    RW* {.bitsize: 1.}: uint32
    US* {.bitsize: 1.}: uint32
    PWT* {.bitsize: 1.}: uint32
    PCD* {.bitsize: 1.}: uint32
    A* {.bitsize: 1.}: uint32
    field6* {.bitsize: 1.}: uint32
    PS* {.bitsize: 1.}: uint32
    G* {.bitsize: 1.}: uint32
    field9* {.bitsize: 3.}: uint32
    ptblBase* {.bitsize: 20.}: uint32

type
  PTE* {.bycopy.} = object
    P* {.bitsize: 1.}: uint32
    RW* {.bitsize: 1.}: uint32
    US* {.bitsize: 1.}: uint32
    PWT* {.bitsize: 1.}: uint32
    PCD* {.bitsize: 1.}: uint32
    A* {.bitsize: 1.}: uint32
    D* {.bitsize: 1.}: uint32
    PAT* {.bitsize: 1.}: uint32
    G* {.bitsize: 1.}: uint32
    field9* {.bitsize: 3.}: uint32
    pageBase* {.bitsize: 20.}: uint32

type
  acsmodeT* {.size: sizeof(cint).} = enum
    MODEREAD
    MODEWRITE
    MODEEXEC

type
  DataAccess* = object of Hardware
    tlb*: seq[ptr PTE]

func logger*(acs: DataAccess): EmuLogger = acs.cpu.logger

template log*(acs: DataAccess, event: EmuEvent, depth: int = -2): untyped =
  acs.cpu.logger.log(event, depth)


proc initDataAccess*(size: ESize, logger: EmuLogger): DataAccess =
  asgnAux[Hardware](result, initHardware(size, logger))
  assertRef(result.mem)
  assertRef(result.io.memory)

import emulator/descriptor

proc setSegment*(this: var DataAccess, reg: SgRegT, sel: uint16): void =
  var sg: SGRegister
  var cache: ptr SGRegCache = addr sg.cache
  this.cpu.getSgreg(reg, sg)
  sg.raw = sel
  if this.cpu.isProtected():
    var dtBase: uint32
    var dtLimit, dtIndex: uint16
    var gdt: SegDesc
    let sgregName = ["ES", "CS", "SS", "DS", "FS", "GS"]
    dtIndex = sg.index shl 3
    dtBase = this.cpu.getDtregBase(if sg.TI.bool: LDTR else: GDTR)
    dtLimit = this.cpu.getDtregLimit(if sg.TI.bool: LDTR else: GDTR)
    if (reg == CS or reg == SS) and not(dtIndex).bool: raise newException(EXP_GP, "")
    if dtIndex > dtLimit:
      raise newException(
        EXP_GP, "dtIndex: $#, dtLimit: $#" % [$dtIndex, $dtLimit])


    this.mem.readDataBlob(gdt, dtBase + dtIndex)

    cache.base = (gdt.baseH shl 24) + (gdt.baseM shl 16) + gdt.baseL
    cache.limit = (gdt.limitH shl 16) + gdt.limitL
    cast[ptr uint8](
      addr cache.flags.`type`
    )[] = cast[ptr uint8](
      addr gdt.getType()
    )[]

    cache.flags.AVL = gdt.AVL
    cache.flags.DB = gdt.DB
    cache.flags.G = gdt.G

  else:
    cache.base = cast[uint32](sel) shl 4

  this.log ev(eekSetSegment, evalue(sg.raw, 16), reg.uint8)
  this.cpu.setSgreg(reg, sg)

proc getSegment*(this: var DataAccess, reg: SgRegT): uint16 =
  var sg: SGRegister
  this.cpu.getSgreg(reg, sg)
  result = sg.raw
  this.log ev(eekGetSegment, evalue(result, 16), reg.uint8)

proc transVirtualToLinear*(
    this: var DataAccess, mode: acsmodeT, seg: SgRegT, vaddr: uint32): uint32 =
  ## Translate virtual (logical) address `vaddr` into linear address

  let CPL: uint8 = this.getSegment(CS).uint8 and 3

  var sg: SGRegister
  this.cpu.getSgreg(seg, sg)
  if this.cpu.isProtected():
    let cache: SGRegCache = sg.cache
    var base = cache.base
    var limit = cache.limit

    if cache.flags.G.bool:
      limit = (limit shl 12)

    if cache.flags.`type`.segc.bool:
      if mode == MODEWRITE:
        raise newException(EXP_GP, "")

      if mode == MODEREAD and not(cache.flags.`type`.code.r).bool:
        raise newException(EXP_GP, "")

      if CPL > cache.flags.DPL and
        not((mode == MODEEXEC and cache.flags.`type`.code.cnf.bool)).bool:

        raise newException(EXP_GP, "")

    else:
      if mode == MODEEXEC:
        raise newException(EXP_GP, "")

      if mode == MODEWRITE and not(cache.flags.`type`.data.w).bool:
        raise newException(EXP_GP, "")

      if CPL > cache.flags.DPL:
        raise newException(EXP_GP, "")

      if cache.flags.`type`.data.exd.bool:
        base = (base - limit)

    if vaddr > limit:
      raise newException(
        EXP_GP,
        "virtual address is out of range: varddr: $#, limit: $#" % [
          $vaddr, $limit
        ])

    result = base + vaddr

  else:
    result = (sg.raw shl 4) + vaddr



proc searchTlb*(this: var DataAccess, vpn: uint32, pte: ptr PTE): bool =
  if vpn + 1 > uint32(this.tlb.len() != 0 or not(this.tlb[vpn].isNil())):
    return false

  ASSERT(pte.isNil())
  pte[] = this.tlb[vpn][]
  return true

proc cacheTlb*(this: var DataAccess, vpn: uint32, pte: PTE): void =
  if vpn + 1 > this.tlb.len().uint32:
    this.tlb.setLen(vpn + 1)

  this.tlb[vpn] = cast[ptr PTE](alloc(sizeof(PTE)))
  this.tlb[vpn][] = pte


proc transVirtualToPhysical*(
  this: var DataAccess, mode: acsmodeT, seg: SgRegT, vaddr: uint32): uint32 =
  ## Translate virtual address `varddr` to physical one. For full
  ## documentation see section 5.1 - "Page translation"
  this.logger.scope "Virtual to physical addrss"

  let laddr: uint32 = this.transVirtualToLinear(mode, seg, vaddr)
  if this.cpu.isEnaPaging():
    var pte: PTE
    if not(this.cpu.isProtected()):
      raise newException(EXP_GP, "Ena paging requires protected mode")

    let cpl: uint8 = this.getSegment(CS).uint8 and 3
    let vpn: uint32 = laddr shr 12
    let offset: uint16 = laddr.uint16 and ((1 shl 12) - 1)
    if not(this.searchTlb(vpn, addr pte)):
      var pdirBase, ptblBase: uint32
      var pdirIndex, ptblIndex: uint16
      pdirIndex = uint16(laddr shr 22)
      ptblIndex = uint16((laddr shr 12) and ((1 shl 10) - 1))
      pdirBase = this.cpu.getPdirBase() shl 12
      var pde: PDE
      this.mem.readDataBlob(
        pde,
        uint32(pdirBase + pdirIndex) * sizeof(PDE).uint32)

      if not(pde.P).toBool():
        this.cpu.setCrn(2, laddr)
        raise newException(EXP_PF, "")

      if not(pde.RW).bool and mode == MODEWRITE:
        this.cpu.setCrn(2, laddr)
        raise newException(EXP_PF, "")

      if not(pde.US).bool and cpl > 2:
        this.cpu.setCrn(2, laddr)
        raise newException(EXP_PF, "")

      ptblBase = pde.ptblBase shl 12
      this.mem.readDataBlob(
        pte,
        uint32(ptblBase + ptblIndex) * sizeof(PTE).uint32())

      this.cacheTlb(vpn, pte)

    if not(pte.P).bool:
      this.cpu.setCrn(2, laddr)
      raise newException(EXP_PF, "")

    if not(pte.RW).bool and mode == MODEWRITE:
      this.cpu.setCrn(2, laddr)
      raise newException(EXP_PF, "")

    if not(pte.US).bool and cpl > 2:
      this.cpu.setCrn(2, laddr)
      raise newException(EXP_PF, "")

    result = (pte.pageBase shl 12) + offset

  else:
    result = laddr

  if not(this.mem.isEnaA20gate()):
    result = (result and (1 shl 20) - 1)

proc readMem32Seg*(this: var DataAccess, seg: SgRegT, memAddr: uint32): uint32 =
  var paddr, ioBase: uint32
  paddr = this.transVirtualToPhysical(MODEREAD, seg, memAddr)
  ioBase = this.io.chkMemio(paddr)
  if ioBase != 0:
    return this.io.readMemio32(ioBase, paddr - ioBase)

  else:
    return this.mem.readMem32(paddr)

proc readMem16Seg*(this: var DataAccess, seg: SgRegT, memAddr: uint32): uint16 =
  var paddr, ioBase: uint32
  paddr = this.transVirtualToPhysical(MODEREAD, seg, memAddr)
  ioBase = this.io.chkMemio(paddr)
  return (if ioBase != 0:
            this.io.readMemio16(ioBase, paddr - ioBase)

          else:
            this.mem.readMem16(paddr)
          )

proc readMem8Seg*(this: var DataAccess, seg: SgRegT, memAddr: uint32): uint8 =
  var paddr, ioBase: uint32
  paddr = this.transVirtualToPhysical(MODEREAD, seg, memAddr)
  ioBase = this.io.chkMemio(paddr)
  return (if ioBase != 0:
            this.io.readMemio8(ioBase, paddr - ioBase)

          else:
            this.mem.readMem8(paddr)
          )

proc writeMem32Seg*(this: var DataAccess, seg: SgRegT, memAddr: uint32, v: uint32): void =
  var paddr, ioBase: uint32
  paddr = this.transVirtualToPhysical(MODEWRITE, seg, memAddr)
  ioBase = this.io.chkMemio(paddr)
  if ioBase != 0:
    this.io.writeMemio32(ioBase, paddr - ioBase, v)

  else:
    this.mem.writeMem32(paddr, v)


proc writeMem16Seg*(this: var DataAccess, seg: SgRegT, memAddr: uint32, v: uint16): void =
  var paddr, ioBase: uint32
  paddr = this.transVirtualToPhysical(MODEWRITE, seg, memAddr)
  ioBase = this.io.chkMemio(paddr)
  if ioBase != 0:
    this.io.writeMemio16(ioBase, paddr - ioBase, v)

  else:
    this.mem.writeMem16(paddr, v)


proc writeMem8Seg*(this: var DataAccess, seg: SgRegT, memAddr: uint32, v: uint8): void =
  var paddr, ioBase: uint32
  paddr = this.transVirtualToPhysical(MODEWRITE, seg, memAddr)
  ioBase = this.io.chkMemio(paddr)
  if ioBase != 0:
    this.io.writeMemio8(ioBase, paddr - ioBase, v)

  else:
    this.mem.writeMem8(paddr, v)



proc execMem8Seg*(this: var DataAccess, seg: SgRegT, memAddr: uint32): uint8 =
  let pos = this.transVirtualToPhysical(MODEEXEC, seg, memAddr)
  return this.mem.readMem8(pos)

proc execMem16Seg*(this: var DataAccess, seg: SgRegT, memAddr: uint32): uint16 =
  return this.mem.readMem16(this.transVirtualToPhysical(MODEEXEC, seg, memAddr))

proc getData8*(this: var DataAccess, seg: SgRegT, memAddr: uint32): uint8 =
  return this.readMem8Seg(seg, memAddr)

proc getData16*(this: var DataAccess, seg: SgRegT, memAddr: uint32): uint16 =
  return this.readMem16Seg(seg, memAddr)

proc getData32*(this: var DataAccess, seg: SgRegT, memAddr: uint32): uint32 =
  return this.readMem32Seg(seg, memAddr)

proc putData8*(this: var DataAccess, seg: SgRegT, memAddr: uint32, v: uint8): void =
  this.writeMem8Seg(seg, memAddr, v)

proc putData16*(this: var DataAccess, seg: SgRegT, memAddr: uint32, v: uint16): void =
  this.writeMem16Seg(seg, memAddr, v)

proc putData32*(this: var DataAccess, seg: SgRegT, memAddr: uint32, v: uint32): void =
  this.writeMem32Seg(seg, memAddr, v)

proc getCode8*(this: var DataAccess, index: cint): uint8 =
  ## Get single Byte from executable memory. Use CS register to compute
  ## base.
  this.logger.logScope ev(eekGetCode)
  result = this.execMem8Seg(CS, this.cpu.getEip() + index.uint32)

proc getCode16*(this: var DataAccess, index: cint): uint16 =
  this.logger.logScope ev(eekGetCode)
  return this.execMem16Seg(CS, this.cpu.getEip() + index.uint32)

proc execMem32Seg*(this: var DataAccess, seg: SgRegT, memAddr: uint32): uint32 =
  return this.mem.readMem32(this.transVirtualToPhysical(MODEEXEC, seg, memAddr))

proc getCode32*(this: var DataAccess, index: cint): uint32 =
  this.logger.logScope ev(eekGetCode)
  return this.execMem32Seg(CS, this.cpu.getEip() + index.uint32)


proc push32*(this: var DataAccess, value: uint32): void =
  this.logger.scope "push 32"

  this.cpu.updateGpreg(ESP, -4)
  let esp: uint32 = this.cpu.getGpreg(ESP)
  this.writeMem32Seg(SS, esp, value)

proc pop32*(this: var DataAccess): uint32 =
  this.logger.scope "pop 32"

  let esp: uint32 = this.cpu.getGpreg(ESP)
  let value: uint32 = this.readMem32Seg(SS, esp)
  this.cpu.updateGpreg(ESP, 4)
  return value

proc push16*(this: var DataAccess, value: uint16): void =
  this.logger.scope "push 16"

  this.cpu.updateGpreg(SP, -2)
  let sp: uint16 = this.cpu.getGpreg(SP)
  this.writeMem16Seg(SS, sp, value)

proc pop16*(this: var DataAccess): uint16 =
  this.logger.scope "pop 16"

  let sp = this.cpu.getGpreg(SP)
  let value = this.readMem16Seg(SS, sp)
  this.cpu.updateGpreg(SP, 2)
  return value

