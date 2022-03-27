import emulator/interrupthpp
import std/deques
import device/[dev_irqhpp, pichpp]
import commonhpp
import ../device/piccpp
import hardware/[crhpp, processorhpp, memoryhpp, eflagshpp, hardwarehpp]
import emulator/exceptionhpp
import emulator/descriptorhpp
import emulator/accesshpp

proc saveRegs*(acs: var DataAccess, this: var Interrupt, chpl: bool, cs: uint16): void =
  if acs.cpu.isProtected():
    if chpl:
      var base, limit, esp: uint32
      var ss: uint16
      var tss: TSS
      base = acs.cpu.getDtregBase(TR)
      limit = acs.cpu.getDtregLimit(TR)
      EXCEPTION(EXPTS, limit < uint32(sizeof(TSS) - 1))
      acs.mem.readDataBlob(tss, base)
      ss = acs.getSegment(SS)
      esp = acs.cpu.getGpreg(ESP)
      acs.setSegment(SS, tss.ss0)
      acs.cpu.setGpreg(ESP, tss.esp0)
      INFO(
        4, "saveRegs (ESP : 0x%08x->0x%08x, SS : 0x%04x->0x%04x)",
        esp, tss.esp0, ss, tss.ss0)

      acs.push32(ss)
      acs.push32(esp)

    acs.push32(acs.cpu.eflags.getEflags())
    acs.push32(cs)
    acs.push32(acs.cpu.getEip())

  else:
    acs.push16(acs.cpu.eflags.getFlags())
    acs.push16(cs)
    acs.push16(acs.cpu.getIp().uint16)


proc hundleInterrupt*(acs: var DataAccess, this: var Interrupt): void =
  var intr: (uint8, bool)
  var n: uint8
  var cs: uint16
  var hard: bool
  if this.intrQ.len() == 0:
    return 
  
  intr = this.intrQ.popFirst()
  n = intr[0]
  hard = intr[1]

  if acs.cpu.isProtected():
    var idt: IntGateDesc
    var idtBase: uint32
    var idtOffset, idtLimit: uint16
    var RPL, CPL: uint8
    CPL = uint8(acs.getSegment(CS) and 3)
    idtBase = acs.cpu.getDtregBase(IDTR)
    idtLimit = acs.cpu.getDtregLimit(IDTR)
    idtOffset = n shl 3
    EXCEPTION(EXPGP, idtOffset > idtLimit)
    acs.mem.readDataBlob(idt, idtBase + idtOffset)

    {.warning: "[FIXME] 'RPL = idt.segSel.RPL'".}
    INFO(
      4, "int 0x%02x [CPL : %d, DPL : %d RPL : %d] (EIP : 0x%04x, CS : 0x%04x)",
      n, CPL, idt.DPL, RPL, (idt.offsetH shl 16) + idt.offsetL, idt.segSel)

    EXCEPTION(EXPNP, not(idt.P.toBool()))
    EXCEPTION(EXPGP, CPL < RPL)
    EXCEPTION(EXPGP, not(hard) and CPL > idt.DPL)
    cs = acs.getSegment(CS)
    acs.setSegment(CS, idt.segSel)
    acs.saveRegs(this, toBool(CPL xor RPL), cs)
    acs.cpu.setEip((idt.offsetH shl 16) + idt.offsetL)
    if idt.Type == TYPEINTERRUPT:
      acs.cpu.eflags.setInterrupt(false)
    
  
  else:
    var idtBase: uint32
    var idtOffset, idtLimit: uint16
    var ivt: IVT
    idtBase = acs.cpu.getDtregBase(IDTR)
    idtLimit = acs.cpu.getDtregLimit(IDTR)
    idtOffset = n shl 2
    EXCEPTION(EXPGP, idtOffset > idtLimit)
    ivt.raw = acs.mem.readMem32(idtBase + idtOffset)
    cs = acs.getSegment(CS)
    acs.setSegment(CS, ivt.segment)
    acs.saveRegs(this, false, cs)
    acs.cpu.setIp(ivt.offset)
    
    INFO(4, "int 0x%02x (IP : 0x%04x, CS : 0x%04x)", n, ivt.offset, ivt.segment)
  

proc chkIrq*(acs: DataAccess, this: var Interrupt): bool =
  var nIntr: int8
  if not(acs.cpu.eflags.isInterrupt()):
    return false
  
  if not(this.picM.toBool()) or not(this.picM.chk_intreq()):
    return false
  
  nIntr = this.picM.getNintr()
  if nIntr < 0:
    nIntr = this.picS.getNintr()
  
  queueInterrupt(this, nIntr.uint8, true)
  return true

