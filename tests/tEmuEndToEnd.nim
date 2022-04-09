import hmisc/core/all
import common
import hmisc/preludes/unittest
import hmisc/algo/clformat

import compiler/[assembler]
import hardware/[processor]
import emulator/[emulator, access]
import instruction/[syntaxes]
import maincpp

let op = hdisplay(flags += { dfSplitNumbers, dfUseHex })

setTestContextDisplayOpts op
startHax()

proc compile*(instr: openarray[string]): seq[EByte] =
  for i in instr:
    result.add i.parseInstr().compileInstr()

proc loadAt*(full: var FullImpl, memAddr: EPointer, instr: openarray[string]) =
  var compiled = compile(instr)
  full.emu.loadBlob(compiled, memAddr)

proc init*(instr: openarray[string], log: bool = false, memsize: ESize = 0): FullImpl =
  var compiled = compile(instr)
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

proc eval*(instr: openarray[string], log: bool = false): Emulator =
  var full = init(instr, log)
  full.loop()
  return full.emu

suite "Register math":
  test "8-bit":
    check eval(["inc ah", "hlt"]).cpu[AH] == 1
    check eval([
      "mov ax, 2", "imul ax, -0x2", "hlt"
    ]).cpu[AX] == cast[uint16](-0x4'i16)

    block:
      let cpu = eval([
        "mov ax, 2",
        "mov bx, 3",
        "xor ax, bx",
        "hlt"
      ]).cpu

      check:
        cpu[AX] == (0b11u16 xor 0b10u16)
        cpu[BX] == 0b11u16

suite "Interrupts":
  test "Division by zero":
    let max = 0x84.ESize
    var full = init([], log = true, memsize = max)
    # Load instructions starting from zero
    full.loadAt(0): [
      "mov ax, 2",
      "mov dx, 0",
      "div edx",
      "hlt"
    ]

    # Interrupt descritor table starts at `0x80`
    full.emu.cpu.setDtreg(IDTR, 0, 0x80, max.U16)
    # Stack pointer starts at `0xFF` and decreases as elements are added.
    # Stack is used when interrupt implementation is executed.
    full.emu.cpu.setGpreg(SP, max.U16)

    full.loop()

    # pprinte emu.cpu.gpregs
