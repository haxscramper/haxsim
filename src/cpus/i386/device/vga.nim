## This module provides implementation of the VGA device. For extensive
## documentation on the features and fields of the various VGA registers
## please refer to http://www.osdever.net/FreeVGA/home.htm, specifically
## sections that describe various registers -
## http://www.osdever.net/FreeVGA/vga/vga.htm "Input/Output Register
## Information".

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
    ## Main VGA object
    logger*: EmuLogger
    mor*: VGAMor
    portio*: PortIO
    memio*: MemoryIO
    plane*: array[4, seq[U8]]
    refresh*: bool
    seq*: Sequencer
    crt*: CRT
    gc*: GraphicController
    attr*: Attribute
    dac*: DAC

  Sequencer* = ref object
    vga*: VGA
    portio*: PortIO
    sar*: SequencerSar
    cmr*: SequencerCmr
    mapMr*: SequencerMapMr
    cmsr*: SequencerCmsr
    memMr*: SequencerMemMr
    regs*: array[8, ptr U8]
    getFont*: ptr U8

  CRT* = ref object
    ## http://www.osdever.net/FreeVGA/vga/crtcreg.htm
    vga*: VGA
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
    regs*: array[0x19, ptr U8] ## Indexed array of CRT registers. Map to
                                  ## the different fields in `CRT` object
                                  ## itself.

  GraphicController* = ref object
    ## The Graphics Controller (Abbreviated to GC) is responsible for
    ## directing memory reads and writes to and from video memory.
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
    regs*: array[9, ptr U8]

  Attribute* = ref object
    vga*: VGA
    acar*: AttributeAcar
    ipr*: array[0x10, AttributeField2]
    amcr*: AttributeAmcr
    cper*: AttributeCper
    portio*: PortIO
    hpelpr*: AttributeHpelpr
    csr*: AttributeCsr
    regs*: array[0x15, ptr U8]

  DAC* = ref object
    vga*: VGA
    progress*: U8
    clut*: array[0x100, DACField2]
    portio*: PortIO
    wPar*: DACWPar
    rPar*: DACRPar
    pdr*: DACPdr
    dacsr*: DACDacsr
    pelmr*: DACPelmr

  VGAMor* = object
    ## "Miscelaneous Output Registers". Read at `0x3CC`, write at `0x3C2`.
    ## http://www.osdever.net/FreeVGA/vga/extreg.htm#3CCR3C2W
    IO* {.bitsize: 1.}: U8 ## This bit selects the CRT controller
    ## addresses. When set to 0, this bit sets the CRT controller addresses
    ## to 0x03Bx and the address for the Input Status Register 1 to 0x03BA
    ## for compatibility withthe monochrome adapter. When set to 1, this
    ## bit sets CRT controller addresses to 0x03Dx and the Input Status
    ## Register 1 address to 0x03DA for compatibility with the
    ## color/graphics adapter. The Write addresses to the Feature Control
    ## register are affected in the same manner.
    ER* {.bitsize: 1.}: U8 ## "Controls system access to the display buffer.
    ## - `= 0` disables address decode for the display buffer from the system
    ## - `= 1` enables address decode for the display buffer from the system"
    CLK0* {.bitsize: 1.}: U8 ## Clock speed selector. Unused in this emulator
    CLK1* {.bitsize: 1.}: U8 ## Second clock speed selector, also unused
    field4* {.bitsize: 1.}: U8 ## Unused filler field
    PS* {.bitsize: 1.}: U8 ## Which memory page to select - low or high
    HSP* {.bitsize: 1.}: U8 ## Horizontal sync polarity, unused in the emulator
    VSA* {.bitsize: 1.}: U8 ## Vertical sync polarity, unused in the emulator.

  SequencerSar* = object
    INDX* {.bitsize: 3.}: U8

  SequencerCmr* = object
    f89DC* {.bitsize: 1.}: U8
    field1* {.bitsize: 1.}: U8
    SL* {.bitsize: 1.}: U8
    DC* {.bitsize: 1.}: U8
    S4* {.bitsize: 1.}: U8
    SO* {.bitsize: 1.}: U8

  SequencerMapMrField1* = object

  SequencerMapMr* = object
    MAP0E* {.bitsize: 1.}: U8
    MAP1E* {.bitsize: 1.}: U8
    MAP2E* {.bitsize: 1.}: U8
    MAP3E* {.bitsize: 1.}: U8

  SequencerCmsrField1* = object
    CMB* {.bitsize: 2.}: U8
    CMA* {.bitsize: 2.}: U8
    CMBM* {.bitsize: 1.}: U8
    CMAM* {.bitsize: 1.}: U8

  SequencerCmsr* {.union.} = object
    raw*: U8
    field1*: SequencerCmsrField1

  SequencerMemMrField1* = object
    field0* {.bitsize: 1.}: U8
    EM* {.bitsize: 1.}: U8
    OE* {.bitsize: 1.}: U8
    C4* {.bitsize: 1.}: U8

  SequencerMemMr* {.union.} = object
    raw*: U8
    field1*: SequencerMemMrField1

  CRTCrtcarField1* = object
    INDX* {.bitsize: 5.}: U8

  CRTCrtcar* {.union.} = object
    raw*: U8
    field1*: CRTCrtcarField1

  CRTHtr* {.union.} = object
    ## Horizontal total register.
    raw*: U8
    HT*: U8

  CRTHdeer* {.union.} = object
    ## "Horizontal display end register", index `0x1`.
    raw*: U8
    HDEE*: U8

  CRTShbr* {.union.} = object
    ## "Start horizontal blanking", index `0x2`
    raw*: U8
    SHB*: U8

  CRTEhbrField1* = object
    EB* {.bitsize: 5.}: U8
    DESC* {.bitsize: 2.}: U8

  CRTMslr* = object
    ## "Maximum Scan Line Register", index 0x09
    MSL* {.bitsize: 5.}: U8 ## In text modes, this field is programmed with
    ## the character height - 1 (scan line numbers are zero based.) In
    ## graphics modes, a non-zero value in this field will cause each scan
    ## line to be repeated by the value of this field + 1.
    SVB9* {.bitsize: 1.}: U8
    LC9* {.bitsize: 1.}: U8
    LC* {.bitsize: 1.}: U8

  CRTCsrField1* = object
    RSCB* {.bitsize: 5.}: U8
    CO* {.bitsize: 1.}: U8

  CRTCsr* {.union.} = object
    raw*: U8
    field1*: CRTCsrField1

  CRTCerField1* = object
    RSCE* {.bitsize: 5.}: U8
    CSC* {.bitsize: 2.}: U8

  CRTCer* {.union.} = object
    raw*: U8
    field1*: CRTCerField1

  CRTSahr* {.union.} = object
    raw*: U8
    HBSA*: U8

  CRTSalr* {.union.} = object
    raw*: U8
    LBSA*: U8

  CRTClhr* {.union.} = object
    raw*: U8
    HBCL*: U8

  CRTCllr* {.union.} = object
    raw*: U8
    LBCL*: U8

  CRTVdeer* {.union.} = object
    raw*: U8
    VDEE*: U8

  CRTOfsr* {.union.} = object
    raw*: U8
    LLWS*: U8

  CRTCrtmcrField1* = object
    CMS0* {.bitsize: 1.}: U8
    SRSC* {.bitsize: 1.}: U8
    HRSX* {.bitsize: 1.}: U8
    C2* {.bitsize: 1.}: U8
    field4* {.bitsize: 1.}: U8
    AW* {.bitsize: 1.}: U8
    WBM* {.bitsize: 1.}: U8
    HR* {.bitsize: 1.}: U8

  GraphicControllerGcar* = object
    INDX* {.bitsize: 4.}: U8

  CRTCrtmcr* {.union.} = object
    raw*: U8
    field1*: CRTCrtmcrField1

  GraphicControllerSr* = object
    ## "Set/Reset Register", index `0x00`
    SRM0* {.bitsize: 1.}: U8
    SRM1* {.bitsize: 1.}: U8
    SRM2* {.bitsize: 1.}: U8
    SRM3* {.bitsize: 1.}: U8

  GraphicControllerEsr* = object
    ## "Enable Set/Reset Register", index `0x01`
    ESRM0* {.bitsize: 1.}: U8
    ESRM1* {.bitsize: 1.}: U8
    ESRM2* {.bitsize: 1.}: U8
    ESRM3* {.bitsize: 1.}: U8

  GraphicControllerCcr* = object
    ## "Color Compare Register", index `0x02`
    CCM0* {.bitsize: 1.}: U8
    CCM1* {.bitsize: 1.}: U8
    CCM2* {.bitsize: 1.}: U8
    CCM3* {.bitsize: 1.}: U8

  GraphicControllerDrr* = object
    ## "Data Rotate Register", index `0x03`
    RC* {.bitsize: 3.}: U8
    FS* {.bitsize: 2.}: U8

  GraphicControllerRmsr* = object
    ## "Read Map Select Register", index `0x04`
    MS* {.bitsize: 2.}: U8 ## Specifies memory plane to transfer data to.
    ## Due to the arrangement of video memory, this field must be modified
    ## four times to read one or more pixels values in the planar video
    ## modes.

  GraphicControllerGmr* = object
    ## "Graphic Mode Register" - GMR
    ## http://www.osdever.net/FreeVGA/vga/graphreg.htm Index `0x05`
    WM* {.bitsize: 2.}: U8 ## "Write Mode". This field selects between four
    ## write modes, simply known as Write Modes 0-3, based upon the value
    ## of this field. Currently emulator implements two of them:
    ##
    ## 1. `00b` -- Write Mode 0: In this mode, the host data is first rotated
    ##   as per the Rotate Count field, then the Enable Set/Reset mechanism
    ##   selects data from this or the Set/Reset field. Then the selected
    ##   Logical Operation is performed on the resulting data and the data
    ##   in the latch register. Then the Bit Mask field is used to select
    ##   which bits come from the resulting data and which come from the
    ##   latch register. Finally, only the bit planes enabled by the Memory
    ##   Plane Write Enable field are written to memory.
    ##
    ## 2. `01b` -- Write Mode 1: In this mode, data is transferred directly
    ##   from the 32 bit latch register to display memory, affected only by
    ##   the Memory Plane Write Enable field. The host data is not used in
    ##   this mode.

    pad1* {.bitsize: 1.}: U8
    RM* {.bitsize: 1.}: U8 ## "Read Mode". Unused in the emulator for now
    OE* {.bitsize: 1.}: U8 ## Host "Odd/Even" memory read addressing
    ## enable. When set to 1, this bit selects the odd/even addressing
    ## mode.
    SRM* {.bitsize: 1.}: U8 ## "Shift Register Interleave Mode"
    f256CM* {.bitsize: 1.}: U8 ## 256-color-mode. "When set to 0, this bit
    ## allows bit 5 to control the loading of the shift registers. When set
    ## to 1, this bit causes the shift registers to be loaded in a manner
    ## that supports the 256-color mode."

  CRTEhbr* {.union.} = object
    raw*: U8
    field1*: CRTEhbrField1

  GraphicControllerMr* = object
    ## "Miscellaneous Graphics Register" Index 06h.,
    GM* {.bitsize: 1.}: U8 ##  "This bit controls alphanumeric mode
    ## addressing. When set to 1, this bit selects graphics modes, which
    ## also disables the character generator latches."
    OE* {.bitsize: 1.}: U8 ## Odd/Even Enable
    MM* {.bitsize: 2.}: U8 ## "Memory Map" register

  AttributeAcar* = object
    INDX* {.bitsize: 5.}: U8
    IPAS* {.bitsize: 1.}: U8

  AttributeField2* = object
    P0* {.bitsize: 1.}: U8
    P1* {.bitsize: 1.}: U8
    P2* {.bitsize: 1.}: U8
    P3* {.bitsize: 1.}: U8
    P4* {.bitsize: 1.}: U8
    P5* {.bitsize: 1.}: U8

  AttributeAmcrField1* = object
    GAM* {.bitsize: 1.}: U8
    ME* {.bitsize: 1.}: U8
    ELGCC* {.bitsize: 1.}: U8
    ELSBI* {.bitsize: 1.}: U8
    field4* {.bitsize: 1.}: U8
    PELPC* {.bitsize: 1.}: U8
    PELW* {.bitsize: 1.}: U8
    P54S* {.bitsize: 1.}: U8

  AttributeAmcr* {.union.} = object
    raw*: U8
    field1*: AttributeAmcrField1

  AttributeCperField1* = object
    ECP* {.bitsize: 4.}: U8
    VSM* {.bitsize: 2.}: U8

  AttributeCper* {.union.} = object
    raw*: U8
    field1*: AttributeCperField1

  AttributeHpelprField1* = object
    HPELP* {.bitsize: 4.}: U8

  AttributeHpelpr* {.union.} = object
    raw*: U8
    field1*: AttributeHpelprField1

  AttributeCsrField1* = object
    SC45* {.bitsize: 2.}: U8
    SC67* {.bitsize: 2.}: U8

  AttributeCsr* {.union.} = object
    raw*: U8
    field1*: AttributeCsrField1

  DACField2Field1* = object
    R* {.bitsize: 6.}: U8
    G* {.bitsize: 6.}: U8
    B* {.bitsize: 6.}: U8

  DACField2* {.union.} = object
    raw*: array[3, U8]
    field1*: DACField2Field1

  DACWPar* {.union.} = object
    raw*: U8
    index*: U8

  DACRPar* {.union.} = object
    raw*: U8
    index*: U8

  DACPdr* {.union.} = object
    raw*: U8
    color*: U8

  DACDacsrField1* = object
    DACstate* {.bitsize: 2.}: U8

  DACDacsr* {.union.} = object
    raw*: U8
    field1*: DACDacsrField1

  DACPelmr* {.union.} = object
    raw*: U8
    mask*: U8


func logger*(s: Sequencer): EmuLogger = s.vga.logger
func logger*(s: GraphicController): EmuLogger = s.vga.logger

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

proc read*(this: var Sequencer, offset: U32): U8

proc CMB*(this: SequencerCmsr): U8 = this.field1.CMB
proc `CMB=`*(this: var SequencerCmsr, value: U8) = this.field1.CMB = value
proc CMA*(this: SequencerCmsr): U8 = this.field1.CMA
proc `CMA=`*(this: var SequencerCmsr, value: U8) = this.field1.CMA = value
proc CMBM*(this: SequencerCmsr): U8 = this.field1.CMBM
proc `CMBM=`*(this: var SequencerCmsr, value: U8) = this.field1.CMBM = value
proc CMAM*(this: SequencerCmsr): U8 = this.field1.CMAM
proc `CMAM=`*(this: var SequencerCmsr, value: U8) = this.field1.CMAM = value
proc EM*(this: SequencerMemMr): U8 = this.field1.EM
proc `EM=`*(this: var SequencerMemMr, value: U8) = this.field1.EM = value
proc OE*(this: SequencerMemMr): U8 = this.field1.OE
proc `OE=`*(this: var SequencerMemMr, value: U8) = this.field1.OE = value
proc C4*(this: SequencerMemMr): U8 = this.field1.C4
proc `C4=`*(this: var SequencerMemMr, value: U8) = this.field1.C4 = value
proc INDX*(this: CRTCrtcar): U8 = this.field1.INDX
proc `INDX=`*(this: var CRTCrtcar, value: U8) = this.field1.INDX = value
proc EB*(this: CRTEhbr): U8 = this.field1.EB
proc `EB=`*(this: var CRTEhbr, value: U8) = this.field1.EB = value
proc DESC*(this: CRTEhbr): U8 = this.field1.DESC
proc `DESC=`*(this: var CRTEhbr, value: U8) = this.field1.DESC = value

proc RSCB*(this: CRTCsr): U8 = this.field1.RSCB
proc `RSCB=`*(this: var CRTCsr, value: U8) = this.field1.RSCB = value
proc CO*(this: CRTCsr): U8 = this.field1.CO
proc `CO=`*(this: var CRTCsr, value: U8) = this.field1.CO = value
proc RSCE*(this: CRTCer): U8 = this.field1.RSCE
proc `RSCE=`*(this: var CRTCer, value: U8) = this.field1.RSCE = value
proc CSC*(this: CRTCer): U8 = this.field1.CSC
proc `CSC=`*(this: var CRTCer, value: U8) = this.field1.CSC = value
proc CMS0*(this: CRTCrtmcr): U8 = this.field1.CMS0
proc `CMS0=`*(this: var CRTCrtmcr, value: U8) = this.field1.CMS0 = value
proc SRSC*(this: CRTCrtmcr): U8 = this.field1.SRSC
proc `SRSC=`*(this: var CRTCrtmcr, value: U8) = this.field1.SRSC = value
proc HRSX*(this: CRTCrtmcr): U8 = this.field1.HRSX
proc `HRSX=`*(this: var CRTCrtmcr, value: U8) = this.field1.HRSX = value
proc C2*(this: CRTCrtmcr): U8 = this.field1.C2
proc `C2=`*(this: var CRTCrtmcr, value: U8) = this.field1.C2 = value
proc AW*(this: CRTCrtmcr): U8 = this.field1.AW
proc `AW=`*(this: var CRTCrtmcr, value: U8) = this.field1.AW = value
proc WBM*(this: CRTCrtmcr): U8 = this.field1.WBM
proc `WBM=`*(this: var CRTCrtmcr, value: U8) = this.field1.WBM = value
proc HR*(this: CRTCrtmcr): U8 = this.field1.HR
proc `HR=`*(this: var CRTCrtmcr, value: U8) = this.field1.HR = value

proc GAM*(this: AttributeAmcr): U8 = this.field1.GAM
proc `GAM=`*(this: var AttributeAmcr, value: U8) = this.field1.GAM = value
proc ME*(this: AttributeAmcr): U8 = this.field1.ME
proc `ME=`*(this: var AttributeAmcr, value: U8) = this.field1.ME = value
proc ELGCC*(this: AttributeAmcr): U8 = this.field1.ELGCC
proc `ELGCC=`*(this: var AttributeAmcr, value: U8) = this.field1.ELGCC = value
proc ELSBI*(this: AttributeAmcr): U8 = this.field1.ELSBI
proc `ELSBI=`*(this: var AttributeAmcr, value: U8) = this.field1.ELSBI = value
proc PELPC*(this: AttributeAmcr): U8 = this.field1.PELPC
proc `PELPC=`*(this: var AttributeAmcr, value: U8) = this.field1.PELPC = value
proc PELW*(this: AttributeAmcr): U8 = this.field1.PELW
proc `PELW=`*(this: var AttributeAmcr, value: U8) = this.field1.PELW = value
proc P54S*(this: AttributeAmcr): U8 = this.field1.P54S
proc `P54S=`*(this: var AttributeAmcr, value: U8) = this.field1.P54S = value
proc ECP*(this: AttributeCper): U8 = this.field1.ECP
proc `ECP=`*(this: var AttributeCper, value: U8) = this.field1.ECP = value
proc VSM*(this: AttributeCper): U8 = this.field1.VSM
proc `VSM=`*(this: var AttributeCper, value: U8) = this.field1.VSM = value
proc HPELP*(this: AttributeHpelpr): U8 = this.field1.HPELP
proc `HPELP=`*(this: var AttributeHpelpr, value: U8) = this.field1.HPELP = value
proc SC45*(this: AttributeCsr): U8 = this.field1.SC45
proc `SC45=`*(this: var AttributeCsr, value: U8) = this.field1.SC45 = value
proc SC67*(this: AttributeCsr): U8 = this.field1.SC67
proc `SC67=`*(this: var AttributeCsr, value: U8) = this.field1.SC67 = value
proc R*(this: DACField2): U8 = this.field1.R
proc `R=`*(this: var DACField2, value: U8) = this.field1.R = value
proc G*(this: DACField2): U8 = this.field1.G
proc `G=`*(this: var DACField2, value: U8) = this.field1.G = value
proc B*(this: DACField2): U8 = this.field1.B
proc `B=`*(this: var DACField2, value: U8) = this.field1.B = value
proc DACstate*(this: DACDacsr): U8 = this.field1.DACstate
proc `DACstate=`*(this: var DACDacsr, value: U8) = this.field1.DACstate = value

template chkRegidx*(this, n: untyped): untyped {.dirty.} =
  if int(n) > sizeof(this.regs):
    ERROR("register index out of bound", n)

  if not(toBool(this.regs[n])):
    ERROR("not implemented")

proc getWindowsize*(this: var CRT, x: ptr U16, y: ptr U16): void =
  x[] = 8 * this.hdeer.HDEE
  y[] = 8 * this.vdeer.VDEE

proc getWindowsize*(this: var VGA, x: ptr U16, y: ptr U16): void =
  this.crt.getWindowsize(x, y)

proc graphicMode*(this: var GraphicController): gmodeT =
  if this.mr.GM.toBool():
    if this.gmr.f256CM.toBool():
      return MODEGRAPHIC256

    return MODEGRAPHIC

  return MODETEXT

proc readPlane*(this: var VGA, nplane: U8, offset: U32): U8 =
  if nplane > 3 or offset > (1 shl 16) - 1:
    ERROR("Out of Plane range")

  return this.plane[nplane][offset]

proc attrIndexGraphic*(this: var GraphicController, n: U32): U8 =
  return this.vga.readPlane(2, n)

proc getFont*(this: var Sequencer, att: U8): ptr U8 =
  var v: U8
  var fontOfst: U16 = 0
  if toBool(att and 0x8):
    v = (this.cmsr.CMAM shl 2) + this.cmsr.CMA
  else:
    v = (this.cmsr.CMBM shl 2) + this.cmsr.CMB

  if toBool(v and 4):
    fontOfst = (v and (not(4'u8))) * 2 + 1

  else:
    fontOfst = v * 2

  if not(this.memMr.EM.toBool()):
    fontOfst = (fontOfst and (1 shl 16) - 1)

  # FIXME
  return (addr this.vga.plane[2][0]) + fontOfst


proc attrIndexText*(this: var CRT, n: U32): U8 =
  let
    # Compute column based on the display width
    x    = U16(n mod (8 * this.hdeer.HDEE))
    # Compute row
    y    = U16(n div (8 * this.hdeer.HDEE))
    idx  = (y div (this.mslr.MSL + 1) * this.hdeer.HDEE) + x div 8
    # Read character codepoint from plane zero
    chr  = this.vga.readPlane(0, U32(idx * 2))
    # Read character attributes from plane one
    att  = this.vga.readPlane(1, U32(idx * 2))

    font = getFont(this.vga.seq, att)
    bits = (font + chr * 0x10 + y mod (this.mslr.MSL + 1))[]


  if toBool((bits shr (x mod 8)) and 1):
    return att and 0x0F

  else:
    return (att and 0xF0) shr 4


proc dacIndex*(this: var Attribute, index: U8): U8 =
  var dacIdx: U8
  type
    field1 = object
      low {.bitsize: 4.}: U8
      high {.bitsize: 2.}: U8

  type
    IpData {.union.} = object
      raw: U8
      field1: field1

  proc low(this: IpData): U8 = this.field1.low
  proc `low=`(this: var IpData, value: U8) = this.field1.low = value
  proc high(this: IpData): U8 = this.field1.high
  proc `high=`(this: var IpData, value: U8) = this.field1.high = value

  let ipData = cast[IpData](this.ipr[index and 0xF])
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

proc translateRgb*(this: var DAC, index: U8): U32 =
  var rgb: U32
  rgb = U32(this.clut[index].R shl 0x02)
  rgb = U32(rgb + this.clut[index].G shl 0x0A)
  rgb = U32(rgb + this.clut[index].B shl 0x12)
  return rgb

proc in8*(this: var DAC, memAddr: U16): U8 =
  var v: U8
  case memAddr:
    of 0x3C6: return this.pelmr.raw
    of 0x3C7: return this.dacsr.raw
    of 0x3C9:
      v = this.clut[this.rPar.index].raw[postInc(this.progress)]
      if this.progress == 3:
        this.progress = 0
        postInc(this.rPar.index)

      return v

    else:
      assert false

  return U8.high()

proc out8*(this: var DAC, memAddr: U16, v: U8): void =
  case memAddr:
    of 0x3C7:
      if v > 0xFF:
        ERROR("")

      this.rPar.raw = v
      this.progress = 0
    of 0x3C8:
      if v > 0xFF:
        ERROR("")

      this.wPar.raw = v
      this.progress = 0
    of 0x3C9:
      this.clut[this.wPar.index].raw[postInc(this.progress)] = v
      if this.progress == 3:
        this.progress = 0
        postInc(this.wPar.index)

    else:
      assert false

proc initDAC*(v: VGA): DAC =
  var dac = DAC(vga: v)
  dac.portio = wrapPortIO(dac, in8, out8)
  return dac

proc rgbImage*(this: var VGA, buffer: var seq[U8], size: int): void =
  ## Fill image buffer of `size*3` with `R,G,B` value triples
  var mode: gmodeT = this.gc.graphicMode()
  var idx = 0
  for i in 0 ..< size:
    let attrIdx: U8 =
      if toBool(mode.int xor MODETEXT.int):
        this.gc.attrIndexGraphic(i.U32)

      else:
        this.crt.attrIndexText(i.U32)

    let dacIdx: U8 =
      if toBool(mode.int xor MODEGRAPHIC256.int):
        this.attr.dacIndex(attrIdx)
      else:
        attrIdx

    let rgb: U32 = this.dac.translateRgb(dacIdx)

    buffer[idx] = U8(rgb and 0xFF)
    inc idx
    buffer[idx] = U8((rgb shr 8) and 0xFF)
    inc idx
    buffer[idx] = U8((rgb shr 16) and 0xFF)
    inc idx

proc in8*(this: var VGA, memAddr: U16): U8 =
  case memAddr:
    of 0x3C2: return 0
    of 0x3C3: return 0
    of 0x3CC: return cast[U8](this.mor)
    of 0x3BA, 0x3DA: return 0
    else: discard
  return high(U8)

proc out8*(this: var VGA, memAddr: U16, v: U8): void =
  case memAddr:
    of 0x3C2: this.mor = cast[VGAMor](v)
    of 0x3C3: discard
    of 0x3BA, 0x3DA: discard
    else: discard

proc read8*(this: var VGA, offset: U32): U8 =
  return (if this.mor.ER.toBool(): this.seq.read(offset) else: 0)

proc write*(this: var GraphicController, nplane: U8, offset: U32, v: U8)

proc writePlane*(this: var Sequencer, n: U8, o: U32, v: U8) =
  this.logger.scope "Write to plane, sequencer"
  if toBool((cast[U8](this.mapMr) shr n) and 1):
    this.vga.gc.write(n, o, v)

proc writePlane*(this: var VGA, nplane: U8, offset: U32, v: U8): void =
  if nplane > 3 or offset > (1 shl 16) - 1:
    ERROR("Out of Plane range")

  this.plane[nplane][offset] = v

proc write*(this: var Sequencer, offset: U32, v: U8): void =
  this.logger.scope "Write to sequencer"
  var offset = offset
  if not(this.memMr.EM.toBool()):
    offset = (offset and (1 shl 16) - 1)

  if this.memMr.C4.toBool():
    this.writePlane(U8(offset and 3), offset and (not(3'u32)), v)

  else:
    if this.memMr.OE.toBool():
      for i in 0'u8 ..< 4'u8:
        this.writePlane(i, offset, v)

    else:
      var nplane: U8 = U8(offset and 1)
      this.writePlane(nplane, offset, v)
      this.writePlane(nplane + 2, offset, v)


proc write8*(this: var VGA, offset: U32, v: U8): void =
  this.logger.scope "Write 8 to VGA"
  var count {.global.}: int = 0
  if this.mor.ER.toBool():
    this.seq.write(offset, v)
    if not(toBool(postInc(count) mod 0x10)):
      this.refresh = true

proc chkOffset*(this: var GraphicController, offset: ptr U32): bool =
  var size, base: U32
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

  let valid: bool = (offset[] >= base and offset[] < base + size)
  offset[] = (offset[] - base)
  return valid




proc write*(this: var GraphicController, nplane: U8, offset: U32, v: U8): void =
  this.logger.scope "Write to graphic controller"
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

proc read*(this: var GraphicController, offset: U32): U8 =
  var offset = offset
  if not(chkOffset(this, addr offset)):
    return 0

  case this.gmr.WM:
    of 0:
      if toBool(this.gmr.OE):
        var nplane: U8 = U8((this.rmsr.MS and 2) + (offset and 1))
        return this.vga.readPlane(nplane, offset and (not(1'u32)))

      else:
        return this.vga.readPlane(this.rmsr.MS, offset)

    of 1:
      discard

    else:
      discard


  return 0




proc read*(this: var Sequencer, offset: U32): U8 =
  var offset = offset
  if not(this.memMr.EM.toBool()):
    offset = (offset and (1 shl 16) - 1)

  return this.vga.gc.read(offset)




proc in8*(this: var Sequencer, memAddr: U16): U8 =
  case memAddr:
    of 0x3C4: return cast[U8](this.sar)
    of 0x3C5: return this.regs[this.sar.INDX][]
    else: return U8.high()

proc out8*(this: var Sequencer, memAddr: U16, v: U8): void =
  case memAddr:
    of 0x3C4:
      chkRegidx(this, v)
      this.sar = cast[SequencerSar](v)

    of 0x3C5:
      this.regs[this.sar.INDX][] = v

    else:
      discard


proc in8*(this: var CRT, memAddr: U16): U8 =
  case memAddr:
    of 0x3B4, 0x3D4: return this.crtcar.raw
    of 0x3B5, 0x3D5: return this.regs[this.crtcar.INDX][]
    else: return high(U8)

proc out8*(this: var CRT, memAddr: U16, v: U8): void =
  case memAddr:
    of 0x3B4, 0x3D4:
      chkRegidx(this, v)
      this.crtcar.raw = v

    of 0x3B5, 0x3D5:
      this.regs[this.crtcar.INDX][] = v

    else:
      discard

proc in8*(this: var GraphicController, memAddr: U16): U8 =
  case memAddr:
    of 0x3CE: return cast[U8](this.gcar)
    of 0x3CF: return this.regs[this.gcar.INDX][]
    else: return high(U8)

proc out8*(this: var GraphicController, memAddr: U16, v: U8): void =
  case memAddr:
    of 0x3CE:
      chkRegidx(this, v)
      this.gcar = cast[GraphicControllerGcar](v)
    of 0x3CF:
      this.regs[this.gcar.INDX][] = v

    else:
      discard

proc in8*(this: var Attribute, memAddr: U16): U8 =
  case memAddr:
    of 0x3C0: return cast[U8](this.acar)
    of 0x3C1: return this.regs[this.acar.INDX][]
    else: return high(U8)

proc out8*(this: var Attribute, memAddr: U16, v: U8): void =
  case memAddr:
    of 0x3C0:
      chkRegidx(this, v)
      this.acar = cast[AttributeAcar](v)
    of 0x3C1:
      this.regs[this.acar.INDX][] = v

    else:
      discard

proc initAttribute*(v: VGA): Attribute =
  var attr = Attribute(vga: v)
  for i in 0 ..< len(attr.regs):
    if not attr.regs[i].isNil():
      attr.regs[i][] = 0

  attr.regs = [
    0x01: pcast[U8](addr attr.ipr[0x0]),
    0x02: pcast[U8](addr attr.ipr[0x1]),
    0x03: pcast[U8](addr attr.ipr[0x2]),
    0x04: pcast[U8](addr attr.ipr[0x3]),
    0x05: pcast[U8](addr attr.ipr[0x4]),
    0x06: pcast[U8](addr attr.ipr[0x5]),
    0x07: pcast[U8](addr attr.ipr[0x6]),
    0x08: pcast[U8](addr attr.ipr[0x7]),
    0x09: pcast[U8](addr attr.ipr[0x8]),
    0x0A: pcast[U8](addr attr.ipr[0x9]),
    0x0B: pcast[U8](addr attr.ipr[0xA]),
    0x0C: pcast[U8](addr attr.ipr[0xB]),
    0x0D: pcast[U8](addr attr.ipr[0xC]),
    0x0E: pcast[U8](addr attr.ipr[0xD]),
    0x0F: pcast[U8](addr attr.ipr[0xE]),
    0x10: pcast[U8](addr attr.ipr[0xF]),
    0x11: pcast[U8](addr attr.amcr),
    0x12: nil,
    0x13: pcast[U8](addr attr.cper),
    0x14: pcast[U8](addr attr.hpelpr),
    0x15: pcast[U8](addr attr.csr)
  ]

  attr.portio = wrapPortIO(attr, in8, out8)

  return attr

proc initSequencer*(v: VGA): Sequencer =
  var se = Sequencer(vga: v)
  for i in 0 ..< len(se.regs):
    if not se.regs[i].isNil():
      se.regs[i][] = 0

  se.regs = [
    0x1: nil,
    0x2: pcast[U8](se.cmr),
    0x3: pcast[U8](se.mapMr),
    0x4: pcast[U8](se.cmsr),
    0x5: pcast[U8](se.memMr),
    0x6: nil,
    0x7: nil,
    0x8: nil
  ]

  se.portio = wrapPortIO(se, in8, out8)

  return se


proc initGraphicController*(v: VGA): GraphicController =
  var gc = GraphicController(vga: v)
  for i in 0 ..< len(gc.regs):
    if not gc.regs[i].isNil():
      gc.regs[i][] = 0

  gc.regs = [
    0x1: pcast[U8](gc.sr),
    0x2: pcast[U8](gc.esr),
    0x3: pcast[U8](gc.ccr),
    0x4: pcast[U8](gc.drr),
    0x5: pcast[U8](gc.rmsr),
    0x6: pcast[U8](gc.gmr),
    0x7: pcast[U8](gc.mr),
    0x8: nil,
    0x9: nil
  ]

  gc.portio = wrapPortIO(gc, in8, out8)

  return gc

proc initCRT*(v: VGA): CRT =
  var crt = CRT()
  crt.vga = v
  for i in 0 ..< len(crt.regs):
    if not crt.regs[i].isNil():
      crt.regs[i][] = 0

  # http://www.osdever.net/FreeVGA/vga/crtcreg.htm
  crt.regs = [
    # Index 00h -- Horizontal Total Register
    0x00: addr crt.htr.raw,
    # Index 01h -- End Horizontal Display Register
    0x01: addr crt.hdeer.raw,
    # Index 02h -- Start Horizontal Blanking Register
    0x02: addr crt.shbr.raw,
    # Index 03h -- End Horizontal Blanking Register
    0x03: addr crt.ehbr.raw,
    # Index 04h -- Start Horizontal Retrace Register
    0x04: nil,
    # Index 05h -- End Horizontal Retrace Register
    0x05: nil,
    # Index 06h -- Vertical Total Register
    0x06: nil,
    # Index 07h -- Overflow Register
    0x07: nil,
    # Index 08h -- Preset Row Scan Register
    0x08: nil,
    # Index 09h -- Maximum Scan Line Register
    0x09: pcast[U8](crt.mslr),
    # Index 0Ah -- Cursor Start Register
    0x0A: addr crt.csr.raw,
    # Index 0Bh -- Cursor End Register
    0x0B: addr crt.cer.raw,
    # Index 0Ch -- Start Address High Register
    0x0C: addr crt.sahr.raw,
    # Index 0Dh -- Start Address Low Register
    0x0D: addr crt.salr.raw,
    # Index 0Eh -- Cursor Location High Register
    0x0E: addr crt.clhr.raw,
    # Index 0Fh -- Cursor Location Low Register
    0x0F: addr crt.cllr.raw,
    # Index 10h -- Vertical Retrace Start Register
    0x10: nil,
    # Index 11h -- Vertical Retrace End Register
    0x11: nil,
    # Index 12h -- Vertical Display End Register
    0x12: addr crt.vdeer.raw,
    # Index 13h -- Offset Register
    0x13: addr crt.ofsr.raw,
    # Index 14h -- Underline Location Register
    0x14: nil,
    # Index 15h -- Start Vertical Blanking Register
    0x15: nil,
    # Index 16h -- End Vertical Blanking
    0x16: nil,
    # Index 17h -- CRTC Mode Control Register
    0x17: addr crt.crtmcr.raw,
    # Index 18h -- Line Compare Register
    0x18: nil,
  ]

  crt.portio = wrapPortIO(crt, in8, out8)

  return crt

proc initVGA*(logger: EmuLogger): VGA =
  var vga = VGA(logger: logger)

  vga.portio = wrapPortIO(vga, in8, out8)
  vga.memio = wrapMemoryIO(vga, read8, write8)

  vga.crt = initCRT(vga)
  vga.seq = initSequencer(vga)
  vga.gc = initGraphicController(vga)
  vga.dac = initDAC(vga)
  vga.attr = initAttribute(vga)

  for i in 0 ..< 4:
    vga.plane[i] = newSeqWith(1 shl 16, 0'u8)

  return vga
