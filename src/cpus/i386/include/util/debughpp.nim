type
  F_MSG_ENUM* = enum
    F_ASSERT
    F_ERROR
    F_WARN
    F_INFO
    F_MSG
  
template DEBUG_PRINT*(`type`: untyped, lv: untyped, fmt: untyped): untyped {.dirty.} = 
  debug_print(`type`, lv, fmt)


template ASSERT*(cond: untyped): untyped {.dirty.} = 
  if not((cond)):
    DEBUG_PRINT(F_ASSERT, 0, astToStr(cond))
  

template ERROR*(fmt: untyped): untyped {.dirty.} = 
  DEBUG_PRINT(F_ERROR, 0, fmt)

template WARN*(fmt: untyped): untyped {.dirty.} = 
  ON_DEBUG(F_WARN, 0, fmt)

template INFO*(lv: untyped, fmt: untyped): untyped {.dirty.} = 
  ON_DEBUG(F_INFO, lv, fmt)

template DEBUG_MSG*(lv: untyped, fmt: untyped): untyped {.dirty.} = 
  ON_DEBUG(F_MSG, lv, fmt)

template MSG*(fmt: untyped): untyped {.dirty.} = 
  fprintf(stdout, fmt)

proc debug_print*(
    `type`: F_MSG_ENUM,
    level: cuint,
    fmt: cstring): void {.varargs.} =
  discard 

proc set_debuglv*(verbose: cstring): void = 
  discard 
