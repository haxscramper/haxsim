import instruction/instructionhpp
import commonhpp
import emulator/[exceptionhpp, accesshpp]
import emulator/descriptorhpp
import hardware/[processorhpp, memoryhpp, crhpp, eflagshpp]

proc type_descriptor*(this: var EmuInstr, sel: uint16): uint8 = 
  var gdt_base: uint32
  var gdt_limit: uint16
  var desc: Descriptor
  gdt_base = CPU.get_dtreg_base(GDTR)
  gdt_limit = CPU.get_dtreg_limit(GDTR)
  EXCEPTION(EXP_GP, sel > gdt_limit)
  discard ACS.mem.read_data(
    addr desc, gdt_base + sel, sizeof(Descriptor).csize_t)

  if desc.S.toBool():
    if getType(cast[ptr SegDesc](addr desc)[]).segc.toBool():
      return TYPE_CODE
    
    else:
      return TYPE_DATA
    
  
  else:
    if desc.`Type` == 3:
      return TYPE_TSS
    
  
  return desc.Type

proc set_ldtr*(this: var EmuInstr, sel: uint16): void = 
  var base, gdt_base: uint32
  var limit, gdt_limit: uint16
  var ldt: LDTDesc
  gdt_base = CPU.get_dtreg_base(GDTR)
  gdt_limit = CPU.get_dtreg_limit(GDTR)
  EXCEPTION(EXP_GP, sel > gdt_limit)
  discard ACS.mem.read_data(addr ldt, gdt_base + sel, sizeof(LDTDesc).csize_t)
  base = (ldt.base_h shl 24) + (ldt.base_m shl 16) + ldt.base_l
  limit = (ldt.limit_h shl 16) + ldt.limit_l
  CPU.set_dtreg(LDTR, sel, base, limit)

proc set_tr*(this: var EmuInstr, sel: uint16): void = 
  var base, gdt_base: uint32
  var limit, gdt_limit: uint16
  var tssdesc: TSSDesc
  gdt_base = CPU.get_dtreg_base(GDTR)
  gdt_limit = CPU.get_dtreg_limit(GDTR)
  EXCEPTION(EXP_GP, sel > gdt_limit)
  discard MEM.read_data(addr tssdesc, gdt_base + sel, sizeof(TSSDesc).csize_t)
  EXCEPTION(EXP_GP, tssdesc.getType() != TYPE_TSS)
  base = (tssdesc.base_h shl 24) + (tssdesc.base_m shl 16) + tssdesc.base_l
  limit = (tssdesc.limit_h shl 16) + tssdesc.limit_l
  CPU.set_dtreg(TR, sel, base, limit)

proc switch_task*(this: var EmuInstr, sel: uint16): void = 
  var base: uint32
  var limit, prev: uint16
  var new_tss, old_tss: TSS
  prev = CPU.get_dtreg_selector(TR).uint16
  base = CPU.get_dtreg_base(TR)
  limit = CPU.get_dtreg_limit(TR)
  EXCEPTION(EXP_GP, limit < (sizeof(TSS) - 1).uint16)
  discard MEM.read_data(addr old_tss, base, sizeof(TSS).csize_t)
  old_tss.cr3 = CPU.get_crn(3)
  old_tss.eip = CPU.get_eip()
  old_tss.eflags = CPU.eflags.get_eflags()
  old_tss.eax = CPU.get_gpreg(EAX)
  old_tss.ecx = CPU.get_gpreg(ECX)
  old_tss.edx = CPU.get_gpreg(EDX)
  old_tss.ebx = CPU.get_gpreg(EBX)
  old_tss.esp = CPU.get_gpreg(ESP)
  old_tss.ebp = CPU.get_gpreg(EBP)
  old_tss.esi = CPU.get_gpreg(ESI)
  old_tss.edi = CPU.get_gpreg(EDI)
  old_tss.es = ACS.get_segment(ES)
  old_tss.cs = ACS.get_segment(CS)
  old_tss.ss = ACS.get_segment(SS)
  old_tss.ds = ACS.get_segment(DS)
  old_tss.fs = ACS.get_segment(FS)
  old_tss.gs = ACS.get_segment(GS)
  old_tss.ldtr = CPU.get_dtreg_selector(LDTR).uint16
  discard MEM.write_data(base, addr old_tss, sizeof(TSS).csize_t)
  this.set_tr(sel)
  base = CPU.get_dtreg_base(TR)
  limit = CPU.get_dtreg_limit(TR)
  EXCEPTION(EXP_GP, limit < uint16(sizeof(TSS) - 1))
  discard MEM.read_data(addr new_tss, base, sizeof(TSS).csize_t)
  new_tss.prev_sel = prev
  discard MEM.write_data(base, addr new_tss, sizeof(TSS).csize_t)
  CPU.set_crn(3, new_tss.cr3)
  CPU.set_eip(new_tss.eip)
  CPU.eflags.set_eflags(new_tss.eflags)
  CPU.set_gpreg(EAX, new_tss.eax)
  CPU.set_gpreg(ECX, new_tss.ecx)
  CPU.set_gpreg(EDX, new_tss.edx)
  CPU.set_gpreg(EBX, new_tss.ebx)
  CPU.set_gpreg(ESP, new_tss.esp)
  CPU.set_gpreg(EBP, new_tss.ebp)
  CPU.set_gpreg(ESI, new_tss.esi)
  CPU.set_gpreg(EDI, new_tss.edi)
  ACS.set_segment(ES, new_tss.es)
  ACS.set_segment(CS, new_tss.cs)
  ACS.set_segment(SS, new_tss.ss)
  ACS.set_segment(DS, new_tss.ds)
  ACS.set_segment(FS, new_tss.fs)
  ACS.set_segment(GS, new_tss.gs)
  this.set_ldtr(new_tss.ldtr)

proc jmpf*(this: var EmuInstr, sel: uint16, eip: uint32): void = 
  if CPU.is_protected():
    case this.type_descriptor(sel):
      of TYPE_CODE:
        # cxx_goto jmp
        discard

      of TYPE_TSS:
        switch_task(this, sel)
        return

      else:
        discard
  
  block jmp:
    INFO(2, "cs = 0x%04x, eip = 0x%08x", sel, eip)
    ACS.set_segment(CS, sel)
    CPU.set_eip(eip)

proc callf*(this: var EmuInstr, sel: uint16, eip: uint32): void = 
  var cs: SGRegister
  var RPL: uint8
  cs.raw = ACS.get_segment(CS)
  RPL = uint8(sel and 3)
  if toBool(cs.RPL xor RPL):
    EXCEPTION(EXP_GP, RPL < cs.RPL)
    ACS.push32(ACS.get_segment(SS))
    ACS.push32(CPU.get_gpreg(ESP))
  
  ACS.push32(cs.raw)
  ACS.push32(CPU.get_eip())
  ACS.set_segment(CS, sel)
  CPU.set_eip(eip)

proc retf*(this: var EmuInstr): void = 
  var cs: SGRegister
  var CPL: uint8
  CPL = uint8(ACS.get_segment(CS) and 3)
  CPU.set_eip(ACS.pop32())
  cs.raw = ACS.pop32().uint16
  if toBool(cs.RPL xor CPL):
    var esp: uint32
    var ss: uint16
    esp = ACS.pop32()
    ss = ACS.pop32().uint16
    CPU.set_gpreg(ESP, esp)
    ACS.set_segment(SS, ss)
  
  ACS.set_segment(CS, cs.raw)

proc iret*(this: var EmuInstr): void = 
  if CPU.is_mode32():
    var cs: SGRegister
    var CPL: uint8
    var eflags: EFLAGS
    CPL = uint8(ACS.get_segment(CS) and 3)
    CPU.set_eip(ACS.pop32())
    cs.raw = ACS.pop32().uint16
    eflags.eflags.reg32 = ACS.pop32()
    CPU.eflags.set_eflags(eflags.eflags.reg32)
    if toBool(eflags.eflags.NT):
      var base: uint32
      var tss: TSS
      base = CPU.get_dtreg_base(TR)
      discard MEM.read_data(addr tss, base, sizeof(TSS).csize_t)
      this.switch_task(tss.prev_sel)
    
    else:
      if cs.RPL > CPL:
        var esp: uint32
        var ss: uint16
        esp = ACS.pop32()
        ss = ACS.pop32().uint16
        CPU.set_gpreg(ESP, esp)
        ACS.set_segment(SS, ss)

    ACS.set_segment(CS, cs.raw)
    INFO(4, "iret (EIP : 0x%08x, CS : 0x%04x)", EMU.get_eip(), EMU.get_segment(CS))
  
  else:
    var cs: uint16
    CPU.set_ip(ACS.pop16())
    cs = ACS.pop16()
    CPU.eflags.set_flags(ACS.pop16())
    ACS.set_segment(CS, cs)
    INFO(4, "iret (IP : 0x%04x, CS : 0x%04x)", EMU.get_ip(), EMU.get_segment(CS))
  

proc chk_ring*(this: var EmuInstr, DPL: uint8): bool = 
  var CPL: uint8
  CPL = uint8(ACS.get_segment(CS) and 3)
  return CPL <= DPL
