import common
import eventer
import std/[math, strutils, sequtils]

type
  EmuMemoryError* = object of EmuImplError

template DEFAULTMEMORYSIZE*(): untyped {.dirty.} =
  (1 * KB)

template assertRange(memAddr: untyped, memLen: untyped): untyped =
  if this.memory.len() < int(memAddr + memLen - 1):
    raise newException(
      EmuMemoryError,
      "Memory access not in range. addr: $#, size: $#, memory: $#" % [
        $hshow(memAddr, clShowHex),
        $hshow(memLen, clShowHex),
        $hshow(this.memory.len(), clShowHex)
      ])

template INRANGE*(memAddr: untyped, memLen: untyped): untyped {.dirty.} =
  (int(memAddr + memLen - 1) < this.memory.len())

type
  Memory* = ref object
    logger*: EmuLogger
    memory*: seq[U8]
    a20gate*: bool

template log*(mem: Memory, ev: EmuEvent) =
  mem.logger.log(ev, -2)



proc setA20gate*(this: var Memory, ena: bool): void =
  this.a20gate = ena

proc isEnaA20gate*(this: Memory): bool =
  return this.a20gate

proc writeMem8*(this: var Memory, memAddr: U32, v: U8): void =
  assertRange(memAddr, 1)
  this.log ev(eekSetMem8, evalue(v, 8), memAddr)
  this.memory[memAddr] = v


proc writeMem16*(this: var Memory, memAddr: U32, v: U16): void =
  assertRange(memAddr, 2)
  this.log ev(eekSetMem16, evalue(v, 16), memAddr)
  (cast[ptr U16](addr this.memory[memAddr]))[] = v


proc writeMem32*(this: var Memory, memAddr: U32, v: U32): void =
  assertRange(memAddr, 4)
  this.log ev(eekSetMem32, evalue(v, 32), memAddr)
  (cast[ptr U32](addr this.memory[memAddr]))[] = v


proc readMem32*(this: var Memory, memAddr: U32): U32 =
  assertRange(memAddr, 4)
  result = (cast[ptr U32](addr this.memory[memAddr]))[]
  this.log ev(eekGetMem32, evalue(result, 32), memAddr)


proc readMem16*(this: var Memory, memAddr: U32): U16 =
  assertRange(memAddr, 2)
  result = (cast[ptr U16](addr this.memory[memAddr]))[]
  this.log ev(eekGetMem16, evalue(result, 16), memAddr)

proc readMem8*(this: var Memory, memAddr: U32): U8 =
  assertRange(memAddr, 1)
  result = this.memory[memAddr]
  this.log ev(eekGetMem8, evalue(result, 8), memAddr)

proc initMemory*(size: ESize, logger: EmuLogger): Memory =
  Memory(memory: newSeq[U8](size), a20gate: false, logger: logger)

proc destroyMemory*(this: var Memory): void =
  discard

func len*(mem: Memory): int = mem.memory.len()

proc dumpMem*(
    this: var Memory,
    memAddr: EPointer = 0,
    size: ESize = ESize(this.len())
  ): void =

  const perRow = 16
  let memAddr = (memAddr and not((0x10 - 1)).U32())
  let numLen = int(ceil(log10(float(memAddr + size))))
  echo repeat(" ", numLen), "  ", mapIt(0 ..< perRow, toHex(it)[^1..^1].align(2)).join(" ")

  for line in ceil(memAddr.float / perRow).int .. ceil(float(memAddr + size) / perRow).int:
    var buf = toHex(line * perRow)[^numLen .. ^1] & ": "
    var hasValue = false
    for cell in (line * perRow) ..< (line + 1) * perRow:
      if cell < this.memory.len:
        hasValue = true
        buf.add toHex(this.memory[cell])
        buf.add " "

    if hasValue:
      echo buf

proc readData*(
  this: var Memory, dst: EPointer, srcAddr: EPointer, size: ESize): ESize =

  assertRange(srcAddr, size)
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
  this.log ev(eekGetMemBlob).withIt do:
    it.value = evalueBlob(dst)
    it.memAddr = srcAddr
    it.msg = $typeof(T)

proc readDataBlob*[T](this: var Memory, srcAddr: EPointer): T =
  readDataBlob[T](this, result, srcAddr)

proc writeDataBlob*[T](this: var Memory, dstAddr: EPointer, src: T) =
  when compiles(memBlob[T]()):
    var srcBlob = memBlob[T]()

  else:
    var srcBlob = memBlob(ESize(sizeof(T)))

  toMemBlob(src, srcBlob)
  copymem(dest = this.memory.asMemPointer(0).asVar(), source = srcBlob)


proc writeDataBlob*(this: var Memory, dstAddr: EPointer, blob: var MemData) =
  assertRange(dstAddr.int(), blob.len())
  copymem(
    dest = this.memory.asMemPointer(dstAddr).asVar(),
    source = blob.asMemPointer(0),
    size = ESize(len(blob))
  )

proc writeData*(
    this: var Memory, dstAddr: EPointer, src: EPointer, size: ESize): ESize =

  assertRange(dstAddr, size)
  copymem(
    dest = this.memory.asMemPointer(dstAddr).asVar(),
    source = this.memory.asMemPointer(src),
    size = size)

  return size
