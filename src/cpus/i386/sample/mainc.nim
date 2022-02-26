import
  commonh
proc _puts*(a0: cstring): cint = 
  discard 

proc set_graphicmode*(): void = 
  discard 

proc main*(): cint = 
  var vram: ptr uint8 = cast[ptr uint8](0xa0000(
  _puts("Hello!\\n")
  _puts("Key or Mouse\\n")
  `__asm__`("hlt")
  set_graphicmode()
  for i in 0 ..< 0x10:
    for j in 0 ..< 320 * 200:
      vram[j] = i
    `__asm__`("hlt")
  for i in 0 ..< 320 * 200:
    vram[i] = i mod 0x10
  `__asm__`("hlt")
  for i in 0 ..< 200:
    var c8: uint8 = i mod 0x10
    var c32: uint32 = (c8 shl 24) + (c8 shl 16) + (c8 shl 8) + c8
    for j in 0 ..< 320 / 4:
      (cast[ptr uint32](vram()[i * 80 + j] = c32
  return 0
