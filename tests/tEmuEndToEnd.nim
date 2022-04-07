import hmisc/core/all
import hmisc/preludes/unittest
import hmisc/algo/clformat

import compiler/[assembler]
import hardware/[processor]
import emulator/[emulator]
import instruction/[syntaxes]
import maincpp

setTestContextDisplayOpts hdisplay(flags += { dfSplitNumbers, dfUseHex })

proc eval*(instr: openarray[string]): Emulator =
  var eset = EmuSetting(memSize: 8)
  var full = initFull(eset)

  # Initial value of the EIP is `0xFFF0` - to make testing simpler we are
  # setting it here to `0`.
  full.emu.cpu.setEip(0)


  var compiled: seq[uint8]
  for i in instr:
    let dat = parseInstr(i)
    compiled.add dat.compileInstr()

  full.emu.loadBlob(compiled)
  full.loop()
  return full.emu

suite "Register math":
  test "8-bit":
    let emu = eval(["inc ah", "hlt"])
    echov emu.cpu[AH]
