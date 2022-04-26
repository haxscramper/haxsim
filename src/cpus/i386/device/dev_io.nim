import common
import hardware/memory

type
  MemWrite8Impl = proc(memAddr: EPointer, value: U8)
  MemRead8Impl = proc(memAddr: EPointer): U8

  PortOutImpl = proc(memAddr: U16, value: U8)
  PortInImpl = proc(memAddr: U16): U8

  PortIO* = ref object
    name*: string ## Name of the device connected to the port. Used for
                  ## debugging purposes, not used in the code
                  ## implementation itself.
    in8*: PortInImpl
    out8*: PortOutImpl

  MemoryIO* = ref object
    name*: string ## Name of the memory-mapped device
    memory*: Memory
    paddr*: U32
    write8*: MemWrite8Impl
    read8*: MemRead8Impl
    size*: csizeT

proc initPortIO*(
    name: string, inI: PortInImpl, outI: PortOutImpl): PortIO =

  PortIO(in8: inI, out8: outI, name: name)

proc initMemoryIO*(
    name: string, writeI: MemWrite8Impl, readI: MemRead8Impl): MemoryIO =

  MemoryIO(write8: writeI, read8: readI, name: name)

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
