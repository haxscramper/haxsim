import
  commonhpp
type
  EflagsImpl* {.bycopy, union, importcpp.} = object
    reg32*: uint32
    reg16*: uint16
    field2*: EflagsImpl_field2_Type
  
  EflagsImpl_field2_Type* {.bycopy.} = object
    CF* {.bitsize: 1.}: uint32
    field1* {.bitsize: 1.}: uint32
    PF* {.bitsize: 1.}: uint32
    field3* {.bitsize: 1.}: uint32
    AF* {.bitsize: 1.}: uint32
    field5* {.bitsize: 1.}: uint32
    ZF* {.bitsize: 1.}: uint32
    SF* {.bitsize: 1.}: uint32
    TF* {.bitsize: 1.}: uint32
    IF* {.bitsize: 1.}: uint32
    DF* {.bitsize: 1.}: uint32
    OF* {.bitsize: 1.}: uint32
    IOPL* {.bitsize: 2.}: uint32
    NT* {.bitsize: 1.}: uint32
    field14* {.bitsize: 1.}: uint32
    RF* {.bitsize: 1.}: uint32
    VM* {.bitsize: 1.}: uint32
    AC* {.bitsize: 1.}: uint32
    VIF* {.bitsize: 1.}: uint32
    VIP* {.bitsize: 1.}: uint32
    ID* {.bitsize: 1.}: uint32

proc CF*(this: EflagsImpl): uint32 =
  this.field2.CF

proc `CF =`*(this: var EflagsImpl, value: uint32) =
  this.field2.CF = value

proc PF*(this: EflagsImpl): uint32 =
  this.field2.PF

proc `PF =`*(this: var EflagsImpl, value: uint32) =
  this.field2.PF = value

proc AF*(this: EflagsImpl): uint32 =
  this.field2.AF

proc `AF =`*(this: var EflagsImpl, value: uint32) =
  this.field2.AF = value

proc ZF*(this: EflagsImpl): uint32 =
  this.field2.ZF

proc `ZF =`*(this: var EflagsImpl, value: uint32) =
  this.field2.ZF = value

proc SF*(this: EflagsImpl): uint32 =
  this.field2.SF

proc `SF =`*(this: var EflagsImpl, value: uint32) =
  this.field2.SF = value

proc TF*(this: EflagsImpl): uint32 =
  this.field2.TF

proc `TF =`*(this: var EflagsImpl, value: uint32) =
  this.field2.TF = value

proc IF*(this: EflagsImpl): uint32 =
  this.field2.IF

proc `IF =`*(this: var EflagsImpl, value: uint32) =
  this.field2.IF = value

proc DF*(this: EflagsImpl): uint32 =
  this.field2.DF

proc `DF =`*(this: var EflagsImpl, value: uint32) =
  this.field2.DF = value

proc OF*(this: EflagsImpl): uint32 =
  this.field2.OF

proc `OF =`*(this: var EflagsImpl, value: uint32) =
  this.field2.OF = value

proc IOPL*(this: EflagsImpl): uint32 =
  this.field2.IOPL

proc `IOPL =`*(this: var EflagsImpl, value: uint32) =
  this.field2.IOPL = value

proc NT*(this: EflagsImpl): uint32 =
  this.field2.NT

proc `NT =`*(this: var EflagsImpl, value: uint32) =
  this.field2.NT = value

proc RF*(this: EflagsImpl): uint32 =
  this.field2.RF

proc `RF =`*(this: var EflagsImpl, value: uint32) =
  this.field2.RF = value

proc VM*(this: EflagsImpl): uint32 =
  this.field2.VM

proc `VM =`*(this: var EflagsImpl, value: uint32) =
  this.field2.VM = value

proc AC*(this: EflagsImpl): uint32 =
  this.field2.AC

proc `AC =`*(this: var EflagsImpl, value: uint32) =
  this.field2.AC = value

proc VIF*(this: EflagsImpl): uint32 =
  this.field2.VIF

proc `VIF =`*(this: var EflagsImpl, value: uint32) =
  this.field2.VIF = value

proc VIP*(this: EflagsImpl): uint32 =
  this.field2.VIP

proc `VIP =`*(this: var EflagsImpl, value: uint32) =
  this.field2.VIP = value

proc ID*(this: EflagsImpl): uint32 =
  this.field2.ID

proc `ID =`*(this: var EflagsImpl, value: uint32) =
  this.field2.ID = value

type
  Eflags* {.bycopy, importcpp.} = object
    eflags*: EflagsImpl

proc get_eflags*(this: var Eflags): uint32 =
  return this.eflags.reg32

proc set_eflags*(this: var Eflags, v: uint32): void =
  this.eflags.reg32 = v

proc get_flags*(this: var Eflags): uint16 =
  return this.eflags.reg16

proc set_flags*(this: var Eflags, v: uint16): void =
  this.eflags.reg16 = v

proc is_carry*(this: var Eflags): bool =
  return this.eflags.CF.bool

proc is_parity*(this: var Eflags): bool =
  return this.eflags.PF.bool

proc is_zero*(this: var Eflags): bool =
  return this.eflags.ZF.bool

proc is_sign*(this: var Eflags): bool =
  return this.eflags.SF.bool

proc is_overflow*(this: var Eflags): bool =
  return this.eflags.OF.bool

proc is_interrupt*(this: var Eflags): bool =
  return this.eflags.IF.bool

proc is_direction*(this: var Eflags): bool =
  return this.eflags.DF.bool

proc set_carry*(this: var Eflags, carry: bool): void =
  this.eflags.CF = carry.uint32

proc set_parity*(this: var Eflags, parity: bool): void =
  this.eflags.PF = parity.uint32

proc set_zero*(this: var Eflags, zero: bool): void =
  this.eflags.ZF = zero.uint32

proc set_sign*(this: var Eflags, sign: bool): void =
  this.eflags.SF = sign.uint32

proc set_overflow*(this: var Eflags, over: bool): void =
  this.eflags.OF = over.uint32

proc set_interrupt*(this: var Eflags, interrupt: bool): void =
  this.eflags.IF = interrupt.uint32

proc set_direction*(this: var Eflags, dir: bool): void =
  this.eflags.DF = dir.uint32
