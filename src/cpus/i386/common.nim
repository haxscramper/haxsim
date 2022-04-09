import instruction/[syntaxes, opcodes]
import std/[strformat, enumutils]
export strformat
import std/strutils
export strutils
import hmisc/wrappers/wraphelp
import hmisc/other/hpprint
import hmisc/algo/clformat
export hpprint
import hmisc/core/all
export all
import eventer
export eventer
import std/math

template ASSERT*(expr: untyped): untyped =
  assert expr

template ERROR*(msg: string, other: varargs[untyped]): untyped =
  assert false, msg

template INFO*(lvl: int, msg: string, other: varargs[untyped]): untyped =
  echo instantiationInfo(), msg

func pow2*(pow: int): uint =
  result = 2
  for _ in 0 ..< pow:
    result = result * 2

type
  NBits*[Count: static[int]] = range[0'u .. pow2(Count) - 1]

type
  EmuCpuExceptionKind* = enum
    EXP_DE = (0x00u8, "divide by zero")
    EXP_DB = (0x01u8, "debug")
    EXP_BP = (0x03u8, "breakpoint")
    EXP_OF = (0x04u8, "overflow")
    EXP_BR = (0x05u8, "bound range exceeded")
    EXP_UD = (0x06u8, "invalid opcode")
    EXP_NM = (0x07u8, "device not available")
    EXP_DF = (0x08u8, "double fault")
    EXP_TS = (0x0Au8, "invalid TSS")
    EXP_NP = (0x0Bu8, "segment not present")
    EXP_SS = (0x0Cu8, "stack-segment fault")
    EXP_GP = (0x0Du8, "general protection fault")
    EXP_PF = (0x0Eu8, "page fault")
    EXP_MF = (0x10u8, "floating-point exception")
    EXP_AC = (0x11u8, "alignment check")
    EXP_MC = (0x12u8, "machine check")
    EXP_XF = (0x13u8, "simd floating point exception")
    EXP_VE = (0x14u8, "virtualization exception")
    EXP_SX = (0x1Eu8, "security exception")

  EmuCpuException* = object of CatchableError
    ## CPU exception - part of the CPU operation
    kind*: EmuCpuExceptionKind

  EmuImplError* = object of CatchableError
    ## Error in the CPU implementation

  EmuIoError* = object of EmuImplError
    ## IO-related errors
    port*: uint16

  EmuExceptionEvent* = ref object of EmuEvent
    exception*: ref EmuCpuException

func newException*(
    kind: EmuCpuExceptionKind, desc: string): ref EmuCpuException =
  new(result)
  result.msg = "Exception during evaluation #$# ($#). $#" % [
    symbolName(kind).substr(4),
    $kind,
    desc
  ]
  result.kind = kind

# type
#   exception_t* = enum

# template EXCEPTION*(n: untyped, c: untyped, msg: string = ""): untyped {.deprecated: "[#########]".} =
#   if c:
#     raise newException(n, msg)


template EXCEPTION_WITH*(n: untyped, c: untyped, e: untyped): untyped {.dirty.} =
  if c:
    assert false, "exception interrupt %d (%s)"
    e
    raise newException(n, "")


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

func toBin*(u: uint, size: int): string =
  toBin(u.BiggestInt, size)

func isExtended*(icode: ICode): bool =
  toBool((icode.uint and 0xF0_FF_FF) and 0x0F_00_00)

const
  clShowHex* = hdisplay(flags += {dfUseHex, dfSplitNumbers})
  clShowBin* = hdisplay(flags += {dfUseBin, dfSplitNumbers})

func opIdx*(icode: ICode): uint16 =
  if isExtended(icode):
    uint16((icode.uint and 0xFF_FF_00) shr 16)

  else:
    uint16((icode.uint and 0xFF_00_00) shr 16)


func opExt*(icode: ICode): uint8 =
  uint8(icode.uint and 0x00_00_FF)

func toOpcode*(code: uint16, ext: uint8 = 0): ICode =
  tern(toBool((code and 0xF0_FF) and 0x0F_00),
       ICode((code.uint64 shl 12) and ext),
       ICode((code.uint64 shl 16) and ext))

func formatOpcode*(code: uint16, ext: uint8 = 0): string =
  let is2 = toBool(code and 0x0F00)
  "0x$# ($#)" % [
    toHex(code)[^tern(is2, 4, 2) .. ^1],
    $toOpcode(code, ext)
  ]


func toInt*(u: uint8): int8 = cast[int8](u)
func toInt*(u: uint16): int16 = cast[int16](u)
func toInt*(u: uint32): int32 = cast[int32](u)
