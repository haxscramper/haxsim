import nimgl/imgui
import std/strformat
import hmisc/core/all
import hmisc/algo/procbox
import cpus/i386/maincpp
import cpus/i386/emulator/emulator
import cpus/i386/compiler/assembler

proc printTest*(arg: cstring) {.exportc.} =
  echo "called print test"
  echo "argument", arg

template printedTrace*(body: untyped) =
  try:
    body

  except:
    writeStackTrace()
    raise

proc loopImpl*() {.cdecl.} =
  printedTrace():
    echo "pressed button 'init'"
    var emuSet: EmuSetting
    emuset.memSize = 0xFFFF
    let full = initFull(emuSet)
    # let code = ($glob.codeText)[0 .. glob.codeLen]
    # echo "code range"
    # assert false, "ERROR MESSAGE"
    # echo "after assert false triggered"
    # var prog = parseProgram(code)
    # echo "parsed program"
    # prog.compile()
    # echo "compiled"
    # var bin = prog.data()
    # echo "collected data"
    # glob.full.emu.loadBlob(bin, 0)
    # echo "loaded blob"
    # echo "----"
    # echo code
    # echo "compiled to code"
    # echo prog.data()
    # echo "----"
