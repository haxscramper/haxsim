import imgui, imgui/[impl_opengl, impl_glfw]
import nimgl/[opengl, glfw]
import std/[
  strformat,
  colors,
  sugar,
  compilesettings,
  strutils,
  macros,
  math,
  algorithm,
  tables,
  lenientops,
  times,
  sequtils,
  os
]

import tinyfiledialogs

import hmisc/hasts/json_serde
import maincpp, eventer, common
import hmisc/algo/[lexcast, clformat_interpolate, clformat]
import hmisc/types/colorstring
import instruction/instruction
import emulator/[emulator, interrupt]
import compiler/[assembler, external]
import device/[vga, dev_io]
import hardware/[processor, hardware, eflags, memory]
import hmisc/core/all
import hmisc/other/oswrap


proc formatTrace*(ex: ref Exception): string =
  const root = querySetting(projectFull).splitFile().dir
  for e in ex.getStackTraceEntries():
    let rel = relativePath($e.filename, root)
    result.add $rel
    result.add "("
    result.add $e.line
    result.add ") "
    result.add $e.procname
    result.add "\n"

proc getValue8*(ev: EmuEvent): U8 = fromMemBlob[U8](ev.value.value)
proc getValue16*(ev: EmuEvent): U16 = fromMemBlob[U16](ev.value.value)
proc getValue32*(ev: EmuEvent): U32 = fromMemBlob[U32](ev.value.value)

proc getMem*(full: FullImpl, memAddr: EPtr): EByte =
  ## Return value from the specified location in the physica memory
  full.emu.mem.memory[memAddr]

proc setMem*(full: FullImpl, memAddr: EPtr, value: EByte) =
  ## Set value at the specified location in the physical memory
  full.emu.mem.memory[memAddr] = value


proc writeJson(writer: var JsonSerializer, value: EmuEvent) =
  writeJsonObject(writer, value, multiline = false, isAcyclic = true)

proc writeJson(writer: var JsonSerializer, value: EmuLogger) =
  writeJsonObject(writer, value, multiline = false, isAcyclic = true)

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

proc igDrag*(label: string, value: var I32) =
  igDragInt(label.cstring, addr value)

template igPopup*(name: string, body: untyped): untyped =
  if igBeginPopupContextItem(name):
    try:
      body

    finally:
      igEndPopup()

proc igText*(args: varargs[string, `$`]) =
  ## Imgui text widget construction call overload with automatic string
  ## conversion
  let str = args.join("")
  igText(str.cstring())

proc igTextf*(fmt: string, args: varargs[string, `$`]) =
  ## Create imgui text using string formatting from strformat. Usage is
  ## identical to regular `strutils.format`
  let str = format(fmt, args)
  igText(str)

macro igRows*(body: untyped): untyped =
  ## Splice each statement in bodu with `igTableNextRow()`. Shortcut for
  ## creating a single table row.
  result = spliceEach(body, newCall("igTableNextRow"))

macro igColumns*(body: untyped): untyped =
  ## Splice each statement in body with sequentually increasing column
  ## numbers. `igText("A"); igText("B")` -> `igTableSetColumnIndex(0); igText("A")`
  var idx = 0
  result = spliceEach(body, newCall("igTableSetColumnIndex", newLit(postInc(idx))))

template igNextColumns*(body: untyped): untyped =
  igTableNextRow()
  igColumns(body)

macro igLines*(body: untyped): untyped =
  result = spliceEach(body, newCall("igSameLine"))

proc igSliderInt*(
    name: string,
    value: var I32,
    vmin: I32 = -100i32,
    vmax: I32 = 100i32,
    valueFormat: string = "%d",
    flags: ImGuiSliderFlags = ImGuiSliderFlags(0)
  ): bool =

  return igSliderInt(
    name.cstring, addr value, vmin, vmax, valueFormat.cstring, flags)


proc igInputText*(
    label: string,
    text: var string,
    flags: ImGuiInputTextFlags = 0.ImGuiInputTextFlags,
    bufferSize: int = 64
  ) =
  var buffer = newString(text.len + bufferSize)
  buffer[0 .. text.high] = text
  igInputText(label.cstring, buffer.cstring, buffer.len.uint, flags)
  text = buffer

template igMainMenuBar*(body: untyped): untyped =
  ## Construct imgui menu bar
  if igBeginMainMenuBar():
    try:
      body

    finally:
      igEndMainMenuBar()

template igMenu*(name: string, body: untyped): untyped =
  ## Start new imgui menu item
  if igBeginMenu(name):
    try:
      body

    finally:
      igEndMenu()

template igMenu*(name, tooltip: string, body: untyped): untyped =
  igMenu(name):
    body

  igTooltip():
    igText(tooltip)

template igItemWidth*(w: float, body: untyped): untyped =
  igPushItemWidth(w)
  try:
    body

  finally:
    igPopItemWidth()

proc igTableSetupColumns*(names: openarray[string]) =
  ## Configure names of the header row for table
  for name in names:
    igTableSetupColumn(name)
  igTableHeadersRow()

proc igTableSetupColumns*(names: openarray[tuple[
    name: string,
    flags: ImGuiTableColumnFlags,
    width: I32
  ]]) =

  ## Configure names of the header row for table
  for (name, flags, width) in names:
    igTableSetupColumn(name, flags, width.float)

  igTableHeadersRow()


proc igTableSetupColumnWidths*(widths: openarray[I32]) =
  for idx, width in widths:
    igSetColumnWidth(idx.I32, width.float)

template igGroup*(body: untyped): untyped =
  igBeginGroup()
  try:
    body

  finally:
    igEndGroup()

template igWindow*(
    name: string,
    flags: ImGuiWindowFlags = ImGuiWindowFlags.None,
    body: untyped): untyped =
  ## Create new imgui window
  igBegin(name, nil, flags)
  try:
    body
  finally:
    igEnd()


template igWindow*(
    name: string,
    isOpen: var bool,
    flags: ImGuiWindowFlags = ImGuiWindowFlags.None,
    body: untyped): untyped =
  ## Create new imgui window
  igBegin(name, addr isOpen, flags)
  try:
    body
  finally:
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
  if igBeginTable(name, columns.I32):
    try:
      body

    finally:
      igEndTable()

template igTab*(name: string, body: untyped): untyped =
  if igBeginTabItem(name):
    body
    igEndTabItem()

template igTabBar*(name: string, body: untyped): untyped =
  if igBeginTabBar(name):
    try:
      body

    finally:
      igEndTabBar()

proc igCheckBox*(label: string, value: var bool): bool =
  igCheckBox(label.cstring, addr value)

template igTooltip*(body: untyped): untyped =
  ## If previous item is hovered on, show tooltip described by `body`
  if igIsItemHovered():
    igBeginTooltip()
    try:
      body

    finally:
      igEndToolTip()

proc igTooltipText*(text: string) =
  ## If previous element is hovered on, show tooltip with provided text
  igTooltip():
    igtext(text)

proc igMenuItemToggleBool*(name, hint: string, value: var bool) =
  if igMenuItem(name):
    value = not value

  igTooltipText(hint)

proc igButton*(name, tip: string): bool =
  result = igButton(name)
  igTooltipText(tip)

proc igTooltipNum*(num: SomeInteger) =
  ## If previous element is hovered on, show tooltip with more elaborate
  ## description of the unsgined integer value
  igTooltip():
    igText(&"""
bin: {toBin(num, 8 * sizeof(num))}
dec: {num}
hex: {toHex(num)}
""")

proc igHexText*(num: SomeInteger, trim: bool = false) =
  ## Show hexadecimal text field, and if the item is hovered on, provide
  ## tooltip with more elaborate description
  if trim:
    igText(toHexTrim(num))

  else:
    igText(toHex(num))

  igTooltipNum(num)

proc igMenuItem*(name, tooltip: string): bool =
  ## Create menu item with given name and tooltip. Tooltip is shown in the
  ## regular text widget.
  result = igMenuItem(name)
  igTooltip():
    igText(tooltip)

proc igVec*(x, y: float): ImVec2 = ImVec2(x: x, y: y)
proc igVec*(x, y, z, w: float): ImVec4 = ImVec4(x: x, y: y, z: z, w: w)
proc igCol32*(r, g, b: U8, a: U8 = 255): U32 =
  (a.U32 shl 24) or (b.U32 shl 16) or (g.U32 shl 8) or (r.U32)

proc igColor*(color: Color, alpha: U8 = 255): U32 =
  let (r, g, b) = color.extractRgb()
  return igGetColorU32(igCol32(r.U8, g.U8, b.U8, alpha))

proc igVec*(color: Color, alpha: U8 = 255): ImVec4 =
  let (r, g, b) = color.extractRgb()
  return ImVec4(x: r.float, y: g.float, z: b.float, w: alpha.float)

proc igTableBg*(
    color: Color,
    target: ImGuiTableBgTarget = CellBg,
    alpha: U8 = 255) =

  igTableSetBgColor(target, igColor(color, alpha))

type
  UiIo = object
    lastRegWrite, lastRegRead: tuple[
      reg8: Option[Reg8T],
      reg16: Option[Reg16T],
      reg32: Option[Reg32T]
    ]


  StoredState = object
    cpu: ProcessorObj
    mem: MemoryObj
    inPorts, outPorts: Table[U16, PortIoItem]
    time: DateTime

  PortIoItem = object
    size: HadData
    data: U32

  UiState = ref object
    ## Global state of the UI
    full: FullImpl ## Reference to the implementation core
    io: UiIo ## Stored information about last IO performed by the emulator
    ## core. Set and unset in the event processing hook. Note that 'IO'
    ## here means any input-ouput operation performed by core on it's
    ## memory, registers, ports, memory-mapped devices AND any external
    ## elements.
    codeText: string ## Current code inputed by user
    eventShow: bool ## Intermediate field, used in event processing hook.
    ## If true event is added int global list of events, otherwise it is
    ## ignored. Set and unset in the hook
    eventStack: seq[EmuEventKind] ## Intermediate field used in event
    ## processing hook. Stores full trace of the current event parents in
    ## order to determine if the event should be ignored.
    events: seq[tuple[level: int, ev: EmuEvent]] ## Stored list of all the
    ## processed events
    memEnd: int ## Max range of memory to show in the editor widget
    compileRes: string ## Message from the compilation result

    pointedMem: Slice[EPtr] ## If user is currently hovering over widget
    ## that shows memory address
    states: seq[StoredState] ## List of previous compilation states, stored
    ## in the widget.
    userInPorts, userOutPorts: Table[U16, PortIoItem] ## For ports that are
    ## not automatically connected to other pats of the compiler but
    ## provided by user instead.
    autoExec: bool ## Automatically execute "next" step. Note - this is
    ## different from "exec all" button. First one is just an automation
    ## for repeated "step" press. Second one disconnects all logging,
    ## executes block of code until `hlt` or exception is encountered and
    ## then connects things back.

    autoCleanOnCompile: bool ## Automatically wipe memory and other state
    ## if input code recompilation was requested.
    showSections: tuple[
      showPortIo, showMemoryIo, showVGA: bool,
      interrupts, interruptQueue: bool,
      loggingTable, stateRestore, disassembler: bool,
      settings: bool
    ] ## Which extra windows to show in the GUI

    portInHistory, portOutHistory: Table[U16, seq[PortIoItem]] ##  Full
    ## port history - each time 'read' or 'write' event is triggered it is
    ## written in here.

    vgaImage: VgaImage ## Current active VGA image, if any. It is expensive
                       ## to compute each time, so vga has `needsRefresh`
                       ## flag, and we only update image if it has changed.
    lastStepErr: ref CatchableError ## Last error in the instruction
    ## evaluation. Only catches certain errors, such as out-of-memory
    ## checks in the emulator. Other things are bubbled up. Set if `step()`
    ## raied exception, and is reset on the next step (if user decides to
    ## proceed ignoring error). If non-nil, automatic evaluation stops
    ## until further notice.


proc igMemText*(state: UiState, mem, final: EPtr) =
  igText(toHex(mem))
  igTooltip():
    igText(toHex(state.full.getMem(mem)))
    state.pointedMem = mem .. final

type RegIO = enum ioIn, ioOut, ioNone
proc showReg(name, value: string, io: RegIO) =
  case io:
    of ioIn:
      igTableSetBgColor(CellBg, igColor(colRed, 30))

    of ioOut:
      igTableSetBgColor(CellBg, igColor(colGreen, 30))

    else:
      discard

  igTextf("$# $#", name, value)

proc showReg(state: UiState, reg: Reg8T | Reg16T | Reg32T) =
  let io = state.io
  var wrote, read: bool
  when reg is Reg8T:
    read = (io.lastRegRead.reg8.canGet(rv) and rv == reg)
    wrote = (io.lastRegWrite.reg8.canGet(w) and w == reg)

  elif reg is Reg16T:
    read = (io.lastRegRead.reg16.canGet(rv) and rv == reg)
    wrote = (io.lastRegWrite.reg16.canGet(w) and w == reg)

  elif reg is Reg32T:
    read = (io.lastRegRead.reg32.canGet(rv) and rv == reg)
    wrote = (io.lastRegWrite.reg32.canGet(w) and w == reg)

  showReg(
    $reg,
    toHex(state.full.emu.cpu[reg]),
    if wrote: ioIn
    elif read: ioOut
    else: ioNone,
  )

proc eventLog(state: UiState) =
  let emu = state.full.emu
  let max = state.events.high
  let evRange = clamp(max - 10, 0, high(int)) .. max

  igTable("events", 5):
    igTableSetupColumns([
      ("Id",    WidthFixed,   30i32),
      ("Level", WidthStretch, 30i32),
      ("Desc",  WidthStretch, 40i32),
      ("Addr",  WidthStretch, 120i32),
      ("Value", WidthStretch, 120i32)
    ])

    for id in evRange:
      let (level, ev) = state.events[id]
      var addrs: string
      var value: string

      if ev.kind in eekValueKinds:
        value = $ev.value
        case ev.kind:
          of eekGetReg8, eekSetReg8:
            addrs = format("$# ($#)", Reg8T(ev.memAddr), ev.memAddr)

          of eekGetReg16, eekSetReg16:
            addrs = format("$# ($#)", Reg16T(ev.memAddr), ev.memAddr)

          of eekGetReg32, eekSetReg32:
            addrs = format("$# ($#)", Reg32T(ev.memAddr), ev.memAddr)

          of eekSetDtRegBase .. eekGetDtRegSelector:
            addrs = $DtRegT(ev.memAddr)

          of eekGetSegment, eekSetSegment:
            addrs = $SgRegT(ev.memAddr)

          of eekSetMem8 .. eekGetMem32, eekSetIo8 .. eekGetIo32:
            let s = log2(emu.mem.len().float()).int()
            addrs = "0x" & toHex(ev.memAddr)[^s .. ^1]

          of eekEndInstructionFetch:
            addrs = ev.msg
            value = ev.value.value.mapIt(toHex(it, 2)).join(" ")

          else:
            discard


      igRows():
        igColumns():
          igText(id)
          igText(repeat("> ", level))
          igText(ev.kind)
          igText(addrs)
          igText(value)

proc tooltip(cpu: ProcessorObj): string =
  template h(it: untyped): untyped = toHex(cpu[it])

  cpu.logger.noLog():
    result = $clfmt"""
EFLAGS:  {toBin(cpu.eflags.getEflags(), 32)}
                       111111110000000000
                       765432109876543210
                       ||||||||||||||||||
                       VR N`IODITSZ A P1C
                            O
EIP: {toHex(cpu.eip):<   }  P
IP:      {toHex(cpu.ip):<}  L

EAX: {h(EAX):<     } ESP: {h(ESP)}
AX:      {h(AX):<  } SP:      {h(SP)}
AH:      {h(AH):<  } EBP: {h(EBP)}
AL:        {h(AL):<} BP:      {h(BP)}
ECX: {h(ECX):<     } ESI: {h(ESI)}
CX:      {h(CX):<  } SI:      {h(SI)}
CH:      {h(CH):<  } EDI: {h(EDI)}
CL:        {h(CL):<} DI:      {h(DI)}
EBX: {h(EBX):<     }
BX:      {h(BX):<  } CS:  {toHex(cpu.getSgReg(CS).raw)}
BH:      {h(BH):<  } DS:  {toHex(cpu.getSgReg(DS).raw)}
BL:        {h(BL):<} ES:  {toHex(cpu.getSgReg(ES).raw)}
EDX: {h(EDX):<     } FS:  {toHex(cpu.getSgReg(FS).raw)}
DX:      {h(DX):<  } GS:  {toHex(cpu.getSgReg(GS).raw)}
DH:      {h(DH):<  } SS:  {toHex(cpu.getSgReg(SS).raw)}
DL:        {h(DL):<}
"""

proc stateStore(state: UiState) =
  proc portTable(ports: Table[U16, PortIoItem]) =
    igTable("ports", 2):
      for idx in toSeq(keys(ports)).sorted():
        igRows():
          igColumns():
            igText($idx)
            case ports[idx].size:
              of Data8: igHexText(ports[idx].data.U8())
              of Data16: igHexText(ports[idx].data.U16())
              of Data32: igHexText(ports[idx].data.U32())
              of NoData: igText("")

  const perRow = 8

  igTable("Stored state", 6):
    igTableSetupColumns([
      ("Time", WidthFixed, 200i32),
      ("Full", WidthFixed, 70i32),
      ("CPU", WidthFixed, 270i32),
      ("Memory", WidthFixed, I32(24 * perRow + 30)),
      ("In port", WidthFixed, 120i32),
      ("Out port", WidthFixed, 120i32)
    ])

    var restoreFull = false
    var usedFull = false # I can't set 'restore full' to false immediately,
                         # because that would prevent other values to be
                         # assigned. Instead I need to check if 'full' has
                         # actually been used, and change it only after all
                         # possible assignments have been completed.

    for saved in state.states:
      igRows():
        igColumns():
          igText(format(isoDateFmtMsec, saved.time))
          if igButton("All"):
            restoreFull = true

          igText(saved.cpu.tooltip())
          igText(saved.mem.dumpMem(perRow = perRow))
          portTable(saved.inPorts)
          portTable(saved.outPorts)

        igColumns():
          igText("")
          igText("")
          if igButton("CPU restore") or restoreFull:
            state.full.emu.cpu[] = saved.cpu
            usedFull = restoreFull

          if igButton("MEM restore") or restoreFull:
            state.full.emu.mem[] = saved.mem
            usedFull = restoreFull

          if igButton("In port restore") or restoreFull:
            state.userInPorts = saved.inPorts
            usedFull = restoreFull

          if igButton("Out port restore") or restoreFull:
            state.userOutPorts = saved.outPorts
            usedFull = restoreFull

      if usedFull:
        restoreFull = false


          

proc currentState(state: UiState): StoredState =
  StoredState(
    cpu: state.full.emu.cpu[],
    mem: state.full.emu.mem[],
    inPorts: state.userInPorts,
    outPorts: state.userOutPorts,
    time: now()
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

        igTableSetColumnIndex(idx.I32 + 1)
        if cell < state.memEnd:
          hasValue = true
          let isEip = cell.U32 == full.emu.cpu.getEip()
          if isEip or (cell.EPtr in state.pointedMem):
            igTableSetBgColor(CellBg, igColor(colRed, 30))

          igText(toHex(getMem(full, EPtr(cell))))
          if isEip:
            igTooltip():
              igText(
                "Current value of the EIP is $#" % [
                  toHex(full.emu.cpu.getEip())])

proc diassebmler(state: UiState) =
  let eipstart = state.full.emu.cpu.eip
  var full = state.full
  full.emu.cpu.eip = 0
  full.logger.noLog(): igTable("disassembler table", 8, orEnum([
    Resizable,
    ImGuiTableFlags.Reorderable
  ])):
    igTableSetupColumns([
      ("Pref", WidthFixed, 30i32),
      ("Raw", WidthFixed, 200i32),
      ("Opc", WidthFixed, 35i32),
      ("Desc", WidthStretch, 0i32),
      ("MODRM", WidthFixed, 30i32),
      ("SIB", WidthFixed, 30i32),
      ("DISP", WidthFixed, 80i32),
      ("IMM", WidthFixed, 80i32),
      # ("Edit flags", WidthStretch, 0i32),
      # ("Read flags", WidthStretch, 0i32)
    ])

    for cmd in full.parseCommands(toHlt = false, toMem = EPointer(0xFF)):
      igRows():
        igColumns():
          # Prefix
          block:
            if eipstart in cmd.instrRange.start .. cmd.instrRange.final:
              igTableBg(colRed, RowBg0, 30)

            if cmd.preSegment.canGet(seg):
              igText($seg)
              igSameLine()

            let mode32 = full.emu.cpu.isMode32()

            if cmd.opSizeOverrideExplicit:
              igText("66")
              igTooltipText("Size override prefix")
              igSameLine()

            if cmd.addrSizeOverrideExplicit:
              igText("67")
              igTooltipText("Address override prefix")

          # Raw
          block:
            igMemText(
              state,
              cmd.instrRange.start,
              cmd.instrRange.final
            )

            igSameLine()

            var text: string = " = "
            var first = true
            for idx in cmd.instrRange.start .. cmd.instrRange.final:
              if not first: text.add " "
              first = false
              text.add(toHex(full.getMem(idx)))

            igText(text)

          # Opc
          igHexText(cmd.opcodeData.code)

          # Description
          igText($cmd.opcodeData.code.toOpcode())

          # Modrm
          if cmd.hadModrm:
            igHexText(cast[U8](cmd.modrm))

          else:
            igText("-")

          # DSIB
          if cmd.hadDSib:
            igText(cast[U8](cmd.dsib))

          else:
            igText("-")

          # DISP
          case cmd.hadDisp:
            of NoData: igText("-")
            of Data8: igHexText(cmd.fieldDisp.disp8)
            of Data16: igHexText(cmd.fieldDisp.disp16)
            of Data32: igHexText(cmd.fieldDisp.disp32)

          # IMM
          case cmd.hadImm:
            of NoData: igText("-")
            of Data8: igHexText(cmd.fieldImm.imm8)
            of Data16: igHexText(cmd.fieldImm.imm16)
            of Data32: igHexText(cmd.fieldImm.imm32)

  state.full.emu.cpu.eip = eipstart


proc vgaWindow*(state: UiState) =
  var vga = state.full.emu.vga
  igTabBar("Tab bar"):
    igTab("Text"):
      let buf = vga.txtBuffer()
      var res: string = "-----\n"
      for line in buf:
        res.add "["
        for (c, attr) in line:
          res.add tern(c == '\x00', ' ', c)

        res.add "]\n"

      res.add "-----"

      igText(res)

    igTab("Registers"):
      igText("VGA registers")

    igTab("Video"):
      if vga.needRefresh():
        vga.rgbImage(state.vgaImage)

      igText("VIDEO")



proc portHistory(state: UiState, its: seq[PortIoItem]) =
  var text: string
  for item in its:
    text.add toHex(
      item.data,
      case item.size:
        of Data8: 8
        of Data16: 16
        of Data32: 32
        of NoData: 0
    )

    text.add "\n"

  igText(text)

proc userPort(state: UiState, idx: U16) =
  var port {.byaddr.} = state.userInPorts[idx]
  let val = port.data.U8()
  let bitidx: array[8, U8] = [
    0: 0b0000_0001u8,
    1: 0b0000_0010u8,
    2: 0b0000_0100u8,
    3: 0b0000_1000u8,
    4: 0b0001_0000u8,
    5: 0b0010_0000u8,
    6: 0b0100_0000u8,
    7: 0b1000_0000u8,
  ]

  var res: U8
  for idx in 0 .. 7:
    var bit = bool(val and bitidx[idx])
    discard igCheckbox(&"{idx} = {tern(bit, '0', '1')}", bit)
    if bit:
      res = res or bitidx[idx]

    else:
      res = res and not bitidx[idx]

  igHexText(res)

  port.data = res

proc portWindow(state: UiState) =
  ## Construct widget with port IO information and configuration.
  var ports: seq[U16]
  for key, _ in state.portInHistory: ports.add key
  for key, _ in state.portOutHistory: ports.add key
  sort(ports)

  igTable("ports", 5, orEnum([Borders, RowBg])):
    igTableSetupColumns(["Addr", "IN", "", "OUT", ""])
    for port in ports:
      igNextColumns():
        igHexText(port)
        if port in state.portInHistory:
          portHistory(state, state.portInHistory[port])

        if port in state.userInPorts:
          userPort(state, port)

        else:
          igText("sys")
          igTooltipText("Port cannot be modified by user")

        if port in state.portOutHistory:
          portHistory(state, state.portOutHistory[port])




proc currentInstr(state: UiState) =
  let i = state.full.data

  igTable("Instruction data", 4):
    igTableSetupColumns(["Name", "Raw", "Decode", "Description"])
    igRows():
      igColumns():
        igText("Seg")
        if i.preSegment.canGet(seg):
          igText($seg)
        else:
          igText("none")

      igColumns():
        igText("MODRM")
        igText(toBin(cast[U8](i.modrm), 8))
        igTextf(
          "rm:$# reg:$# mod:$#",
          toBin(i.modrm.mod.uint, 2),
          toBin(i.modrm.reg.uint, 3),
          toBin(i.modrm.rm.uint, 3)
        )

      igColumns():
        igText("OPC")
        igText(toHexTrim(i.opcodeData.code))
        igText(toOpcode(i.opcodeData.code))

      igColumns():
        igText("IMM")
        igText(toHex(i.fieldImm.imm32.U32))


proc clearState(state: UiState) =
  let full = state.full
  full.logger.noLog():
    let cpu = full.emu.cpu[]
    initProcessor(full.emu.cpu, full.logger)
    full.emu.mem[] = initMemory(ESize(full.emu.mem.len()), full.logger)[]
    state.events.clear()

    full.emu.cpu.withResIt do:
      it.eip = cpu.eip



import hmisc/other/hpprint

proc codeEdit(state: UiState) =
  igInputTextMultiline(
    "",
    state.codeText.cstring,
    0xFFFF,
  )

  var compiled = false
  if igButton(
    "Compile",
    "Compile using built-in assembler implementation (note - experimental)"
  ):
    try:
      var prog = parseProgram($state.codeText.cstring)
      prog.compile()
      var bin = prog.data()

      compiled = true
      if state.autoCleanOnCompile:
        clearState(state)

      state.full.emu.loadBlob(bin, 0)

    except InstrParseError as ex:
      state.compileRes = &"Compilation failed: {ex.msg}"

  igSameLine()
  if igButton(
    "Compile via `nasm`",
    "Compile using external shell command 'nasm'"
  ):
    try:
      let asmf = getAppTempFile("stored_asm.asm")
      let binf = getAppTempFile("compiled_asm.bin")
      mkDir binf.dir()
      let code = $state.codeText.cstring
      asmf.writeFile(code)
      compileAsm(asmf, binf)
      compiled = true
      if state.autoCleanOnCompile:
        clearState(state)

      let f = readFile(binf)
      # echov f
      state.full.emu.loadBlob(f)

    except ShellError as ex:
      state.compileRes = &"Compilation failed: {ex.msg}"

  igSameLine()
  discard igCheckBox("Clean memory on compile", state.autoCleanOnCompile)
  igTooltipText("""
After each successful recompilation program memory
and CPU state is completely wiped""")

  if compiled:
    let nowfmt = now().format(isoDateFmtMsec)
    state.compileRes = &"Compilation OK at {nowfmt}"


  igText(state.compileRes)


proc menuBar(state: UiState) =
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
        let file = saveFileDialog("Save emulator state", "/tmp/state.json")
        if file.canGet(path):
          writeFile(path, toJson(state.full.emu.cpu))

      if igMenuItem(
        "Save logs",
        "Save current event logs to file"):

        let file = saveFileDialog("Save emulator logs", "/tmp/logs.json")
        if file.canGet(path):
          let str = withItWriter():
            it.writeJsonItems(state.events, multiline = true)

          writeFile(path, str)


    igMenu("Devices", "External devices"):
      igMenuItemToggleBool(
        "Port IO",
        "Toggle visibility of the port input/output operations",
        state.showSections.showPortIO
      )

      igMenuItemToggleBool(
        "Memory-mapped IO",
        "Toggle visibility of the memory-mapped input/ouput operations",
        state.showSections.showMemoryIO
      )

      igMenuItemToggleBool(
        "VGA",
        "VGA",
        state.showSections.showVga
      )

    igMenu(
      "State, loggin",
      "Show or hide operations related to logging, emulator state save"
    ):
      igMenuItemToggleBool(
        "Logging table",
        "Show or hide event log table",
        state.showSections.loggingTable
      )

      igMenuItemToggleBool(
        "Stored state list",
        "Show stored state list",
        state.showSections.stateRestore
      )

    igMenu(
      "Memory structures",
      "Additional visualization for in-memory data structures"):
        igMenuItemToggleBool(
          "Interrupt table",
          "Show IVT (interrupt vector table)",
          state.showSections.interrupts
        )

        igMenuItemToggleBool(
          "Dissasembler",
          "Dissasembler",
          state.showSections.disassembler
        )

        igMenuItemToggleBool(
          "Interrupt queue",
          "Interrupt queue",
          state.showSections.interrupts
        )


proc mainWindow(state: UiState) =
  let full = state.full

  block:
    # Space for the main emnu bar
    const menuH = 18
    var size = igGetIO().displaySize
    size.y -= menuH
    # Configure positioning and size of the next ('main') window to occupy
    # the whole 'real' window.
    igSetNextWindowSize(size)
    igSetNextWindowPos(igVec(0, menuH))


  igWindow("Main window TMP" , orEnum([
    # Hide title bar, don
    NoTitleBar,
    # Don't focus on the 'main' window if it is pressed
    NoBringToFrontOnFocus,
    # Window is fixed in position and cannot be resized
    ImGuiWindowFlags.NoResize, NoMove
  ])):
    let cpu = state.full.emu.cpu
    var eipText {.global.}: string

    proc updateEip() =
      full.logger.noLog():
        eipText = "0x" & toHex(cpu.getEip())

    if eipText.len == 0:
      updateEip()

    discard igCheckBox("Exec all", state.autoExec)
    igSameLine()
    igText(&"FPS: {igGetIO().framerate:.2f}")

    igSameLine()
    # Either button was explicitly pressed or automatic execution is
    # enabled.
    if igButton("Step") or state.autoExec:
      full.logger.doLog():
        if cpu.eip < full.emu.mem.len().ESize():
          state.io = UiIo()
          try:
            full.step()
            state.lastStepErr = nil

          except EmuMemoryError as err:
            state.lastStepErr = err
            state.autoExec = false

          except EmuIoError as err:
            state.lastStepErr = err
            state.autoExec = false

          if full.emu.cpu.isHalt():
            state.autoExec = false

          updateEip()

    igSameLine()
    if igButton(
      "Store state",
      "Add current state to the list of stores"
    ):
      state.states.add state.currentState()

    igSameLine()
    if igButton(
      "Clear state",
      """Completely clean current emulator state,
including event lots, register values,
stored values in memory."""
    ):
      clearState(state)

    full.logger.noLog():

      igSameLine()
      if igButton("--EIP"):
        cpu.setEip(cpu.getEip() - 1)
        updateEip()

      igSameLine()

      if igButton("++EIP"):
        cpu.setEip(cpu.getEip() + 1)
        updateEip()

      igSameLine()

      if igButton("EIP=0"):
        cpu.setEip(0)
        updateEip()

      igSameLine()
      igItemWidth(240):
        igInputText("EIP", eipText, orEnum([CHarsHexadecimal, CharsUppercase]))
      igSameLine()
      if igButton("Load"):
        cpu.setEip(lexcast[U32](eipText))

      const memw = ((memConf.perRow + 1) * (memConf.cellWidth + 5)) +
            (memConf.prefixWidth + 40)

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

      currentInstr(state)
      let err = state.lastStepErr
      if err.notNil():
        igTextColored(
          igVec(colRed),
          &"""
User code error

err: {err.name}
msg: {err.msg.stripSgr()}
trc:
{formatTrace(err)}
"""

        )


proc igLogic(state: UiState) =
  ## Main entry point for the visualization logic
  let full = state.full

  state.pointedMem = high(EPtr)..high(EPointer)

  # Configure main menu bar
  menuBar(state)
  # Depending on the menu state, show movable 'additional' windows.
  var show {.byaddr.} = state.showSections
  if show.loggingTable:
    igWindow("Logging table", show.loggingTable):
      eventLog(state)

  if show.showVga:
    igWindow("VGA", show.showVga):
      vgaWindow(state)

  if show.stateRestore:
    igWindow("Stored state", show.loggingTable):
      stateStore(state)

  if show.disassembler:
    igWindow("Diassembler", show.disassembler):
      diassebmler(state)

  if show.showPortIO:
    igWindow("Port IO", show.showPortIO):
      portWindow(state)

  if show.interrupts:
    full.logger.noLog():
      igWindow("Interrupts", show.interrupts):
        igTable("interrupts", 5):
          let cpu = full.emu.cpu
          var mem = full.emu.mem
          igTableSetupColumns([
            ("IDX",     WidthFixed, 40i32),
            ("ADDR",    WidthFixed, 60i32),
            ("desc",    WidthStretch, 40i32),
            ("segment", WidthFixed, 70i32),
            ("offset",  WidthFixed, 70i32)
          ])
          # Iterate from the first interrupt to the last one, or until the
          # end of the memory (for demonstration purposes smaller memory
          # size could be used, which might lead to the truncated IVT)
          const ivts = sizeof(IVT).ESize()
          let base: EPtr = cpu.getDtregBase(IDTR)
          for idx in 0u8 .. 0xFFu8:
            let offset = EPtr(idx * ivts)
            let adr: EPtr = base + offset
            if mem.len() <= int(adr + ivts - 1):
              break

            let ivt = readDataBlob[IVT](mem, adr)
            igRows():
              igColumns():
                igText(toHex(idx))
                state.igMemText(adr, EPtr(adr + ivts - 1))
                igText("")
                igHexText(ivt.segment)
                igHexText(ivt.offset)


  # Show unmovable 'main' window
  mainWindow(state)



const hideList: set[EmuEventKind] = { eekStartInstructionFetch }

proc event(state: UiState, ev: EmuEvent) =
  var io {.byaddr.} = state.io
  case ev.kind:
    of eekGetReg8: io.lastRegRead.reg8 = some Reg8T(ev.memAddr)
    of eekSetReg8: io.lastRegWrite.reg8 = some Reg8T(ev.memAddr)
    of eekGetReg16: io.lastRegRead.reg16 = some Reg16T(ev.memAddr)
    of eekSetReg16: io.lastRegWrite.reg16 = some Reg16T(ev.memAddr)
    of eekGetReg32: io.lastRegRead.reg32 = some Reg32T(ev.memAddr)
    of eekSetReg32: io.lastRegWrite.reg32 = some Reg32T(ev.memAddr)
    of eekInIoDone, eekOutIo:
      let (data, val) = case ev.size.int:
        of 8: (Data8, ev.getValue8().U32())
        of 16: (Data16, ev.getValue16().U32())
        of 32: (Data32, ev.getValue32().U32())
        else: (NoData, 0u32)

      if ev.kind == eekOutIo:
        state.portOutHistory.mgetOrPut(ev.memAddr.U16, @[]).add PortIoItem(
          size: data, data: val
        )

      else:
        state.portInHistory.mgetOrPut(ev.memAddr.U16, @[]).add PortIoItem(
          size: data, data: val
        )

    else:
      discard

  if ev.kind in eekEndKinds:
    if state.eventStack.pop() in hideList:
      state.eventShow = true

    return

  state.events.add((state.eventStack.len, ev))

  if ev.kind in eekStartKinds:
    if ev.kind in hideList:
      state.eventShow = false

    state.eventStack.add ev.kind



proc main() =
  assert glfwInit()
  var text = """
mov dx, 0x3C2
mov al, 0b10
out dx, al

mov dx, 0x3C4
mov al, 0x02
out dx, al

mov dx, 0x3C5
mov al, 0b11
out dx, al

mov dx, 0x03b4
mov al, 0x1
out dx, al
mov dx, 0x03b5
mov al, 0x28
out dx, al

mov dx, 0x03b4
mov al, 0x12
out dx, al
mov dx, 0x03b5
mov al, 0x19
out dx, al

mov ebx, 0xB8000
mov byte [ebx], 65
mov byte [ebx+1], 0x7
hlt

in al, 0x5
in al, 0x5
in al, 0x5
in al, 0x5
in al, 0x5
"""

  if false:
    text = """
in al, 0x5
in al, 0x5
in al, 0x5
in al, 0x5
in al, 0x5
"""

  let size = 256
  var full = initFull(EmuSetting(memSize: size.ESize()))
  full.emu.cpu.setEip(0)
  var uiState = UiState(
    full: full,
    memEnd: size,
    eventShow: true,
    autoCleanOnCompile: true,
    codeText: text,
    autoExec: false
  )

  var io = full.emu.accs.io

  # Create ports indexed from zero to fifteen, and create associated
  # closures. In future this should probably be configurable, but for the
  # purposes of demonstration it is more than enough.
  for idx in 0u16 .. 0xFu16:
    uiState.userOutPorts[idx] = PortIoItem(size: Data8)
    uiState.userInPorts[idx] = PortIoItem(size: Data8)
    capture idx:
      io.setPortIO(idx, 1, initPortIO(
        &"Port {idx}",
        proc(port: U16): U8 = uiState.userInPorts[idx].data.U8(),
        proc(port: U16, v: U8) = uiState.userOutPorts[idx].data = U32(v)
      ))

  uiState.showSections.showPortIO = true
  full.addEchoHandler()
  let hook = full.logger.eventHandler
  full.logger.setHook(
    proc(ev: EmuEvent) =
      hook(ev)
      event(uiState, ev)
  )

  full.compileAndLoad(uiState.codeText)


  glfwWindowHint(GLFWContextVersionMajor, 4)
  glfwWindowHint(GLFWContextVersionMinor, 1)
  glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE)
  glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
  glfwWindowHint(GLFWResizable, GLFW_TRUE)

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
  var counter: I32 = 0

  igStyleColorsLight(igGetStyle())

  var errText = ""
  while not w.windowShouldClose:
    glfwPollEvents()

    igOpenGL3NewFrame()
    igGlfwNewFrame()
    igNewFrame()

    try:
      # Call main logic implementation function
      if errText.empty():
        igLogic(uiState)

      else:
        igWindow("Error"):
          igText(errText)
          igPopup("Copy RMB"):
            if igButton("Copy"):
              igSetClipboardText(errText)
              igCloseCurrentPopup()

    except Exception as ex:
      errText = &"""
Exception occured in the main core implementation

Name: {ex.name}
Msg:
{ex.msg}
Trace:
{getStackTrace(ex)}
"""

      echo errText

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
  echo "ended"

let params = getCommandLineParams()
if not params.empty() and params.first() == "run":
  main()
