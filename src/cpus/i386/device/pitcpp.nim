import
  thread
import
  stringh
import
  device/pithpp
proc initPIT*(): PIT_PIT = 
  memset(timer, 0, sizeof((timer)))
  for i in 0 ..< 3:
    timer[i].count = timer[i].def = 0xffff

proc destroyPIT*(this: var PIT): void = 
  for i in 0 ..< 3:
    if timer[i].th.joinable():
      timer[i].running = false
      timer[i].th.join()
    

var rl_fst: bool
proc in8*(this: var PIT, `addr`: uint16): uint8 = 
  var rgn: uint8 = `addr` and 0x3
  case rgn:
    of 0, 1, 2:
      case cwr.RL:
        of 1:
          return timer[rgn].count shr 8
        of 2:
          return timer[rgn].count and 0xff
        of 3:
          if not((rl_fst = (rl_fst xor true))):
            return timer[rgn].count shr 8
          
          else:
            return timer[rgn].count and 0xff
          
    else:
      return 0

proc out8*(this: var PIT, `addr`: uint16, v: uint8): void = 
  var rgn: uint8 = `addr` and 0x3
  case rgn:
    of 0, 1, 2:
      case cwr.RL:
        of 1:
          timer[rgn].count = (timer[rgn].count and 0xff00) + v
        of 2:
          timer[rgn].count = (v shl 8) + (timer[rgn].count and 0xff)
        of 3:
          if not((rl_fst = (rl_fst xor true))):
            timer[rgn].count = v
          
          else:
            timer[rgn].count = (v shl 8) + (timer[rgn].count and 0xff)
          
      timer[rgn].def = timer[rgn].count
      INFO(2, "timer[%d].def = 0x%04x", rgn, timer[rgn].def)
    of 3:
      cwr.raw = v
      if cwr.SC < 3:
        timer[cwr.SC].mode = cwr.mode
        case cwr.RL:
          of 0:
            timer[cwr.SC].def = timer[cwr.SC].count
          of 3:
            rl_fst = true
      
      if not(timer[cwr.SC].th.joinable()):
        timer[cwr.SC].running = true
        timer[cwr.SC].th = std.thread(addr PIT.counter, this, addr timer[cwr.SC])
      


proc counter*(this: var PIT, t: ptr Timer): void = 
  while (t.running):
    case t.mode:
      of 2:
        std.this_thread.sleep_for(std.chrono.milliseconds(100 * t.def / 119318))
        intr = true
      else:
        std.this_thread.sleep_for(std.chrono.milliseconds(100))
