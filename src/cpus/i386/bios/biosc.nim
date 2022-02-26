import
  biosh
var msg: cstring = "now booting from floppy disk..."
proc bios_main*(): cint = 
  print(msg)
  return 0

proc bios_init*(): void = 
  init_ivt()

proc init_ivt*(): void = 
  set_ivt(0x10, cast[uint32](bsv_video(, 0xf000)
  set_ivt(0x13, cast[uint32](bsv_disk(, 0xf000)
  set_ivt(0x16, cast[uint32](bsv_keyboard(, 0xf000)
  set_ivt(0x26, cast[uint32](bsv_irq_disk(, 0xf000)

proc set_ivt*(n: cint, offset: uint32, cs: uint16): void = 
  var ivt: ptr IVT = cast[ptr IVT](0(
  write_esw(addr (ivt[n].offset), offset)
  write_esw(addr (ivt[n].segment), cs)
