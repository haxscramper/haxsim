import
  commonhpp
import
  dev_iohpp
template r*(reg: untyped): untyped {.dirty.} = 
  (addr reg.raw)

type
  MODE_GRAPHIC256* {.size: sizeof(cint).} = enum
    MODE_TEXT
    MODE_GRAPHIC
    MODE_GRAPHIC256
  
type
  VGA* {.bycopy, importcpp.} = object
    mor*: VGA_mor_Type        
    plane*: array[4, ptr uint8]
    refresh*: bool        
    seq*: Sequencer        
    crt*: CRT        
    gc*: GraphicController        
    attr*: Attribute        
    dac*: DAC        
  
proc initVGA*(): VGA = 
  for i in 0 ..< 4:
    plane[i] = newuint8_t()

proc initVGA*(): VGA = 
  for i in 0 ..< 4:
    cxx_delete plane[i]

proc need_refresh*(this: var VGA): bool = 
  var v: bool = refresh
  refresh = false
  return v

proc get_dac*(this: var VGA): ptr DAC = 
  return addr dac

proc get_attr*(this: var VGA): ptr Attribute = 
  return addr attr

proc get_seq*(this: var VGA): ptr Sequencer = 
  return addr seq

proc get_crt*(this: var VGA): ptr CRT = 
  return addr crt

proc get_gc*(this: var VGA): ptr GraphicController = 
  return addr gc

type
  Sequencer* {.bycopy, importcpp.} = object
    vga*: ptr VGA    
    sar*: Sequencer_sar_Type        
    cmr*: Sequencer_cmr_Type        
    map_mr*: Sequencer_map_mr_Type        
    cmsr*: Sequencer_cmsr_Type        
    mem_mr*: Sequencer_mem_mr_Type        
    regs*: array[8, ptr uint8]
    get_font*: ptr uint8    
  
proc initSequencer*(v: ptr VGA): Sequencer = 
  vga = v
  for i in 0 ..< sizeof(regs) / sizeof(ptr uint8):
    if regs[i]:
      regs[i][] = 0
    

proc read*(this: var Sequencer, offset: uint32): uint8 = 
  discard 

proc write*(this: var Sequencer, offset: uint32, v: uint8): void = 
  discard 

proc in8*(this: var Sequencer, `addr`: uint16): uint8 = 
  discard 

proc out8*(this: var Sequencer, `addr`: uint16, v: uint8): void = 
  discard 

type
  CRT* {.bycopy, importcpp.} = object
    vga*: ptr VGA    
    crtcar*: CRT_crtcar_Type        
    htr*: CRT_htr_Type        
    hdeer*: CRT_hdeer_Type        
    shbr*: CRT_shbr_Type        
    ehbr*: CRT_ehbr_Type        
    mslr*: CRT_mslr_Type        
    csr*: CRT_csr_Type        
    cer*: CRT_cer_Type        
    sahr*: CRT_sahr_Type        
    salr*: CRT_salr_Type        
    clhr*: CRT_clhr_Type        
    cllr*: CRT_cllr_Type        
    vdeer*: CRT_vdeer_Type        
    ofsr*: CRT_ofsr_Type        
    crtmcr*: CRT_crtmcr_Type        
    regs*: array[25, ptr uint8]
  
proc initCRT*(v: ptr VGA): CRT = 
  vga = v
  for i in 0 ..< sizeof(regs) / sizeof(ptr uint8):
    if regs[i]:
      regs[i][] = 0
    

proc get_windowsize*(this: var CRT, x: ptr uint16, y: ptr uint16): void = 
  discard 

proc attr_index_text*(this: var CRT, n: uint32): uint8 = 
  discard 

proc in8*(this: var CRT, `addr`: uint16): uint8 = 
  discard 

proc out8*(this: var CRT, `addr`: uint16, v: uint8): void = 
  discard 

type
  GraphicController* {.bycopy, importcpp.} = object
    vga*: ptr VGA    
    gcar*: GraphicController_gcar_Type        
    sr*: GraphicController_sr_Type        
    esr*: GraphicController_esr_Type        
    ccr*: GraphicController_ccr_Type        
    drr*: GraphicController_drr_Type        
    rmsr*: GraphicController_rmsr_Type        
    gmr*: GraphicController_gmr_Type        
    mr*: GraphicController_mr_Type        
    regs*: array[9, ptr uint8]
  
proc initGraphicController*(v: ptr VGA): GraphicController = 
  vga = v
  for i in 0 ..< sizeof(regs) / sizeof(ptr uint8):
    if regs[i]:
      regs[i][] = 0
    

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

proc in8*(this: var GraphicController, `addr`: uint16): uint8 = 
  discard 

proc out8*(this: var GraphicController, `addr`: uint16, v: uint8): void = 
  discard 

type
  Attribute* {.bycopy, importcpp.} = object
    vga*: ptr VGA    
    acar*: Attribute_acar_Type        
    field2*: Attribute_field2_Type        
    amcr*: Attribute_amcr_Type        
    cper*: Attribute_cper_Type        
    hpelpr*: Attribute_hpelpr_Type        
    csr*: Attribute_csr_Type        
    regs*: array[21, ptr uint8]
  
proc initAttribute*(v: ptr VGA): Attribute = 
  vga = v
  for i in 0 ..< sizeof(regs) / sizeof(ptr uint8):
    if regs[i]:
      regs[i][] = 0
    

proc dac_index*(this: var Attribute, index: uint8): uint8 = 
  discard 

proc in8*(this: var Attribute, `addr`: uint16): uint8 = 
  discard 

proc out8*(this: var Attribute, `addr`: uint16, v: uint8): void = 
  discard 

type
  DAC* {.bycopy, importcpp.} = object
    vga*: ptr VGA
    progress*: uint8    
    field2*: DAC_field2_Type    
    w_par*: DAC_w_par_Type    
    r_par*: DAC_r_par_Type    
    pdr*: DAC_pdr_Type    
    dacsr*: DAC_dacsr_Type    
    pelmr*: DAC_pelmr_Type    
  
proc initDAC*(v: ptr VGA): DAC = 
  vga = v

proc translate_rgb*(this: var DAC, index: uint8): uint32 = 
  discard 

proc in8*(this: var DAC, `addr`: uint16): uint8 = 
  discard 

proc out8*(this: var DAC, `addr`: uint16, v: uint8): void = 
  discard 

type
  field1_Type* {.bycopy.} = object
    IO* {.bitsize: 1.}: uint8
    ER* {.bitsize: 1.}: uint8
    CLK0* {.bitsize: 1.}: uint8
    CLK1* {.bitsize: 1.}: uint8
    * {.bitsize: 1.}: uint8
    PS* {.bitsize: 1.}: uint8
    HSP* {.bitsize: 1.}: uint8
    VSA* {.bitsize: 1.}: uint8
  
proc IO*(this: VGA_mor_Type): uint8 = 
  this.field1.IO

proc `IO =`*(this: var VGA_mor_Type): uint8 = 
  this.field1.IO

proc ER*(this: VGA_mor_Type): uint8 = 
  this.field1.ER

proc `ER =`*(this: var VGA_mor_Type): uint8 = 
  this.field1.ER

proc CLK0*(this: VGA_mor_Type): uint8 = 
  this.field1.CLK0

proc `CLK0 =`*(this: var VGA_mor_Type): uint8 = 
  this.field1.CLK0

proc CLK1*(this: VGA_mor_Type): uint8 = 
  this.field1.CLK1

proc `CLK1 =`*(this: var VGA_mor_Type): uint8 = 
  this.field1.CLK1

proc *(this: VGA_mor_Type): uint8 = 
  this.field1.

proc ` =`*(this: var VGA_mor_Type): uint8 = 
  this.field1.

proc PS*(this: VGA_mor_Type): uint8 = 
  this.field1.PS

proc `PS =`*(this: var VGA_mor_Type): uint8 = 
  this.field1.PS

proc HSP*(this: VGA_mor_Type): uint8 = 
  this.field1.HSP

proc `HSP =`*(this: var VGA_mor_Type): uint8 = 
  this.field1.HSP

proc VSA*(this: VGA_mor_Type): uint8 = 
  this.field1.VSA

proc `VSA =`*(this: var VGA_mor_Type): uint8 = 
  this.field1.VSA

type
  VGA_mor_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  
type
  field1_Type* {.bycopy.} = object
    INDX* {.bitsize: 3.}: uint8
  
proc INDX*(this: Sequencer_sar_Type): uint8 = 
  this.field1.INDX

proc `INDX =`*(this: var Sequencer_sar_Type): uint8 = 
  this.field1.INDX

type
  Sequencer_sar_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  
type
  field1_Type* {.bycopy.} = object
    _89DC* {.bitsize: 1.}: uint8
    * {.bitsize: 1.}: uint8
    SL* {.bitsize: 1.}: uint8
    DC* {.bitsize: 1.}: uint8
    S4* {.bitsize: 1.}: uint8
    SO* {.bitsize: 1.}: uint8
  
proc _89DC*(this: Sequencer_cmr_Type): uint8 = 
  this.field1._89DC

proc `_89DC =`*(this: var Sequencer_cmr_Type): uint8 = 
  this.field1._89DC

proc *(this: Sequencer_cmr_Type): uint8 = 
  this.field1.

proc ` =`*(this: var Sequencer_cmr_Type): uint8 = 
  this.field1.

proc SL*(this: Sequencer_cmr_Type): uint8 = 
  this.field1.SL

proc `SL =`*(this: var Sequencer_cmr_Type): uint8 = 
  this.field1.SL

proc DC*(this: Sequencer_cmr_Type): uint8 = 
  this.field1.DC

proc `DC =`*(this: var Sequencer_cmr_Type): uint8 = 
  this.field1.DC

proc S4*(this: Sequencer_cmr_Type): uint8 = 
  this.field1.S4

proc `S4 =`*(this: var Sequencer_cmr_Type): uint8 = 
  this.field1.S4

proc SO*(this: Sequencer_cmr_Type): uint8 = 
  this.field1.SO

proc `SO =`*(this: var Sequencer_cmr_Type): uint8 = 
  this.field1.SO

type
  Sequencer_cmr_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  
type
  field1_Type* {.bycopy.} = object
    MAP0E* {.bitsize: 1.}: uint8
    MAP1E* {.bitsize: 1.}: uint8
    MAP2E* {.bitsize: 1.}: uint8
    MAP3E* {.bitsize: 1.}: uint8
  
proc MAP0E*(this: Sequencer_map_mr_Type): uint8 = 
  this.field1.MAP0E

proc `MAP0E =`*(this: var Sequencer_map_mr_Type): uint8 = 
  this.field1.MAP0E

proc MAP1E*(this: Sequencer_map_mr_Type): uint8 = 
  this.field1.MAP1E

proc `MAP1E =`*(this: var Sequencer_map_mr_Type): uint8 = 
  this.field1.MAP1E

proc MAP2E*(this: Sequencer_map_mr_Type): uint8 = 
  this.field1.MAP2E

proc `MAP2E =`*(this: var Sequencer_map_mr_Type): uint8 = 
  this.field1.MAP2E

proc MAP3E*(this: Sequencer_map_mr_Type): uint8 = 
  this.field1.MAP3E

proc `MAP3E =`*(this: var Sequencer_map_mr_Type): uint8 = 
  this.field1.MAP3E

type
  Sequencer_map_mr_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  
type
  field1_Type* {.bycopy.} = object
    CMB* {.bitsize: 2.}: uint8
    CMA* {.bitsize: 2.}: uint8
    CMBM* {.bitsize: 1.}: uint8
    CMAM* {.bitsize: 1.}: uint8
  
proc CMB*(this: Sequencer_cmsr_Type): uint8 = 
  this.field1.CMB

proc `CMB =`*(this: var Sequencer_cmsr_Type): uint8 = 
  this.field1.CMB

proc CMA*(this: Sequencer_cmsr_Type): uint8 = 
  this.field1.CMA

proc `CMA =`*(this: var Sequencer_cmsr_Type): uint8 = 
  this.field1.CMA

proc CMBM*(this: Sequencer_cmsr_Type): uint8 = 
  this.field1.CMBM

proc `CMBM =`*(this: var Sequencer_cmsr_Type): uint8 = 
  this.field1.CMBM

proc CMAM*(this: Sequencer_cmsr_Type): uint8 = 
  this.field1.CMAM

proc `CMAM =`*(this: var Sequencer_cmsr_Type): uint8 = 
  this.field1.CMAM

type
  Sequencer_cmsr_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  
type
  field1_Type* {.bycopy.} = object
    * {.bitsize: 1.}: uint8
    EM* {.bitsize: 1.}: uint8
    OE* {.bitsize: 1.}: uint8
    C4* {.bitsize: 1.}: uint8
  
proc *(this: Sequencer_mem_mr_Type): uint8 = 
  this.field1.

proc ` =`*(this: var Sequencer_mem_mr_Type): uint8 = 
  this.field1.

proc EM*(this: Sequencer_mem_mr_Type): uint8 = 
  this.field1.EM

proc `EM =`*(this: var Sequencer_mem_mr_Type): uint8 = 
  this.field1.EM

proc OE*(this: Sequencer_mem_mr_Type): uint8 = 
  this.field1.OE

proc `OE =`*(this: var Sequencer_mem_mr_Type): uint8 = 
  this.field1.OE

proc C4*(this: Sequencer_mem_mr_Type): uint8 = 
  this.field1.C4

proc `C4 =`*(this: var Sequencer_mem_mr_Type): uint8 = 
  this.field1.C4

type
  Sequencer_mem_mr_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  
type
  field1_Type* {.bycopy.} = object
    INDX* {.bitsize: 5.}: uint8
  
proc INDX*(this: CRT_crtcar_Type): uint8 = 
  this.field1.INDX

proc `INDX =`*(this: var CRT_crtcar_Type): uint8 = 
  this.field1.INDX

type
  CRT_crtcar_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  
type
  CRT_htr_Type* {.bycopy, union.} = object
    raw*: uint8
    HT*: uint8
  
type
  CRT_hdeer_Type* {.bycopy, union.} = object
    raw*: uint8
    HDEE*: uint8
  
type
  CRT_shbr_Type* {.bycopy, union.} = object
    raw*: uint8
    SHB*: uint8
  
type
  field1_Type* {.bycopy.} = object
    EB* {.bitsize: 5.}: uint8
    DESC* {.bitsize: 2.}: uint8
  
proc EB*(this: CRT_ehbr_Type): uint8 = 
  this.field1.EB

proc `EB =`*(this: var CRT_ehbr_Type): uint8 = 
  this.field1.EB

proc DESC*(this: CRT_ehbr_Type): uint8 = 
  this.field1.DESC

proc `DESC =`*(this: var CRT_ehbr_Type): uint8 = 
  this.field1.DESC

type
  CRT_ehbr_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  
type
  field1_Type* {.bycopy.} = object
    MSL* {.bitsize: 5.}: uint8
    SVB9* {.bitsize: 1.}: uint8
    LC9* {.bitsize: 1.}: uint8
    LC* {.bitsize: 1.}: uint8
  
proc MSL*(this: CRT_mslr_Type): uint8 = 
  this.field1.MSL

proc `MSL =`*(this: var CRT_mslr_Type): uint8 = 
  this.field1.MSL

proc SVB9*(this: CRT_mslr_Type): uint8 = 
  this.field1.SVB9

proc `SVB9 =`*(this: var CRT_mslr_Type): uint8 = 
  this.field1.SVB9

proc LC9*(this: CRT_mslr_Type): uint8 = 
  this.field1.LC9

proc `LC9 =`*(this: var CRT_mslr_Type): uint8 = 
  this.field1.LC9

proc LC*(this: CRT_mslr_Type): uint8 = 
  this.field1.LC

proc `LC =`*(this: var CRT_mslr_Type): uint8 = 
  this.field1.LC

type
  CRT_mslr_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  
type
  field1_Type* {.bycopy.} = object
    RSCB* {.bitsize: 5.}: uint8
    CO* {.bitsize: 1.}: uint8
  
proc RSCB*(this: CRT_csr_Type): uint8 = 
  this.field1.RSCB

proc `RSCB =`*(this: var CRT_csr_Type): uint8 = 
  this.field1.RSCB

proc CO*(this: CRT_csr_Type): uint8 = 
  this.field1.CO

proc `CO =`*(this: var CRT_csr_Type): uint8 = 
  this.field1.CO

type
  CRT_csr_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  
type
  field1_Type* {.bycopy.} = object
    RSCE* {.bitsize: 5.}: uint8
    CSC* {.bitsize: 2.}: uint8
  
proc RSCE*(this: CRT_cer_Type): uint8 = 
  this.field1.RSCE

proc `RSCE =`*(this: var CRT_cer_Type): uint8 = 
  this.field1.RSCE

proc CSC*(this: CRT_cer_Type): uint8 = 
  this.field1.CSC

proc `CSC =`*(this: var CRT_cer_Type): uint8 = 
  this.field1.CSC

type
  CRT_cer_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  
type
  CRT_sahr_Type* {.bycopy, union.} = object
    raw*: uint8
    HBSA*: uint8
  
type
  CRT_salr_Type* {.bycopy, union.} = object
    raw*: uint8
    LBSA*: uint8
  
type
  CRT_clhr_Type* {.bycopy, union.} = object
    raw*: uint8
    HBCL*: uint8
  
type
  CRT_cllr_Type* {.bycopy, union.} = object
    raw*: uint8
    LBCL*: uint8
  
type
  CRT_vdeer_Type* {.bycopy, union.} = object
    raw*: uint8
    VDEE*: uint8
  
type
  CRT_ofsr_Type* {.bycopy, union.} = object
    raw*: uint8
    LLWS*: uint8
  
type
  field1_Type* {.bycopy.} = object
    CMS0* {.bitsize: 1.}: uint8
    SRSC* {.bitsize: 1.}: uint8
    HRSX* {.bitsize: 1.}: uint8
    C2* {.bitsize: 1.}: uint8
    * {.bitsize: 1.}: uint8
    AW* {.bitsize: 1.}: uint8
    WBM* {.bitsize: 1.}: uint8
    HR* {.bitsize: 1.}: uint8
  
proc CMS0*(this: CRT_crtmcr_Type): uint8 = 
  this.field1.CMS0

proc `CMS0 =`*(this: var CRT_crtmcr_Type): uint8 = 
  this.field1.CMS0

proc SRSC*(this: CRT_crtmcr_Type): uint8 = 
  this.field1.SRSC

proc `SRSC =`*(this: var CRT_crtmcr_Type): uint8 = 
  this.field1.SRSC

proc HRSX*(this: CRT_crtmcr_Type): uint8 = 
  this.field1.HRSX

proc `HRSX =`*(this: var CRT_crtmcr_Type): uint8 = 
  this.field1.HRSX

proc C2*(this: CRT_crtmcr_Type): uint8 = 
  this.field1.C2

proc `C2 =`*(this: var CRT_crtmcr_Type): uint8 = 
  this.field1.C2

proc *(this: CRT_crtmcr_Type): uint8 = 
  this.field1.

proc ` =`*(this: var CRT_crtmcr_Type): uint8 = 
  this.field1.

proc AW*(this: CRT_crtmcr_Type): uint8 = 
  this.field1.AW

proc `AW =`*(this: var CRT_crtmcr_Type): uint8 = 
  this.field1.AW

proc WBM*(this: CRT_crtmcr_Type): uint8 = 
  this.field1.WBM

proc `WBM =`*(this: var CRT_crtmcr_Type): uint8 = 
  this.field1.WBM

proc HR*(this: CRT_crtmcr_Type): uint8 = 
  this.field1.HR

proc `HR =`*(this: var CRT_crtmcr_Type): uint8 = 
  this.field1.HR

type
  CRT_crtmcr_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  
type
  field1_Type* {.bycopy.} = object
    INDX* {.bitsize: 4.}: uint8
  
proc INDX*(this: GraphicController_gcar_Type): uint8 = 
  this.field1.INDX

proc `INDX =`*(this: var GraphicController_gcar_Type): uint8 = 
  this.field1.INDX

type
  GraphicController_gcar_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  
type
  field1_Type* {.bycopy.} = object
    SRM0* {.bitsize: 1.}: uint8
    SRM1* {.bitsize: 1.}: uint8
    SRM2* {.bitsize: 1.}: uint8
    SRM3* {.bitsize: 1.}: uint8
  
proc SRM0*(this: GraphicController_sr_Type): uint8 = 
  this.field1.SRM0

proc `SRM0 =`*(this: var GraphicController_sr_Type): uint8 = 
  this.field1.SRM0

proc SRM1*(this: GraphicController_sr_Type): uint8 = 
  this.field1.SRM1

proc `SRM1 =`*(this: var GraphicController_sr_Type): uint8 = 
  this.field1.SRM1

proc SRM2*(this: GraphicController_sr_Type): uint8 = 
  this.field1.SRM2

proc `SRM2 =`*(this: var GraphicController_sr_Type): uint8 = 
  this.field1.SRM2

proc SRM3*(this: GraphicController_sr_Type): uint8 = 
  this.field1.SRM3

proc `SRM3 =`*(this: var GraphicController_sr_Type): uint8 = 
  this.field1.SRM3

type
  GraphicController_sr_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  
type
  field1_Type* {.bycopy.} = object
    ESRM0* {.bitsize: 1.}: uint8
    ESRM1* {.bitsize: 1.}: uint8
    ESRM2* {.bitsize: 1.}: uint8
    ESRM3* {.bitsize: 1.}: uint8
  
proc ESRM0*(this: GraphicController_esr_Type): uint8 = 
  this.field1.ESRM0

proc `ESRM0 =`*(this: var GraphicController_esr_Type): uint8 = 
  this.field1.ESRM0

proc ESRM1*(this: GraphicController_esr_Type): uint8 = 
  this.field1.ESRM1

proc `ESRM1 =`*(this: var GraphicController_esr_Type): uint8 = 
  this.field1.ESRM1

proc ESRM2*(this: GraphicController_esr_Type): uint8 = 
  this.field1.ESRM2

proc `ESRM2 =`*(this: var GraphicController_esr_Type): uint8 = 
  this.field1.ESRM2

proc ESRM3*(this: GraphicController_esr_Type): uint8 = 
  this.field1.ESRM3

proc `ESRM3 =`*(this: var GraphicController_esr_Type): uint8 = 
  this.field1.ESRM3

type
  GraphicController_esr_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  
type
  field1_Type* {.bycopy.} = object
    CCM0* {.bitsize: 1.}: uint8
    CCM1* {.bitsize: 1.}: uint8
    CCM2* {.bitsize: 1.}: uint8
    CCM3* {.bitsize: 1.}: uint8
  
proc CCM0*(this: GraphicController_ccr_Type): uint8 = 
  this.field1.CCM0

proc `CCM0 =`*(this: var GraphicController_ccr_Type): uint8 = 
  this.field1.CCM0

proc CCM1*(this: GraphicController_ccr_Type): uint8 = 
  this.field1.CCM1

proc `CCM1 =`*(this: var GraphicController_ccr_Type): uint8 = 
  this.field1.CCM1

proc CCM2*(this: GraphicController_ccr_Type): uint8 = 
  this.field1.CCM2

proc `CCM2 =`*(this: var GraphicController_ccr_Type): uint8 = 
  this.field1.CCM2

proc CCM3*(this: GraphicController_ccr_Type): uint8 = 
  this.field1.CCM3

proc `CCM3 =`*(this: var GraphicController_ccr_Type): uint8 = 
  this.field1.CCM3

type
  GraphicController_ccr_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  
type
  field1_Type* {.bycopy.} = object
    RC* {.bitsize: 3.}: uint8
    FS* {.bitsize: 2.}: uint8
  
proc RC*(this: GraphicController_drr_Type): uint8 = 
  this.field1.RC

proc `RC =`*(this: var GraphicController_drr_Type): uint8 = 
  this.field1.RC

proc FS*(this: GraphicController_drr_Type): uint8 = 
  this.field1.FS

proc `FS =`*(this: var GraphicController_drr_Type): uint8 = 
  this.field1.FS

type
  GraphicController_drr_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  
type
  field1_Type* {.bycopy.} = object
    MS* {.bitsize: 2.}: uint8
  
proc MS*(this: GraphicController_rmsr_Type): uint8 = 
  this.field1.MS

proc `MS =`*(this: var GraphicController_rmsr_Type): uint8 = 
  this.field1.MS

type
  GraphicController_rmsr_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  
type
  field1_Type* {.bycopy.} = object
    WM* {.bitsize: 2.}: uint8
    * {.bitsize: 1.}: uint8
    RM* {.bitsize: 1.}: uint8
    OE* {.bitsize: 1.}: uint8
    SRM* {.bitsize: 1.}: uint8
    _256CM* {.bitsize: 1.}: uint8
  
proc WM*(this: GraphicController_gmr_Type): uint8 = 
  this.field1.WM

proc `WM =`*(this: var GraphicController_gmr_Type): uint8 = 
  this.field1.WM

proc *(this: GraphicController_gmr_Type): uint8 = 
  this.field1.

proc ` =`*(this: var GraphicController_gmr_Type): uint8 = 
  this.field1.

proc RM*(this: GraphicController_gmr_Type): uint8 = 
  this.field1.RM

proc `RM =`*(this: var GraphicController_gmr_Type): uint8 = 
  this.field1.RM

proc OE*(this: GraphicController_gmr_Type): uint8 = 
  this.field1.OE

proc `OE =`*(this: var GraphicController_gmr_Type): uint8 = 
  this.field1.OE

proc SRM*(this: GraphicController_gmr_Type): uint8 = 
  this.field1.SRM

proc `SRM =`*(this: var GraphicController_gmr_Type): uint8 = 
  this.field1.SRM

proc _256CM*(this: GraphicController_gmr_Type): uint8 = 
  this.field1._256CM

proc `_256CM =`*(this: var GraphicController_gmr_Type): uint8 = 
  this.field1._256CM

type
  GraphicController_gmr_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  
type
  field1_Type* {.bycopy.} = object
    GM* {.bitsize: 1.}: uint8
    OE* {.bitsize: 1.}: uint8
    MM* {.bitsize: 2.}: uint8
  
proc GM*(this: GraphicController_mr_Type): uint8 = 
  this.field1.GM

proc `GM =`*(this: var GraphicController_mr_Type): uint8 = 
  this.field1.GM

proc OE*(this: GraphicController_mr_Type): uint8 = 
  this.field1.OE

proc `OE =`*(this: var GraphicController_mr_Type): uint8 = 
  this.field1.OE

proc MM*(this: GraphicController_mr_Type): uint8 = 
  this.field1.MM

proc `MM =`*(this: var GraphicController_mr_Type): uint8 = 
  this.field1.MM

type
  GraphicController_mr_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  
type
  field1_Type* {.bycopy.} = object
    INDX* {.bitsize: 5.}: uint8
    IPAS* {.bitsize: 1.}: uint8
  
proc INDX*(this: Attribute_acar_Type): uint8 = 
  this.field1.INDX

proc `INDX =`*(this: var Attribute_acar_Type): uint8 = 
  this.field1.INDX

proc IPAS*(this: Attribute_acar_Type): uint8 = 
  this.field1.IPAS

proc `IPAS =`*(this: var Attribute_acar_Type): uint8 = 
  this.field1.IPAS

type
  Attribute_acar_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  
type
  field1_Type* {.bycopy.} = object
    P0* {.bitsize: 1.}: uint8
    P1* {.bitsize: 1.}: uint8
    P2* {.bitsize: 1.}: uint8
    P3* {.bitsize: 1.}: uint8
    P4* {.bitsize: 1.}: uint8
    P5* {.bitsize: 1.}: uint8
  
proc P0*(this: Attribute_field2_Type): uint8 = 
  this.field1.P0

proc `P0 =`*(this: var Attribute_field2_Type): uint8 = 
  this.field1.P0

proc P1*(this: Attribute_field2_Type): uint8 = 
  this.field1.P1

proc `P1 =`*(this: var Attribute_field2_Type): uint8 = 
  this.field1.P1

proc P2*(this: Attribute_field2_Type): uint8 = 
  this.field1.P2

proc `P2 =`*(this: var Attribute_field2_Type): uint8 = 
  this.field1.P2

proc P3*(this: Attribute_field2_Type): uint8 = 
  this.field1.P3

proc `P3 =`*(this: var Attribute_field2_Type): uint8 = 
  this.field1.P3

proc P4*(this: Attribute_field2_Type): uint8 = 
  this.field1.P4

proc `P4 =`*(this: var Attribute_field2_Type): uint8 = 
  this.field1.P4

proc P5*(this: Attribute_field2_Type): uint8 = 
  this.field1.P5

proc `P5 =`*(this: var Attribute_field2_Type): uint8 = 
  this.field1.P5

type
  Attribute_field2_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  
proc raw*(this: Attribute): uint8 = 
  this.field2.raw

proc `raw =`*(this: var Attribute): uint8 = 
  this.field2.raw

proc P0*(this: Attribute): uint8 = 
  this.field2.field1.P0

proc `P0 =`*(this: var Attribute): uint8 = 
  this.field2.field1.P0

proc P1*(this: Attribute): uint8 = 
  this.field2.field1.P1

proc `P1 =`*(this: var Attribute): uint8 = 
  this.field2.field1.P1

proc P2*(this: Attribute): uint8 = 
  this.field2.field1.P2

proc `P2 =`*(this: var Attribute): uint8 = 
  this.field2.field1.P2

proc P3*(this: Attribute): uint8 = 
  this.field2.field1.P3

proc `P3 =`*(this: var Attribute): uint8 = 
  this.field2.field1.P3

proc P4*(this: Attribute): uint8 = 
  this.field2.field1.P4

proc `P4 =`*(this: var Attribute): uint8 = 
  this.field2.field1.P4

proc P5*(this: Attribute): uint8 = 
  this.field2.field1.P5

proc `P5 =`*(this: var Attribute): uint8 = 
  this.field2.field1.P5

type
  field1_Type* {.bycopy.} = object
    GAM* {.bitsize: 1.}: uint8
    ME* {.bitsize: 1.}: uint8
    ELGCC* {.bitsize: 1.}: uint8
    ELSBI* {.bitsize: 1.}: uint8
    * {.bitsize: 1.}: uint8
    PELPC* {.bitsize: 1.}: uint8
    PELW* {.bitsize: 1.}: uint8
    P54S* {.bitsize: 1.}: uint8
  
proc GAM*(this: Attribute_amcr_Type): uint8 = 
  this.field1.GAM

proc `GAM =`*(this: var Attribute_amcr_Type): uint8 = 
  this.field1.GAM

proc ME*(this: Attribute_amcr_Type): uint8 = 
  this.field1.ME

proc `ME =`*(this: var Attribute_amcr_Type): uint8 = 
  this.field1.ME

proc ELGCC*(this: Attribute_amcr_Type): uint8 = 
  this.field1.ELGCC

proc `ELGCC =`*(this: var Attribute_amcr_Type): uint8 = 
  this.field1.ELGCC

proc ELSBI*(this: Attribute_amcr_Type): uint8 = 
  this.field1.ELSBI

proc `ELSBI =`*(this: var Attribute_amcr_Type): uint8 = 
  this.field1.ELSBI

proc *(this: Attribute_amcr_Type): uint8 = 
  this.field1.

proc ` =`*(this: var Attribute_amcr_Type): uint8 = 
  this.field1.

proc PELPC*(this: Attribute_amcr_Type): uint8 = 
  this.field1.PELPC

proc `PELPC =`*(this: var Attribute_amcr_Type): uint8 = 
  this.field1.PELPC

proc PELW*(this: Attribute_amcr_Type): uint8 = 
  this.field1.PELW

proc `PELW =`*(this: var Attribute_amcr_Type): uint8 = 
  this.field1.PELW

proc P54S*(this: Attribute_amcr_Type): uint8 = 
  this.field1.P54S

proc `P54S =`*(this: var Attribute_amcr_Type): uint8 = 
  this.field1.P54S

type
  Attribute_amcr_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  
type
  field1_Type* {.bycopy.} = object
    ECP* {.bitsize: 4.}: uint8
    VSM* {.bitsize: 2.}: uint8
  
proc ECP*(this: Attribute_cper_Type): uint8 = 
  this.field1.ECP

proc `ECP =`*(this: var Attribute_cper_Type): uint8 = 
  this.field1.ECP

proc VSM*(this: Attribute_cper_Type): uint8 = 
  this.field1.VSM

proc `VSM =`*(this: var Attribute_cper_Type): uint8 = 
  this.field1.VSM

type
  Attribute_cper_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  
type
  field1_Type* {.bycopy.} = object
    HPELP* {.bitsize: 4.}: uint8
  
proc HPELP*(this: Attribute_hpelpr_Type): uint8 = 
  this.field1.HPELP

proc `HPELP =`*(this: var Attribute_hpelpr_Type): uint8 = 
  this.field1.HPELP

type
  Attribute_hpelpr_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  
type
  field1_Type* {.bycopy.} = object
    SC45* {.bitsize: 2.}: uint8
    SC67* {.bitsize: 2.}: uint8
  
proc SC45*(this: Attribute_csr_Type): uint8 = 
  this.field1.SC45

proc `SC45 =`*(this: var Attribute_csr_Type): uint8 = 
  this.field1.SC45

proc SC67*(this: Attribute_csr_Type): uint8 = 
  this.field1.SC67

proc `SC67 =`*(this: var Attribute_csr_Type): uint8 = 
  this.field1.SC67

type
  Attribute_csr_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  
type
  field1_Type* {.bycopy.} = object
    R* {.bitsize: 6.}: uint8
    G* {.bitsize: 6.}: uint8
    B* {.bitsize: 6.}: uint8
  
proc R*(this: DAC_field2_Type): uint8 = 
  this.field1.R

proc `R =`*(this: var DAC_field2_Type): uint8 = 
  this.field1.R

proc G*(this: DAC_field2_Type): uint8 = 
  this.field1.G

proc `G =`*(this: var DAC_field2_Type): uint8 = 
  this.field1.G

proc B*(this: DAC_field2_Type): uint8 = 
  this.field1.B

proc `B =`*(this: var DAC_field2_Type): uint8 = 
  this.field1.B

type
  DAC_field2_Type* {.bycopy, union.} = object
    raw*: array[3, uint8]
    field1*: field1_Type    
  
proc raw*(this: DAC): array[3, uint8] = 
  this.field2.raw

proc `raw =`*(this: var DAC): array[3, uint8] = 
  this.field2.raw

proc R*(this: DAC): uint8 = 
  this.field2.field1.R

proc `R =`*(this: var DAC): uint8 = 
  this.field2.field1.R

proc G*(this: DAC): uint8 = 
  this.field2.field1.G

proc `G =`*(this: var DAC): uint8 = 
  this.field2.field1.G

proc B*(this: DAC): uint8 = 
  this.field2.field1.B

proc `B =`*(this: var DAC): uint8 = 
  this.field2.field1.B

type
  DAC_w_par_Type* {.bycopy, union.} = object
    raw*: uint8
    index*: uint8
  
type
  DAC_r_par_Type* {.bycopy, union.} = object
    raw*: uint8
    index*: uint8
  
type
  DAC_pdr_Type* {.bycopy, union.} = object
    raw*: uint8
    color*: uint8
  
type
  field1_Type* {.bycopy.} = object
    DACstate* {.bitsize: 2.}: uint8
  
proc DACstate*(this: DAC_dacsr_Type): uint8 = 
  this.field1.DACstate

proc `DACstate =`*(this: var DAC_dacsr_Type): uint8 = 
  this.field1.DACstate

type
  DAC_dacsr_Type* {.bycopy, union.} = object
    raw*: uint8
    field1*: field1_Type
  
type
  DAC_pelmr_Type* {.bycopy, union.} = object
    raw*: uint8
    mask*: uint8
  