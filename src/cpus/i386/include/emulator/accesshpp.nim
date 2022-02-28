import commonhpp
import hardware/[hardwarehpp, crhpp]
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
    ptbl_base* {.bitsize: 20.}: uint32

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
    page_base* {.bitsize: 20.}: uint32

type
  acsmode_t* {.size: sizeof(cint).} = enum
    MODE_READ
    MODE_WRITE
    MODE_EXEC

type
  DataAccess* {.bycopy.} = object of Hardware
    tlb*: seq[ptr PTE]

import emulator/exceptionhpp
import emulator/descriptorhpp

proc set_segment*(this: var DataAccess, reg: sgreg_t, sel: uint16): void =
  var sg: SGRegister
  var cache: ptr SGRegCache = addr sg.cache
  this.cpu.get_sgreg(reg, addr sg)
  sg.raw = sel
  if this.cpu.is_protected():
    var dt_base: uint32
    var dt_limit, dt_index: uint16
    var gdt: SegDesc
    let sgreg_name = ["ES", "CS", "SS", "DS", "FS", "GS"]
    dt_index = sg.index shl 3
    dt_base = this.cpu.get_dtreg_base(if sg.TI.bool: LDTR else: GDTR)
    dt_limit = this.cpu.get_dtreg_limit(if sg.TI.bool: LDTR else: GDTR)
    EXCEPTION(EXP_GP, (reg == CS or reg == SS) and not(dt_index).bool)
    EXCEPTION(EXP_GP, dt_index > dt_limit)
    discard this.mem.read_data(addr gdt, dt_base + dt_index, sizeof((SegDesc)).csize_t)
    cache.base = (gdt.base_h shl 24) + (gdt.base_m shl 16) + gdt.base_l
    cache.limit = (gdt.limit_h shl 16) + gdt.limit_l
    cast[ptr uint8](
      addr cache.flags.`type`
    )[] = cast[ptr uint8](
      addr gdt.getType()
    )[]

    cache.flags.AVL = gdt.AVL
    cache.flags.DB = gdt.DB
    cache.flags.G = gdt.G
    INFO(3, "%s : dt_base=0x%04x, dt_limit=0x%02x, dt_index=0x%02x {base=0x%08x, limit=0x%08x, flags=0x%04x}", sgreg_name[reg], dt_base, dt_limit, dt_index, cache.base, cache.limit shl ((if cache.flags.G:
                             12

                           else:
                             0
                           )), cache.flags.raw)

  else:
    cache.base = cast[uint32](sel) shl 4

  this.cpu.set_sgreg(reg, addr sg)

proc get_segment*(this: var DataAccess, reg: sgreg_t): uint16 =
  var sg: SGRegister
  this.cpu.get_sgreg(reg, addr sg)
  return sg.raw

proc trans_v2l*(this: var DataAccess, mode: acsmode_t, seg: sgreg_t, vaddr: uint32): uint32 =
  var laddr: uint32
  var CPL: uint8
  var sg: SGRegister
  CPL = this.get_segment(CS).uint8 and 3
  this.cpu.get_sgreg(seg, addr sg)
  if this.cpu.is_protected():
    var base, limit: uint32
    var cache: SGRegCache = sg.cache
    base = cache.base
    limit = cache.limit
    if cache.flags.G.bool:
      limit = (limit shl 12)

    if cache.flags.`type`.segc.bool:
      EXCEPTION(EXP_GP, mode == MODE_WRITE)
      EXCEPTION(EXP_GP, mode == MODE_READ and not(cache.flags.`type`.code.r).bool)
      EXCEPTION(
        EXP_GP,
        CPL > cache.flags.DPL and
        not((mode == MODE_EXEC and cache.flags.`type`.code.cnf.bool)).bool)

    else:
      EXCEPTION(EXP_GP, mode == MODE_EXEC)
      EXCEPTION(EXP_GP, mode == MODE_WRITE and not(cache.flags.`type`.data.w).bool)
      EXCEPTION(EXP_GP, CPL > cache.flags.DPL)
      if cache.flags.`type`.data.exd.bool:
        base = (base - limit)


    EXCEPTION(EXP_GP, vaddr > limit)
    laddr = base + vaddr
    INFO(6, "base=0x%04x, limit=0x%02x, laddr=0x%02x", base, limit, laddr)

  else:
    laddr = (sg.raw shl 4) + vaddr
    INFO(6, "base=0x%04x, laddr=0x%02x", sg.raw shl 4, laddr)

  return laddr


proc search_tlb*(this: var DataAccess, vpn: uint32, pte: ptr PTE): bool =
  if vpn + 1 > uint32(this.tlb.len() != 0 or not(this.tlb[vpn].isNil())):
    return false

  ASSERT(pte.isNil())
  pte[] = this.tlb[vpn][]
  return true

proc cache_tlb*(this: var DataAccess, vpn: uint32, pte: PTE): void =
  if vpn + 1 > this.tlb.len().uint32:
    this.tlb.setLen(vpn + 1)

  this.tlb[vpn] = cast[ptr PTE](alloc(sizeof(PTE)))
  this.tlb[vpn][] = pte


proc trans_v2p*(this: var DataAccess, mode: acsmode_t, seg: sgreg_t, vaddr: uint32): uint32 =
  var laddr, paddr: uint32
  laddr = this.trans_v2l(mode, seg, vaddr)
  if this.cpu.is_ena_paging():
    var vpn: uint32
    var offset: uint16
    var cpl: uint8
    var pte: PTE
    EXCEPTION(EXP_GP, not(this.cpu.is_protected()))
    cpl = this.get_segment(CS).uint8 and 3
    vpn = laddr shr 12
    offset = laddr.uint16 and ((1 shl 12) - 1)
    if not(this.search_tlb(vpn, addr pte)):
      var pdir_base, ptbl_base: uint32
      var pdir_index, ptbl_index: uint16
      var pde: PDE
      pdir_index = uint16(laddr shr 22)
      ptbl_index = uint16((laddr shr 12) and ((1 shl 10) - 1))
      pdir_base = this.cpu.get_pdir_base() shl 12
      discard this.mem.read_data(
        addr pde,
        uint32(pdir_base + pdir_index) * sizeof(PDE).uint32,
        sizeof(PDE).csize_t)

      EXCEPTION_WITH(EXP_PF, not(pde.P).bool, this.cpu.set_crn(2, laddr))
      EXCEPTION_WITH(EXP_PF, not(pde.RW).bool and mode == MODE_WRITE, this.cpu.set_crn(2, laddr))
      EXCEPTION_WITH(EXP_PF, not(pde.US).bool and cpl > 2, this.cpu.set_crn(2, laddr))
      ptbl_base = pde.ptbl_base shl 12
      discard this.mem.read_data(
        addr pte,
        uint32(ptbl_base + ptbl_index) * sizeof(PTE).uint32(),
        sizeof(PTE).uint32())

      this.cache_tlb(vpn, pte)
      INFO(3, "Cache TLB : pdir_base=0x%04x, ptbl_base=0x%04x {vpn=0x%04x, pfn=0x%04x}",
           pdir_base, ptbl_base, vpn, pte.page_base)

    EXCEPTION_WITH(EXP_PF, not(pte.P).bool, this.cpu.set_crn(2, laddr))
    EXCEPTION_WITH(EXP_PF, not(pte.RW).bool and mode == MODE_WRITE, this.cpu.set_crn(2, laddr))
    EXCEPTION_WITH(EXP_PF, not(pte.US).bool and cpl > 2, this.cpu.set_crn(2, laddr))
    paddr = (pte.page_base shl 12) + offset

  else:
    paddr = laddr

  if not(this.mem.is_ena_a20gate()):
    paddr = (paddr and (1 shl 20) - 1)

  return paddr

proc read_mem32_seg*(this: var DataAccess, seg: sgreg_t, `addr`: uint32): uint32 =
  var paddr, io_base: uint32
  paddr = this.trans_v2p(MODE_READ, seg, `addr`)
  io_base = this.io.chk_memio(paddr)
  if io_base != 0:
    return this.io.read_memio32(io_base, paddr - io_base)

  else:
    return this.mem.read_mem32(paddr)

proc read_mem16_seg*(this: var DataAccess, seg: sgreg_t, `addr`: uint32): uint16 =
  var paddr, io_base: uint32
  paddr = this.trans_v2p(MODE_READ, seg, `addr`)
  io_base = this.io.chk_memio(paddr)
  return (if io_base != 0:
            this.io.read_memio16(io_base, paddr - io_base)

          else:
            this.mem.read_mem16(paddr)
          )

proc read_mem8_seg*(this: var DataAccess, seg: sgreg_t, `addr`: uint32): uint8 =
  var paddr, io_base: uint32
  paddr = this.trans_v2p(MODE_READ, seg, `addr`)
  io_base = this.io.chk_memio(paddr)
  return (if io_base != 0:
            this.io.read_memio8(io_base, paddr - io_base)

          else:
            this.mem.read_mem8(paddr)
          )

proc write_mem32_seg*(this: var DataAccess, seg: sgreg_t, `addr`: uint32, v: uint32): void =
  var paddr, io_base: uint32
  paddr = this.trans_v2p(MODE_WRITE, seg, `addr`)
  io_base = this.io.chk_memio(paddr)
  if io_base != 0:
    this.io.write_memio32(io_base, paddr - io_base, v)

  else:
    this.mem.write_mem32(paddr, v)


proc write_mem16_seg*(this: var DataAccess, seg: sgreg_t, `addr`: uint32, v: uint16): void =
  var paddr, io_base: uint32
  paddr = this.trans_v2p(MODE_WRITE, seg, `addr`)
  io_base = this.io.chk_memio(paddr)
  if io_base != 0:
    this.io.write_memio16(io_base, paddr - io_base, v)

  else:
    this.mem.write_mem16(paddr, v)


proc write_mem8_seg*(this: var DataAccess, seg: sgreg_t, `addr`: uint32, v: uint8): void =
  var paddr, io_base: uint32
  paddr = this.trans_v2p(MODE_WRITE, seg, `addr`)
  io_base = this.io.chk_memio(paddr)
  if io_base != 0:
    this.io.write_memio8(io_base, paddr - io_base, v)

  else:
    this.mem.write_mem8(paddr, v)



proc exec_mem8_seg*(this: var DataAccess, seg: sgreg_t, `addr`: uint32): uint8 =
  return this.mem.read_mem8(this.trans_v2p(MODE_EXEC, seg, `addr`))

proc exec_mem16_seg*(this: var DataAccess, seg: sgreg_t, `addr`: uint32): uint16 =
  return this.mem.read_mem16(this.trans_v2p(MODE_EXEC, seg, `addr`))

proc get_data8*(this: var DataAccess, seg: sgreg_t, `addr`: uint32): uint8 =
  return this.read_mem8_seg(seg, `addr`)

proc get_data16*(this: var DataAccess, seg: sgreg_t, `addr`: uint32): uint16 =
  return this.read_mem16_seg(seg, `addr`)

proc get_data32*(this: var DataAccess, seg: sgreg_t, `addr`: uint32): uint32 =
  return this.read_mem32_seg(seg, `addr`)

proc put_data8*(this: var DataAccess, seg: sgreg_t, `addr`: uint32, v: uint8): void =
  this.write_mem8_seg(seg, `addr`, v)

proc put_data16*(this: var DataAccess, seg: sgreg_t, `addr`: uint32, v: uint16): void =
  this.write_mem16_seg(seg, `addr`, v)

proc put_data32*(this: var DataAccess, seg: sgreg_t, `addr`: uint32, v: uint32): void =
  this.write_mem32_seg(seg, `addr`, v)

proc get_code8*(this: var DataAccess, index: cint): uint8 =
  return this.exec_mem8_seg(CS, this.cpu.get_eip() + index.uint32)

proc get_code16*(this: var DataAccess, index: cint): uint16 =
  return this.exec_mem16_seg(CS, this.cpu.get_eip() + index.uint32)

proc exec_mem32_seg*(this: var DataAccess, seg: sgreg_t, `addr`: uint32): uint32 =
  return this.mem.read_mem32(this.trans_v2p(MODE_EXEC, seg, `addr`))

proc get_code32*(this: var DataAccess, index: cint): uint32 =
  return this.exec_mem32_seg(CS, this.cpu.get_eip() + index.uint32)


proc push32*(this: var DataAccess, value: uint32): void =
  var esp: uint32
  discard this.cpu.update_gpreg(ESP, -4)
  esp = this.cpu.get_gpreg(ESP)
  this.write_mem32_seg(SS, esp, value)

proc pop32*(this: var DataAccess): uint32 =
  var esp, value: uint32
  esp = this.cpu.get_gpreg(ESP)
  value = this.read_mem32_seg(SS, esp)
  discard this.cpu.update_gpreg(ESP, 4)
  return value

proc push16*(this: var DataAccess, value: uint16): void =
  var sp: uint16
  discard this.cpu.update_gpreg(SP, -2)
  sp = this.cpu.get_gpreg(SP)
  this.write_mem16_seg(SS, sp, value)

proc pop16*(this: var DataAccess): uint16 =
  var sp, value: uint16
  sp = this.cpu.get_gpreg(SP)
  value = this.read_mem16_seg(SS, sp)
  discard this.cpu.update_gpreg(SP, 2)
  return value

