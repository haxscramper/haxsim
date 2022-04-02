import std/[strutils, math]
import hmisc/core/all

type
  EmuEventKind* = enum
    eekStartInstructionFetch = "fetch instruction"
    # eekEndInstructionFetch
    eekCallOpcodeImpl = "call opcode"
    # eekCallOpcodeEnd
    eekGetModrmReg = "get modrm.reg"
    eekGetModrmMod = "get modrm.mod"
    eekGetModrmRM = "get modrm.rm"
    eekSetReg8 = "set reg 8"
    eekSetReg16 = "set reg 16"
    eekSetReg32 = "set reg 32"

    eekGetReg8 = "get reg 8"
    eekGetReg16 = "get reg 16"
    eekGetReg32 = "get reg 32"

    eekInIO = "io in"
    eekOutIO = "io out"

    eekEnd = "end"

  EmuEvent* = ref object of RootObj
    kind*: EmuEventKind
    memAddr*: uint64
    size*: uint64
    value*: EmuValue
    info*: typeof(instantiationInfo())

  EmuValueSystem* = enum evs2, evs8, evs10, evs16

  EmuValue* = object
    value*: uint64
    size*: int
    system*: EmuValueSystem

  EmuEventHandler* = proc(event: EmuEvent)

  EmuLogger* = ref object
    eventHandler*: EmuEventHandler

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
    eekStartInstructionFetch,
    eekCallOpcodeImpl
  }

  eekValueKinds* = {
    eekCallOpcodeImpl,
    eekGetModrmMod,
    eekGetModrmRm,
    eekGetModrmReg,
    eekSetReg8,
    eekSetReg16,
    eekSetReg32,
    eekGetReg8,
    eekGetReg16,
    eekGetReg32
  }

  eekEndKinds* = {
    eekEnd
  }

# func toStr*(ev: EmuEventKind): string {.magic: "EnumToStr".}
# func `$`*(ev: EmuEventKind): string = toStr(ev).substr(3)

proc ev*(kind: EmuEventKind): EmuEvent =
  EmuEvent(kind: kind)

proc ev*[T](der: typedesc[T], kind: EmuEventKind): T =
  T(kind: kind)

func evEnd*(): EmuEvent = EmuEvent(kind: eekEnd)


template log*(
    logger: EmuLogger, event: EmuEvent, instDepth: int = -1): untyped =

  var tmp = event
  tmp.info = instantiationInfo(instDepth, true)
  logger.eventHandler(event)

func setHook*(emu: var EmuLogger, handler: EmuEventHandler) =
  emu.eventHandler = handler

func initEmuLogger*(handler: EmuEventHandler = nil): EmuLogger =
  EmuLogger(eventHandler: handler)
