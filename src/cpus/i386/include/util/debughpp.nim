import
  stdioh
import
  unistdh

type
  F_MSG* = enum
    F_ASSERT
    F_ERROR
    F_WARN
    F_INFO
    F_MSG
  
template DEBUG_PRINT*(`type`: untyped, lv: untyped, fmt: untyped): untyped {.dirty.} = 
  debug_print(`type`, __FILE__, __FUNCTION__, __LINE__, lv, fmt, ` __VA_ARGS__`)


template ASSERT*(cond: untyped): untyped {.dirty.} = 
  if not((cond)):
    DEBUG_PRINT(F_ASSERT, 0, astToStr(cond))
  

template ERROR*(fmt: untyped): untyped {.dirty.} = 
  DEBUG_PRINT(F_ERROR, 0, fmt, ` __VA_ARGS__`)

template WARN*(fmt: untyped): untyped {.dirty.} = 
  ON_DEBUG(F_WARN, 0, fmt, ` __VA_ARGS__`)

template INFO*(lv: untyped, fmt: untyped): untyped {.dirty.} = 
  ON_DEBUG(F_INFO, lv, fmt, ` __VA_ARGS__`)

template DEBUG_MSG*(lv: untyped, fmt: untyped): untyped {.dirty.} = 
  ON_DEBUG(F_MSG, lv, fmt, ` __VA_ARGS__`)

template MSG*(fmt: untyped): untyped {.dirty.} = 
  fprintf(stdout, fmt, ` __VA_ARGS__`)

proc debug_print*(`type`: cint, file: cstring, function: cstring, line: cint, level: cuint, fmt: cstring): void {.varargs.} = 
  discard 

proc set_debuglv*(verbose: cstring): void = 
  discard 
