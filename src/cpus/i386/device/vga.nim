import commonhpp
import dev_iohpp

import std/sequtils

template r*(reg: untyped): untyped {.dirty.} =
  (addr reg.raw)

type
  gmode_t* {.size: sizeof(cint).} = enum
    MODE_TEXT
    MODE_GRAPHIC
    MODE_GRAPHIC256

  VGA* = ref object
    mor*: VGA_mor
    portio*: PortIO
    memio*: ref MemoryIO
    plane*: array[4, seq[uint8]]
    refresh*: bool
    seq*: Sequencer
    crt*: CRT
    gc*: GraphicController
    attr*: Attribute
    dac*: DAC

  Sequencer* = object
    vga*: ptr VGA
    portio*: PortIO
    sar*: Sequencer_sar
    cmr*: Sequencer_cmr
    map_mr*: Sequencer_map_mr
    cmsr*: Sequencer_cmsr
    mem_mr*: Sequencer_mem_mr
    regs*: array[8, ptr uint8]
    get_font*: ptr uint8

  CRT* = object
    vga*: ptr VGA
    portio*: PortIO
    crtcar*: CRT_crtcar
    htr*: CRT_htr
    hdeer*: CRT_hdeer
    shbr*: CRT_shbr
    ehbr*: CRT_ehbr
    mslr*: CRT_mslr
    csr*: CRT_csr
    cer*: CRT_cer
    sahr*: CRT_sahr
    salr*: CRT_salr
    clhr*: CRT_clhr
    cllr*: CRT_cllr
    vdeer*: CRT_vdeer
    ofsr*: CRT_ofsr
    crtmcr*: CRT_crtmcr
    regs*: array[25, ptr uint8]

  GraphicController* = object
    vga*: VGA
    portio*: PortIO
    gcar*: GraphicController_gcar
    sr*: GraphicController_sr
    esr*: GraphicController_esr
    ccr*: GraphicController_ccr
    drr*: GraphicController_drr
    rmsr*: GraphicController_rmsr
    gmr*: GraphicController_gmr
    mr*: GraphicController_mr
    regs*: array[9, ptr uint8]

  Attribute* = object
    vga*: VGA
    acar*: Attribute_acar
    field2*: Attribute_field2
    amcr*: Attribute_amcr
    cper*: Attribute_cper
    portio*: PortIO
    hpelpr*: Attribute_hpelpr
    csr*: Attribute_csr
    regs*: array[21, ptr uint8]

  DAC* = object
    vga*: VGA
    progress*: uint8
    field2*: DAC_field2
    portio*: PortIO
    w_par*: DAC_w_par
    r_par*: DAC_r_par
    pdr*: DAC_pdr
    dacsr*: DAC_dacsr
    pelmr*: DAC_pelmr

  VGA_mor_field1* {.bycopy.} = object
    IO* {.bitsize: 1.}: uint8
    ER* {.bitsize: 1.}: uint8
    CLK0* {.bitsize: 1.}: uint8
    CLK1* {.bitsize: 1.}: uint8
    field4* {.bitsize: 1.}: uint8
    PS* {.bitsize: 1.}: uint8
    HSP* {.bitsize: 1.}: uint8
    VSA* {.bitsize: 1.}: uint8

  VGA_mor* {.bycopy, union.} = object
    raw*: uint8
    field1*: VGA_mor_field1

  Sequencer_sar_field1* {.bycopy.} = object
    INDX* {.bitsize: 3.}: uint8

  Sequencer_sar* {.bycopy, union.} = object
    raw*: uint8
    field1*: Sequencer_sar_field1

  Sequencer_cmr_field1* {.bycopy.} = object
    f89DC* {.bitsize: 1.}: uint8
    field1* {.bitsize: 1.}: uint8
    SL* {.bitsize: 1.}: uint8
    DC* {.bitsize: 1.}: uint8
    S4* {.bitsize: 1.}: uint8
    SO* {.bitsize: 1.}: uint8

  Sequencer_cmr* {.bycopy, union.} = object
    raw*: uint8
    field1*: Sequencer_cmr_field1

  Sequencer_map_mr_field1* {.bycopy.} = object
    MAP0E* {.bitsize: 1.}: uint8
    MAP1E* {.bitsize: 1.}: uint8
    MAP2E* {.bitsize: 1.}: uint8
    MAP3E* {.bitsize: 1.}: uint8

  Sequencer_map_mr* {.bycopy, union.} = object
    raw*: uint8
    field1*: Sequencer_map_mr_field1

  Sequencer_cmsr_field1* {.bycopy.} = object
    CMB* {.bitsize: 2.}: uint8
    CMA* {.bitsize: 2.}: uint8
    CMBM* {.bitsize: 1.}: uint8
    CMAM* {.bitsize: 1.}: uint8

  Sequencer_cmsr* {.bycopy, union.} = object
    raw*: uint8
    field1*: Sequencer_cmsr_field1

  Sequencer_mem_mr_field1* {.bycopy.} = object
    field0* {.bitsize: 1.}: uint8
    EM* {.bitsize: 1.}: uint8
    OE* {.bitsize: 1.}: uint8
    C4* {.bitsize: 1.}: uint8

  Sequencer_mem_mr* {.bycopy, union.} = object
    raw*: uint8
    field1*: Sequencer_mem_mr_field1

  CRT_crtcar_field1* {.bycopy.} = object
    INDX* {.bitsize: 5.}: uint8

  CRT_crtcar* {.bycopy, union.} = object
    raw*: uint8
    field1*: CRT_crtcar_field1

  CRT_htr* {.bycopy, union.} = object
    raw*: uint8
    HT*: uint8

  CRT_hdeer* {.bycopy, union.} = object
    raw*: uint8
    HDEE*: uint8

  CRT_shbr* {.bycopy, union.} = object
    raw*: uint8
    SHB*: uint8

  CRT_ehbr_field1* {.bycopy.} = object
    EB* {.bitsize: 5.}: uint8
    DESC* {.bitsize: 2.}: uint8

  CRT_mslr_field1* {.bycopy.} = object
    MSL* {.bitsize: 5.}: uint8
    SVB9* {.bitsize: 1.}: uint8
    LC9* {.bitsize: 1.}: uint8
    LC* {.bitsize: 1.}: uint8

  CRT_mslr* {.bycopy, union.} = object
    raw*: uint8
    field1*: CRT_mslr_field1

  CRT_csr_field1* {.bycopy.} = object
    RSCB* {.bitsize: 5.}: uint8
    CO* {.bitsize: 1.}: uint8

  CRT_csr* {.bycopy, union.} = object
    raw*: uint8
    field1*: CRT_csr_field1

  CRT_cer_field1* {.bycopy.} = object
    RSCE* {.bitsize: 5.}: uint8
    CSC* {.bitsize: 2.}: uint8

  CRT_cer* {.bycopy, union.} = object
    raw*: uint8
    field1*: CRT_cer_field1

  CRT_sahr* {.bycopy, union.} = object
    raw*: uint8
    HBSA*: uint8

  CRT_salr* {.bycopy, union.} = object
    raw*: uint8
    LBSA*: uint8

  CRT_clhr* {.bycopy, union.} = object
    raw*: uint8
    HBCL*: uint8

  CRT_cllr* {.bycopy, union.} = object
    raw*: uint8
    LBCL*: uint8

  CRT_vdeer* {.bycopy, union.} = object
    raw*: uint8
    VDEE*: uint8

  CRT_ofsr* {.bycopy, union.} = object
    raw*: uint8
    LLWS*: uint8

  CRT_crtmcr_field1* {.bycopy.} = object
    CMS0* {.bitsize: 1.}: uint8
    SRSC* {.bitsize: 1.}: uint8
    HRSX* {.bitsize: 1.}: uint8
    C2* {.bitsize: 1.}: uint8
    field4* {.bitsize: 1.}: uint8
    AW* {.bitsize: 1.}: uint8
    WBM* {.bitsize: 1.}: uint8
    HR* {.bitsize: 1.}: uint8

  GraphicController_gcar* {.bycopy, union.} = object
    raw*: uint8
    field1*: GraphicController_gcar_field1

  GraphicController_sr_field1* {.bycopy.} = object
    SRM0* {.bitsize: 1.}: uint8
    SRM1* {.bitsize: 1.}: uint8
    SRM2* {.bitsize: 1.}: uint8
    SRM3* {.bitsize: 1.}: uint8

  CRT_crtmcr* {.bycopy, union.} = object
    raw*: uint8
    field1*: CRT_crtmcr_field1

  GraphicController_gcar_field1* {.bycopy.} = object
    INDX* {.bitsize: 4.}: uint8

  GraphicController_sr* {.bycopy, union.} = object
    raw*: uint8
    field1*: GraphicController_sr_field1

  GraphicController_esr_field1* {.bycopy.} = object
    ESRM0* {.bitsize: 1.}: uint8
    ESRM1* {.bitsize: 1.}: uint8
    ESRM2* {.bitsize: 1.}: uint8
    ESRM3* {.bitsize: 1.}: uint8

  GraphicController_esr* {.bycopy, union.} = object
    raw*: uint8
    field1*: GraphicController_esr_field1

  GraphicController_ccr_field1* {.bycopy.} = object
    CCM0* {.bitsize: 1.}: uint8
    CCM1* {.bitsize: 1.}: uint8
    CCM2* {.bitsize: 1.}: uint8
    CCM3* {.bitsize: 1.}: uint8

  GraphicController_ccr* {.bycopy, union.} = object
    raw*: uint8
    field1*: GraphicController_ccr_field1

  GraphicController_drr_field1* {.bycopy.} = object
    RC* {.bitsize: 3.}: uint8
    FS* {.bitsize: 2.}: uint8

  GraphicController_drr* {.bycopy, union.} = object
    raw*: uint8
    field1*: GraphicController_drr_field1

  GraphicController_rmsr_field1* {.bycopy.} = object
    MS* {.bitsize: 2.}: uint8

  GraphicController_rmsr* {.bycopy, union.} = object
    raw*: uint8
    field1*: GraphicController_rmsr_field1

  GraphicController_gmr_field1* {.bycopy.} = object
    WM* {.bitsize: 2.}: uint8
    field1* {.bitsize: 1.}: uint8
    RM* {.bitsize: 1.}: uint8
    OE* {.bitsize: 1.}: uint8
    SRM* {.bitsize: 1.}: uint8
    f256CM* {.bitsize: 1.}: uint8

  GraphicController_gmr* {.bycopy, union.} = object
    raw*: uint8
    field1*: GraphicController_gmr_field1

  GraphicController_mr_field1* {.bycopy.} = object
    GM* {.bitsize: 1.}: uint8
    OE* {.bitsize: 1.}: uint8
    MM* {.bitsize: 2.}: uint8

  CRT_ehbr* {.bycopy, union.} = object
    raw*: uint8
    field1*: CRT_ehbr_field1

  GraphicController_mr* {.bycopy, union.} = object
    raw*: uint8
    field1*: GraphicController_mr_field1

  Attribute_acar_field1* {.bycopy.} = object
    INDX* {.bitsize: 5.}: uint8
    IPAS* {.bitsize: 1.}: uint8

  Attribute_acar* {.bycopy, union.} = object
    raw*: uint8
    field1*: Attribute_acar_field1

  Attribute_field2_field1* {.bycopy.} = object
    P0* {.bitsize: 1.}: uint8
    P1* {.bitsize: 1.}: uint8
    P2* {.bitsize: 1.}: uint8
    P3* {.bitsize: 1.}: uint8
    P4* {.bitsize: 1.}: uint8
    P5* {.bitsize: 1.}: uint8

  Attribute_field2* {.bycopy, union.} = object
    raw*: uint8
    field1*: Attribute_field2_field1

  Attribute_amcr_field1* {.bycopy.} = object
    GAM* {.bitsize: 1.}: uint8
    ME* {.bitsize: 1.}: uint8
    ELGCC* {.bitsize: 1.}: uint8
    ELSBI* {.bitsize: 1.}: uint8
    field4* {.bitsize: 1.}: uint8
    PELPC* {.bitsize: 1.}: uint8
    PELW* {.bitsize: 1.}: uint8
    P54S* {.bitsize: 1.}: uint8

  Attribute_amcr* {.bycopy, union.} = object
    raw*: uint8
    field1*: Attribute_amcr_field1

  Attribute_cper_field1* {.bycopy.} = object
    ECP* {.bitsize: 4.}: uint8
    VSM* {.bitsize: 2.}: uint8

  Attribute_cper* {.bycopy, union.} = object
    raw*: uint8
    field1*: Attribute_cper_field1

  Attribute_hpelpr_field1* {.bycopy.} = object
    HPELP* {.bitsize: 4.}: uint8

  Attribute_hpelpr* {.bycopy, union.} = object
    raw*: uint8
    field1*: Attribute_hpelpr_field1

  Attribute_csr_field1* {.bycopy.} = object
    SC45* {.bitsize: 2.}: uint8
    SC67* {.bitsize: 2.}: uint8

  Attribute_csr* {.bycopy, union.} = object
    raw*: uint8
    field1*: Attribute_csr_field1

  DAC_field2_field1* {.bycopy.} = object
    R* {.bitsize: 6.}: uint8
    G* {.bitsize: 6.}: uint8
    B* {.bitsize: 6.}: uint8

  DAC_field2* {.bycopy, union.} = object
    raw*: array[3, uint8]
    field1*: DAC_field2_field1

  DAC_w_par* {.bycopy, union.} = object
    raw*: uint8
    index*: uint8

  DAC_r_par* {.bycopy, union.} = object
    raw*: uint8
    index*: uint8

  DAC_pdr* {.bycopy, union.} = object
    raw*: uint8
    color*: uint8

  DAC_dacsr_field1* {.bycopy.} = object
    DACstate* {.bitsize: 2.}: uint8

  DAC_dacsr* {.bycopy, union.} = object
    raw*: uint8
    field1*: DAC_dacsr_field1

  DAC_pelmr* {.bycopy, union.} = object
    raw*: uint8
    mask*: uint8


    
proc initVGA*(): VGA =
  result = VGA(
    memio: initMemoryIO().asRef(),
    portio: initPortIO())

  for i in 0 ..< 4:
    result.plane[i] = newSeqWith(1 shl 16, 0'u8)

proc deleteVGA*(vga: var VGA): VGA =
  for i in 0 ..< 4:
    discard

proc need_refresh*(this: var VGA): bool =
  var v: bool = this.refresh
  this.refresh = false
  return v

proc get_dac*(this: var VGA): ptr DAC =
  return addr this.dac

proc get_attr*(this: var VGA): ptr Attribute =
  return addr this.attr

proc get_seq*(this: var VGA): ptr Sequencer =
  return addr this.`seq`

proc get_crt*(this: var VGA): ptr CRT =
  return addr this.crt

proc get_gc*(this: var VGA): ptr GraphicController =
  return addr this.gc

proc initSequencer*(v: ptr VGA): Sequencer =
  result.vga = v
  for i in 0 ..< len(result.regs):
    if not result.regs[i].isNil():
      result.regs[i][] = 0


proc read*(this: var Sequencer, offset: uint32): uint8 =
  discard

proc write*(this: var Sequencer, offset: uint32, v: uint8): void =
  discard

proc in8*(this: var Sequencer, memAddr: uint16): uint8 =
  discard

proc out8*(this: var Sequencer, memAddr: uint16, v: uint8): void =
  discard

proc initCRT*(v: ptr VGA): CRT =
  result.vga = v
  for i in 0 ..< len(result.regs):
    if not result.regs[i].isNil():
      result.regs[i][] = 0


proc get_windowsize*(this: var CRT, x: ptr uint16, y: ptr uint16): void =
  discard

proc attr_index_text*(this: var CRT, n: uint32): uint8 =
  discard

proc in8*(this: var CRT, memAddr: uint16): uint8 =
  discard

proc out8*(this: var CRT, memAddr: uint16, v: uint8): void =
  discard

proc initGraphicController*(v: VGA): GraphicController =
  result.vga = v
  for i in 0 ..< len(result.regs):
    if not result.regs[i].isNil():
      result.regs[i][] = 0

proc read*(this: var GraphicController, offset: uint32): uint8 =
  discard

proc write*(this: var GraphicController, nplane: uint8, offset: uint32, v: uint8): void =
  discard

proc chk_offset*(this: var GraphicController, offset: ptr uint32): bool =
  discard

proc graphic_mode*(this: var GraphicController): gmode_t =
  discard

proc attr_index_graphic*(this: var GraphicController, n: uint32): uint8 =
  discard

proc in8*(this: var GraphicController, memAddr: uint16): uint8 =
  discard

proc out8*(this: var GraphicController, memAddr: uint16, v: uint8): void =
  discard

proc initAttribute*(v: VGA): Attribute =
  result.vga = v
  for i in 0 ..< len(result.regs):
    if not result.regs[i].isNil():
      result.regs[i][] = 0


proc dac_index*(this: var Attribute, index: uint8): uint8 =
  discard

proc in8*(this: var Attribute, memAddr: uint16): uint8 =
  discard

proc out8*(this: var Attribute, memAddr: uint16, v: uint8): void =
  discard

proc initDAC*(v: VGA): DAC =
  result.vga = v

proc translate_rgb*(this: var DAC, index: uint8): uint32 =
  discard

proc in8*(this: var DAC, memAddr: uint16): uint8 =
  discard

proc out8*(this: var DAC, memAddr: uint16, v: uint8): void =
  discard

proc IO*(this: VGA_mor): uint8 = this.field1.IO
proc `IO=`*(this: var VGA_mor, value: uint8) = this.field1.IO = value
proc ER*(this: VGA_mor): uint8 = this.field1.ER
proc `ER=`*(this: var VGA_mor, value: uint8) = this.field1.ER = value
proc CLK0*(this: VGA_mor): uint8 = this.field1.CLK0
proc `CLK0=`*(this: var VGA_mor, value: uint8) = this.field1.CLK0 = value
proc CLK1*(this: VGA_mor): uint8 = this.field1.CLK1
proc `CLK1=`*(this: var VGA_mor, value: uint8) = this.field1.CLK1 = value
proc PS*(this: VGA_mor): uint8 = this.field1.PS
proc `PS=`*(this: var VGA_mor, value: uint8) = this.field1.PS = value
proc HSP*(this: VGA_mor): uint8 = this.field1.HSP
proc `HSP=`*(this: var VGA_mor, value: uint8) = this.field1.HSP = value
proc VSA*(this: VGA_mor): uint8 = this.field1.VSA
proc `VSA=`*(this: var VGA_mor, value: uint8) = this.field1.VSA = value
proc INDX*(this: Sequencer_sar): uint8 = this.field1.INDX
proc `INDX=`*(this: var Sequencer_sar, value: uint8) = this.field1.INDX = value
proc f89DC*(this: Sequencer_cmr): uint8 = this.field1.f89DC
proc `f89DC=`*(this: var Sequencer_cmr, value: uint8) = this.field1.f89DC = value
proc SL*(this: Sequencer_cmr): uint8 = this.field1.SL
proc `SL=`*(this: var Sequencer_cmr, value: uint8) = this.field1.SL = value
proc DC*(this: Sequencer_cmr): uint8 = this.field1.DC
proc `DC=`*(this: var Sequencer_cmr, value: uint8) = this.field1.DC = value
proc S4*(this: Sequencer_cmr): uint8 = this.field1.S4
proc `S4=`*(this: var Sequencer_cmr, value: uint8) = this.field1.S4 = value
proc SO*(this: Sequencer_cmr): uint8 = this.field1.SO
proc `SO=`*(this: var Sequencer_cmr, value: uint8) = this.field1.SO = value
proc MAP0E*(this: Sequencer_map_mr): uint8 = this.field1.MAP0E
proc `MAP0E=`*(this: var Sequencer_map_mr, value: uint8) = this.field1.MAP0E = value
proc MAP1E*(this: Sequencer_map_mr): uint8 = this.field1.MAP1E
proc `MAP1E=`*(this: var Sequencer_map_mr, value: uint8) = this.field1.MAP1E = value
proc MAP2E*(this: Sequencer_map_mr): uint8 = this.field1.MAP2E
proc `MAP2E=`*(this: var Sequencer_map_mr, value: uint8) = this.field1.MAP2E = value
proc MAP3E*(this: Sequencer_map_mr): uint8 = this.field1.MAP3E
proc `MAP3E=`*(this: var Sequencer_map_mr, value: uint8) = this.field1.MAP3E = value
proc CMB*(this: Sequencer_cmsr): uint8 = this.field1.CMB
proc `CMB=`*(this: var Sequencer_cmsr, value: uint8) = this.field1.CMB = value
proc CMA*(this: Sequencer_cmsr): uint8 = this.field1.CMA
proc `CMA=`*(this: var Sequencer_cmsr, value: uint8) = this.field1.CMA = value
proc CMBM*(this: Sequencer_cmsr): uint8 = this.field1.CMBM
proc `CMBM=`*(this: var Sequencer_cmsr, value: uint8) = this.field1.CMBM = value
proc CMAM*(this: Sequencer_cmsr): uint8 = this.field1.CMAM
proc `CMAM=`*(this: var Sequencer_cmsr, value: uint8) = this.field1.CMAM = value
proc EM*(this: Sequencer_mem_mr): uint8 = this.field1.EM
proc `EM=`*(this: var Sequencer_mem_mr, value: uint8) = this.field1.EM = value
proc OE*(this: Sequencer_mem_mr): uint8 = this.field1.OE
proc `OE=`*(this: var Sequencer_mem_mr, value: uint8) = this.field1.OE = value
proc C4*(this: Sequencer_mem_mr): uint8 = this.field1.C4
proc `C4=`*(this: var Sequencer_mem_mr, value: uint8) = this.field1.C4 = value
proc INDX*(this: CRT_crtcar): uint8 = this.field1.INDX
proc `INDX=`*(this: var CRT_crtcar, value: uint8) = this.field1.INDX = value
proc EB*(this: CRT_ehbr): uint8 = this.field1.EB
proc `EB=`*(this: var CRT_ehbr, value: uint8) = this.field1.EB = value
proc DESC*(this: CRT_ehbr): uint8 = this.field1.DESC
proc `DESC=`*(this: var CRT_ehbr, value: uint8) = this.field1.DESC = value
proc MSL*(this: CRT_mslr): uint8 = this.field1.MSL
proc `MSL=`*(this: var CRT_mslr, value: uint8) = this.field1.MSL = value
proc SVB9*(this: CRT_mslr): uint8 = this.field1.SVB9
proc `SVB9=`*(this: var CRT_mslr, value: uint8) = this.field1.SVB9 = value
proc LC9*(this: CRT_mslr): uint8 = this.field1.LC9
proc `LC9=`*(this: var CRT_mslr, value: uint8) = this.field1.LC9 = value
proc LC*(this: CRT_mslr): uint8 = this.field1.LC
proc `LC=`*(this: var CRT_mslr, value: uint8) = this.field1.LC = value
proc RSCB*(this: CRT_csr): uint8 = this.field1.RSCB
proc `RSCB=`*(this: var CRT_csr, value: uint8) = this.field1.RSCB = value
proc CO*(this: CRT_csr): uint8 = this.field1.CO
proc `CO=`*(this: var CRT_csr, value: uint8) = this.field1.CO = value
proc RSCE*(this: CRT_cer): uint8 = this.field1.RSCE
proc `RSCE=`*(this: var CRT_cer, value: uint8) = this.field1.RSCE = value
proc CSC*(this: CRT_cer): uint8 = this.field1.CSC
proc `CSC=`*(this: var CRT_cer, value: uint8) = this.field1.CSC = value
proc CMS0*(this: CRT_crtmcr): uint8 = this.field1.CMS0
proc `CMS0=`*(this: var CRT_crtmcr, value: uint8) = this.field1.CMS0 = value
proc SRSC*(this: CRT_crtmcr): uint8 = this.field1.SRSC
proc `SRSC=`*(this: var CRT_crtmcr, value: uint8) = this.field1.SRSC = value
proc HRSX*(this: CRT_crtmcr): uint8 = this.field1.HRSX
proc `HRSX=`*(this: var CRT_crtmcr, value: uint8) = this.field1.HRSX = value
proc C2*(this: CRT_crtmcr): uint8 = this.field1.C2
proc `C2=`*(this: var CRT_crtmcr, value: uint8) = this.field1.C2 = value
proc AW*(this: CRT_crtmcr): uint8 = this.field1.AW
proc `AW=`*(this: var CRT_crtmcr, value: uint8) = this.field1.AW = value
proc WBM*(this: CRT_crtmcr): uint8 = this.field1.WBM
proc `WBM=`*(this: var CRT_crtmcr, value: uint8) = this.field1.WBM = value
proc HR*(this: CRT_crtmcr): uint8 = this.field1.HR
proc `HR=`*(this: var CRT_crtmcr, value: uint8) = this.field1.HR = value
proc INDX*(this: GraphicController_gcar): uint8 = this.field1.INDX
proc `INDX=`*(this: var GraphicController_gcar, value: uint8) = this.field1.INDX = value
proc SRM0*(this: GraphicController_sr): uint8 = this.field1.SRM0
proc `SRM0=`*(this: var GraphicController_sr, value: uint8) = this.field1.SRM0 = value
proc SRM1*(this: GraphicController_sr): uint8 = this.field1.SRM1
proc `SRM1=`*(this: var GraphicController_sr, value: uint8) = this.field1.SRM1 = value
proc SRM2*(this: GraphicController_sr): uint8 = this.field1.SRM2
proc `SRM2=`*(this: var GraphicController_sr, value: uint8) = this.field1.SRM2 = value
proc SRM3*(this: GraphicController_sr): uint8 = this.field1.SRM3
proc `SRM3=`*(this: var GraphicController_sr, value: uint8) = this.field1.SRM3 = value
proc ESRM0*(this: GraphicController_esr): uint8 = this.field1.ESRM0
proc `ESRM0=`*(this: var GraphicController_esr, value: uint8) = this.field1.ESRM0 = value
proc ESRM1*(this: GraphicController_esr): uint8 = this.field1.ESRM1
proc `ESRM1=`*(this: var GraphicController_esr, value: uint8) = this.field1.ESRM1 = value
proc ESRM2*(this: GraphicController_esr): uint8 = this.field1.ESRM2
proc `ESRM2=`*(this: var GraphicController_esr, value: uint8) = this.field1.ESRM2 = value
proc ESRM3*(this: GraphicController_esr): uint8 = this.field1.ESRM3
proc `ESRM3=`*(this: var GraphicController_esr, value: uint8) = this.field1.ESRM3 = value
proc CCM0*(this: GraphicController_ccr): uint8 = this.field1.CCM0
proc `CCM0=`*(this: var GraphicController_ccr, value: uint8) = this.field1.CCM0 = value
proc CCM1*(this: GraphicController_ccr): uint8 = this.field1.CCM1
proc `CCM1=`*(this: var GraphicController_ccr, value: uint8) = this.field1.CCM1 = value
proc CCM2*(this: GraphicController_ccr): uint8 = this.field1.CCM2
proc `CCM2=`*(this: var GraphicController_ccr, value: uint8) = this.field1.CCM2 = value
proc CCM3*(this: GraphicController_ccr): uint8 = this.field1.CCM3
proc `CCM3=`*(this: var GraphicController_ccr, value: uint8) = this.field1.CCM3 = value
proc RC*(this: GraphicController_drr): uint8 = this.field1.RC
proc `RC=`*(this: var GraphicController_drr, value: uint8) = this.field1.RC = value
proc FS*(this: GraphicController_drr): uint8 = this.field1.FS
proc `FS=`*(this: var GraphicController_drr, value: uint8) = this.field1.FS = value
proc MS*(this: GraphicController_rmsr): uint8 = this.field1.MS
proc `MS=`*(this: var GraphicController_rmsr, value: uint8) = this.field1.MS = value
proc WM*(this: GraphicController_gmr): uint8 = this.field1.WM
proc `WM=`*(this: var GraphicController_gmr, value: uint8) = this.field1.WM = value
proc RM*(this: GraphicController_gmr): uint8 = this.field1.RM
proc `RM=`*(this: var GraphicController_gmr, value: uint8) = this.field1.RM = value
proc OE*(this: GraphicController_gmr): uint8 = this.field1.OE
proc `OE=`*(this: var GraphicController_gmr, value: uint8) = this.field1.OE = value
proc SRM*(this: GraphicController_gmr): uint8 = this.field1.SRM
proc `SRM=`*(this: var GraphicController_gmr, value: uint8) = this.field1.SRM = value
proc f256CM*(this: GraphicController_gmr): uint8 = this.field1.f256CM
proc `f256CM=`*(this: var GraphicController_gmr, value: uint8) = this.field1.f256CM = value
proc GM*(this: GraphicController_mr): uint8 = this.field1.GM
proc `GM=`*(this: var GraphicController_mr, value: uint8) = this.field1.GM = value
proc OE*(this: GraphicController_mr): uint8 = this.field1.OE
proc `OE=`*(this: var GraphicController_mr, value: uint8) = this.field1.OE = value
proc MM*(this: GraphicController_mr): uint8 = this.field1.MM
proc `MM=`*(this: var GraphicController_mr, value: uint8) = this.field1.MM = value
proc INDX*(this: Attribute_acar): uint8 = this.field1.INDX
proc `INDX=`*(this: var Attribute_acar, value: uint8) = this.field1.INDX = value
proc IPAS*(this: Attribute_acar): uint8 = this.field1.IPAS
proc `IPAS=`*(this: var Attribute_acar, value: uint8) = this.field1.IPAS = value
proc P0*(this: Attribute_field2): uint8 = this.field1.P0
proc `P0=`*(this: var Attribute_field2, value: uint8) = this.field1.P0 = value
proc P1*(this: Attribute_field2): uint8 = this.field1.P1
proc `P1=`*(this: var Attribute_field2, value: uint8) = this.field1.P1 = value
proc P2*(this: Attribute_field2): uint8 = this.field1.P2
proc `P2=`*(this: var Attribute_field2, value: uint8) = this.field1.P2 = value
proc P3*(this: Attribute_field2): uint8 = this.field1.P3
proc `P3=`*(this: var Attribute_field2, value: uint8) = this.field1.P3 = value
proc P4*(this: Attribute_field2): uint8 = this.field1.P4
proc `P4=`*(this: var Attribute_field2, value: uint8) = this.field1.P4 = value
proc P5*(this: Attribute_field2): uint8 = this.field1.P5
proc `P5=`*(this: var Attribute_field2, value: uint8) = this.field1.P5 = value
proc raw*(this: Attribute): uint8 = this.field2.raw
proc `raw=`*(this: var Attribute, value: uint8) = this.field2.raw = value
proc P0*(this: Attribute): uint8 = this.field2.field1.P0
proc `P0=`*(this: var Attribute, value: uint8) = this.field2.field1.P0 = value
proc P1*(this: Attribute): uint8 = this.field2.field1.P1
proc `P1=`*(this: var Attribute, value: uint8) = this.field2.field1.P1 = value
proc P2*(this: Attribute): uint8 = this.field2.field1.P2
proc `P2=`*(this: var Attribute, value: uint8) = this.field2.field1.P2 = value
proc P3*(this: Attribute): uint8 = this.field2.field1.P3
proc `P3=`*(this: var Attribute, value: uint8) = this.field2.field1.P3 = value
proc P4*(this: Attribute): uint8 = this.field2.field1.P4
proc `P4=`*(this: var Attribute, value: uint8) = this.field2.field1.P4 = value
proc P5*(this: Attribute): uint8 = this.field2.field1.P5
proc `P5=`*(this: var Attribute, value: uint8) = this.field2.field1.P5 = value
proc GAM*(this: Attribute_amcr): uint8 = this.field1.GAM
proc `GAM=`*(this: var Attribute_amcr, value: uint8) = this.field1.GAM = value
proc ME*(this: Attribute_amcr): uint8 = this.field1.ME
proc `ME=`*(this: var Attribute_amcr, value: uint8) = this.field1.ME = value
proc ELGCC*(this: Attribute_amcr): uint8 = this.field1.ELGCC
proc `ELGCC=`*(this: var Attribute_amcr, value: uint8) = this.field1.ELGCC = value
proc ELSBI*(this: Attribute_amcr): uint8 = this.field1.ELSBI
proc `ELSBI=`*(this: var Attribute_amcr, value: uint8) = this.field1.ELSBI = value
proc PELPC*(this: Attribute_amcr): uint8 = this.field1.PELPC
proc `PELPC=`*(this: var Attribute_amcr, value: uint8) = this.field1.PELPC = value
proc PELW*(this: Attribute_amcr): uint8 = this.field1.PELW
proc `PELW=`*(this: var Attribute_amcr, value: uint8) = this.field1.PELW = value
proc P54S*(this: Attribute_amcr): uint8 = this.field1.P54S
proc `P54S=`*(this: var Attribute_amcr, value: uint8) = this.field1.P54S = value
proc ECP*(this: Attribute_cper): uint8 = this.field1.ECP
proc `ECP=`*(this: var Attribute_cper, value: uint8) = this.field1.ECP = value
proc VSM*(this: Attribute_cper): uint8 = this.field1.VSM
proc `VSM=`*(this: var Attribute_cper, value: uint8) = this.field1.VSM = value
proc HPELP*(this: Attribute_hpelpr): uint8 = this.field1.HPELP
proc `HPELP=`*(this: var Attribute_hpelpr, value: uint8) = this.field1.HPELP = value
proc SC45*(this: Attribute_csr): uint8 = this.field1.SC45
proc `SC45=`*(this: var Attribute_csr, value: uint8) = this.field1.SC45 = value
proc SC67*(this: Attribute_csr): uint8 = this.field1.SC67
proc `SC67=`*(this: var Attribute_csr, value: uint8) = this.field1.SC67 = value
proc R*(this: DAC_field2): uint8 = this.field1.R
proc `R=`*(this: var DAC_field2, value: uint8) = this.field1.R = value
proc G*(this: DAC_field2): uint8 = this.field1.G
proc `G=`*(this: var DAC_field2, value: uint8) = this.field1.G = value
proc B*(this: DAC_field2): uint8 = this.field1.B
proc `B=`*(this: var DAC_field2, value: uint8) = this.field1.B = value
proc raw*(this: DAC): array[3, uint8] = this.field2.raw
proc `raw=`*(this: var DAC, value: array[3, uint8]) = this.field2.raw = value
proc R*(this: DAC): uint8 = this.field2.field1.R
proc `R=`*(this: var DAC, value: uint8) = this.field2.field1.R = value
proc G*(this: DAC): uint8 = this.field2.field1.G
proc `G=`*(this: var DAC, value: uint8) = this.field2.field1.G = value
proc B*(this: DAC): uint8 = this.field2.field1.B
proc `B=`*(this: var DAC, value: uint8) = this.field2.field1.B = value
proc DACstate*(this: DAC_dacsr): uint8 = this.field1.DACstate
proc `DACstate=`*(this: var DAC_dacsr, value: uint8) = this.field1.DACstate = value

template chk_regidx*(n: untyped): untyped {.dirty.} =
  block:
    var doTmp: bool = true
    while doTmp or (0):
      doTmp = "false"
      if n > sizeof((regs)):
        ERROR("register index out of bound", n)

      if not(regs[n]):
        ERROR("not implemented")


proc get_windowsize*(this: var VGA, x: ptr uint16, y: ptr uint16): void =
  crt.get_windowsize(x, y)

proc rgb_image*(this: var VGA, buffer: ptr uint8, size: uint32): void =
  var mode: gmode_t = gc.graphic_mode()
  for i in 0 ..< size:
    var dac_idx: uint8
    var rgb: uint32
    attr_idx = (if mode xor MODE_TEXT:
          gc.attr_index_graphic(i)

        else:
          crt.attr_index_text(i)
        )
    dac_idx = (if mode xor MODE_GRAPHIC256:
          attr.dac_index(attr_idx)

        else:
          attr_idx
        )
    rgb = dac.translate_rgb(dac_idx)
    (postInc(buffer))[] = rgb and 0xff
    (postInc(buffer))[] = (rgb shr 8) and 0xff
    (postInc(buffer))[] = (rgb shr 16) and 0xff

proc in8*(this: var VGA, memAddr: uint16): uint8 =
  case memAddr:
    of 0x3c2:
      return 0
    of 0x3c3:
      return 0
    of 0x3cc:
      return mor.raw
    of 0x3ba, 0x3da:
      return 0
  return -1

proc out8*(this: var VGA, memAddr: uint16, v: uint8): void =
  case memAddr:
    of 0x3c2:
      mor.raw = v
    of 0x3c3:
      discard
    of 0x3ba, 0x3da:
      discard

proc read8*(this: var VGA, offset: uint32): uint8 =
  return (if mor.ER:
            seq.read(offset)

          else:
            0
          )

proc write8*(this: var VGA, offset: uint32, v: uint8): void =
  var count: cint = 0
  if mor.ER:
    seq.write(offset, v)
    if not((postInc(count) mod 0x10)):
      refresh = true



proc read_plane*(this: var VGA, nplane: uint8, offset: uint32): uint8 =
  if nplane > 3 or offset > (1 shl 16) - 1:
    ERROR("Out of Plane range")

  return plane[nplane][offset]

proc write_plane*(this: var VGA, nplane: uint8, offset: uint32, v: uint8): void =
  if nplane > 3 or offset > (1 shl 16) - 1:
    ERROR("Out of Plane range")

  plane[nplane][offset] = v


proc VGA_Sequencer_read*(offset: uint32): uint8 =
  if not(mem_mr.EM):
    offset = (offset and (1 shl 16) - 1)

  return vga.gc.read(offset)

template SEQ_WRITE_PLANE*(n: untyped, o: untyped, v: untyped): untyped {.dirty.} =
  if (map_mr.raw shr (n)) and 1:
    vga.gc.write(n, o, v)


proc VGA_Sequencer_write*(offset: uint32, v: uint8): void =
  if not(mem_mr.EM):
    offset = (offset and (1 shl 16) - 1)

  if mem_mr.C4:
    SEQ_WRITE_PLANE(offset and 3, offset and (not(3)), v)

  else:
    if mem_mr.OE:
      for i in 0 ..< 4:
        SEQ_WRITE_PLANE(i, offset, v)

    else:
      var nplane: uint8 = offset and 1
      SEQ_WRITE_PLANE(nplane, offset, v)
      SEQ_WRITE_PLANE(nplane + 2, offset, v)



proc VGA_Sequencer_get_font*(att: uint8): ptr uint8 =
  var v: uint8
  var font_ofst: uint16 = 0
  v = (if att and 0x8:
        (cmsr.CMAM shl 2) + cmsr.CMA

      else:
        (cmsr.CMBM shl 2) + cmsr.CMB
      )
  font_ofst = (if v and 4:
        (v and (not(4))) * 2 + 1

      else:
        v * 2
      )
  if not(mem_mr.EM):
    font_ofst = (font_ofst and (1 shl 16) - 1)

  return vga.plane[2] + font_ofst

proc VGA_Sequencer_in8*(memAddr: uint16): uint8 =
  case memAddr:
    of 0x3c4:
      return sar.raw
    of 0x3c5:
      return regs[sar.INDX][]
  return -1

proc VGA_Sequencer_out8*(memAddr: uint16, v: uint8): void =
  case memAddr:
    of 0x3c4:
      chk_regidx(v)
      sar.raw = v
    of 0x3c5:
      regs[sar.INDX][] = v


proc VGA_CRT_get_windowsize*(x: ptr uint16, y: ptr uint16): void =
  x[] = 8 * hdeer.HDEE
  y[] = 8 * vdeer.VDEE

proc VGA_CRT_attr_index_text*(n: uint32): uint8 =
  var att: uint8
  var font: ptr uint8
  var bits: uint8
  var y: uint16
  x = n mod (8 * hdeer.HDEE)
  y = n / (8 * hdeer.HDEE)
  idx = y / (mslr.MSL + 1) * hdeer.HDEE + x / 8
  chr = vga.read_plane(0, idx * 2)
  att = vga.read_plane(1, idx * 2)
  font = vga.seq.get_font(att)
  bits = (font + chr * 0x10 + y mod (mslr.MSL + 1))[]
  return (if (bits shr (x mod 8)) and 1:
            att and 0x0f

          else:
            (att and 0xf0) shr 4
          )

proc VGA_CRT_in8*(memAddr: uint16): uint8 =
  case memAddr:
    of 0x3b4, 0x3d4:
      return crtcar.raw
    of 0x3b5, 0x3d5:
      return regs[crtcar.INDX][]
  return -1

proc VGA_CRT_out8*(memAddr: uint16, v: uint8): void =
  case memAddr:
    of 0x3b4, 0x3d4:
      chk_regidx(v)
      crtcar.raw = v
    of 0x3b5, 0x3d5:
      regs[crtcar.INDX][] = v


proc VGA_GraphicController_read*(offset: uint32): uint8 =
  if not(chk_offset(addr offset)):
    return 0

  case gmr.WM:
    of 0:
      if gmr.OE:
        var nplane: uint8 = (rmsr.MS and 2) + (offset and 1)
        return vga.read_plane(nplane, offset and (not(1)))

      else:
        return vga.read_plane(rmsr.MS, offset)

    of 1:
      discard
  return 0

proc VGA_GraphicController_write*(nplane: uint8, offset: uint32, v: uint8): void =
  if not(chk_offset(addr offset)):
    return

  case gmr.WM:
    of 0:
      if gmr.OE:
        offset = (offset and not(1))

      vga.write_plane(nplane, offset, v)
    of 1:
      discard
    of 2:
      discard
    of 3:
      discard
  INFO(4, "plane[%d][0x%x] = 0x%02x", nplane, offset, v)

proc VGA_GraphicController_chk_offset*(offset: ptr uint32): bool =
  var size: uint32
  var valid: bool
  case mr.MM:
    of 0:
      base = 0x00000
      size = 0x20000
    of 1:
      base = 0x00000
      size = 0x10000
    of 2:
      base = 0x10000
      size = 0x08000
    of 3:
      base = 0x18000
      size = 0x08000
  valid = (offset[] >= base and offset[] < base + size)
  offset[] = (offset[] - base)
  return valid

proc VGA_GraphicController_graphic_mode*(): gmode_t =
  if mr.GM:
    if gmr._256CM:
      return MODE_GRAPHIC256

    return MODE_GRAPHIC

  return MODE_TEXT

proc VGA_GraphicController_attr_index_graphic*(n: uint32): uint8 =
  return vga.read_plane(2, n)

proc VGA_GraphicController_in8*(memAddr: uint16): uint8 =
  case memAddr:
    of 0x3ce:
      return gcar.raw
    of 0x3cf:
      return regs[gcar.INDX][]
  return -1

proc VGA_GraphicController_out8*(memAddr: uint16, v: uint8): void =
  case memAddr:
    of 0x3ce:
      chk_regidx(v)
      gcar.raw = v
    of 0x3cf:
      regs[gcar.INDX][] = v


proc VGA_Attribute_dac_index*(index: uint8): uint8 =
  var dac_idx: uint8
  type
    field1* {.bycopy.} = object
      low* {.bitsize: 4.}: uint8
      high* {.bitsize: 2.}: uint8

  proc low*(this: ): uint8 =
    this.field1.low

  proc `low=`*(this: var , value: uint8) =
    this.field1.low = value

  proc high*(this: ): uint8 =
    this.field1.high

  proc `high=`*(this: var , value: uint8) =
    this.field1.high = value

  type
    * {.bycopy, union.} = object
      raw*: uint8
      field1*: field1

  var ip_data:
  ip_data.raw = ipr[index and 0xf].raw
  if amcr.GAM:
    dac_idx = ip_data.low
    dac_idx = (dac_idx + ((if amcr.P54S:
              csr.SC45

            else:
              ip_data.high
            )) shl 4)
    dac_idx = (dac_idx + csr.SC67 shl 6)

  else:
    dac_idx = ip_data.low

  return dac_idx

proc VGA_Attribute_in8*(memAddr: uint16): uint8 =
  case memAddr:
    of 0x3c0:
      return acar.raw
    of 0x3c1:
      return regs[acar.INDX][]
  return -1

proc VGA_Attribute_out8*(memAddr: uint16, v: uint8): void =
  case memAddr:
    of 0x3c0:
      chk_regidx(v)
      acar.raw = v
    of 0x3c1:
      regs[acar.INDX][] = v


proc VGA_DAC_translate_rgb*(index: uint8): uint32 =
  var rgb: uint32

  rgb = clut[index].R shl 0x02
  rgb = (rgb + clut[index].G shl 0x0a)
  rgb = (rgb + clut[index].B shl 0x12)
  return rgb

proc VGA_DAC_in8*(memAddr: uint16): uint8 =
  var v: uint8
  case memAddr:
    of 0x3c6: return pelmr.raw
    of 0x3c7: return dacsr.raw
    of 0x3c9:
      v = clut[r_par.index].raw[postInc(progress)]
      if progress == 3:
        progress = 0
        postInc(r_par.index)

      return v
  return -1

proc VGA_DAC_out8*(memAddr: uint16, v: uint8): void =
  case memAddr:
    of 0x3c7:
      if v > 0xff:
        ERROR("")

      r_par.raw = v
      progress = 0
    of 0x3c8:
      if v > 0xff:
        ERROR("")

      w_par.raw = v
      progress = 0
    of 0x3c9:
      clut[w_par.index].raw[postInc(progress)] = v
      if progress == 3:
        progress = 0
        postInc(w_par.index)
