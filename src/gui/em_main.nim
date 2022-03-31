import nimgl/imgui
import std/strformat
import hmisc/core/all
import em_sokol

var state: tuple[
  passAction: SgPassAction,
  laptime: uint64
]

template printedTrace*(body: untyped) =
  try:
    body

  except:
    writeStackTrace()
    raise

proc initImpl*(): void {.cdecl.} =
  startHax()

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


    igSetNextWindowPos(igVec(0, 0), ImGuiCond.Once, igVec(0, 0))
    igSetNextWindowSize(igVec(1920, 1080), ImGuiCond.Once)
    igBegin("", nil, ImGuiWindowFlags(
      ImGuiWindowFlags.NoTitleBar.int or ImGuiWindowFlags.NoBackground.int))

    var list = igGetWindowDrawList()
    list.addLine(igVec(0, 0), igVec(300, 300), igCol32(255, 0, 0, 255), 20)

    igEnd()

    igSetNextWindowPos(igVec(40, 40), ImGuiCond.Once, igVec(0, 0))
    igSetNextWindowSize(igVec(400, 400), ImGuiCond.Once)

    igBegin("Test ??", nil, ImGuiWindowFlags.None)

    for i in 0 .. 10:
      if igButton(&"Test button {i}"):
        echo "button {i} was clicked"


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
