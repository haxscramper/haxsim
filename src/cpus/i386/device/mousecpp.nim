import
  thread
import
  device/mousehpp
import
  device/keyboardhpp
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
  
  while (keyboard.kcsr.OBF):
    std.this_thread.sleep_for(std.chrono.microseconds(10))
  keyboard.kcsr.OBF = 1
  keyboard.out_buf = code
  if keyboard.ccb.MIE:
    intr = true
  
