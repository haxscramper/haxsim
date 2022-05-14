## Main implementation file for the web UI. `em_main.c` calls into
## procedures exported in this file.

import hmisc/core/code_errors
import maincpp, common, eventer
import emulator/emulator
import hardware/[memory, processor]
import compiler/assembler
import instruction/[instruction, syntaxes]
import pkg/genny

template printedTrace*(body: untyped) =
  try:
    body

  except Exception as e:
    echo e.msg
    echo "Exception triggered"
    pprintStackTrace(e)


proc getAddr*(ev: EmuEvent): uint32 = ev.memAddr.uint32()
proc getCPU*(e: Emulator): Processor = e.cpu()

proc getMemSize*(full: FullImpl): int =
  ## Get physical memory size
  full.emu.mem.len()

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

type ExceptionRef = ref Exception

proc formatStackTrace*(ex: ExceptionRef): string =
  getStackTrace(ex)

when defined(directRun):
  printTest("mov ax, bx")
  printTest("mov ax, bx")
  printTest("mov ax, bx")
  echo "Completed"

else:
  import std/[macros, compilesettings]

  exportRawTypes """
using U8  = unsigned char;
using U16 = unsigned short;
using U32 = unsigned long;

using I8  = char;
using I16 = short;
using I32 = long;
"""

  exportEnums:
    EmuEventKind
    EmuValueSystem
    Reg8T
    Reg16T
    Reg32T

  exportRawTypes "using ESize = unsigned int;"
  exportRawTypes "using EByte = unsigned char;"
  exportRawTypes "using EPointer = unsigned short int;"
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
      memAddr

    procs:
      getAddr
      getValue8
      getValue16
      getValue32

  exportRawTypes "using EmuEventHandler = void(*)(EmuEvent, void*);"
  exportRefObject InstrData:
    discard

  exportRefObject Processor:
    procs:
      setEip

  exportRefObject Emulator:
    procs:
      getCpu

  exportObject EmuSetting:
    discard

  exportRefObject EmuLogger:
    procs:
      setRawHook
      setRawHookPayload

    constructor:
      initEmuLogger

  exportRefObject ExceptionRef:
    fields:
      name
      msg

    procs:
      formatStackTrace


  exportRefObject FullImpl:
    fields:
      emu
      data
      logger

    procs:
      getMem
      setMem
      getMemSize
      compileAndLoad
      step

    constructor:
      initFull(EmuSetting, EmuLogger)

  const cache = querySetting(nimcacheDir) & "/genny"
  writeFiles(cache, "haxsim")
  macro genIncl(path: static[string]): untyped =
    let pathLit = newLit(path)
    quote do:
      include `pathLit`

  genIncl(cache & "/internal")
