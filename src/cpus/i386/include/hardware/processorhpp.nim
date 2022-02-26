import
  commonhpp
import
  eflagshpp
import
  crhpp
type
  GPREGS_COUNT* = enum
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
  DI* = enum
    AX
    CX
    DX
    BX
    SP
    BP
    SI
    DI
  
type
  BH* = enum
    AL
    CL
    DL
    BL
    AH
    CH
    DH
    BH
  

type
  SGREGS_COUNT* = enum
    ES
    CS
    SS
    DS
    FS
    GS
    SGREGS_COUNT
  
type
  DTREGS_COUNT* = enum
    GDTR
    IDTR
    LDTR
    TR
    DTREGS_COUNT
  
type
  GPRegister* {.bycopy, union, importcpp.} = object
    reg32*: uint32
    reg16*: uint16
    field2*: GPRegister_field2_Type
  
type
  GPRegister_field2_Type* {.bycopy.} = object
    reg8_l*: uint8
    reg8_h*: uint8
  
proc reg8_l*(this: GPRegister): uint8 = 
  this.field2.reg8_l

proc `reg8_l =`*(this: var GPRegister): uint8 = 
  this.field2.reg8_l

proc reg8_h*(this: GPRegister): uint8 = 
  this.field2.reg8_h

proc `reg8_h =`*(this: var GPRegister): uint8 = 
  this.field2.reg8_h

type
  SGRegCache* {.bycopy, importcpp.} = object
    base*:        uint32
    limit* {.bitsize: 20.}: uint32
    flags*:        SGRegCache_flags_Type
  
type
  data_Type* {.bycopy.} = object
    * {.bitsize: 1.}: uint8
    w* {.bitsize: 1.}: uint8
    exd* {.bitsize: 1.}: uint8
    * {.bitsize: 1.}: uint8
  
type
  code_Type* {.bycopy.} = object
    * {.bitsize: 1.}: uint8
    r* {.bitsize: 1.}: uint8
    cnf* {.bitsize: 1.}: uint8
    * {.bitsize: 1.}: uint8
  
type
  field2_Type* {.bycopy.} = object
    A* {.bitsize: 1.}: uint8
    * {.bitsize: 2.}: uint8
    segc* {.bitsize: 1.}: uint8
  
proc A*(this: type_Type): uint8 = 
  this.field2.A

proc `A =`*(this: var type_Type): uint8 = 
  this.field2.A

proc *(this: type_Type): uint8 = 
  this.field2.

proc ` =`*(this: var type_Type): uint8 = 
  this.field2.

proc segc*(this: type_Type): uint8 = 
  this.field2.segc

proc `segc =`*(this: var type_Type): uint8 = 
  this.field2.segc

type
  type_Type* {.bycopy, union.} = object
    data*: data_Type
    code*: code_Type
    field2*: field2_Type
  
type
  field2_Type* {.bycopy.} = object
    * {.bitsize: 4.}: uint8
    S* {.bitsize: 1.}: uint8
    DPL* {.bitsize: 2.}: uint8
    P* {.bitsize: 1.}: uint8
    AVL* {.bitsize: 1.}: uint8
    * {.bitsize: 1.}: uint8
    DB* {.bitsize: 1.}: uint8
    G* {.bitsize: 1.}: uint8
  
proc *(this: SGRegCache_flags_Type): uint8 = 
  this.field2.

proc ` =`*(this: var SGRegCache_flags_Type): uint8 = 
  this.field2.

proc S*(this: SGRegCache_flags_Type): uint8 = 
  this.field2.S

proc `S =`*(this: var SGRegCache_flags_Type): uint8 = 
  this.field2.S

proc DPL*(this: SGRegCache_flags_Type): uint8 = 
  this.field2.DPL

proc `DPL =`*(this: var SGRegCache_flags_Type): uint8 = 
  this.field2.DPL

proc P*(this: SGRegCache_flags_Type): uint8 = 
  this.field2.P

proc `P =`*(this: var SGRegCache_flags_Type): uint8 = 
  this.field2.P

proc AVL*(this: SGRegCache_flags_Type): uint8 = 
  this.field2.AVL

proc `AVL =`*(this: var SGRegCache_flags_Type): uint8 = 
  this.field2.AVL

proc *(this: SGRegCache_flags_Type): uint8 = 
  this.field2.

proc ` =`*(this: var SGRegCache_flags_Type): uint8 = 
  this.field2.

proc DB*(this: SGRegCache_flags_Type): uint8 = 
  this.field2.DB

proc `DB =`*(this: var SGRegCache_flags_Type): uint8 = 
  this.field2.DB

proc G*(this: SGRegCache_flags_Type): uint8 = 
  this.field2.G

proc `G =`*(this: var SGRegCache_flags_Type): uint8 = 
  this.field2.G

type
  SGRegCache_flags_Type* {.bycopy, union.} = object
    raw* {.bitsize: 12.}: uint16
    type*:        type_Type
    field2*:        field2_Type
  
type
  SGRegister* {.bycopy, importcpp.} = object
    field0*: SGRegister_field0_Type
    cache*: SGRegCache
  
type
  field1_Type* {.bycopy.} = object
    RPL* {.bitsize: 2.}: uint16
    TI* {.bitsize: 1.}: uint16
    index* {.bitsize: 13.}: uint16
  
proc RPL*(this: SGRegister_field0_Type): uint16 = 
  this.field1.RPL

proc `RPL =`*(this: var SGRegister_field0_Type): uint16 = 
  this.field1.RPL

proc TI*(this: SGRegister_field0_Type): uint16 = 
  this.field1.TI

proc `TI =`*(this: var SGRegister_field0_Type): uint16 = 
  this.field1.TI

proc index*(this: SGRegister_field0_Type): uint16 = 
  this.field1.index

proc `index =`*(this: var SGRegister_field0_Type): uint16 = 
  this.field1.index

type
  SGRegister_field0_Type* {.bycopy, union.} = object
    raw*: uint16
    field1*: field1_Type
  
proc raw*(this: SGRegister): uint16 = 
  this.field0.raw

proc `raw =`*(this: var SGRegister): uint16 = 
  this.field0.raw

proc RPL*(this: SGRegister): uint16 = 
  this.field0.field1.RPL

proc `RPL =`*(this: var SGRegister): uint16 = 
  this.field0.field1.RPL

proc TI*(this: SGRegister): uint16 = 
  this.field0.field1.TI

proc `TI =`*(this: var SGRegister): uint16 = 
  this.field0.field1.TI

proc index*(this: SGRegister): uint16 = 
  this.field0.field1.index

proc `index =`*(this: var SGRegister): uint16 = 
  this.field0.field1.index

type
  DTRegister* {.bycopy, importcpp.} = object
    selector*: uint16
    base*: uint32
    limit*: uint16
  
type
  Processor* {.bycopy, importcpp.} = object
    field0*: Processor_field0_Type    
    gpregs*: array[, GPRegister]
    sgregs*: array[, SGRegister]
    dtregs*: array[, DTRegister]
    halt*: bool    
    *:     
  
proc is_mode32*(this: var Processor): bool = 
  return sgregs[CS].cache.flags.DB

proc is_protected*(this: var Processor): bool = 
  return CR.is_protected()

proc get_eip*(this: var Processor): uint32 = 
  return eip

proc get_ip*(this: var Processor): uint32 = 
  return ip

proc get_gpreg*(this: var Processor, n: reg32_t): uint32 = 
  ASSERT(n < GPREGS_COUNT)
  return gpregs[n].reg32

proc get_gpreg*(this: var Processor, n: reg16_t): uint16 = 
  ASSERT(cast[reg32_t](n( < GPREGS_COUNT)
  return gpregs[n].reg16

proc get_gpreg*(this: var Processor, n: reg8_t): uint8 = 
  ASSERT(cast[reg32_t](n( < GPREGS_COUNT)
  return (if n < AH:
            gpregs[n].reg8_l
          
          else:
            gpregs[n - AH].reg8_h
          )

proc get_sgreg*(this: var Processor, n: sgreg_t, reg: ptr SGRegister): void = 
  ASSERT(n < SGREGS_COUNT and reg)
  reg[] = sgregs[n]

proc get_dtreg_selector*(this: var Processor, n: dtreg_t): uint32 = 
  ASSERT(n < DTREGS_COUNT)
  return dtregs[n].selector

proc get_dtreg_base*(this: var Processor, n: dtreg_t): uint32 = 
  ASSERT(n < DTREGS_COUNT)
  return dtregs[n].base

proc get_dtreg_limit*(this: var Processor, n: dtreg_t): uint16 = 
  ASSERT(n < DTREGS_COUNT)
  return dtregs[n].limit

proc set_eip*(this: var Processor, v: uint32): void = 
  eip = v

proc set_ip*(this: var Processor, v: uint16): void = 
  ip = v

proc set_gpreg*(this: var Processor, n: reg32_t, v: uint32): void = 
  ASSERT(n < GPREGS_COUNT)
  gpregs[n].reg32 = v

proc set_gpreg*(this: var Processor, n: reg16_t, v: uint16): void = 
  ASSERT(cast[reg32_t](n( < GPREGS_COUNT)
  gpregs[n].reg16 = v

proc set_gpreg*(this: var Processor, n: reg8_t, v: uint8): void = 
  ASSERT(cast[reg32_t](n( < GPREGS_COUNT)
  ((if n < AH:
      gpregs[n].reg8_l
    
    else:
      gpregs[n - AH].reg8_h
    )) = v

proc set_sgreg*(this: var Processor, n: sgreg_t, reg: ptr SGRegister): void = 
  ASSERT(n < SGREGS_COUNT and reg)
  sgregs[n] = reg[]

proc set_dtreg*(this: var Processor, n: dtreg_t, sel: uint16, base: uint32, limit: uint16): void = 
  ASSERT(n < DTREGS_COUNT)
  dtregs[n].selector = sel
  dtregs[n].base = base
  dtregs[n].limit = limit

proc update_eip*(this: var Processor, v: int32): uint32 = 
  return eip = (eip + v)

proc update_ip*(this: var Processor, v: int32): uint32 = 
  return ip = (ip + v)

proc update_gpreg*(this: var Processor, n: reg32_t, v: int32): uint32 = 
  ASSERT(n < GPREGS_COUNT)
  return gpregs[n].reg32 = (gpregs[n].reg32 + v)

proc update_gpreg*(this: var Processor, n: reg16_t, v: int16): uint16 = 
  ASSERT(cast[reg32_t](n( < GPREGS_COUNT)
  return gpregs[n].reg16 = (gpregs[n].reg16 + v)

proc update_gpreg*(this: var Processor, n: reg8_t, v: int8): uint8 = 
  ASSERT(cast[reg32_t](n( < GPREGS_COUNT)
  return ((if n < AH:
             gpregs[n].reg8_l
           
           else:
             gpregs[n - AH].reg8_h
           )) = (((if n < AH:
                     gpregs[n].reg8_l
                   
                   else:
                     gpregs[n - AH].reg8_h
                   )) + v)

proc is_halt*(this: var Processor): bool = 
  return halt

proc do_halt*(this: var Processor, h: bool): void = 
  halt = h

type
  Processor_field0_Type* {.bycopy, union.} = object
    eip*: uint32
    ip*: uint16
  
proc eip*(this: Processor): uint32 = 
  this.field0.eip

proc `eip =`*(this: var Processor): uint32 = 
  this.field0.eip

proc ip*(this: Processor): uint16 = 
  this.field0.ip

proc `ip =`*(this: var Processor): uint16 = 
  this.field0.ip
