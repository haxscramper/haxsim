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
    objLogger: EmuLogger
    accs*: DataAccess
    intr*: Interrupt
    vga*: VGA
    fdd*: FDD

func logger*(emu: Emulator): EmuLogger =
  result = emu.objLogger
  echov result.enabled

func logger*(emu: var Emulator): var EmuLogger =
  result = emu.objLogger
  echov result.enabled

func `logger=`*(emu: Emulator, logger: EmuLogger) =
  echov logger.enabled
  emu.objLogger = logger

func io*(emu: Emulator): IO = emu.accs.io
func io*(emu: var Emulator): var IO = emu.accs.io
func cpu*(emu: Emulator): Processor = emu.accs.cpu
func cpu*(emu: var Emulator): var Processor =
  result = emu.accs.cpu
  # echov result.logger.enabled

func mem*(emu: Emulator): Memory = emu.accs.mem
func mem*(emu: var Emulator): var Memory = emu.accs.mem

template log*(emu: Emulator, event: EmuEvent): untyped =
  emu.log.logger(event, -2)

proc ejectFloppy*(this: var Emulator, slot: uint8): bool =
  return (if not this.fdd.isNIl(): this.fdd.ejectDisk(slot) else: false)

proc insertFloppy*(this: var Emulator, slot: uint8, disk: cstring, write: bool): bool =
  return (if not this.fdd.isNil(): this.fdd.insertDisk(slot, disk, write) else: false)

proc initEmulator*(set: EmuSetting, logger: EmuLogger): Emulator =
  var emu = Emulator()
  var
    picM = initPIC(logger)
    picS = initPIC(logger, picM)

  emu.intr.setPic(picM, true)
  emu.intr.setPic(picS, false)
  emu.fdd = initFDD()

  var
    pit = initPIT()
    syscon = initSysControl(emu.accs.mem)
    com = initCom()

  emu.vga = initVGA(logger)

  var kb = initKeyboard(emu.accs.mem)

  picM.setIrq(0, pit)
  picM.setIrq(1, kb)
  picM.setIrq(2, picS)
  picM.setIrq(6, emu.fdd)
  picS.setIrq(4, kb.getMouse())
  emu.logger = logger
  emu.accs = initDataAccess(set.memSize, logger)

  assertRef(emu.accs.io.memory)
  emu.accs.io.setPortio(0x020, 2, picM.portio)
  emu.accs.io.setPortio(0x040, 4, pit.portio)
  emu.accs.io.setPortio(0x060, 1, kb.portio)
  emu.accs.io.setPortio(0x064, 1, kb.portio)
  emu.accs.io.setPortio(0x0A0, 2, picS.portio)
  emu.accs.io.setPortio(0x092, 1, syscon.portio)
  block: # VGA configuration
    # Configuration registers for various parts of the VGA device.
    #
    # Two-byte ports provide access to all registers using
    # `[<index-selector>]`, `[<actual-register>]` approach. First byte
    # selects index of the regiser, second one actually writes to
    # registers.

    emu.accs.io.setPortio(0x3B4, 2, emu.vga.getCrt().portio)
    emu.accs.io.setPortio(0x3BA, 1, emu.vga.portio)
    emu.accs.io.setPortio(0x3C0, 2, emu.vga.getAttr().portio)
    emu.accs.io.setPortio(0x3C2, 2, emu.vga.portio)
    emu.accs.io.setPortio(0x3C4, 2, emu.vga.getSeq().portio)
    emu.accs.io.setPortio(0x3C6, 4, emu.vga.getDac().portio)
    emu.accs.io.setPortio(0x3CC, 1, emu.vga.portio)
    emu.accs.io.setPortio(0x3CE, 2, emu.vga.getGc().portio)
    emu.accs.io.setPortio(0x3D4, 2, emu.vga.getCrt().portio)
    emu.accs.io.setPortio(0x3DA, 1, emu.vga.portio)

  emu.accs.io.setPortio(0x3F0, 8, emu.fdd.portio)
  emu.accs.io.setPortio(0x3F8, 1, com.portio)
  emu.accs.io.setMemio(0xA0000, 0x20000, emu.vga.memio)

  return emu

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
