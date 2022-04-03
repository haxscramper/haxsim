import commonhpp
import dev_irqhpp
import dev_iohpp
import mousehpp
import hardware/memoryhpp

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


import device/mousehpp
import device/keyboardhpp

proc command*(this: var Mouse, v: uint8): void =
  case v:
    of 0xf4:
      while (keyboard.kcsr.OBF):
        discard

      keyboard.kcsr.OBF = 1
      keyboard.out_buf = 0xfa
      if keyboard.ccb.MIE:
        intr = true

      enable = true

proc send_code*(this: var Mouse, code: uint8): void =
  if keyboard.ccb.ME or not(enable):
    return

  # FIXME
  # while (keyboard.kcsr.OBF):
  #   std.this_thread.sleep_for(std.chrono.microseconds(10))

  keyboard.kcsr.OBF = 1
  keyboard.out_buf = code
  if keyboard.ccb.MIE:
    intr = true

import device/keyboardhpp
proc in8*(this: var Keyboard, memAddr: uint16): uint8 =
  case memAddr:
    of 0x60:
      return read_outbuf()
    of 0x64:
      return kcsr.raw
  return -1

proc out8*(this: var Keyboard, memAddr: uint16, v: uint8): void =
  case memAddr:
    of 0x60:
      kcsr.F1 = 0
    of 0x64:
      kcsr.F1 = 1
  command(v)

proc command*(this: var Keyboard, v: uint8): void =
  if not(kcsr.ST6):
    if kcsr.F1:
      case v:
        of 0xa7:
          ccb.ME = 0

          return
        of 0xa8:
          ccb.ME = 1

          return
        of 0xad:
          ccb.KE = 0

          return
        of 0xae:
          ccb.KE = 1

          return
        else:
          if v < 0x40:
            write_outbuf(controller_ram[v mod 0x20])
            return


    else:
      discard

    mode = v
    kcsr.ST6 = 1

  else:
    if kcsr.F1:
      discard

    else:
      case mode:
        of 0xd1:
          swt_a20gate(v)
        of 0xd2:
          send_code(v)
        of 0xd3:
          mouse.send_code(v)
        of 0xd4:
          mouse.command(v)
        else:
          if mode >= 0x40 and mode < 0x80:
            controller_ram[(mode - 0x40) mod 0x20] = v


    kcsr.ST6 = 0


proc write_outbuf*(this: var Keyboard, v: uint8): void =
  while (kcsr.OBF):
    discard
  kcsr.OBF = 1
  out_buf = v
  if ccb.KIE:
    intr = true


proc read_outbuf*(this: var Keyboard): uint8 =
  kcsr.OBF = 0
  return out_buf

proc send_code*(this: var Keyboard, scancode: uint8): void =
  if not(ccb.KE):
    write_outbuf(scancode)


proc swt_a20gate*(this: var Keyboard, v: uint8): void =
  case v:
    of 0xdd:
      mem.set_a20gate(false)
    of 0xdf:
      mem.set_a20gate(true)
