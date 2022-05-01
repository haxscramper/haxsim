import common

type
  EflagsImpl* {.union.} = object
    reg32*: U32
    reg16*: U16
    field2*: EflagsImplField2Type
  
  EflagsImplField2Type* = object
    CF*      {.bitsize: 1.}: U32
    field1*  {.bitsize: 1.}: U32
    PF*      {.bitsize: 1.}: U32
    field3*  {.bitsize: 1.}: U32
    AF*      {.bitsize: 1.}: U32
    field5*  {.bitsize: 1.}: U32
    ZF*      {.bitsize: 1.}: U32
    SF*      {.bitsize: 1.}: U32
    TF*      {.bitsize: 1.}: U32
    IF*      {.bitsize: 1.}: U32
    DF*      {.bitsize: 1.}: U32
    OF*      {.bitsize: 1.}: U32
    IOPL*    {.bitsize: 2.}: U32
    NT*      {.bitsize: 1.}: U32
    field14* {.bitsize: 1.}: U32
    RF*      {.bitsize: 1.}: U32
    VM*      {.bitsize: 1.}: U32
    AC*      {.bitsize: 1.}: U32
    VIF*     {.bitsize: 1.}: U32
    VIP*     {.bitsize: 1.}: U32
    ID*      {.bitsize: 1.}: U32

proc CF*(this: EflagsImpl): U32 =
  this.field2.CF

proc `CF=`*(this: var EflagsImpl, value: U32) =
  this.field2.CF = value

proc PF*(this: EflagsImpl): U32 =
  this.field2.PF

proc `PF=`*(this: var EflagsImpl, value: U32) =
  this.field2.PF = value

proc AF*(this: EflagsImpl): U32 =
  this.field2.AF

proc `AF=`*(this: var EflagsImpl, value: U32) =
  this.field2.AF = value

proc ZF*(this: EflagsImpl): U32 =
  this.field2.ZF

proc `ZF=`*(this: var EflagsImpl, value: U32) =
  this.field2.ZF = value

proc SF*(this: EflagsImpl): U32 = this.field2.SF
proc `SF=`*(this: var EflagsImpl, value: U32) = this.field2.SF = value
proc TF*(this: EflagsImpl): U32 = this.field2.TF
proc `TF=`*(this: var EflagsImpl, value: U32) = this.field2.TF = value
proc IF*(this: EflagsImpl): U32 = this.field2.IF
proc `IF=`*(this: var EflagsImpl, value: U32) = this.field2.IF = value
proc DF*(this: EflagsImpl): U32 = this.field2.DF
proc `DF=`*(this: var EflagsImpl, value: U32) = this.field2.DF = value
proc OF*(this: EflagsImpl): U32 = this.field2.OF
proc `OF=`*(this: var EflagsImpl, value: U32) = this.field2.OF = value
proc IOPL*(this: EflagsImpl): U32 = this.field2.IOPL
proc `IOPL=`*(this: var EflagsImpl, value: U32) = this.field2.IOPL = value
proc NT*(this: EflagsImpl): U32 = this.field2.NT
proc `NT=`*(this: var EflagsImpl, value: U32) = this.field2.NT = value
proc RF*(this: EflagsImpl): U32 = this.field2.RF
proc `RF=`*(this: var EflagsImpl, value: U32) = this.field2.RF = value
proc VM*(this: EflagsImpl): U32 = this.field2.VM
proc `VM=`*(this: var EflagsImpl, value: U32) = this.field2.VM = value
proc AC*(this: EflagsImpl): U32 = this.field2.AC
proc `AC=`*(this: var EflagsImpl, value: U32) = this.field2.AC = value
proc VIF*(this: EflagsImpl): U32 = this.field2.VIF
proc `VIF=`*(this: var EflagsImpl, value: U32) = this.field2.VIF = value
proc VIP*(this: EflagsImpl): U32 = this.field2.VIP
proc `VIP=`*(this: var EflagsImpl, value: U32) = this.field2.VIP = value
proc ID*(this: EflagsImpl): U32 = this.field2.ID
proc `ID=`*(this: var EflagsImpl, value: U32) = this.field2.ID = value

type
  Eflags* = object
    eflags*: EflagsImpl

proc setEflags*(this: var Eflags, v: U32): void = this.eflags.reg32 = v
proc setFlags*(this: var Eflags, v: U16): void = this.eflags.reg16 = v

proc getEflags*(this: Eflags): U32 = return this.eflags.reg32
proc getFlags*(this: Eflags): U16 = return this.eflags.reg16
proc isCarry*(this: Eflags): bool = return this.eflags.CF.bool
proc isParity*(this: Eflags): bool = return this.eflags.PF.bool
proc isZero*(this: Eflags): bool = return this.eflags.ZF.bool
proc isSign*(this: Eflags): bool = return this.eflags.SF.bool
proc isOverflow*(this: Eflags): bool = return this.eflags.OF.bool
proc isInterrupt*(this: Eflags): bool = return this.eflags.IF.bool
proc isDirection*(this: Eflags): bool = return this.eflags.DF.bool

proc setCarry*(this: var Eflags, carry: bool): void =
  this.eflags.CF = carry.U32

proc setParity*(this: var Eflags, parity: bool): void =
  this.eflags.PF = parity.U32

proc setZero*(this: var Eflags, zero: bool): void =
  this.eflags.ZF = zero.U32

proc setSign*(this: var Eflags, sign: bool): void =
  this.eflags.SF = sign.U32

proc setOverflow*(this: var Eflags, over: bool): void =
  this.eflags.OF = over.U32

proc setInterrupt*(this: var Eflags, interrupt: bool): void =
  this.eflags.IF = interrupt.U32

proc setDirection*(this: var Eflags, dir: bool): void =
  this.eflags.DF = dir.U32

import common
import std/[lenientops]

proc chk_parity*(this: var Eflags, v: U8): bool =
  var p: bool = true
  for i in 0 ..< 8:
    p = (p xor toBool((v shr i) and 1))
  return p


proc updateAdd*[T](this: var Eflags, v1: T, v2: U32) =
  var sr, s1, s2: bool
  var result: uint64
  var size: U8
  var v2 = v2
  v2 = cast[T](v2)
  result = cast[uint64](v1) + v2
  size = sizeof(T) * 8
  s1 = toBool(v1 shr (size - 1))
  s2 = toBool(v2 shr (size - 1))
  sr = toBool((result shr (size - 1)) and 1)
  this.set_carry(toBool(result shr size))
  this.set_parity(this.chk_parity(U8(result and 0xff)))
  this.set_zero(not(result.toBool()))
  this.set_sign(sr)
  this.set_overflow(not((s1 xor s2)) and s1 xor sr)




proc updateOr*[T](this: var Eflags, v1: T, v2: U32) =
  var result: T
  var size: U8
  var v2 = v2
  v2 = cast[T](v2)
  result = T(v1) or T(v2)
  size = sizeof(T) * 8
  this.set_carry(false)
  this.set_parity(this.chk_parity(U8(result and 0xff)))
  this.set_zero(not(result.toBool()))
  this.set_sign(toBool((result shr (size - 1)) and 1))
  this.set_overflow(false)




proc updateAnd*[T](this: var Eflags, v1: T, v2: U32) =
  var result: T
  var size: U8
  var v2 = v2
  v2 = cast[T](v2)
  result = T(v1) and T(v2)
  size = sizeof(T) * 8
  this.set_carry(false)
  this.set_parity(this.chk_parity(U8(result and 0xff)))
  this.set_zero(not(result.toBool()))
  this.set_sign(toBool((result shr (size - 1)) and 1))
  this.set_overflow(false)




proc updateSub*[T](this: var Eflags, v1: T, v2: U32) =
  var sr, s1, s2: bool
  var result: uint64
  var size: U8
  var v2 = v2
  v2 = cast[T](v2)
  result = cast[uint64](v1) - v2
  size = sizeof(T) * 8
  s1 = toBool(v1 shr (size - 1))
  s2 = toBool(v2 shr (size - 1))
  sr = toBool((result shr (size - 1)) and 1)
  this.set_carry(toBool(result shr size))
  this.set_parity(this.chk_parity(U8(result and 0xff)))
  this.set_zero(not(result.toBool()))
  this.set_sign(sr)
  this.set_overflow(s1 xor s2 and s1 xor sr)




proc updateMul*[T](this: var Eflags, v1: T, v2: U32) =
  var result: uint64
  var size: U8
  var v2 = cast[T](v2)
  result = cast[uint64](v1) * v2
  size = sizeof(T) * 8
  this.set_carry(toBool(result shr size))
  this.set_overflow(toBool(result shr size))




proc updateImul*[T](this: var Eflags, v1: T, v2: int32) =
  var result: int64
  var size: U8
  let v2 = cast[T](v2)
  result = cast[int64](v1) * v2
  size = sizeof(T) * 8
  this.set_carry((result shr size) != -1)
  this.set_overflow((result shr size) != -1)




proc updateShl*[T](this: var Eflags, v: T, c: U8) =
  var result: T
  var size: U8
  result = v shl c
  size = sizeof(T) * 8
  this.set_carry(toBool((v shr (size - c)) and 1))
  this.set_parity(this.chk_parity(U8(result and 0xff)))
  this.set_zero(not(result.toBool()))
  this.set_sign(toBool(result shr (size - 1) and 1))
  if c == 1:
    this.set_overflow(toBool(
      ((v shr (size - 1)) and 1) xor
      ((v shr (size - 2)) and 1)))




proc updateShr*[T](this: var Eflags, v: T, c: U8) =
  var result: T
  var size: U8
  result = v shr c
  size = sizeof(T) * 8
  this.set_carry(toBool((v shr (c - 1)) and 1))
  this.set_parity(this.chk_parity(U8(result and 0xff)))
  this.set_zero(not(result.toBool()))
  this.set_sign(toBool((result shr (size - 1)) and 1))
  if c == 1:
    this.set_overflow(toBool((v shr (size - 1)) and 1))
