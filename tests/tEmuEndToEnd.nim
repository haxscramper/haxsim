import hmisc/core/all
import common
import hmisc/preludes/unittest
import hmisc/algo/clformat

import compiler/[assembler]
import hardware/[processor, memory]
import emulator/[emulator, access]
import instruction/[syntaxes, instruction]
import maincpp

let op = hdisplay(flags += { dfSplitNumbers, dfUseHex })

setTestContextDisplayOpts op
startHax()

let ppconf = defaultPPrintConf.withIt do:
  it.showErrorTrace = true
  # it.extraFields = @[
  #   pprintExtraField(OpcodeData, "code", newPPrintConst(it.code.formatOpcode()))
  # ]
  # it.overridePaths = @[
  #   pprintOverride(int, matchTypeField("OpcodeData", "code")) do:
  #     return newPPrintConst(toHex(it))
  # ]


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

suite "Full instruction parser":
  test "1":
    var full = init([
      "mov edi, 0xB800",
      "mov byte [edi], 65",
      "mov byte [edi+1], 0x7",
      "hlt"
    ])

    # full.emu.mem.dumpMem()
    let cmds = full.parseCommands()
    # pprinte(cmds, pconf = ppconf)
    # full.emu.mem.dumpMem()

    check:
      cmds[0].imm32.U32 == 0xB800u32
      cmds[0].opcode.U16 == 0xBFu16

      cmds[0].instrRange == (1u32, 6u32)
      cmds[1].instrRange == (6u32, 9u32)
      cmds[2].instrRange == (9u32, 13u32)

      cmds.len == 4
