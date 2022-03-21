import commonhpp
import accesshpp
import interrupthpp
import uihpp
import hardware/[
  iohpp,
  memoryhpp
]
import device/[
  deviceshpp,
  pichpp,
  fddhpp,
  pithpp,
  syscontrolhpp,
  comhpp,
  vgahpp,
  keyboardhpp
]

type
  EmuSetting* {.bycopy, importcpp.} = object
    mem_size*: csize_t
    uiset*: UISetting
  
  Emulator* {.bycopy.} = object
    accs*: DataAccess
    intr*: Interrupt
    ui*: ref UI
    fdd*: ref FDD
  
proc eject_floppy*(this: var Emulator, slot: uint8): bool = 
  return (if not this.fdd.isNIl(): this.fdd[].eject_disk(slot) else: false)

proc is_running*(this: var Emulator): bool = 
  return (if not this.ui.isNil(): this.ui[].get_status() else: false)

proc stop*(this: var Emulator): void = 
   # ui
  this.ui = nil

proc insert_floppy*(this: var Emulator, slot: uint8, disk: cstring, write: bool): bool = 
  return (if not this.fdd.isNil(): this.fdd[].insert_disk(slot, disk, write) else: false)

proc initEmulator*(set: EmuSetting): Emulator =
  var pic_m, pic_s: ref PIC
  var pit: ref PIT
  var syscon: ref SysControl
  var com: ref COM
  var vga: ref VGA
  var kb: ref Keyboard
  {.warning: "FIXME".}
  # pic_m = newPIC()
  # pic_s = newPIC(pic_m)
  # set_pic(pic_m, true)
  # set_pic(pic_s, false)
  # ui = newUI(this, set.uiset)
  # pit = newPIT()
  # fdd = newFDD()
  # syscon = newSysControl(this)
  # com = newCOM()
  vga = result.ui[].get_vga()
  kb = result.ui[].get_keyboard()
  pic_m[].set_irq(0, pit)
  pic_m[].set_irq(1, kb)
  pic_m[].set_irq(2, pic_s)
  pic_m[].set_irq(6, result.fdd)
  pic_s[].set_irq(4, kb[].get_mouse())
  result.accs.io.set_portio(0x020, 2, pic_m.portio)
  result.accs.io.set_portio(0x040, 4, pit.portio)
  result.accs.io.set_portio(0x060, 1, kb.portio)
  result.accs.io.set_portio(0x064, 1, kb.portio)
  result.accs.io.set_portio(0x0a0, 2, pic_s.portio)
  result.accs.io.set_portio(0x092, 1, syscon.portio)
  result.accs.io.set_portio(0x3b4, 2, vga[].get_crt().portio)
  result.accs.io.set_portio(0x3ba, 1, vga.portio)
  result.accs.io.set_portio(0x3c0, 2, vga[].get_attr().portio)
  result.accs.io.set_portio(0x3c2, 2, vga.portio)
  result.accs.io.set_portio(0x3c4, 2, vga[].get_seq().portio)
  result.accs.io.set_portio(0x3c6, 4, vga[].get_dac().portio)
  result.accs.io.set_portio(0x3cc, 1, vga.portio)
  result.accs.io.set_portio(0x3ce, 2, vga[].get_gc().portio)
  result.accs.io.set_portio(0x3d4, 2, vga[].get_crt().portio)
  result.accs.io.set_portio(0x3da, 1, vga.portio)
  result.accs.io.set_portio(0x3f0, 8, result.fdd.portio)
  result.accs.io.set_portio(0x3f8, 1, com.portio)
  result.accs.io.set_memio(0xa0000, 0x20000, vga.memio)

proc load_binary*(this: var Emulator, fname: cstring, `addr`: uint32, offset: uint32, size: csize_t): void =
  var fp: FILE
  var buf: ptr uint8
  when false:
    fp = open($fname, fmRead)
    if not(fp.toBool()):
      return

    if cast[int32](size) < 0:
      seek(fp, 0, SEEK_END)
      size = ftell(fp)

    buf = newuint8_t()
    seek(fp, offset, SEEK_SET)
    read(buf, 1, size, fp)
    close(fp)

  discard write_data(this.accs.mem, `addr`, buf, size)
