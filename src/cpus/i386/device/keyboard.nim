import common
import dev_irq
import dev_io
import hardware/memory

type
  Mouse* = ref object of IRQ
    portio*: PortIO
    keyboard*: Keyboard
    enable*: bool

  CCB* = object
    KIE* {.bitsize: 1.}: uint8
    MIE* {.bitsize: 1.}: uint8
    SYSF* {.bitsize: 1.}: uint8
    IGNLK* {.bitsize: 1.}: uint8
    KE* {.bitsize: 1.}: uint8
    ME* {.bitsize: 1.}: uint8
    XLATE* {.bitsize: 1.}: uint8

  Keyboard* = ref object of IRQ
    portio*: PortIO
    mouse*: Mouse
    mem*: Memory
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


proc initMouse*(kb: Keyboard): Mouse =
  Mouse(keyboard: kb, enable: false)

proc initKeyboard*(m: Memory): Keyboard =
  new(result)
  new(result.mouse)
  result.mouse = initMouse(result)
  result.kcsr.raw = 0
  result.mem = m

proc get_mouse*(this: var Keyboard): Mouse =
  return this.mouse

proc OBF*(this: Keyboard_kcsr_Type): uint8 = this.field1.OBF
proc `OBF=`*(this: var Keyboard_kcsr_Type, value: uint8) = this.field1.OBF = value
proc IBF*(this: Keyboard_kcsr_Type): uint8 = this.field1.IBF
proc `IBF=`*(this: var Keyboard_kcsr_Type, value: uint8) = this.field1.IBF = value
proc F0*(this: Keyboard_kcsr_Type): uint8 = this.field1.F0
proc `F0=`*(this: var Keyboard_kcsr_Type, value: uint8) = this.field1.F0 = value
proc F1*(this: Keyboard_kcsr_Type): uint8 = this.field1.F1
proc `F1=`*(this: var Keyboard_kcsr_Type, value: uint8) = this.field1.F1 = value
proc ST4*(this: Keyboard_kcsr_Type): uint8 = this.field1.ST4
proc `ST4=`*(this: var Keyboard_kcsr_Type, value: uint8) = this.field1.ST4 = value
proc ST5*(this: Keyboard_kcsr_Type): uint8 = this.field1.ST5
proc `ST5=`*(this: var Keyboard_kcsr_Type, value: uint8) = this.field1.ST5 = value
proc ST6*(this: Keyboard_kcsr_Type): uint8 = this.field1.ST6
proc `ST6=`*(this: var Keyboard_kcsr_Type, value: uint8) = this.field1.ST6 = value
proc ST7*(this: Keyboard_kcsr_Type): uint8 = this.field1.ST7
proc `ST7=`*(this: var Keyboard_kcsr_Type, value: uint8) = this.field1.ST7 = value


proc command*(this: var Mouse, v: uint8): void =
  case v:
    of 0xf4:
      while toBool(this.keyboard.kcsr.OBF):
        discard

      this.keyboard.kcsr.OBF = 1
      this.keyboard.out_buf = 0xfa
      if this.keyboard.ccb.MIE.toBool():
        this.intr = true

      this.enable = true

    else:
      discard

proc send_code*(this: var Mouse, code: uint8): void =
  if this.keyboard.ccb.ME.toBool() or not(this.enable):
    return

  # FIXME
  # while (keyboard.kcsr.OBF):
  #   std.this_thread.sleep_for(std.chrono.microseconds(10))

  this.keyboard.kcsr.OBF = 1
  this.keyboard.out_buf = code
  if this.keyboard.ccb.MIE.toBool():
    this.intr = true

proc read_outbuf*(this: var Keyboard): uint8 =
  this.kcsr.OBF = 0
  return this.out_buf



proc in8*(this: var Keyboard, memAddr: uint16): uint8 =
  case memAddr:
    of 0x60:
      return this.read_outbuf()
    of 0x64:
      return this.kcsr.raw
    else:
      discard

  return uint8(255)

proc write_outbuf*(this: var Keyboard, v: uint8): void =
  while this.kcsr.OBF.toBool():
    discard
  this.kcsr.OBF = 1
  this.out_buf = v
  if this.ccb.KIE.toBool():
    this.intr = true


proc send_code*(this: var Keyboard, scancode: uint8): void =
  if not(this.ccb.KE.toBool()):
    this.write_outbuf(scancode)


proc swt_a20gate*(this: var Keyboard, v: uint8): void =
  case v:
    of 0xdd:
      this.mem.set_a20gate(false)
    of 0xdf:
      this.mem.set_a20gate(true)
    else:
      discard


proc command*(this: var Keyboard, v: uint8): void =
  if not(this.kcsr.ST6.toBool()):
    if this.kcsr.F1.toBool():
      case v:
        of 0xa7:
          this.ccb.ME = 0
          return
        of 0xa8:
          this.ccb.ME = 1
          return
        of 0xad:
          this.ccb.KE = 0
          return
        of 0xae:
          this.ccb.KE = 1
          return
        else:
          if v < 0x40:
            write_outbuf(this, this.controller_ram[v mod 0x20])
            return

    else:
      discard

    this.mode = v
    this.kcsr.ST6 = 1

  elif this.kcsr.F1.toBool():
    discard

  else:
    case this.mode:
      of 0xd1:
        this.swt_a20gate(v)
      of 0xd2:
        this.send_code(v)
      of 0xd3:
        this.mouse.send_code(v)
      of 0xd4:
        this.mouse.command(v)
      else:
        if this.mode >= 0x40 and this.mode < 0x80:
          this.controller_ram[(this.mode - 0x40) mod 0x20] = v

  this.kcsr.ST6 = 0


proc out8*(this: var Keyboard, memAddr: uint16, v: uint8): void =
  case memAddr:
    of 0x60: this.kcsr.F1 = 0
    of 0x64: this.kcsr.F1 = 1
    else: discard

  command(this, v)



