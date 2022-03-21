import commonhpp
import device/vgahpp
import device/keyboardhpp
import device/mousehpp
import hardware/memoryhpp

type
  UISetting* {.bycopy, importcpp.} = object
    enable*: bool
    full*: bool
    vm*: bool
  
type
  UI* {.bycopy, importcpp.} = object
    set*: UISetting    
    vga*: ptr VGA
    keyboard*: ptr Keyboard
    working*: bool    
    capture*: bool    
    size_y*: uint16    
    image*: ptr uint8
    field7*: UI_field7_Type    

  UI_field7_Type* {.bycopy.} = object
    Y*: int16
    click*: array[2, bool]

proc get_status*(this: var UI): bool = 
  return this.working

proc get_keyboard*(this: var UI): ptr Keyboard = 
  return this.keyboard

proc get_vga*(this: var UI): ptr VGA = 
  return this.vga


proc Y*(this: UI): int16 = this.field7.Y
proc `Y=`*(this: var UI): int16 = this.field7.Y
proc click*(this: UI): array[2, bool] = this.field7.click
proc `click=`*(this: var UI): array[2, bool] = this.field7.click
