import commonhpp
import memoryhpp
import device/dev_iohpp
import std/tables

type
  IO* {.bycopy.} = object
    memory*: ptr Memory
    port_io*: Table[uint16, PortIO]
    port_io_map*: Table[uint16, csize_t]
    mem_io*: Table[uint32, MemoryIO]
    mem_io_map*: Table[uint32, uint32]
  
proc initIO*(mem: ptr Memory): IO = 
  memory = mem

proc initIO*(): IO = 
  discard 

proc chk_memio*(this: var IO, `addr`: uint32): uint32 = 
  return get_memio_base(`addr`)
