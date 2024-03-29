import common

import instruction/instruction
import emulator/[access, descriptor]
import hardware/[processor, memory, cr, eflags]

proc typeDescriptor*(this: var ExecInstr, sel: U16): U8 =
  var gdtBase: U32
  var gdtLimit: U16
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

proc setLdtr*(this: var ExecInstr, sel: U16): void =
  var base, gdtBase: U32
  var limit, gdtLimit: U16
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

proc setTr*(this: var ExecInstr, sel: U16): void =
  var base, gdtBase: U32
  var limit, gdtLimit: U16
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

proc switchTask*(this: var ExecInstr, sel: U16): void =
  var base: U32
  var limit, prev: U16
  var newTss, oldTss: TSS
  prev = CPU.getDtregSelector(TR).U16
  base = CPU.getDtregBase(TR)
  limit = CPU.getDtregLimit(TR)
  if limit < (sizeof(TSS) - 1).U16:
    raise newException(EXP_GP, "limit: $#" % [$limit])

  MEM.readDataBlob(oldTss, base)
  oldTss.cr3 = CPU.getCrn(3)
  oldTss.eip = CPU.getEip()
  oldTss.eflags = CPU.eflags.getEflags()
  oldTss.eax = CPU[EAX]
  oldTss.ecx = CPU[ECX]
  oldTss.edx = CPU[EDX]
  oldTss.ebx = CPU[EBX]
  oldTss.esp = CPU[ESP]
  oldTss.ebp = CPU[EBP]
  oldTss.esi = CPU[ESI]
  oldTss.edi = CPU[EDI]
  oldTss.es = ACS.getSegment(ES)
  oldTss.cs = ACS.getSegment(CS)
  oldTss.ss = ACS.getSegment(SS)
  oldTss.ds = ACS.getSegment(DS)
  oldTss.fs = ACS.getSegment(FS)
  oldTss.gs = ACS.getSegment(GS)
  oldTss.ldtr = CPU.getDtregSelector(LDTR).U16
  MEM.writeDataBlob(base, oldTss)
  this.setTr(sel)
  base = CPU.getDtregBase(TR)
  limit = CPU.getDtregLimit(TR)
  if limit < (sizeof(TSS) - 1).U16:
    raise newException(EXP_GP, "limit: $#" % [$limit])

  MEM.readDataBlob(newTss, base)
  newTss.prevSel = prev
  MEM.writeDataBlob(base, newTss)
  CPU.setCrn(3, newTss.cr3)
  CPU.setEip(newTss.eip)
  CPU.eflags.setEflags(newTss.eflags)
  CPU[EAX] = newTss.eax
  CPU[ECX] = newTss.ecx
  CPU[EDX] = newTss.edx
  CPU[EBX] = newTss.ebx
  CPU[ESP] = newTss.esp
  CPU[EBP] = newTss.ebp
  CPU[ESI] = newTss.esi
  CPU[EDI] = newTss.edi
  ACS.setSegment(ES, newTss.es)
  ACS.setSegment(CS, newTss.cs)
  ACS.setSegment(SS, newTss.ss)
  ACS.setSegment(DS, newTss.ds)
  ACS.setSegment(FS, newTss.fs)
  ACS.setSegment(GS, newTss.gs)
  this.setLdtr(newTss.ldtr)

proc jmpf*(this: var ExecInstr, sel: U16, eip: U32): void =
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

proc callf*(this: var ExecInstr, sel: U16, eip: U32): void =
  var cs: SGRegister
  cs.raw = ACS.getSegment(CS)
  var RPL: U8 = U8(sel and 3)
  if toBool(cs.RPL xor RPL):
    if RPL < cs.RPL: raise newException(EXPGP, "")
    ACS.push32(ACS.getSegment(SS))
    ACS.push32(CPU[ESP])
  
  ACS.push32(cs.raw)
  ACS.push32(CPU.getEip())
  ACS.setSegment(CS, sel)
  CPU.setEip(eip)

proc retf*(this: var ExecInstr): void =
  var cs: SGRegister
  var CPL: U8 = U8(ACS.getSegment(CS) and 3)
  CPU.setEip(ACS.pop32())
  cs.raw = ACS.pop32().U16
  if toBool(cs.RPL xor CPL):
    var esp: U32
    var ss: U16
    esp = ACS.pop32()
    ss = ACS.pop32().U16
    CPU[ESP] = esp
    ACS.setSegment(SS, ss)
  
  ACS.setSegment(CS, cs.raw)

proc iret*(this: var ExecInstr): void =
  if CPU.isMode32():
    var cs: SGRegister
    var eflags: EFLAGS
    var CPL: U8 = U8(ACS.getSegment(CS) and 3)
    CPU.setEip(ACS.pop32())
    cs.raw = ACS.pop32().U16
    eflags.eflags.reg32 = ACS.pop32()
    CPU.eflags.setEflags(eflags.eflags.reg32)
    if toBool(eflags.eflags.NT):
      var base: U32
      var tss: TSS
      base = CPU.getDtregBase(TR)
      MEM.readDataBlob(tss, base)
      this.switchTask(tss.prevSel)
    
    elif cs.RPL > CPL:
      var esp: U32
      var ss: U16
      esp = ACS.pop32()
      ss = ACS.pop32().U16
      CPU[ESP] = esp
      ACS.setSegment(SS, ss)

    ACS.setSegment(CS, cs.raw)

  else:
    var cs: U16
    CPU.setIp(ACS.pop16())
    cs = ACS.pop16()
    CPU.eflags.setFlags(ACS.pop16())
    ACS.setSegment(CS, cs)

proc chkRing*(this: var ExecInstr, DPL: U8): bool =
  var CPL: U8
  CPL = U8(ACS.getSegment(CS) and 3)
  return CPL <= DPL
