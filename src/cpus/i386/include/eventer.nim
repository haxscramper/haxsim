type
  EmuEventKind* = enum
    eekStartInstructionFetch
    eekEndInstructionFetch
    eekCallOpcodeImpl
    eekCallOpcodeEnd
    eekInIO
    eekOutIO

    eekEnd

  EmuEvent* = ref object of RootObj
    kind*: EmuEventKind
    memAddr*: uint16
    size*: uint16
    info*: typeof(instantiationInfo())

  EmuEventHandler* = proc(event: EmuEvent)

  EmuLogger* = ref object
    eventHandler*: EmuEventHandler

proc ev*(kind: EmuEventKind): EmuEvent =
  EmuEvent(kind: kind)

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
