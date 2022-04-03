import commonhpp
import eventer
import std/strformat
import std/math

template DEFAULTMEMORYSIZE*(): untyped {.dirty.} =
  (1 * KB)

template ASSERTRANGE*(memAddr: untyped, memLen: untyped): untyped {.dirty.} =
  assert(
    int(memAddr + memLen - 1) < this.memory.len(),
    "Memory access not in range. addr: $#, size: $#, memory: $#" % [
      $memAddr,
      $memLen,
      $this.memory.len()
    ]
  )

template INRANGE*(memAddr: untyped, memLen: untyped): untyped {.dirty.} =
  (int(memAddr + memLen - 1) < this.memory.len())

type
  Memory* = ref object
    logger*: EmuLogger
    memory*: seq[uint8]
    a20gate*: bool

template log*(mem: Memory, ev: EmuEvent) =
  mem.logger.log(ev, -2)



proc setA20gate*(this: var Memory, ena: bool): void =
  this.a20gate = ena

proc isEnaA20gate*(this: Memory): bool =
  return this.a20gate

proc writeMem8*(this: var Memory, memAddr: uint32, v: uint8): void =
  if INRANGE(memAddr, 1):
    this.memory[memAddr] = v


proc writeMem16*(this: var Memory, memAddr: uint32, v: uint16): void =
  if INRANGE(memAddr, 2):
    (cast[ptr uint16](addr this.memory[memAddr]))[] = v


proc writeMem32*(this: var Memory, memAddr: uint32, v: uint32): void =
  if INRANGE(memAddr, 4):
    (cast[ptr uint32](addr this.memory[memAddr]))[] = v


proc readMem32*(this: var Memory, memAddr: uint32): uint32 =
  if INRANGE(memAddr, 4):
    return (cast[ptr uint32](addr this.memory[memAddr]))[]

  else:
    return 0

proc readMem16*(this: var Memory, memAddr: uint32): uint16 =
  if INRANGE(memAddr, 2):
    return (cast[ptr uint16](addr this.memory[memAddr]))[]

  else:
    return 0

proc readMem8*(this: var Memory, memAddr: uint32): uint8 =
  if INRANGE(memAddr, 1):
    result = this.memory[memAddr]
    this.log ev(eekGetMem8, evalue(result, 8), memAddr)

  else:
    assert(false, "OOM - $# is not in 0..$#" % [$memAddr, $this.memory.high])

proc initMemory*(size: ESize, logger: EmuLogger): Memory =
  Memory(memory: newSeq[uint8](size), a20gate: false, logger: logger)

proc destroyMemory*(this: var Memory): void =
  discard

func len*(mem: Memory): int = mem.memory.len()

proc dumpMem*(
    this: var Memory,
    memAddr: EPointer = 0,
    size: ESize = ESize(this.len())
  ): void =

  let memAddr = (memAddr and not((0x10 - 1)).uint32())
  for line in ceil(memAddr.float / 8).int ..< ceil(float(memAddr + size) / 8).int:
    var buf = toHex(line * 8)[^int(ceil(log10(float(memAddr + size)))) .. ^1] & ": "
    for cell in (line * 8) ..< (line + 1) * 8:
      buf.add toHex(this.memory[cell])
      buf.add " "

    echo buf

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


proc writeDataBlob*(this: var Memory, dstAddr: EPointer, blob: var MemData) =
  ASSERTRANGE(dstAddr.int(), blob.len())
  copymem(
    dest = this.memory.asMemPointer(dstAddr).asVar(),
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
