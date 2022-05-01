{.pragma: pr, header: "sokol.c" .}
{.pragma: pri, header: "sokol.c" .}
{.pragma: st, header: "sokol.c" .}

type
  SappDesc* {.importc: "struct sapp_desc", st.} = object
    init_cb*: proc() {.cdecl.}
    frame_cb*: proc() {.cdecl.}
    cleanup_cb*: proc() {.cdecl.}
    event_cb*: proc(ev: ptr SappEvent) {.cdecl.}
    window_title*: cstring

  SimGuiDesc* {.importc: "simgui_desc_t", st.} = object
    max_vertices*: cint

  SgContextDesc* {.importc: "sg_context_desc", st.} = object

  SappEvent* {.importc: "sapp_event", st.} = object

  # SgBindings* {.importc: "sg_bindings", st.} = object


  SgDesc* {.importc: "sg_desc", st.} = object
    context*: SgContextDesc

  SgAction* {.importc: "sg_action", st.} = enum
    SG_ACTION_CLEAR = 1

  SgColorAttachmentAction* {.importc: "sg_color_attachment_action", st.} = object
    val*: array[4, float]
    action*: SgAction

  SgPassAction* {.importc: "sg_pass_action", st.} = object
    colors*: array[4, SgColorAttachmentAction]

  # SappPassAction* {.importc: "struct sapp_pass_action", st.} = object

proc sapp_sgcontext*(): SgContextDesc {.pri.}
proc sapp_width*(): cint {.pri.}
proc sapp_height*(): cint {.pri.}
proc sapp_frame_duration*(): cint {.pri.}
proc sapp_dpi_scale*(): cint {.pri.}

proc sg_begin_default_pass*(act: ptr SgPassAction, w: cint, h: cint) {.pri.}
proc sg_commit*() {.pri.}
proc sg_end_pass*() {.pri.}
proc sg_shutdown*() {.pri.}
proc sg_setup*(desc: ptr SgDesc) {.pri.}

proc simgui_setup*(desc: ptr SimguiDesc) {.pri.}
proc simgui_render*() {.pri.}
proc simgui_shutdown*() {.pri.}
proc simgui_new_frame*(width, height: cint, delta: float) {.pri.}
proc simgui_handle_event*(ev: ptr SappEvent) {.pri.}


proc stm_setup*() {.pri.}
proc stm_sec*(f: float): float {.pri.}
proc stm_round_to_common_refresh_rate*(a: float): float {.pri.}
proc stm_laptime*(prev: ptr uint64): float {.pri.}


import nimgl/imgui
import std/strformat
import hmisc/core/all
import em_sokol
import hmisc/algo/procbox
import cpus/i386/maincpp
import cpus/i386/emulator/emulator
import cpus/i386/compiler/assembler

var global: int

type
  GlobalState = ref object
    codeLen*: int
    codeText*: string
    full*: FullImpl

var glob: GlobalState

var state: tuple[
  passAction: SgPassAction,
  laptime: uint64,
  text: string
]

template printedTrace*(body: untyped) =
  try:
    body

  except:
    echo "writing stack trace"
    writeStackTrace()
    echo "done stack trace"
    raise

proc initImpl*(): void {.cdecl.} =
  startHax()

  echo "Started hax"
  var glob = GlobalState(
    codeText: """
label:
  mov ax, bx
""")

  glob.codeLen = glob.codeText.len
  glob.codeText.setLen(0xFFFF)
  printedTrace():
    var desc = SgDesc(context: sapp_sgcontext())
    sg_setup(addr desc)
    stm_setup()
    var tmp = SimGuiDesc(maxVertices: 0)
    simgui_setup(addr tmp)

    state.pass_action = SgPassAction()
    state.pass_action.colors[0] = SgColorAttachmentAction(
      action: SG_ACTION_CLEAR,
      val: [0.0, 0.5, 0.5, 1.0]
    )

template igMainMenuBar*(body: untyped): untyped =
  if igBeginMainMenuBar():
    body
    igEndMainMenuBar()

template igMenu*(name: string, body: untyped): untyped =
  if igBeginMenu(name):
    body
    igEndMenu()

proc igVec*(x, y: float): ImVec2 = ImVec2(x: x, y: y)

proc igCol32*(r, g, b: uint8, a: uint8 = 255): uint32 =
  (a.uint32 shl 24) or (b.uint32 shl 16) or (g.uint32 shl 8) or (r.uint32)

proc cb(data: ptr ImGuiInputTextCallbackData): int32 {.cdecl.} =
  glob.codeLen = data.bufTextLen

proc loopImpl*() {.cdecl.} =
  printedTrace():
    let width = sappWidth()
    let height = sappHeight()
    let deltaTime = stm_sec(stm_round_to_common_refresh_rate(
      stm_laptime(addr state.laptime)))

    simgui_new_frame(width, height, delta_time)

    igMainMenuBar():
      igMenu("Test menu"):
        if igMenuItem("Test item"):
          echo "Selected test menu item"

        if igMenuItem("Other item"):
          echo "Selected other test item"

    igEnd()

    igSetNextWindowPos(igVec(40, 40), ImGuiCond.Once, igVec(0, 0))
    igSetNextWindowSize(igVec(400, 400), ImGuiCond.Once)

    igBegin("Main window TMP", nil, ImGuiWindowFlags.None)

    igInputTextMultiline(
      "Label",
      glob.codeText.cstring,
      0xFFFF,
      flags = ImGuiInputTextFlags.CallbackEdit,
      callback = cb,
    )

    if igButton("Init"):
      echo "pressed button 'init'"
      var emuSet: EmuSetting
      emuset.memSize = 0xFFFF
      glob.full = initFull(emuSet)
      let code = ($glob.codeText)[0 .. glob.codeLen]
      echo "code range"
      assert false, "ERROR MESSAGE"
      echo "after assert false triggered"
      var prog = parseProgram(code)
      echo "parsed program"
      prog.compile()
      echo "compiled"
      var bin = prog.data()
      echo "collected data"
      glob.full.emu.loadBlob(bin, 0)
      echo "loaded blob"
      echo "----"
      echo code
      echo "compiled to code"
      echo prog.data()
      echo "----"

    igEnd()

    state.passAction.colors[0].val = [1.0, 0.5, 0.5, 0.5]
    sg_begin_default_pass(addr state.pass_action, width, height)
    simgui_render()
    sg_end_pass()
    sg_commit()

proc closeImpl*() {.cdecl.} =
  printedTrace():
    simgui_shutdown()
    sg_shutdown()

proc eventImpl*(ev: ptr SappEvent) {.cdecl.} =
  printedTrace():
    simgui_handle_event(ev)

proc main(argc: cint, argv: ptr UncheckedArray[cstring]): SappDesc {.exportc: "sokol_main".} =
  echo "started main"
  return SappDesc(
    initCb: initImpl,
    frameCb: loopImpl,
    cleanupCb: closeImpl,
    eventCb: eventImpl,
    window_title: "Test"
  )
