import common

import instruction/instruction
import emulator/[access, descriptor]
import hardware/[processor, memory, cr, eflags]

proc typeDescriptor*(this: var ExecInstr, sel: uint16): uint8 =
  var gdtBase: uint32
  var gdtLimit: uint16
  var desc: Descriptor
  gdtBase = CPU.getDtregBase(GDTR)
  gdtLimit = CPU.getDtregLimit(GDTR)
  if gdtLimit < sel:
    raise newException(
      EXP_GP, "gdt limit: $#, selector: $#" % [$gdtLimit, $sel])

  MEM.readDataBlob(desc, gdtBase + sel)

  if desc.S.toBool():
    if getType(cast[ptr SegDesc](addr desc)[]).segc.toBool():
      return TYPECODE
    
    else:
      return TYPEDATA
    
  
  else:
    if desc.`Type` == 3:
      return TYPETSS
    
  
  return desc.Type

proc setLdtr*(this: var ExecInstr, sel: uint16): void =
  var base, gdtBase: uint32
  var limit, gdtLimit: uint16
  var ldt: LDTDesc
  gdtBase = CPU.getDtregBase(GDTR)
  gdtLimit = CPU.getDtregLimit(GDTR)
  if gdtLimit < sel:
    raise newException(
      EXP_GP, "gdt limit: $#, selector: $#" % [$gdtLimit, $sel])

  MEM.readDataBlob(ldt, gdtBase + sel)
  base = (ldt.baseH shl 24) + (ldt.baseM shl 16) + ldt.baseL
  limit = (ldt.limitH shl 16) + ldt.limitL
  CPU.setDtreg(LDTR, sel, base, limit)

proc setTr*(this: var ExecInstr, sel: uint16): void =
  var base, gdtBase: uint32
  var limit, gdtLimit: uint16
  var tssdesc: TSSDesc
  gdtBase = CPU.getDtregBase(GDTR)
  gdtLimit = CPU.getDtregLimit(GDTR)
  if gdtLimit < sel:
    raise newException(
      EXP_GP, "gdt limit: $#, selector: $#" % [$gdtLimit, $sel])
  MEM.readDataBlob(tssdesc, gdtBase + sel)
  if tssdesc.getType() != TYPETSS:
    raise newException(EXP_GP, "tssdesc: $#" % [$tssdesc])

  base = (tssdesc.baseH shl 24) + (tssdesc.baseM shl 16) + tssdesc.baseL
  limit = (tssdesc.limitH shl 16) + tssdesc.limitL
  CPU.setDtreg(TR, sel, base, limit)

proc switchTask*(this: var ExecInstr, sel: uint16): void =
  var base: uint32
  var limit, prev: uint16
  var newTss, oldTss: TSS
  prev = CPU.getDtregSelector(TR).uint16
  base = CPU.getDtregBase(TR)
  limit = CPU.getDtregLimit(TR)
  if limit < (sizeof(TSS) - 1).uint16:
    raise newException(EXP_GP, "limit: $#" % [$limit])

  MEM.readDataBlob(oldTss, base)
  oldTss.cr3 = CPU.getCrn(3)
  oldTss.eip = CPU.getEip()
  oldTss.eflags = CPU.eflags.getEflags()
  oldTss.eax = CPU.getGpreg(EAX)
  oldTss.ecx = CPU.getGpreg(ECX)
  oldTss.edx = CPU.getGpreg(EDX)
  oldTss.ebx = CPU.getGpreg(EBX)
  oldTss.esp = CPU.getGpreg(ESP)
  oldTss.ebp = CPU.getGpreg(EBP)
  oldTss.esi = CPU.getGpreg(ESI)
  oldTss.edi = CPU.getGpreg(EDI)
  oldTss.es = ACS.getSegment(ES)
  oldTss.cs = ACS.getSegment(CS)
  oldTss.ss = ACS.getSegment(SS)
  oldTss.ds = ACS.getSegment(DS)
  oldTss.fs = ACS.getSegment(FS)
  oldTss.gs = ACS.getSegment(GS)
  oldTss.ldtr = CPU.getDtregSelector(LDTR).uint16
  MEM.writeDataBlob(base, oldTss)
  this.setTr(sel)
  base = CPU.getDtregBase(TR)
  limit = CPU.getDtregLimit(TR)
  if limit < (sizeof(TSS) - 1).uint16:
    raise newException(EXP_GP, "limit: $#" % [$limit])

  MEM.readDataBlob(newTss, base)
  newTss.prevSel = prev
  MEM.writeDataBlob(base, newTss)
  CPU.setCrn(3, newTss.cr3)
  CPU.setEip(newTss.eip)
  CPU.eflags.setEflags(newTss.eflags)
  CPU.setGpreg(EAX, newTss.eax)
  CPU.setGpreg(ECX, newTss.ecx)
  CPU.setGpreg(EDX, newTss.edx)
  CPU.setGpreg(EBX, newTss.ebx)
  CPU.setGpreg(ESP, newTss.esp)
  CPU.setGpreg(EBP, newTss.ebp)
  CPU.setGpreg(ESI, newTss.esi)
  CPU.setGpreg(EDI, newTss.edi)
  ACS.setSegment(ES, newTss.es)
  ACS.setSegment(CS, newTss.cs)
  ACS.setSegment(SS, newTss.ss)
  ACS.setSegment(DS, newTss.ds)
  ACS.setSegment(FS, newTss.fs)
  ACS.setSegment(GS, newTss.gs)
  this.setLdtr(newTss.ldtr)

proc jmpf*(this: var ExecInstr, sel: uint16, eip: uint32): void =
  if CPU.isProtected():
    case this.typeDescriptor(sel):
      of TYPECODE:
        # cxxGoto jmp
        discard

      of TYPETSS:
        switchTask(this, sel)
        return

      else:
        discard
  
  block jmp:
    INFO(2, "cs = 0x%04x, eip = 0x%08x", sel, eip)
    ACS.setSegment(CS, sel)
    CPU.setEip(eip)

proc callf*(this: var ExecInstr, sel: uint16, eip: uint32): void =
  var cs: SGRegister
  var RPL: uint8
  cs.raw = ACS.getSegment(CS)
  RPL = uint8(sel and 3)
  if toBool(cs.RPL xor RPL):
    EXCEPTION(EXPGP, RPL < cs.RPL)
    ACS.push32(ACS.getSegment(SS))
    ACS.push32(CPU.getGpreg(ESP))
  
  ACS.push32(cs.raw)
  ACS.push32(CPU.getEip())
  ACS.setSegment(CS, sel)
  CPU.setEip(eip)

proc retf*(this: var ExecInstr): void =
  var cs: SGRegister
  var CPL: uint8
  CPL = uint8(ACS.getSegment(CS) and 3)
  CPU.setEip(ACS.pop32())
  cs.raw = ACS.pop32().uint16
  if toBool(cs.RPL xor CPL):
    var esp: uint32
    var ss: uint16
    esp = ACS.pop32()
    ss = ACS.pop32().uint16
    CPU.setGpreg(ESP, esp)
    ACS.setSegment(SS, ss)
  
  ACS.setSegment(CS, cs.raw)

proc iret*(this: var ExecInstr): void =
  if CPU.isMode32():
    var cs: SGRegister
    var CPL: uint8
    var eflags: EFLAGS
    CPL = uint8(ACS.getSegment(CS) and 3)
    CPU.setEip(ACS.pop32())
    cs.raw = ACS.pop32().uint16
    eflags.eflags.reg32 = ACS.pop32()
    CPU.eflags.setEflags(eflags.eflags.reg32)
    if toBool(eflags.eflags.NT):
      var base: uint32
      var tss: TSS
      base = CPU.getDtregBase(TR)
      MEM.readDataBlob(tss, base)
      this.switchTask(tss.prevSel)
    
    else:
      if cs.RPL > CPL:
        var esp: uint32
        var ss: uint16
        esp = ACS.pop32()
        ss = ACS.pop32().uint16
        CPU.setGpreg(ESP, esp)
        ACS.setSegment(SS, ss)

    ACS.setSegment(CS, cs.raw)
    INFO(4, "iret (EIP : 0x%08x, CS : 0x%04x)", EMU.getEip(), EMU.getSegment(CS))
  
  else:
    var cs: uint16
    CPU.setIp(ACS.pop16())
    cs = ACS.pop16()
    CPU.eflags.setFlags(ACS.pop16())
    ACS.setSegment(CS, cs)
    INFO(4, "iret (IP : 0x%04x, CS : 0x%04x)", EMU.getIp(), EMU.getSegment(CS))
  

proc chkRing*(this: var ExecInstr, DPL: uint8): bool =
  var CPL: uint8
  CPL = uint8(ACS.getSegment(CS) and 3)
  return CPL <= DPL
