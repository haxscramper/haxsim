## Main implementation file for the web UI. `em_main.c` calls into
## procedures exported in this file.

import nimgl/imgui
import std/strformat
import hmisc/core/all
import hmisc/algo/procbox
import cpus/i386/maincpp
import cpus/i386/emulator/emulator
import cpus/i386/compiler/assembler

template printedTrace*(body: untyped) =
  try:
    body

  except Exception as e:
    echo e.msg
    echo "Exception triggered"
    writeStackTrace()
    raise

proc printTest*(arg: cstring) {.exportc.} =
  printedTrace():
    echo "pressed button 'init'"
    echo "input code"
    echo "----"
    echo arg
    echo "----"

    block:
      var str = "asdfjlk;fdsakjlfasdkljsjdjdsjdjdjd"
      str.add("123123")
      echo str

    var emuSet: EmuSetting
    emuset.memSize = 0xFFFF
    var full = initFull(emuSet)
    let i = parseInstr("mov ax, bx")

    # full.loadAt(0): [
    #   "mov ax, 2",
    #   "mov dx, 0",
    #   "div edx",
    #   "hlt"
    # ]
   #  let code = $arg
   #  echo "code range"
   #  var prog: InstrProgram
   # # = parseProgram(code)
   #  echo "parsed program"
   #  # prog.compile()
   #  echo "compiled"
   #  var bin = prog.data()
   #  echo "collected data"
   #  full.emu.loadBlob(bin, 0)
    echo "loaded blob"
    echo "----"
    # echo code
    # echo "compiled to code"
    # echo prog.data()
    echo "----"
