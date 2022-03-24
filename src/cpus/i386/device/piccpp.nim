import device/pichpp
import commonhpp

proc initPIC*(master: ptr PIC): PIC =
  result.pic_m = master
  for i in 0 ..< MAX_IRQ:
    result.irq[i] = nil
  result.irr = 0
  result.isr = 0
  result.init_icn = -1


proc get_nintr*(this: var PIC): int8 = 
  var iva: uint8
  var i: cint
  block:
    i = 0
    while i < MAX_IRQ and toBool(not(((this.irr shr i) and 1))):
      postInc(i)
  if i == MAX_IRQ:
    return -1
  
  INFO(4, "IRQ %d", (if not(this.pic_m.toBool()): i else: i + MAX_IRQ))
  if not(this.ic4.AEOI.toBool()):
    this.isr = (this.isr or uint8(1 shl i))
  
  this.irr = (this.irr xor uint8(1 shl i))
  if not(this.ic1.SNGL).toBool():
    if not(this.pic_m.toBool()) and toBool(this.ic3.raw and uint8(1 shl i)):
      return -1
    
    else:
      if this.pic_m.toBool() and not(this.pic_m[].chk_m2s_pic(this.ic3.ID)):
        ERROR("")
      
    
  
  iva = (if this.ic4.PM.toBool(): this.ic2.IVA_x86 shl 3 else: this.ic1.IVA_l + (this.ic2.IVA_h shl 3))
  return iva.int8 + int8(i)

proc chk_intreq*(this: var PIC): bool = 
  var i: cint
  if this.init_icn.toBool():
    return false
  
  block:
    i = 0
    while i < MAX_IRQ and not((
      toBool(this.irq[i]) and
      toBool(this.imr shr i) and
      (block: {.warning: "[FIXME] 'toBool(1 and this.irq[i][].chk_intreq())'".}; true))):

      postInc(i)
  if i == MAX_IRQ:
    return false
  
  if uint8(this.isr and uint8(1 shl i)) >= this.isr:
    return false
  
  this.irr = (this.irr or uint8(1 shl i))
  return true


proc in8*(this: var PIC, `addr`: uint16): uint8 = 
  case `addr`:
    of 0x21, 0xa1:
      return not(this.imr)

    else:
      assert false
  return 0

proc set_command*(this: var PIC, v: uint8): void =
  if this.init_icn.toBool():
    this.ic1.raw = v
    INFO(2, "ic1 : 0x%04x", v)
    this.init_icn = 1
  
  else:
    var ocw2: OCW2
    ocw2.raw = v
    if ocw2.EOI.toBool():
      if ocw2.SL.toBool():
        this.isr = (this.isr and not(uint8(1 shl ocw2.L)))
      
      else:
        var i: cint
        block:
          i = 0
          while i < MAX_IRQ and not(toBool((this.isr shr i) and 1)):
            postInc(i)
        if i < MAX_IRQ:
          this.isr = (this.isr and not(uint8(1 shl i)))
        
      
    
    
  

proc set_data*(this: var PIC, v: uint8): void = 
  if this.init_icn > 0:
    case preInc(this.init_icn):
      of 2:
        this.ic2.raw = v
        INFO(2, "ic2 : 0x%04x", v)
        if this.ic1.SNGL.toBool():
          {.warning: "[FIXME] 'cxx_goto done'".}
        
        return 
      of 3:
        this.ic3.raw = v
        INFO(2, "ic3 : 0x%04x", v)
        if not(this.ic1.IC4).toBool():
          {.warning: "[FIXME] 'cxx_goto done'".}
        
        return 
      of 4:
        this.ic4.raw = v
        INFO(2, "ic4 : 0x%04x", v)

      else:
        block done:
          this.init_icn = 0

        for i in 0 ..< MAX_IRQ:
          if this.irq[i].toBool():
            {.warning: "[FIXME] 'this.irq[i][].chk_intreq()'".}
          
  
  else:
    this.imr = not(v)
  
proc out8*(this: var PIC, `addr`: uint16, v: uint8): void =
  case `addr`:
    of 0x20, 0xa0:
      set_command(this, v)
    of 0x21, 0xa1:
      set_data(this, v)

    else:
      assert false
