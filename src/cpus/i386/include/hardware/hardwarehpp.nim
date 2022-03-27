import commonhpp
import processorhpp
import memoryhpp
import iohpp

export commonhpp, processorhpp, memoryhpp, iohpp

type
  Hardware* {.inheritable.} = object
    cpu*: Processor
    mem*: Memory
    io*: IO
  
proc initHardware*(size: uint32): Hardware =
  result.mem = initMemory(size)
