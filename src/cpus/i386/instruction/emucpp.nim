import
  instruction/instructionhpp
import
  emulator/exceptionhpp
import
  emulator/descriptorhpp
proc type_descriptor*(this: var EmuInstr, sel: uint16): uint8 = 
  var gdt_base: uint32
  var gdt_limit: uint16
  var desc: Descriptor
  gdt_base = EMU.get_dtreg_base(GDTR)
  gdt_limit = EMU.get_dtreg_limit(GDTR)
  EXCEPTION(EXP_GP, sel > gdt_limit)
  EMU.read_data(addr desc, gdt_base + sel, sizeof((Descriptor)))
  if desc.S:
    if (cast[ptr SegDesc](addr desc)).`type`.segc:
      return TYPE_CODE
    
    else:
      return TYPE_DATA
    
  
  else:
    if desc.`type` == 3:
      return TYPE_TSS
    
  
  return desc.`type`

proc set_ldtr*(this: var EmuInstr, sel: uint16): void = 
  var base: uint32
  var limit: uint16
  var ldt: LDTDesc
  gdt_base = EMU.get_dtreg_base(GDTR)
  gdt_limit = EMU.get_dtreg_limit(GDTR)
  EXCEPTION(EXP_GP, sel > gdt_limit)
  EMU.read_data(addr ldt, gdt_base + sel, sizeof((LDTDesc)))
  base = (ldt.base_h shl 24) + (ldt.base_m shl 16) + ldt.base_l
  limit = (ldt.limit_h shl 16) + ldt.limit_l
  EMU.set_dtreg(LDTR, sel, base, limit)

proc set_tr*(this: var EmuInstr, sel: uint16): void = 
  var base: uint32
  var limit: uint16
  var tssdesc: TSSDesc
  gdt_base = EMU.get_dtreg_base(GDTR)
  gdt_limit = EMU.get_dtreg_limit(GDTR)
  EXCEPTION(EXP_GP, sel > gdt_limit)
  EMU.read_data(addr tssdesc, gdt_base + sel, sizeof((TSSDesc)))
  EXCEPTION(EXP_GP, tssdesc.`type` != TYPE_TSS)
  base = (tssdesc.base_h shl 24) + (tssdesc.base_m shl 16) + tssdesc.base_l
  limit = (tssdesc.limit_h shl 16) + tssdesc.limit_l
  EMU.set_dtreg(TR, sel, base, limit)

proc switch_task*(this: var EmuInstr, sel: uint16): void = 
  var base: uint32
  var limit: uint16
  var new_tss: TSS
  prev = EMU.get_dtreg_selector(TR)
  base = EMU.get_dtreg_base(TR)
  limit = EMU.get_dtreg_limit(TR)
  EXCEPTION(EXP_GP, limit < sizeof((TSS) - 1))
  EMU.read_data(addr old_tss, base, sizeof((TSS)))
  old_tss.cr3 = EMU.get_crn(3)
  old_tss.eip = EMU.get_eip()
  old_tss.eflags = EMU.get_eflags()
  old_tss.eax = EMU.get_gpreg(EAX)
  old_tss.ecx = EMU.get_gpreg(ECX)
  old_tss.edx = EMU.get_gpreg(EDX)
  old_tss.ebx = EMU.get_gpreg(EBX)
  old_tss.esp = EMU.get_gpreg(ESP)
  old_tss.ebp = EMU.get_gpreg(EBP)
  old_tss.esi = EMU.get_gpreg(ESI)
  old_tss.edi = EMU.get_gpreg(EDI)
  old_tss.es = EMU.get_segment(ES)
  old_tss.cs = EMU.get_segment(CS)
  old_tss.ss = EMU.get_segment(SS)
  old_tss.ds = EMU.get_segment(DS)
  old_tss.fs = EMU.get_segment(FS)
  old_tss.gs = EMU.get_segment(GS)
  old_tss.ldtr = EMU.get_dtreg_selector(LDTR)
  EMU.write_data(base, addr old_tss, sizeof((TSS)))
  set_tr(sel)
  base = EMU.get_dtreg_base(TR)
  limit = EMU.get_dtreg_limit(TR)
  EXCEPTION(EXP_GP, limit < sizeof((TSS) - 1))
  EMU.read_data(addr new_tss, base, sizeof((TSS)))
  new_tss.prev_sel = prev
  EMU.write_data(base, addr new_tss, sizeof((TSS)))
  EMU.set_crn(3, new_tss.cr3)
  EMU.set_eip(new_tss.eip)
  EMU.set_eflags(new_tss.eflags)
  EMU.set_gpreg(EAX, new_tss.eax)
  EMU.set_gpreg(ECX, new_tss.ecx)
  EMU.set_gpreg(EDX, new_tss.edx)
  EMU.set_gpreg(EBX, new_tss.ebx)
  EMU.set_gpreg(ESP, new_tss.esp)
  EMU.set_gpreg(EBP, new_tss.ebp)
  EMU.set_gpreg(ESI, new_tss.esi)
  EMU.set_gpreg(EDI, new_tss.edi)
  EMU.set_segment(ES, new_tss.es)
  EMU.set_segment(CS, new_tss.cs)
  EMU.set_segment(SS, new_tss.ss)
  EMU.set_segment(DS, new_tss.ds)
  EMU.set_segment(FS, new_tss.fs)
  EMU.set_segment(GS, new_tss.gs)
  set_ldtr(new_tss.ldtr)

proc jmpf*(this: var EmuInstr, sel: uint16, eip: uint32): void = 
  if EMU.is_protected():
    case type_descriptor(sel):
      of TYPE_CODE:
        cxx_goto jmp
      of TYPE_TSS:
        switch_task(sel)
        return 
  
  block jmp:
    INFO(2, "cs = 0x%04x, eip = 0x%08x", sel, eip)
  EMU.set_segment(CS, sel)
  EMU.set_eip(eip)

proc callf*(this: var EmuInstr, sel: uint16, eip: uint32): void = 
  var cs: SGRegister
  var RPL: uint8
  cs.raw = EMU.get_segment(CS)
  RPL = sel and 3
  if cs.RPL xor RPL:
    EXCEPTION(EXP_GP, RPL < cs.RPL)
    EMU.push32(EMU.get_segment(SS))
    EMU.push32(EMU.get_gpreg(ESP))
  
  EMU.push32(cs.raw)
  EMU.push32(EMU.get_eip())
  EMU.set_segment(CS, sel)
  EMU.set_eip(eip)

proc retf*(this: var EmuInstr): void = 
  var cs: SGRegister
  var CPL: uint8
  CPL = EMU.get_segment(CS) and 3
  EMU.set_eip(EMU.pop32())
  cs.raw = EMU.pop32()
  if cs.RPL xor CPL:
    var esp: uint32
    var ss: uint16
    esp = EMU.pop32()
    ss = EMU.pop32()
    EMU.set_gpreg(ESP, esp)
    EMU.set_segment(SS, ss)
  
  EMU.set_segment(CS, cs.raw)

proc iret*(this: var EmuInstr): void = 
  if is_mode32():
    var cs: SGRegister
    var CPL: uint8
    var eflags: EFLAGS
    CPL = EMU.get_segment(CS) and 3
    EMU.set_eip(EMU.pop32())
    cs.raw = EMU.pop32()
    eflags.reg32 = EMU.pop32()
    EMU.set_eflags(eflags.reg32)
    if eflags.NT:
      var base: uint32
      var tss: TSS
      base = EMU.get_dtreg_base(TR)
      EMU.read_data(addr tss, base, sizeof((TSS)))
      switch_task(tss.prev_sel)
    
    else:
      if cs.RPL > CPL:
        var esp: uint32
        var ss: uint16
        esp = EMU.pop32()
        ss = EMU.pop32()
        EMU.set_gpreg(ESP, esp)
        EMU.set_segment(SS, ss)
      
    
    EMU.set_segment(CS, cs.raw)
    INFO(4, "iret (EIP : 0x%08x, CS : 0x%04x)", EMU.get_eip(), EMU.get_segment(CS))
  
  else:
    var cs: uint16
    EMU.set_ip(EMU.pop16())
    cs = EMU.pop16()
    EMU.set_flags(EMU.pop16())
    EMU.set_segment(CS, cs)
    INFO(4, "iret (IP : 0x%04x, CS : 0x%04x)", EMU.get_ip(), EMU.get_segment(CS))
  

proc chk_ring*(this: var EmuInstr, DPL: uint8): bool = 
  var CPL: uint8
  CPL = EMU.get_segment(CS) and 3
  return CPL <= DPL
