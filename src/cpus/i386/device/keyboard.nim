import common
import dev_irq
import dev_io
import hardware/memory

## https://d1.amobbs.com/bbs_upload782111/files_32/ourdev_576549.pdf
##
## https://www.win.tue.nl/~aeb/linux/kbd/scancodes-11.html

type
  Mouse* = ref object of IRQ
    portio*: PortIO ## Port for communicating with mouse
    keyboard*: Keyboard ## Reference to main memory
    enable*: bool ## Mouse enabled?

  CCB* = object
    KIE* {.bitsize: 1.}: uint8 ## Keyboard interrupt enabled?
    MIE* {.bitsize: 1.}: uint8 ## Mouse interrupt enabled?
    SYSF* {.bitsize: 1.}: uint8
    IGNLK* {.bitsize: 1.}: uint8 ##
    KE* {.bitsize: 1.}: uint8 ## Keyboard enabled?
    ME* {.bitsize: 1.}: uint8 ## Mouse enabled?
    XLATE* {.bitsize: 1.}: uint8 ## Translate scan codes?

  Keyboard* = ref object of IRQ
    portio*: PortIO ## Port for communicating with keyboard
    mouse*: Mouse ## Mouse device
    mem*: Memory ## Reference to main emulator memory
    mode*: uint8
    kcsr*: KeyboardKcsr ## Keyboard controller status register
    out_buf*: uint8
    in_buf*: uint8
    controller_ram*: array[32, uint8]
    ccb*: ref CCB

  KeyboardKcsr* = object
    OBF* {.bitsize: 1.}: uint8 ## Output buffer full. Indicates whether
    ## output buffer is full.
    IBF* {.bitsize: 1.}: uint8 ## Input buffer is full
    F0* {.bitsize: 1.}: uint8
    F1* {.bitsize: 1.}: uint8 ## Command/data (0 = data written to input
    ## buffer is data for PS/2 device, 1 = data written to input buffer is
    ## data for PS/2 controller command)
    ST4* {.bitsize: 1.}: uint8
    ST5* {.bitsize: 1.}: uint8
    ST6* {.bitsize: 1.}: uint8
    ST7* {.bitsize: 1.}: uint8

proc initMouse*(kb: Keyboard): Mouse =
  Mouse(keyboard: kb, enable: false)


proc get_mouse*(this: var Keyboard): Mouse =
  return this.mouse

proc command*(this: var Mouse, v: uint8) =
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

proc send_code*(this: var Mouse, code: uint8) =
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
      # Read output buffer
      return this.read_outbuf()
    of 0x64:
      # Read status register
      return cast[U8](this.kcsr)
    else:
      discard

  return uint8(255)

proc write_outbuf*(this: var Keyboard, v: uint8) =
  # FIXME - required threaded access: while this.kcsr.OBF.toBool(): discard

  this.kcsr.OBF = 1
  this.out_buf = v
  if this.ccb.KIE.toBool():
    this.intr = true


proc send_code*(this: var Keyboard, scancode: uint8) =
  if not(this.ccb.KE.toBool()):
    this.write_outbuf(scancode)


proc swt_a20gate*(this: var Keyboard, v: uint8) =
  case v:
    of 0xdd:
      this.mem.set_a20gate(false)
    of 0xdf:
      this.mem.set_a20gate(true)
    else:
      discard


proc command*(this: var Keyboard, v: uint8) =
  if not(this.kcsr.ST6.toBool()):
    # Check if input data is meant for controller command
    if this.kcsr.F1.toBool():
      case v:
        of 0xa7:
          # Disable mouse interface
          this.ccb.ME = 0
          return
        of 0xa8:
          # Enable mouse interface
          this.ccb.ME = 1
          return
        of 0xad:
          # Disable keyboard interface
          this.ccb.KE = 0
          return
        of 0xae:
          # Enable keyboard interface
          this.ccb.KE = 1
          return

        of 0x20 .. 0x3F:
          # Read "byte N" from internal RAM (where 'N' is the command byte
          # & 0x1F). The read data is placed into the output buffer, and
          # can be read by reading port 0x60.
          write_outbuf(this, this.controller_ram[v mod 0x20])
          return

        else:
          discard

    this.mode = v
    this.kcsr.ST6 = 1

  elif this.kcsr.F1.toBool():
    # Data meant for PS/2 device, not for controller. Skipping execution.
    discard

  else:
    # Executing controller command
    case this.mode:
      of 0xd1:
        # Write next byte to Controller Output Port (see below)
        this.swt_a20gate(v)

      of 0xd2:
        # Write keyboard output buffer
        this.send_code(v)

      of 0xd3:
        # write mouse output buffer
        this.mouse.send_code(v)

      of 0xd4:
        # Write mouse input buffer
        this.mouse.command(v)

      of 0x40 .. 0x7F:
        # Write keyboard controller RAM
        this.controller_ram[(this.mode - 0x40) mod 0x20] = v

      else:
        discard

  this.kcsr.ST6 = 0


proc out8*(this: var Keyboard, memAddr: uint16, v: uint8) =
  case memAddr:
    of 0x60:
      # Write command byte
      this.kcsr.F1 = 0

    of 0x64:
      # Write to status register
      this.kcsr.F1 = 1

    else:
      discard

  command(this, v)

proc initKeyboard*(m: Memory): Keyboard =
  var kb = Keyboard()
  kb.mouse = initMouse(kb)
  kb.kcsr = cast[KeyboardKcsr](0'u8)
  kb.mem = m
  kb.portio = wrapPortIO(kb, in8, out8)
  return kb
