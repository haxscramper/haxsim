# import thread
import std/tables
import std/deques
import std/locks
import commonhpp
import dev_iohpp
import dev_irqhpp

const
  MAX_FDD*                = 4
  SIZE_SECTOR*            = 0x200
  N_SpH*                  = 18
  N_HpC*                  = 2
  FDD_READ_TRACK*         = 0x02
  FDD_SENSE_DRIVE_STATUS* = 0x04
  FDD_WRITE_DATA*         = 0x05
  FDD_READ_DATA*          = 0x06
  FDD_RECALIBRATE*        = 0x07
  FDD_READ_ID*            = 0x0a
  FDD_FORMAT_TRACK*       = 0x0d
  FDD_SEEK*               = 0x0f
  FDD_CONFIGURE*          = 0x13

type
  DRIVE* {.bycopy.} = object
    disk*:               ptr FILE
    cylinder* {.bitsize: 7.}: uint8
    head* {.bitsize:     1.}: uint8
    sector* {.bitsize:   5.}: uint8
    write*:              bool
    progress*:           uint16

  QUEUE* {.bycopy.} = object
    queue*: Deque[uint8]
    mtx*: Lock
    max*: uint16

  FDD* {.bycopy.} = object
    fddfuncs*: Table[uint8, fddfunc_t]
    drive*: array[MAX_FDD, ref DRIVE]
    conf*: FDD_conf
    sra*: FDD_sra
    srb*: FDD_srb
    dor*: FDD_dor
    tdr*: FDD_tdr
    msr*: FDD_msr
    dsr*: FDD_dsr
    data*: uint8
    data_q*: QUEUE
    ccr*: FDD_ccr
    dir*: FDD_dir
    st0*: FDD_st0
    st1*: FDD_st1
    st2*: FDD_st2
    str3*: FDD_str3
    # th*: std_thread

  FDD_str3* {.bycopy, union.} = object
    raw*: uint8
    field1*: FDD_str3_field1

  fddfunc_t* = proc(arg0: void): void {.cdecl.}

  FDD_conf_field1* {.bycopy.} = object
    FIFOTHR* {.bitsize: 4.}: uint8
    POLL* {.bitsize: 1.}: uint8
    EFIFO* {.bitsize: 1.}: uint8
    EIS* {.bitsize: 1.}: uint8

  FDD_st2* {.bycopy, union.} = object
    raw*: uint8
    field1*: FDD_st2_field1

  FDD_st1* {.bycopy, union.} = object
    raw*: uint8
    field1*: FDD_st1_field1

  FDD_st2_field1* {.bycopy.} = object
    MD* {.bitsize: 1.}: uint8
    BC* {.bitsize: 1.}: uint8
    SN* {.bitsize: 1.}: uint8
    SH* {.bitsize: 1.}: uint8
    WC* {.bitsize: 1.}: uint8
    DD* {.bitsize: 1.}: uint8
    CM* {.bitsize: 1.}: uint8

  FDD_st0* {.bycopy, union.} = object
    raw*: uint8
    field1*: FDD_st0_field1

  FDD_st1_field1* {.bycopy.} = object
    MA* {.bitsize: 1.}: uint8
    NW* {.bitsize: 1.}: uint8
    ND* {.bitsize: 1.}: uint8
    field3* {.bitsize: 1.}: uint8
    OR* {.bitsize: 1.}: uint8
    DE* {.bitsize: 1.}: uint8
    field6* {.bitsize: 1.}: uint8
    EN* {.bitsize: 1.}: uint8

  FDD_msr* {.bycopy, union.} = object
    raw*: uint8
    field1*: FDD_msr_field1

  FDD_dsr* {.bycopy, union.} = object
    raw*: uint8

  FDD_ccr* {.bycopy, union.} = object
    raw*: uint8

  FDD_dir* {.bycopy, union.} = object
    raw*: uint8

  FDD_st0_field1* {.bycopy.} = object
    DS0* {.bitsize: 1.}: uint8
    DS1* {.bitsize: 1.}: uint8
    H* {.bitsize: 1.}: uint8
    field3* {.bitsize: 1.}: uint8
    EC* {.bitsize: 1.}: uint8
    SE* {.bitsize: 1.}: uint8
    IC0* {.bitsize: 1.}: uint8
    IC1* {.bitsize: 1.}: uint8

  FDD_dor* {.bycopy, union.} = object
    raw*: uint8
    field1*: FDD_dor_field1

  FDD_tdr* {.bycopy, union.} = object
    raw*: uint8

  FDD_srb* {.bycopy, union.} = object
    raw*: uint8
    field1*: FDD_srb_field1

  FDD_conf* {.bycopy, union.} = object
    raw*: uint8
    field1*: FDD_conf_field1

  FDD_sra_field1* {.bycopy.} = object
    DIR* {.bitsize: 1.}: uint8
    nWP* {.bitsize: 1.}: uint8
    nINDX* {.bitsize: 1.}: uint8
    HDSEL* {.bitsize: 1.}: uint8
    nTRK0* {.bitsize: 1.}: uint8
    STEP* {.bitsize: 1.}: uint8
    nDRV2* {.bitsize: 1.}: uint8
    INT* {.bitsize: 1.}: uint8

  FDD_sra* {.bycopy, union.} = object
    raw*: uint8
    field1*: FDD_sra_field1

  FDD_srb_field1* {.bycopy.} = object
    MOT0* {.bitsize: 1.}: uint8
    MOT1* {.bitsize: 1.}: uint8
    WE* {.bitsize: 1.}: uint8
    RD* {.bitsize: 1.}: uint8
    WR* {.bitsize: 1.}: uint8
    SEL0* {.bitsize: 1.}: uint8

  FDD_dor_field1* {.bycopy.} = object
    SEL0* {.bitsize: 1.}: uint8
    SEL1* {.bitsize: 1.}: uint8
    nRESET* {.bitsize: 1.}: uint8
    nDMA* {.bitsize: 1.}: uint8
    MOT* {.bitsize: 4.}: uint8

  FDD_msr_field1* {.bycopy.} = object
    DRV_BSY* {.bitsize: 4.}: uint8
    CMD_BSY* {.bitsize: 1.}: uint8
    NON_DMA* {.bitsize: 1.}: uint8
    DIO* {.bitsize: 1.}: uint8
    RQM* {.bitsize: 1.}: uint8

  FDD_str3_field1* {.bycopy.} = object
    DS0* {.bitsize: 1.}: uint8
    DS1* {.bitsize: 1.}: uint8
    HD* {.bitsize: 1.}: uint8
    field3* {.bitsize: 1.}: uint8
    T0* {.bitsize: 1.}: uint8
    field5* {.bitsize: 1.}: uint8
    WP* {.bitsize: 1.}: uint8

proc FIFOTHR*(this: FDD_conf): uint8 = this.field1.FIFOTHR
proc `FIFOTHR=`*(this: var FDD_conf, value: uint8) = this.field1.FIFOTHR = value
proc POLL*(this: FDD_conf): uint8 = this.field1.POLL
proc `POLL=`*(this: var FDD_conf, value: uint8) = this.field1.POLL = value
proc EFIFO*(this: FDD_conf): uint8 = this.field1.EFIFO
proc `EFIFO=`*(this: var FDD_conf, value: uint8) = this.field1.EFIFO = value
proc EIS*(this: FDD_conf): uint8 = this.field1.EIS
proc `EIS=`*(this: var FDD_conf, value: uint8) = this.field1.EIS = value
proc DIR*(this: FDD_sra): uint8 = this.field1.DIR
proc `DIR=`*(this: var FDD_sra, value: uint8) = this.field1.DIR = value
proc nWP*(this: FDD_sra): uint8 = this.field1.nWP
proc `nWP=`*(this: var FDD_sra, value: uint8) = this.field1.nWP = value
proc nINDX*(this: FDD_sra): uint8 = this.field1.nINDX
proc `nINDX=`*(this: var FDD_sra, value: uint8) = this.field1.nINDX = value
proc HDSEL*(this: FDD_sra): uint8 = this.field1.HDSEL
proc `HDSEL=`*(this: var FDD_sra, value: uint8) = this.field1.HDSEL = value
proc nTRK0*(this: FDD_sra): uint8 = this.field1.nTRK0
proc `nTRK0=`*(this: var FDD_sra, value: uint8) = this.field1.nTRK0 = value
proc STEP*(this: FDD_sra): uint8 = this.field1.STEP
proc `STEP=`*(this: var FDD_sra, value: uint8) = this.field1.STEP = value
proc nDRV2*(this: FDD_sra): uint8 = this.field1.nDRV2
proc `nDRV2=`*(this: var FDD_sra, value: uint8) = this.field1.nDRV2 = value
proc INT*(this: FDD_sra): uint8 = this.field1.INT
proc `INT=`*(this: var FDD_sra, value: uint8) = this.field1.INT = value
proc MOT0*(this: FDD_srb): uint8 = this.field1.MOT0
proc `MOT0=`*(this: var FDD_srb, value: uint8) = this.field1.MOT0 = value
proc MOT1*(this: FDD_srb): uint8 = this.field1.MOT1
proc `MOT1=`*(this: var FDD_srb, value: uint8) = this.field1.MOT1 = value
proc WE*(this: FDD_srb): uint8 = this.field1.WE
proc `WE=`*(this: var FDD_srb, value: uint8) = this.field1.WE = value
proc RD*(this: FDD_srb): uint8 = this.field1.RD
proc `RD=`*(this: var FDD_srb, value: uint8) = this.field1.RD = value
proc WR*(this: FDD_srb): uint8 = this.field1.WR
proc `WR=`*(this: var FDD_srb, value: uint8) = this.field1.WR = value
proc SEL0*(this: FDD_srb): uint8 = this.field1.SEL0
proc `SEL0=`*(this: var FDD_srb, value: uint8) = this.field1.SEL0 = value
proc SEL0*(this: FDD_dor): uint8 = this.field1.SEL0
proc `SEL0=`*(this: var FDD_dor, value: uint8) = this.field1.SEL0 = value
proc SEL1*(this: FDD_dor): uint8 = this.field1.SEL1
proc `SEL1=`*(this: var FDD_dor, value: uint8) = this.field1.SEL1 = value
proc nRESET*(this: FDD_dor): uint8 = this.field1.nRESET
proc `nRESET=`*(this: var FDD_dor, value: uint8) = this.field1.nRESET = value
proc nDMA*(this: FDD_dor): uint8 = this.field1.nDMA
proc `nDMA=`*(this: var FDD_dor, value: uint8) = this.field1.nDMA = value
proc MOT*(this: FDD_dor): uint8 = this.field1.MOT
proc `MOT=`*(this: var FDD_dor, value: uint8) = this.field1.MOT = value
proc DRV_BSY*(this: FDD_msr): uint8 = this.field1.DRV_BSY
proc `DRV_BSY=`*(this: var FDD_msr, value: uint8) = this.field1.DRV_BSY = value
proc CMD_BSY*(this: FDD_msr): uint8 = this.field1.CMD_BSY
proc `CMD_BSY=`*(this: var FDD_msr, value: uint8) = this.field1.CMD_BSY = value
proc NON_DMA*(this: FDD_msr): uint8 = this.field1.NON_DMA
proc `NON_DMA=`*(this: var FDD_msr, value: uint8) = this.field1.NON_DMA = value
proc DIO*(this: FDD_msr): uint8 = this.field1.DIO
proc `DIO=`*(this: var FDD_msr, value: uint8) = this.field1.DIO = value
proc RQM*(this: FDD_msr): uint8 = this.field1.RQM
proc `RQM=`*(this: var FDD_msr, value: uint8) = this.field1.RQM = value
proc DS0*(this: FDD_st0): uint8 = this.field1.DS0
proc `DS0=`*(this: var FDD_st0, value: uint8) = this.field1.DS0 = value
proc DS1*(this: FDD_st0): uint8 = this.field1.DS1
proc `DS1=`*(this: var FDD_st0, value: uint8) = this.field1.DS1 = value
proc H*(this: FDD_st0): uint8 = this.field1.H
proc `H=`*(this: var FDD_st0, value: uint8) = this.field1.H = value
proc EC*(this: FDD_st0): uint8 = this.field1.EC
proc `EC=`*(this: var FDD_st0, value: uint8) = this.field1.EC = value
proc SE*(this: FDD_st0): uint8 = this.field1.SE
proc `SE=`*(this: var FDD_st0, value: uint8) = this.field1.SE = value
proc IC0*(this: FDD_st0): uint8 = this.field1.IC0
proc `IC0=`*(this: var FDD_st0, value: uint8) = this.field1.IC0 = value
proc IC1*(this: FDD_st0): uint8 = this.field1.IC1
proc `IC1=`*(this: var FDD_st0, value: uint8) = this.field1.IC1 = value
proc MA*(this: FDD_st1): uint8 = this.field1.MA
proc `MA=`*(this: var FDD_st1, value: uint8) = this.field1.MA = value
proc NW*(this: FDD_st1): uint8 = this.field1.NW
proc `NW=`*(this: var FDD_st1, value: uint8) = this.field1.NW = value
proc ND*(this: FDD_st1): uint8 = this.field1.ND
proc `ND=`*(this: var FDD_st1, value: uint8) = this.field1.ND = value
proc OR*(this: FDD_st1): uint8 = this.field1.OR
proc `OR=`*(this: var FDD_st1, value: uint8) = this.field1.OR = value
proc DE*(this: FDD_st1): uint8 = this.field1.DE
proc `DE=`*(this: var FDD_st1, value: uint8) = this.field1.DE = value
proc EN*(this: FDD_st1): uint8 = this.field1.EN
proc `EN=`*(this: var FDD_st1, value: uint8) = this.field1.EN = value
proc MD*(this: FDD_st2): uint8 = this.field1.MD
proc `MD=`*(this: var FDD_st2, value: uint8) = this.field1.MD = value
proc BC*(this: FDD_st2): uint8 = this.field1.BC
proc `BC=`*(this: var FDD_st2, value: uint8) = this.field1.BC = value
proc SN*(this: FDD_st2): uint8 = this.field1.SN
proc `SN=`*(this: var FDD_st2, value: uint8) = this.field1.SN = value
proc SH*(this: FDD_st2): uint8 = this.field1.SH
proc `SH=`*(this: var FDD_st2, value: uint8) = this.field1.SH = value
proc WC*(this: FDD_st2): uint8 = this.field1.WC
proc `WC=`*(this: var FDD_st2, value: uint8) = this.field1.WC = value
proc DD*(this: FDD_st2): uint8 = this.field1.DD
proc `DD=`*(this: var FDD_st2, value: uint8) = this.field1.DD = value
proc CM*(this: FDD_st2): uint8 = this.field1.CM
proc `CM=`*(this: var FDD_st2, value: uint8) = this.field1.CM = value
proc DS0*(this: FDD_str3): uint8 = this.field1.DS0
proc `DS0=`*(this: var FDD_str3, value: uint8) = this.field1.DS0 = value
proc DS1*(this: FDD_str3): uint8 = this.field1.DS1
proc `DS1=`*(this: var FDD_str3, value: uint8) = this.field1.DS1 = value
proc HD*(this: FDD_str3): uint8 = this.field1.HD
proc `HD=`*(this: var FDD_str3, value: uint8) = this.field1.HD = value
proc T0*(this: FDD_str3): uint8 = this.field1.T0
proc `T0=`*(this: var FDD_str3, value: uint8) = this.field1.T0 = value
proc WP*(this: FDD_str3): uint8 = this.field1.WP
proc `WP=`*(this: var FDD_str3, value: uint8) = this.field1.WP = value
