import commonhpp
import device/vgahpp
import hmisc/core/all
import device/keyboardhpp
import device/mousehpp
import hardware/memoryhpp

type
  UISetting* = object
    enable*: bool
    full*: bool
    vm*: bool
  
type
  UI* = ref object
    set*: UISetting    
    vga*: VGA
    keyboard*: Keyboard
    working*: bool    
    capture*: bool    
    size_x, size_y*: uint16
    image*: seq[uint8]
    field7*: UI_field7_Type    

  UI_field7_Type* {.bycopy.} = object
    X*, Y*: int16
    click*: array[2, bool]

proc get_status*(this: var UI): bool = 
  return this.working

proc get_keyboard*(this: var UI): Keyboard =
  return this.keyboard

proc get_vga*(this: var UI): VGA =
  return this.vga


proc X*(this: UI): int16 = this.field7.X
proc `X=`*(this: var UI, value: int16) = this.field7.X = value
proc Y*(this: UI): int16 = this.field7.Y
proc `Y=`*(this: var UI, value: int16) = this.field7.Y = value
proc click*(this: UI): array[2, bool] = this.field7.click
proc click*(this: var UI): var array[2, bool] = this.field7.click
proc `click=`*(this: var UI): array[2, bool] = this.field7.click

proc initUI*(m: Memory, s: UISetting): UI =
  result = UI(
    vga: initVGA().asRef(),
    keyboard: initKeyboard(m),
    set: s,
    working: true,
    capture: false,
    size_x: 320,
    size_y: 200,
  )

  result.image = newSeq[uint8](result.size_x * result.size_y * 3)
  result.X = int16(result.size_x div 2)
  result.Y = int16(result.size_y div 2)
  result.click[0] = false
  result.click[1] = false

  # if set.enable:
  #   main_th = std.thread(addr UI.ui_main, this)
  #   main_th.detach()


proc destroyUI*(this: var UI): void =
  discard
  # glfwTerminate()
  # cxx_delete image
  # cxx_delete vga
  # cxx_delete keyboard

when false:
  proc ui_main*(this: var UI): void =
    var window: ptr GLFWwindow
    var texID: GLuint
    window = glfwCreateWindow(size_x, size_y, "x86emu", (if set.full:
                glfwGetPrimaryMonitor()

              else:
                nil
              ), nil)
    glfwSetWindowUserPointer(window, this)
    glfwMakeContextCurrent(window)
    glfwSetKeyCallback(window, keyboard_callback)
    glfwSetMouseButtonCallback(window, mouse_callback)
    glfwSetCursorPosCallback(window, cursorpos_callback)
    glfwSetWindowSizeCallback(window, window_size_callback)

    glfwSetWindowAspectRatio(window, size_x, size_y)
    glOrtho(0, size_x, 0, size_y, -1, 1)
    glGenTextures(1, addr texID)
    glBindTexture(GL_TEXTURE_2D, texID)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP)
    glEnable(GL_TEXTURE_2D)
    glEnableClientState(GL_VERTEX_ARRAY)
    glEnableClientState(GL_TEXTURE_COORD_ARRAY)
    var vtx: ptr UncheckedArray[GLfloat] = @([0, 0, cast[cfloat](size_x), 0, cast[cfloat](size_x), cast[cfloat](size_y), 0, cast[cfloat](size_y)])
    var texuv: ptr UncheckedArray[GLfloat] = @([0, 1, 1, 1, 1, 0, 0, 0])
    while (not(glfwWindowShouldClose(window))):
      std.this_thread.sleep_for(std.chrono.milliseconds(40))
      glfwPollEvents()
      glClearColor(0.5f, 0.5f, 0.5f, 0.0f)
      glClear(GL_COLOR_BUFFER_BIT)
      if vga.need_refresh():
        var y: uint16
        vga.get_windowsize(addr x, addr y)
        if x and y and ((size_x xor x) or (size_y xor y)):
          printf("x : %d, y : %d\\n", x, y)
          # size_x = vtx[2] = vtx[4] = x
          # size_y = vtx[5] = vtx[7] = y
          glfwSetWindowSize(window, x, y)
          glfwSetWindowAspectRatio(window, x, y)
          glOrtho(0, x, 0, y, -1, 1)
          cxx_delete image
          image = newuint8_t()

        vga.rgb_image(image, x * y)
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, size_x, size_y, 0, GL_RGB, GL_UNSIGNED_BYTE, image)
        glVertexPointer(2, GL_FLOAT, 0, vtx)
        glTexCoordPointer(2, GL_FLOAT, 0, texuv)

      glDrawArrays(GL_QUADS, 0, 4)
      glfwSwapBuffers(window)
    glDisableClientState(GL_TEXTURE_COORD_ARRAY)
    glDisableClientState(GL_VERTEX_ARRAY)
    glDisable(GL_TEXTURE_2D)
    glfwDestroyWindow(window)
    working = false

  proc keyboard_callback*(this: var UI, window: ptr GLFWwindow, key: cint, scancode: cint, action: cint, mods: cint): void =
    var ui: ptr UI = static_cast[ptr UI](glfwGetWindowUserPointer(window))
    var kb: ptr Keyboard = ui.keyboard
    if not(ui.capture):
      return

    DEBUG_MSG(1, "key : 0x%02x, scancode : 0x%02x, action : %d, mods : %d\\n", key, scancode, action, mods)
    case key:
      of 0x159:
        ui.capture = false
        glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_NORMAL)
        return
    case action:
      of GLFW_RELEASE:
        kb.send_code(scancode - ((if ui.set.vm:
                8

              else:
                0
              )) + 0x80)
      of GLFW_PRESS, GLFW_REPEAT:
        kb.send_code(scancode - ((if ui.set.vm:
                8

              else:
                0
              )))

  proc mouse_callback*(this: var UI, window: ptr GLFWwindow, button: cint, action: cint, mods: cint): void =
    var ui: ptr UI = static_cast[ptr UI](glfwGetWindowUserPointer(window))
    var mouse: ptr Mouse = ui.keyboard.get_mouse()
    if ui.capture:
      ui.click[button mod 2] = action
      mouse.send_code((1 shl 3) + (ui.click[1] shl 1) + ui.click[0])
      mouse.send_code(0)
      mouse.send_code(0)
      DEBUG_MSG(1, "[%02x %02x %02x] button : %d, action : %d, mods : %d\\n", (1 shl 3) + (ui.click[1] shl 1) + ui.click[0], 0, 0, button, action, mods)

    else:
      ui.capture = true
      glfwSetInputMode(window, GLFW_CURSOR, (if not(ui.set.vm):
              GLFW_CURSOR_DISABLED

            else:
              GLFW_CURSOR_HIDDEN
            ))
      MSG("To cancel the input capture, press the right control key.\\n")


  proc cursorpos_callback*(this: var UI, window: ptr GLFWwindow, xpos: cdouble, ypos: cdouble): void =
    var ui: ptr UI = static_cast[ptr UI](glfwGetWindowUserPointer(window))
    var mouse: ptr Mouse = ui.keyboard.get_mouse()
    var ypos: int32 = ypos
    var sy: bool
    var count: cint = 0
    if not(ui.capture) or postInc(count) mod 6:
      return

    sx = xpos < ui.X
    sy = ypos > ui.Y
    mouse.send_code((sy shl 5) + (sx shl 4) + (1 shl 3) + (ui.click[1] shl 1) + ui.click[0])
    std.this_thread.sleep_for(std.chrono.microseconds(100))
    mouse.send_code(xpos - ui.X)
    std.this_thread.sleep_for(std.chrono.microseconds(100))
    mouse.send_code(ui.Y - ypos)
    DEBUG_MSG(1, "[%02x %02x %02x] _xpos : %d, _ypos : %d\\n", (sy shl 5) + (sx shl 4) + (1 shl 3) + (ui.click[1] shl 1) + ui.click[0], cast[uint8]((xpos - ui.X)), cast[uint8]((ui.Y - ypos)), xpos, ypos)
    ui.X = xpos
    ui.Y = ypos

  proc window_size_callback*(this: var UI, window: ptr GLFWwindow, width: cint, height: cint): void =
    DEBUG_MSG(1, "width : %d, height : %d\\n", width, height)
    glViewport(0, 0, width, height)
