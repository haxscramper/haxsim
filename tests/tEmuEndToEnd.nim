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
    let idt = 0x80.ESize
    var full = init([], log = true, memsize = max)
    # Load instructions starting from zero
    full.loadAt(0): [
      "mov ax, 2",
      "mov dx, 0",
      "div edx",
      "hlt"
    ]

    # Interrupt descritor table starts at `0x80`
    full.emu.cpu.setDtreg(IDTR, 0, idt.U32, max.U16)

    let div0impl = 0x60.ESize
    # Create entry for the IDT. Technically it should have 256 entries, but
    # the divide-by-zero exception has index 0, so one will be sufficient
    full.emu.loadBlob(asVar @[
      0x00u8,
      0x00u8, # Offset from the start of the segment used for interrupt
              # routine implementation. In this case implementation starts
              # immediately, so offset is zero.
      0x00u8,
      div0impl.U8 # start of the code segment for interrupt routime
                  # implementation.
    ], idt.U32)

    full.loadAt(div0Impl.U32): [
      "mov bx, 0x13", # for latter `check` call
      "iret" # Don't perform any additional operations, return from
             # interrupt immediately after setting check flag.
    ]

    # Stack pointer starts at `0xFF` and decreases as elements are added.
    # Stack is used when interrupt implementation is executed.
    full.emu.cpu.setGpreg(SP, max.U16)

    full.loop()

    pprinte full.emu.cpu.gpregs
