import imgui, imgui/[impl_opengl, impl_glfw]
import nimgl/[opengl, glfw]
import std/[strformat, strutils, macros, math, lenientops]
import maincpp, eventer, common
import emulator/emulator
import compiler/assembler
import hardware/processor
import hmisc/core/all
import hmisc/other/oswrap

proc getMem*(full: FullImpl, memAddr: EPointer): EByte =
  ## Return value from the specified location in the physica memory
  full.emu.mem.memory[memAddr]

proc setMem*(full: FullImpl, memAddr: EPointer, value: EByte) =
  ## Set value at the specified location in the physical memory
  full.emu.mem.memory[memAddr] = value



template spliceEach(
    stmts: NimNode, mid: NimNode, before: bool = true): NimNode =
  block:
    result = newStmtList()
    if before:
      for item in stmts:
        result.add mid
        result.add item

    else:
      for item in stmts:
        result.add item
        result.add mid

    result

proc igText*(args: varargs[string, `$`]) =
  let str = args.join("")
  igText(str.cstring())

proc igTextf*(fmt: string, args: varargs[string, `$`]) =
  let str = format(fmt, args)
  igText(str.cstring())

macro igRows*(body: untyped): untyped =
  result = spliceEach(body, newCall("igTableNextRow"))

macro igColumns*(body: untyped): untyped =
  var idx = 0
  result = spliceEach(body, newCall("igTableSetColumnIndex", newLit(postInc(idx))))

template igMainMenuBar*(body: untyped): untyped =
  if igBeginMainMenuBar():
    body
    igEndMainMenuBar()

template igMenu*(name: string, body: untyped): untyped =
  if igBeginMenu(name):
    body
    igEndMenu()

template igWindow*(name: string, body: untyped): untyped =
  igBegin(name, nil, ImGuiWindowFlags.None)
  body
  igEnd()

template igTable*(name: string, columns: int, body: untyped): untyped =
  if igBeginTable(name, columns.int32):
    body
    igEndTable()

proc igVec*(x, y: float): ImVec2 = ImVec2(x: x, y: y)
proc igCol32*(r, g, b: uint8, a: uint8 = 255): uint32 =
  (a.uint32 shl 24) or (b.uint32 shl 16) or (g.uint32 shl 8) or (r.uint32)

var glob = (
  codeLen: 0,
  codeText: repeat(" ", 0xFFFF)
)

proc cb(data: ptr ImGuiInputTextCallbackData): int32 {.cdecl.} =
  discard
  # glob.codeLen = data.bufTextLen

type
  UiState = ref object
    full: FullImpl
    lastRegWrite, lastRegRead: tuple[
      reg8: Option[Reg8T],
      reg16: Option[Reg16T],
      reg32: Option[Reg32T]
    ]

    memEnd: int

proc igLogic(state: UiState) =
  let full = state.full

  ## Main entry point for the visualization logic
  # igSetNextWindowSize(igVec(600, 600))
  igWindow("Main window TMP"):
    if igButton("Sub"):
      echo "Selected sub"

    igSameLine()

    if igButton("Next"):
      full.step()

    igSameLine()

    if igButton("Compile and load"):
      full.compileAndLoad(glob.codeText)

    igSameLine()

    if igButton("Example"):
      glob.codeText = """
mov ax, 2
imul ax, -0x2
hlt
"""

    let cpu = full.emu.cpu
    type RegIO = enum ioIn, ioOut, ioNone

    proc showReg(name, value: string, io: RegIO) =
      igTextf(
        "$#$# $#",
        name,
        (
          case io:
            of ioIn: "+"
            of ioOut: "-"
            of ioNone: "~"
        ),
        value
      )


    proc showReg(state: UiState, reg: Reg8T | Reg16T | Reg32T) =
      var wrote, read: bool
      when reg is Reg8T:
        read = (state.lastRegRead.reg8.canGet(r) and r == reg)
        wrote = (state.lastRegWrite.reg8.canGet(w) and w == reg)

      elif reg is Reg16T:
        read = (state.lastRegRead.reg16.canGet(r) and r == reg)
        wrote = (state.lastRegWrite.reg16.canGet(w) and w == reg)

      elif reg is Reg32T:
        read = (state.lastRegRead.reg32.canGet(r) and r == reg)
        wrote = (state.lastRegWrite.reg32.canGet(w) and w == reg)

      showReg(
        $reg,
        toHex(cpu[reg]),
        if wrote: ioIn
        elif read: ioOut
        else: ioNone,
      )


    full.logger.noLog():
      igTable("Registers", 4):
        igTableSetupColumn("32-bit", WidthStretch)
        igTableSetupColumn("16-bit", WidthStretch)
        igTableSetupColumn("8-bit", WidthStretch)
        igTableSetupColumn("Name", WidthStretch)
        igTableHeadersRow()

        igRows():
          igColumns():
            igText("Main registers")

        for (r32, r16, r8high, r8low, name) in @[
          (EAX, AX, AH, AL, "Accumulator"),
          (ECX, CX, CH, CL, "Count"),
          (EDX, DX, DH, DL, "Data"),
          (EBX, BX, BH, BL, "Base")
        ]:
          igRows():
            igColumns():
              state.showReg(r32)
              state.showReg(r16)
              igText("")
              igText(name)

            igColumns():
              igText("")
              state.showReg(r8high)
              state.showReg(r8low)

        igRows():
          igColumns():
            igText("Index registers")

        for (r32, r16, name) in @[
          (ESP, SP, "Stack Pointer"),
          (EBP, BP, "Base Pointer"),
          (ESI, SI, "Source Index"),
          (EDI, DI, "Destination Index")
        ]:
          igRows():
            igColumns():
              state.showReg(r32)
              state.showReg(r16)
              igText(name)

        igRows():
          igColumns():
            igText("Program counter")

          igColumns():
            showReg("EIP", cpu.getEip().toHex(), ioNone)
            showReg("IP", cpu.getIp().toHex(), ioNone)
            igText("Instruction pointer")

        for (r, name) in @[
          (CS, "Code Segment"),
          (DS, "Data Segment"),
          (ES, "Extra Segment"),
          (FS, "F Segment"),
          (GS, "G Segment"),
          (SS, "Stack Segment")
        ]:
          igRows():
            igColumns():
              igText("")
              showReg($r, cpu.getSgreg(r).raw().toHex(), ioNone)
              igText(name)


      let perRow = 8
      let memStart = 0
      igTable("memory", perRow + 1):
        for mem in 0 ..< perRow:
          igTableSetupColumn("+" & toHexTrim(mem), WidthStretch)

        igTableHeadersRow()

        for line in ceil(float(memStart) / perRow).int ..
                    ceil(float(memStart + state.memEnd) / perRow).int:

          igTableNextRow()
          igTableSetColumnIndex(0)
          igText("0x" & toHexTrim(line * perRow).alignLeft(3, '0'))
          var hasValue = false
          for idx in 0 ..< perRow:
            let cell = line * perRow + idx
            igTableSetColumnIndex(idx.int32 + 1)
            if cell < state.memEnd:
              hasValue = true
              igText(toHex(getMem(full, EPointer(cell))))

    igInputTextMultiline(
      "Label",
      glob.codeText.cstring,
      0xFFFF,
      # flags = ImGuiInputTextFlags.CallbackEdit,
      # callback = cb,
    )



proc main() =
  assert glfwInit()

  var full = initFull(EmuSetting(memSize: 256))
  full.emu.cpu.setEip(0)
  full.addEchoHandler()
  var uiState = UiState(full: full, memEnd: 256)

  glfwWindowHint(GLFWContextVersionMajor, 4)
  glfwWindowHint(GLFWContextVersionMinor, 1)
  glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE)
  glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
  glfwWindowHint(GLFWResizable, GLFW_FALSE)

  var w: GLFWWindow = glfwCreateWindow(1920, 1080)
  if w == nil:
    quit(-1)

  w.makeContextCurrent()

  assert glInit()

  let context = igCreateContext()
  #let io = igGetIO()

  assert igGlfwInitForOpenGL(w, true)
  assert igOpenGL3Init()

  igStyleColorsCherry()

  var show_demo: bool = true
  var somefloat: float32 = 0.0f
  var counter: int32 = 0

  while not w.windowShouldClose:
    glfwPollEvents()

    igOpenGL3NewFrame()
    igGlfwNewFrame()
    igNewFrame()
    # Call main logic implementation function
    igLogic(uiState)

    igRender()

    glClearColor(0.45f, 0.55f, 0.60f, 1.00f)
    glClear(GL_COLOR_BUFFER_BIT)
    igOpenGL3RenderDrawData(igGetDrawData())
    w.swapBuffers()

  igOpenGL3Shutdown()
  igGlfwShutdown()
  context.igDestroyContext()
  w.destroyWindow()
  glfwTerminate()

let params = getCommandLineParams()
if not params.empty() and params.first() == "run":
  main()
