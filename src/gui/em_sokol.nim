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
