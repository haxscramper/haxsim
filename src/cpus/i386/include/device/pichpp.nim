import commonhpp
import dev_irqhpp
import dev_iohpp

const MAX_IRQ* = 8
type
  OCW2* {.bycopy, union.} = object
    raw*: uint8
    field1*: OCW2_field1

  OCW2_field1* {.bycopy.} = object
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
  PIC* {.bycopy.} = object of IRQ
    portio*: PortIO
    pic_m*: ptr PIC
    irq*: array[MAX_IRQ, ref IRQ]
    irr*: uint8
    isr*: uint8
    imr*: uint8
    ic1*: PIC_ic1
    ic2*: PIC_ic2
    ic3*: PIC_ic3
    ic4*: PIC_ic4
    init_icn*: int8

  PIC_ic2_field1* {.bycopy.} = object
    IVA_h* {.bitsize: 3.}: uint8
    IVA_x86* {.bitsize: 5.}: uint8

  PIC_ic1* {.bycopy, union.} = object
    raw*: uint8
    field1*: PIC_ic1_field1

  PIC_ic1_field1* {.bycopy.} = object
    IC4* {.bitsize: 1.}: uint8
    SNGL* {.bitsize: 1.}: uint8
    ADI* {.bitsize: 1.}: uint8
    LTIM* {.bitsize: 1.}: uint8
    field4* {.bitsize: 1.}: uint8
    IVA_l* {.bitsize: 3.}: uint8

  PIC_ic2* {.bycopy, union.} = object
    raw*: uint8
    field1*: PIC_ic2_field1

  PIC_ic3_field1* {.bycopy.} = object
    S0* {.bitsize: 1.}: uint8
    S1* {.bitsize: 1.}: uint8
    S2* {.bitsize: 1.}: uint8
    S3* {.bitsize: 1.}: uint8
    S4* {.bitsize: 1.}: uint8
    S5* {.bitsize: 1.}: uint8
    S6* {.bitsize: 1.}: uint8
    S7* {.bitsize: 1.}: uint8

  PIC_ic3_field2* {.bycopy.} = object
    ID* {.bitsize: 3.}: uint8

  PIC_ic3* {.bycopy, union.} = object
    raw*: uint8
    field1*: PIC_ic3_field1
    field2*: PIC_ic3_field2

  PIC_ic4* {.bycopy, union.} = object
    raw*: uint8
    field1*: PIC_ic4_field1

  PIC_ic4_field1* {.bycopy.} = object
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

proc set_irq*(this: var PIC, n: uint8, dev: ref IRQ): void =
  if n < MAX_IRQ:
    this.irq[n] = dev

  else:
    ERROR("IRQ out of bound : %d", n)
