import common
import hardware/memory

type
  PortIO* = object
    in8*: proc(memAddr: U16): U8
    out8*: proc(memAddr: U16, v: U8): void

proc initPortIO*(): PortIO = 
  discard 


type
  MemWrite8Impl = proc(memAddr: EPointer, value: U8)
  MemRead8Impl = proc(memAddr: EPointer): U8

  MemoryIO* = ref object
    memory*: Memory
    paddr*: U32
    write8*: MemWrite8Impl
    read8*: MemRead8Impl
    size*: csizeT
  
proc initMemoryIO*(writeI: MemWrite8Impl, readI: MemRead8Impl): MemoryIO =
  MemoryIO(write8: writeI, read8: readI)

proc setMem*(this: var MemoryIO, mem: Memory, memAddr: U32, len: csizeT): void =
  assertRef(mem)
  this.memory = mem
  this.paddr = memAddr
  this.size = len

proc read32*(this: var MemoryIO, offset: U32): U32 =
  var v: U32 = 0
  for i in 0 ..< U32(4):
    v = (v + this.read8(offset + i).U32 shl (8 * i))
  return v

proc read16*(this: var MemoryIO, offset: U32): U16 =
  var v: U16 = 0
  for i in 0 ..< U32(2):
    v = (v + this.read8(offset + i).U16 shl (8 * i))
  return v

proc write32*(this: var MemoryIO, offset: U32, v: U32): void =
  for i in 0 ..< U32(4):
    this.write8(offset + i, U8((v shr (8 * i)) and 0xff))

proc write16*(this: var MemoryIO, offset: U32, v: U16): void =
  for i in 0 ..< U32(2):
    this.write8(offset + i, U8((v shr (8 * i)) and 0xff))
