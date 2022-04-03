import commonhpp
import std/deques
import accesshpp
import device/pichpp

type
  IVT* {.bycopy, union.} = object
    raw*: uint32
    field1*: IVT_field1

  IVT_field1* {.bycopy.} = object
    offset*: uint16
    segment*: uint16

proc offset*(this: IVT): uint16 = this.field1.offset
proc `offset=`*(this: var IVT, value: uint16) = this.field1.offset = value
proc segment*(this: IVT): uint16 = this.field1.segment
proc `segment=`*(this: var IVT, value: uint16) = this.field1.segment = value

type
  Interrupt* = object
    intr_q*: Deque[(uint8, bool)]
    pic_s*, pic_m*: PIC

proc set_pic*(this: var Interrupt, pic: PIC, master: bool): void =
  assertRef(pic)
  if master:
    this.pic_m = pic

  else:
    this.pic_s = pic

proc restore_regs*(this: var Interrupt): void =
  discard

proc queue_interrupt*(this: var Interrupt, n: uint8, hard: bool): void =
  this.intr_q.addLast((n, hard))

proc iret*(this: var Interrupt): void =
  discard
