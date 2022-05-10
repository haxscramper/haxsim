import common
import eflags
import cr
import instruction/syntaxes
export Reg32T, Reg16T, Reg8T, SgRegT, DTregT

type
  GPRegister* {.union.} = object
    ## General-purpose register
    reg32*: U32 ## Full (extended, 32-bit) value of the regsiters
    reg16*: U16 ## Lower word of the registers
    regLH*: RegLH ## Two lower bytes of the register

  RegLH* = object
    reg8L*: U8
    reg8H*: U8

proc reg8L*(this: GPRegister): U8 = this.regLH.reg8L
proc `reg8L=`*(this: var GPRegister, value: U8) = this.regLH.reg8L = value
proc reg8H*(this: GPRegister): U8 = this.regLH.reg8H
proc `reg8H=`*(this: var GPRegister, value: U8) = this.regLH.reg8H = value

type
  SGRegCache* = object
    ## To allow for fast accesses to segmented memory, the x86 processor
    ## keeps a copy of each segment descriptor in a special descriptor
    ## cache. This saves the processor from accessing the GDT for every
    ## memory access made
    base*:        U32
    limit* {.bitsize: 20.}: U32
    flags*:        SGRegCacheFlags

  data* = object
    field0* {.bitsize: 1.}: U8
    w*      {.bitsize: 1.}: U8
    exd*    {.bitsize: 1.}: U8
    field3* {.bitsize: 1.}: U8

  code* = object
    field0* {.bitsize: 1.}: U8
    r*      {.bitsize: 1.}: U8
    cnf*    {.bitsize: 1.}: U8
    field3* {.bitsize: 1.}: U8

  typeField2* = object
    A*      {.bitsize: 1.}: U8
    field1* {.bitsize: 2.}: U8
    segc*   {.bitsize: 1.}: U8

  SGRegCacheFlagsField2* = object
    field0* {.bitsize: 4.}: U8
    S*      {.bitsize: 1.}: U8
    DPL*    {.bitsize: 2.}: U8
    P*      {.bitsize: 1.}: U8
    AVL*    {.bitsize: 1.}: U8
    field5* {.bitsize: 1.}: U8
    DB*     {.bitsize: 1.}: U8
    G*      {.bitsize: 1.}: U8

  SGRegCacheFlags* {.union.} = object
    raw* {.bitsize: 12.}: U16
    typ*:        typ
    field2*:        SGRegCacheFlagsField2

  SGRegister* = object
    ## Segment register object
    data*: SGRegisterData ## Actual value of the segment register
    cache*:  SGRegCache ## Segment register access cache

  # SGRegisterData* {.union.} = object
  #   raw*:    U16
  #   impl*: SGRegisterDataImpl

  SGRegisterData* = object
    RPL*   {.bitsize: 2.}: U16
    TI*    {.bitsize: 1.}: U16
    index* {.bitsize: 13.}: U16

  typ* {.union.} = object
    data*:   data
    code*:   code
    field2*: typeField2


proc A*(this: typ): U8 = this.field2.A
proc `A=`*(this: var typ, value: U8) = this.field2.A = value
proc segc*(this: typ): U8 = this.field2.segc
proc `segc=`*(this: var typ, value: U8) = this.field2.segc = value
proc S*(this: SGRegCacheFlags): U8 = this.field2.S
proc `S=`*(this: var SGRegCacheFlags, value: U8) = this.field2.S = value
proc DPL*(this: SGRegCacheFlags): U8 = this.field2.DPL
proc `DPL=`*(this: var SGRegCacheFlags, value: U8) = this.field2.DPL = value
proc P*(this: SGRegCacheFlags): U8 = this.field2.P
proc `P=`*(this: var SGRegCacheFlags, value: U8) = this.field2.P = value
proc AVL*(this: SGRegCacheFlags): U8 = this.field2.AVL
proc `AVL=`*(this: var SGRegCacheFlags, value: U8) = this.field2.AVL = value
proc DB*(this: SGRegCacheFlags): U8 = this.field2.DB
proc `DB=`*(this: var SGRegCacheFlags, value: U8) = this.field2.DB = value
proc G*(this: SGRegCacheFlags): U8 = this.field2.G
proc `G=`*(this: var SGRegCacheFlags, value: U8) = this.field2.G = value
# proc RPL*(this: SGRegisterData): U16 = this.impl.RPL
# proc `RPL=`*(this: var SGRegisterData, value: U16) = this.impl.RPL = value
# proc TI*(this: SGRegisterData): U16 = this.impl.TI
# proc `TI=`*(this: var SGRegisterData, value: U16) = this.impl.TI = value
# proc index*(this: SGRegisterData): U16 = this.impl.index
# proc `index=`*(this: var SGRegisterData, value: U16) = this.impl.index = value
proc raw*(this: SGRegister): U16 = cast[U16](this.data)
proc `raw=`*(this: var SGRegister, value: U16) = this.data = cast[SgRegisterData](value)

proc RPL*(this: SGRegister): U16 = this.data.RPL
proc `RPL=`*(this: var SGRegister, value: U16) = this.data.RPL = value
proc TI*(this: SGRegister): U16 = this.data.TI
proc `TI=`*(this: var SGRegister, value: U16) = this.data.TI = value
proc index*(this: SGRegister): U16 = this.data.index
proc `index=`*(this: var SGRegister, value: U16) = this.data.index = value

type
  DTRegister* = object
    ## Data register object
    selector*: U16
    base*: U32
    limit*: U16

  InstructionPointer* {.union.} = object
    ## The instruction pointer register (EIP) contains the offset address,
    ## relative to the start of the current code segment, of the next
    ## sequential instruction to be executed. The instruction pointer is
    ## not directly visible to the programmer; it is controlled implicitly
    ## by control-transfer instructions, interrupts, and exceptions.
    eip*: U32 ## Extended instruction pointer
    ip*: U16 ## Base instruction pointer

  ProcessorObj* =  object of CR
    ## Current state of the CPU
    logger*: EmuLogger ## Reference to main logger instance
    eflags*: Eflags ## Extended execution flags
    field0*: InstructionPointer ## Value of the instruction pointer
    gpregs*: array[Reg32T, GPRegister] ## General-purpose registers
    sgregs*: array[SgRegT, SGRegister] ## Segment registers hold the
    ## segment address of various items. They are only available in 16
    ## values. They can only be set by a general register or special
    ## instructions.
    dtregs*: array[DTregT, DTRegister] ## Data registers
    halt*: bool ## Is execution halted?

  Processor* = ref ProcessorObj ## Reference type for the processor

template log*(p: Processor, ev: EmuEvent, depth: int = -2): untyped =
  p.logger.log(ev, depth)

proc eip*(this: Processor): U32 = this.field0.eip
proc `eip=`*(this: Processor, value: U32) = this.field0.eip = value
proc ip*(this: Processor): U16 = this.field0.ip
proc `ip=`*(this: Processor, value: U16) = this.field0.ip = value

proc isMode32*(this: var Processor): bool =
  return this.sgregs[CS].cache.flags.DB.bool

func `[]`*(this: var Processor, reg: SgRegT): var SGRegister = this.sgregs[reg]

proc setMode32*(this: var Processor, mode: bool) =
  this[CS].cache.flags.DB = mode.U8

proc isProtected*(this: var Processor): bool =
  # FIXME will cause infinite recursion because original implementation of
  # the processor called into `CR::isProtected()` for the parent class
  # implementation.
  return CR(this).isProtected()

proc getEip*(this: Processor): U32 =
  result = this.eip
  this.log ev(eekGetEIP).withIt do:
    it.value = evalue(result)

proc getIp*(this: Processor): U16 =
  result = this.ip
  this.log ev(eekGetIP).withIt do:
    it.value = evalue(result)

proc getGpreg*(this: Processor, n: Reg32T): U32 =
  result = this.gpregs[n].reg32
  this.log ev(eekGetReg32, evalue(result), n.U8)

proc getGpreg*(this: Processor, n: Reg16T): U16 =
  result = this.gpregs[Reg32T(n.int)].reg16
  this.log ev(eekGetReg16, evalue(result), n.U8)

proc getGpreg*(this: Processor, n: Reg8T, log: bool = true): U8 =
  if n < AH:
    result = this.gpregs[Reg32T(n.int)].reg8L

  else:
    result = this.gpregs[Reg32T(n.int - AH.int)].reg8H

  this.log ev(eekGetReg8).withIt do:
    it.memAddr = n.uint64
    it.value = evalue(result)

proc `[]`*(this: Processor, reg: Reg8T): U8 = this.getGPreg(reg)
proc `[]`*(this: Processor, reg: Reg16T): U16 = this.getGPreg(reg)
proc `[]`*(this: Processor, reg: Reg32T): U32 = this.getGPreg(reg)


proc getSgreg*(this: Processor, n: SgRegT): SgRegister =
  result = this.sgregs[n]

proc getDtregSelector*(this: Processor, n: DTregT): U32 =
  result = this.dtregs[n].selector
  this.log ev(eekGetDtRegSelector, evalue(result), n.U8)

proc getDtregBase*(this: Processor, n: DTregT): U32 =
  result = this.dtregs[n].base
  this.log ev(eekGetDtRegBase, evalue(result), n.U8)

proc getDtregLimit*(this: Processor, n: DTregT): U16 =
  result = this.dtregs[n].limit
  this.log ev(eekGetDtRegLimit, evalue(result), n.U8)

proc setEip*(this: Processor, v: U32): void =
  this.eip = v
  assertRef(this.logger)
  this.log ev(eekSetEIP).withIt do:
    it.value = evalue(v, 32)

proc setIp*(this: var Processor, v: U16): void =
  this.ip = v
  assertRef(this.logger)
  this.log ev(eekSetIP).withIt do:
    it.value = evalue(v, 16)

proc setGpreg*(this: var Processor, n: Reg32T, v: U32): void =
  this.gpregs[n].reg32 = v
  this.log ev(eekSetReg32, evalue(v), n.U8)

proc setGpreg*(this: var Processor, n: Reg16T, v: U16): void =
  this.gpregs[Reg32T(n.int)].reg16 = v
  this.log ev(eekSetReg16, evalue(v), n.U8)

proc setGpreg*(this: var Processor, n: Reg8T, v: U8): void =
  if n < AH:
    this.gpregs[Reg32T(n.int)].reg8L = v

  else:
    this.gpregs[Reg32T(n.int - AH.int)].reg8H = v


proc `[]=`*(this: var Processor, reg: Reg8T, value: U8) =
  this.setGPreg(reg, value)

proc `[]=`*(this: var Processor, reg: Reg16T, value: U16) =
  this.setGPreg(reg, value)

proc `[]=`*(this: var Processor, reg: Reg32T, value: U32) =
  this.setGPreg(reg, value)

proc setSgreg*(this: var Processor, n: SgRegT, reg: SGRegister): void =
  this.sgregs[n] = reg

proc setDtreg*(this: var Processor, n: DTregT, sel: U16, base: U32, limit: U16): void =
  this.dtregs[n].selector = sel
  this.dtregs[n].base = base
  this.dtregs[n].limit = limit

proc updateEip*(this: var Processor, v: int32) =
  this.setEIp(this.eip + v.U32)

proc updateIp*(this: var Processor, v: int32) =
  this.setIP(this.ip + v.U16)

proc updateGpreg*(this: var Processor, n: Reg32T, v: int32) =
  this.gpregs[n].reg32 = (this.gpregs[n].reg32 + v.U32)

proc updateGpreg*(this: var Processor, n: Reg16T, v: int16) =
  this.gpregs[Reg32T(n.int)].reg16 = (this.gpregs[Reg32T(n.int)].reg16 + v.U16)

proc updateGpreg*(this: var Processor, n: Reg8T, v: int8) =
  let rhs = if n < AH:
              this.gpregs[Reg32T(n.int)].reg8L + v.U8
            else:
              this.gpregs[Reg32T(n.int - AH.int)].reg8H + v.U8

  if n < AH:
    this.gpregs[Reg32T(n.int)].reg8L = rhs

  else:
    this.gpregs[Reg32T(n.int - AH.int)].reg8H = rhs

proc isHalt*(this: Processor): bool =
  return this.halt

proc doHalt*(this: var Processor, h: bool): void =
  this.halt = h

import hardware/[cr, eflags]
import common

proc initProcessor*(logger: EmuLogger): Processor =
  assertRef(logger)
  logger.logScope ev(eekInitCPU)
  result = Processor(logger: logger)
  initCR(result)
  assertRef(logger)
  # Processor execution starts from specific memory location that stores
  # BIOS. This memory might be mapped to a ROM chip.
  result.set_eip(0x0000fff0)
  result.set_crn(0, 0x60000010)
  result.eflags.set_eflags(0x00000002)
  result.sgregs[CS].data = cast[SgRegisterData](0xf000)
  result.sgregs[CS].cache.base = 0xffff0000u32
  result.sgregs[CS].cache.flags.typ.segc = 1
  for i in ES .. GS:
    result.sgregs[i].cache.limit = 0xffff
    result.sgregs[i].cache.flags.P = 1
    result.sgregs[i].cache.flags.typ.A = 1
    result.sgregs[i].cache.flags.typ.data.w = 1

  result.dtregs[IDTR].base  = 0x0000
  result.dtregs[IDTR].limit = 0xffff
  result.dtregs[GDTR].base  = 0x0000
  result.dtregs[GDTR].limit = 0xffff
  result.dtregs[LDTR].base  = 0x0000
  result.dtregs[LDTR].limit = 0xffff
  result.halt = false
