import commonhpp
import dev_iohpp
import hardware/memoryhpp

type
  SysControl* {.bycopy.} = object
    portio*: PortIO
    mem*: ptr Memory
  
proc initSysControl*(m: ptr Memory): SysControl = 
  result.mem = m
