import
  stdioh
import
  emulator/emulatorhpp
import
  device/deviceshpp
proc initEmulator*(set: EmuSetting): Emulator_Emulator = 
  var pic_s: ptr PIC
  var pit: ptr PIT
  var syscon: ptr SysControl
  var com: ptr COM
  var vga: ptr VGA
  var kb: ptr Keyboard
  pic_m = newPIC()
  pic_s = newPIC(pic_m)
  set_pic(pic_m, true)
  set_pic(pic_s, false)
  ui = newUI(this, set.uiset)
  pit = newPIT()
  fdd = newFDD()
  syscon = newSysControl(this)
  com = newCOM()
  vga = ui.get_vga()
  kb = ui.get_keyboard()
  pic_m.set_irq(0, pit)
  pic_m.set_irq(1, kb)
  pic_m.set_irq(2, pic_s)
  pic_m.set_irq(6, fdd)
  pic_s.set_irq(4, kb.get_mouse())
  set_portio(0x020, 2, pic_m)
  
  set_portio(0x040, 4, pit)
  
  set_portio(0x060, 1, kb)
  
  set_portio(0x064, 1, kb)
  
  set_portio(0x0a0, 2, pic_s)
  
  set_portio(0x092, 1, syscon)
  
  set_portio(0x3b4, 2, vga.get_crt())
  
  set_portio(0x3ba, 1, vga)
  
  set_portio(0x3c0, 2, vga.get_attr())
  
  set_portio(0x3c2, 2, vga)
  
  set_portio(0x3c4, 2, vga.get_seq())
  
  set_portio(0x3c6, 4, vga.get_dac())
  
  set_portio(0x3cc, 1, vga)
  
  set_portio(0x3ce, 2, vga.get_gc())
  
  set_portio(0x3d4, 2, vga.get_crt())
  
  set_portio(0x3da, 1, vga)
  
  set_portio(0x3f0, 8, fdd)
  
  set_portio(0x3f8, 1, com)
  
  set_memio(0xa0000, 0x20000, vga)

proc load_binary*(this: var Emulator, fname: cstring, `addr`: uint32, offset: uint32, size: csize_t): void = 
  var fp: ptr FILE
  var buf: ptr uint8
  fp = fopen(fname, "rb")
  if not(fp):
    return 
  
  if cast[int32](size( < 0:
    fseek(fp, 0, SEEK_END)
    size = ftell(fp)
  
  buf = newuint8_t()
  fseek(fp, offset, SEEK_SET)
  fread(buf, 1, size, fp)
  fclose(fp)
  write_data(`addr`, buf, size)
  cxx_delete buf
