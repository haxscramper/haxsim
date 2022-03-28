import
  commonhpp
import
  dev_drqhpp
import
  dev_iohpp
type
  DMA* {.bycopy.} = object
    drq*: array[4, ptr DRQ]
    adrr*: array[4, uint16]    
    xpadrr*: array[4, uint8]    
    cntr*: array[4, uint16]    
    cmnr*: DMA_cmnr_Type        
    modr*: DMA_modr_Type        
    reqr*: DMA_reqr_Type        
    scmr*: DMA_scmr_Type        
    amr*: DMA_amr_Type        
    statr*: DMA_statr_Type        
  
proc in8*(this: var DMA, memAddr: uint16): uint8 =
  discard 

proc out8*(this: var DMA, memAddr: uint16, v: uint8): void =
  discard 

type
  field1_Type* {.bycopy.} = object
    NMT* {.bitsize: 1.}: uint8
    ADHE* {.bitsize: 1.}: uint8
    COND* {.bitsize: 1.}: uint8
    COMP* {.bitsize: 1.}: uint8
    PRIO* {.bitsize: 1.}: uint8
    EXTW* {.bitsize: 1.}: uint8
    DRQP* {.bitsize: 1.}: uint8
    DACKP* {.bitsize: 1.}: uint8
  
proc NMT*(this: DMA_cmnr_Type): uint8 = 
  this.field1.NMT

proc `NMT =`*(this: var DMA_cmnr_Type): uint8 = 
  this.field1.NMT

proc ADHE*(this: DMA_cmnr_Type): uint8 = 
  this.field1.ADHE

proc `ADHE =`*(this: var DMA_cmnr_Type): uint8 = 
  this.field1.ADHE

proc COND*(this: DMA_cmnr_Type): uint8 = 
  this.field1.COND

proc `COND =`*(this: var DMA_cmnr_Type): uint8 = 
  this.field1.COND

proc COMP*(this: DMA_cmnr_Type): uint8 = 
  this.field1.COMP

proc `COMP =`*(this: var DMA_cmnr_Type): uint8 = 
  this.field1.COMP

proc PRIO*(this: DMA_cmnr_Type): uint8 = 
  this.field1.PRIO

proc `PRIO =`*(this: var DMA_cmnr_Type): uint8 = 
  this.field1.PRIO

proc EXTW*(this: DMA_cmnr_Type): uint8 = 
  this.field1.EXTW

proc `EXTW =`*(this: var DMA_cmnr_Type): uint8 = 
  this.field1.EXTW

proc DRQP*(this: DMA_cmnr_Type): uint8 = 
  this.field1.DRQP

proc `DRQP =`*(this: var DMA_cmnr_Type): uint8 = 
  this.field1.DRQP

proc DACKP*(this: DMA_cmnr_Type): uint8 = 
  this.field1.DACKP

proc `DACKP =`*(this: var DMA_cmnr_Type): uint8 = 
  this.field1.DACKP

type
  DMA_cmnr_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  
type
  field1_Type* {.bycopy.} = object
    SEL* {.bitsize: 2.}: uint8
    TRA* {.bitsize: 2.}: uint8
    AUTO* {.bitsize: 1.}: uint8
    DOWN* {.bitsize: 1.}: uint8
    MOD* {.bitsize: 2.}: uint8
  
proc SEL*(this: DMA_modr_Type): uint8 = 
  this.field1.SEL

proc `SEL =`*(this: var DMA_modr_Type): uint8 = 
  this.field1.SEL

proc TRA*(this: DMA_modr_Type): uint8 = 
  this.field1.TRA

proc `TRA =`*(this: var DMA_modr_Type): uint8 = 
  this.field1.TRA

proc AUTO*(this: DMA_modr_Type): uint8 = 
  this.field1.AUTO

proc `AUTO =`*(this: var DMA_modr_Type): uint8 = 
  this.field1.AUTO

proc DOWN*(this: DMA_modr_Type): uint8 = 
  this.field1.DOWN

proc `DOWN =`*(this: var DMA_modr_Type): uint8 = 
  this.field1.DOWN

proc MOD*(this: DMA_modr_Type): uint8 = 
  this.field1.MOD

proc `MOD =`*(this: var DMA_modr_Type): uint8 = 
  this.field1.MOD

type
  DMA_modr_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  
type
  field1_Type* {.bycopy.} = object
    SEL* {.bitsize: 2.}: uint8
    REQ* {.bitsize: 1.}: uint8
  
proc SEL*(this: DMA_reqr_Type): uint8 = 
  this.field1.SEL

proc `SEL =`*(this: var DMA_reqr_Type): uint8 = 
  this.field1.SEL

proc REQ*(this: DMA_reqr_Type): uint8 = 
  this.field1.REQ

proc `REQ =`*(this: var DMA_reqr_Type): uint8 = 
  this.field1.REQ

type
  DMA_reqr_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  
type
  field1_Type* {.bycopy.} = object
    SEL* {.bitsize: 2.}: uint8
    MASK* {.bitsize: 1.}: uint8
  
proc SEL*(this: DMA_scmr_Type): uint8 = 
  this.field1.SEL

proc `SEL =`*(this: var DMA_scmr_Type): uint8 = 
  this.field1.SEL

proc MASK*(this: DMA_scmr_Type): uint8 = 
  this.field1.MASK

proc `MASK =`*(this: var DMA_scmr_Type): uint8 = 
  this.field1.MASK

type
  DMA_scmr_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  
type
  field1_Type* {.bycopy.} = object
    CH0* {.bitsize: 1.}: uint8
    CH1* {.bitsize: 1.}: uint8
    CH2* {.bitsize: 1.}: uint8
    CH3* {.bitsize: 1.}: uint8
  
proc CH0*(this: DMA_amr_Type): uint8 = 
  this.field1.CH0

proc `CH0 =`*(this: var DMA_amr_Type): uint8 = 
  this.field1.CH0

proc CH1*(this: DMA_amr_Type): uint8 = 
  this.field1.CH1

proc `CH1 =`*(this: var DMA_amr_Type): uint8 = 
  this.field1.CH1

proc CH2*(this: DMA_amr_Type): uint8 = 
  this.field1.CH2

proc `CH2 =`*(this: var DMA_amr_Type): uint8 = 
  this.field1.CH2

proc CH3*(this: DMA_amr_Type): uint8 = 
  this.field1.CH3

proc `CH3 =`*(this: var DMA_amr_Type): uint8 = 
  this.field1.CH3

type
  DMA_amr_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  
type
  field1_Type* {.bycopy.} = object
    TC0* {.bitsize: 1.}: uint8
    TC1* {.bitsize: 1.}: uint8
    TC2* {.bitsize: 1.}: uint8
    TC3* {.bitsize: 1.}: uint8
    CH0* {.bitsize: 1.}: uint8
    CH1* {.bitsize: 1.}: uint8
    CH2* {.bitsize: 1.}: uint8
    CH3* {.bitsize: 1.}: uint8
  
proc TC0*(this: DMA_statr_Type): uint8 = 
  this.field1.TC0

proc `TC0 =`*(this: var DMA_statr_Type): uint8 = 
  this.field1.TC0

proc TC1*(this: DMA_statr_Type): uint8 = 
  this.field1.TC1

proc `TC1 =`*(this: var DMA_statr_Type): uint8 = 
  this.field1.TC1

proc TC2*(this: DMA_statr_Type): uint8 = 
  this.field1.TC2

proc `TC2 =`*(this: var DMA_statr_Type): uint8 = 
  this.field1.TC2

proc TC3*(this: DMA_statr_Type): uint8 = 
  this.field1.TC3

proc `TC3 =`*(this: var DMA_statr_Type): uint8 = 
  this.field1.TC3

proc CH0*(this: DMA_statr_Type): uint8 = 
  this.field1.CH0

proc `CH0 =`*(this: var DMA_statr_Type): uint8 = 
  this.field1.CH0

proc CH1*(this: DMA_statr_Type): uint8 = 
  this.field1.CH1

proc `CH1 =`*(this: var DMA_statr_Type): uint8 = 
  this.field1.CH1

proc CH2*(this: DMA_statr_Type): uint8 = 
  this.field1.CH2

proc `CH2 =`*(this: var DMA_statr_Type): uint8 = 
  this.field1.CH2

proc CH3*(this: DMA_statr_Type): uint8 = 
  this.field1.CH3

proc `CH3 =`*(this: var DMA_statr_Type): uint8 = 
  this.field1.CH3

type
  DMA_statr_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
