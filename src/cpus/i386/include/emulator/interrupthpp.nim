import
  queue
import
  map
import
  commonhpp
import
  accesshpp
import
  device/pichpp
type
  IVT* {.bycopy, union, importcpp.} = object
    raw*: uint32
    field1*: IVT_field1_Type
  
type
  IVT_field1_Type* {.bycopy.} = object
    offset*: uint16
    segment*: uint16
  
proc offset*(this: IVT): uint16 = 
  this.field1.offset

proc `offset =`*(this: var IVT): uint16 = 
  this.field1.offset

proc segment*(this: IVT): uint16 = 
  this.field1.segment

proc `segment =`*(this: var IVT): uint16 = 
  this.field1.segment

type
  Interrupt* {.bycopy, importcpp.} = object
    intr_q*: std_queue[std_pair[uint8, bool]]
    pic_s*: ptr PIC  
  
proc set_pic*(this: var Interrupt, pic: ptr PIC, master: bool): void = 
  ((if master:
      pic_m
    
    else:
      pic_s
    )) = pic

proc restore_regs*(this: var Interrupt): void = 
  discard 

proc queue_interrupt*(this: var Interrupt, n: uint8, hard: bool): void = 
  intr_q.push(std.make_pair(n, hard))

proc iret*(this: var Interrupt): void = 
  discard 
