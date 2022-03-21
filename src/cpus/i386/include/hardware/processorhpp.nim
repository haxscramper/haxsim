import commonhpp
import eflagshpp
import crhpp

type
  reg32_t* = enum
    EAX
    ECX
    EDX
    EBX
    ESP
    EBP
    ESI
    EDI
    GPREGS_COUNT

type
  reg16_t* = enum
    AX
    CX
    DX
    BX
    SP
    BP
    SI
    DI

type
  reg8_t* = enum
    AL
    CL
    DL
    BL
    AH
    CH
    DH
    BH


type
  sgreg_t* = enum
    ES
    CS
    SS
    DS
    FS
    GS
    SGREGS_COUNT

type
  dtreg_t* = enum
    GDTR
    IDTR
    LDTR
    TR
    DTREGS_COUNT

type
  GPRegister* {.bycopy, union, importcpp.} = object
    reg32*: uint32
    reg16*: uint16
    field2*: GPRegister_field2

  GPRegister_field2* {.bycopy.} = object
    reg8_l*: uint8
    reg8_h*: uint8

proc reg8_l*(this: GPRegister): uint8 =
  this.field2.reg8_l

proc `reg8_l =`*(this: var GPRegister, value: uint8) =
  this.field2.reg8_l = value

proc reg8_h*(this: GPRegister): uint8 =
  this.field2.reg8_h

proc `reg8_h =`*(this: var GPRegister, value: uint8) =
  this.field2.reg8_h = value

type
  SGRegCache* {.bycopy, importcpp.} = object
    base*:        uint32
    limit* {.bitsize: 20.}: uint32
    flags*:        SGRegCache_flags

  data* {.bycopy.} = object
    field0* {.bitsize: 1.}: uint8
    w* {.bitsize: 1.}: uint8
    exd* {.bitsize: 1.}: uint8
    field3* {.bitsize: 1.}: uint8

  code* {.bycopy.} = object
    field0* {.bitsize: 1.}: uint8
    r* {.bitsize: 1.}: uint8
    cnf* {.bitsize: 1.}: uint8
    field3* {.bitsize: 1.}: uint8

  type_field2* {.bycopy.} = object
    A* {.bitsize: 1.}: uint8
    field1* {.bitsize: 2.}: uint8
    segc* {.bitsize: 1.}: uint8

  SGRegCache_flags_field2* {.bycopy.} = object
    field0* {.bitsize: 4.}: uint8
    S* {.bitsize: 1.}: uint8
    DPL* {.bitsize: 2.}: uint8
    P* {.bitsize: 1.}: uint8
    AVL* {.bitsize: 1.}: uint8
    field5* {.bitsize: 1.}: uint8
    DB* {.bitsize: 1.}: uint8
    G* {.bitsize: 1.}: uint8

  SGRegCache_flags* {.bycopy, union.} = object
    raw* {.bitsize: 12.}: uint16
    `type`*:        `type`
    field2*:        SGRegCache_flags_field2

  SGRegister* {.bycopy, importcpp.} = object
    field0*: SGRegister_field0
    cache*: SGRegCache

  SGRegister_field0* {.bycopy, union.} = object
    raw*: uint16
    field1*: SGRegister_field0_field1


  SGRegister_field0_field1* {.bycopy.} = object
    RPL* {.bitsize: 2.}: uint16
    TI* {.bitsize: 1.}: uint16
    index* {.bitsize: 13.}: uint16

  `type`* {.bycopy, union.} = object
    data*: data
    code*: code
    field2*: type_field2



proc A*(this: `type`): uint8 = this.field2.A
proc `A=`*(this: var `type`, value: uint8) = this.field2.A = value
proc segc*(this: `type`): uint8 = this.field2.segc
proc `segc=`*(this: var `type`, value: uint8) = this.field2.segc = value
proc S*(this: SGRegCache_flags): uint8 = this.field2.S
proc `S=`*(this: var SGRegCache_flags, value: uint8) = this.field2.S = value
proc DPL*(this: SGRegCache_flags): uint8 = this.field2.DPL
proc `DPL=`*(this: var SGRegCache_flags, value: uint8) = this.field2.DPL = value
proc P*(this: SGRegCache_flags): uint8 = this.field2.P
proc `P=`*(this: var SGRegCache_flags, value: uint8) = this.field2.P = value
proc AVL*(this: SGRegCache_flags): uint8 = this.field2.AVL
proc `AVL=`*(this: var SGRegCache_flags, value: uint8) = this.field2.AVL = value
proc DB*(this: SGRegCache_flags): uint8 = this.field2.DB
proc `DB=`*(this: var SGRegCache_flags, value: uint8) = this.field2.DB = value
proc G*(this: SGRegCache_flags): uint8 = this.field2.G
proc `G=`*(this: var SGRegCache_flags, value: uint8) = this.field2.G = value
proc RPL*(this: SGRegister_field0): uint16 = this.field1.RPL
proc `RPL=`*(this: var SGRegister_field0, value: uint16) = this.field1.RPL = value
proc TI*(this: SGRegister_field0): uint16 = this.field1.TI
proc `TI=`*(this: var SGRegister_field0, value: uint16) = this.field1.TI = value
proc index*(this: SGRegister_field0): uint16 = this.field1.index
proc `index=`*(this: var SGRegister_field0, value: uint16) = this.field1.index = value
proc raw*(this: SGRegister): uint16 = this.field0.raw
proc `raw=`*(this: var SGRegister, value: uint16) = this.field0.raw = value
proc RPL*(this: SGRegister): uint16 = this.field0.field1.RPL
proc `RPL=`*(this: var SGRegister, value: uint16) = this.field0.field1.RPL = value
proc TI*(this: SGRegister): uint16 = this.field0.field1.TI
proc `TI=`*(this: var SGRegister, value: uint16) = this.field0.field1.TI = value
proc index*(this: SGRegister): uint16 = this.field0.field1.index
proc `index=`*(this: var SGRegister, value: uint16) = this.field0.field1.index = value

type
  DTRegister* {.bycopy.} = object
    selector*: uint16
    base*: uint32
    limit*: uint16

type
  Processor_field0* {.bycopy, union.} = object
    eip*: uint32
    ip*: uint16

  Processor* {.bycopy.} = object of CR
    eflags*: Eflags
    field0*: Processor_field0
    gpregs*: array[GPREGS_COUNT, GPRegister]
    sgregs*: array[SGREGS_COUNT, SGRegister]
    dtregs*: array[DTREGS_COUNT, DTRegister]
    halt*: bool

proc eip*(this: Processor): uint32 = this.field0.eip
proc `eip=`*(this: var Processor, value: uint32) = this.field0.eip = value
proc ip*(this: Processor): uint16 = this.field0.ip
proc `ip=`*(this: var Processor, value: uint16) = this.field0.ip = value

proc is_mode32*(this: var Processor): bool =
  return this.sgregs[CS].cache.flags.DB.bool

proc is_protected*(this: var Processor): bool =
  # FIXME will cause infinite recursion because original implementation of
  # the processor called into `CR::is_protected()` for the parent class
  # implementation.
  return this.is_protected()

proc get_eip*(this: var Processor): uint32 =
  return this.eip

proc get_ip*(this: var Processor): uint32 =
  return this.ip

proc get_gpreg*(this: var Processor, n: reg32_t): uint32 =
  ASSERT(n < GPREGS_COUNT)
  return this.gpregs[n].reg32

proc get_gpreg*(this: var Processor, n: reg16_t): uint16 =
  ASSERT(cast[reg32_t](n) < GPREGS_COUNT)
  return this.gpregs[reg32_t(n)].reg16

proc get_gpreg*(this: var Processor, n: reg8_t): uint8 =
  ASSERT(cast[reg32_t](n) < GPREGS_COUNT)
  return (if n < AH:
            this.gpregs[reg32_t(n)].reg8_l

          else:
            this.gpregs[reg32_t(n.int - AH.int)].reg8_h
          )

proc get_sgreg*(this: Processor, n: sgreg_t, reg: ptr SGRegister): void =
  ASSERT(n < SGREGS_COUNT and reg.isNil().not())
  reg[] = this.sgregs[n]

proc get_dtreg_selector*(this: Processor, n: dtreg_t): uint32 =
  ASSERT(n < DTREGS_COUNT)
  return this.dtregs[n].selector

proc get_dtreg_base*(this: Processor, n: dtreg_t): uint32 =
  ASSERT(n < DTREGS_COUNT)
  return this.dtregs[n].base

proc get_dtreg_limit*(this: Processor, n: dtreg_t): uint16 =
  ASSERT(n < DTREGS_COUNT)
  return this.dtregs[n].limit

proc set_eip*(this: var Processor, v: uint32): void =
  this.eip = v

proc set_ip*(this: var Processor, v: uint16): void =
  this.ip = v

proc set_gpreg*(this: var Processor, n: reg32_t, v: uint32): void =
  ASSERT(n < GPREGS_COUNT)
  this.gpregs[n].reg32 = v

proc set_gpreg*(this: var Processor, n: reg16_t, v: uint16): void =
  ASSERT(cast[reg32_t](n) < GPREGS_COUNT)
  this.gpregs[reg32_t(n)].reg16 = v

proc set_gpreg*(this: var Processor, n: reg8_t, v: uint8): void =
  ASSERT(cast[reg32_t](n) < GPREGS_COUNT)
  if n < AH:
    this.gpregs[reg32_t(n)].reg8_l = v

  else:
    this.gpregs[reg32_t(n.int - AH.int)].reg8_h = v

proc set_sgreg*(this: var Processor, n: sgreg_t, reg: ptr SGRegister): void =
  ASSERT(n < SGREGS_COUNT and not reg.isNil())
  this.sgregs[n] = reg[]

proc set_dtreg*(this: var Processor, n: dtreg_t, sel: uint16, base: uint32, limit: uint16): void =
  ASSERT(n < DTREGS_COUNT)
  this.dtregs[n].selector = sel
  this.dtregs[n].base = base
  this.dtregs[n].limit = limit

proc update_eip*(this: var Processor, v: int32): uint32 =
  this.eip = (this.eip + v.uint32)
  return this.eip

proc update_ip*(this: var Processor, v: int32): uint32 =
  this.ip = (this.ip + v.uint16)
  return this.ip

proc update_gpreg*(this: var Processor, n: reg32_t, v: int32): uint32 =
  ASSERT(n < GPREGS_COUNT)
  this.gpregs[n].reg32 = (this.gpregs[n].reg32 + v.uint32)
  return this.gpregs[n].reg32

proc update_gpreg*(this: var Processor, n: reg16_t, v: int16): uint16 =
  ASSERT(cast[reg32_t](n) < GPREGS_COUNT)
  this.gpregs[reg32_t(n)].reg16 = (this.gpregs[reg32_t(n)].reg16 + v.uint16)
  return this.gpregs[reg32_t(n)].reg16

proc update_gpreg*(this: var Processor, n: reg8_t, v: int8): uint8 =
  ASSERT(cast[reg32_t](n) < GPREGS_COUNT)
  let rhs = if n < AH:
              this.gpregs[reg32_t(n)].reg8_l + v.uint8
            else:
              this.gpregs[reg32_t(n.int - AH.int)].reg8_h + v.uint8

  if n < AH:
    this.gpregs[reg32_t(n)].reg8_l = rhs

  else:
    this.gpregs[reg32_t(n.int - AH.int)].reg8_h = rhs

  return rhs

proc is_halt*(this: Processor): bool =
  return this.halt

proc do_halt*(this: var Processor, h: bool): void =
  this.halt = h
