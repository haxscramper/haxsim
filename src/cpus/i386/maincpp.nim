import instruction/execcpp


import "commonhpp"
import emulator/[emulatorhpp, interruptcpp]
import hardware/[processorhpp, memoryhpp]
import instruction/[
  instructionhpp,
  basehpp,
  instr16cpp,
  instr32cpp,
  parsecpp,
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

  FullImpl = ref object
    logger: EmuLogger
    data: InstrData
    impl16: InstrImpl
    impl32: InstrImpl
    emu: Emulator

template log*(full: FullImpl, ev: EmuEvent): untyped =
  full.logger.log(ev, -2)

proc help*(name: cstring): void =
  discard 

proc init*(): void =
  when false:
    setbuf(stdout, nil)
    setbuf(stderr, nil)

proc fetch*(full: var FullImpl): uint8 =
  full.log ev(eekStartInstructionFetch)

  let isMode32 = full.emu.cpu.isMode32()
  let prefix =
    if isMode32:
      full.impl32.parsePrefix()

    else:
      full.impl16.parsePrefix()

  let chszOp = toBool(prefix and CHSZOP)
  let chszAd = toBool(prefix and CHSZAD)
  if isMode32 xor chszOp:
    full.impl32.setChszAd(not((isMode32 xor chszAd)))
    parse(full.impl32)

  else:
    full.impl16.setChszAd(isMode32 xor chszAd)
    parse(full.impl16)

  full.log ev(eekEndInstructionFetch)
  return prefix

proc loop*(full: var FullImpl) =
  assertRef(full.impl16.get_emu())
  assertRef(full.impl16.get_emu())
  dumpMem(full.emu.mem)

  while not full.emu.cpu.isHalt():
    zeroMem(addr full.data[], sizeof(full.data[]))
    if full.emu.accs.chkIrq(full.emu.intr):
      full.emu.cpu.doHalt(false)

    if full.emu.cpu.isHalt():
      {.warning: "[FIXME] 'std.thisThread.sleepFor(std.chrono.milliseconds(10))'".}
      continue

    full.emu.accs.hundleInterrupt(full.emu.intr)
    let prefix = fetch(full)
    # pprinte full.data
    # echov "executing"
    if full.emu.cpu.isMode32() xor toBool(prefix and CHSZOP):
      discard exec(full.impl32)

    else:
      discard exec(full.impl16)

    pprinte full.emu.cpu.halt

    # except:
    #   # emu.queueInterrupt(n, true)
    #   raise
      # ERROR("Exception %d", n)

    # except:
    #   emu.dumpRegs()
    #   emu.stop()

proc initFull*(emuset: var EmuSetting): FullImpl =
  let emu = initEmulator(emuset)
  let data = InstrData()
  proc echoHandler(ev: EmuEvent) =
    echov ev.kind
    if ev.kind in {eekStartInstructionFetch, eekEndInstructionFetch}:
      echov emu.cpu.eip

    if ev.kind == eekEndInstructionFetch:
      pprinte data

  var full = FullImpl(
    emu: emu, data: data, logger: initEmuLogger(echoHandler))

  var instr = initInstruction(full.emu, full.data, false)
  assertRef(full.emu)
  full.impl16 = initInstrImpl16(instr)
  full.impl32 = initInstrImpl32(instr)
  assertRef(full.impl16.get_emu())
  return full


proc runEmulator*(eset: Setting): void =
  var emuset: EmuSetting
  emuset.memSize = eset.memSize
  emuset.uiset.enable = eset.uiEnable
  emuset.uiset.full = eset.uiFull
  emuset.uiset.vm = eset.uiVm

  var full = initFull(emuset)
  if not(full.emu.insertFloppy(0, eset.imageName, false)):
    WARN("cannot load image \'%s\'", eset.imageName)
    return 
  
  full.emu.loadBinary("bios/bios.bin", 0xf0000, 0, 0x2800)
  full.emu.loadBinary("bios/crt0.bin", 0xffff0, 0, 0x10)
  if eset.loadAddr.toBool():
    full.emu.loadBinary(eset.imageName, eset.loadAddr, 0x200, eset.loadSize.int64)

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

proc main1() =
  echo "Created settings"
  var eset = EmuSetting(memSize: 8)
  var full = initFull(eset)

  # Initial value of the EIP is `0xFFF0` - to make testing simpler we are
  # setting it here to `0`.
  full.emu.cpu.setEip(0)

  full.emu.loadBlob(asVar @[
    # `inc al`
    0xFE'u8, 0xC0,
    # `hlt`
    0xF4'u8
  ])

  # assertRef(full.emu.cpu)
  full.loop()

startHax()
main1()
echo "done"
