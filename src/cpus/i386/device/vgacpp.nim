import
  device/vgahpp
template chk_regidx*(n: untyped): untyped {.dirty.} = 
  block:
    var doTmp: bool = true
    while doTmp or (0):
      doTmp = "false"
      if n > sizeof((regs)):
        ERROR("register index out of bound", n)
      
      if not(regs[n]):
        ERROR("not implemented")
      

proc get_windowsize*(this: var VGA, x: ptr uint16, y: ptr uint16): void = 
  crt.get_windowsize(x, y)

proc rgb_image*(this: var VGA, buffer: ptr uint8, size: uint32): void = 
  var mode: gmode_t = gc.graphic_mode()
  for i in 0 ..< size:
    var dac_idx: uint8
    var rgb: uint32
    attr_idx = (if mode xor MODE_TEXT:
          gc.attr_index_graphic(i)
        
        else:
          crt.attr_index_text(i)
        )
    dac_idx = (if mode xor MODE_GRAPHIC256:
          attr.dac_index(attr_idx)
        
        else:
          attr_idx
        )
    rgb = dac.translate_rgb(dac_idx)
    (postInc(buffer))[] = rgb and 0xff
    (postInc(buffer))[] = (rgb shr 8) and 0xff
    (postInc(buffer))[] = (rgb shr 16) and 0xff

proc in8*(this: var VGA, `addr`: uint16): uint8 = 
  case `addr`:
    of 0x3c2:
      return 0
    of 0x3c3:
      return 0
    of 0x3cc:
      return mor.raw
    of 0x3ba, 0x3da:
      return 0
  return -1

proc out8*(this: var VGA, `addr`: uint16, v: uint8): void = 
  case `addr`:
    of 0x3c2:
      mor.raw = v
    of 0x3c3:
      discard 
    of 0x3ba, 0x3da:
      discard 

proc read8*(this: var VGA, offset: uint32): uint8 = 
  return (if mor.ER:
            seq.read(offset)
          
          else:
            0
          )

proc write8*(this: var VGA, offset: uint32, v: uint8): void = 
  var count: cint = 0
  if mor.ER:
    seq.write(offset, v)
    if not((postInc(count) mod 0x10)):
      refresh = true
    
  

proc read_plane*(this: var VGA, nplane: uint8, offset: uint32): uint8 = 
  if nplane > 3 or offset > (1 shl 16) - 1:
    ERROR("Out of Plane range")
  
  return plane[nplane][offset]

proc write_plane*(this: var VGA, nplane: uint8, offset: uint32, v: uint8): void = 
  if nplane > 3 or offset > (1 shl 16) - 1:
    ERROR("Out of Plane range")
  
  plane[nplane][offset] = v


proc VGA_Sequencer_read*(offset: uint32): uint8 = 
  if not(mem_mr.EM):
    offset = (offset and (1 shl 16) - 1)
  
  return vga.gc.read(offset)

template SEQ_WRITE_PLANE*(n: untyped, o: untyped, v: untyped): untyped {.dirty.} = 
  if (map_mr.raw shr (n)) and 1:
    vga.gc.write(n, o, v)
  

proc VGA_Sequencer_write*(offset: uint32, v: uint8): void = 
  if not(mem_mr.EM):
    offset = (offset and (1 shl 16) - 1)
  
  if mem_mr.C4:
    SEQ_WRITE_PLANE(offset and 3, offset and (not(3)), v)
  
  else:
    if mem_mr.OE:
      for i in 0 ..< 4:
        SEQ_WRITE_PLANE(i, offset, v)
    
    else:
      var nplane: uint8 = offset and 1
      SEQ_WRITE_PLANE(nplane, offset, v)
      SEQ_WRITE_PLANE(nplane + 2, offset, v)
    
  

proc VGA_Sequencer_get_font*(att: uint8): ptr uint8 = 
  var v: uint8
  var font_ofst: uint16 = 0
  v = (if att and 0x8:
        (cmsr.CMAM shl 2) + cmsr.CMA
      
      else:
        (cmsr.CMBM shl 2) + cmsr.CMB
      )
  font_ofst = (if v and 4:
        (v and (not(4))) * 2 + 1
      
      else:
        v * 2
      )
  if not(mem_mr.EM):
    font_ofst = (font_ofst and (1 shl 16) - 1)
  
  return vga.plane[2] + font_ofst

proc VGA_Sequencer_in8*(`addr`: uint16): uint8 = 
  case `addr`:
    of 0x3c4:
      return sar.raw
    of 0x3c5:
      return regs[sar.INDX][]
  return -1

proc VGA_Sequencer_out8*(`addr`: uint16, v: uint8): void = 
  case `addr`:
    of 0x3c4:
      chk_regidx(v)
      sar.raw = v
    of 0x3c5:
      regs[sar.INDX][] = v


proc VGA_CRT_get_windowsize*(x: ptr uint16, y: ptr uint16): void = 
  x[] = 8 * hdeer.HDEE
  y[] = 8 * vdeer.VDEE

proc VGA_CRT_attr_index_text*(n: uint32): uint8 = 
  var att: uint8
  var font: ptr uint8
  var bits: uint8
  var y: uint16
  x = n mod (8 * hdeer.HDEE)
  y = n / (8 * hdeer.HDEE)
  idx = y / (mslr.MSL + 1) * hdeer.HDEE + x / 8
  chr = vga.read_plane(0, idx * 2)
  att = vga.read_plane(1, idx * 2)
  font = vga.seq.get_font(att)
  bits = (font + chr * 0x10 + y mod (mslr.MSL + 1))[]
  return (if (bits shr (x mod 8)) and 1:
            att and 0x0f
          
          else:
            (att and 0xf0) shr 4
          )

proc VGA_CRT_in8*(`addr`: uint16): uint8 = 
  case `addr`:
    of 0x3b4, 0x3d4:
      return crtcar.raw
    of 0x3b5, 0x3d5:
      return regs[crtcar.INDX][]
  return -1

proc VGA_CRT_out8*(`addr`: uint16, v: uint8): void = 
  case `addr`:
    of 0x3b4, 0x3d4:
      chk_regidx(v)
      crtcar.raw = v
    of 0x3b5, 0x3d5:
      regs[crtcar.INDX][] = v


proc VGA_GraphicController_read*(offset: uint32): uint8 = 
  if not(chk_offset(addr offset)):
    return 0
  
  case gmr.WM:
    of 0:
      if gmr.OE:
        var nplane: uint8 = (rmsr.MS and 2) + (offset and 1)
        return vga.read_plane(nplane, offset and (not(1)))
      
      else:
        return vga.read_plane(rmsr.MS, offset)
      
    of 1:
      discard 
  return 0

proc VGA_GraphicController_write*(nplane: uint8, offset: uint32, v: uint8): void = 
  if not(chk_offset(addr offset)):
    return 
  
  case gmr.WM:
    of 0:
      if gmr.OE:
        offset = (offset and not(1))
      
      vga.write_plane(nplane, offset, v)
    of 1:
      discard 
    of 2:
      discard 
    of 3:
      discard 
  INFO(4, "plane[%d][0x%x] = 0x%02x", nplane, offset, v)

proc VGA_GraphicController_chk_offset*(offset: ptr uint32): bool = 
  var size: uint32
  var valid: bool
  case mr.MM:
    of 0:
      base = 0x00000
      size = 0x20000
    of 1:
      base = 0x00000
      size = 0x10000
    of 2:
      base = 0x10000
      size = 0x08000
    of 3:
      base = 0x18000
      size = 0x08000
  valid = (offset[] >= base and offset[] < base + size)
  offset[] = (offset[] - base)
  return valid

proc VGA_GraphicController_graphic_mode*(): gmode_t = 
  if mr.GM:
    if gmr._256CM:
      return MODE_GRAPHIC256
    
    return MODE_GRAPHIC
  
  return MODE_TEXT

proc VGA_GraphicController_attr_index_graphic*(n: uint32): uint8 = 
  return vga.read_plane(2, n)

proc VGA_GraphicController_in8*(`addr`: uint16): uint8 = 
  case `addr`:
    of 0x3ce:
      return gcar.raw
    of 0x3cf:
      return regs[gcar.INDX][]
  return -1

proc VGA_GraphicController_out8*(`addr`: uint16, v: uint8): void = 
  case `addr`:
    of 0x3ce:
      chk_regidx(v)
      gcar.raw = v
    of 0x3cf:
      regs[gcar.INDX][] = v


proc VGA_Attribute_dac_index*(index: uint8): uint8 = 
  var dac_idx: uint8
  type
    field1_Type* {.bycopy.} = object
      low* {.bitsize: 4.}: uint8
      high* {.bitsize: 2.}: uint8
    
  proc low*(this: ): uint8 = 
    this.field1.low
  
  proc `low =`*(this: var ): uint8 = 
    this.field1.low
  
  proc high*(this: ): uint8 = 
    this.field1.high
  
  proc `high =`*(this: var ): uint8 = 
    this.field1.high
  
  type
    * {.bycopy, union, importcpp.} = object
      raw*: uint8
      field1*: field1_Type
    
  var ip_data: 
  ip_data.raw = ipr[index and 0xf].raw
  if amcr.GAM:
    dac_idx = ip_data.low
    dac_idx = (dac_idx + ((if amcr.P54S:
              csr.SC45
            
            else:
              ip_data.high
            )) shl 4)
    dac_idx = (dac_idx + csr.SC67 shl 6)
  
  else:
    dac_idx = ip_data.low
  
  return dac_idx

proc VGA_Attribute_in8*(`addr`: uint16): uint8 = 
  case `addr`:
    of 0x3c0:
      return acar.raw
    of 0x3c1:
      return regs[acar.INDX][]
  return -1

proc VGA_Attribute_out8*(`addr`: uint16, v: uint8): void = 
  case `addr`:
    of 0x3c0:
      chk_regidx(v)
      acar.raw = v
    of 0x3c1:
      regs[acar.INDX][] = v


proc VGA_DAC_translate_rgb*(index: uint8): uint32 = 
  var rgb: uint32
  
  rgb = clut[index].R shl 0x02
  rgb = (rgb + clut[index].G shl 0x0a)
  rgb = (rgb + clut[index].B shl 0x12)
  return rgb

proc VGA_DAC_in8*(`addr`: uint16): uint8 = 
  var v: uint8
  case `addr`:
    of 0x3c6:
      return pelmr.raw
    of 0x3c7:
      return dacsr.raw
    of 0x3c9:
      v = clut[r_par.index].raw[postInc(progress)]
      if progress == 3:
        progress = 0
        postInc(r_par.index)
      
      return v
  return -1

proc VGA_DAC_out8*(`addr`: uint16, v: uint8): void = 
  case `addr`:
    of 0x3c7:
      if v > 0xff:
        ERROR("")
      
      r_par.raw = v
      progress = 0
    of 0x3c8:
      if v > 0xff:
        ERROR("")
      
      w_par.raw = v
      progress = 0
    of 0x3c9:
      clut[w_par.index].raw[postInc(progress)] = v
      if progress == 3:
        progress = 0
        postInc(w_par.index)
      
