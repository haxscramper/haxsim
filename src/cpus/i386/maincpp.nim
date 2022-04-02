import instruction/execcpp
import hmisc/algo/[clformat, clformat_interpolate]

import "commonhpp"
import emulator/[emulatorhpp, interruptcpp]
import hardware/[processorhpp, memoryhpp, iohpp]
import device/[dev_iohpp]
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
    data: InstrData
    impl16: InstrImpl
    impl32: InstrImpl
    emu: Emulator

template log*(full: FullImpl, ev: EmuEvent): untyped =
  full.emu.logger.log(ev, -2)

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

  full.log evEnd()
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
    if full.emu.cpu.isMode32() xor toBool(prefix and CHSZOP):
      discard exec(full.impl32)

    else:
      discard exec(full.impl16)


    # except:
    #   # emu.queueInterrupt(n, true)
    #   raise
      # ERROR("Exception %d", n)

    # except:
    #   emu.dumpRegs()
    #   emu.stop()

proc initFull*(emuset: var EmuSetting): FullImpl =
  var logger = initEmuLogger()
  var emu = initEmulator(emuset, logger)
  let data = InstrData()
  var ind = 0
  proc echoHandler(ev: EmuEvent) =
    if ev.kind in eekEndKinds:
      dec ind
      return

    var res = repeat("  ", ind) & ($ev.kind + fgBlue |<< 16)
    if ev.kind == eekCallOpcodeImpl:
      res.add " "
      res.add formatOpcode(ev.value.value.uint16) + fgGreen

    elif ev.kind in eekValueKinds:
      res.add " = "
      res.add $ev.value + fgCyan

    echo res
    if ev.kind in eekStartKinds:
      inc ind



  emu.logger.setHook(echoHandler)

  var full = FullImpl(emu: emu, data: data)

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

let basic = @[
  # `mov al, 4`
  0xB0'u8, 0x04,
  # `inc al`
  0xFE'u8, 0xC0,
  # `hlt`
  0xF4'u8
]

proc main1() =
  echo "Created settings"
  var eset = EmuSetting(memSize: 8)
  var full = initFull(eset)

  # Initial value of the EIP is `0xFFF0` - to make testing simpler we are
  # setting it here to `0`.
  full.emu.cpu.setEip(0)

  full.emu.loadBlob(asVar @[
    # `mov al, 4`
    0xB0'u8, 0x04,
    # `add al, al`
    0x00, 0xC0,
    # `hlt`
    0xF4
  ])


  if false:
    full.emu.io.setPortIO(8, 1, PortIO(
      in8: proc(mem: uint16): uint8 = 1,
      out8: proc(mem: uint16, val: uint8) = discard
    ))

    full.emu.loadBlob(asVar @[
      # `in al, 8`
      0xE4'u8, 0x08,
      # `hlt`
      0xF4
    ])

    full.loop()
    assert full.emu.cpu.getGPreg(AL) == 1

  full.loop()


startHax()
main1()
echo "done"
