import commonhpp
import processorhpp
import ../../hardware/processorcpp
import memoryhpp
import iohpp

export commonhpp, processorhpp, memoryhpp, iohpp

type
  Hardware* {.inheritable.} = object
    cpu*: Processor
    mem*: Memory
    io*: IO
  
proc initHardware*(size: ESize, logger: EmuLogger): Hardware =
  result.cpu = initProcessor()
  result.mem = initMemory(size, logger)
  result.io = initIO(result.mem)
