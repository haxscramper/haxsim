import
  commonhpp
import
  hardware/memoryhpp
type
  PortIO* {.bycopy, importcpp.} = object
    
  
proc initPortIO*(): PortIO = 
  discard 

proc in8*(this: var PortIO, `addr`: uint16): uint8 = 
  discard 

proc out8*(this: var PortIO, `addr`: uint16, v: uint8): void = 
  discard 

type
  MemoryIO* {.bycopy, importcpp.} = object
    memory*: ptr Memory
    paddr*: uint32    
    size*: csize_t    
  
proc initMemoryIO*(): MemoryIO = 
  discard 

proc set_mem*(this: var MemoryIO, mem: ptr Memory, `addr`: uint32, len: csize_t): void = 
  memory = mem
  paddr = `addr`
  size = len

proc read32*(this: var MemoryIO, offset: uint32): uint32 = 
  var v: uint32 = 0
  for i in 0 ..< 4:
    v = (v + read8(offset + i) shl (8 * i))
  return v

proc read16*(this: var MemoryIO, offset: uint32): uint16 = 
  var v: uint16 = 0
  for i in 0 ..< 2:
    v = (v + read8(offset + i) shl (8 * i))
  return v

proc read8*(this: var MemoryIO, offset: uint32): uint8 = 
  discard 

proc write32*(this: var MemoryIO, offset: uint32, v: uint32): void = 
  for i in 0 ..< 4:
    write8(offset + i, (v shr (8 * i)) and 0xff)

proc write16*(this: var MemoryIO, offset: uint32, v: uint16): void = 
  for i in 0 ..< 2:
    write8(offset + i, (v shr (8 * i)) and 0xff)

proc write8*(this: var MemoryIO, offset: uint32, v: uint8): void = 
  discard 
