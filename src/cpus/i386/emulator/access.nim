import common
import std/tables
import hardware/[hardware, cr]

type
  PDE* = object
    ## Page directory entry. See section
    P* {.bitsize: 1.}: U32
    RW* {.bitsize: 1.}: U32
    US* {.bitsize: 1.}: U32
    PWT* {.bitsize: 1.}: U32
    PCD* {.bitsize: 1.}: U32
    A* {.bitsize: 1.}: U32
    field6* {.bitsize: 1.}: U32
    PS* {.bitsize: 1.}: U32
    G* {.bitsize: 1.}: U32
    field9* {.bitsize: 3.}: U32
    ptblBase* {.bitsize: 20.}: U32

  PTE* = object
    ## Page table entry. See figure 5-10 for format description
    P* {.bitsize: 1.}: U32 ## 'Present'
    RW* {.bitsize: 1.}: U32 ## 'Read/write'
    US* {.bitsize: 1.}: U32 ## 'User/superuser'
    PWT* {.bitsize: 1.}: U32
    PCD* {.bitsize: 1.}: U32
    A* {.bitsize: 1.}: U32
    D* {.bitsize: 1.}: U32 ## 'dirty'
    PAT* {.bitsize: 1.}: U32
    G* {.bitsize: 1.}: U32
    field9* {.bitsize: 3.}: U32
    pageBase* {.bitsize: 20.}: U32 ## PAge frame address

type
  acsmodeT* {.size: sizeof(cint).} = enum
    MODEREAD
    MODEWRITE
    MODEEXEC

type
  DataAccess* = object of Hardware
    tlb*: Table[U32, PTE] ## 'Translation Lookaside Buffer'. is a memory
    ## cache that stores the recent translations of virtual memory to
    ## physical memory. It is used to reduce the time taken to access a
    ## user memory location.
    ##
    ## Maps local address paging indices to page table entry object

func logger*(acs: DataAccess): EmuLogger = acs.cpu.logger

template log*(acs: DataAccess, event: EmuEvent, depth: int = -2): untyped =
  acs.cpu.logger.log(event, depth)


proc initDataAccess*(size: ESize, logger: EmuLogger): DataAccess =
  asgnAux[Hardware](result, initHardware(size, logger))
  assertRef(result.mem)
  assertRef(result.io.memory)

import emulator/descriptor

proc setSegment*(this: var DataAccess, reg: SgRegT, sel: U16): void =
  ## Set segment value in the GDT table, update cache in the SG registers.
  ## https://wiki.osdev.org/Descriptor_Cache
  var sg: SGRegister = this.cpu.getSgreg(reg)
  sg.raw = sel
  if this.cpu.isProtected():
    let dtIndex: U16 = sg.index shl 3
    var dtBase: U32 = this.cpu.getDtregBase(if sg.TI.bool: LDTR else: GDTR)
    let dtLimit: U16 = this.cpu.getDtregLimit(if sg.TI.bool: LDTR else: GDTR)

    if (reg == CS or reg == SS) and not(dtIndex).bool:
      raise newException(EXP_GP, "")

    if dtIndex > dtLimit:
      raise newException(
        EXP_GP, "dtIndex: $#, dtLimit: $#" % [$dtIndex, $dtLimit])

    var gdt = readDataBlob[SegDesc](this.mem, dtBase + dtIndex)

    sg.cache.base = (gdt.baseH shl 24) + (gdt.baseM shl 16) + gdt.baseL
    sg.cache.limit = (gdt.limitH shl 16) + gdt.limitL

    # sg.cache.flags.typ = gdt.getType()
    cast[ptr U8](
      addr sg.cache.flags.typ
    )[] = cast[ptr U8](
      addr gdt.getType()
    )[]

    sg.cache.flags.AVL = gdt.AVL
    sg.cache.flags.DB = gdt.DB
    sg.cache.flags.G = gdt.G

  else:
    sg.cache.base = cast[U32](sel) shl 4

  this.log ev(eekSetSegment, evalue(sg.raw, 16), reg.U8)
  this.cpu.setSgreg(reg, sg)

proc getSegment*(this: var DataAccess, reg: SgRegT): U16 =
  let sg: SGRegister = this.cpu.getSgreg(reg)
  result = sg.raw
  this.log ev(eekGetSegment, evalue(result, 16), reg.U8)

proc transVirtualToLinear*(
    this: var DataAccess, mode: acsmodeT, seg: SgRegT, vaddr: U32): U32 =
  ## Translate virtual (logical) address `vaddr` into linear address

  let CPL: U8 = this.getSegment(CS).U8 and 3

  let sg: SGRegister = this.cpu.getSgreg(seg)
  if this.cpu.isProtected():
    let cache: SGRegCache = sg.cache
    var base = cache.base
    var limit = cache.limit

    if cache.flags.G.bool:
      limit = (limit shl 12)

    if cache.flags.typ.segc.bool:
      if mode == MODEWRITE:
        raise newException(EXP_GP, "")

      if mode == MODEREAD and not(cache.flags.typ.code.r).bool:
        raise newException(EXP_GP, "")

      if CPL > cache.flags.DPL and
        not((mode == MODEEXEC and cache.flags.typ.code.cnf.bool)).bool:

        raise newException(EXP_GP, "")

    else:
      if mode == MODEEXEC:
        raise newException(EXP_GP, "")

      if mode == MODEWRITE and not(cache.flags.typ.data.w).bool:
        raise newException(EXP_GP, "")

      if CPL > cache.flags.DPL:
        raise newException(EXP_GP, "")

      if cache.flags.typ.data.exd.bool:
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



proc searchTlb*(this: var DataAccess, vpn: U32, pte: var PTE): bool =
  if vpn notin this.tlb:
    return false

  else:
    pte = this.tlb[vpn]
    return true

proc cacheTlb*(this: var DataAccess, vpn: U32, pte: PTE): void =
  this.tlb[vpn] = pte


proc transVirtualToPhysical*(
  this: var DataAccess, mode: acsmodeT, seg: SgRegT, vaddr: U32): U32 =
  ## Translate virtual address `varddr` to physical one. For full
  ## documentation see section 5.1 - "Page translation"
  this.logger.scope "Virtual to physical addrss"

  let laddr: U32 = this.transVirtualToLinear(mode, seg, vaddr)
  if this.cpu.isEnaPaging():
    # If paging is enabled linear address must be translated into physical
    # one via page table lookup.
    if not(this.cpu.isProtected()):
      raise newException(EXP_GP, "Ena paging requires protected mode")

    let cpl: U8 = this.getSegment(CS).U8 and 3
    let vpn = laddr{31 .. 12}

    var pte: PTE
    # Try search ing cache table using page directory and table indices
    if not(this.searchTlb(vpn, pte)):
      # /index/ of the page directory
      let pdirIndex = laddr{31 .. 22}
      # /index/ of a page in page table
      let ptblIndex = laddr{21 .. 22}
      # Get page directory base (upper 31..12 bits inclusive)
      let pdirBase: U32 = this.cpu.getPdirBase(){31 .. 22}

      # `pdirIndex` is used to look up target page directory entry that
      # will be used for subsequent computing information. This is a first
      # level of table lookups.
      let pde = this.mem.readDataBlob[:PDE](
        pdirBase + (pdirIndex * sizeof(PDE).U32))

      if not(pde.P).toBool():
        this.cpu.setCrn(2, laddr)
        raise newException(
          EXP_PF,
          "Page directory entry not present. base: $#, index: $#" % [
            $pdirIndex,
            $ptblIndex
        ])

      if not(pde.RW).bool and mode == MODEWRITE:
        this.cpu.setCrn(2, laddr)
        raise newException(
          EXP_PF,
          "requested write mode, but read-write is not enabled for page")

      if not(pde.US).bool and cpl > 2:
        this.cpu.setCrn(2, laddr)
        raise newException(
          EXP_PF,
          "Page requires superuser priviledge for access, but cpl was $#" % $cpl)

      let ptblBase: U32 = pde.ptblBase shl 12
      this.mem.readDataBlob(
        pte,
        U32(ptblBase + ptblIndex) * sizeof(PTE).U32())

      this.cacheTlb(vpn, pte)

    if not(pte.P).bool:
      this.cpu.setCrn(2, laddr)
      raise newException(EXP_PF, "Page table entry not present")

    if not(pte.RW).bool and mode == MODEWRITE:
      this.cpu.setCrn(2, laddr)
      raise newException(EXP_PF, "Write mode is not enabled for page")

    if not(pte.US).bool and cpl > 2:
      this.cpu.setCrn(2, laddr)
      raise newException(
        EXP_PF,
        "Page requires superuser priviledge for access, but cpl was $#" % $cpl)

    # With paging enabled, final formula for computing address can be
    # abbreviated into
    #
    # `[dir, page, offset] = <linear address>`
    # `result = page-table[page-directory[dir], page] + offset`
    result = (pte.pageBase shl 12) + laddr{0 .. 11}.U16

  else:
    # If paging is not used, linear is equal to physical address
    result = laddr

  if not(this.mem.isEnaA20gate()):
    # https://en.wikipedia.org/wiki/A20_line TODO
    result = (result and (1 shl 20) - 1)

proc readMem32Seg*(this: var DataAccess, seg: SgRegT, memAddr: U32): U32 =
  var paddr, ioBase: U32
  paddr = this.transVirtualToPhysical(MODEREAD, seg, memAddr)
  ioBase = this.io.chkMemio(paddr)
  if ioBase != 0:
    return this.io.readMemio32(ioBase, paddr - ioBase)

  else:
    return this.mem.readMem32(paddr)

proc readMem16Seg*(this: var DataAccess, seg: SgRegT, memAddr: U32): U16 =
  var paddr, ioBase: U32
  paddr = this.transVirtualToPhysical(MODEREAD, seg, memAddr)
  ioBase = this.io.chkMemio(paddr)
  if ioBase != 0:
    return this.io.readMemio16(ioBase, paddr - ioBase)

  else:
    return this.mem.readMem16(paddr)

proc readMem8Seg*(this: var DataAccess, seg: SgRegT, memAddr: U32): U8 =
  var paddr, ioBase: U32
  paddr = this.transVirtualToPhysical(MODEREAD, seg, memAddr)
  ioBase = this.io.chkMemio(paddr)
  if ioBase != 0:
    return this.io.readMemio8(ioBase, paddr - ioBase)

  else:
    return this.mem.readMem8(paddr)

proc writeMem32Seg*(this: var DataAccess, seg: SgRegT, memAddr: U32, v: U32): void =
  var paddr, ioBase: U32
  paddr = this.transVirtualToPhysical(MODEWRITE, seg, memAddr)
  ioBase = this.io.chkMemio(paddr)
  if ioBase != 0:
    this.io.writeMemio32(ioBase, paddr - ioBase, v)

  else:
    this.mem.writeMem32(paddr, v)


proc writeMem16Seg*(this: var DataAccess, seg: SgRegT, memAddr: U32, v: U16): void =
  var paddr, ioBase: U32
  paddr = this.transVirtualToPhysical(MODEWRITE, seg, memAddr)
  ioBase = this.io.chkMemio(paddr)
  if ioBase != 0:
    this.io.writeMemio16(ioBase, paddr - ioBase, v)

  else:
    this.mem.writeMem16(paddr, v)


proc writeMem8Seg*(this: var DataAccess, seg: SgRegT, memAddr: U32, v: U8): void =
  var paddr, ioBase: U32
  paddr = this.transVirtualToPhysical(MODEWRITE, seg, memAddr)
  ioBase = this.io.chkMemio(paddr)
  if ioBase != 0:
    this.io.writeMemio8(ioBase, paddr - ioBase, v)

  else:
    this.mem.writeMem8(paddr, v)



proc execMem8Seg*(this: var DataAccess, seg: SgRegT, memAddr: U32): U8 =
  let pos = this.transVirtualToPhysical(MODEEXEC, seg, memAddr)
  return this.mem.readMem8(pos)

proc execMem16Seg*(this: var DataAccess, seg: SgRegT, memAddr: U32): U16 =
  return this.mem.readMem16(this.transVirtualToPhysical(MODEEXEC, seg, memAddr))

proc getData8*(this: var DataAccess, seg: SgRegT, memAddr: U32): U8 =
  return this.readMem8Seg(seg, memAddr)

proc getData16*(this: var DataAccess, seg: SgRegT, memAddr: U32): U16 =
  return this.readMem16Seg(seg, memAddr)

proc getData32*(this: var DataAccess, seg: SgRegT, memAddr: U32): U32 =
  return this.readMem32Seg(seg, memAddr)

proc putData8*(this: var DataAccess, seg: SgRegT, memAddr: U32, v: U8): void =
  this.logger.scope "put data $# to $#" % [$v, toHexTrim(memAddr)]
  this.writeMem8Seg(seg, memAddr, v)

proc putData16*(this: var DataAccess, seg: SgRegT, memAddr: U32, v: U16): void =
  this.writeMem16Seg(seg, memAddr, v)

proc putData32*(this: var DataAccess, seg: SgRegT, memAddr: U32, v: U32): void =
  this.writeMem32Seg(seg, memAddr, v)

proc getCode8*(this: var DataAccess, index: cint): U8 =
  ## Get single Byte from executable memory. Use CS register to compute
  ## base.
  this.logger.logScope ev(eekGetCode)
  result = this.execMem8Seg(CS, this.cpu.getEip() + index.U32)

proc getCode16*(this: var DataAccess, index: cint): U16 =
  this.logger.logScope ev(eekGetCode)
  return this.execMem16Seg(CS, this.cpu.getEip() + index.U32)

proc execMem32Seg*(this: var DataAccess, seg: SgRegT, memAddr: U32): U32 =
  return this.mem.readMem32(this.transVirtualToPhysical(MODEEXEC, seg, memAddr))

proc getCode32*(this: var DataAccess, index: cint): U32 =
  this.logger.logScope ev(eekGetCode)
  return this.execMem32Seg(CS, this.cpu.getEip() + index.U32)


proc push32*(this: var DataAccess, value: U32): void =
  this.logger.scope "push 32"

  this.cpu.updateGpreg(ESP, -4)
  let esp: U32 = this.cpu.getGpreg(ESP)
  this.writeMem32Seg(SS, esp, value)

proc pop32*(this: var DataAccess): U32 =
  this.logger.scope "pop 32"

  let esp: U32 = this.cpu.getGpreg(ESP)
  let value: U32 = this.readMem32Seg(SS, esp)
  this.cpu.updateGpreg(ESP, 4)
  return value

proc push16*(this: var DataAccess, value: U16): void =
  this.logger.scope "push 16"

  this.cpu.updateGpreg(SP, -2)
  let sp: U16 = this.cpu.getGpreg(SP)
  this.writeMem16Seg(SS, sp, value)

proc pop16*(this: var DataAccess): U16 =
  this.logger.scope "pop 16"

  let sp = this.cpu.getGpreg(SP)
  let value = this.readMem16Seg(SS, sp)
  this.cpu.updateGpreg(SP, 2)
  return value

