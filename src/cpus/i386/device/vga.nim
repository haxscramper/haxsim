import common
import hmisc/wrappers/wraphelp
import dev_io

import std/sequtils

template r*(reg: untyped): untyped {.dirty.} =
  (addr reg.raw)

type
  gmodeT* {.size: sizeof(cint).} = enum
    MODETEXT
    MODEGRAPHIC
    MODEGRAPHIC256

  VGA* = ref object
    mor*: VGAMor
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
    sar*: SequencerSar
    cmr*: SequencerCmr
    mapMr*: SequencerMapMr
    cmsr*: SequencerCmsr
    memMr*: SequencerMemMr
    regs*: array[8, ptr uint8]
    getFont*: ptr uint8

  CRT* = object
    vga*: ptr VGA
    portio*: PortIO
    crtcar*: CRTCrtcar
    htr*: CRTHtr
    hdeer*: CRTHdeer
    shbr*: CRTShbr
    ehbr*: CRTEhbr
    mslr*: CRTMslr
    csr*: CRTCsr
    cer*: CRTCer
    sahr*: CRTSahr
    salr*: CRTSalr
    clhr*: CRTClhr
    cllr*: CRTCllr
    vdeer*: CRTVdeer
    ofsr*: CRTOfsr
    crtmcr*: CRTCrtmcr
    regs*: array[25, ptr uint8]

  GraphicController* = object
    vga*: VGA
    portio*: PortIO
    gcar*: GraphicControllerGcar
    sr*: GraphicControllerSr
    esr*: GraphicControllerEsr
    ccr*: GraphicControllerCcr
    drr*: GraphicControllerDrr
    rmsr*: GraphicControllerRmsr
    gmr*: GraphicControllerGmr
    mr*: GraphicControllerMr
    regs*: array[9, ptr uint8]

  Attribute* = object
    vga*: VGA
    acar*: AttributeAcar
    ipr*: array[0x10, AttributeField2]
    amcr*: AttributeAmcr
    cper*: AttributeCper
    portio*: PortIO
    hpelpr*: AttributeHpelpr
    csr*: AttributeCsr
    regs*: array[21, ptr uint8]

  DAC* = object
    vga*: VGA
    progress*: uint8
    clut*: array[0x100, DACField2]
    portio*: PortIO
    wPar*: DACWPar
    rPar*: DACRPar
    pdr*: DACPdr
    dacsr*: DACDacsr
    pelmr*: DACPelmr

  VGAMorField1* = object
    IO* {.bitsize: 1.}: uint8
    ER* {.bitsize: 1.}: uint8
    CLK0* {.bitsize: 1.}: uint8
    CLK1* {.bitsize: 1.}: uint8
    field4* {.bitsize: 1.}: uint8
    PS* {.bitsize: 1.}: uint8
    HSP* {.bitsize: 1.}: uint8
    VSA* {.bitsize: 1.}: uint8

  VGAMor* {.union.} = object
    raw*: uint8
    field1*: VGAMorField1

  SequencerSarField1* = object
    INDX* {.bitsize: 3.}: uint8

  SequencerSar* {.union.} = object
    raw*: uint8
    field1*: SequencerSarField1

  SequencerCmrField1* = object
    f89DC* {.bitsize: 1.}: uint8
    field1* {.bitsize: 1.}: uint8
    SL* {.bitsize: 1.}: uint8
    DC* {.bitsize: 1.}: uint8
    S4* {.bitsize: 1.}: uint8
    SO* {.bitsize: 1.}: uint8

  SequencerCmr* {.union.} = object
    raw*: uint8
    field1*: SequencerCmrField1

  SequencerMapMrField1* = object
    MAP0E* {.bitsize: 1.}: uint8
    MAP1E* {.bitsize: 1.}: uint8
    MAP2E* {.bitsize: 1.}: uint8
    MAP3E* {.bitsize: 1.}: uint8

  SequencerMapMr* {.union.} = object
    raw*: uint8
    field1*: SequencerMapMrField1

  SequencerCmsrField1* = object
    CMB* {.bitsize: 2.}: uint8
    CMA* {.bitsize: 2.}: uint8
    CMBM* {.bitsize: 1.}: uint8
    CMAM* {.bitsize: 1.}: uint8

  SequencerCmsr* {.union.} = object
    raw*: uint8
    field1*: SequencerCmsrField1

  SequencerMemMrField1* = object
    field0* {.bitsize: 1.}: uint8
    EM* {.bitsize: 1.}: uint8
    OE* {.bitsize: 1.}: uint8
    C4* {.bitsize: 1.}: uint8

  SequencerMemMr* {.union.} = object
    raw*: uint8
    field1*: SequencerMemMrField1

  CRTCrtcarField1* = object
    INDX* {.bitsize: 5.}: uint8

  CRTCrtcar* {.union.} = object
    raw*: uint8
    field1*: CRTCrtcarField1

  CRTHtr* {.union.} = object
    raw*: uint8
    HT*: uint8

  CRTHdeer* {.union.} = object
    raw*: uint8
    HDEE*: uint8

  CRTShbr* {.union.} = object
    raw*: uint8
    SHB*: uint8

  CRTEhbrField1* = object
    EB* {.bitsize: 5.}: uint8
    DESC* {.bitsize: 2.}: uint8

  CRTMslrField1* = object
    MSL* {.bitsize: 5.}: uint8
    SVB9* {.bitsize: 1.}: uint8
    LC9* {.bitsize: 1.}: uint8
    LC* {.bitsize: 1.}: uint8

  CRTMslr* {.union.} = object
    raw*: uint8
    field1*: CRTMslrField1

  CRTCsrField1* = object
    RSCB* {.bitsize: 5.}: uint8
    CO* {.bitsize: 1.}: uint8

  CRTCsr* {.union.} = object
    raw*: uint8
    field1*: CRTCsrField1

  CRTCerField1* = object
    RSCE* {.bitsize: 5.}: uint8
    CSC* {.bitsize: 2.}: uint8

  CRTCer* {.union.} = object
    raw*: uint8
    field1*: CRTCerField1

  CRTSahr* {.union.} = object
    raw*: uint8
    HBSA*: uint8

  CRTSalr* {.union.} = object
    raw*: uint8
    LBSA*: uint8

  CRTClhr* {.union.} = object
    raw*: uint8
    HBCL*: uint8

  CRTCllr* {.union.} = object
    raw*: uint8
    LBCL*: uint8

  CRTVdeer* {.union.} = object
    raw*: uint8
    VDEE*: uint8

  CRTOfsr* {.union.} = object
    raw*: uint8
    LLWS*: uint8

  CRTCrtmcrField1* = object
    CMS0* {.bitsize: 1.}: uint8
    SRSC* {.bitsize: 1.}: uint8
    HRSX* {.bitsize: 1.}: uint8
    C2* {.bitsize: 1.}: uint8
    field4* {.bitsize: 1.}: uint8
    AW* {.bitsize: 1.}: uint8
    WBM* {.bitsize: 1.}: uint8
    HR* {.bitsize: 1.}: uint8

  GraphicControllerGcar* {.union.} = object
    raw*: uint8
    field1*: GraphicControllerGcarField1

  GraphicControllerSrField1* = object
    SRM0* {.bitsize: 1.}: uint8
    SRM1* {.bitsize: 1.}: uint8
    SRM2* {.bitsize: 1.}: uint8
    SRM3* {.bitsize: 1.}: uint8

  CRTCrtmcr* {.union.} = object
    raw*: uint8
    field1*: CRTCrtmcrField1

  GraphicControllerGcarField1* = object
    INDX* {.bitsize: 4.}: uint8

  GraphicControllerSr* {.union.} = object
    raw*: uint8
    field1*: GraphicControllerSrField1

  GraphicControllerEsrField1* = object
    ESRM0* {.bitsize: 1.}: uint8
    ESRM1* {.bitsize: 1.}: uint8
    ESRM2* {.bitsize: 1.}: uint8
    ESRM3* {.bitsize: 1.}: uint8

  GraphicControllerEsr* {.union.} = object
    raw*: uint8
    field1*: GraphicControllerEsrField1

  GraphicControllerCcrField1* = object
    CCM0* {.bitsize: 1.}: uint8
    CCM1* {.bitsize: 1.}: uint8
    CCM2* {.bitsize: 1.}: uint8
    CCM3* {.bitsize: 1.}: uint8

  GraphicControllerCcr* {.union.} = object
    raw*: uint8
    field1*: GraphicControllerCcrField1

  GraphicControllerDrrField1* = object
    RC* {.bitsize: 3.}: uint8
    FS* {.bitsize: 2.}: uint8

  GraphicControllerDrr* {.union.} = object
    raw*: uint8
    field1*: GraphicControllerDrrField1

  GraphicControllerRmsrField1* = object
    MS* {.bitsize: 2.}: uint8

  GraphicControllerRmsr* {.union.} = object
    raw*: uint8
    field1*: GraphicControllerRmsrField1

  GraphicControllerGmrField1* = object
    WM* {.bitsize: 2.}: uint8
    field1* {.bitsize: 1.}: uint8
    RM* {.bitsize: 1.}: uint8
    OE* {.bitsize: 1.}: uint8
    SRM* {.bitsize: 1.}: uint8
    f256CM* {.bitsize: 1.}: uint8

  GraphicControllerGmr* {.union.} = object
    raw*: uint8
    field1*: GraphicControllerGmrField1

  GraphicControllerMrField1* = object
    GM* {.bitsize: 1.}: uint8
    OE* {.bitsize: 1.}: uint8
    MM* {.bitsize: 2.}: uint8

  CRTEhbr* {.union.} = object
    raw*: uint8
    field1*: CRTEhbrField1

  GraphicControllerMr* {.union.} = object
    raw*: uint8
    field1*: GraphicControllerMrField1

  AttributeAcarField1* = object
    INDX* {.bitsize: 5.}: uint8
    IPAS* {.bitsize: 1.}: uint8

  AttributeAcar* {.union.} = object
    raw*: uint8
    field1*: AttributeAcarField1

  AttributeField2Field1* = object
    P0* {.bitsize: 1.}: uint8
    P1* {.bitsize: 1.}: uint8
    P2* {.bitsize: 1.}: uint8
    P3* {.bitsize: 1.}: uint8
    P4* {.bitsize: 1.}: uint8
    P5* {.bitsize: 1.}: uint8

  AttributeField2* {.union.} = object
    raw*: uint8
    field1*: AttributeField2Field1

  AttributeAmcrField1* = object
    GAM* {.bitsize: 1.}: uint8
    ME* {.bitsize: 1.}: uint8
    ELGCC* {.bitsize: 1.}: uint8
    ELSBI* {.bitsize: 1.}: uint8
    field4* {.bitsize: 1.}: uint8
    PELPC* {.bitsize: 1.}: uint8
    PELW* {.bitsize: 1.}: uint8
    P54S* {.bitsize: 1.}: uint8

  AttributeAmcr* {.union.} = object
    raw*: uint8
    field1*: AttributeAmcrField1

  AttributeCperField1* = object
    ECP* {.bitsize: 4.}: uint8
    VSM* {.bitsize: 2.}: uint8

  AttributeCper* {.union.} = object
    raw*: uint8
    field1*: AttributeCperField1

  AttributeHpelprField1* = object
    HPELP* {.bitsize: 4.}: uint8

  AttributeHpelpr* {.union.} = object
    raw*: uint8
    field1*: AttributeHpelprField1

  AttributeCsrField1* = object
    SC45* {.bitsize: 2.}: uint8
    SC67* {.bitsize: 2.}: uint8

  AttributeCsr* {.union.} = object
    raw*: uint8
    field1*: AttributeCsrField1

  DACField2Field1* = object
    R* {.bitsize: 6.}: uint8
    G* {.bitsize: 6.}: uint8
    B* {.bitsize: 6.}: uint8

  DACField2* {.union.} = object
    raw*: array[3, uint8]
    field1*: DACField2Field1

  DACWPar* {.union.} = object
    raw*: uint8
    index*: uint8

  DACRPar* {.union.} = object
    raw*: uint8
    index*: uint8

  DACPdr* {.union.} = object
    raw*: uint8
    color*: uint8

  DACDacsrField1* = object
    DACstate* {.bitsize: 2.}: uint8

  DACDacsr* {.union.} = object
    raw*: uint8
    field1*: DACDacsrField1

  DACPelmr* {.union.} = object
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

proc needRefresh*(this: var VGA): bool =
  var v: bool = this.refresh
  this.refresh = false
  return v

proc getDac*(this: var VGA): ptr DAC =
  return addr this.dac

proc getAttr*(this: var VGA): ptr Attribute =
  return addr this.attr

proc getSeq*(this: var VGA): ptr Sequencer =
  return addr this.`seq`

proc getCrt*(this: var VGA): ptr CRT =
  return addr this.crt

proc getGc*(this: var VGA): ptr GraphicController =
  return addr this.gc

proc initSequencer*(v: ptr VGA): Sequencer =
  result.vga = v
  for i in 0 ..< len(result.regs):
    if not result.regs[i].isNil():
      result.regs[i][] = 0


proc read*(this: var Sequencer, offset: uint32): uint8

proc initCRT*(v: ptr VGA): CRT =
  result.vga = v
  for i in 0 ..< len(result.regs):
    if not result.regs[i].isNil():
      result.regs[i][] = 0


proc initGraphicController*(v: VGA): GraphicController =
  result.vga = v
  for i in 0 ..< len(result.regs):
    if not result.regs[i].isNil():
      result.regs[i][] = 0

proc initAttribute*(v: VGA): Attribute =
  result.vga = v
  for i in 0 ..< len(result.regs):
    if not result.regs[i].isNil():
      result.regs[i][] = 0

proc initDAC*(v: VGA): DAC =
  result.vga = v

proc IO*(this: VGAMor): uint8 = this.field1.IO
proc `IO=`*(this: var VGAMor, value: uint8) = this.field1.IO = value
proc ER*(this: VGAMor): uint8 = this.field1.ER
proc `ER=`*(this: var VGAMor, value: uint8) = this.field1.ER = value
proc CLK0*(this: VGAMor): uint8 = this.field1.CLK0
proc `CLK0=`*(this: var VGAMor, value: uint8) = this.field1.CLK0 = value
proc CLK1*(this: VGAMor): uint8 = this.field1.CLK1
proc `CLK1=`*(this: var VGAMor, value: uint8) = this.field1.CLK1 = value
proc PS*(this: VGAMor): uint8 = this.field1.PS
proc `PS=`*(this: var VGAMor, value: uint8) = this.field1.PS = value
proc HSP*(this: VGAMor): uint8 = this.field1.HSP
proc `HSP=`*(this: var VGAMor, value: uint8) = this.field1.HSP = value
proc VSA*(this: VGAMor): uint8 = this.field1.VSA
proc `VSA=`*(this: var VGAMor, value: uint8) = this.field1.VSA = value
proc INDX*(this: SequencerSar): uint8 = this.field1.INDX
proc `INDX=`*(this: var SequencerSar, value: uint8) = this.field1.INDX = value
proc f89DC*(this: SequencerCmr): uint8 = this.field1.f89DC
proc `f89DC=`*(this: var SequencerCmr, value: uint8) = this.field1.f89DC = value
proc SL*(this: SequencerCmr): uint8 = this.field1.SL
proc `SL=`*(this: var SequencerCmr, value: uint8) = this.field1.SL = value
proc DC*(this: SequencerCmr): uint8 = this.field1.DC
proc `DC=`*(this: var SequencerCmr, value: uint8) = this.field1.DC = value
proc S4*(this: SequencerCmr): uint8 = this.field1.S4
proc `S4=`*(this: var SequencerCmr, value: uint8) = this.field1.S4 = value
proc SO*(this: SequencerCmr): uint8 = this.field1.SO
proc `SO=`*(this: var SequencerCmr, value: uint8) = this.field1.SO = value
proc MAP0E*(this: SequencerMapMr): uint8 = this.field1.MAP0E
proc `MAP0E=`*(this: var SequencerMapMr, value: uint8) = this.field1.MAP0E = value
proc MAP1E*(this: SequencerMapMr): uint8 = this.field1.MAP1E
proc `MAP1E=`*(this: var SequencerMapMr, value: uint8) = this.field1.MAP1E = value
proc MAP2E*(this: SequencerMapMr): uint8 = this.field1.MAP2E
proc `MAP2E=`*(this: var SequencerMapMr, value: uint8) = this.field1.MAP2E = value
proc MAP3E*(this: SequencerMapMr): uint8 = this.field1.MAP3E
proc `MAP3E=`*(this: var SequencerMapMr, value: uint8) = this.field1.MAP3E = value
proc CMB*(this: SequencerCmsr): uint8 = this.field1.CMB
proc `CMB=`*(this: var SequencerCmsr, value: uint8) = this.field1.CMB = value
proc CMA*(this: SequencerCmsr): uint8 = this.field1.CMA
proc `CMA=`*(this: var SequencerCmsr, value: uint8) = this.field1.CMA = value
proc CMBM*(this: SequencerCmsr): uint8 = this.field1.CMBM
proc `CMBM=`*(this: var SequencerCmsr, value: uint8) = this.field1.CMBM = value
proc CMAM*(this: SequencerCmsr): uint8 = this.field1.CMAM
proc `CMAM=`*(this: var SequencerCmsr, value: uint8) = this.field1.CMAM = value
proc EM*(this: SequencerMemMr): uint8 = this.field1.EM
proc `EM=`*(this: var SequencerMemMr, value: uint8) = this.field1.EM = value
proc OE*(this: SequencerMemMr): uint8 = this.field1.OE
proc `OE=`*(this: var SequencerMemMr, value: uint8) = this.field1.OE = value
proc C4*(this: SequencerMemMr): uint8 = this.field1.C4
proc `C4=`*(this: var SequencerMemMr, value: uint8) = this.field1.C4 = value
proc INDX*(this: CRTCrtcar): uint8 = this.field1.INDX
proc `INDX=`*(this: var CRTCrtcar, value: uint8) = this.field1.INDX = value
proc EB*(this: CRTEhbr): uint8 = this.field1.EB
proc `EB=`*(this: var CRTEhbr, value: uint8) = this.field1.EB = value
proc DESC*(this: CRTEhbr): uint8 = this.field1.DESC
proc `DESC=`*(this: var CRTEhbr, value: uint8) = this.field1.DESC = value
proc MSL*(this: CRTMslr): uint8 = this.field1.MSL
proc `MSL=`*(this: var CRTMslr, value: uint8) = this.field1.MSL = value
proc SVB9*(this: CRTMslr): uint8 = this.field1.SVB9
proc `SVB9=`*(this: var CRTMslr, value: uint8) = this.field1.SVB9 = value
proc LC9*(this: CRTMslr): uint8 = this.field1.LC9
proc `LC9=`*(this: var CRTMslr, value: uint8) = this.field1.LC9 = value
proc LC*(this: CRTMslr): uint8 = this.field1.LC
proc `LC=`*(this: var CRTMslr, value: uint8) = this.field1.LC = value
proc RSCB*(this: CRTCsr): uint8 = this.field1.RSCB
proc `RSCB=`*(this: var CRTCsr, value: uint8) = this.field1.RSCB = value
proc CO*(this: CRTCsr): uint8 = this.field1.CO
proc `CO=`*(this: var CRTCsr, value: uint8) = this.field1.CO = value
proc RSCE*(this: CRTCer): uint8 = this.field1.RSCE
proc `RSCE=`*(this: var CRTCer, value: uint8) = this.field1.RSCE = value
proc CSC*(this: CRTCer): uint8 = this.field1.CSC
proc `CSC=`*(this: var CRTCer, value: uint8) = this.field1.CSC = value
proc CMS0*(this: CRTCrtmcr): uint8 = this.field1.CMS0
proc `CMS0=`*(this: var CRTCrtmcr, value: uint8) = this.field1.CMS0 = value
proc SRSC*(this: CRTCrtmcr): uint8 = this.field1.SRSC
proc `SRSC=`*(this: var CRTCrtmcr, value: uint8) = this.field1.SRSC = value
proc HRSX*(this: CRTCrtmcr): uint8 = this.field1.HRSX
proc `HRSX=`*(this: var CRTCrtmcr, value: uint8) = this.field1.HRSX = value
proc C2*(this: CRTCrtmcr): uint8 = this.field1.C2
proc `C2=`*(this: var CRTCrtmcr, value: uint8) = this.field1.C2 = value
proc AW*(this: CRTCrtmcr): uint8 = this.field1.AW
proc `AW=`*(this: var CRTCrtmcr, value: uint8) = this.field1.AW = value
proc WBM*(this: CRTCrtmcr): uint8 = this.field1.WBM
proc `WBM=`*(this: var CRTCrtmcr, value: uint8) = this.field1.WBM = value
proc HR*(this: CRTCrtmcr): uint8 = this.field1.HR
proc `HR=`*(this: var CRTCrtmcr, value: uint8) = this.field1.HR = value
proc INDX*(this: GraphicControllerGcar): uint8 = this.field1.INDX
proc `INDX=`*(this: var GraphicControllerGcar, value: uint8) = this.field1.INDX = value
proc SRM0*(this: GraphicControllerSr): uint8 = this.field1.SRM0
proc `SRM0=`*(this: var GraphicControllerSr, value: uint8) = this.field1.SRM0 = value
proc SRM1*(this: GraphicControllerSr): uint8 = this.field1.SRM1
proc `SRM1=`*(this: var GraphicControllerSr, value: uint8) = this.field1.SRM1 = value
proc SRM2*(this: GraphicControllerSr): uint8 = this.field1.SRM2
proc `SRM2=`*(this: var GraphicControllerSr, value: uint8) = this.field1.SRM2 = value
proc SRM3*(this: GraphicControllerSr): uint8 = this.field1.SRM3
proc `SRM3=`*(this: var GraphicControllerSr, value: uint8) = this.field1.SRM3 = value
proc ESRM0*(this: GraphicControllerEsr): uint8 = this.field1.ESRM0
proc `ESRM0=`*(this: var GraphicControllerEsr, value: uint8) = this.field1.ESRM0 = value
proc ESRM1*(this: GraphicControllerEsr): uint8 = this.field1.ESRM1
proc `ESRM1=`*(this: var GraphicControllerEsr, value: uint8) = this.field1.ESRM1 = value
proc ESRM2*(this: GraphicControllerEsr): uint8 = this.field1.ESRM2
proc `ESRM2=`*(this: var GraphicControllerEsr, value: uint8) = this.field1.ESRM2 = value
proc ESRM3*(this: GraphicControllerEsr): uint8 = this.field1.ESRM3
proc `ESRM3=`*(this: var GraphicControllerEsr, value: uint8) = this.field1.ESRM3 = value
proc CCM0*(this: GraphicControllerCcr): uint8 = this.field1.CCM0
proc `CCM0=`*(this: var GraphicControllerCcr, value: uint8) = this.field1.CCM0 = value
proc CCM1*(this: GraphicControllerCcr): uint8 = this.field1.CCM1
proc `CCM1=`*(this: var GraphicControllerCcr, value: uint8) = this.field1.CCM1 = value
proc CCM2*(this: GraphicControllerCcr): uint8 = this.field1.CCM2
proc `CCM2=`*(this: var GraphicControllerCcr, value: uint8) = this.field1.CCM2 = value
proc CCM3*(this: GraphicControllerCcr): uint8 = this.field1.CCM3
proc `CCM3=`*(this: var GraphicControllerCcr, value: uint8) = this.field1.CCM3 = value
proc RC*(this: GraphicControllerDrr): uint8 = this.field1.RC
proc `RC=`*(this: var GraphicControllerDrr, value: uint8) = this.field1.RC = value
proc FS*(this: GraphicControllerDrr): uint8 = this.field1.FS
proc `FS=`*(this: var GraphicControllerDrr, value: uint8) = this.field1.FS = value
proc MS*(this: GraphicControllerRmsr): uint8 = this.field1.MS
proc `MS=`*(this: var GraphicControllerRmsr, value: uint8) = this.field1.MS = value
proc WM*(this: GraphicControllerGmr): uint8 = this.field1.WM
proc `WM=`*(this: var GraphicControllerGmr, value: uint8) = this.field1.WM = value
proc RM*(this: GraphicControllerGmr): uint8 = this.field1.RM
proc `RM=`*(this: var GraphicControllerGmr, value: uint8) = this.field1.RM = value
proc OE*(this: GraphicControllerGmr): uint8 = this.field1.OE
proc `OE=`*(this: var GraphicControllerGmr, value: uint8) = this.field1.OE = value
proc SRM*(this: GraphicControllerGmr): uint8 = this.field1.SRM
proc `SRM=`*(this: var GraphicControllerGmr, value: uint8) = this.field1.SRM = value
proc f256CM*(this: GraphicControllerGmr): uint8 = this.field1.f256CM
proc `f256CM=`*(this: var GraphicControllerGmr, value: uint8) = this.field1.f256CM = value
proc GM*(this: GraphicControllerMr): uint8 = this.field1.GM
proc `GM=`*(this: var GraphicControllerMr, value: uint8) = this.field1.GM = value
proc OE*(this: GraphicControllerMr): uint8 = this.field1.OE
proc `OE=`*(this: var GraphicControllerMr, value: uint8) = this.field1.OE = value
proc MM*(this: GraphicControllerMr): uint8 = this.field1.MM
proc `MM=`*(this: var GraphicControllerMr, value: uint8) = this.field1.MM = value
proc INDX*(this: AttributeAcar): uint8 = this.field1.INDX
proc `INDX=`*(this: var AttributeAcar, value: uint8) = this.field1.INDX = value
proc IPAS*(this: AttributeAcar): uint8 = this.field1.IPAS
proc `IPAS=`*(this: var AttributeAcar, value: uint8) = this.field1.IPAS = value
proc P0*(this: AttributeField2): uint8 = this.field1.P0
proc `P0=`*(this: var AttributeField2, value: uint8) = this.field1.P0 = value
proc P1*(this: AttributeField2): uint8 = this.field1.P1
proc `P1=`*(this: var AttributeField2, value: uint8) = this.field1.P1 = value
proc P2*(this: AttributeField2): uint8 = this.field1.P2
proc `P2=`*(this: var AttributeField2, value: uint8) = this.field1.P2 = value
proc P3*(this: AttributeField2): uint8 = this.field1.P3
proc `P3=`*(this: var AttributeField2, value: uint8) = this.field1.P3 = value
proc P4*(this: AttributeField2): uint8 = this.field1.P4
proc `P4=`*(this: var AttributeField2, value: uint8) = this.field1.P4 = value
proc P5*(this: AttributeField2): uint8 = this.field1.P5
proc `P5=`*(this: var AttributeField2, value: uint8) = this.field1.P5 = value

# proc raw*(this: Attribute): uint8 = this.ipr.raw
# proc `raw=`*(this: var AttributeField2, value: uint8) = this.raw = value
# proc P0*(this: AttributeField2): uint8 = this.field1.P0
# proc `P0=`*(this: var AttributeField2, value: uint8) = this.field1.P0 = value
# proc P1*(this: AttributeField2): uint8 = this.field1.P1
# proc `P1=`*(this: var AttributeField2, value: uint8) = this.field1.P1 = value
# proc P2*(this: AttributeField2): uint8 = this.field1.P2
# proc `P2=`*(this: var AttributeField2, value: uint8) = this.field1.P2 = value
# proc P3*(this: AttributeField2): uint8 = this.field1.P3
# proc `P3=`*(this: var AttributeField2, value: uint8) = this.field1.P3 = value
# proc P4*(this: AttributeField2): uint8 = this.field1.P4
# proc `P4=`*(this: var AttributeField2, value: uint8) = this.field1.P4 = value
# proc P5*(this: AttributeField2): uint8 = this.field1.P5
# proc `P5=`*(this: var AttributeField2, value: uint8) = this.field1.P5 = value

proc GAM*(this: AttributeAmcr): uint8 = this.field1.GAM
proc `GAM=`*(this: var AttributeAmcr, value: uint8) = this.field1.GAM = value
proc ME*(this: AttributeAmcr): uint8 = this.field1.ME
proc `ME=`*(this: var AttributeAmcr, value: uint8) = this.field1.ME = value
proc ELGCC*(this: AttributeAmcr): uint8 = this.field1.ELGCC
proc `ELGCC=`*(this: var AttributeAmcr, value: uint8) = this.field1.ELGCC = value
proc ELSBI*(this: AttributeAmcr): uint8 = this.field1.ELSBI
proc `ELSBI=`*(this: var AttributeAmcr, value: uint8) = this.field1.ELSBI = value
proc PELPC*(this: AttributeAmcr): uint8 = this.field1.PELPC
proc `PELPC=`*(this: var AttributeAmcr, value: uint8) = this.field1.PELPC = value
proc PELW*(this: AttributeAmcr): uint8 = this.field1.PELW
proc `PELW=`*(this: var AttributeAmcr, value: uint8) = this.field1.PELW = value
proc P54S*(this: AttributeAmcr): uint8 = this.field1.P54S
proc `P54S=`*(this: var AttributeAmcr, value: uint8) = this.field1.P54S = value
proc ECP*(this: AttributeCper): uint8 = this.field1.ECP
proc `ECP=`*(this: var AttributeCper, value: uint8) = this.field1.ECP = value
proc VSM*(this: AttributeCper): uint8 = this.field1.VSM
proc `VSM=`*(this: var AttributeCper, value: uint8) = this.field1.VSM = value
proc HPELP*(this: AttributeHpelpr): uint8 = this.field1.HPELP
proc `HPELP=`*(this: var AttributeHpelpr, value: uint8) = this.field1.HPELP = value
proc SC45*(this: AttributeCsr): uint8 = this.field1.SC45
proc `SC45=`*(this: var AttributeCsr, value: uint8) = this.field1.SC45 = value
proc SC67*(this: AttributeCsr): uint8 = this.field1.SC67
proc `SC67=`*(this: var AttributeCsr, value: uint8) = this.field1.SC67 = value
proc R*(this: DACField2): uint8 = this.field1.R
proc `R=`*(this: var DACField2, value: uint8) = this.field1.R = value
proc G*(this: DACField2): uint8 = this.field1.G
proc `G=`*(this: var DACField2, value: uint8) = this.field1.G = value
proc B*(this: DACField2): uint8 = this.field1.B
proc `B=`*(this: var DACField2, value: uint8) = this.field1.B = value
# proc raw*(this: DAC): array[3, uint8] = this.field2.raw
# proc `raw=`*(this: var DAC, value: array[3, uint8]) = this.field2.raw = value
# proc R*(this: DAC): uint8 = this.field2.field1.R
# proc `R=`*(this: var DAC, value: uint8) = this.field2.field1.R = value
# proc G*(this: DAC): uint8 = this.field2.field1.G
# proc `G=`*(this: var DAC, value: uint8) = this.field2.field1.G = value
# proc B*(this: DAC): uint8 = this.field2.field1.B
# proc `B=`*(this: var DAC, value: uint8) = this.field2.field1.B = value
proc DACstate*(this: DACDacsr): uint8 = this.field1.DACstate
proc `DACstate=`*(this: var DACDacsr, value: uint8) = this.field1.DACstate = value

template chkRegidx*(this, n: untyped): untyped {.dirty.} =
  if int(n) > sizeof(this.regs):
    ERROR("register index out of bound", n)

  if not(toBool(this.regs[n])):
    ERROR("not implemented")

proc getWindowsize*(this: var CRT, x: ptr uint16, y: ptr uint16): void =
  x[] = 8 * this.hdeer.HDEE
  y[] = 8 * this.vdeer.VDEE

proc getWindowsize*(this: var VGA, x: ptr uint16, y: ptr uint16): void =
  this.crt.getWindowsize(x, y)

proc graphicMode*(this: var GraphicController): gmodeT =
  if this.mr.GM.toBool():
    if this.gmr.f256CM.toBool():
      return MODEGRAPHIC256

    return MODEGRAPHIC

  return MODETEXT

proc readPlane*(this: var VGA, nplane: uint8, offset: uint32): uint8 =
  if nplane > 3 or offset > (1 shl 16) - 1:
    ERROR("Out of Plane range")

  return this.plane[nplane][offset]

proc attrIndexGraphic*(this: var GraphicController, n: uint32): uint8 =
  return this.vga.readPlane(2, n)

proc getFont*(this: var Sequencer, att: uint8): ptr uint8 =
  var v: uint8
  var fontOfst: uint16 = 0
  v = (if toBool(att and 0x8):
        (this.cmsr.CMAM shl 2) + this.cmsr.CMA

      else:
        (this.cmsr.CMBM shl 2) + this.cmsr.CMB
      )
  fontOfst = (if toBool(v and 4):
        (v and (not(4'u8))) * 2 + 1

      else:
        v * 2
      )
  if not(this.memMr.EM.toBool()):
    fontOfst = (fontOfst and (1 shl 16) - 1)

  # FIXME
  return (addr this.vga.plane[2][0]) + fontOfst


proc attrIndexText*(this: var CRT, n: uint32): uint8 =
  var att, chr: uint8
  var font: ptr uint8
  var bits: uint8
  var y, x, idx: uint16
  x = uint16(n mod (8 * this.hdeer.HDEE))
  y = uint16(n div (8 * this.hdeer.HDEE))
  idx = y div (this.mslr.MSL + 1) * this.hdeer.HDEE + x div 8
  chr = this.vga[].readPlane(0, uint32(idx * 2))
  att = this.vga[].readPlane(1, uint32(idx * 2))
  font = getFont(this.vga.seq, att)
  bits = (font + chr * 0x10 + y mod (this.mslr.MSL + 1))[]
  return (if toBool((bits shr (x mod 8)) and 1):
            att and 0x0f

          else:
            (att and 0xf0) shr 4
          )

proc dacIndex*(this: var Attribute, index: uint8): uint8 =
  var dacIdx: uint8
  type
    field1 = object
      low {.bitsize: 4.}: uint8
      high {.bitsize: 2.}: uint8

  type
    IpData {.union.} = object
      raw: uint8
      field1: field1

  proc low(this: IpData): uint8 = this.field1.low
  proc `low=`(this: var IpData, value: uint8) = this.field1.low = value
  proc high(this: IpData): uint8 = this.field1.high
  proc `high=`(this: var IpData, value: uint8) = this.field1.high = value


  var ipData: IpData
  ipData.raw = this.ipr[index and 0xf].raw
  if toBool(this.amcr.GAM):
    dacIdx = ipData.low
    dacIdx = (dacIdx + ((if toBool(this.amcr.P54S):
              this.csr.SC45

            else:
              ipData.high
            )) shl 4)
    dacIdx = (dacIdx + this.csr.SC67 shl 6)

  else:
    dacIdx = ipData.low

  return dacIdx

proc translateRgb*(this: var DAC, index: uint8): uint32 =
  var rgb: uint32
  rgb = uint32(this.clut[index].R shl 0x02)
  rgb = uint32(rgb + this.clut[index].G shl 0x0a)
  rgb = uint32(rgb + this.clut[index].B shl 0x12)
  return rgb

proc in8*(this: var DAC, memAddr: uint16): uint8 =
  var v: uint8
  case memAddr:
    of 0x3c6: return this.pelmr.raw
    of 0x3c7: return this.dacsr.raw
    of 0x3c9:
      v = this.clut[this.rPar.index].raw[postInc(this.progress)]
      if this.progress == 3:
        this.progress = 0
        postInc(this.rPar.index)

      return v

    else:
      assert false

  return uint8.high()

proc out8*(this: var DAC, memAddr: uint16, v: uint8): void =
  case memAddr:
    of 0x3c7:
      if v > 0xff:
        ERROR("")

      this.rPar.raw = v
      this.progress = 0
    of 0x3c8:
      if v > 0xff:
        ERROR("")

      this.wPar.raw = v
      this.progress = 0
    of 0x3c9:
      this.clut[this.wPar.index].raw[postInc(this.progress)] = v
      if this.progress == 3:
        this.progress = 0
        postInc(this.wPar.index)

    else:
      assert false



proc rgbImage*(this: var VGA, buffer: ptr uint8, size: uint32): void =
  var mode: gmodeT = this.gc.graphicMode()
  for i in 0 ..< size:
    var dacIdx, attrIdx: uint8
    var rgb: uint32
    attrIdx = (if toBool(mode.int xor MODETEXT.int):
          this.gc.attrIndexGraphic(i)

        else:
          this.crt.attrIndexText(i)
        )
    dacIdx = (if toBool(mode.int xor MODEGRAPHIC256.int):
          this.attr.dacIndex(attrIdx)

        else:
          attrIdx
        )

    var buffer = buffer
    rgb = this.dac.translateRgb(dacIdx)
    inc buffer ; buffer[] = uint8(rgb and 0xff)
    inc buffer ; buffer[] = uint8((rgb shr 8) and 0xff)
    inc buffer ; buffer[] = uint8((rgb shr 16) and 0xff)

proc in8*(this: var VGA, memAddr: uint16): uint8 =
  case memAddr:
    of 0x3c2: return 0
    of 0x3c3: return 0
    of 0x3cc: return this.mor.raw
    of 0x3ba, 0x3da: return 0
    else: discard
  return high(uint8)

proc out8*(this: var VGA, memAddr: uint16, v: uint8): void =
  case memAddr:
    of 0x3c2: this.mor.raw = v
    of 0x3c3: discard
    of 0x3ba, 0x3da: discard
    else: discard

proc read8*(this: var VGA, offset: uint32): uint8 =
  return (if this.mor.ER.toBool(): this.seq.read(offset) else: 0)

proc write*(this: var GraphicController, nplane: uint8, offset: uint32, v: uint8)

proc writePlane*(this: var Sequencer, n: uint8, o: uint32, v: uint8) =
  if toBool((this.mapMr.raw shr n) and 1):
    this.vga.gc.write(n, o, v)

proc writePlane*(this: var VGA, nplane: uint8, offset: uint32, v: uint8): void =
  if nplane > 3 or offset > (1 shl 16) - 1:
    ERROR("Out of Plane range")

  this.plane[nplane][offset] = v

proc write*(this: var Sequencer, offset: uint32, v: uint8): void =
  var offset = offset
  if not(this.memMr.EM.toBool()):
    offset = (offset and (1 shl 16) - 1)

  if this.memMr.C4.toBool():
    this.writePlane(uint8(offset and 3), offset and (not(3'u32)), v)

  else:
    if this.memMr.OE.toBool():
      for i in 0'u8 ..< 4'u8:
        this.writePlane(i, offset, v)

    else:
      var nplane: uint8 = uint8(offset and 1)
      this.writePlane(nplane, offset, v)
      this.writePlane(nplane + 2, offset, v)


proc write8*(this: var VGA, offset: uint32, v: uint8): void =
  var count: cint = 0
  if this.mor.ER.toBool():
    this.seq.write(offset, v)
    if not(toBool(postInc(count) mod 0x10)):
      this.refresh = true

proc chkOffset*(this: var GraphicController, offset: ptr uint32): bool =
  var size, base: uint32
  var valid: bool
  case this.mr.MM:
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

    else:
      discard

  valid = (offset[] >= base and offset[] < base + size)
  offset[] = (offset[] - base)
  return valid




proc write*(this: var GraphicController, nplane: uint8, offset: uint32, v: uint8): void =
  var offset = offset
  if not(chkOffset(this, addr offset)):
    return

  case this.gmr.WM:
    of 0:
      var offset = offset
      if toBool(this.gmr.OE):
        offset = (offset and not(1'u32))

      this.vga.writePlane(nplane, offset, v)
    of 1: discard
    of 2: discard
    of 3: discard
    else: discard

proc read*(this: var GraphicController, offset: uint32): uint8 =
  var offset = offset
  if not(chkOffset(this, addr offset)):
    return 0

  case this.gmr.WM:
    of 0:
      if toBool(this.gmr.OE):
        var nplane: uint8 = uint8((this.rmsr.MS and 2) + (offset and 1))
        return this.vga.readPlane(nplane, offset and (not(1'u32)))

      else:
        return this.vga.readPlane(this.rmsr.MS, offset)

    of 1:
      discard

    else:
      discard


  return 0




proc read*(this: var Sequencer, offset: uint32): uint8 =
  var offset = offset
  if not(this.memMr.EM.toBool()):
    offset = (offset and (1 shl 16) - 1)

  return this.vga.gc.read(offset)




proc in8*(this: var Sequencer, memAddr: uint16): uint8 =
  case memAddr:
    of 0x3c4: return this.sar.raw
    of 0x3c5: return this.regs[this.sar.INDX][]
    else: return uint8.high()

proc out8*(this: var Sequencer, memAddr: uint16, v: uint8): void =
  case memAddr:
    of 0x3c4:
      chkRegidx(this, v)
      this.sar.raw = v

    of 0x3c5:
      this.regs[this.sar.INDX][] = v

    else:
      discard

proc in8*(this: var CRT, memAddr: uint16): uint8 =
  case memAddr:
    of 0x3b4, 0x3d4: return this.crtcar.raw
    of 0x3b5, 0x3d5: return this.regs[this.crtcar.INDX][]
    else: return high(uint8)

proc out8*(this: var CRT, memAddr: uint16, v: uint8): void =
  case memAddr:
    of 0x3b4, 0x3d4:
      chkRegidx(this, v)
      this.crtcar.raw = v

    of 0x3b5, 0x3d5:
      this.regs[this.crtcar.INDX][] = v

    else:
      discard



proc in8*(this: var GraphicController, memAddr: uint16): uint8 =
  case memAddr:
    of 0x3ce: return this.gcar.raw
    of 0x3cf: return this.regs[this.gcar.INDX][]
    else: return high(uint8)

proc out8*(this: var GraphicController, memAddr: uint16, v: uint8): void =
  case memAddr:
    of 0x3ce:
      chkRegidx(this, v)
      this.gcar.raw = v
    of 0x3cf:
      this.regs[this.gcar.INDX][] = v

    else:
      discard

proc in8*(this: var Attribute, memAddr: uint16): uint8 =
  case memAddr:
    of 0x3c0: return this.acar.raw
    of 0x3c1: return this.regs[this.acar.INDX][]
    else: return high(uint8)

proc out8*(this: var Attribute, memAddr: uint16, v: uint8): void =
  case memAddr:
    of 0x3c0:
      chkRegidx(this, v)
      this.acar.raw = v
    of 0x3c1:
      this.regs[this.acar.INDX][] = v

    else:
      discard
