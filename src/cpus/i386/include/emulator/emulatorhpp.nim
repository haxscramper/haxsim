import commonhpp
import accesshpp
import interrupthpp
import uihpp
import hardware/[
  iohpp,
  memoryhpp
]
import device/[
  deviceshpp,
  pichpp,
  fddhpp,
  pithpp,
  syscontrolhpp,
  comhpp,
  vgahpp,
  keyboardhpp
]

type
  EmuSetting* {.bycopy, importcpp.} = object
    memSize*: csizeT
    uiset*: UISetting
  
  Emulator* {.bycopy.} = object
    accs*: DataAccess
    intr*: Interrupt
    ui*: ref UI
    fdd*: ref FDD
  
proc ejectFloppy*(this: var Emulator, slot: uint8): bool =
  return (if not this.fdd.isNIl(): this.fdd[].ejectDisk(slot) else: false)

proc isRunning*(this: var Emulator): bool =
  return (if not this.ui.isNil(): this.ui[].getStatus() else: false)

proc stop*(this: var Emulator): void = 
   # ui
  this.ui = nil

proc insertFloppy*(this: var Emulator, slot: uint8, disk: cstring, write: bool): bool =
  return (if not this.fdd.isNil(): this.fdd[].insertDisk(slot, disk, write) else: false)

proc initEmulator*(set: EmuSetting): Emulator =
  var picM, picS: ref PIC
  var pit: ref PIT
  var syscon: ref SysControl
  var com: ref COM
  var vga: ref VGA
  var kb: ref Keyboard
  {.warning: "FIXME".}
  # picM = newPIC()
  # picS = newPIC(picM)
  # setPic(picM, true)
  # setPic(picS, false)
  # ui = newUI(this, set.uiset)
  # pit = newPIT()
  # fdd = newFDD()
  # syscon = newSysControl(this)
  # com = newCOM()
  vga = result.ui[].getVga()
  kb = result.ui[].getKeyboard()
  picM[].setIrq(0, pit)
  picM[].setIrq(1, kb)
  picM[].setIrq(2, picS)
  picM[].setIrq(6, result.fdd)
  picS[].setIrq(4, kb[].getMouse())
  result.accs.io.setPortio(0x020, 2, picM.portio)
  result.accs.io.setPortio(0x040, 4, pit.portio)
  result.accs.io.setPortio(0x060, 1, kb.portio)
  result.accs.io.setPortio(0x064, 1, kb.portio)
  result.accs.io.setPortio(0x0a0, 2, picS.portio)
  result.accs.io.setPortio(0x092, 1, syscon.portio)
  result.accs.io.setPortio(0x3b4, 2, vga[].getCrt().portio)
  result.accs.io.setPortio(0x3ba, 1, vga.portio)
  result.accs.io.setPortio(0x3c0, 2, vga[].getAttr().portio)
  result.accs.io.setPortio(0x3c2, 2, vga.portio)
  result.accs.io.setPortio(0x3c4, 2, vga[].getSeq().portio)
  result.accs.io.setPortio(0x3c6, 4, vga[].getDac().portio)
  result.accs.io.setPortio(0x3cc, 1, vga.portio)
  result.accs.io.setPortio(0x3ce, 2, vga[].getGc().portio)
  result.accs.io.setPortio(0x3d4, 2, vga[].getCrt().portio)
  result.accs.io.setPortio(0x3da, 1, vga.portio)
  result.accs.io.setPortio(0x3f0, 8, result.fdd.portio)
  result.accs.io.setPortio(0x3f8, 1, com.portio)
  result.accs.io.setMemio(0xa0000, 0x20000, vga.memio)

proc loadBinary*(this: var Emulator, fname: cstring, `addr`: uint32, offset: uint32, size: int64): void =
  var fp: FILE
  var size = size
  fp = open($fname, fmRead)
  if not(fp.toBool()):
    return

  if cast[int32](size) < 0:
    setFilePos(fp, 0, fspEnd)
    size = getFileSize(fp)

  var buf = newSeq[uint8]()
  setFilePos(fp, offset.int64, fspSet)
  discard readBuffer(fp, buf[0].addr, size)
  close(fp)

  discard writeData(this.accs.mem, `addr`, buf[0].addr, size.csize_t)
