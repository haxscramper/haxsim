import emulator/interrupthpp
import std/deques
import commonhpp
import ../device/piccpp
import hardware/[crhpp, processorhpp, memoryhpp, eflagshpp]
import emulator/exceptionhpp
import emulator/descriptorhpp
import emulator/accesshpp

proc save_regs*(this: var Interrupt, chpl: bool, cs: uint16): void =
  if this.cpu.is_protected():
    if chpl:
      var base, limit, esp: uint32
      var ss: uint16
      var tss: TSS
      base = this.cpu.get_dtreg_base(TR)
      limit = this.cpu.get_dtreg_limit(TR)
      EXCEPTION(EXP_TS, limit < uint32(sizeof(TSS) - 1))
      discard this.mem.read_data(addr tss, base, sizeof(TSS).csize_t)
      ss = this.get_segment(SS)
      esp = this.cpu.get_gpreg(ESP)
      this.set_segment(SS, tss.ss0)
      this.cpu.set_gpreg(ESP, tss.esp0)
      INFO(
        4, "save_regs (ESP : 0x%08x->0x%08x, SS : 0x%04x->0x%04x)",
        esp, tss.esp0, ss, tss.ss0)

      this.push32(ss)
      this.push32(esp)

    this.push32(this.cpu.eflags.get_eflags())
    this.push32(cs)
    this.push32(this.cpu.get_eip())

  else:
    this.push16(this.cpu.eflags.get_flags())
    this.push16(cs)
    this.push16(this.cpu.get_ip().uint16)


proc hundle_interrupt*(this: var Interrupt): void = 
  var intr: (uint8, bool)
  var n: uint8
  var cs: uint16
  var hard: bool
  if this.intr_q.len() == 0:
    return 
  
  intr = this.intr_q.popFirst()
  n = intr[0]
  hard = intr[1]

  if this.cpu.is_protected():
    var idt: IntGateDesc
    var idt_base: uint32
    var idt_offset, idt_limit: uint16
    var RPL, CPL: uint8
    CPL = uint8(this.get_segment(CS) and 3)
    idt_base = this.cpu.get_dtreg_base(IDTR)
    idt_limit = this.cpu.get_dtreg_limit(IDTR)
    idt_offset = n shl 3
    EXCEPTION(EXP_GP, idt_offset > idt_limit)
    discard this.mem.read_data(
      addr idt, idt_base + idt_offset, sizeof(IntGateDesc).csize_t)

    RPL = idt.seg_sel.RPL
    INFO(
      4, "int 0x%02x [CPL : %d, DPL : %d RPL : %d] (EIP : 0x%04x, CS : 0x%04x)",
      n, CPL, idt.DPL, RPL, (idt.offset_h shl 16) + idt.offset_l, idt.seg_sel)

    EXCEPTION(EXP_NP, not(idt.P.toBool()))
    EXCEPTION(EXP_GP, CPL < RPL)
    EXCEPTION(EXP_GP, not(hard) and CPL > idt.DPL)
    cs = this.get_segment(CS)
    this.set_segment(CS, idt.seg_sel)
    this.save_regs(CPL xor RPL, cs)
    this.cpu.set_eip((idt.offset_h shl 16) + idt.offset_l)
    if idt.`type` == TYPE_INTERRUPT:
      this.cpu.eflags.set_interrupt(false)
    
  
  else:
    var idt_base: uint32
    var idt_offset, idt_limit: uint16
    var ivt: IVT
    idt_base = this.cpu.get_dtreg_base(IDTR)
    idt_limit = this.cpu.get_dtreg_limit(IDTR)
    idt_offset = n shl 2
    EXCEPTION(EXP_GP, idt_offset > idt_limit)
    ivt.raw = this.mem.read_mem32(idt_base + idt_offset)
    cs = this.get_segment(CS)
    this.set_segment(CS, ivt.segment)
    this.save_regs(false, cs)
    this.cpu.set_ip(ivt.offset)
    
    INFO(4, "int 0x%02x (IP : 0x%04x, CS : 0x%04x)", n, ivt.offset, ivt.segment)
  

proc chk_irq*(this: var Interrupt): bool = 
  var n_intr: int8
  if not(this.cpu.eflags.is_interrupt()):
    return false
  
  if not(this.pic_m.toBool()) or not(this.pic_m.chk_intreq()):
    return false
  
  n_intr = this.pic_m.get_nintr()
  if n_intr < 0:
    n_intr = this.pic_s.get_nintr()
  
  queue_interrupt(n_intr, true)
  return true

