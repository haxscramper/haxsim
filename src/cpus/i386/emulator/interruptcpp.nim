import
  map
import
  emulator/interrupthpp
import
  emulator/exceptionhpp
import
  emulator/descriptorhpp
proc hundle_interrupt*(this: var Interrupt): void = 
  var intr: [uint8, bool]
  var n: uint8
  var cs: uint16
  var hard: bool
  if intr_q.empty():
    return 
  
  intr = intr_q.front()
  intr_q.pop()
  n = intr.first
  hard = intr.second
  if is_protected():
    var idt: IntGateDesc
    var idt_base: uint32
    var idt_offset: uint16
    var RPL: uint8
    CPL = get_segment(CS) and 3
    idt_base = get_dtreg_base(IDTR)
    idt_limit = get_dtreg_limit(IDTR)
    idt_offset = n shl 3
    EXCEPTION(EXP_GP, idt_offset > idt_limit)
    read_data(addr idt, idt_base + idt_offset, sizeof((IntGateDesc)))
    RPL = (cast[ptr SGRegister](addr (idt.seg_sel)().RPL
    INFO(4, "int 0x%02x [CPL : %d, DPL : %d RPL : %d] (EIP : 0x%04x, CS : 0x%04x)", n, CPL, idt.DPL, RPL, (idt.offset_h shl 16) + idt.offset_l, idt.seg_sel)
    EXCEPTION(EXP_NP, not(idt.P))
    EXCEPTION(EXP_GP, CPL < RPL)
    EXCEPTION(EXP_GP, not(hard) and CPL > idt.DPL)
    cs = get_segment(CS)
    set_segment(CS, idt.seg_sel)
    save_regs(CPL xor RPL, cs)
    set_eip((idt.offset_h shl 16) + idt.offset_l)
    if idt.`type` == TYPE_INTERRUPT:
      set_interrupt(false)
    
  
  else:
    var idt_base: uint32
    var idt_offset: uint16
    var ivt: IVT
    idt_base = get_dtreg_base(IDTR)
    idt_limit = get_dtreg_limit(IDTR)
    idt_offset = n shl 2
    EXCEPTION(EXP_GP, idt_offset > idt_limit)
    ivt.raw = read_mem32(idt_base + idt_offset)
    cs = get_segment(CS)
    set_segment(CS, ivt.segment)
    save_regs(false, cs)
    set_ip(ivt.offset)
    
    INFO(4, "int 0x%02x (IP : 0x%04x, CS : 0x%04x)", n, ivt.offset, ivt.segment)
  

proc chk_irq*(this: var Interrupt): bool = 
  var n_intr: int8
  if not(is_interrupt()):
    return false
  
  if not(pic_m) or not(pic_m.chk_intreq()):
    return false
  
  n_intr = pic_m.get_nintr()
  if n_intr < 0:
    n_intr = pic_s.get_nintr()
  
  queue_interrupt(n_intr, true)
  return true

proc save_regs*(this: var Interrupt, chpl: bool, cs: uint16): void = 
  if is_protected():
    if chpl:
      var esp: uint32
      var ss: uint16
      var tss: TSS
      base = get_dtreg_base(TR)
      limit = get_dtreg_limit(TR)
      EXCEPTION(EXP_TS, limit < sizeof((TSS) - 1))
      read_data(addr tss, base, sizeof((TSS)))
      ss = get_segment(SS)
      esp = get_gpreg(ESP)
      set_segment(SS, tss.ss0)
      set_gpreg(ESP, tss.esp0)
      INFO(4, "save_regs (ESP : 0x%08x->0x%08x, SS : 0x%04x->0x%04x)", esp, tss.esp0, ss, tss.ss0)
      push32(ss)
      push32(esp)
    
    push32(get_eflags())
    push32(cs)
    push32(get_eip())
  
  else:
    push16(get_flags())
    push16(cs)
    push16(get_ip())
  
