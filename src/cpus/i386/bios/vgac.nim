import
  commonh
import
  font8x8h
type
  rgb_t* {.bycopy, importcpp.} = object
    red*: uint8
    green*: uint8
    blue*: uint8
  
var palette: array[16, rgb_t] = @([
                , 
                (0x00, 0x00, 0x00), 
                (0x00, 0x00, 0x2a), 
                (0x00, 0x2a, 0x00), 
                (0x00, 0x2a, 0x2a), 
                (0x2a, 0x00, 0x00), 
                (0x2a, 0x00, 0x2a), 
                (0x2a, 0x15, 0x00), 
                (0x2a, 0x2a, 0x2a), 
                (0x15, 0x15, 0x15), 
                (0x15, 0x15, 0x3f), 
                (0x15, 0x3f, 0x15), 
                (0x15, 0x3f, 0x3f), 
                (0x3f, 0x15, 0x15), 
                (0x3f, 0x15, 0x3f), 
                (0x3f, 0x3f, 0x15), 
                (0x3f, 0x3f, 0x3f)
              ])
proc attr_configure*(): void = 
  for i in 0 ..< 0x10:
    out_port(0x3c0, i)
    out_port(0x3c1, i)

proc seq_configure*(): void = 
  out_port(0x3c4, 2)
  out_port(0x3c5, 0x3)
  out_port(0x3c4, 3)
  out_port(0x3c5, 0x0)
  out_port(0x3c4, 4)
  out_port(0x3c5, 0x2)

proc dac_configure*(): void = 
  out_port(0x3c8, 0)
  for i in 0 ..< 0x10:
    out_port(0x3c9, palette[i].red)
    out_port(0x3c9, palette[i].green)
    out_port(0x3c9, palette[i].blue)

proc gc_configure*(): void = 
  out_port(0x3ce, 5)
  out_port(0x3cf, 0x10)
  out_port(0x3ce, 6)
  out_port(0x3cf, 0xe)

proc load_font*(): void = 
  _cli()
  out_port(0x3c4, 2)
  out_port(0x3c5, 0x4)
  out_port(0x3c4, 4)
  out_port(0x3c5, 0x6)
  out_port(0x3ce, 5)
  out_port(0x3cf, 0x0)
  out_port(0x3ce, 6)
  out_port(0x3cf, 0x0)
  _sti()
  `__asm__`("")
  for i in 0 ..< 0x80:
    var p: ptr uint8 = font8x8_basic[i]
    write_esd(cast[ptr uint32]((i * 0x10)(, cast[ptr uint32](addr p[0]([])
    write_esd(cast[ptr uint32]((i * 0x10 + 4)(, cast[ptr uint32](addr p[4]([])
  `__asm__`("pop es")

var cursor_y: uint16
proc print*(s: ptr uint8): uint32 = 
  var i: uint32
  `__asm__`("")
  block:
    i = 0
    while s[i]:
      write_esw(cast[ptr uint16](((cursor_y * 0x28 + cursor_x) * 2)(, 0x0700 + s[i])
      postInc(cursor_x)
      if cursor_x >= 0x28 or not((s[i] xor 0x0a)):
        cursor_x = 0
        postInc(cursor_y)
      
      if cursor_y >= 0x19:
        var j: uint32
        block:
          j = 0
          while j < 0x18 * 0x28:
            copy_esw(cast[ptr uint16]((j * 2)(, cast[ptr uint16](((0x28 + j) * 2)()
            postInc(j)
        while j < 0x19 * 0x28:
          write_esw(cast[ptr uint16]((j * 2)(, 0x0700)
          postInc(j)
        cursor_x = 0
        postDec(cursor_y)
      
      postInc(i)
  `__asm__`("pop es")
  return i
