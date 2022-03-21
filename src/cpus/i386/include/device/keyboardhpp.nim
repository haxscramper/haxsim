import commonhpp
import dev_irqhpp
import dev_iohpp
import mousehpp
import hardware/memoryhpp

type
  Mouse* {.bycopy, importcpp.} = object
    keyboard*: ref Keyboard
    enable*: bool

  CCB* {.bycopy, importcpp.} = object
    KIE* {.bitsize: 1.}: uint8
    MIE* {.bitsize: 1.}: uint8
    SYSF* {.bitsize: 1.}: uint8
    IGNLK* {.bitsize: 1.}: uint8
    KE* {.bitsize: 1.}: uint8
    ME* {.bitsize: 1.}: uint8
    XLATE* {.bitsize: 1.}: uint8

  Keyboard* {.bycopy, importcpp.} = object
    mouse*: ref Mouse
    mem*: ref Memory
    mode*: uint8
    kcsr*: Keyboard_kcsr_Type
    out_buf*: uint8
    in_buf*: uint8
    controller_ram*: array[32, uint8]
    ccb*: ref CCB

  field1_Type* {.bycopy.} = object
    OBF* {.bitsize: 1.}: uint8
    IBF* {.bitsize: 1.}: uint8
    F0* {.bitsize: 1.}: uint8
    F1* {.bitsize: 1.}: uint8
    ST4* {.bitsize: 1.}: uint8
    ST5* {.bitsize: 1.}: uint8
    ST6* {.bitsize: 1.}: uint8
    ST7* {.bitsize: 1.}: uint8

  Keyboard_kcsr_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type


proc initMouse*(kb: ref Keyboard): Mouse =
  result.keyboard = kb
  result.enable = false



proc initKeyboard*(m: ref Memory): ref Keyboard =
  new(result)
  new(result.mouse)
  result.mouse[] = initMouse(result)
  result.kcsr.raw = 0
  result.mem = m

proc get_mouse*(this: var Keyboard): ref Mouse =
  return this.mouse

proc OBF*(this: Keyboard_kcsr_Type): uint8 = this.field1.OBF
proc `OBF=`*(this: var Keyboard_kcsr_Type): uint8 = this.field1.OBF
proc IBF*(this: Keyboard_kcsr_Type): uint8 = this.field1.IBF
proc `IBF=`*(this: var Keyboard_kcsr_Type): uint8 = this.field1.IBF
proc F0*(this: Keyboard_kcsr_Type): uint8 = this.field1.F0
proc `F0=`*(this: var Keyboard_kcsr_Type): uint8 = this.field1.F0
proc F1*(this: Keyboard_kcsr_Type): uint8 = this.field1.F1
proc `F1=`*(this: var Keyboard_kcsr_Type): uint8 = this.field1.F1
proc ST4*(this: Keyboard_kcsr_Type): uint8 = this.field1.ST4
proc `ST4=`*(this: var Keyboard_kcsr_Type): uint8 = this.field1.ST4
proc ST5*(this: Keyboard_kcsr_Type): uint8 = this.field1.ST5
proc `ST5=`*(this: var Keyboard_kcsr_Type): uint8 = this.field1.ST5
proc ST6*(this: Keyboard_kcsr_Type): uint8 = this.field1.ST6
proc `ST6=`*(this: var Keyboard_kcsr_Type): uint8 = this.field1.ST6
proc ST7*(this: Keyboard_kcsr_Type): uint8 = this.field1.ST7
proc `ST7=`*(this: var Keyboard_kcsr_Type): uint8 = this.field1.ST7
