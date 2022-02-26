import
  commonhpp
import
  dev_irqhpp
import
  dev_iohpp
const MAX_IRQ* = 8
type
  OCW2* {.bycopy, union, importcpp.} = object
    raw*: uint8
    field1*: OCW2_field1_Type
  
type
  OCW2_field1_Type* {.bycopy.} = object
    L* {.bitsize: 3.}: uint8
    * {.bitsize: 2.}: uint8
    EOI* {.bitsize: 1.}: uint8
    SL* {.bitsize: 1.}: uint8
    R* {.bitsize: 1.}: uint8
  
proc L*(this: OCW2): uint8 = 
  this.field1.L

proc `L =`*(this: var OCW2): uint8 = 
  this.field1.L

proc *(this: OCW2): uint8 = 
  this.field1.

proc ` =`*(this: var OCW2): uint8 = 
  this.field1.

proc EOI*(this: OCW2): uint8 = 
  this.field1.EOI

proc `EOI =`*(this: var OCW2): uint8 = 
  this.field1.EOI

proc SL*(this: OCW2): uint8 = 
  this.field1.SL

proc `SL =`*(this: var OCW2): uint8 = 
  this.field1.SL

proc R*(this: OCW2): uint8 = 
  this.field1.R

proc `R =`*(this: var OCW2): uint8 = 
  this.field1.R

type
  PIC* {.bycopy, importcpp.} = object
    pic_m*: ptr PIC    
    irq*: array[, ptr IRQ]
    irr*: uint8        
    isr*: uint8        
    imr*: uint8        
    ic1*: PIC_ic1_Type        
    ic2*: PIC_ic2_Type        
    ic3*: PIC_ic3_Type        
    ic4*: PIC_ic4_Type        
    init_icn*: int8        
  
proc chk_m2s_pic*(this: var PIC, n: uint8): bool = 
  return not(ic1.SNGL) and not(pic_m) and ic3.raw and (1 shl n)

proc set_irq*(this: var PIC, n: uint8, dev: ptr IRQ): void = 
  if n < MAX_IRQ:
    irq[n] = dev
  
  else:
    ERROR("IRQ out of bound : %d", n)
  

type
  field1_Type* {.bycopy.} = object
    IC4* {.bitsize: 1.}: uint8
    SNGL* {.bitsize: 1.}: uint8
    ADI* {.bitsize: 1.}: uint8
    LTIM* {.bitsize: 1.}: uint8
    * {.bitsize: 1.}: uint8
    IVA_l* {.bitsize: 3.}: uint8
  
proc IC4*(this: PIC_ic1_Type): uint8 = 
  this.field1.IC4

proc `IC4 =`*(this: var PIC_ic1_Type): uint8 = 
  this.field1.IC4

proc SNGL*(this: PIC_ic1_Type): uint8 = 
  this.field1.SNGL

proc `SNGL =`*(this: var PIC_ic1_Type): uint8 = 
  this.field1.SNGL

proc ADI*(this: PIC_ic1_Type): uint8 = 
  this.field1.ADI

proc `ADI =`*(this: var PIC_ic1_Type): uint8 = 
  this.field1.ADI

proc LTIM*(this: PIC_ic1_Type): uint8 = 
  this.field1.LTIM

proc `LTIM =`*(this: var PIC_ic1_Type): uint8 = 
  this.field1.LTIM

proc *(this: PIC_ic1_Type): uint8 = 
  this.field1.

proc ` =`*(this: var PIC_ic1_Type): uint8 = 
  this.field1.

proc IVA_l*(this: PIC_ic1_Type): uint8 = 
  this.field1.IVA_l

proc `IVA_l =`*(this: var PIC_ic1_Type): uint8 = 
  this.field1.IVA_l

type
  PIC_ic1_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  
type
  field1_Type* {.bycopy.} = object
    IVA_h* {.bitsize: 3.}: uint8
    IVA_x86* {.bitsize: 5.}: uint8
  
proc IVA_h*(this: PIC_ic2_Type): uint8 = 
  this.field1.IVA_h

proc `IVA_h =`*(this: var PIC_ic2_Type): uint8 = 
  this.field1.IVA_h

proc IVA_x86*(this: PIC_ic2_Type): uint8 = 
  this.field1.IVA_x86

proc `IVA_x86 =`*(this: var PIC_ic2_Type): uint8 = 
  this.field1.IVA_x86

type
  PIC_ic2_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  
type
  field1_Type* {.bycopy.} = object
    S0* {.bitsize: 1.}: uint8
    S1* {.bitsize: 1.}: uint8
    S2* {.bitsize: 1.}: uint8
    S3* {.bitsize: 1.}: uint8
    S4* {.bitsize: 1.}: uint8
    S5* {.bitsize: 1.}: uint8
    S6* {.bitsize: 1.}: uint8
    S7* {.bitsize: 1.}: uint8
  
proc S0*(this: PIC_ic3_Type): uint8 = 
  this.field1.S0

proc `S0 =`*(this: var PIC_ic3_Type): uint8 = 
  this.field1.S0

proc S1*(this: PIC_ic3_Type): uint8 = 
  this.field1.S1

proc `S1 =`*(this: var PIC_ic3_Type): uint8 = 
  this.field1.S1

proc S2*(this: PIC_ic3_Type): uint8 = 
  this.field1.S2

proc `S2 =`*(this: var PIC_ic3_Type): uint8 = 
  this.field1.S2

proc S3*(this: PIC_ic3_Type): uint8 = 
  this.field1.S3

proc `S3 =`*(this: var PIC_ic3_Type): uint8 = 
  this.field1.S3

proc S4*(this: PIC_ic3_Type): uint8 = 
  this.field1.S4

proc `S4 =`*(this: var PIC_ic3_Type): uint8 = 
  this.field1.S4

proc S5*(this: PIC_ic3_Type): uint8 = 
  this.field1.S5

proc `S5 =`*(this: var PIC_ic3_Type): uint8 = 
  this.field1.S5

proc S6*(this: PIC_ic3_Type): uint8 = 
  this.field1.S6

proc `S6 =`*(this: var PIC_ic3_Type): uint8 = 
  this.field1.S6

proc S7*(this: PIC_ic3_Type): uint8 = 
  this.field1.S7

proc `S7 =`*(this: var PIC_ic3_Type): uint8 = 
  this.field1.S7

type
  field2_Type* {.bycopy.} = object
    ID* {.bitsize: 3.}: uint8
  
proc ID*(this: PIC_ic3_Type): uint8 = 
  this.field2.ID

proc `ID =`*(this: var PIC_ic3_Type): uint8 = 
  this.field2.ID

type
  PIC_ic3_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
    field2*: field2_Type
  
type
  field1_Type* {.bycopy.} = object
    PM* {.bitsize: 1.}: uint8
    AEOI* {.bitsize: 1.}: uint8
    MS* {.bitsize: 1.}: uint8
    BUF* {.bitsize: 1.}: uint8
    SFNM* {.bitsize: 1.}: uint8
  
proc PM*(this: PIC_ic4_Type): uint8 = 
  this.field1.PM

proc `PM =`*(this: var PIC_ic4_Type): uint8 = 
  this.field1.PM

proc AEOI*(this: PIC_ic4_Type): uint8 = 
  this.field1.AEOI

proc `AEOI =`*(this: var PIC_ic4_Type): uint8 = 
  this.field1.AEOI

proc MS*(this: PIC_ic4_Type): uint8 = 
  this.field1.MS

proc `MS =`*(this: var PIC_ic4_Type): uint8 = 
  this.field1.MS

proc BUF*(this: PIC_ic4_Type): uint8 = 
  this.field1.BUF

proc `BUF =`*(this: var PIC_ic4_Type): uint8 = 
  this.field1.BUF

proc SFNM*(this: PIC_ic4_Type): uint8 = 
  this.field1.SFNM

proc `SFNM =`*(this: var PIC_ic4_Type): uint8 = 
  this.field1.SFNM

type
  PIC_ic4_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  