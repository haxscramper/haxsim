import hmisc/core/all
import common
import hmisc/preludes/unittest
import hmisc/algo/clformat

import compiler/[assembler, external]
import hardware/[processor, memory]
import emulator/[emulator, access]
import instruction/[syntaxes, instruction]
import maincpp

suite "Load compiled code":
  test "Assembly":
    let asmf = getTestTempFile("asm")
    let binf = getTestTempFile("bin")

    mkDir asmf.dir()

    let code = """
bits 16
mov bx, 0x12
mov ax, bx
mov bx, ax
"""

    asmf.writeFile(code)
    compileAsm(asmf, binf)

    var full = initFull(EmuSetting(memSize: 256))
    full.emu.cpu.setEip(0)
    full.emu.loadBlob(readFile(binf))

    echo full.emu.mem.dumpMem()

