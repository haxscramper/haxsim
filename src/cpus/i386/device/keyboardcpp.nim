import
  device/keyboardhpp
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
