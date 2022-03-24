import emulator/interrupthpp
import std/deques
import commonhpp
import ../device/piccpp
import hardware/[crhpp, processorhpp, memoryhpp, eflagshpp]
import emulator/exceptionhpp
import emulator/descriptorhpp
import emulator/accesshpp

proc saveRegs*(this: var Interrupt, chpl: bool, cs: uint16): void =
  if this.cpu.isProtected():
    if chpl:
      var base, limit, esp: uint32
      var ss: uint16
      var tss: TSS
      base = this.cpu.getDtregBase(TR)
      limit = this.cpu.getDtregLimit(TR)
      EXCEPTION(EXPTS, limit < uint32(sizeof(TSS) - 1))
      discard this.mem.readData(addr tss, base, sizeof(TSS).csizeT)
      ss = this.getSegment(SS)
      esp = this.cpu.getGpreg(ESP)
      this.setSegment(SS, tss.ss0)
      this.cpu.setGpreg(ESP, tss.esp0)
      INFO(
        4, "saveRegs (ESP : 0x%08x->0x%08x, SS : 0x%04x->0x%04x)",
        esp, tss.esp0, ss, tss.ss0)

      this.push32(ss)
      this.push32(esp)

    this.push32(this.cpu.eflags.getEflags())
    this.push32(cs)
    this.push32(this.cpu.getEip())

  else:
    this.push16(this.cpu.eflags.getFlags())
    this.push16(cs)
    this.push16(this.cpu.getIp().uint16)


proc hundleInterrupt*(this: var Interrupt): void =
  var intr: (uint8, bool)
  var n: uint8
  var cs: uint16
  var hard: bool
  if this.intrQ.len() == 0:
    return 
  
  intr = this.intrQ.popFirst()
  n = intr[0]
  hard = intr[1]

  if this.cpu.isProtected():
    var idt: IntGateDesc
    var idtBase: uint32
    var idtOffset, idtLimit: uint16
    var RPL, CPL: uint8
    CPL = uint8(this.getSegment(CS) and 3)
    idtBase = this.cpu.getDtregBase(IDTR)
    idtLimit = this.cpu.getDtregLimit(IDTR)
    idtOffset = n shl 3
    EXCEPTION(EXPGP, idtOffset > idtLimit)
    discard this.mem.readData(
      addr idt, idtBase + idtOffset, sizeof(IntGateDesc).csizeT)

    {.warning: "[FIXME] 'RPL = idt.segSel.RPL'".}
    INFO(
      4, "int 0x%02x [CPL : %d, DPL : %d RPL : %d] (EIP : 0x%04x, CS : 0x%04x)",
      n, CPL, idt.DPL, RPL, (idt.offsetH shl 16) + idt.offsetL, idt.segSel)

    EXCEPTION(EXPNP, not(idt.P.toBool()))
    EXCEPTION(EXPGP, CPL < RPL)
    EXCEPTION(EXPGP, not(hard) and CPL > idt.DPL)
    cs = this.getSegment(CS)
    this.setSegment(CS, idt.segSel)
    this.saveRegs(toBool(CPL xor RPL), cs)
    this.cpu.setEip((idt.offsetH shl 16) + idt.offsetL)
    if idt.Type == TYPEINTERRUPT:
      this.cpu.eflags.setInterrupt(false)
    
  
  else:
    var idtBase: uint32
    var idtOffset, idtLimit: uint16
    var ivt: IVT
    idtBase = this.cpu.getDtregBase(IDTR)
    idtLimit = this.cpu.getDtregLimit(IDTR)
    idtOffset = n shl 2
    EXCEPTION(EXPGP, idtOffset > idtLimit)
    ivt.raw = this.mem.readMem32(idtBase + idtOffset)
    cs = this.getSegment(CS)
    this.setSegment(CS, ivt.segment)
    this.saveRegs(false, cs)
    this.cpu.setIp(ivt.offset)
    
    INFO(4, "int 0x%02x (IP : 0x%04x, CS : 0x%04x)", n, ivt.offset, ivt.segment)
  

proc chkIrq*(this: var Interrupt): bool =
  var nIntr: int8
  if not(this.cpu.eflags.isInterrupt()):
    return false
  
  if not(this.picM.toBool()) or not(this.picM[].chkIntreq()):
    return false
  
  nIntr = this.picM[].getNintr()
  if nIntr < 0:
    nIntr = this.picS[].getNintr()
  
  queueInterrupt(this, nIntr.uint8, true)
  return true

