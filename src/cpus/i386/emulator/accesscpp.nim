import
  emulator/accesshpp
import
  emulator/exceptionhpp
import
  emulator/descriptorhpp
proc set_segment*(this: var DataAccess, reg: sgreg_t, sel: uint16): void = 
  var sg: SGRegister
  var cache: ptr SGRegCache = addr sg.cache
  get_sgreg(reg, addr sg)
  sg.raw = sel
  if is_protected():
    var dt_base: uint32
    var dt_index: uint16
    var gdt: SegDesc
    var sgreg_name: ptr UncheckedArray[cstring] = ("ES", "CS", "SS", "DS", "FS", "GS")
    dt_index = sg.index shl 3
    dt_base = get_dtreg_base((if sg.TI:
          LDTR
        
        else:
          GDTR
        ))
    dt_limit = get_dtreg_limit((if sg.TI:
          LDTR
        
        else:
          GDTR
        ))
    EXCEPTION(EXP_GP, (reg == CS or reg == SS) and not(dt_index))
    EXCEPTION(EXP_GP, dt_index > dt_limit)
    read_data(addr gdt, dt_base + dt_index, sizeof((SegDesc)))
    cache.base = (gdt.base_h shl 24) + (gdt.base_m shl 16) + gdt.base_l
    cache.limit = (gdt.limit_h shl 16) + gdt.limit_l
    cast[ptr uint8](addr cache.flags.`type`)[] = cast[ptr uint8](addr gdt.`type`)[]
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
  
  set_sgreg(reg, addr sg)

proc get_segment*(this: var DataAccess, reg: sgreg_t): uint16 = 
  var sg: SGRegister
  get_sgreg(reg, addr sg)
  return sg.raw

proc trans_v2p*(this: var DataAccess, mode: acsmode_t, seg: sgreg_t, vaddr: uint32): uint32 = 
  var paddr: uint32
  laddr = trans_v2l(mode, seg, vaddr)
  if is_ena_paging():
    var vpn: uint32
    var offset: uint16
    var cpl: uint8
    var pte: PTE
    EXCEPTION(EXP_GP, not(is_protected()))
    cpl = get_segment(CS) and 3
    vpn = laddr shr 12
    offset = laddr and ((1 shl 12) - 1)
    if not(search_tlb(vpn, addr pte)):
      var ptbl_base: uint32
      var ptbl_index: uint16
      var pde: PDE
      pdir_index = laddr shr 22
      ptbl_index = (laddr shr 12) and ((1 shl 10) - 1)
      pdir_base = get_pdir_base() shl 12
      read_data(addr pde, pdir_base + pdir_index * sizeof((PDE)), sizeof((PDE)))
      EXCEPTION_WITH(EXP_PF, not(pde.P), set_crn(2, laddr))
      EXCEPTION_WITH(EXP_PF, not(pde.RW) and mode == MODE_WRITE, set_crn(2, laddr))
      EXCEPTION_WITH(EXP_PF, not(pde.US) and cpl > 2, set_crn(2, laddr))
      ptbl_base = pde.ptbl_base shl 12
      read_data(addr pte, ptbl_base + ptbl_index * sizeof((PTE)), sizeof((PTE)))
      cache_tlb(vpn, pte)
      INFO(3, "Cache TLB : pdir_base=0x%04x, ptbl_base=0x%04x {vpn=0x%04x, pfn=0x%04x}", pdir_base, ptbl_base, vpn, pte.page_base)
    
    EXCEPTION_WITH(EXP_PF, not(pte.P), set_crn(2, laddr))
    EXCEPTION_WITH(EXP_PF, not(pte.RW) and mode == MODE_WRITE, set_crn(2, laddr))
    EXCEPTION_WITH(EXP_PF, not(pte.US) and cpl > 2, set_crn(2, laddr))
    paddr = (pte.page_base shl 12) + offset
  
  else:
    paddr = laddr
  
  if not(is_ena_a20gate()):
    paddr = (paddr and (1 shl 20) - 1)
  
  return paddr

proc trans_v2l*(this: var DataAccess, mode: acsmode_t, seg: sgreg_t, vaddr: uint32): uint32 = 
  var laddr: uint32
  var CPL: uint8
  var sg: SGRegister
  CPL = get_segment(CS) and 3
  get_sgreg(seg, addr sg)
  if is_protected():
    var limit: uint32
    var cache: SGRegCache = sg.cache
    base = cache.base
    limit = cache.limit
    if cache.flags.G:
      limit = (limit shl 12)
    
    if cache.flags.`type`.segc:
      EXCEPTION(EXP_GP, mode == MODE_WRITE)
      EXCEPTION(EXP_GP, mode == MODE_READ and not(cache.flags.`type`.code.r))
      EXCEPTION(EXP_GP, CPL > cache.flags.DPL and not((mode == MODE_EXEC and cache.flags.`type`.code.cnf)))
    
    else:
      EXCEPTION(EXP_GP, mode == MODE_EXEC)
      EXCEPTION(EXP_GP, mode == MODE_WRITE and not(cache.flags.`type`.data.w))
      EXCEPTION(EXP_GP, CPL > cache.flags.DPL)
      if cache.flags.`type`.data.exd:
        base = (base - limit)
      
    
    EXCEPTION(EXP_GP, vaddr > limit)
    laddr = base + vaddr
    INFO(6, "base=0x%04x, limit=0x%02x, laddr=0x%02x", base, limit, laddr)
  
  else:
    laddr = (sg.raw shl 4) + vaddr
    INFO(6, "base=0x%04x, laddr=0x%02x", sg.raw shl 4, laddr)
  
  return laddr

proc search_tlb*(this: var DataAccess, vpn: uint32, pte: ptr PTE): bool = 
  if vpn + 1 > tlb.size() or not(tlb[vpn]):
    return false
  
  ASSERT(pte)
  pte[] = tlb[vpn][]
  return true

proc cache_tlb*(this: var DataAccess, vpn: uint32, pte: PTE): void = 
  if vpn + 1 > tlb.size():
    tlb.resize(vpn + 1, `nil`)
  
  tlb[vpn] = newPTE()
  tlb[vpn][] = pte

proc push32*(this: var DataAccess, value: uint32): void = 
  var esp: uint32
  update_gpreg(ESP, -4)
  esp = get_gpreg(ESP)
  write_mem32_seg(SS, esp, value)

proc pop32*(this: var DataAccess): uint32 = 
  var value: uint32
  esp = get_gpreg(ESP)
  value = read_mem32_seg(SS, esp)
  update_gpreg(ESP, 4)
  return value

proc push16*(this: var DataAccess, value: uint16): void = 
  var sp: uint16
  update_gpreg(SP, -2)
  sp = get_gpreg(SP)
  write_mem16_seg(SS, sp, value)

proc pop16*(this: var DataAccess): uint16 = 
  var value: uint16
  sp = get_gpreg(SP)
  value = read_mem16_seg(SS, sp)
  update_gpreg(SP, 2)
  return value

proc read_mem32_seg*(this: var DataAccess, seg: sgreg_t, `addr`: uint32): uint32 = 
  var io_base: uint32
  paddr = trans_v2p(MODE_READ, seg, `addr`)
  return (if (io_base = chk_memio(paddr)):
            read_memio32(io_base, paddr - io_base)
          
          else:
            read_mem32(paddr)
          )

proc read_mem16_seg*(this: var DataAccess, seg: sgreg_t, `addr`: uint32): uint16 = 
  var io_base: uint32
  paddr = trans_v2p(MODE_READ, seg, `addr`)
  return (if (io_base = chk_memio(paddr)):
            read_memio16(io_base, paddr - io_base)
          
          else:
            read_mem16(paddr)
          )

proc read_mem8_seg*(this: var DataAccess, seg: sgreg_t, `addr`: uint32): uint8 = 
  var io_base: uint32
  paddr = trans_v2p(MODE_READ, seg, `addr`)
  return (if (io_base = chk_memio(paddr)):
            read_memio8(io_base, paddr - io_base)
          
          else:
            read_mem8(paddr)
          )

proc write_mem32_seg*(this: var DataAccess, seg: sgreg_t, `addr`: uint32, v: uint32): void = 
  var io_base: uint32
  paddr = trans_v2p(MODE_WRITE, seg, `addr`)
  if (io_base = chk_memio(paddr)):
    write_memio32(io_base, paddr - io_base, v)
  
  else:
    write_mem32(paddr, v)
  

proc write_mem16_seg*(this: var DataAccess, seg: sgreg_t, `addr`: uint32, v: uint16): void = 
  var io_base: uint32
  paddr = trans_v2p(MODE_WRITE, seg, `addr`)
  if (io_base = chk_memio(paddr)):
    write_memio16(io_base, paddr - io_base, v)
  
  else:
    write_mem16(paddr, v)
  

proc write_mem8_seg*(this: var DataAccess, seg: sgreg_t, `addr`: uint32, v: uint8): void = 
  var io_base: uint32
  paddr = trans_v2p(MODE_WRITE, seg, `addr`)
  if (io_base = chk_memio(paddr)):
    write_memio8(io_base, paddr - io_base, v)
  
  else:
    write_mem8(paddr, v)
  
