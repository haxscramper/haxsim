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

const
  charWidth*: U8 = 8
  charHeight*: U8 = 8

type
  gmodeT* {.size: sizeof(cint).} = enum
    MODETEXT
    MODEGRAPHIC
    MODEGRAPHIC256

  DisplayMemory* = array[4, seq[U8]]

  VGA* = ref object
    ## Main VGA object
    logger*: EmuLogger
    mor*: VGAMor
    portio*: PortIO
    memio*: MemoryIO
    plane*: DisplayMemory
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
    ipr*: array[0x10, AttributePaletteRegister]
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

  SequencerMapMr* = object
    ## "Map Mask Register", index `0x02`
    MAP0E* {.bitsize: 1.}: U8
    MAP1E* {.bitsize: 1.}: U8
    MAP2E* {.bitsize: 1.}: U8
    MAP3E* {.bitsize: 1.}: U8

  SequencerCmsr* = object
    CMB* {.bitsize: 2.}: U8
    CMA* {.bitsize: 2.}: U8
    CMBM* {.bitsize: 1.}: U8
    CMAM* {.bitsize: 1.}: U8

  SequencerMemMr* = object
    ## "Memory Mode" register, index `0x04`
    pad {.bitsize: 1.}: U8 ## Unused
    EM* {.bitsize: 1.}: U8 ## Extended memory. When set to 1, this bit
                           ## enables the video memory from 64KB to 256KB.
    OE* {.bitsize: 1.}: U8 ## Odd/Event host memeory write addresign disable
    C4* {.bitsize: 1.}: U8 ## Chain 4 enable. "This bit controls the map
    ## selected during system read operations. When set to 0, this bit
    ## enables system addresses to sequentially access data within a bit
    ## map by using the Map Mask register. When set to 1, this bit causes
    ## the two low-order bits to select the map accessed as shown below:
    ##
    ## =====   ============
    ## A0 A1   Map Selected
    ## 0   0   0
    ## 0   1   1
    ## 1   0   2
    ## 1   1   3
    ## =====   =============

  CRTCrtcar* {.union.} = object
    INDX* {.bitsize: 5.}: U8

  CRTHtr* {.union.} = object
    ## Horizontal total register.
    HT*: U8

  CRTHdeer* {.union.} = object
    ## "Horizontal display end register", index `0x1`.
    HDEE*: U8

  CRTShbr* {.union.} = object
    ## "Start horizontal blanking", index `0x2`
    SHB*: U8

  CRTMslr* = object
    ## "Maximum Scan Line Register", index `0x09`
    MSL* {.bitsize: 5.}: U8 ## In text modes, this field is programmed with
    ## the character height - 1 (scan line numbers are zero based.) In
    ## graphics modes, a non-zero value in this field will cause each scan
    ## line to be repeated by the value of this field + 1.
    SVB9* {.bitsize: 1.}: U8
    LC9* {.bitsize: 1.}: U8
    LC* {.bitsize: 1.}: U8

  CRTCsr* = object
    RSCB* {.bitsize: 5.}: U8
    CO* {.bitsize: 1.}: U8

  CRTCer* = object
    RSCE* {.bitsize: 5.}: U8
    CSC* {.bitsize: 2.}: U8

  CRTSahr* = object
    HBSA*: U8

  CRTSalr* = object
    LBSA*: U8

  CRTClhr* = object
    HBCL*: U8

  CRTCllr* = object
    LBCL*: U8

  CRTVdeer* = object
    VDEE*: U8

  CRTOfsr* = object
    LLWS*: U8

  CRTCrtmcrField1* = object

  GraphicControllerGcar* = object
    INDX* {.bitsize: 4.}: U8

  CRTCrtmcr* = object
    CMS0* {.bitsize: 1.}: U8
    SRSC* {.bitsize: 1.}: U8
    HRSX* {.bitsize: 1.}: U8
    C2* {.bitsize: 1.}: U8
    pad {.bitsize: 1.}: U8
    AW* {.bitsize: 1.}: U8
    WBM* {.bitsize: 1.}: U8
    HR* {.bitsize: 1.}: U8

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

  CRTEhbr* = object
    EB* {.bitsize: 5.}: U8
    DESC* {.bitsize: 2.}: U8

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

  AttributePaletteRegister* = object
    ## "Attribute Palette Register".
    ##
    ## These 6-bit registers allow a dynamic mapping between the text
    ## attribute or graphic color input value and the display color on the
    ## CRT screen. When set to 1, this bit selects the appropriate color.
    ##
    ## Value is used as address into DAC registers.
    P0* {.bitsize: 1.}: U8
    P1* {.bitsize: 1.}: U8
    P2* {.bitsize: 1.}: U8
    P3* {.bitsize: 1.}: U8
    P4* {.bitsize: 1.}: U8
    P5* {.bitsize: 1.}: U8

  AttributeAmcr* = object
    ## "Attribute Mode Controller" register, index `0x10`
    AGTE* {.bitsize: 1.}: U8 ## "Attribute Controller Graphic Enable"
    ME* {.bitsize: 1.}: U8
    ELGCC* {.bitsize: 1.}: U8
    ELSBI* {.bitsize: 1.}: U8
    pad {.bitsize: 1.}: U8
    PELPC* {.bitsize: 1.}: U8
    PELW* {.bitsize: 1.}: U8
    P54S* {.bitsize: 1.}: U8 ## "Palette Bits 5-4 Select"
    ##
    ## This bit selects the source for the P5 and P4 video bits that act as
    ## inputs to the video DAC. When this bit is set to 0, P5 and P4 are
    ## the outputs of the Internal Palette registers. When this bit is set
    ## to 1, P5 and P4 are bits 1 and 0 of the Color Select register.

  AttributeCper* = object
    ECP* {.bitsize: 4.}: U8
    VSM* {.bitsize: 2.}: U8

  AttributeHpelpr* = object
    HPELP* {.bitsize: 4.}: U8

  AttributeCsr* = object
    ## "Color Select Register", index `0x14`.

    SC45* {.bitsize: 2.}: U8 ## Color Select 5-4
    ##
    ## These bits can be used in place of the P4 and P5 bits from the
    ## Internal Palette registers to form the 8-bit digital color value to
    ## the video DAC. Selecting these bits is done in the Attribute Mode
    ## Control register (index 0x10). These bits are used to rapidly switch
    ## between colors sets within the video DAC.

    SC67* {.bitsize: 2.}: U8 ## Color Select 7-6
    ##
    ## In modes other than mode 13 hex, these are the two most-significant
    ## bits of the 8-bit digital color value to the video DAC. In mode 13
    ## hex, the 8-bit attribute is the digital color value to the video
    ## DAC. These bits are used to rapidly switch between sets of colors in
    ## the video DAC.

  DACField2Field1* = object
    R* {.bitsize: 6.}: U8
    G* {.bitsize: 6.}: U8
    B* {.bitsize: 6.}: U8

  DACField2* {.union.} = object
    raw*: array[3, U8]
    field1*: DACField2Field1

  DACWPar* = object
    index*: U8

  DACRPar* = object
    index*: U8

  DACPdr* = object
    color*: U8

  DACDacsr* = object
    DACstate* {.bitsize: 2.}: U8

  DACPelmr* = object
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

proc R*(this: DACField2): U8 = this.field1.R
proc `R=`*(this: var DACField2, value: U8) = this.field1.R = value
proc G*(this: DACField2): U8 = this.field1.G
proc `G=`*(this: var DACField2, value: U8) = this.field1.G = value
proc B*(this: DACField2): U8 = this.field1.B
proc `B=`*(this: var DACField2, value: U8) = this.field1.B = value

template chkRegidx*(this, n: untyped): untyped {.dirty.} =
  if int(n) > sizeof(this.regs):
    ERROR("register index out of bound", n)

  if isNil(this.regs[n]):
    ERROR("Cannot write to register index $#[$#] - it is nil" % [
      $typeof(this), $n])


proc getWindowsize*(this: var CRT, x: var U16, y: var U16): void =
  x = charWidth * this.hdeer.HDEE
  y = charHeight * this.vdeer.VDEE

proc getWindowsize*(this: var VGA, x: var U16, y: var U16): void =
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
  # In alphanumeric mode the four planes are assigned distinct tasks. Plane
  # 0 contains character data, while plane 1 contains Attribute data.
  let
    # Compute column based on the display width
    x    = U16(n mod (charWidth * this.hdeer.HDEE))
    # Compute row
    y    = U16(n div (charHeight * this.hdeer.HDEE))
    idx  = (
      y div ( # Number of characters per row
        (this.mslr.MSL + 1) * # (Character height - 1) + 1
        this.hdeer.HDEE) # Display height
      ) + x div charWidth
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
  type
    IpData = object
      low {.bitsize: 4.}: U8
      high {.bitsize: 2.}: U8

  let ipData = cast[IpData](this.ipr[index and 0xF])
  if toBool(this.amcr.AGTE):
    result = ipData.low
    if toBool(this.amcr.P54S):
      result += (this.csr.SC45 shl 4)

    else:
      result += ipData.high shl 4

    result += this.csr.SC67 shl 6

  else:
    result = ipData.low

proc translateRgb*(this: var DAC, index: U8): U32 =
  ## Translate color index (6-bit) into concrete value of the RGB using
  ## `this.clut` map.
  var rgb: U32
  rgb = U32(this.clut[index].R shl 0x02)
  rgb = U32(rgb + this.clut[index].G shl 0x0A)
  rgb = U32(rgb + this.clut[index].B shl 0x12)
  return rgb

proc in8*(this: var DAC, memAddr: U16): U8 =
  var v: U8
  case memAddr:
    of 0x3C6: return cast[U8](this.pelmr)
    of 0x3C7: return cast[U8](this.dacsr)
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

      this.rPar = cast[DACRPar](v)
      this.progress = 0
    of 0x3C8:
      if v > 0xFF:
        ERROR("")

      this.wPar = cast[DACWPar](v)
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

type VgaImage* = seq[seq[tuple[r, g, b: U8]]]

proc rgbImage*(this: var VGA, buffer: var VgaImage): void =
  ## Fill image buffer of `size*3` with `R,G,B` value triples
  let mode: gmodeT = this.gc.graphicMode()
  let width = buffer[0].len()
  for row in 0 ..< buffer.len():
    for col in 0 ..< width:
      let i = width * row + col

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

      buffer[row][col] = (
        r: U8(rgb and 0xFF),
        g: U8((rgb shr 8) and 0xFF),
        b: U8((rgb shr 16) and 0xFF)
      )

proc txtBuffer*(
    this: var VGA, offset: U32 = 0x8000): seq[seq[tuple[ch: char, attr: U8]]] =

  for row in 0u8 ..< this.crt.vdeer.VDEE:
    var rowBuf = newSeqWith(this.crt.hdeer.HDEE.int, ('0', 0u8))
    for cell in 0u8 ..< this.crt.hdeer.HDEE:
      let idx = (this.crt.vdeer.VDEE.U32 * row.U32 + cell.U32) * 2 + offset
      let chr = this.readPlane(0, idx).char()
      let att = this.readPlane(1, idx)
      rowBuf[cell] = (chr, att)

    result.add rowBuf

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

proc writePlane*(this: var Sequencer, n: U8, offset: U32, v: U8) =
  this.logger.scope "Write to plane, sequencer n=$#, offset=$#, v=$#".format(
    n, toHexTrim(offset), v)

  if toBool((cast[U8](this.mapMr) shr n) and 1):
    this.vga.gc.write(n, offset, v)

proc writePlane*(this: var VGA, nplane: U8, offset: U32, v: U8): void =
  this.logger.scope "Write to vga plane n=$#, offset=$#, v=$#".format(
    nplane, offset.toHexTrim(), v)

  if nplane > 3 or offset > (1 shl 16) - 1:
    ERROR("Out of Plane range")

  this.plane[nplane][offset] = v

proc write*(this: var Sequencer, offset: U32, v: U8): void =
  this.logger.scope "Write to sequencer, offset=$#, v=$#".format(
    toHexTrim(offset), v)

  var offset = offset
  if not(this.memMr.EM.toBool()):
    # Cut off lower indices of the memory if "Extended Memory" is not
    # enabled.
    offset = (offset and (1 shl 16) - 1)

  if this.memMr.C4.toBool():
    # "Chain 4" is enabled, using lower bits of the offset as an indicator
    # for a plane index.
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
  this.logger.scope "Write 8 to VGA, offset=$#, v=$#".format(
    toHexTrim(offset), v)

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
    of 0x3B4, 0x3D4: return cast[U8](this.crtcar)
    of 0x3B5, 0x3D5: return this.regs[this.crtcar.INDX][]
    else: return high(U8)

proc out8*(this: var CRT, memAddr: U16, v: U8): void =
  case memAddr:
    of 0x3B4, 0x3D4:
      chkRegidx(this, v)
      this.crtcar = cast[CRTCrtcar](v)

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

proc in8*(this: var Attribute, port: U16): U8 =
  case port:
    of 0x3C0: return cast[U8](this.acar)
    of 0x3C1: return this.regs[this.acar.INDX][]
    else: return high(U8)

proc out8*(this: var Attribute, port: U16, v: U8): void =
  case port:
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
    0x2: pcast[U8](addr se.cmr),
    0x3: pcast[U8](addr se.mapMr),
    0x4: pcast[U8](addr se.cmsr),
    0x5: pcast[U8](addr se.memMr),
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
    0x1: pcast[U8](addr gc.sr),
    0x2: pcast[U8](addr gc.esr),
    0x3: pcast[U8](addr gc.ccr),
    0x4: pcast[U8](addr gc.drr),
    0x5: pcast[U8](addr gc.rmsr),
    0x6: pcast[U8](addr gc.gmr),
    0x7: pcast[U8](addr gc.mr),
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
    0x00: pcast[U8](addr crt.htr),
    # Index 01h -- End Horizontal Display Register
    0x01: pcast[U8](addr crt.hdeer),
    # Index 02h -- Start Horizontal Blanking Register
    0x02: pcast[U8](addr crt.shbr),
    # Index 03h -- End Horizontal Blanking Register
    0x03: pcast[U8](addr crt.ehbr),
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
    0x09: pcast[U8](addr crt.mslr),
    # Index 0Ah -- Cursor Start Register
    0x0A: pcast[U8](addr crt.csr),
    # Index 0Bh -- Cursor End Register
    0x0B: pcast[U8](addr crt.cer),
    # Index 0Ch -- Start Address High Register
    0x0C: pcast[U8](addr crt.sahr),
    # Index 0Dh -- Start Address Low Register
    0x0D: pcast[U8](addr crt.salr),
    # Index 0Eh -- Cursor Location High Register
    0x0E: pcast[U8](addr crt.clhr),
    # Index 0Fh -- Cursor Location Low Register
    0x0F: pcast[U8](addr crt.cllr),
    # Index 10h -- Vertical Retrace Start Register
    0x10: nil,
    # Index 11h -- Vertical Retrace End Register
    0x11: nil,
    # Index 12h -- Vertical Display End Register
    0x12: pcast[U8](addr crt.vdeer),
    # Index 13h -- Offset Register
    0x13: pcast[U8](addr crt.ofsr),
    # Index 14h -- Underline Location Register
    0x14: nil,
    # Index 15h -- Start Vertical Blanking Register
    0x15: nil,
    # Index 16h -- End Vertical Blanking
    0x16: nil,
    # Index 17h -- CRTC Mode Control Register
    0x17: pcast[U8](addr crt.crtmcr),
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
