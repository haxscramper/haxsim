import commonhpp
import eflagshpp
import crhpp

type
  Reg32T* = enum
    EAX
    ECX
    EDX ## Called the Data register It is used for I/O port access,
    ## arithmetic, some interrupt calls.
    EBX
    ESP ## Stack pointer register Holds the top address of the stack
    EBP ## Stack Base pointer register. Holds the base address of the stack
    ESI ## Source index register. Used for string and memory array copying
    EDI ## Destination index register Used for string, memory array copying
    ## and setting and for far pointer addressing with ES
    GPREGSCOUNT

type
  Reg16T* = enum
    AX
    CX
    DX
    BX
    SP ## Part of ESP
    BP ## Part of EBP
    SI ## Part of ESI
    DI ## Part of EDI

type
  Reg8T* = enum
    AL
    CL
    DL
    BL
    AH
    CH
    DH
    BH


type
  SgRegT* = enum
    ES
    CS ## 'Code Segment' Holds the Code segment in which your program runs.
    SS ## 'Stack Segment' Holds the Stack segment your program uses.
    DS ## 'Data Segment' Holds the Data segment that your program accesses.
    FS
    GS
    SGREGSCOUNT

type
  dtregT* = enum
    GDTR
    IDTR
    LDTR
    TR
    DTREGSCOUNT

type
  GPRegister* {.union.} = object
    reg32*: uint32
    reg16*: uint16
    regLH*: RegLH

  RegLH* = object
    reg8L*: uint8
    reg8H*: uint8

proc reg8L*(this: GPRegister): uint8 = this.regLH.reg8L
proc `reg8L=`*(this: var GPRegister, value: uint8) = this.regLH.reg8L = value
proc reg8H*(this: GPRegister): uint8 = this.regLH.reg8H
proc `reg8H=`*(this: var GPRegister, value: uint8) = this.regLH.reg8H = value

type
  SGRegCache* = object
    base*:        uint32
    limit* {.bitsize: 20.}: uint32
    flags*:        SGRegCacheFlags

  data* = object
    field0* {.bitsize: 1.}: uint8
    w*      {.bitsize: 1.}: uint8
    exd*    {.bitsize: 1.}: uint8
    field3* {.bitsize: 1.}: uint8

  code* = object
    field0* {.bitsize: 1.}: uint8
    r*      {.bitsize: 1.}: uint8
    cnf*    {.bitsize: 1.}: uint8
    field3* {.bitsize: 1.}: uint8

  typeField2* {.bycopy.} = object
    A*      {.bitsize: 1.}: uint8
    field1* {.bitsize: 2.}: uint8
    segc*   {.bitsize: 1.}: uint8

  SGRegCacheFlagsField2* {.bycopy.} = object
    field0* {.bitsize: 4.}: uint8
    S*      {.bitsize: 1.}: uint8
    DPL*    {.bitsize: 2.}: uint8
    P*      {.bitsize: 1.}: uint8
    AVL*    {.bitsize: 1.}: uint8
    field5* {.bitsize: 1.}: uint8
    DB*     {.bitsize: 1.}: uint8
    G*      {.bitsize: 1.}: uint8

  SGRegCacheFlags* {.union.} = object
    raw* {.bitsize: 12.}: uint16
    `type`*:        `type`
    field2*:        SGRegCacheFlagsField2

  SGRegister* = object
    field0*: SGRegisterField0
    cache*:  SGRegCache

  SGRegisterField0* {.union.} = object
    raw*:    uint16
    field1*: SGRegisterField0Field1


  SGRegisterField0Field1* = object
    RPL*   {.bitsize: 2.}: uint16
    TI*    {.bitsize: 1.}: uint16
    index* {.bitsize: 13.}: uint16

  `type`* {.union.} = object
    data*:   data
    code*:   code
    field2*: typeField2



proc A*(this: `type`): uint8 = this.field2.A
proc `A=`*(this: var `type`, value: uint8) = this.field2.A = value
proc segc*(this: `type`): uint8 = this.field2.segc
proc `segc=`*(this: var `type`, value: uint8) = this.field2.segc = value
proc S*(this: SGRegCacheFlags): uint8 = this.field2.S
proc `S=`*(this: var SGRegCacheFlags, value: uint8) = this.field2.S = value
proc DPL*(this: SGRegCacheFlags): uint8 = this.field2.DPL
proc `DPL=`*(this: var SGRegCacheFlags, value: uint8) = this.field2.DPL = value
proc P*(this: SGRegCacheFlags): uint8 = this.field2.P
proc `P=`*(this: var SGRegCacheFlags, value: uint8) = this.field2.P = value
proc AVL*(this: SGRegCacheFlags): uint8 = this.field2.AVL
proc `AVL=`*(this: var SGRegCacheFlags, value: uint8) = this.field2.AVL = value
proc DB*(this: SGRegCacheFlags): uint8 = this.field2.DB
proc `DB=`*(this: var SGRegCacheFlags, value: uint8) = this.field2.DB = value
proc G*(this: SGRegCacheFlags): uint8 = this.field2.G
proc `G=`*(this: var SGRegCacheFlags, value: uint8) = this.field2.G = value
proc RPL*(this: SGRegisterField0): uint16 = this.field1.RPL
proc `RPL=`*(this: var SGRegisterField0, value: uint16) = this.field1.RPL = value
proc TI*(this: SGRegisterField0): uint16 = this.field1.TI
proc `TI=`*(this: var SGRegisterField0, value: uint16) = this.field1.TI = value
proc index*(this: SGRegisterField0): uint16 = this.field1.index
proc `index=`*(this: var SGRegisterField0, value: uint16) = this.field1.index = value
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
  ProcessorField0* {.union.} = object
    ## The instruction pointer register (EIP) contains the offset address,
    ## relative to the start of the current code segment, of the next
    ## sequential instruction to be executed. The instruction pointer is
    ## not directly visible to the programmer; it is controlled implicitly
    ## by control-transfer instructions, interrupts, and exceptions.
    eip*: uint32
    ip*: uint16

  Processor* = ref object of CR
    eflags*: Eflags
    field0*: ProcessorField0
    gpregs*: array[GPREGSCOUNT, GPRegister]
    sgregs*: array[SGREGSCOUNT, SGRegister] ## Segment registers hold the
    ## segment address of various items. They are only available in 16
    ## values. They can only be set by a general register or special
    ## instructions.
    dtregs*: array[DTREGSCOUNT, DTRegister]
    halt*: bool

proc eip*(this: Processor): uint32 = this.field0.eip
proc `eip=`*(this: var Processor, value: uint32) = this.field0.eip = value
proc ip*(this: Processor): uint16 = this.field0.ip
proc `ip=`*(this: var Processor, value: uint16) = this.field0.ip = value

proc isMode32*(this: var Processor): bool =
  return this.sgregs[CS].cache.flags.DB.bool

proc isProtected*(this: var Processor): bool =
  # FIXME will cause infinite recursion because original implementation of
  # the processor called into `CR::isProtected()` for the parent class
  # implementation.
  return CR(this).isProtected()

proc getEip*(this: var Processor): uint32 =
  # echov this.halt
  # pprint this
  result = this.eip
  # echov "end"

proc getIp*(this: var Processor): uint32 =
  return this.ip

proc getGpreg*(this: var Processor, n: Reg32T): uint32 =
  ASSERT(n < GPREGSCOUNT)
  return this.gpregs[n].reg32

proc getGpreg*(this: var Processor, n: Reg16T): uint16 =
  ASSERT(cast[Reg32T](n) < GPREGSCOUNT)
  return this.gpregs[Reg32T(n)].reg16

proc getGpreg*(this: var Processor, n: Reg8T): uint8 =
  ASSERT(cast[Reg32T](n) < GPREGSCOUNT)
  return (if n < AH:
            this.gpregs[Reg32T(n)].reg8L

          else:
            this.gpregs[Reg32T(n.int - AH.int)].reg8H
          )

proc getSgreg*(this: Processor, n: SgRegT, reg: var SGRegister): void =
  ASSERT(n < SGREGSCOUNT)
  reg = this.sgregs[n]

proc getDtregSelector*(this: Processor, n: dtregT): uint32 =
  ASSERT(n < DTREGSCOUNT)
  return this.dtregs[n].selector

proc getDtregBase*(this: Processor, n: dtregT): uint32 =
  ASSERT(n < DTREGSCOUNT)
  return this.dtregs[n].base

proc getDtregLimit*(this: Processor, n: dtregT): uint16 =
  ASSERT(n < DTREGSCOUNT)
  return this.dtregs[n].limit

proc setEip*(this: var Processor, v: uint32): void =
  this.eip = v

proc setIp*(this: var Processor, v: uint16): void =
  this.ip = v

proc setGpreg*(this: var Processor, n: Reg32T, v: uint32): void =
  ASSERT(n < GPREGSCOUNT)
  this.gpregs[n].reg32 = v

proc setGpreg*(this: var Processor, n: Reg16T, v: uint16): void =
  ASSERT(cast[Reg32T](n) < GPREGSCOUNT)
  this.gpregs[Reg32T(n)].reg16 = v

proc setGpreg*(this: var Processor, n: Reg8T, v: uint8): void =
  ASSERT(cast[Reg32T](n) < GPREGSCOUNT)
  if n < AH:
    this.gpregs[Reg32T(n)].reg8L = v

  else:
    this.gpregs[Reg32T(n.int - AH.int)].reg8H = v

proc setSgreg*(this: var Processor, n: SgRegT, reg: SGRegister): void =
  ASSERT(n < SGREGSCOUNT)
  this.sgregs[n] = reg

proc setDtreg*(this: var Processor, n: dtregT, sel: uint16, base: uint32, limit: uint16): void =
  ASSERT(n < DTREGSCOUNT)
  this.dtregs[n].selector = sel
  this.dtregs[n].base = base
  this.dtregs[n].limit = limit

proc updateEip*(this: var Processor, v: int32): uint32 =
  this.eip = (this.eip + v.uint32)
  return this.eip

proc updateIp*(this: var Processor, v: int32): uint32 =
  this.ip = (this.ip + v.uint16)
  return this.ip

proc updateGpreg*(this: var Processor, n: Reg32T, v: int32): uint32 =
  ASSERT(n < GPREGSCOUNT)
  this.gpregs[n].reg32 = (this.gpregs[n].reg32 + v.uint32)
  return this.gpregs[n].reg32

proc updateGpreg*(this: var Processor, n: Reg16T, v: int16): uint16 =
  ASSERT(cast[Reg32T](n) < GPREGSCOUNT)
  this.gpregs[Reg32T(n)].reg16 = (this.gpregs[Reg32T(n)].reg16 + v.uint16)
  return this.gpregs[Reg32T(n)].reg16

proc updateGpreg*(this: var Processor, n: Reg8T, v: int8): uint8 =
  ASSERT(cast[Reg32T](n) < GPREGSCOUNT)
  let rhs = if n < AH:
              this.gpregs[Reg32T(n)].reg8L + v.uint8
            else:
              this.gpregs[Reg32T(n.int - AH.int)].reg8H + v.uint8

  if n < AH:
    this.gpregs[Reg32T(n)].reg8L = rhs

  else:
    this.gpregs[Reg32T(n.int - AH.int)].reg8H = rhs

  return rhs

proc isHalt*(this: Processor): bool =
  return this.halt

proc doHalt*(this: var Processor, h: bool): void =
  this.halt = h
