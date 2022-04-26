import common
import std/bitops
import dev_irq
import dev_io

const MAXIRQ* = 8
type
  OCW2* = object
    L* {.bitsize: 3.}: U8
    field1* {.bitsize: 2.}: U8
    EOI* {.bitsize: 1.}: U8
    SL* {.bitsize: 1.}: U8
    R* {.bitsize: 1.}: U8

  PIC* = ref object of IRQ
    ## Programmable interrupt controller.
    portio*: PortIO
    logger*: EmuLogger
    picM*: PIC ## Master PIC
    irq*: array[MAXIRQ, IRQ] ## Array of devices that can create interrupts
    irr*: U8 ## Interrupt request register. Stores index of the device
                ## that generated interrupt. The IRR tells us which
                ## interrupts have been raised.
    isr*: U8 ## Interrupt service register. The ISR tells us which
                ## interrupts are being serviced, meaning IRQs sent to the
                ## CPU.
    imr*: U8 ## Interrupt mask register. Based on the interrupt mask
                ## (IMR), the PIC will send interrupts from the IRR to the
                ## CPU, at which point they are marked in the ISR.
    ic1*: PICIc1
    ic2*: PICIc2
    ic3*: PICIc3
    ic4*: PICIc4
    initIcn*: int8

  PICIc1* = object
    IC4* {.bitsize: 1.}: U8
    SNGL* {.bitsize: 1.}: U8
    ADI* {.bitsize: 1.}: U8
    LTIM* {.bitsize: 1.}: U8
    field4* {.bitsize: 1.}: U8
    IVAL* {.bitsize: 3.}: U8

  PICIc2* = object
    IVAH* {.bitsize: 3.}: U8
    IVAX86* {.bitsize: 5.}: U8

  PICIc3Field1* = object
    S0* {.bitsize: 1.}: U8
    S1* {.bitsize: 1.}: U8
    S2* {.bitsize: 1.}: U8
    S3* {.bitsize: 1.}: U8
    S4* {.bitsize: 1.}: U8
    S5* {.bitsize: 1.}: U8
    S6* {.bitsize: 1.}: U8
    S7* {.bitsize: 1.}: U8

  PICIc3Field2* = object
    ID* {.bitsize: 3.}: U8

  PICIc3* {.union.} = object
    raw*: U8
    field1*: PICIc3Field1
    field2*: PICIc3Field2

  PICIc4* = object
    PM* {.bitsize: 1.}: U8
    AEOI* {.bitsize: 1.}: U8
    MS* {.bitsize: 1.}: U8
    BUF* {.bitsize: 1.}: U8
    SFNM* {.bitsize: 1.}: U8


template log*(mem: PIC, ev: EmuEvent, depth: int = -2) =
  mem.logger.log(ev, depth)

proc S0*(this: PICIc3): U8 = this.field1.S0
proc `S0=`*(this: var PICIc3, value: U8) = this.field1.S0 = value
proc S1*(this: PICIc3): U8 = this.field1.S1
proc `S1=`*(this: var PICIc3, value: U8) = this.field1.S1 = value
proc S2*(this: PICIc3): U8 = this.field1.S2
proc `S2=`*(this: var PICIc3, value: U8) = this.field1.S2 = value
proc S3*(this: PICIc3): U8 = this.field1.S3
proc `S3=`*(this: var PICIc3, value: U8) = this.field1.S3 = value
proc S4*(this: PICIc3): U8 = this.field1.S4
proc `S4=`*(this: var PICIc3, value: U8) = this.field1.S4 = value
proc S5*(this: PICIc3): U8 = this.field1.S5
proc `S5=`*(this: var PICIc3, value: U8) = this.field1.S5 = value
proc S6*(this: PICIc3): U8 = this.field1.S6
proc `S6=`*(this: var PICIc3, value: U8) = this.field1.S6 = value
proc S7*(this: PICIc3): U8 = this.field1.S7
proc `S7=`*(this: var PICIc3, value: U8) = this.field1.S7 = value

proc ID*(this: PICIc3): U8 = this.field2.ID
proc `ID=`*(this: var PICIc3, value: U8) = this.field2.ID = value

proc chkM2sPic*(this: var PIC, n: U8): bool =
  return not(this.ic1.SNGL).bool and
         not(this.picM.isNil()) and
         bool(this.ic3.raw and U8(1 shl n))

proc setIrq*(this: var PIC, n: U8, dev: IRQ): void =
  this.irq[n] = dev


proc out8*(this: var PIC, memAddr: U16, v: U8)
proc in8*(this: var PIC, memAddr: U16): U8

proc initPIC*(logger: EmuLogger, master: PIC = nil): PIC =
  var pic =  PIC(
    picM: master,
    logger: logger,
    irr: 0,
    isr: 0,
    initIcn: -1
  )

  pic.portio.in8 = proc(mem: U16): U8 = in8(pic, mem)
  pic.portio.out8 = proc(mem: U16, v: U8) = out8(pic, mem, v)

  for i in 0 ..< MAXIRQ:
    pic.irq[i] = nil

  return pic

proc getNintr*(this: var PIC): int8 =
  var iva: U8
  var i: cint
  block:
    i = 0
    while i < MAXIRQ and toBool(not(((this.irr shr i) and 1))):
      postInc(i)

  if i == MAXIRQ:
    return -1

  if not(this.ic4.AEOI.toBool()):
    this.isr = (this.isr or U8(1 shl i))

  this.irr = (this.irr xor U8(1 shl i))
  if not(this.ic1.SNGL).toBool():
    if not(this.picM.toBool()) and toBool(this.ic3.raw and U8(1 shl i)):
      return -1

    else:
      if this.picM.toBool() and not(this.picM.chkM2sPic(this.ic3.ID)):
        ERROR("")

  iva = (if this.ic4.PM.toBool(): this.ic2.IVAX86 shl 3 else: this.ic1.IVAL + (this.ic2.IVAH shl 3))
  return iva.int8 + int8(i)

proc chkIntreq*(this: var PIC): bool =
  ## Check for interrupt request on any of the devices connected to the
  ## interrupt controller.
  if this.initIcn.toBool():
    return false

  # Scan through all attached devices, looking for any external interrupt
  # routine.
  var firstInterrupt: Option[U8]
  for i in 0'u8 ..< MAXIRQ.U8:
    if # Check IRQ device is not nil
       this.irq[i].isNil().not() and
       # Check if IMR bit is set and interrupt can be used.
       this.imr.testBit(i) and
       # Check if interruptis actually present
       this.irq[i].chkIntreq():
      firstInterrupt = some i
      break

  if firstInterrupt.isNone():
    # No interrupt detected
    return false

  let interrupt = firstInterrupt.get()
  if U8(this.isr and U8(1 shl interrupt)) >= this.isr:
    return false

  # Mask interrupt request register values
  this.irr = (this.irr or U8(1 shl interrupt))
  return true


proc in8*(this: var PIC, memAddr: U16): U8 =
  case memAddr:
    of 0x21, 0xa1:
      result = not(this.imr)
      this.log ev(
        eekIn8Read, evalue(result),
        memAddr, msg = "PIC IMR register")

    else:
      this.logger.log ev(eekIn8Unknown, memAddr)

proc setCommand*(this: var PIC, v: U8): void =
  if this.initIcn.toBool():
    this.ic1 = cast[PICIc1](v)
    this.initIcn = 1

  else:
    let ocw2: OCW2 = cast[OCW2](v)
    if ocw2.EOI.toBool():
      if ocw2.SL.toBool():
        this.isr = (this.isr and not(U8(1 shl ocw2.L)))

      else:
        var i: cint
        block:
          i = 0
          while i < MAXIRQ and not(toBool((this.isr shr i) and 1)):
            postInc(i)
        if i < MAXIRQ:
          this.isr = (this.isr and not(U8(1 shl i)))

proc setData*(this: var PIC, v: U8): void =
  if this.initIcn > 0:
    var done = false
    case preInc(this.initIcn):
      of 2:
        this.ic2 = cast[PICIc2](v)
        if this.ic1.SNGL.toBool():
          done = true

        else:
          return
      of 3:
        this.ic3 = cast[PICIc3](v)
        if not(this.ic1.IC4).toBool():
          done = true

        else:
          return

      of 4:
        this.ic4 = cast[PICIc4](v)
        done = true

      else:
        done = true

    if done:
      this.initIcn = 0
      for i in 0 ..< MAXIRQ:
        if this.irq[i].toBool():
          discard this.irq[i].chkIntreq()

  else:
    this.imr = not(v)

proc out8*(this: var PIC, memAddr: U16, v: U8) =
  case memAddr:
    of 0x20, 0xa0:
      this.log ev(eekOut8Write, evalue(v), memAddr, msg = "PIC set command")
      setCommand(this, v)

    of 0x21, 0xa1:
      this.log ev(eekOut8Write, evalue(v), memAddr, msg = "PIC set data")
      setData(this, v)

    else:
      this.logger.log ev(eekOut8Unknown, evalue(v), memAddr).withIt do:
        it.msg = "PIC"
