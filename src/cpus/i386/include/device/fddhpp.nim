import
  thread
import
  unordered_map
import
  queue
import
  mutex
import
  commonhpp
import
  dev_iohpp
import
  dev_irqhpp
const MAX_FDD* = 4
const SIZE_SECTOR* = 0x200
const N_SpH* = 18
const N_HpC* = 2
const FDD_READ_TRACK* = 0x02
const FDD_SENSE_DRIVE_STATUS* = 0x04
const FDD_WRITE_DATA* = 0x05
const FDD_READ_DATA* = 0x06
const FDD_RECALIBRATE* = 0x07
const FDD_READ_ID* = 0x0a
const FDD_FORMAT_TRACK* = 0x0d
const FDD_SEEK* = 0x0f
const FDD_CONFIGURE* = 0x13
type
  DRIVE* {.bycopy, importcpp.} = object
    disk*:        ptr FILE
    cylinder* {.bitsize: 7.}: uint8    
    head* {.bitsize: 1.}: uint8    
    sector* {.bitsize: 5.}: uint8    
    write*:        bool    
    progress*:        uint16    
  
type
  QUEUE* {.bycopy, importcpp.} = object
    queue*: std_queue[uint8]
    mtx*: std_mutex  
    max*: uint16  
  
type
  FDD* {.bycopy, importcpp.} = object
    fddfuncs*: std_unordered_map[uint8, fddfunc_t]    
    drive*: array[, ptr DRIVE]
    conf*: FDD_conf_Type        
    sra*: FDD_sra_Type        
    srb*: FDD_srb_Type        
    dor*: FDD_dor_Type        
    tdr*: FDD_tdr_Type        
    msr*: FDD_msr_Type        
    dsr*: FDD_dsr_Type        
    data*: uint8        
    data_q*: QUEUE        
    ccr*: FDD_ccr_Type        
    dir*: FDD_dir_Type        
    st0*: FDD_st0_Type        
    st1*: FDD_st1_Type        
    st2*: FDD_st2_Type        
    str3*: FDD_str3_Type        
    th*: std_thread        
  
type
  fddfunc_t* = 
    proc(arg0: void): void {.cdecl.}
  
type
  field1_Type* {.bycopy.} = object
    FIFOTHR* {.bitsize: 4.}: uint8
    POLL* {.bitsize: 1.}: uint8
    EFIFO* {.bitsize: 1.}: uint8
    EIS* {.bitsize: 1.}: uint8
  
proc FIFOTHR*(this: FDD_conf_Type): uint8 = 
  this.field1.FIFOTHR

proc `FIFOTHR =`*(this: var FDD_conf_Type): uint8 = 
  this.field1.FIFOTHR

proc POLL*(this: FDD_conf_Type): uint8 = 
  this.field1.POLL

proc `POLL =`*(this: var FDD_conf_Type): uint8 = 
  this.field1.POLL

proc EFIFO*(this: FDD_conf_Type): uint8 = 
  this.field1.EFIFO

proc `EFIFO =`*(this: var FDD_conf_Type): uint8 = 
  this.field1.EFIFO

proc EIS*(this: FDD_conf_Type): uint8 = 
  this.field1.EIS

proc `EIS =`*(this: var FDD_conf_Type): uint8 = 
  this.field1.EIS

type
  FDD_conf_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  
type
  field1_Type* {.bycopy.} = object
    DIR* {.bitsize: 1.}: uint8
    nWP* {.bitsize: 1.}: uint8
    nINDX* {.bitsize: 1.}: uint8
    HDSEL* {.bitsize: 1.}: uint8
    nTRK0* {.bitsize: 1.}: uint8
    STEP* {.bitsize: 1.}: uint8
    nDRV2* {.bitsize: 1.}: uint8
    INT* {.bitsize: 1.}: uint8
  
proc DIR*(this: FDD_sra_Type): uint8 = 
  this.field1.DIR

proc `DIR =`*(this: var FDD_sra_Type): uint8 = 
  this.field1.DIR

proc nWP*(this: FDD_sra_Type): uint8 = 
  this.field1.nWP

proc `nWP =`*(this: var FDD_sra_Type): uint8 = 
  this.field1.nWP

proc nINDX*(this: FDD_sra_Type): uint8 = 
  this.field1.nINDX

proc `nINDX =`*(this: var FDD_sra_Type): uint8 = 
  this.field1.nINDX

proc HDSEL*(this: FDD_sra_Type): uint8 = 
  this.field1.HDSEL

proc `HDSEL =`*(this: var FDD_sra_Type): uint8 = 
  this.field1.HDSEL

proc nTRK0*(this: FDD_sra_Type): uint8 = 
  this.field1.nTRK0

proc `nTRK0 =`*(this: var FDD_sra_Type): uint8 = 
  this.field1.nTRK0

proc STEP*(this: FDD_sra_Type): uint8 = 
  this.field1.STEP

proc `STEP =`*(this: var FDD_sra_Type): uint8 = 
  this.field1.STEP

proc nDRV2*(this: FDD_sra_Type): uint8 = 
  this.field1.nDRV2

proc `nDRV2 =`*(this: var FDD_sra_Type): uint8 = 
  this.field1.nDRV2

proc INT*(this: FDD_sra_Type): uint8 = 
  this.field1.INT

proc `INT =`*(this: var FDD_sra_Type): uint8 = 
  this.field1.INT

type
  FDD_sra_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  
type
  field1_Type* {.bycopy.} = object
    MOT0* {.bitsize: 1.}: uint8
    MOT1* {.bitsize: 1.}: uint8
    WE* {.bitsize: 1.}: uint8
    RD* {.bitsize: 1.}: uint8
    WR* {.bitsize: 1.}: uint8
    SEL0* {.bitsize: 1.}: uint8
  
proc MOT0*(this: FDD_srb_Type): uint8 = 
  this.field1.MOT0

proc `MOT0 =`*(this: var FDD_srb_Type): uint8 = 
  this.field1.MOT0

proc MOT1*(this: FDD_srb_Type): uint8 = 
  this.field1.MOT1

proc `MOT1 =`*(this: var FDD_srb_Type): uint8 = 
  this.field1.MOT1

proc WE*(this: FDD_srb_Type): uint8 = 
  this.field1.WE

proc `WE =`*(this: var FDD_srb_Type): uint8 = 
  this.field1.WE

proc RD*(this: FDD_srb_Type): uint8 = 
  this.field1.RD

proc `RD =`*(this: var FDD_srb_Type): uint8 = 
  this.field1.RD

proc WR*(this: FDD_srb_Type): uint8 = 
  this.field1.WR

proc `WR =`*(this: var FDD_srb_Type): uint8 = 
  this.field1.WR

proc SEL0*(this: FDD_srb_Type): uint8 = 
  this.field1.SEL0

proc `SEL0 =`*(this: var FDD_srb_Type): uint8 = 
  this.field1.SEL0

type
  FDD_srb_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  
type
  field1_Type* {.bycopy.} = object
    SEL0* {.bitsize: 1.}: uint8
    SEL1* {.bitsize: 1.}: uint8
    nRESET* {.bitsize: 1.}: uint8
    nDMA* {.bitsize: 1.}: uint8
    MOT* {.bitsize: 4.}: uint8
  
proc SEL0*(this: FDD_dor_Type): uint8 = 
  this.field1.SEL0

proc `SEL0 =`*(this: var FDD_dor_Type): uint8 = 
  this.field1.SEL0

proc SEL1*(this: FDD_dor_Type): uint8 = 
  this.field1.SEL1

proc `SEL1 =`*(this: var FDD_dor_Type): uint8 = 
  this.field1.SEL1

proc nRESET*(this: FDD_dor_Type): uint8 = 
  this.field1.nRESET

proc `nRESET =`*(this: var FDD_dor_Type): uint8 = 
  this.field1.nRESET

proc nDMA*(this: FDD_dor_Type): uint8 = 
  this.field1.nDMA

proc `nDMA =`*(this: var FDD_dor_Type): uint8 = 
  this.field1.nDMA

proc MOT*(this: FDD_dor_Type): uint8 = 
  this.field1.MOT

proc `MOT =`*(this: var FDD_dor_Type): uint8 = 
  this.field1.MOT

type
  FDD_dor_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  
type
  FDD_tdr_Type* {.bycopy, union.} = object
    raw*: uint8
  
type
  field1_Type* {.bycopy.} = object
    DRV_BSY* {.bitsize: 4.}: uint8
    CMD_BSY* {.bitsize: 1.}: uint8
    NON_DMA* {.bitsize: 1.}: uint8
    DIO* {.bitsize: 1.}: uint8
    RQM* {.bitsize: 1.}: uint8
  
proc DRV_BSY*(this: FDD_msr_Type): uint8 = 
  this.field1.DRV_BSY

proc `DRV_BSY =`*(this: var FDD_msr_Type): uint8 = 
  this.field1.DRV_BSY

proc CMD_BSY*(this: FDD_msr_Type): uint8 = 
  this.field1.CMD_BSY

proc `CMD_BSY =`*(this: var FDD_msr_Type): uint8 = 
  this.field1.CMD_BSY

proc NON_DMA*(this: FDD_msr_Type): uint8 = 
  this.field1.NON_DMA

proc `NON_DMA =`*(this: var FDD_msr_Type): uint8 = 
  this.field1.NON_DMA

proc DIO*(this: FDD_msr_Type): uint8 = 
  this.field1.DIO

proc `DIO =`*(this: var FDD_msr_Type): uint8 = 
  this.field1.DIO

proc RQM*(this: FDD_msr_Type): uint8 = 
  this.field1.RQM

proc `RQM =`*(this: var FDD_msr_Type): uint8 = 
  this.field1.RQM

type
  FDD_msr_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  
type
  FDD_dsr_Type* {.bycopy, union.} = object
    raw*: uint8
  
type
  FDD_ccr_Type* {.bycopy, union.} = object
    raw*: uint8
  
type
  FDD_dir_Type* {.bycopy, union.} = object
    raw*: uint8
  
type
  field1_Type* {.bycopy.} = object
    DS0* {.bitsize: 1.}: uint8
    DS1* {.bitsize: 1.}: uint8
    H* {.bitsize: 1.}: uint8
    * {.bitsize: 1.}: uint8
    EC* {.bitsize: 1.}: uint8
    SE* {.bitsize: 1.}: uint8
    IC0* {.bitsize: 1.}: uint8
    IC1* {.bitsize: 1.}: uint8
  
proc DS0*(this: FDD_st0_Type): uint8 = 
  this.field1.DS0

proc `DS0 =`*(this: var FDD_st0_Type): uint8 = 
  this.field1.DS0

proc DS1*(this: FDD_st0_Type): uint8 = 
  this.field1.DS1

proc `DS1 =`*(this: var FDD_st0_Type): uint8 = 
  this.field1.DS1

proc H*(this: FDD_st0_Type): uint8 = 
  this.field1.H

proc `H =`*(this: var FDD_st0_Type): uint8 = 
  this.field1.H

proc *(this: FDD_st0_Type): uint8 = 
  this.field1.

proc ` =`*(this: var FDD_st0_Type): uint8 = 
  this.field1.

proc EC*(this: FDD_st0_Type): uint8 = 
  this.field1.EC

proc `EC =`*(this: var FDD_st0_Type): uint8 = 
  this.field1.EC

proc SE*(this: FDD_st0_Type): uint8 = 
  this.field1.SE

proc `SE =`*(this: var FDD_st0_Type): uint8 = 
  this.field1.SE

proc IC0*(this: FDD_st0_Type): uint8 = 
  this.field1.IC0

proc `IC0 =`*(this: var FDD_st0_Type): uint8 = 
  this.field1.IC0

proc IC1*(this: FDD_st0_Type): uint8 = 
  this.field1.IC1

proc `IC1 =`*(this: var FDD_st0_Type): uint8 = 
  this.field1.IC1

type
  FDD_st0_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  
type
  field1_Type* {.bycopy.} = object
    MA* {.bitsize: 1.}: uint8
    NW* {.bitsize: 1.}: uint8
    ND* {.bitsize: 1.}: uint8
    * {.bitsize: 1.}: uint8
    OR* {.bitsize: 1.}: uint8
    DE* {.bitsize: 1.}: uint8
    * {.bitsize: 1.}: uint8
    EN* {.bitsize: 1.}: uint8
  
proc MA*(this: FDD_st1_Type): uint8 = 
  this.field1.MA

proc `MA =`*(this: var FDD_st1_Type): uint8 = 
  this.field1.MA

proc NW*(this: FDD_st1_Type): uint8 = 
  this.field1.NW

proc `NW =`*(this: var FDD_st1_Type): uint8 = 
  this.field1.NW

proc ND*(this: FDD_st1_Type): uint8 = 
  this.field1.ND

proc `ND =`*(this: var FDD_st1_Type): uint8 = 
  this.field1.ND

proc *(this: FDD_st1_Type): uint8 = 
  this.field1.

proc ` =`*(this: var FDD_st1_Type): uint8 = 
  this.field1.

proc OR*(this: FDD_st1_Type): uint8 = 
  this.field1.OR

proc `OR =`*(this: var FDD_st1_Type): uint8 = 
  this.field1.OR

proc DE*(this: FDD_st1_Type): uint8 = 
  this.field1.DE

proc `DE =`*(this: var FDD_st1_Type): uint8 = 
  this.field1.DE

proc *(this: FDD_st1_Type): uint8 = 
  this.field1.

proc ` =`*(this: var FDD_st1_Type): uint8 = 
  this.field1.

proc EN*(this: FDD_st1_Type): uint8 = 
  this.field1.EN

proc `EN =`*(this: var FDD_st1_Type): uint8 = 
  this.field1.EN

type
  FDD_st1_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  
type
  field1_Type* {.bycopy.} = object
    MD* {.bitsize: 1.}: uint8
    BC* {.bitsize: 1.}: uint8
    SN* {.bitsize: 1.}: uint8
    SH* {.bitsize: 1.}: uint8
    WC* {.bitsize: 1.}: uint8
    DD* {.bitsize: 1.}: uint8
    CM* {.bitsize: 1.}: uint8
  
proc MD*(this: FDD_st2_Type): uint8 = 
  this.field1.MD

proc `MD =`*(this: var FDD_st2_Type): uint8 = 
  this.field1.MD

proc BC*(this: FDD_st2_Type): uint8 = 
  this.field1.BC

proc `BC =`*(this: var FDD_st2_Type): uint8 = 
  this.field1.BC

proc SN*(this: FDD_st2_Type): uint8 = 
  this.field1.SN

proc `SN =`*(this: var FDD_st2_Type): uint8 = 
  this.field1.SN

proc SH*(this: FDD_st2_Type): uint8 = 
  this.field1.SH

proc `SH =`*(this: var FDD_st2_Type): uint8 = 
  this.field1.SH

proc WC*(this: FDD_st2_Type): uint8 = 
  this.field1.WC

proc `WC =`*(this: var FDD_st2_Type): uint8 = 
  this.field1.WC

proc DD*(this: FDD_st2_Type): uint8 = 
  this.field1.DD

proc `DD =`*(this: var FDD_st2_Type): uint8 = 
  this.field1.DD

proc CM*(this: FDD_st2_Type): uint8 = 
  this.field1.CM

proc `CM =`*(this: var FDD_st2_Type): uint8 = 
  this.field1.CM

type
  FDD_st2_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  
type
  field1_Type* {.bycopy.} = object
    DS0* {.bitsize: 1.}: uint8
    DS1* {.bitsize: 1.}: uint8
    HD* {.bitsize: 1.}: uint8
    * {.bitsize: 1.}: uint8
    T0* {.bitsize: 1.}: uint8
    * {.bitsize: 1.}: uint8
    WP* {.bitsize: 1.}: uint8
  
proc DS0*(this: FDD_str3_Type): uint8 = 
  this.field1.DS0

proc `DS0 =`*(this: var FDD_str3_Type): uint8 = 
  this.field1.DS0

proc DS1*(this: FDD_str3_Type): uint8 = 
  this.field1.DS1

proc `DS1 =`*(this: var FDD_str3_Type): uint8 = 
  this.field1.DS1

proc HD*(this: FDD_str3_Type): uint8 = 
  this.field1.HD

proc `HD =`*(this: var FDD_str3_Type): uint8 = 
  this.field1.HD

proc *(this: FDD_str3_Type): uint8 = 
  this.field1.

proc ` =`*(this: var FDD_str3_Type): uint8 = 
  this.field1.

proc T0*(this: FDD_str3_Type): uint8 = 
  this.field1.T0

proc `T0 =`*(this: var FDD_str3_Type): uint8 = 
  this.field1.T0

proc *(this: FDD_str3_Type): uint8 = 
  this.field1.

proc ` =`*(this: var FDD_str3_Type): uint8 = 
  this.field1.

proc WP*(this: FDD_str3_Type): uint8 = 
  this.field1.WP

proc `WP =`*(this: var FDD_str3_Type): uint8 = 
  this.field1.WP

type
  FDD_str3_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  