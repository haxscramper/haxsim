import
  commonhpp
import
  hardware/memoryhpp
import std/lenientops
type
  PortIO* {.bycopy.} = object
    
  
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
  this.memory = mem
  this.paddr = `addr`
  this.size = len

proc read8*(this: var MemoryIO, offset: uint32): uint8 =
  assert false, "Implementation is empty?"
  discard

proc write8*(this: var MemoryIO, offset: uint32, v: uint8): void =
  assert false, "Implementation is empty?"
  discard

proc read32*(this: var MemoryIO, offset: uint32): uint32 = 
  var v: uint32 = 0
  for i in 0 ..< uint32(4):
    v = (v + this.read8(offset + i).uint32 shl (8 * i))
  return v

proc read16*(this: var MemoryIO, offset: uint32): uint16 = 
  var v: uint16 = 0
  for i in 0 ..< uint32(2):
    v = (v + this.read8(offset + i).uint16 shl (8 * i))
  return v

proc write32*(this: var MemoryIO, offset: uint32, v: uint32): void = 
  for i in 0 ..< uint32(4):
    this.write8(offset + i, uint8((v shr (8 * i)) and 0xff))

proc write16*(this: var MemoryIO, offset: uint32, v: uint16): void = 
  for i in 0 ..< uint32(2):
    this.write8(offset + i, uint8((v shr (8 * i)) and 0xff))
