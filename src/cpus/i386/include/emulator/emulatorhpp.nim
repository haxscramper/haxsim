import
  commonhpp
import
  accesshpp
import
  interrupthpp
import
  uihpp
import
  device/deviceshpp
type
  EmuSetting* {.bycopy, importcpp.} = object
    mem_size*: csize_t
    uiset*: UISetting
  
type
  Emulator* {.bycopy, importcpp.} = object
    ui*: ptr UI
    fdd*: ptr FDD
  
proc eject_floppy*(this: var Emulator, slot: uint8): bool = 
  return (if fdd:
            fdd.eject_disk(slot)
          
          else:
            false
          )

proc is_running*(this: var Emulator): bool = 
  return (if ui:
            ui.get_status()
          
          else:
            false
          )

proc stop*(this: var Emulator): void = 
  cxx_delete ui
  ui = nil

proc insert_floppy*(this: var Emulator, slot: uint8, disk: cstring, write: bool): bool = 
  return (if fdd:
            fdd.insert_disk(slot, disk, write)
          
          else:
            false
          )
