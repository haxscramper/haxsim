import hmisc/core/all
import hmisc/other/oswrap
import hmisc/preludes/unittest
import compiler/assembler
import hmisc/algo/clformat
import common

startHax()

let file = ~"/defaultdirs/input/XT286" /. "VIDEO1.ASM"
let text = file.readFile()
let prog = parseProgram(text)
