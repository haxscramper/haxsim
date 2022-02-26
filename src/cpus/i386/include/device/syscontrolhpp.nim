import
  commonhpp
import
  dev_iohpp
import
  hardware/memoryhpp
type
  SysControl* {.bycopy, importcpp.} = object
    mem*: ptr Memory
  
proc initSysControl*(m: ptr Memory): SysControl = 
  mem = m
