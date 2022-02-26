import
  commonhpp
import
  processorhpp
import
  memoryhpp
import
  iohpp
type
  Hardware* {.bycopy, importcpp.} = object
    
  
proc initHardware*(size: csize_t): Hardware = 
  discard 
