import commonhpp
import dev_irqhpp
import dev_iohpp

type
  Timer* {.bycopy.} = object
    mode*: uint8
    count*: uint16
    def*: uint16
    running*: bool
    # th*: std_thread

  PIT* {.bycopy.} = object of IRQ
    portio*: PortIO
    cwr*: PIT_cwr_Type    
    timer*: array[3, Timer]
  
  field1_Type* {.bycopy.} = object
    BCD* {.bitsize: 1.}: uint8
    mode* {.bitsize: 3.}: uint8
    RL* {.bitsize: 2.}: uint8
    SC* {.bitsize: 2.}: uint8

  PIT_cwr_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type

  
proc BCD*(this: PIT_cwr_Type): uint8 = this.field1.BCD
proc `BCD=`*(this: var PIT_cwr_Type): uint8 = this.field1.BCD
proc mode*(this: PIT_cwr_Type): uint8 = this.field1.mode
proc `mode=`*(this: var PIT_cwr_Type): uint8 = this.field1.mode
proc RL*(this: PIT_cwr_Type): uint8 = this.field1.RL
proc `RL=`*(this: var PIT_cwr_Type): uint8 = this.field1.RL
proc SC*(this: PIT_cwr_Type): uint8 = this.field1.SC
proc `SC=`*(this: var PIT_cwr_Type): uint8 = this.field1.SC


proc initPIT*(): PIT =
  for i in 0 ..< 3:
    result.timer[i].count = 0xffff
    result.timer[i].def = 0xffff

proc destroyPIT*(this: var PIT): void =
  discard
  # for i in 0 ..< 3:
  #   if timer[i].th.joinable():
  #     timer[i].running = false
  #     timer[i].th.join()


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
      this.cwr.raw = v
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
