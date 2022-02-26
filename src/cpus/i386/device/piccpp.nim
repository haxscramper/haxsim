import
  stdinth
import
  device/pichpp
proc initPIC*(master: ptr PIC): PIC_PIC = 
  pic_m = master
  for i in 0 ..< MAX_IRQ:
    irq[i] = `nil`
  irr = 0
  isr = 0
  init_icn = -1


proc get_nintr*(this: var PIC): int8 = 
  var iva: uint8
  var i: cint
  block:
    i = 0
    while i < MAX_IRQ and not(((irr shr i) and 1)):
      postInc(i)
  if i == MAX_IRQ:
    return -1
  
  INFO(4, "IRQ %d", (if not(pic_m):
          i
        
        else:
          i + MAX_IRQ
        ))
  if not(ic4.AEOI):
    isr = (isr or 1 shl i)
  
  irr = (irr xor 1 shl i)
  if not(ic1.SNGL):
    if not(pic_m) and ic3.raw and (1 shl i):
      return -1
    
    else:
      if pic_m and not(pic_m.chk_m2s_pic(ic3.ID)):
        ERROR("")
      
    
  
  iva = (if ic4.PM:
        ic2.IVA_x86 shl 3
      
      else:
        ic1.IVA_l + (ic2.IVA_h shl 3)
      )
  return iva + i

proc chk_intreq*(this: var PIC): bool = 
  var i: cint
  if init_icn:
    return false
  
  block:
    i = 0
    while i < MAX_IRQ and not((irq[i] and (imr shr i) and 1 and irq[i].chk_intreq())):
      postInc(i)
  if i == MAX_IRQ:
    return false
  
  if isr and (1 shl i) >= isr:
    return false
  
  irr = (irr or 1 shl i)
  return true


proc in8*(this: var PIC, `addr`: uint16): uint8 = 
  case `addr`:
    of 0x21, 0xa1:
      return not(imr)
  return 0

proc out8*(this: var PIC, `addr`: uint16, v: uint8): void = 
  case `addr`:
    of 0x20, 0xa0:
      set_command(v)
    of 0x21, 0xa1:
      set_data(v)

proc set_command*(this: var PIC, v: uint8): void = 
  if init_icn:
    ic1.raw = v
    INFO(2, "ic1 : 0x%04x", v)
    init_icn = 1
  
  else:
    var ocw2: OCW2
    ocw2.raw = v
    if ocw2.EOI:
      if ocw2.SL:
        isr = (isr and not((1 shl ocw2.L)))
      
      else:
        var i: cint
        block:
          i = 0
          while i < MAX_IRQ and not(((isr shr i) and 1)):
            postInc(i)
        if i < MAX_IRQ:
          isr = (isr and not((1 shl i)))
        
      
    
    
  

proc set_data*(this: var PIC, v: uint8): void = 
  if init_icn > 0:
    case preInc(init_icn):
      of 2:
        ic2.raw = v
        INFO(2, "ic2 : 0x%04x", v)
        if ic1.SNGL:
          cxx_goto done
        
        return 
      of 3:
        ic3.raw = v
        INFO(2, "ic3 : 0x%04x", v)
        if not(ic1.IC4):
          cxx_goto done
        
        return 
      of 4:
        ic4.raw = v
        INFO(2, "ic4 : 0x%04x", v)
      else:
        block done:
          init_icn = 0
        for i in 0 ..< MAX_IRQ:
          if irq[i]:
            irq[i].chk_intreq()
          
  
  else:
    imr = not(v)
  
