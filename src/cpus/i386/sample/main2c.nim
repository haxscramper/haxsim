import
  commonh
proc _puts*(a0: cstring): cint = 
  discard 

proc set_graphicmode*(): void = 
  discard 

proc main*(): cint = 
  var vram: ptr uint8 = cast[ptr uint8](0xa0000(
  _puts("Hello!\\n")
  
  _puts("Key or Mouse\\n")
  
  return 0
