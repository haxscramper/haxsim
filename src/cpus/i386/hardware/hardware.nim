import common
import hardware/processor
import memory
import io

export common, processor, memory, io

type
  Hardware* {.inheritable.} = object
    cpu*: Processor
    mem*: Memory
    io*: IO
  
proc initHardware*(size: ESize, logger: EmuLogger): Hardware =
  result.cpu = initProcessor(logger)
  result.mem = initMemory(size, logger)
  result.io = initIO(result.mem)
