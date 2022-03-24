import
  stdioh
import
  unistdh
import
  stdargh
import
  stdlibh
import
  util/debughpp
type
  TypeSet* {.bycopy.} = object
    name*: cstring    
    fp*: ptr FILE
    fatal*: bool    
  
var typeset: ptr UncheckedArray[TypeSet] = @([("ASSERT", stderr, true), ("ERROR", stderr, true), ("WARN", stderr, false), ("INFO", stdout, false), (nil, stdout, false)])
var debug_level: cuint = 0
proc debug_print*(`type`: cint, file: cstring, function: cstring, line: cint, level: cuint, fmt: cstring): void {.varargs.} = 
  var ap: va_list
  var ts: TypeSet = typeset[`type`]
  if ts.fatal:
    cxx_goto print
  
  if level > 0 and not(((1 shl (level - 1)) and debug_level)):
    return 
  
  block print:
    if ts.name:
      fprintf(ts.fp, (if level:
             "[%s_%d] "
           
           else:
             "[%s] "
           ), ts.name, level)
      fprintf(ts.fp, "%s (%s:%d) ", function, file, line)
    
  va_start(ap, fmt)
  vfprintf(ts.fp, fmt, ap)
  va_end(ap)
  if ts.name:
    fprintf(ts.fp, "\\n")
  
  if ts.fatal:
    raise -1
  

proc set_debuglv*(verbose: cstring): void = 
  debug_level = atoi(verbose)
