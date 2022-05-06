## Main implementation file for the web UI. `em_main.c` calls into
## procedures exported in this file.

import std/strformat
import hmisc/core/all
import hmisc/core/code_errors
import hmisc/algo/procbox
import maincpp, common, eventer
import emulator/emulator
import compiler/assembler
import instruction/instruction
import pkg/genny

template printedTrace*(body: untyped) =
  try:
    body

  except Exception as e:
    echo e.msg
    echo "Exception triggered"
    pprintStackTrace(e)

proc exportedFunc() {.exportc.} =
  echo "[[[[[[[[[[!!!!!]]]]]]]]]]"

proc printTest*(arg: string)  =
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
    let code = $arg
    echo "code range"
    var prog: InstrProgram = parseProgram(code)
    echo "parsed program"
    prog.compile()
    echo "compiled"
    var bin = prog.data()
    echo "collected data"
    full.emu.loadBlob(bin, 0)
    echo "loaded blob"
    echo "----"
    echo code
    echo "compiled to code"
    echo prog.data()
    echo "----"

when defined(directRun):
  printTest("mov ax, bx")
  printTest("mov ax, bx")
  printTest("mov ax, bx")
  echo "Completed"

else:
  import std/[macros, compilesettings]

  exportProcs:
    printTest

  exportEnums:
    EmuEventKind
    EmuValueSystem


  exportRawTypes "using ESize = unsigned int;"
  exportRawTypes "using EByte = unsigned char;"
  exportSeq seq[EByte]:
    discard

  exportRawTypes "using MemData = SeqEByte;"

  exportObject EmuValue:
    discard


  exportRefObject EmuEvent:
    fields:
      kind
      msg
      value
      size

  exportRefObject InstrData:
    discard

  exportRefObject Emulator:
    discard

  exportObject EmuSetting:
    discard

  exportRefObject EmuLogger:
    procs:
      setRawHook
      setRawHookPayload

  exportRefObject FullImpl:
    fields:
      emu
      data
      logger

    constructor:
      initFull(EmuSetting, EmuLogger)

  const cache = querySetting(nimcacheDir) & "/genny"
  writeFiles(cache, "haxsim")
  macro genIncl(path: static[string]): untyped =
    let pathLit = newLit(path)
    quote do:
      include `pathLit`

  genIncl(cache & "/internal")
