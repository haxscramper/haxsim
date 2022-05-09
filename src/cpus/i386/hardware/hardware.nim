import common
import hardware/processor
import memory
import io

export common, processor, memory, io

type
  Hardware* = ref object of RootObj
    cpu*: Processor
    mem*: Memory
    io*: IO
  
proc initHardware*(size: ESize, logger: EmuLogger): Hardware =
  new(result)
  result.cpu = initProcessor(logger)
  result.mem = initMemory(size, logger)
  result.io = initIO(result.mem)
