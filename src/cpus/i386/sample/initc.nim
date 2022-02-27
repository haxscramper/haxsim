import
  commonh
type
  DTReg* {.bycopy, importcpp.} = object
    limit*: uint16
    base_l*: uint16
    base_h*: uint16
  
type
  IDT* {.bycopy, importcpp.} = object
    offset_l*:        uint16
    selector*:        uint16
    * {.bitsize: 8.}: uint8
    type* {.bitsize: 3.}: uint8
    D* {.bitsize: 1.}: uint8
    * {.bitsize: 1.}: uint8
    DPL* {.bitsize: 2.}: uint8
    P* {.bitsize: 1.}: uint8
    offset_h*:        uint16
  
type
  PDE* {.bycopy, importcpp.} = object
    P* {.bitsize: 1.}: uint32
    RW* {.bitsize: 1.}: uint32
    US* {.bitsize: 1.}: uint32
    PWT* {.bitsize: 1.}: uint32
    PCD* {.bitsize: 1.}: uint32
    A* {.bitsize: 1.}: uint32
    * {.bitsize: 1.}: uint32
    PS* {.bitsize: 1.}: uint32
    G* {.bitsize: 1.}: uint32
    * {.bitsize: 3.}: uint32
    ptbl_base* {.bitsize: 20.}: uint32
  
type
  PTE* {.bycopy.} = object
    P* {.bitsize: 1.}: uint32
    RW* {.bitsize: 1.}: uint32
    US* {.bitsize: 1.}: uint32
    PWT* {.bitsize: 1.}: uint32
    PCD* {.bitsize: 1.}: uint32
    A* {.bitsize: 1.}: uint32
    D* {.bitsize: 1.}: uint32
    PAT* {.bitsize: 1.}: uint32
    G* {.bitsize: 1.}: uint32
    * {.bitsize: 3.}: uint32
    page_base* {.bitsize: 20.}: uint32
  
proc set_idt*(idt: ptr IDT, off: proc(): void {.cdecl.}, `type`: uint8, DPL: uint8, sel: uint16): void = 
  discard 

proc sys_puts*(): void = 
  discard 

proc sys_gets*(): void = 
  discard 

proc irq_timer*(): void = 
  discard 

proc irq_keyboard*(): void = 
  discard 

proc irq_mouse*(): void = 
  discard 

proc init_paging*(): uint32 = 
  var pde: ptr PDE = cast[ptr PDE](0x20000)
  var pte: ptr PTE = cast[ptr PTE](0x21000)
  pde[0].ptbl_base = (cast[uint32](pte)) shr 12
  pde[0].P = 1
  pde[0].RW = 1
  pde[0].US = 1
  for i in 0 ..< 20:
    pte[i].page_base = i
    pte[i].P = 1
    pte[i].RW = 1
    pte[i].US = 1
  for i in 0xa0 ..< 0xc0:
    pte[i].page_base = i
    pte[i].P = 1
    pte[i].RW = 1
    pte[i].US = 1
  return cast[uint32](pde)

proc init_idt*(): uint32 = 
  var idtr: ptr DTReg = cast[ptr DTReg](0x28000)
  var idt: ptr IDT = cast[ptr IDT](0x28030)
  idtr.limit = sizeof(cast[IDT](255[]) - 1)
  idtr.base_l = cast[uint32](idt) and 0xffff
  idtr.base_h = cast[uint32](idt) shr 16
  set_idt(addr idt[0x00], sys_puts, 7, 3, 0x8)
  set_idt(addr idt[0x01], sys_gets, 7, 3, 0x8)
  set_idt(addr idt[0x20], irq_timer, 6, 0, 0x8)
  set_idt(addr idt[0x21], irq_keyboard, 6, 0, 0x8)
  set_idt(addr idt[0x2c], irq_mouse, 6, 0, 0x8)
  return cast[uint32](idtr)

proc set_idt*(idt: ptr IDT, off: proc(): void {.cdecl.}, `type`: uint8, DPL: uint8, sel: uint16): void = 
  idt.offset_l = cast[uint32](off) and 0xffff
  idt.offset_h = cast[uint32](off) shr 16
  idt.selector = sel
  idt.`type` = `type`
  idt.D = 1
  idt.DPL = DPL
  idt.P = 1
