# Copyright 2018, NimGL contributors.

import nimgl/imgui, nimgl/imgui/[impl_opengl, impl_glfw]
import nimgl/[opengl, glfw]
import hmisc/core/all

var w: GLFWWindow
var show_demo: bool = true
var somefloat: float32 = 0.0f
var counter: int32 = 0
var context: ptr ImGuiContext

template printedTrace*(body: untyped) =
  try:
    body

  except:
    writeStackTrace()
    raise

proc canLoop*(): bool =
  not w.windowShouldClose

proc init*(): bool {.exportc.} =
  startHax()

  printedTrace():
    ploc()
    doAssert glfwInit()

    ploc()
    glfwWindowHint(GLFWContextVersionMajor, 3)
    glfwWindowHint(GLFWContextVersionMinor, 3)
    glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE)
    glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
    glfwWindowHint(GLFWResizable, GLFW_FALSE)

    ploc()
    w = glfwCreateWindow(1280, 720)
    ploc()
    if w == nil:
      echo "Failed to create window"
      return false

    ploc()
    w.makeContextCurrent()

    ploc()
    doAssert glInit()
    ploc()

    try:
      context = igCreateContext()
    except:
      echo "wer"

    ploc()
    doAssert igGlfwInitForOpenGL(w, true)
    doAssert igOpenGL3Init()
    ploc()

    igStyleColorsCherry()

    ploc()
    return true

proc loop*() {.exportc.} =
  printedTrace():
    ploc()
    glfwPollEvents()

    igOpenGL3NewFrame()
    igGlfwNewFrame()
    igNewFrame()

    if show_demo:
      igShowDemoWindow(show_demo.addr)

    # Simple window
    igBegin("Hello, world!")

    igText("This is some useful text.")
    igCheckbox("Demo Window", show_demo.addr)

    igSliderFloat("float", somefloat.addr, 0.0f, 1.0f)

    if igButton("Button", ImVec2(x: 0, y: 0)):
      counter.inc
    igSameLine()
    igText("counter = %d", counter)

    igText(
      "Application average %.3f ms/frame (%.1f FPS)",
      1000.0f / igGetIO().framerate, igGetIO().framerate)

    igEnd()
    # End simple window

    igRender()

    glClearColor(0.45f, 0.55f, 0.60f, 1.00f)
    glClear(GL_COLOR_BUFFER_BIT)

    igOpenGL3RenderDrawData(igGetDrawData())

    w.swapBuffers()

proc close*() {.exportc.} =
  printedTrace():
    igOpenGL3Shutdown()
    igGlfwShutdown()
    context.igDestroyContext()

    w.destroyWindow()
    glfwTerminate()

# main()
