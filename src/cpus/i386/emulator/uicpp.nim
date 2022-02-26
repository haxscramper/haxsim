import
  thread
import
  GLFW/glfw3h
import
  emulator/uihpp
proc initUI*(m: ptr Memory, s: UISetting): UI_UI = 
  var main_th: 
  vga = newVGA()
  keyboard = newKeyboard(m)
  set = s
  working = true
  capture = false
  size_x = 320
  size_y = 200
  image = newuint8_t()
  X = size_x / 2
  Y = size_y / 2
  click[0] = click[1] = false
  glfwInit()
  if set.enable:
    main_th = std.thread(addr UI.ui_main, this)
    main_th.detach()
  

proc destroyUI*(this: var UI): void = 
  glfwTerminate()
  cxx_delete image
  cxx_delete vga
  cxx_delete keyboard

proc ui_main*(this: var UI): void = 
  var window: ptr GLFWwindow
  var texID: GLuint
  window = glfwCreateWindow(size_x, size_y, "x86emu", (if set.full:
              glfwGetPrimaryMonitor()
            
            else:
              `nil`
            ), `nil`)
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
  var vtx: ptr UncheckedArray[GLfloat] = @([0, 0, cast[cfloat](size_x(, 0, cast[cfloat](size_x(, cast[cfloat](size_y(, 0, cast[cfloat](size_y(])
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
        size_x = vtx[2] = vtx[4] = x
        size_y = vtx[5] = vtx[7] = y
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
  var _ypos: int32 = ypos
  var sy: bool
  var count: cint = 0
  if not(ui.capture) or postInc(count) mod 6:
    return 
  
  sx = _xpos < ui.X
  sy = _ypos > ui.Y
  mouse.send_code((sy shl 5) + (sx shl 4) + (1 shl 3) + (ui.click[1] shl 1) + ui.click[0])
  std.this_thread.sleep_for(std.chrono.microseconds(100))
  mouse.send_code(_xpos - ui.X)
  std.this_thread.sleep_for(std.chrono.microseconds(100))
  mouse.send_code(ui.Y - _ypos)
  DEBUG_MSG(1, "[%02x %02x %02x] _xpos : %d, _ypos : %d\\n", (sy shl 5) + (sx shl 4) + (1 shl 3) + (ui.click[1] shl 1) + ui.click[0], cast[uint8]((_xpos - ui.X)(, cast[uint8]((ui.Y - _ypos)(, _xpos, _ypos)
  ui.X = _xpos
  ui.Y = _ypos

proc window_size_callback*(this: var UI, window: ptr GLFWwindow, width: cint, height: cint): void = 
  DEBUG_MSG(1, "width : %d, height : %d\\n", width, height)
  glViewport(0, 0, width, height)

