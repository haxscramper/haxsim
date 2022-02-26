import
  commonhpp
import
  hardware/hardwarehpp
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
  PTE* {.bycopy, importcpp.} = object
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
  
type
  MODE_EXEC* {.size: sizeof(cint).} = enum
    MODE_READ
    MODE_WRITE
    MODE_EXEC
  
type
  DataAccess* {.bycopy, importcpp.} = object
    tlb*: std_vector[PTE]
  
proc exec_mem8_seg*(this: var DataAccess, seg: sgreg_t, `addr`: uint32): uint8 = 
  return read_mem8(trans_v2p(MODE_EXEC, seg, `addr`))

proc exec_mem16_seg*(this: var DataAccess, seg: sgreg_t, `addr`: uint32): uint16 = 
  return read_mem16(trans_v2p(MODE_EXEC, seg, `addr`))

proc get_data8*(this: var DataAccess, seg: sgreg_t, `addr`: uint32): uint8 = 
  return read_mem8_seg(seg, `addr`)

proc get_data16*(this: var DataAccess, seg: sgreg_t, `addr`: uint32): uint16 = 
  return read_mem16_seg(seg, `addr`)

proc get_data32*(this: var DataAccess, seg: sgreg_t, `addr`: uint32): uint32 = 
  return read_mem32_seg(seg, `addr`)

proc put_data8*(this: var DataAccess, seg: sgreg_t, `addr`: uint32, v: uint8): void = 
  write_mem8_seg(seg, `addr`, v)

proc put_data16*(this: var DataAccess, seg: sgreg_t, `addr`: uint32, v: uint16): void = 
  write_mem16_seg(seg, `addr`, v)

proc put_data32*(this: var DataAccess, seg: sgreg_t, `addr`: uint32, v: uint32): void = 
  write_mem32_seg(seg, `addr`, v)

proc get_code8*(this: var DataAccess, index: cint): uint8 = 
  return exec_mem8_seg(CS, get_eip() + index)

proc get_code16*(this: var DataAccess, index: cint): uint16 = 
  return exec_mem16_seg(CS, get_eip() + index)

proc get_code32*(this: var DataAccess, index: cint): uint32 = 
  return exec_mem32_seg(CS, get_eip() + index)

proc exec_mem32_seg*(this: var DataAccess, seg: sgreg_t, `addr`: uint32): uint32 = 
  return read_mem32(trans_v2p(MODE_EXEC, seg, `addr`))
