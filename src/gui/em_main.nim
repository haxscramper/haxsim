# Copyright 2018, NimGL contributors.

import nimgl/imgui
# , nimgl/imgui/[impl_opengl, impl_glfw]
# import nimgl/[opengl, glfw]
import hmisc/core/all
import em_sokol
{.emit: """/*INCLUDESECTION*/
#include "sokol_app.h"
#include "sokol_gfx.h"
#include "sokol_glue.h"
#define CIMGUI_DEFINE_ENUMS_AND_STRUCTS
#include "cimgui.h"
#include "sokol_imgui.h"
#warning "Test warning message"

static struct {
    uint64_t laptime;
    sg_pass_action pass_action;
} state;
""".}

# var w: GLFWWindow
# var show_demo: bool = true
# var somefloat: float32 = 0.0f
# var counter: int32 = 0
# var context: ptr ImGuiContext

template printedTrace*(body: untyped) =
  try:
    body

  except:
    writeStackTrace()
    raise

# var state

# var desc: SgDesc
# var sim: SimGuiDesec

proc initImpl*(): void {.cdecl.} =
  startHax()

  printedTrace():
    {.emit: """
    sg_setup(&(sg_desc){
        .context = sapp_sgcontext()
    });
    stm_setup();
    simgui_setup(&(simgui_desc_t){ 0 });

    // initial clear color
    state.pass_action = (sg_pass_action) {
        .colors[0] = {
            .action = SG_ACTION_CLEAR,
            .val = { 0.0f, 0.5f, 1.0f, 1.0 }
        }
    };
""".}
    # sg_setup(DgDesc(context: sapp_sgcontext()))
    # simgui_setup(SimGuiDesc())

proc loopImpl*() {.cdecl.} =
  printedTrace():
    # let width = sappWidth()
    # let height = sappHeight()
    {.emit: """
    const int width = sapp_width();
    const int height = sapp_height();
    double delta_time = stm_sec(stm_round_to_common_refresh_rate(stm_laptime(&state.laptime)));
    simgui_new_frame(width, height, delta_time);
""".}

#     {.emit: """
#     igSetNextWindowPos((ImVec2){10,10}, ImGuiCond_Once, (ImVec2){0,0});
#     igSetNextWindowSize((ImVec2){400, 100}, ImGuiCond_Once);
#     igBegin("Hello Dear ImGui!", 0, ImGuiWindowFlags_None);
#     // igColorEdit3("Background", &state.pass_action.colors[0].val[0], ImGuiColorEditFlags_None);
#     // igEnd();
# """.}

    igSetNextWindowPos(ImVec2(x: 10, y: 10), ImGuiCond.Once, ImVec2(x: 0, y: 0))
    igSetNextWindowSize(ImVec2(x: 400, y: 100), ImGuiCond.Once)
    igBegin("Test", nil, ImGuiWindowFlags.None)
    # igColorEdit3("Background", &state.pass_action.colors[0].val[0], ImGuiColorEditFlags_None)
    # /// "IG end":
    igEnd()


    {.emit: """
    sg_begin_default_pass(&state.pass_action, width, height);
    simgui_render();
    sg_end_pass();
    sg_commit();
""".}
    # simgui_new_frame(SimguiFrameDesc(
    #     width:      sapp_width(),
    #     height:     sapp_height(),
    #     delta_time: sapp_frame_duration(),
    #     dpi_scale:  sapp_dpi_scale(),
    # })

    # igSetNextWindowPos((ImVec2){10, 10}, ImGuiCond_Once, (ImVec2){0, 0});
    # igSetNextWindowSize((ImVec2){400, 100}, ImGuiCond_Once);
    # igBegin("Hello Dear ImGui!", 0, ImGuiWindowFlags_None);
    # igColorEdit3(
    #     "Background",
    #     &state.pass_action.colors[0].value.r,
    #     ImGuiColorEditFlags_None);
    # igEnd();

    # sg_begin_default_pass(&state.pass_action, sapp_width(), sapp_height())
    # simgui_render()
    # sg_end_pass()
    # sg_commit()

proc closeImpl*() {.cdecl.} =
  printedTrace():
    {.emit: """
    simgui_shutdown();
    sg_shutdown();
""".}
    # simgui_shutdown()
    # sg_shutdown()

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


# main()
