import util/debughpp
import std/strutils
export strutils
import hmisc/wrappers/wraphelp
import hmisc/other/hpprint
export hpprint
export debughpp
import hmisc/core/all
export all

const KB* = 1024
template MB*(): untyped {.dirty.} = (KB * 1024)
template GB*(): untyped {.dirty.} = (MB * 1024)

func toBool*(i: SomeInteger): bool = i != 0
func toBool*[T](i: ptr T): bool = not isNil(i)
func toBool*[T](i: ref T): bool = not isNil(i)

# proc preInc*[I: SomeInteger](v: var I): I {.discardable.} = discard
# proc postInc*[I: SomeInteger](v: var I): I {.discardable.} = discard
# proc preDec*[I: SomeInteger](v: var I): I {.discardable.} = discard
# proc postDec*[I: SomeInteger](v: var I): I {.discardable.} = discard

type
  ESize* = uint
  EPointer* = uint32
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

func memBlob*(size: ESize): MemData = discard

func toMemBlob*[T](it: T, result: var MemData) =
  result = memBlob(ESize(sizeof(it)))
  var arr = cast[PUarray[EByte]](unsafeAddr it)
  for byt in 0 ..< sizeof(T):
    result[byt] = arr[][byt]

func fromMemBlob*[T](it: var T, blob: MemData) =
  var arr = cast[PUArray[EByte]](addr it)
  for byt in 0 ..< sizeof(T):
    arr[][byt] = blob[byt]

func memBlob*[T](): MemBlob[sizeof(T)] = discard

func toMemBlob*[T](it: T, result: MemBlob[sizeof(T)]) =
  result = cast[MemBlob[sizeof(T)]](it)

func fromMemBlob*[T](it: var T, blob: MemBlob[sizeof(T)]) =
  it = cast[T](blob)

func copymem*(dest: var MemPointer, source: MemPointer, size: ESize) =
  assertRef(dest.data)
  assertRef(source.data)
  dest.data[][dest.pos ..< dest.pos + size] =
    source.data[][source.pos ..< source.pos + size]

func copymem*(
    dest: var MemData, source: MemPointer, size: ESize = ESize(len(dest))) =
  dest[0 ..< size] = source.data[][source.pos ..< source.pos + size]

func copymem*(
    dest: var MemPointer, source: MemData, size: ESize = ESize(len(source))) =
  dest.data[][dest.pos ..< dest.pos + size] = source[0 ..< size]

func copymem*[R](
    dest: var MemPointer, source: MemBlob[R], size: ESize = R) =
  dest.data[][dest.pos ..< dest.pos + size] = source[0 ..< size]

func copymem*[R](
    dest: var MemBlob[R], source: MemPointer, size: ESize = R) =
  dest[0 ..< size] = source.data[][source.pos ..< source.pos + size]
