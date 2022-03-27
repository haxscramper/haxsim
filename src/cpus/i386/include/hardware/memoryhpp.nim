import commonhpp

template DEFAULTMEMORYSIZE*(): untyped {.dirty.} =
  (1 * KB)

template ASSERTRANGE*(`addr`: untyped, memLen: untyped): untyped {.dirty.} =
  ASSERT(int(`addr` + memLen - 1) < this.memory.len())

template INRANGE*(`addr`: untyped, memLen: untyped): untyped {.dirty.} =
  (int(`addr` + memLen - 1) < this.memory.len())

type
  Memory* = ref object
    memory*: seq[uint8]
    a20gate*: bool

proc setA20gate*(this: var Memory, ena: bool): void =
  this.a20gate = ena

proc isEnaA20gate*(this: Memory): bool =
  return this.a20gate

proc writeMem8*(this: var Memory, `addr`: uint32, v: uint8): void =
  if INRANGE(`addr`, 1):
    this.memory[`addr`] = v


proc writeMem16*(this: var Memory, `addr`: uint32, v: uint16): void =
  if INRANGE(`addr`, 2):
    (cast[ptr uint16](addr this.memory[`addr`]))[] = v


proc writeMem32*(this: var Memory, `addr`: uint32, v: uint32): void =
  if INRANGE(`addr`, 4):
    (cast[ptr uint32](addr this.memory[`addr`]))[] = v


proc readMem32*(this: var Memory, `addr`: uint32): uint32 =
  if INRANGE(`addr`, 4):
    return (cast[ptr uint32](addr this.memory[`addr`]))[]

  else:
    return 0

proc readMem16*(this: var Memory, `addr`: uint32): uint16 =
  if INRANGE(`addr`, 2):
    return (cast[ptr uint16](addr this.memory[`addr`]))[]

  else:
    return 0

proc readMem8*(this: var Memory, `addr`: uint32): uint8 =
  if INRANGE(`addr`, 1):
    return this.memory[`addr`]

  else:
    return 0

proc initMemory*(size: uint32): Memory =
  Memory(memory: newSeq[uint8](size), a20gate: false)

proc destroyMemory*(this: var Memory): void =
  discard

proc dumpMem*(this: var Memory, `addr`: uint32, size: csizeT): void =
  let `addr` = (`addr` and not((0x10 - 1)).uint32())
  for idx in 0 ..< size:
    MSG("0x%08x : ", `addr` + idx * 0x10)
    for i in 0 ..< 4:
      MSG("%08x ", (cast[ptr UncheckedArray[uint32]](this.memory))[
        (`addr` + idx * 0x10) div 4 + uint64(i)])

    MSG("\\n")

proc readData*(this: var Memory, dst: pointer, srcAddr: uint32, size: csizeT): csizeT =
  ASSERTRANGE(srcAddr, size)
  copymem(dest = dst, source = addr this.memory[srcAddr], size = size)
  return size

proc writeData*(this: var Memory, dstAddr: uint32, src: pointer, size: csizeT): csizeT =
  ASSERTRANGE(dstAddr, size)
  copymem(dest = addr this.memory[dstAddr], source = src, size = size)
  return size
