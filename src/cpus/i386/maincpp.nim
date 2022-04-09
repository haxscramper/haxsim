import instruction/exec
import std/math
import hmisc/algo/[clformat, clformat_interpolate]
import hmisc/other/oswrap

import common
import emulator/[emulator, interrupt]
import hardware/[processor, memory, io]
import device/[dev_io]
import instruction/[
  instruction,
  base,
  instr16,
  instr32,
  parse,
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

  FullImpl* = ref object
    ## Full implementation of the emulator
    data*: InstrData ## Data for instruction currently being executed
    impl16*: InstrImpl ## Implementation of the instructions for 16-bit mode
    impl32*: InstrImpl ## Implementation for 32-bit mode
    emu*: Emulator ## Emulator core object

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

  while not full.emu.cpu.isHalt():
    zeroMem(addr full.data[], sizeof(full.data[]))
    try:
      if full.emu.accs.chkIrq(full.emu.intr):
        full.emu.cpu.doHalt(false)

      if full.emu.cpu.isHalt():
        {.warning: "[FIXME] 'std.thisThread.sleepFor(std.chrono.milliseconds(10))'".}
        continue

      full.emu.accs.handleInterrupt(full.emu.intr)
      let prefix = fetch(full)
      if full.emu.cpu.isMode32() xor toBool(prefix and CHSZOP):
        discard exec(full.impl32)

      else:
        discard exec(full.impl16)

    except EmuCpuException as e:
      full.log ev(EmuExceptionEvent, eekInterrupt).withIt do:
        it.exception = e

      full.emu.intr.queueInterrupt(e.kind.uint8, true)

    # except:
    #   # emu.queueInterrupt(n, true)
    #   raise
      # ERROR("Exception %d", n)

    # except:
    #   emu.dumpRegs()
    #   emu.stop()

proc addEchoHandler*(full: var FullImpl) =
  var emu = full.emu
  var ind = 0
  proc echoHandler(ev: EmuEvent) =
    if ev.kind in eekEndKinds:
      dec ind
      return

    var res = clt(repeat("  ", ind))
    for call in ev.stackTrace[^3 .. ^1]:
      # let (procname, line, path) = call
      let
        procname = call.procname
        line = call.line
        path = call.filename

      let (dir, name, _) = splitFile(AbsFile($path))
      # echo clfmt"{    procname:>} {  name:>}:{line:<3}" |>> terminalWidth()


    if ev.kind == eekScope:
      res.add "> " + fgYellow
      res.add ev.msg + fgRed

    else:
      res.add ($ev.kind + fgBlue |<< 16)

    if ev.kind == eekCallOpcodeImpl:
      let ev = EmuInstrEvent(ev)
      res.add " "
      res.add formatOpcode(ev.value.value.uint16) + fgGreen
      res.add " mod:$# reg:$# rm:$#" % [
        toBin(ev.instr.modrm.mod.uint, 2),
        toBin(ev.instr.modrm.reg.uint, 3),
        toBin(ev.instr.modrm.rm.uint, 3)
      ]

    elif ev.kind in eekValueKinds:
      case ev.kind:
        of eekGetReg8, eekSetReg8: res.add " " & $Reg8T(ev.memAddr)
        of eekGetReg16, eekSetReg16: res.add " " & $Reg16T(ev.memAddr)
        of eekGetReg32, eekSetReg32: res.add " " & $Reg32T(ev.memAddr)
        of eekSetDtRegBase .. eekGetDtRegSelector:
          res.add " " & $DtRegT(ev.memAddr)

        of eekGetSegment, eekSetSegment: res.add " " & $SgRegT(ev.memAddr)
        of eekSetMem8 .. eekGetMem32:
          let s = log2(emu.mem.len().float()).int()
          res.add " 0x" & toHex(ev.memAddr)[^s .. ^1]

        else:
          discard

      res.add " = "
      res.add $ev.value + fgCyan

    elif ev.kind == eekInterrupt:
      let ev = EmuExceptionEvent(ev)
      res.add " "
      res.add hshow(ev.exception.kind.uint8, clShowHex)
      res.add ", "
      res.add ev.exception.msg + fgRed

    elif ev.kind == eekGetMemBlob:
      res.add " "
      res.add ev.msg + fgCyan
      res.add " from "
      res.add hshow(ev.memAddr, clShowHex)

    echo res
    if ev.kind in eekStartKinds:
      inc ind

  emu.logger.setHook(echoHandler)

proc initFull*(emuset: var EmuSetting, logger: EmuLogger = initEmuLogger()): FullImpl =
  ## Create full implementation of the evaluation core
  var logger = logger
  logger.logScope ev(eekInitEmulator)
  var emu = initEmulator(emuset, logger)
  let data = InstrData()
  var full = FullImpl(emu: emu, data: data)
  var instr = initExecInstr(full.emu, full.data, false)
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
    assert false, "cannot load image \'%s\'"
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

when isMainModule:
  startHax()
  main1()
  echo "done"
