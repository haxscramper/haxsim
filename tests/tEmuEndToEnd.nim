import hmisc/core/all
import common
import hmisc/preludes/unittest
import hmisc/algo/clformat

import compiler/[assembler]
import hardware/[processor, memory]
import emulator/[emulator, access]
import instruction/[syntaxes]
import maincpp

let op = hdisplay(flags += { dfSplitNumbers, dfUseHex })

setTestContextDisplayOpts op
startHax()


suite "Register math":
  test "8-bit":
    check eval(["inc ah", "hlt"]).cpu[AH] == 1'u8
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
    let idt = 0x50.ESize
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
      # CPU is little endian, storing first byte of address at the start of
      # a segment value
      div0impl.U8, # start of the code segment for interrupt routime
                   # implementation.
      0x00u8,
      0x00u8,
      0x00u8, # Offset from the start of the segment used for interrupt
              # routine implementation. In this case implementation starts
              # immediately, so offset is zero.


    ], idt.U32)

    full.loadAt(div0Impl.U32): [
      "mov bl, 0x13", # for latter `check` call
      "iret" # Don't perform any additional operations, return from
             # interrupt immediately after setting check flag.
    ]

    # Stack pointer starts at `0xFF` and decreases as elements are added.
    # Stack is used when interrupt implementation is executed.
    full.emu.cpu.setGpreg(SP, max.U16)

    full.loop()
    full.emu.mem.dumpMem()

    check full.emu.cpu[BL] == 0x13'u8
    # pprinte(full.emu.cpu.gpregs)
