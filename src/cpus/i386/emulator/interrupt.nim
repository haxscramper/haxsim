import common
import std/deques
import access
import device/pic

type
  IVT* = object
    offset*: uint16
    segment*: uint16

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
  ## Store values of the current register, code segment on stack
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

  if this.intrQ.len() == 0:
    return

  let (n, hard) = this.intrQ.popFirst()

  if acs.cpu.isProtected():
    var RPL: uint8
    var CPL: uint8 = uint8(acs.getSegment(CS) and 3)
    let idtBase: uint32 = acs.cpu.getDtregBase(IDTR)
    let idtOffset: uint16 = n shl 3
    let idtLimit: uint16 = acs.cpu.getDtregLimit(IDTR)
    if idtOffset > idtLimit:
      raise newException(EXP_GP, "idtOffset: $#, idtLimit: $#" % [
        $idtOffset, $idtLimit])

    var idt = acs.mem.readDataBlob[:IntGateDesc](idtBase + idtOffset)

    var segSel = addr idt.seg_sel
    RPL = cast[ptr SGregister](segSel)[].RPL.uint8()

    if not(idt.P.toBool()): raise newException(EXPNP, "")
    if CPL < RPL:
      raise newException(EXP_GP, "CPL: $#, RPL: $#" % [$CPL, $RPL])

    if not(hard) and CPL > idt.DPL: raise newException(EXPGP, "")
    let cs = acs.getSegment(CS)
    acs.setSegment(CS, idt.segSel)
    acs.saveRegs(this, toBool(CPL xor RPL), cs)
    acs.cpu.setEip((idt.offsetH shl 16) + idt.offsetL)
    if idt.Type == TYPEINTERRUPT:
      acs.cpu.eflags.setInterrupt(false)

  else:
    # Get values from `Interupt Descriptor Table Register` (IDTR for short)
    let idtBase: uint32 = acs.cpu.getDtregBase(IDTR)
    let idtOffset: uint16 = n shl 2
    let idtLimit: uint16 = acs.cpu.getDtregLimit(IDTR)
    if idtOffset > idtLimit:
      raise newException(EXP_GP, "idtOffset: $#, idtLimit: $#" % [
        $idtOffset, $idtLimit
      ])

    # read value from the interrupt descriptor table. IDTR stores interrupt
    # location in form of `[segment selector - 31:16, offset bits - 15:0]`
    let ivt: IVT = acs.mem.readDataBlob[:IVT](idtBase + idtOffset)
    # Get code segment location, store it
    let cs = acs.getSegment(CS)
    # Set location of the code segment
    acs.setSegment(CS, ivt.segment)
    # Store registers, flags, instruction pointer, code segment value on stack
    acs.saveRegs(this, false, cs)
    # Set instruction pointer location using entry from IDTR table
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
