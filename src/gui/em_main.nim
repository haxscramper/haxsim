import nimgl/imgui
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
      val: [0.0, 0.5, 1.0, 1.0]
    )

proc loopImpl*() {.cdecl.} =
  printedTrace():
    let width = sappWidth()
    let height = sappHeight()
    let deltaTime = stm_sec(stm_round_to_common_refresh_rate(
      stm_laptime(addr state.laptime)))

    simgui_new_frame(width, height, delta_time)


    igSetNextWindowPos(ImVec2(x: 10, y: 10), ImGuiCond.Once, ImVec2(x: 0, y: 0))
    igSetNextWindowSize(ImVec2(x: 400, y: 100), ImGuiCond.Once)
    igBegin("Test ??", nil, ImGuiWindowFlags.None)
    if igButton("Test button"):
      echo "button was clicked"

    igEnd()


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
