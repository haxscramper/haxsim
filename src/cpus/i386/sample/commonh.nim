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