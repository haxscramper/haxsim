import imgui, imgui/[impl_opengl, impl_glfw]
import nimgl/[opengl, glfw]
import std/strformat
import maincpp
import emulator/emulator
import compiler/assembler
import hardware/processor
import hmisc/core/all
import hmisc/other/oswrap

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

proc igVec*(x, y: float): ImVec2 = ImVec2(x: x, y: y)
proc igCol32*(r, g, b: uint8, a: uint8 = 255): uint32 =
  (a.uint32 shl 24) or (b.uint32 shl 16) or (g.uint32 shl 8) or (r.uint32)

var glob = (
  codeLen: 0,
  codeText: newString(0xFFFF)
)

proc cb(data: ptr ImGuiInputTextCallbackData): int32 {.cdecl.} =
  discard
  # glob.codeLen = data.bufTextLen

proc compileAndLoad*(full: FullImpl, str: string) =
  ## Compile and load program starting at position zero
  var prog = parseProgram(str)
  prog.compile()
  var bin = prog.data()
  full.emu.loadBlob(bin, 0)

proc igLogic(full: FullImpl) =
  ## Main entry point for the visualization logic
  igSetNextWindowSize(igVec(300, 300))
  igWindow("Main window TMP"):
    if igButton("Sub"):
      echo "Selected sub"

    if igButton("Next"):
      full.step()

    if igButton("Compile and load"):
      full.compileAndLoad(glob.codeText)

    if igButton("Example"):
      glob.codeText = """
mov ax, 2
imul ax, -0x2
hlt
"""

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

  glfwWindowHint(GLFWContextVersionMajor, 4)
  glfwWindowHint(GLFWContextVersionMinor, 1)
  glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE)
  glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
  glfwWindowHint(GLFWResizable, GLFW_FALSE)

  var w: GLFWWindow = glfwCreateWindow(720, 720)
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
    igLogic(full)

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
