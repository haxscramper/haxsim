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

proc igDrag*(label: string, value: var int32) =
  igDragInt(label.cstring, addr value)

proc igText*(args: varargs[string, `$`]) =
  ## Imgui text widget construction call overload with automatic string
  ## conversion
  let str = args.join("")
  igText(str.cstring())

proc igTextf*(fmt: string, args: varargs[string, `$`]) =
  ## Create imgui text using string formatting from strformat. Usage is
  ## identical to regular `strutils.format`
  let str = format(fmt, args)
  igText(str.cstring())

macro igRows*(body: untyped): untyped =
  ## Splice each statement in bodu with `igTableNextRow()`. Shortcut for
  ## creating a single table row.
  result = spliceEach(body, newCall("igTableNextRow"))

macro igColumns*(body: untyped): untyped =
  ## Splice each statement in body with sequentually increasing column
  ## numbers. `igText("A"); igText("B")` -> `igTableSetColumnIndex(0); igText("A")`
  var idx = 0
  result = spliceEach(body, newCall("igTableSetColumnIndex", newLit(postInc(idx))))

template igMainMenuBar*(body: untyped): untyped =
  ## Construct imgui menu bar
  if igBeginMainMenuBar():
    body
    igEndMainMenuBar()

template igMenu*(name: string, body: untyped): untyped =
  ## Start new imgui menu item
  if igBeginMenu(name):
    body
    igEndMenu()

proc igMenuItemToggleBool*(toFalse, toTrue: string, value: var bool) =
  if value:
    if igMenuItem(toFalse):
      echov "selected", toFalse
      value = false

  else:
    if igMenuItem(toTrue):
      echov "selected", toTrue
      value = true

template igItemWidth*(w: float, body: untyped): untyped =
  igPushItemWidth(w)
  body
  igPopItemWidth()

proc igTableSetupColumns*(names: openarray[string]) =
  ## Configure names of the header row for table
  for name in names:
    igTableSetupColumn(name)
  igTableHeadersRow()

proc igTableSetupColumns*(names: openarray[tuple[
    name: string,
    flags: ImGuiTableColumnFlags,
    width: int32
  ]]) =

  ## Configure names of the header row for table
  for (name, flags, width) in names:
    igTableSetupColumn(name, flags, width.float)


proc igTableSetupColumnWidths*(widths: openarray[int32]) =
  for idx, width in widths:
    igSetColumnWidth(idx.int32, width.float)

template igGroup*(body: untyped): untyped =
  igBeginGroup()
  body
  igEndGroup()

template igWindow*(name: string, body: untyped): untyped =
  ## Create new imgui window
  igBegin(name, nil, ImGuiWindowFlags.None)
  body
  igEnd()

proc orEnum[E: enum](values: openarray[E]): E =
  var res: I32
  for val in values:
    res = res or I32(val.ord)

  return cast[E](res)

template igTable*(
    name: string, columns: int,
    flags: ImGuiTableFlags = 0.ImGuiTableFlags, body: untyped): untyped =
  ## Wrap body in imgui table construction calls
  if igBeginTable(name, columns.int32):
    body
    igEndTable()

template igTooltip*(body: untyped): untyped =
  ## If previous item is hovered on, show tooltip described by `body`
  if igIsItemHovered():
    igBeginTooltip()
    body
    igEndToolTip()

proc igMenuItem*(name, tooltip: string): bool =
  ## Create menu item with given name and tooltip. Tooltip is shown in the
  ## regular text widget.
  result = igMenuItem(name)
  igTooltip():
    igText(tooltip)

proc igVec*(x, y: float): ImVec2 = ImVec2(x: x, y: y)
proc igVec*(x, y, z, w: float): ImVec4 = ImVec4(x: x, y: y, z: z, w: w)
proc igCol32*(r, g, b: uint8, a: uint8 = 255): uint32 =
  (a.uint32 shl 24) or (b.uint32 shl 16) or (g.uint32 shl 8) or (r.uint32)

type
  UiIo = object
    lastRegWrite, lastRegRead: tuple[
      reg8: Option[Reg8T],
      reg16: Option[Reg16T],
      reg32: Option[Reg32T]
    ]


  UiState = ref object
    full: FullImpl
    io: UiIo
    codeText: string
    events: seq[EmuEvent]
    memEnd: int

    showSections: tuple[
      showPortIo, showMemoryIo, showVGA: bool
    ]

type RegIO = enum ioIn, ioOut, ioNone
proc showReg(name, value: string, io: RegIO) =
  let
    colors = (
      red: igGetColorU32(igCol32(120, 20, 20)),
      green: igGetColorU32(igCol32(20, 120, 20))
    )

  case io:
    of ioIn:
      echov name, value, io
      igTableSetBgColor(CellBg, colors.red)

    of ioOut:
      echov name, value, io
      igTableSetBgColor(CellBg, colors.green)

    else:
      discard

  igTextf("$# $#", name, value)

proc showReg(state: UiState, reg: Reg8T | Reg16T | Reg32T) =
  let io = state.io
  var wrote, read: bool
  when reg is Reg8T:
    read = (io.lastRegRead.reg8.canGet(r) and r == reg)
    wrote = (io.lastRegWrite.reg8.canGet(w) and w == reg)

  elif reg is Reg16T:
    read = (io.lastRegRead.reg16.canGet(r) and r == reg)
    wrote = (io.lastRegWrite.reg16.canGet(w) and w == reg)

  elif reg is Reg32T:
    read = (io.lastRegRead.reg32.canGet(r) and r == reg)
    wrote = (io.lastRegWrite.reg32.canGet(w) and w == reg)

  showReg(
    $reg,
    toHex(state.full.emu.cpu[reg]),
    if wrote: ioIn
    elif read: ioOut
    else: ioNone,
  )


var
  regWidths = (
    w32: 110i32,
    w16: 50i32,
    w8: 40i32,
    wName: 120i32,
  )

proc regTable(state: UiState) =
  let full = state.full
  let io = state.io
  let cpu = full.emu.cpu

  igTable("Registers", 4):
    igTableSetupColumns([
      ("32-bit", WidthFixed, regWidths.w32),
      ("16-bit", WidthFixed, regWidths.w16),
      ("8-bit", WidthFixed, regWidths.w8),
      ("Name", WidthFixed, regWidths.wName)
    ])
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
          igText("")
          igText(name)

    igRows():
      igColumns():
        igText("Program counter")

      igColumns():
        showReg("EIP", cpu.getEip().toHex(), ioNone)
        showReg("IP", cpu.getIp().toHex(), ioNone)
        igText("")
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
          igText("")
          igText(name)

const
  memConf = (
    perRow: 8,
    cellWidth: 15i32,
    prefixWidth: 40i32
  )

proc memTable(
    state: UiState, perRow: int = memConf.perRow, memStart: int = 0) =
  let full = state.full
  igTable("memory", perRow + 1, orEnum([Borders, BordersInnerH, BordersInnerV])):
    igTableSetupColumn(
      "", WidthFixed, memConf.prefixWidth.float32())

    for mem in 0 ..< perRow:
      igTableSetupColumn(
        "+" & toHexTrim(mem),
        WidthFixed, memConf.cellWidth.float32())

    igTableHeadersRow()

    for line in ceil(float(memStart) / perRow).int ..
                ceil(float(memStart + state.memEnd) / perRow).int:

      igTableNextRow()
      igTableSetColumnIndex(0)
      igText("0x" & toHexTrim(line * perRow).align(3, '0'))
      var hasValue = false
      for idx in 0 ..< perRow:
        let cell = line * perRow + idx

        igTableSetColumnIndex(idx.int32 + 1)
        if cell < state.memEnd:
          hasValue = true
          let isEip = cell.U32 == full.emu.cpu.getEip()
          if isEip:
            igTableSetBgColor(CellBg, igGetColorU32(igCol32(120, 20, 20)))

          igText(toHex(getMem(full, EPointer(cell))))
          if isEip:
            igTooltip():
              igText(
                "Current value of the EIP is $#" % [
                  toHex(full.emu.cpu.getEip())])


proc cb(data: ptr ImGuiInputTextCallbackData): int32 {.cdecl.} =
  discard
  # glob.codeLen = data.bufTextLen



proc codeEdit(state: UiState) =
  igInputTextMultiline(
    "",
    state.codeText.cstring,
    0xFFFF,
    # flags = ImGuiInputTextFlags.CallbackEdit,
    # callback = cb,
  )



proc igLogic(state: UiState) =
  let full = state.full

  ## Main entry point for the visualization logic
  # igSetNextWindowSize(igVec(600, 600))
  igWindow("Main window TMP"):
    if igButton("Next"):
      state.io = UiIo()
      full.step()

    full.logger.noLog():
      const memw = ((memConf.perRow + 1) * (memConf.cellWidth + 5)) +
            (memConf.prefixWidth + 40)

      igMainMenuBar():
        igMenu("File"):
          if igMenuItem(
            "Load binary",
            "Load compiled binary file into memory, startin at position 0"):

            echov "Selected file open"

          if igMenuItem(
            "Load state",
            "Load saved emulator state from file"):

            echov "Selected state open"

          if igMenuItem(
            "Save state",
            "Save current emulator state from file"):

            echov "Selected state save"

          if igMenuItem(
            "Save logs",
            "Save current event logs to file"):

            echov "Selected logs save"

        igMenu("Show/hide"):
          igMenuItemToggleBool(
            "Show port IO",
            "Hide port IO",
            state.showSections.showPortIO
          )

          igMenuItemToggleBool(
            "Show memory IO",
            "Hide memory IO",
            state.showSections.showMemoryIO
          )

      igTable("table", 3, BordersV):
        igTableSetupColumn("Memory", WidthFixed, float32(memw))
        igTableSetupColumn("Input code")
        igTableSetupColumn(
          "Registers",
          WidthFixed,
          float32(
            regWidths.w32 +
            regWidths.w16 +
            regWidths.w8 +
            regWidths.wName))

        igTableHeadersRow()

        igRows():
          igColumns():
            memTable(state)
            igItemWidth(-1):
              codeEdit(state)
            regTable(state)



proc event(state: UiState, ev: EmuEvent) =
  state.events.add  ev
  echov ev.kind
  var io {.byaddr.} = state.io
  case ev.kind:
    of eekGetReg8: io.lastRegRead.reg8 = some Reg8T(ev.memAddr)
    of eekSetReg8: io.lastRegWrite.reg8 = some Reg8T(ev.memAddr)
    else:
      discard

proc main() =
  assert glfwInit()

  var full = initFull(EmuSetting(memSize: 256))
  full.emu.cpu.setEip(0)
  var uiState = UiState(full: full, memEnd: 256)
  full.logger.setHook(proc(ev: EmuEvent) = event(uiState, ev))

  uiState.codeText = """
mov ax, 2
mov bx, 2
mov cx, 2
hlt
"""

  full.compileAndLoad(uiState.codeText)


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

  igStyleColorsLight(igGetStyle())

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
