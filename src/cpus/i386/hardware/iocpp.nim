import
  stdinth
import
  unordered_map
import
  hardware/iohpp
proc destroyIO*(this: var IO): void = 
  var it_p: [uint16, PortIO]
  var it_m: [uint32, MemoryIO]
  
  
  port_io.clear()
  
  
  mem_io.clear()
  mem_io_map.clear()


proc set_portio*(this: var IO, `addr`: uint16, len: csize_t, dev: ptr PortIO): void = 
  `addr` = (`addr` and not(1))
  port_io[`addr`] = dev
  port_io_map[`addr`] = len

proc get_portio_base*(this: var IO, `addr`: uint16): uint16 = 
  for i in 0 ..< 5:
    var base: uint16 = (`addr` and (not(1))) - (2 * i)
    if port_io_map.count(base):
      return (if `addr` < base + port_io_map[base]:
                base
              
              else:
                0
              )
    
  return 0

proc in_io32*(this: var IO, `addr`: uint16): uint32 = 
  var v: uint32 = 0
  for i in 0 ..< 4:
    v = (v + in_io8(`addr` + i) shl (8 * i))
  return v

proc in_io16*(this: var IO, `addr`: uint16): uint16 = 
  var v: uint16 = 0
  for i in 0 ..< 2:
    v = (v + in_io8(`addr` + i) shl (8 * i))
  return v

proc in_io8*(this: var IO, `addr`: uint16): uint8 = 
  var v: uint8 = 0
  var base: uint16 = get_portio_base(`addr`)
  if base:
    v = port_io[base].in8(`addr`)
  
  else:
    ERROR("no device connected at port : 0x%04x", `addr`)
  
  INFO(4, "in [0x%04x] (0x%04x)", `addr`, v)
  return v

proc out_io32*(this: var IO, `addr`: uint16, value: uint32): void = 
  for i in 0 ..< 4:
    out_io8(`addr` + i, (value shr (8 * i)) and 0xff)

proc out_io16*(this: var IO, `addr`: uint16, value: uint16): void = 
  for i in 0 ..< 2:
    out_io8(`addr` + i, (value shr (8 * i)) and 0xff)

proc out_io8*(this: var IO, `addr`: uint16, value: uint8): void = 
  var base: uint16 = get_portio_base(`addr`)
  if base:
    port_io[base].out8(`addr`, value)
  
  else:
    ERROR("no device connected at port : 0x%04x", `addr`)
  
  INFO(4, "out [0x%04x] (0x%04x)", `addr`, value)


proc set_memio*(this: var IO, base: uint32, len: csize_t, dev: ptr MemoryIO): void = 
  var `addr`: uint32
  ASSERT(not((base and ((1 shl 12) - 1))))
  dev.set_mem(memory, base, len)
  mem_io[base] = dev
  block:
    `addr` = base
    while `addr` < base + len:
      mem_io_map[`addr`] = base
      `addr` = (`addr` + (1 shl 12))


proc get_memio_base*(this: var IO, `addr`: uint32): uint32 = 
  `addr` = (`addr` and (not(((1 shl 12) - 1))))
  return (if mem_io_map.count(`addr`):
            mem_io_map[`addr`]
          
          else:
            0
          )

proc read_memio32*(this: var IO, base: uint32, offset: uint32): uint32 = 
  ASSERT(mem_io.count(base))
  return mem_io[base].read32(offset)

proc read_memio16*(this: var IO, base: uint32, offset: uint32): uint16 = 
  ASSERT(mem_io.count(base))
  return mem_io[base].read16(offset)

proc read_memio8*(this: var IO, base: uint32, offset: uint32): uint8 = 
  ASSERT(mem_io.count(base))
  return mem_io[base].read8(offset)

proc write_memio32*(this: var IO, base: uint32, offset: uint32, value: uint32): void = 
  ASSERT(mem_io.count(base))
  mem_io[base].write32(offset, value)

proc write_memio16*(this: var IO, base: uint32, offset: uint32, value: uint16): void = 
  ASSERT(mem_io.count(base))
  mem_io[base].write16(offset, value)

proc write_memio8*(this: var IO, base: uint32, offset: uint32, value: uint8): void = 
  ASSERT(mem_io.count(base))
  mem_io[base].write8(offset, value)
