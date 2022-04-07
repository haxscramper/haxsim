import hmisc/core/all
import common
import hmisc/preludes/unittest
import hmisc/algo/clformat

import compiler/[assembler]
import hardware/[processor]
import emulator/[emulator]
import instruction/[syntaxes]
import maincpp

let op = hdisplay(flags += { dfSplitNumbers, dfUseHex })

setTestContextDisplayOpts op
startHax()

proc eval*(instr: openarray[string]): Emulator =
  var compiled: seq[uint8]
  for i in instr:
    let dat = parseInstr(i)
    let bin = dat.compileInstr()
    compiled.add bin

  var eset = EmuSetting(memSize: ESize(compiled.len() + 12))
  var full = initFull(eset)

  # Initial value of the EIP is `0xFFF0` - to make testing simpler we are
  # setting it here to `0`.
  full.emu.cpu.setEip(0)

  full.emu.loadBlob(compiled)
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
    echov "Hello"
    let emu = eval([
      "mov ax, 2",
      "mov dx, 0",
      "div edx",
      "hlt"
    ])

    pprinte emu.cpu.gpregs
