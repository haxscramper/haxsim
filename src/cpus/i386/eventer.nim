import std/[strutils, math]
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

    eekInIO = "io in"
    eekOutIO = "io out"
    # value kind end

    eekInterrupt = "interrupt"
    eekInterruptHandler = "execute interrupt handler setup"
    eekScope = "scope"
    eekEnd = "end"

  EmuEvent* = ref object of RootObj
    stackTrace*: seq[StackTraceEntry]

    kind*: EmuEventKind
    memAddr*: uint64
    size*: uint64
    value*: EmuValue
    msg*: string
    info*: typeof(instantiationInfo())

  EmuValueSystem* = enum evs2, evs8, evs10, evs16

  EmuValue* = object
    value*: uint64
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
  # echov value.value.toHex(), value.system
  case value.system:
    of evs2: result = toBin(value.value.BiggestInt, value.size)
    of evs8: result = toHex(value.value, 8)[^((value.size div 3) + 2) .. ^1]
    of evs10: result = ($value.value)[
      ^(log10(float(2 ^ value.size)).int + 2) .. ^1]
    of evs16:
      let slice = ^((value.size div 4) + 2) .. ^1
      result = toHex(value.value)[slice]

func `$`*(va: EmuValue): string = toString(va)

func evalue*(
    value: SomeUnsignedInt,
    size: int,
    sys: EmuValueSystem = evs16): EmuValue =

  EmuValue(value: value.uint64, size: size, system: sys)

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
  var tmp = event
  tmp.stackTrace = getTrace()
  tmp.info = instantiationInfo(instDepth, true)
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
