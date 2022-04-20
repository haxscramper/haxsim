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

suite "Write character to VGA":
  test "Write single character":
    var emu = eval([
      "mov edi, 0xB800",
      "mov byte [edi], 65", # Codepoint 'A', code is `65`
      "mov byte [edi+1], 0x7", # Character attribute `0b111`
      "hlt"
    ])
