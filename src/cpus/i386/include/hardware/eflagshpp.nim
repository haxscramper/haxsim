import
  commonhpp
type
  EFLAGS* {.bycopy, union, importcpp.} = object
    reg32*: uint32
    reg16*: uint16
    field2*: EFLAGS_field2_Type
  
type
  EFLAGS_field2_Type* {.bycopy.} = object
    CF* {.bitsize: 1.}: uint32
    * {.bitsize: 1.}: uint32
    PF* {.bitsize: 1.}: uint32
    * {.bitsize: 1.}: uint32
    AF* {.bitsize: 1.}: uint32
    * {.bitsize: 1.}: uint32
    ZF* {.bitsize: 1.}: uint32
    SF* {.bitsize: 1.}: uint32
    TF* {.bitsize: 1.}: uint32
    IF* {.bitsize: 1.}: uint32
    DF* {.bitsize: 1.}: uint32
    OF* {.bitsize: 1.}: uint32
    IOPL* {.bitsize: 2.}: uint32
    NT* {.bitsize: 1.}: uint32
    * {.bitsize: 1.}: uint32
    RF* {.bitsize: 1.}: uint32
    VM* {.bitsize: 1.}: uint32
    AC* {.bitsize: 1.}: uint32
    VIF* {.bitsize: 1.}: uint32
    VIP* {.bitsize: 1.}: uint32
    ID* {.bitsize: 1.}: uint32
  
proc CF*(this: EFLAGS): uint32 = 
  this.field2.CF

proc `CF =`*(this: var EFLAGS): uint32 = 
  this.field2.CF

proc *(this: EFLAGS): uint32 = 
  this.field2.

proc ` =`*(this: var EFLAGS): uint32 = 
  this.field2.

proc PF*(this: EFLAGS): uint32 = 
  this.field2.PF

proc `PF =`*(this: var EFLAGS): uint32 = 
  this.field2.PF

proc *(this: EFLAGS): uint32 = 
  this.field2.

proc ` =`*(this: var EFLAGS): uint32 = 
  this.field2.

proc AF*(this: EFLAGS): uint32 = 
  this.field2.AF

proc `AF =`*(this: var EFLAGS): uint32 = 
  this.field2.AF

proc *(this: EFLAGS): uint32 = 
  this.field2.

proc ` =`*(this: var EFLAGS): uint32 = 
  this.field2.

proc ZF*(this: EFLAGS): uint32 = 
  this.field2.ZF

proc `ZF =`*(this: var EFLAGS): uint32 = 
  this.field2.ZF

proc SF*(this: EFLAGS): uint32 = 
  this.field2.SF

proc `SF =`*(this: var EFLAGS): uint32 = 
  this.field2.SF

proc TF*(this: EFLAGS): uint32 = 
  this.field2.TF

proc `TF =`*(this: var EFLAGS): uint32 = 
  this.field2.TF

proc IF*(this: EFLAGS): uint32 = 
  this.field2.IF

proc `IF =`*(this: var EFLAGS): uint32 = 
  this.field2.IF

proc DF*(this: EFLAGS): uint32 = 
  this.field2.DF

proc `DF =`*(this: var EFLAGS): uint32 = 
  this.field2.DF

proc OF*(this: EFLAGS): uint32 = 
  this.field2.OF

proc `OF =`*(this: var EFLAGS): uint32 = 
  this.field2.OF

proc IOPL*(this: EFLAGS): uint32 = 
  this.field2.IOPL

proc `IOPL =`*(this: var EFLAGS): uint32 = 
  this.field2.IOPL

proc NT*(this: EFLAGS): uint32 = 
  this.field2.NT

proc `NT =`*(this: var EFLAGS): uint32 = 
  this.field2.NT

proc *(this: EFLAGS): uint32 = 
  this.field2.

proc ` =`*(this: var EFLAGS): uint32 = 
  this.field2.

proc RF*(this: EFLAGS): uint32 = 
  this.field2.RF

proc `RF =`*(this: var EFLAGS): uint32 = 
  this.field2.RF

proc VM*(this: EFLAGS): uint32 = 
  this.field2.VM

proc `VM =`*(this: var EFLAGS): uint32 = 
  this.field2.VM

proc AC*(this: EFLAGS): uint32 = 
  this.field2.AC

proc `AC =`*(this: var EFLAGS): uint32 = 
  this.field2.AC

proc VIF*(this: EFLAGS): uint32 = 
  this.field2.VIF

proc `VIF =`*(this: var EFLAGS): uint32 = 
  this.field2.VIF

proc VIP*(this: EFLAGS): uint32 = 
  this.field2.VIP

proc `VIP =`*(this: var EFLAGS): uint32 = 
  this.field2.VIP

proc ID*(this: EFLAGS): uint32 = 
  this.field2.ID

proc `ID =`*(this: var EFLAGS): uint32 = 
  this.field2.ID

type
  Eflags* {.bycopy, importcpp.} = object
    eflags*: EFLAGS
  
proc get_eflags*(this: var Eflags): uint32 = 
  return eflags.reg32

proc set_eflags*(this: var Eflags, v: uint32): void = 
  eflags.reg32 = v

proc get_flags*(this: var Eflags): uint16 = 
  return eflags.reg16

proc set_flags*(this: var Eflags, v: uint16): void = 
  eflags.reg16 = v

proc is_carry*(this: var Eflags): bool = 
  return eflags.CF

proc is_parity*(this: var Eflags): bool = 
  return eflags.PF

proc is_zero*(this: var Eflags): bool = 
  return eflags.ZF

proc is_sign*(this: var Eflags): bool = 
  return eflags.SF

proc is_overflow*(this: var Eflags): bool = 
  return eflags.OF

proc is_interrupt*(this: var Eflags): bool = 
  return eflags.IF

proc is_direction*(this: var Eflags): bool = 
  return eflags.DF

proc set_carry*(this: var Eflags, carry: bool): void = 
  eflags.CF = carry

proc set_parity*(this: var Eflags, parity: bool): void = 
  eflags.PF = parity

proc set_zero*(this: var Eflags, zero: bool): void = 
  eflags.ZF = zero

proc set_sign*(this: var Eflags, sign: bool): void = 
  eflags.SF = sign

proc set_overflow*(this: var Eflags, over: bool): void = 
  eflags.OF = over

proc set_interrupt*(this: var Eflags, interrupt: bool): void = 
  eflags.IF = interrupt

proc set_direction*(this: var Eflags, dir: bool): void = 
  eflags.DF = dir
