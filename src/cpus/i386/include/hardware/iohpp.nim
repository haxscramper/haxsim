import commonhpp
import memoryhpp
import device/dev_iohpp
import std/tables

type
  IO* {.bycopy.} = object
    memory*: ptr Memory
    port_io*: Table[uint16, PortIO]
    port_io_map*: Table[uint16, csize_t]
    mem_io*: Table[uint32, ref MemoryIO]
    mem_io_map*: Table[uint32, uint32]
  
proc initIO*(mem: ptr Memory): IO = 
  result.memory = mem

proc initIO*(): IO = 
  discard 

proc destroyIO*(this: var IO): void =
  this.port_io.clear()
  this.mem_io.clear()
  this.mem_io_map.clear()


proc set_portio*(this: var IO, `addr`: uint16, len: csize_t, dev: PortIO): void =
  let `addr` = (`addr` and not(1.uint16))
  this.port_io[`addr`] = dev
  this.port_io_map[`addr`] = len

proc get_portio_base*(this: var IO, `addr`: uint16): uint16 =
  for i in 0 ..< 5:
    var base: uint16 = (`addr` and (not(1.uint16))) - uint16(2 * i)
    if base in this.port_io_map:
      if `addr` < base + this.port_io_map[base]:
        return base

      else:
        return 0

  return 0

proc in_io8*(this: var IO, `addr`: uint16): uint8 =
  var v: uint8 = 0
  let base: uint16 = this.get_portio_base(`addr`)
  if base != 0:
    v = this.port_io[base].in8(`addr`)

  else:
    ERROR("no device connected at port : 0x%04x", `addr`)

  INFO(4, "in [0x%04x] (0x%04x)", `addr`, v)
  return v


proc in_io32*(this: var IO, `addr`: uint16): uint32 =
  var v: uint32 = 0
  for i in 0 ..< 4:
    v = (v + this.in_io8(`addr` + uint16(i)) shl (8 * i))
  return v



proc in_io16*(this: var IO, `addr`: uint16): uint16 =
  var v: uint16 = 0
  for i in 0 ..< 2:
    v = (v + this.in_io8(`addr` + uint16(i)) shl (8 * i))
  return v

proc out_io8*(this: var IO, `addr`: uint16, value: uint8): void =
  var base: uint16 = this.get_portio_base(`addr`)
  if base != 0:
    this.port_io[base].out8(`addr`, value)

  else:
    ERROR("no device connected at port : 0x%04x", `addr`)

  INFO(4, "out [0x%04x] (0x%04x)", `addr`, value)

proc out_io32*(this: var IO, `addr`: uint16, value: uint32): void =
  for i in 0 ..< 4:
    this.out_io8(`addr` + uint16(i), uint8((value shr (8 * i)) and 0xff))

proc out_io16*(this: var IO, `addr`: uint16, value: uint16): void =
  for i in 0 ..< 2:
    this.out_io8(`addr` + uint16(i), uint8((value shr (8 * i)) and 0xff))

proc set_memio*(this: var IO, base: uint32, len: csize_t, dev: ref MemoryIO): void =
  var `addr`: uint32
  ASSERT(not((base != 0 and ((1 shl 12) - 1) != 0)))
  dev[].set_mem(this.memory, base, len)
  this.mem_io[base] = dev
  block:
    `addr` = base
    while `addr` < base + len:
      this.mem_io_map[`addr`] = base
      `addr` = (`addr` + (1 shl 12))


proc get_memio_base*(this: var IO, `addr`: uint32): uint32 =
  let `addr` = (`addr` and (not(((1.uint32 shl 12) - 1))))
  return (if `addr` in this.mem_io_map:
            this.mem_io_map[`addr`]

          else:
            0
          )

proc read_memio32*(this: var IO, base: uint32, offset: uint32): uint32 =
  ASSERT(base in this.mem_io)
  return this.mem_io[base][].read32(offset)

proc read_memio16*(this: var IO, base: uint32, offset: uint32): uint16 =
  ASSERT(base in this.mem_io)
  return this.mem_io[base][].read16(offset)

proc read_memio8*(this: var IO, base: uint32, offset: uint32): uint8 =
  ASSERT(base in this.mem_io)
  return this.mem_io[base][].read8(offset)

proc write_memio32*(this: var IO, base: uint32, offset: uint32, value: uint32): void =
  ASSERT(base in this.mem_io)
  this.mem_io[base][].write32(offset, value)

proc write_memio16*(this: var IO, base: uint32, offset: uint32, value: uint16): void =
  ASSERT(base in this.mem_io)
  this.mem_io[base][].write16(offset, value)

proc write_memio8*(this: var IO, base: uint32, offset: uint32, value: uint8): void =
  ASSERT(base in this.mem_io)
  this.mem_io[base][].write8(offset, value)

proc chk_memio*(this: var IO, `addr`: uint32): uint32 = 
  return this.get_memio_base(`addr`)
