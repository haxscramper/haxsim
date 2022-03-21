import commonhpp
import accesshpp
import interrupthpp
import device/fddhpp
import uihpp
import device/deviceshpp

type
  EmuSetting* {.bycopy, importcpp.} = object
    mem_size*: csize_t
    uiset*: UISetting
  
  Emulator* {.bycopy, importcpp.} = object
    ui*: ref UI
    fdd*: ref FDD
  
proc eject_floppy*(this: var Emulator, slot: uint8): bool = 
  return (if not this.fdd.isNIl(): this.fdd[].eject_disk(slot) else: false)

proc is_running*(this: var Emulator): bool = 
  return (if not this.ui.isNil(): this.ui[].get_status() else: false)

proc stop*(this: var Emulator): void = 
   # ui
  this.ui = nil

proc insert_floppy*(this: var Emulator, slot: uint8, disk: cstring, write: bool): bool = 
  return (if not this.fdd.isNil(): this.fdd[].insert_disk(slot, disk, write) else: false)
