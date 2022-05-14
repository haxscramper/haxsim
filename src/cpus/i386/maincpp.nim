import instruction/exec
import std/[math, sequtils]
import hmisc/algo/[clformat, clformat_interpolate]
import hmisc/other/oswrap

import common
import emulator/[emulator, interrupt]
import compiler/[assembler]
import hardware/[processor, memory, io]
import device/[dev_io]
import instruction/[
  instruction,
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

  FullImpl* = ref object
    ## Full implementation of the emulator
    logger*: EmuLogger
    data*: InstrData ## Data for instruction currently being executed
    impl16*: InstrImpl ## Implementation of the instructions for 16-bit mode
    impl32*: InstrImpl ## Implementation for 32-bit mode
    emu*: Emulator ## Emulator core object

template log*(full: FullImpl, ev: EmuEvent): untyped =
  full.emu.logger.log(ev, -2)

proc help*(name: cstring) =
  discard 

proc init*() =
  when false:
    setbuf(stdout, nil)
    setbuf(stderr, nil)

proc fetch*(full: FullImpl) =
  ## Fetch single instruction with it's associated prefixes, return true or
  ## false based on the presence of `0x66`-operand-override prefix.
  full.log ev(eekStartInstructionFetch)

  let isMode32 = full.emu.cpu.isMode32()
  # Instruction prefix parsing is not affected by the current mode of
  # operation, `if` is used in order to use correct implementation object.
  if isMode32:
    full.impl32.parsePrefix()

  else:
    full.impl16.parsePrefix()

  # Parse instruction as a 32-bit one if in the 32-bit mode *or* specific
  # instruction changed size (Otherwise parse instruction as in 16-bit
  # mode). Switch between different implementations in order to seelct
  # proper set of flags for parsing. Opcode implementation is not triggered
  # here.
  if isMode32 xor full.data.opSizeOverride:
    full.data.addrSizeOverride = not(isMode32 xor full.data.addrSizeOverride)
    parse(full.impl32)

  else:
    full.data.addrSizeOverride = isMode32 xor full.data.addrSizeOverride
    parse(full.impl16)

  full.log evEnd()

  full.log ev(eekEndInstructionFetch).withIt do:
    # full.emu.logger.noLog():
    let r = full.data.instrRange
    var p = full.emu.mem.memory.asMemPointer(r.start)
    let size = r.final - r.start + 1
    it.value.value.setLen(size)
    it.msg.addf("$#..$#", toHexTrim(r.start), toHexTrim(r.final))
    copymem(it.value.value, p, size)


proc parseCommands*(
    full: var FullImpl,
    toHlt: bool = true,
    toMem: EPointer = 0
  ): seq[InstrData] =
  ## Parse all commands from current memory position, without executing
  ## them. Used for testing purposes.
  while (
    if toHlt: full.data.opcode() != 0xF4
    elif toMem != 0:
      full.emu.cpu.eip < toMem and
      (full.emu.cpu.eip < full.emu.mem.len().EPointer())
    else: full.emu.cpu.eip < full.emu.mem.len().EPointer()
  ):
    zeroMem(addr full.data[], sizeof(full.data[]))
    fetch(full)
    var tmp = InstrData()
    tmp[] = full.data[]
    result.add tmp


proc step*(full: FullImpl) =
  assertRef(full)

  full.emu.logger.logScope(ev(eekStartLoopRun))
  # Reset current instruction data to a new state
  zeroMem(addr full.data[], sizeof(full.data[]))
  try:
    # Check if any device queued in new interupts
    if full.emu.accs.chkIrq(full.emu.intr):
      full.emu.cpu.doHalt(false)

    # Handle existing interrupts, if any
    full.emu.accs.handleInterrupt(full.emu.intr)

    # Fetch instruction data into `full.data` field
    fetch(full)

    # Depending on the current mode of operation and optional operand
    # size override, select instruction implementation operation.
    if full.emu.cpu.isMode32() xor full.data.opSizeOverride:
      discard exec(full.impl32)

    else:
      discard exec(full.impl16)

  except EmuCpuException as e:
    # CPU exception occurred, queue in new interrupt
    full.log ev(EmuExceptionEvent, eekInterrupt).withIt do:
      it.exception = e

    full.emu.intr.queueInterrupt(e.kind.uint8, true)


proc loop*(full: var FullImpl) =
  assertRef(full.impl16.get_emu())
  assertRef(full.impl16.get_emu())
  while not full.emu.cpu.isHalt():
    step(full)

proc addEchoHandler*(full: var FullImpl) =
  assertRef(full.emu)
  var emu = full.emu
  var stack: seq[EmuEventKind]
  var show = true
  var hideList: set[EmuEventKind] = { eekStartInstructionFetch }
  const showTrace: set[EmuEventKind] = { }

  proc echoHandler(ev: EmuEvent) =
    # echov ev.kind, ev.info
    assertRef(emu)
    if ev.kind in eekEndKinds:
      if stack.pop() in hideList:
        show = true

      return

    let indent = clt(repeat("  ", stack.len()))
    var res = &"[{stack.len():^3}]" & indent
    if ev.kind == eekScope:
      res.add "> " + fgYellow
      res.add ev.msg + fgRed

    else:
      res.add ($ev.kind + fgBlue |<< 16)

    if ev.kind == eekCallOpcodeImpl:
      let ev = EmuInstrEvent(ev)
      res.add " "
      res.add formatOpcode(fromMemBlob[U16](ev.value.value)) + fgGreen
      res.add " mod:$# reg:$# rm:$#" % [
        toBin(ev.instr.modrm.mod.uint, 2),
        toBin(ev.instr.modrm.reg.uint, 3),
        toBin(ev.instr.modrm.rm.uint, 3)
      ]


    elif ev.kind == eekGetMemBlob:
      res.add " "
      res.add ev.msg + fgCyan
      res.add " value "
      res.add $ev.value
      res.add " from "
      res.add hshow(ev.memAddr, clShowHex)
      # emu.mem.dumpMem()

    elif ev.kind in eekValueKinds:
      case ev.kind:
        of eekGetReg8, eekSetReg8:
          res.add format(" $# ($#)", Reg8T(ev.memAddr), ev.memAddr)

        of eekGetReg16, eekSetReg16:
          res.add format(" $# ($#)", Reg16T(ev.memAddr), ev.memAddr)

        of eekGetReg32, eekSetReg32:
          res.add format(" $# ($#)", Reg32T(ev.memAddr), ev.memAddr)

        of eekSetDtRegBase .. eekGetDtRegSelector:
          res.add " " & $DtRegT(ev.memAddr)

        of eekGetSegment, eekSetSegment:
          res.add " " & $SgRegT(ev.memAddr)

        of eekSetMem8 .. eekGetMem32, eekSetIo8 .. eekGetIo32:
          let s = log2(emu.mem.len().float()).int()
          res.add " 0x" & toHex(ev.memAddr)[^s .. ^1]

        of eekEndInstructionFetch:
          res.add " "
          res.add ev.msg
          res.add " "
          res.add ev.value.value.mapIt(toHex(it, 2)).join(" ")

        else:
          discard

      res.add " = "
      res.add $ev.value + fgCyan

    elif ev.kind == eekInterrupt:
      let ev = EmuExceptionEvent(ev)
      res.add " "
      let ind = res.len
      res.add hshow(ev.exception.kind.uint8, clShowHex)
      res.add ", "
      res.add ev.exception.msg + fgRed
      res.add "\n"
      for part in getStackTraceEntries(ev.exception):
        res.add "\n"
        res.add repeat(" ", ind)
        let (dir, name, ext) = splitFile(AbsFile $part.filename)
        res.add clfmt"|{name:>20}:{part.line:<4,fg-red} {part.procname:,fg-cyan}"

      res.add "\n"

    if show:
      echo res

    if ev.kind in showTrace:
      var trace = clt("")
      for call in ev.stackTrace:
        let
          procname = call.procname
          line = call.line
          path = call.filename

        let (dir, name, _) = splitFile(AbsFile($path))
        trace.add clfmt("    |{indent}  - {procname:,fg-red} {name:,fg-green}:{line:,fg-cyan}\n")

      echo trace

    if ev.kind in eekStartKinds:
      if ev.kind in hideList:
        show = false
      stack.add ev.kind

  emu.logger.setHook(echoHandler)

proc initFull*(
    emuset: EmuSetting, logger: EmuLogger = initEmuLogger()): FullImpl =
  ## Create full implementation of the evaluation core
  var logger = logger
  logger.logScope ev(eekInitEmulator)
  var emu = initEmulator(emuset, logger)
  let data = InstrData()
  var full = FullImpl(emu: emu, data: data, logger: logger)
  assertRef(full.emu)
  full.impl16 = initInstrImpl16(initExecInstr(full.emu, full.data, false))
  full.impl32 = initInstrImpl32(initExecInstr(full.emu, full.data, true))
  assertRef(full.impl16.get_emu())
  return full


proc runEmulator*(eset: Setting) =
  var emuset: EmuSetting
  emuset.memSize = eset.memSize

  var full = initFull(emuset)
  if not(full.emu.insertFloppy(0, eset.imageName, false)):
    assert false, "cannot load image \'%s\'"
    return 
  
  full.emu.loadBinary("bios/bios.bin", 0xf0000, 0, 0x2800)
  full.emu.loadBinary("bios/crt0.bin", 0xffff0, 0, 0x10)
  if eset.loadAddr.toBool():
    full.emu.loadBinary(eset.imageName, eset.loadAddr, 0x200, eset.loadSize.int64)

  full.loop()

proc main(): cint =
  var eset = Setting(
    memSize: MEMORYSIZE,
    imageName: "sample/kernel.img",
    loadAddr: 0x0,
    loadSize: cast[csizeT](-1))

  var opt: char
  runEmulator(eset)

proc compile*(
    instr: openarray[string],
    protMode: bool = false): seq[EByte] =
  for i in instr:
    result.add i.
      parseInstr(protMode = protMode, (0, 0)).
      compileInstr(protMode = protMode).
      data

proc loadAt*(
    full: var FullImpl,
    memAddr: EPointer,
    instr: openarray[string],
    protMode: bool = false
  ) =
  var compiled = compile(instr, protMode = protMode)
  full.emu.loadBlob(compiled, memAddr)

proc init*(
    instr: openarray[string],
    log: bool = false,
    memsize: ESize = 0,
    protMode: bool = false
  ): FullImpl =

  var compiled = compile(instr, protMode = protMode)
  var eset = EmuSetting(memSize: tern(
    memsize == 0,
    ESize(compiled.len() + 12),
    memsize))

  var full = initFull(eset)
  if log:
    full.addEchoHandler()
  # Initial value of the EIP is `0xFFF0` - to make testing simpler we are
  # setting it here to `0`.
  full.emu.cpu.setEip(0)
  full.emu.loadBlob(compiled)
  return full

proc eval*(
    instr: openarray[string],
    log: bool = false,
    memsize: ESize = 0,
    protMode: bool = false
  ): Emulator =

  var full = init(instr, log, memsize, protMode = protMode)
  full.emu.cpu.setMode32(protMode)
  full.loop()
  return full.emu

proc compileAndLoad*(full: FullImpl, str: string) =
  ## Compile and load program starting at position zero
  var prog = parseProgram(str)
  prog.compile()
  var bin = prog.data()
  full.emu.loadBlob(bin, 0)

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
