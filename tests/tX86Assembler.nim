import hmisc/core/all
import hmisc/preludes/unittest
import compiler/assembler
import hmisc/algo/clformat
import common

setTestContextDisplayOpts hdisplay(flags += { dfSplitNumbers, dfUseHex })

suite "Primitive instructions":
  test "Can parse":
    for instr in [
      "mov byte [eax], 17",
      "mov AH, AL",
      "mov ah, al",
      "mov AH,al",
      "mov [eax], 17",
      "mul edx",
      "sub BYTE [eax], 17",
      "sub BYTE [ebx], 17",
      "sub BYTE [ecx], 17",
      "sub BYTE [edx], 17",
      "sub eax, ebx",
      "sub eax, ecx",
      "sub ebx, ebx",
      "sub ebx, ecx"
    ]:
      discard parseInstr(instr)

  test "Compile binary":
    for (instr, bin) in {
      "mov al, ah": u8 [0x88, 0xE0],
      "mov ah, al": u8 [0x88, 0xC4],
      # Register-register addressing mode, target register is `AH=100`,
      # source register is `AL=000`, modrm byte is used to encode the
      # arguments.
      "mov ah, al": u8 [0x88, 0b11_000_100],
      # Swapping operands also results in swapping of the `r/m` and `reg`
      # fields in `MODRM` byte.
      "mov al, ah": u8 [0x88, 0b11_100_000],
      # `mov ah` has dedicated instruction, modrm byte is not used. `0x12`
      # is encoded using regular immediate value
      "mov ah, 0x12": u8 [0xB4, 0x12],
      "mov byte [ebx], 0x17": u8 [
        0xC6, # Instruction opcode - `mov r/m8 imm8`
        0b00_000_011, # modrm byte for addressing. Target location is
                      # computed using `ebx` register, it's code is `011`.
                      # Source register does not exist. `mod=00`, so
                      # register indirect addressing mode is used.
        0x17  # Immediate value to move to target location
      ]
    }:
      let instrDat = parseInstr(instr)
      # pprinte instrDat
      # echov instr
      let compiled = compileInstr(instrDat)
      check:
        compiled == bin

  test "Integer encoding":
    for (instr, bin) in {
      "mov al, 0xAB": u8 [0xB0, 0xAB],
      "mov ax, 0xABCD": u8 [0xB8, 0xCD, 0xAB],
      "mov eax, 0x89ABCDEF": u8 [0xB8, 0xEF, 0xCD, 0xAB, 0x89]
    }:
      # echov instr, bin
      check parseInstr(instr).compileInstr() == bin

  test "Indirect addressing":
    for (instr, bin) in {
      # Not in protected mode, add 0x66 prefix in order to change operand
      # size.
      "mov edi, 0xB800": u8 [0x66, 0xBF, 0x00, 0xB8, 0x00, 0x00],
      # 16-bit register used, no need for operand size change prefix.
      "mov di, 0xB800": u8 [0xBF, 0x00, 0xB8],
      "mov byte [edi], 65": u8 [0xC6, 0x07, 0x41],
      "mov byte [edi+1], 0x7": u8 [0xC6, 0x47, 0x01, 0x07]
    }:
      check parseInstr(instr).compileInstr() == bin
