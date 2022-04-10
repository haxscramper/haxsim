import common
import std/deques
import access
import device/pic

type
  IVT* = object
    offset*: U16
    segment*: U16

type
  Interrupt* = object
    intrQ*: Deque[(U8, bool)]
    picS*, picM*: PIC

proc setPic*(this: var Interrupt, pic: PIC, master: bool): void =
  assertRef(pic)
  if master:
    this.picM = pic

  else:
    this.picS = pic

proc queueInterrupt*(this: var Interrupt, n: U8, hard: bool): void =
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

proc saveRegs*(acs: var DataAccess, this: var Interrupt, chpl: bool, cs: U16): void =
  ## Store values of the current register, code segment on stack. Values
  ## are put on stack in order `(E)FLAGS -> CS -> (E)IP`. Values are popped
  ## back when `iret` (interrupt return) instruction is called.
  if acs.cpu.isProtected():
    if chpl:
      let
        base: U32 = acs.cpu.getDtregBase(TR)
        limit: U32 = acs.cpu.getDtregLimit(TR)

      if limit < U32(sizeof(TSS) - 1):
        raise newException(EXPTS, "")

      let
        tss = acs.mem.readDataBlob[:TSS](base)
        ss: U16 = acs.getSegment(SS)
        esp: U32 = acs.cpu.getGpreg(ESP)

      acs.setSegment(SS, tss.ss0)
      acs.cpu.setGpreg(ESP, tss.esp0)

      acs.push32(ss)
      acs.push32(esp)

    acs.push32(acs.cpu.eflags.getEflags())
    acs.push32(cs)
    acs.push32(acs.cpu.getEip())

  else:
    acs.push16(acs.cpu.eflags.getFlags())
    acs.push16(cs)
    acs.push16(acs.cpu.getIp().U16)


proc handleInterrupt*(acs: var DataAccess, this: var Interrupt): void =
  acs.logger.logScope ev(eekInterruptHandler)

  if this.intrQ.len() == 0:
    return

  let (n, hard) = this.intrQ.popFirst()

  if acs.cpu.isProtected():
    var RPL: U8
    var CPL: U8 = U8(acs.getSegment(CS) and 3)
    let idtBase: U32 = acs.cpu.getDtregBase(IDTR)
    let idtOffset: U16 = n shl 3
    let idtLimit: U16 = acs.cpu.getDtregLimit(IDTR)
    if idtOffset > idtLimit:
      raise newException(EXP_GP, "idtOffset: $#, idtLimit: $#" % [
        $idtOffset, $idtLimit])

    var idt = acs.mem.readDataBlob[:IntGateDesc](idtBase + idtOffset)

    var segSel = addr idt.seg_sel
    RPL = cast[ptr SGregister](segSel)[].RPL.U8()

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
    let idtBase: U32 = acs.cpu.getDtregBase(IDTR)
    let idtOffset: U16 = n shl 2
    let idtLimit: U16 = acs.cpu.getDtregLimit(IDTR)
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

  queueInterrupt(this, nIntr.U8, true)
  return true
