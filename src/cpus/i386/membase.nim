import hmisc/wrappers/wraphelp
import hmisc/core/all
import std/[strformat, strutils]

type
  EmuRawMemError* = object of CatchableError

  ESize* = uint
  EPointer* = uint32
  EPtr* = uint32
  EByte* = uint8
  EWord* = uint16
  EDWord* = uint32

  MemData* = seq[EByte]
  MemBlob*[R: static[int]] = array[R, EByte]

  MemPointer* = object
    data*: ptr MemData
    pos*: EPointer

func asMemPointer*(s: var MemData, pos: EPointer): MemPointer =
  MemPointer(pos: pos, data: addr s)

func memBlob*(size: ESize): MemData =
  newSeq[EByte](size.int)

func toMemBlob*(it: string, result: var MemData) =
  result = memBlob(ESize(it.len))
  copymem(
    dest   = addr result[0],
    source = unsafeAddr it[0],
    size   = ESize(len(result)))

func toMemBlob*[T](it: T, result: var MemData) =
  result = memBlob(ESize(sizeof(it)))
  var arr = cast[PUarray[EByte]](unsafeAddr it)
  for byt in 0 ..< sizeof(T):
    result[byt] = arr[][byt]

func toMemData*[T](it: T): MemData =
  toMemBlob(it, result)

func fromMemBlob*[T](it: var T, blob: MemData) =
  var arr = cast[PUArray[EByte]](addr it)
  for byt in 0 ..< sizeof(T):
    # echov byt, blob[byt]
    arr[][byt] = blob[byt]

  # echov blob
  # echov it

func fromMemBlob*[T](blob: MemData): T =
  fromMemBlob(result, blob)

func memBlob*[T](): MemBlob[sizeof(T)] =
  assert 0 < len(result)

func toMemBlob*[T](it: T, result: MemBlob[sizeof(T)]) =
  result = cast[MemBlob[sizeof(T)]](it)

func fromMemBlob*[T](it: var T, blob: MemBlob[sizeof(T)]) =
  it = cast[T](blob)

func fromMemBlob*[T](blob: MemBlob[sizeof(T)]): T =
  result = cast[T](blob)

func len*(mem: MemPointer): int = mem.data[].len

func checkRange[A, B](mem: MemPointer | MemData, slice: HSlice[A, B]) =
  if slice.a.int < 0 or mem.len < slice.b.int:
    raise newException(
      EmuRawMemError,
      "Raw memory access is out of range. Given range is $#..$#, reading range: $#..$#" % [
        toHex(0),
        toHex(mem.len),
        toHex(slice.a.int),
        toHex(slice.b.int)
    ])

func copymem*(dest: var MemPointer, source: MemPointer, size: ESize) =
  assertRef(dest.data)
  assertRef(source.data)
  if 0 < source.data[].len:
    let rdest = dest.pos ..< dest.pos + size
    let rsrc = source.pos ..< source.pos + size
    dest.checkRange(rdest)
    source.checkRange(rsrc)
    dest.data[][rdest] = source.data[][rsrc]

func copymem*(
    dest: var MemData, source: MemPointer, size: ESize = ESize(len(dest))) =
  assert 0 < size
  if 0 < source.data[].len:
    let rdest = 0 ..< size
    let rsrc = source.pos ..< source.pos + size
    checkRange(dest, rdest)
    checkRange(source, rsrc)
    dest[rdest] = source.data[][rsrc]

func copymem*(
    dest: var MemPointer, source: MemData, size: ESize = ESize(len(source))) =
  assert 0 < size
  let rdest = dest.pos ..< dest.pos + size
  let rsrc = 0 ..< size
  dest.checkRange(rdest)
  dest.checkRange(rsrc)
  dest.data[][rdest] = source[rsrc]

func copymem*[R](
    dest: var MemPointer, source: MemBlob[R], size: ESize = R) =
  assert 0 < size
  let rdest = dest.pos ..< dest.pos + size
  let rsrc = 0 ..< size
  checkRange(dest, rdest)
  checkRange(source, rsrc)
  dest.data[][rdest] = source[rsrc]

func copymem*[R](
    dest: var MemBlob[R], source: MemPointer, size: ESize = R) =
  assert 0 < size
  let rsrc = source.pos ..< source.pos + size
  checkRange(source, rsrc)
  dest[0 ..< size] = source.data[][rsrc]
