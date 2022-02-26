import
  unordered_map
import
  commonhpp
import
  memoryhpp
import
  device/dev_iohpp
type
  IO* {.bycopy, importcpp.} = object
    memory*: ptr Memory
    port_io*: std_unordered_map[uint16, PortIO]
    port_io_map*: std_unordered_map[uint16, csize_t]
    mem_io*: std_unordered_map[uint32, MemoryIO]
    mem_io_map*: std_unordered_map[uint32, uint32]
  
proc initIO*(mem: ptr Memory): IO = 
  memory = mem

proc initIO*(): IO = 
  discard 

proc chk_memio*(this: var IO, `addr`: uint32): uint32 = 
  return get_memio_base(`addr`)
