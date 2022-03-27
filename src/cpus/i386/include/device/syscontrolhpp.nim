import commonhpp
import dev_iohpp
import hardware/memoryhpp

type
  SysControl* = object
    portio*: PortIO
    mem*: Memory
  
proc initSysControl*(m: Memory): SysControl =
  result.mem = m
