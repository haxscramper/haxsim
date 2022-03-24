import "commonhpp"
import emulator/[emulatorhpp, interruptcpp]
import hardware/[processorhpp]
import instruction/[
  instructionhpp,
  basehpp,
  instr16cpp,
  instr32cpp,
  parsecpp,
  execcpp
]

template MEMORYSIZE*(): untyped {.dirty.} =
  (4 * MB)

type
  Setting* = object
    memSize*: csizeT
    imageName*: cstring
    loadAddr*: uint32
    loadSize*: csizeT
    uiEnable*: bool
    uiFull*: bool
    uiVm*: bool

  FullImpl = object
    data: InstrData
    impl16: Instr16
    impl32: Instr32
    emu: Emulator
  
proc help*(name: cstring): void =
  discard 

proc init*(): void =
  when false:
    setbuf(stdout, nil)
    setbuf(stderr, nil)

proc loop*(full: var FullImpl) =
  while (full.emu.isRunning()):
    var isMode32: bool
    var prefix: uint8
    var chszAd, chszOp: bool
    full.data = InstrData()
    # memset(addr instr, 0, sizeof((InstrData)))
    try:
      if full.emu.intr.chkIrq():
        full.emu.accs.cpu.doHalt(false)

      if full.emu.accs.cpu.isHalt():
        {.warning: "[FIXME] 'std.thisThread.sleepFor(std.chrono.milliseconds(10))'".}
        continue

      full.emu.intr.hundleInterrupt()
      isMode32 = full.emu.accs.cpu.isMode32()
      if isMode32:
        prefix = full.impl32.parsePrefix()

      else:
        prefix = full.impl16.parsePrefix()
      chszOp = toBool(prefix and CHSZOP)
      chszAd = toBool(prefix and CHSZAD)
      if isMode32 xor chszOp:
        full.impl32.setChszAd(not((isMode32 xor chszAd)))
        parse(full.impl32)
        discard exec(full.impl32)

      else:
        full.impl16.setChszAd(isMode32 xor chszAd)
        parse(full.impl16)
        discard exec(full.impl16)

    except:
      # emu.queueInterrupt(n, true)
      assert false
      # ERROR("Exception %d", n)

    # except:
    #   emu.dumpRegs()
    #   emu.stop()
  
proc runEmulator*(eset: Setting): void =
  var emuset: EmuSetting
  emuset.memSize = eset.memSize
  emuset.uiset.enable = eset.uiEnable
  emuset.uiset.full = eset.uiFull
  emuset.uiset.vm = eset.uiVm

  var full = FullImpl(emu: initEmulator(emuset))
  full.impl16 = initInstr16(addr full.emu, addr full.data)
  full.impl32 = initInstr32(addr full.emu, addr full.data)

  if not(full.emu.insertFloppy(0, eset.imageName, false)):
    WARN("cannot load image \'%s\'", eset.imageName)
    return 
  
  full.emu.loadBinary("bios/bios.bin", 0xf0000, 0, 0x2800)
  full.emu.loadBinary("bios/crt0.bin", 0xffff0, 0, 0x10)
  if eset.loadAddr.toBool():
    full.emu.loadBinary(eset.imageName, eset.loadAddr, 0x200, eset.loadSize)

  full.loop()

proc main*(): cint =
  var eset = Setting(
    memSize: MEMORYSIZE,
    imageName: "sample/kernel.img",
    loadAddr: 0x0,
    loadSize: cast[csizeT](-1),
    uiEnable: true,
    uiFull: false,
    uiVm: false)

  var opt: char
  runEmulator(eset)
