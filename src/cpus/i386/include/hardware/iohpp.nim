import commonhpp
import memoryhpp
import device/dev_iohpp
import std/tables

type
  IO* {.bycopy.} = object
    memory*: Memory
    portIo*: Table[uint16, PortIO]
    portIoMap*: Table[uint16, csizeT]
    memIo*: Table[uint32, ref MemoryIO]
    memIoMap*: Table[uint32, uint32]
  
proc initIO*(mem: Memory): IO =
  result.memory = mem

proc initIO*(): IO = 
  discard 

proc destroyIO*(this: var IO): void =
  this.portIo.clear()
  this.memIo.clear()
  this.memIoMap.clear()


proc setPortio*(this: var IO, `addr`: uint16, len: csizeT, dev: PortIO): void =
  let `addr` = (`addr` and not(1.uint16))
  this.portIo[`addr`] = dev
  this.portIoMap[`addr`] = len

proc getPortioBase*(this: var IO, `addr`: uint16): uint16 =
  for i in 0 ..< 5:
    var base: uint16 = (`addr` and (not(1.uint16))) - uint16(2 * i)
    if base in this.portIoMap:
      if `addr` < base + this.portIoMap[base]:
        return base

      else:
        return 0

  return 0

proc inIo8*(this: var IO, `addr`: uint16): uint8 =
  var v: uint8 = 0
  let base: uint16 = this.getPortioBase(`addr`)
  if base != 0:
    v = this.portIo[base].in8(`addr`)

  else:
    ERROR("no device connected at port : 0x%04x", `addr`)

  INFO(4, "in [0x%04x] (0x%04x)", `addr`, v)
  return v


proc inIo32*(this: var IO, `addr`: uint16): uint32 =
  var v: uint32 = 0
  for i in 0 ..< 4:
    v = (v + this.inIo8(`addr` + uint16(i)) shl (8 * i))
  return v



proc inIo16*(this: var IO, `addr`: uint16): uint16 =
  var v: uint16 = 0
  for i in 0 ..< 2:
    v = (v + this.inIo8(`addr` + uint16(i)) shl (8 * i))
  return v

proc outIo8*(this: var IO, `addr`: uint16, value: uint8): void =
  var base: uint16 = this.getPortioBase(`addr`)
  if base != 0:
    this.portIo[base].out8(`addr`, value)

  else:
    ERROR("no device connected at port : 0x%04x", `addr`)

  INFO(4, "out [0x%04x] (0x%04x)", `addr`, value)

proc outIo32*(this: var IO, `addr`: uint16, value: uint32): void =
  for i in 0 ..< 4:
    this.outIo8(`addr` + uint16(i), uint8((value shr (8 * i)) and 0xff))

proc outIo16*(this: var IO, `addr`: uint16, value: uint16): void =
  for i in 0 ..< 2:
    this.outIo8(`addr` + uint16(i), uint8((value shr (8 * i)) and 0xff))

proc setMemio*(this: var IO, base: uint32, len: csizeT, dev: ref MemoryIO): void =
  var `addr`: uint32
  ASSERT(not((base != 0 and ((1 shl 12) - 1) != 0)))
  dev[].setMem(this.memory, base, len)
  this.memIo[base] = dev
  block:
    `addr` = base
    while `addr` < base + len:
      this.memIoMap[`addr`] = base
      `addr` = (`addr` + (1 shl 12))


proc getMemioBase*(this: var IO, `addr`: uint32): uint32 =
  let `addr` = (`addr` and (not(((1.uint32 shl 12) - 1))))
  return (if `addr` in this.memIoMap:
            this.memIoMap[`addr`]

          else:
            0
          )

proc readMemio32*(this: var IO, base: uint32, offset: uint32): uint32 =
  ASSERT(base in this.memIo)
  return this.memIo[base][].read32(offset)

proc readMemio16*(this: var IO, base: uint32, offset: uint32): uint16 =
  ASSERT(base in this.memIo)
  return this.memIo[base][].read16(offset)

proc readMemio8*(this: var IO, base: uint32, offset: uint32): uint8 =
  ASSERT(base in this.memIo)
  return this.memIo[base][].read8(offset)

proc writeMemio32*(this: var IO, base: uint32, offset: uint32, value: uint32): void =
  ASSERT(base in this.memIo)
  this.memIo[base][].write32(offset, value)

proc writeMemio16*(this: var IO, base: uint32, offset: uint32, value: uint16): void =
  ASSERT(base in this.memIo)
  this.memIo[base][].write16(offset, value)

proc writeMemio8*(this: var IO, base: uint32, offset: uint32, value: uint8): void =
  ASSERT(base in this.memIo)
  this.memIo[base][].write8(offset, value)

proc chkMemio*(this: var IO, `addr`: uint32): uint32 =
  return this.getMemioBase(`addr`)
