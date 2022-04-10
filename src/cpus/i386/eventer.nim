import std/[strutils, math]
import membase
import hmisc/core/all

type
  EmuEventKind* = enum
    # starter kind start
    eekInitEmulator = "init emulator"
    eekInitCPU = "init cpu"

    eekStartInstructionFetch = "fetch instruction"
    eekCallOpcodeImpl = "call opcode"

    eekGetCode = "get code"
    # starter kind end

    # value kind start
    eekGetModrmReg = "get modrm.reg"
    eekGetModrmMod = "get modrm.mod"
    eekGetModrmRM = "get modrm.rm"

    eekGetIP = "get IP"
    eekGetEIP = "get EIP"
    eekSetIP = "set IP"
    eekSetEIP = "set EIP"

    eekSetDtRegBase = "set DTREG base"
    eekSetDtRegLimit = "set DTREG limit"
    eekSetDtRegSelector = "set DTREG selector"
    eekGetDtregBase = "get DTREG base"
    eekGetDtregLimit = "get DTREG limit"
    eekGetDtregSelector = "get DTREG selector"

    eekGetSegment = "get sgreg"
    eekSetSegment = "set sgreg"

    eekSetReg8 = "set reg 8"
    eekSetReg16 = "set reg 16"
    eekSetReg32 = "set reg 32"
    eekGetReg8 = "get reg 8"
    eekGetReg16 = "get reg 16"
    eekGetReg32 = "get reg 32"

    eekSetMem8 = "set mem 8"
    eekSetMem16 = "set mem 16"
    eekSetMem32 = "set mem 32"
    eekGetMem8 = "get mem 8"
    eekGetMem16 = "get mem 16"
    eekGetMem32 = "get mem 32"


    eekGetMemBlob = "read blob"
    eekInIO = "io in"
    eekOutIO = "io out"
    # value kind end

    eekInterrupt = "interrupt"
    eekInterruptHandler = "execute interrupt handler setup"
    eekScope = "scope"
    eekEnd = "end"

  EmuEventCategory* = enum
    eecNone
    eecLowLevelMemory

  EmuEvent* = ref object of RootObj
    stackTrace*: seq[StackTraceEntry]

    category*: EmuEventCategory
    kind*: EmuEventKind
    memAddr*: uint64
    size*: uint64
    value*: EmuValue
    msg*: string
    info*: typeof(instantiationInfo())

  EmuValueSystem* = enum evs2, evs8, evs10, evs16

  EmuValue* = object
    value*: MemData
    size*: int
    system*: EmuValueSystem

  EmuEventHandler* = proc(event: EmuEvent)

  EmuLogger* = ref object
    procStackTrace: seq[string]

    eventHandler*: EmuEventHandler
    buffer*: seq[EmuEvent]

func getDeltaCalls*(
  logger: var EmuLogger, event: EmuEvent): seq[StackTraceEntry] =

  return event.stackTrace

func `$`*(id: BackwardsIndex): string = "^" & $id.int

func toString*(value: EmuValue): string =
  var total = value.size
  var bytes = value.value
  while 0 < total:
    # echov bytes.len()
    let size = tern(8 <= total, 8, total)
    let byte = bytes.pop()
    case value.system:
      of evs2: result &= toBin(BiggestInt(byte), size)
      of evs8: result &= toHex(byte, 8)[^((size div 3) + 2) .. ^1]
      of evs10: result &= ($byte)[^(log10(float(2 ^ size)).int + 2) .. ^1]
      of evs16: result &= toHex(byte)[^(size div 4) .. ^1]

    total -= size

func `$`*(va: EmuValue): string = toString(va)

func evalue*(
    value: SomeUnsignedInt,
    size: int,
    sys: EmuValueSystem = evs16): EmuValue =

  result = EmuValue(value: toMemData(value), size: size, system: sys)
  assert result.value.len < 100

func evalue*(
    value: SomeUnsignedInt,
    sys: EmuValueSystem = evs16): EmuValue =

  result = EmuValue(value: toMemData(value), size: sizeof(value) * 8, system: sys)
  assert result.value.len < 100


func evalueBlob*[T](
    value: T, size: int = sizeof(T) * 8, sys: EmuValueSystem = evs16): EmuValue =
  result = EmuValue(value: toMemData(value), size: size, system: sys)
  assert result.value.len < 100

const
  eekStartKinds* = {
    eekInitEmulator .. eekGetCode, eekInterruptHandler,
    eekScope
  }

  eekValueKinds* = {
    eekCallOpcodeImpl,
    eekGetModrmReg .. eekOutIO
  }

  eekEndKinds* = {
    eekEnd
  }

# func toStr*(ev: EmuEventKind): string {.magic: "EnumToStr".}
# func `$`*(ev: EmuEventKind): string = toStr(ev).substr(3)

func ev*(kind: EmuEventKind): EmuEvent =
  EmuEvent(kind: kind)

func ev*(kind: EmuEventKind, value: EmuValue): EmuEvent =
  EmuEvent(kind: kind, value: value)

func ev*(kind: EmuEventKind, value: EmuValue, memAddr: uint): EmuEvent =
  EmuEvent(kind: kind, value: value, memAddr: memaddr)

func ev*[T](der: typedesc[T], kind: EmuEventKind): T =
  T(kind: kind)

func evEnd*(): EmuEvent =
  EmuEvent(kind: eekEnd)

proc writeEvent(logger: EmuLogger, event: EmuEvent) =
  if logger.eventHandler.isNil():
    logger.buffer.add event

  else:
    var idx = 0
    while idx < logger.buffer.high:
      logger.eventHandler(logger.buffer[idx])
      inc idx

    logger.buffer.clear()
    logger.eventHandler(event)



func getTrace(): seq[StackTraceEntry] =
  {.cast(noSideEffect).}:
    when compileOption"stacktrace":
      result = getStackTraceEntries()
      if 1 < result.len:
        discard result.pop()

template log*(
    logger: EmuLogger, event: EmuEvent, instDepth: int = -1): untyped =
  bind writeEvent
  const iinfo = instantiationInfo(instDepth, true)
  {.line: iinfo.}:
    var tmp = event
    tmp.stackTrace = getTrace()
    tmp.info = iinfo
    writeEvent(logger, tmp)


template logScope*(
  logger: EmuLogger, event: EmuEvent, instDepth: int = -2): untyped =
  let tmp = event
  assert tmp.kind in eekStartKinds, $tmp.kind
  logger.log(tmp, instDepth)
  defer:
    logger.log(evEnd(), instDepth)

template scope*(logger: EmuLogger, name: string, depth: int = -3): untyped =
  var event = ev(eekScope)
  event.msg = name
  logScope(logger, event, depth)

func setHook*(emu: var EmuLogger, handler: EmuEventHandler) =
  emu.eventHandler = handler

func initEmuLogger*(handler: EmuEventHandler = nil): EmuLogger =
  EmuLogger(eventHandler: handler)
