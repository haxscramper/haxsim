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

proc readData*(
  this: var Memory, dst: EPointer, srcAddr: EPointer, size: ESize): ESize =

  ASSERTRANGE(srcAddr, size)
  copymem(
    dest = this.memory.asMemPointer(dst).asVar(),
    source = this.memory.asMemPointer(srcAddr),
    size = size)

  return size


proc readDataBlob*[T](this: var Memory, dst: var T, srcAddr: EPointer) =
  when compiles(memBlob[T]()):
    # `{.bitisize.}` fields break `sizeof` for compile-time, so it is not
    # possible to have proper `array[sizeof(T)]`
    var dstBlob = memBlob[T]()

  else:
    var dstBlob = memBlob(ESize(sizeof(T)))

  copymem(
    dest = dstBlob,
    source = this.memory.asMemPointer(srcAddr),
  )

  fromMemBlob(dst, dstBlob)


proc writeDataBlob*[T](this: var Memory, dstAddr: EPointer, src: T) =
  when compiles(memBlob[T]()):
    var srcBlob = memBlob[T]()

  else:
    var srcBlob = memBlob(ESize(sizeof(T)))

  toMemBlob(src, srcBlob)
  copymem(dest = this.memory.asMemPointer(0).asVar(), source = srcBlob)


proc writeDataBlob*(this: var Memory, srcAddr: EPointer, blob: MemData) =
  copymem(
    dest = this.memory.asMemPointer(srcAddr).asVar(),
    source = blob.asMemPointer(0),
    size = ESize(len(blob))
  )

proc writeData*(
    this: var Memory, dstAddr: EPointer, src: EPointer, size: ESize): ESize =

  ASSERTRANGE(dstAddr, size)
  copymem(
    dest = this.memory.asMemPointer(dstAddr).asVar(),
    source = this.memory.asMemPointer(src),
    size = size)

  return size
