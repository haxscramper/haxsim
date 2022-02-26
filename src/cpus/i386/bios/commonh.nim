template uint8_t*(): untyped {.dirty.} = 
  unsigned char

template uint16_t*(): untyped {.dirty.} = 
  unsigned short

template uint32_t*(): untyped {.dirty.} = 
  unsigned long

template bool*(): untyped {.dirty.} = 
  uint8_t

const true* = 1
const false* = 0
proc write_esb*(`addr`: ptr uint8, v: uint8): void = 
  discard 

proc write_esw*(`addr`: ptr uint16, v: uint16): void = 
  discard 

proc write_esd*(`addr`: ptr uint32, v: uint32): void = 
  discard 

proc copy_esw*(daddr: ptr uint16, saddr: ptr uint16): void = 
  discard 

proc in_port*(port: uint16): uint8 = 
  discard 

proc out_port*(port: uint16, v: uint8): void = 
  discard 

proc _cli*(): void = 
  discard 

proc _sti*(): void = 
  discard 

proc bsv_test*(): void = 
  discard 

proc bsv_video*(): void = 
  discard 

proc bsv_disk*(): void = 
  discard 

proc bsv_keyboard*(): void = 
  discard 

proc bsv_irq_disk*(): void = 
  discard 

proc print*(s: ptr uint8): uint32 = 
  discard 
