import
  commonhpp
import
  dev_irqhpp
type
  Keyboard* {.bycopy, incompleteStruct, importcpp.} = object
    
  
type
  Mouse* {.bycopy, importcpp.} = object
    keyboard*: ptr Keyboard
    enable*: bool    
  
proc initMouse*(kb: ptr Keyboard): Mouse = 
  keyboard = kb
  enable = false
