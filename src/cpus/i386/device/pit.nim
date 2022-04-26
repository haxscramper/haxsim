import common
import dev_irq
import dev_io

type
  Timer* = object
    mode*: uint8
    count*: uint16
    def*: uint16
    running*: bool

  PIT* = ref object of IRQ
    portio*: PortIO
    cwr*: PITCwr
    timer*: array[3, Timer]
  
  PITCwr* = object
    BCD* {.bitsize: 1.}: uint8
    mode* {.bitsize: 3.}: uint8
    RL* {.bitsize: 2.}: uint8
    SC* {.bitsize: 2.}: uint8

var rl_fst: bool
proc in8*(this: var PIT, memAddr: uint16): uint8 =
  var rgn: uint8 = uint8(memAddr and 0x3)
  case rgn:
    of 0, 1, 2:
      case this.cwr.RL:
        of 1:
          return uint8(this.timer[rgn].count shr 8)
        of 2:
          return uint8(this.timer[rgn].count and 0xff)
        of 3:
          rl_fst = (rl_fst xor true)
          if not(rl_fst):
            return uint8(this.timer[rgn].count shr 8)

          else:
            return uint8(this.timer[rgn].count and 0xff)

        else:
          assert false

    else:
      return 0

proc out8*(this: var PIT, memAddr: uint16, v: uint8): void =
  var rgn: uint8 = uint8(memAddr and 0x3)
  case rgn:
    of 0, 1, 2:
      case this.cwr.RL:
        of 1:
          this.timer[rgn].count = uint8((this.timer[rgn].count and 0xff00) + v)
        of 2:
          this.timer[rgn].count = uint8((v shl 8) + (this.timer[rgn].count and 0xff))
        of 3:
          rl_fst = (rl_fst xor true)
          if not(rl_fst):
            this.timer[rgn].count = v

          else:
            this.timer[rgn].count = uint8((v shl 8) + (this.timer[rgn].count and 0xff))

        else:
          assert false

      this.timer[rgn].def = this.timer[rgn].count
      INFO(2, "this.timer[%d].def = 0x%04x", rgn, this.timer[rgn].def)

    of 3:
      this.cwr = cast[PITCwr](v)
      if this.cwr.SC < 3:
        this.timer[this.cwr.SC].mode = this.cwr.mode
        case this.cwr.RL:
          of 0:
            this.timer[this.cwr.SC].def = this.timer[this.cwr.SC].count
          of 3:
            rl_fst = true

          else:
            assert false

      # if not(this.timer[cwr.SC].th.joinable()):
      #   this.timer[cwr.SC].running = true
        # this.timer[cwr.SC].th = std.thread(
        #   addr PIT.counter, this, addr this.timer[this.cwr.SC])

    else:
      assert false

proc initPIT*(): PIT =
  var pit = PIT()
  for i in 0 ..< 3:
    pit.timer[i].count = 0xffff
    pit.timer[i].def = 0xffff

  pit.portio = wrapPortIO(pit, in8, out8)
  return pit

proc destroyPIT*(this: var PIT): void =
  discard



proc counter*(this: var PIT, t: ptr Timer): void =
  while (t.running):
    case t.mode:
      of 2:
        discard
        # std.this_thread.sleep_for(std.chrono.milliseconds(100 * t.def / 119318))
        this.intr = true
      else:
        discard
        # std.this_thread.sleep_for(std.chrono.milliseconds(100))
