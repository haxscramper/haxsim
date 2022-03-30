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

  SimGuiDesc* {.importc: "struct simgui_desc", st.} = object

  SgContextDesc* {.importc: "sg_context_desc", st.} = object

  SappEvent* {.importc: "sapp_event", st.} = object

  SgDesc* {.importc: "", st.} = object
    context*: SgContextDesc

  # SappPassAction* {.importc: "struct sapp_pass_action", st.} = object

proc sapp_sgcontext*(): SgContextDesc {.pri.}
proc sg_commit*() {.pri.}
proc sg_end_pass*() {.pri.}
proc simgui_render*() {.pri.}
proc sg_shutdown*() {.pri.}
proc simgui_shutdown*() {.pri.}

proc sapp_width*(): cint {.pri.}
proc sapp_height*(): cint {.pri.}
proc sapp_frame_duration*(): cint {.pri.}
proc sapp_dpi_scale*(): cint {.pri.}
proc simgui_handle_event*(ev: ptr SappEvent) {.pri.}
