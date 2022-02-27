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
  

template ERROR*(
    fmt: untyped, args: varargs[untyped]): untyped {.dirty.} =
  discard

template WARN*(
    fmt: untyped, args: varargs[untyped]): untyped {.dirty.} =
  discard

template INFO*(
    lv: untyped, fmt: untyped, args: varargs[untyped]): untyped {.dirty.} =
  discard

template DEBUG_MSG*(
    lv: untyped, fmt: untyped, args: varargs[untyped]): untyped {.dirty.} =
  discard

template MSG*(fmt: untyped, args: varargs[untyped]): untyped {.dirty.} =
  echo fmt
  # fprintf(stdout, fmt)

proc debug_print*(
    `type`: F_MSG_ENUM,
    level: cuint,
    fmt: cstring): void {.varargs.} =
  discard 

proc set_debuglv*(verbose: cstring): void = 
  discard 
