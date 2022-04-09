import common
import std/deques
import access
import device/pic

type
  IVT* {.bycopy, union.} = object
    raw*: uint32
    field1*: IVTField1

  IVTField1* {.bycopy.} = object
    offset*: uint16
    segment*: uint16

proc offset*(this: IVT): uint16 = this.field1.offset
proc `offset=`*(this: var IVT, value: uint16) = this.field1.offset = value
proc segment*(this: IVT): uint16 = this.field1.segment
proc `segment=`*(this: var IVT, value: uint16) = this.field1.segment = value

type
  Interrupt* = object
    intrQ*: Deque[(uint8, bool)]
    picS*, picM*: PIC

proc setPic*(this: var Interrupt, pic: PIC, master: bool): void =
  assertRef(pic)
  if master:
    this.picM = pic

  else:
    this.picS = pic

proc restoreRegs*(this: var Interrupt): void =
  discard

proc queueInterrupt*(this: var Interrupt, n: uint8, hard: bool): void =
  this.intrQ.addLast((n, hard))

proc iret*(this: var Interrupt): void =
  discard

import std/deques
import device/[pic]
import common
import device/pic
import hardware/[processor, memory, eflags, hardware]
import emulator/descriptor
import emulator/access

proc saveRegs*(acs: var DataAccess, this: var Interrupt, chpl: bool, cs: uint16): void =
  if acs.cpu.isProtected():
    if chpl:
      var base, limit, esp: uint32
      var ss: uint16
      var tss: TSS
      base = acs.cpu.getDtregBase(TR)
      limit = acs.cpu.getDtregLimit(TR)
      if limit < uint32(sizeof(TSS) - 1): raise newException(EXPTS, "")
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


proc handleInterrupt*(acs: var DataAccess, this: var Interrupt): void =
  acs.logger.logScope ev(eekInterruptHandler)

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
    var RPL, CPL: uint8
    CPL = uint8(acs.getSegment(CS) and 3)
    let idtBase: uint32 = acs.cpu.getDtregBase(IDTR)
    let idtOffset: uint16 = n shl 3
    let idtLimit: uint16 = acs.cpu.getDtregLimit(IDTR)
    if idtOffset > idtLimit:
      raise newException(EXP_GP, "idtOffset: $#, idtLimit: $#" % [
        $idtOffset, $idtLimit])

    var idt: IntGateDesc
    acs.mem.readDataBlob(idt, idtBase + idtOffset)

    {.warning: "[FIXME] 'RPL = idt.segSel.RPL'".}

    if not(idt.P.toBool()): raise newException(EXPNP, "")
    if CPL < RPL:
      raise newException(EXP_GP, "CPL: $#, RPL: $#" % [$CPL, $RPL])

    if not(hard) and CPL > idt.DPL: raise newException(EXPGP, "")
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
    if idtOffset > idtLimit:
      raise newException(EXP_GP, "idtOffset: $#, idtLimit: $#" % [
        $idtOffset, $idtLimit
      ])

    ivt.raw = acs.mem.readMem32(idtBase + idtOffset)
    cs = acs.getSegment(CS)
    acs.setSegment(CS, ivt.segment)
    acs.saveRegs(this, false, cs)
    acs.cpu.setIp(ivt.offset)

proc chkIrq*(acs: DataAccess, this: var Interrupt): bool =
  var nIntr: int8
  if not(acs.cpu.eflags.isInterrupt()):
    return false

  if not(this.picM.toBool()) or not(this.picM.chkIntreq()):
    return false

  nIntr = this.picM.getNintr()
  if nIntr < 0:
    nIntr = this.picS.getNintr()

  queueInterrupt(this, nIntr.uint8, true)
  return true
