import common
import dev_irq
import dev_io

const MAX_IRQ* = 8
type
  OCW2* {.union.} = object
    raw*: uint8
    field1*: OCW2_field1

  OCW2_field1* = object
    L* {.bitsize: 3.}: uint8
    field1* {.bitsize: 2.}: uint8
    EOI* {.bitsize: 1.}: uint8
    SL* {.bitsize: 1.}: uint8
    R* {.bitsize: 1.}: uint8

proc L*(this: OCW2): uint8 = this.field1.L
proc `L=`*(this: var OCW2, value: uint8) = this.field1.L = value
proc EOI*(this: OCW2): uint8 = this.field1.EOI
proc `EOI=`*(this: var OCW2, value: uint8) = this.field1.EOI = value
proc SL*(this: OCW2): uint8 = this.field1.SL
proc `SL=`*(this: var OCW2, value: uint8) = this.field1.SL = value
proc R*(this: OCW2): uint8 = this.field1.R
proc `R=`*(this: var OCW2, value: uint8) = this.field1.R = value

type
  PIC* = ref object of IRQ
    portio*: PortIO
    pic_m*: PIC
    irq*: array[MAX_IRQ, IRQ]
    irr*: uint8
    isr*: uint8
    imr*: uint8
    ic1*: PIC_ic1
    ic2*: PIC_ic2
    ic3*: PIC_ic3
    ic4*: PIC_ic4
    init_icn*: int8

  PIC_ic2_field1* = object
    IVA_h* {.bitsize: 3.}: uint8
    IVA_x86* {.bitsize: 5.}: uint8

  PIC_ic1* {.union.} = object
    raw*: uint8
    field1*: PIC_ic1_field1

  PIC_ic1_field1* = object
    IC4* {.bitsize: 1.}: uint8
    SNGL* {.bitsize: 1.}: uint8
    ADI* {.bitsize: 1.}: uint8
    LTIM* {.bitsize: 1.}: uint8
    field4* {.bitsize: 1.}: uint8
    IVA_l* {.bitsize: 3.}: uint8

  PIC_ic2* {.union.} = object
    raw*: uint8
    field1*: PIC_ic2_field1

  PIC_ic3_field1* = object
    S0* {.bitsize: 1.}: uint8
    S1* {.bitsize: 1.}: uint8
    S2* {.bitsize: 1.}: uint8
    S3* {.bitsize: 1.}: uint8
    S4* {.bitsize: 1.}: uint8
    S5* {.bitsize: 1.}: uint8
    S6* {.bitsize: 1.}: uint8
    S7* {.bitsize: 1.}: uint8

  PIC_ic3_field2* = object
    ID* {.bitsize: 3.}: uint8

  PIC_ic3* {.union.} = object
    raw*: uint8
    field1*: PIC_ic3_field1
    field2*: PIC_ic3_field2

  PIC_ic4* {.union.} = object
    raw*: uint8
    field1*: PIC_ic4_field1

  PIC_ic4_field1* = object
    PM* {.bitsize: 1.}: uint8
    AEOI* {.bitsize: 1.}: uint8
    MS* {.bitsize: 1.}: uint8
    BUF* {.bitsize: 1.}: uint8
    SFNM* {.bitsize: 1.}: uint8


proc IC4*(this: PIC_ic1): uint8 = this.field1.IC4
proc `IC4=`*(this: var PIC_ic1, value: uint8) = this.field1.IC4 = value
proc SNGL*(this: PIC_ic1): uint8 = this.field1.SNGL
proc `SNGL=`*(this: var PIC_ic1, value: uint8) = this.field1.SNGL = value
proc ADI*(this: PIC_ic1): uint8 = this.field1.ADI
proc `ADI=`*(this: var PIC_ic1, value: uint8) = this.field1.ADI = value
proc LTIM*(this: PIC_ic1): uint8 = this.field1.LTIM
proc `LTIM=`*(this: var PIC_ic1, value: uint8) = this.field1.LTIM = value
proc IVA_l*(this: PIC_ic1): uint8 = this.field1.IVA_l
proc `IVA_l=`*(this: var PIC_ic1, value: uint8) = this.field1.IVA_l = value
proc IVA_h*(this: PIC_ic2): uint8 = this.field1.IVA_h
proc `IVA_h=`*(this: var PIC_ic2, value: uint8) = this.field1.IVA_h = value
proc IVA_x86*(this: PIC_ic2): uint8 = this.field1.IVA_x86
proc `IVA_x86=`*(this: var PIC_ic2, value: uint8) = this.field1.IVA_x86 = value

proc S0*(this: PIC_ic3): uint8 = this.field1.S0
proc `S0=`*(this: var PIC_ic3, value: uint8) = this.field1.S0 = value
proc S1*(this: PIC_ic3): uint8 = this.field1.S1
proc `S1=`*(this: var PIC_ic3, value: uint8) = this.field1.S1 = value
proc S2*(this: PIC_ic3): uint8 = this.field1.S2
proc `S2=`*(this: var PIC_ic3, value: uint8) = this.field1.S2 = value
proc S3*(this: PIC_ic3): uint8 = this.field1.S3
proc `S3=`*(this: var PIC_ic3, value: uint8) = this.field1.S3 = value
proc S4*(this: PIC_ic3): uint8 = this.field1.S4
proc `S4=`*(this: var PIC_ic3, value: uint8) = this.field1.S4 = value
proc S5*(this: PIC_ic3): uint8 = this.field1.S5
proc `S5=`*(this: var PIC_ic3, value: uint8) = this.field1.S5 = value
proc S6*(this: PIC_ic3): uint8 = this.field1.S6
proc `S6=`*(this: var PIC_ic3, value: uint8) = this.field1.S6 = value
proc S7*(this: PIC_ic3): uint8 = this.field1.S7
proc `S7=`*(this: var PIC_ic3, value: uint8) = this.field1.S7 = value

proc ID*(this: PIC_ic3): uint8 = this.field2.ID
proc `ID=`*(this: var PIC_ic3, value: uint8) = this.field2.ID = value

proc PM*(this: PIC_ic4): uint8 = this.field1.PM
proc `PM=`*(this: var PIC_ic4, value: uint8) = this.field1.PM = value
proc AEOI*(this: PIC_ic4): uint8 = this.field1.AEOI
proc `AEOI=`*(this: var PIC_ic4, value: uint8) = this.field1.AEOI = value
proc MS*(this: PIC_ic4): uint8 = this.field1.MS
proc `MS=`*(this: var PIC_ic4, value: uint8) = this.field1.MS = value
proc BUF*(this: PIC_ic4): uint8 = this.field1.BUF
proc `BUF=`*(this: var PIC_ic4, value: uint8) = this.field1.BUF = value
proc SFNM*(this: PIC_ic4): uint8 = this.field1.SFNM
proc `SFNM=`*(this: var PIC_ic4, value: uint8) = this.field1.SFNM = value


proc chk_m2s_pic*(this: var PIC, n: uint8): bool =
  return not(this.ic1.SNGL).bool and
         not(this.pic_m.isNil()) and
         bool(this.ic3.raw and uint8(1 shl n))

proc set_irq*(this: var PIC, n: uint8, dev: IRQ): void =
  if n < MAX_IRQ:
    this.irq[n] = dev

  else:
    ERROR("IRQ out of bound : %d", n)


proc initPIC*(master: PIC = nil): PIC =
  result = PIC(
    pic_m: master,
    irr: 0,
    isr: 0,
    init_icn: -1
  )

  for i in 0 ..< MAX_IRQ:
    result.irq[i] = nil


proc get_nintr*(this: var PIC): int8 =
  var iva: uint8
  var i: cint
  block:
    i = 0
    while i < MAX_IRQ and toBool(not(((this.irr shr i) and 1))):
      postInc(i)
  if i == MAX_IRQ:
    return -1

  INFO(4, "IRQ %d", (if not(this.pic_m.toBool()): i else: i + MAX_IRQ))
  if not(this.ic4.AEOI.toBool()):
    this.isr = (this.isr or uint8(1 shl i))

  this.irr = (this.irr xor uint8(1 shl i))
  if not(this.ic1.SNGL).toBool():
    if not(this.pic_m.toBool()) and toBool(this.ic3.raw and uint8(1 shl i)):
      return -1

    else:
      if this.pic_m.toBool() and not(this.pic_m.chk_m2s_pic(this.ic3.ID)):
        ERROR("")



  iva = (if this.ic4.PM.toBool(): this.ic2.IVA_x86 shl 3 else: this.ic1.IVA_l + (this.ic2.IVA_h shl 3))
  return iva.int8 + int8(i)

proc chk_intreq*(this: var PIC): bool =
  var i: cint
  if this.init_icn.toBool():
    return false

  block:
    i = 0
    while i < MAX_IRQ and not((
      toBool(this.irq[i]) and
      toBool(this.imr shr i) and
      (block: {.warning: "[FIXME] 'toBool(1 and this.irq[i][].chk_intreq())'".}; true))):

      postInc(i)
  if i == MAX_IRQ:
    return false

  if uint8(this.isr and uint8(1 shl i)) >= this.isr:
    return false

  this.irr = (this.irr or uint8(1 shl i))
  return true


proc in8*(this: var PIC, memAddr: uint16): uint8 =
  case memAddr:
    of 0x21, 0xa1:
      return not(this.imr)

    else:
      assert false
  return 0

proc set_command*(this: var PIC, v: uint8): void =
  if this.init_icn.toBool():
    this.ic1.raw = v
    INFO(2, "ic1 : 0x%04x", v)
    this.init_icn = 1

  else:
    var ocw2: OCW2
    ocw2.raw = v
    if ocw2.EOI.toBool():
      if ocw2.SL.toBool():
        this.isr = (this.isr and not(uint8(1 shl ocw2.L)))

      else:
        var i: cint
        block:
          i = 0
          while i < MAX_IRQ and not(toBool((this.isr shr i) and 1)):
            postInc(i)
        if i < MAX_IRQ:
          this.isr = (this.isr and not(uint8(1 shl i)))






proc set_data*(this: var PIC, v: uint8): void =
  if this.init_icn > 0:
    case preInc(this.init_icn):
      of 2:
        this.ic2.raw = v
        INFO(2, "ic2 : 0x%04x", v)
        if this.ic1.SNGL.toBool():
          {.warning: "[FIXME] 'cxx_goto done'".}

        return
      of 3:
        this.ic3.raw = v
        INFO(2, "ic3 : 0x%04x", v)
        if not(this.ic1.IC4).toBool():
          {.warning: "[FIXME] 'cxx_goto done'".}

        return
      of 4:
        this.ic4.raw = v
        INFO(2, "ic4 : 0x%04x", v)

      else:
        block done:
          this.init_icn = 0

        for i in 0 ..< MAX_IRQ:
          if this.irq[i].toBool():
            {.warning: "[FIXME] 'this.irq[i][].chk_intreq()'".}


  else:
    this.imr = not(v)

proc out8*(this: var PIC, memAddr: uint16, v: uint8): void =
  case memAddr:
    of 0x20, 0xa0:
      set_command(this, v)
    of 0x21, 0xa1:
      set_data(this, v)

    else:
      assert false
