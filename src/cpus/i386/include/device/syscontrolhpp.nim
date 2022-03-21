import commonhpp
import dev_iohpp
import hardware/memoryhpp

type
  SysControl* {.bycopy.} = object
    mem*: ptr Memory
  
proc initSysControl*(m: ptr Memory): SysControl = 
  result.mem = m
