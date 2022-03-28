type
  EmuEventKind* = enum
    eekStartInstructionFetch
    eekEndInstructionFetch

  EmuEvent* = ref object of RootObj
    kind*: EmuEventKind
    info*: typeof(instantiationInfo())

  EmuEventHandler* = proc(event: EmuEvent)

  EmuLogger* = ref object
    eventHandler*: EmuEventHandler

proc ev*(kind: EmuEventKind): EmuEvent =
  EmuEvent(kind: kind)

template log*(
    logger: EmuLogger, event: EmuEvent, instDepth: int = -1): untyped =

  var tmp = event
  tmp.info = instantiationInfo(instDepth, true)
  logger.eventHandler(event)

proc initEmuLogger*(handler: EmuEventHandler): EmuLogger =
  EmuLogger(eventHandler: handler)
