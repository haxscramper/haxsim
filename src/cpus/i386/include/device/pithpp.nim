import commonhpp
import dev_irqhpp
import dev_iohpp

type
  Timer* {.bycopy.} = object
    mode*: uint8
    count*: uint16
    def*: uint16
    running*: bool
    # th*: std_thread

  PIT* {.bycopy.} = object of IRQ
    portio*: PortIO
    cwr*: PIT_cwr_Type    
    timer*: array[3, Timer]
  
  field1_Type* {.bycopy.} = object
    BCD* {.bitsize: 1.}: uint8
    mode* {.bitsize: 3.}: uint8
    RL* {.bitsize: 2.}: uint8
    SC* {.bitsize: 2.}: uint8

  PIT_cwr_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type

  
proc BCD*(this: PIT_cwr_Type): uint8 = this.field1.BCD
proc `BCD=`*(this: var PIT_cwr_Type): uint8 = this.field1.BCD
proc mode*(this: PIT_cwr_Type): uint8 = this.field1.mode
proc `mode=`*(this: var PIT_cwr_Type): uint8 = this.field1.mode
proc RL*(this: PIT_cwr_Type): uint8 = this.field1.RL
proc `RL=`*(this: var PIT_cwr_Type): uint8 = this.field1.RL
proc SC*(this: PIT_cwr_Type): uint8 = this.field1.SC
proc `SC=`*(this: var PIT_cwr_Type): uint8 = this.field1.SC
