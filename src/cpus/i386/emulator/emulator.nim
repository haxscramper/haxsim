import common
import hmisc/core/all
import access
import interrupt
import hardware/[
  io,
  memory,
  processor,
]
import device/[
  pic,
  fdd,
  pit,
  syscontrol,
  com,
  vga,
  keyboard
]

type
  EmuSetting* = object
    memSize*: ESize

  Emulator* = ref object
    logger*: EmuLogger
    accs*: DataAccess
    intr*: Interrupt
    fdd*: FDD

func io*(emu: Emulator): IO = emu.accs.io
func io*(emu: var Emulator): var IO = emu.accs.io
func cpu*(emu: Emulator): Processor = emu.accs.cpu
func cpu*(emu: var Emulator): var Processor = emu.accs.cpu
func mem*(emu: Emulator): Memory = emu.accs.mem
func mem*(emu: var Emulator): var Memory = emu.accs.mem

template log*(emu: Emulator, event: EmuEvent): untyped =
  emu.log.logger(event, -2)

proc ejectFloppy*(this: var Emulator, slot: uint8): bool =
  return (if not this.fdd.isNIl(): this.fdd.ejectDisk(slot) else: false)

proc insertFloppy*(this: var Emulator, slot: uint8, disk: cstring, write: bool): bool =
  return (if not this.fdd.isNil(): this.fdd.insertDisk(slot, disk, write) else: false)

proc initEmulator*(set: EmuSetting, logger: EmuLogger): Emulator =
  new(result)
  var picM = initPIC(logger)
  var picS = initPIC(logger, picM)
  result.intr.setPic(picM, true)
  result.intr.setPic(picS, false)
  var pit = initPIT().asRef()
  result.fdd = initFDD().asReF()
  var syscon = initSysControl(result.accs.mem).asRef()
  var com = (ref COM)()
  var vga = initVGA(logger)
  var kb = initKeyboard(result.accs.mem)
  picM.setIrq(0, pit)
  picM.setIrq(1, kb)
  picM.setIrq(2, picS)
  picM.setIrq(6, result.fdd)
  picS.setIrq(4, kb.getMouse())
  result.logger = logger
  result.accs = initDataAccess(set.memSize, logger)

  assertRef(result.accs.io.memory)
  result.accs.io.setPortio(0x020, 2, picM.portio)
  result.accs.io.setPortio(0x040, 4, pit.portio)
  result.accs.io.setPortio(0x060, 1, kb.portio)
  result.accs.io.setPortio(0x064, 1, kb.portio)
  result.accs.io.setPortio(0x0a0, 2, picS.portio)
  result.accs.io.setPortio(0x092, 1, syscon.portio)
  result.accs.io.setPortio(0x3b4, 2, vga.getCrt().portio)
  result.accs.io.setPortio(0x3ba, 1, vga.portio)
  result.accs.io.setPortio(0x3c0, 2, vga.getAttr().portio)
  # `VGA::MOR` register write
  result.accs.io.setPortio(0x3c2, 2, vga.portio)
  result.accs.io.setPortio(0x3c4, 2, vga.getSeq().portio)
  result.accs.io.setPortio(0x3c6, 4, vga.getDac().portio)
  # `VGA::MOR` register read
  result.accs.io.setPortio(0x3cc, 1, vga.portio)
  result.accs.io.setPortio(0x3ce, 2, vga.getGc().portio)
  result.accs.io.setPortio(0x3d4, 2, vga.getCrt().portio)
  result.accs.io.setPortio(0x3da, 1, vga.portio)
  result.accs.io.setPortio(0x3f0, 8, result.fdd.portio)
  result.accs.io.setPortio(0x3f8, 1, com.portio)
  result.accs.io.setMemio(0xa0000, 0x20000, vga.memio)

proc loadBlob*(this: var Emulator, blob: var MemData, pos: uint32 = 0) =
  assertRef(this.accs.mem)
  this.accs.mem.writeDataBlob(pos, blob)

proc loadBinary*(
    this: var Emulator, fname: cstring, memAddr: uint32,
    offset: uint32, size: int64): void =

  var size = size
  var fp: FILE = open($fname, fmRead)
  if not(fp.toBool()):
    return

  if cast[int32](size) < 0:
    setFilePos(fp, 0, fspEnd)
    size = getFileSize(fp)

  var buf = newSeq[uint8]()
  setFilePos(fp, offset.int64, fspSet)
  discard readBuffer(fp, buf[0].addr, size)
  close(fp)

  writeDataBlob(this.accs.mem, memAddr, buf)
