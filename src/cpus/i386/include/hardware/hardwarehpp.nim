import commonhpp
import processorhpp
import memoryhpp
import iohpp

export commonhpp, processorhpp, memoryhpp, iohpp

type
  Hardware* {.bycopy, inheritable.} = object
    cpu*: Processor
    mem*: Memory
    io*: IO
  
proc initHardware*(size: csize_t): Hardware =
  discard
  # result.mem = initMemory(size)
