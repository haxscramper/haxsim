import common

type
  EflagsImpl* {.union.} = object
    reg32*: uint32
    reg16*: uint16
    field2*: EflagsImplField2Type
  
  EflagsImplField2Type* = object
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

proc `CF=`*(this: var EflagsImpl, value: uint32) =
  this.field2.CF = value

proc PF*(this: EflagsImpl): uint32 =
  this.field2.PF

proc `PF=`*(this: var EflagsImpl, value: uint32) =
  this.field2.PF = value

proc AF*(this: EflagsImpl): uint32 =
  this.field2.AF

proc `AF=`*(this: var EflagsImpl, value: uint32) =
  this.field2.AF = value

proc ZF*(this: EflagsImpl): uint32 =
  this.field2.ZF

proc `ZF=`*(this: var EflagsImpl, value: uint32) =
  this.field2.ZF = value

proc SF*(this: EflagsImpl): uint32 = this.field2.SF
proc `SF=`*(this: var EflagsImpl, value: uint32) = this.field2.SF = value
proc TF*(this: EflagsImpl): uint32 = this.field2.TF
proc `TF=`*(this: var EflagsImpl, value: uint32) = this.field2.TF = value
proc IF*(this: EflagsImpl): uint32 = this.field2.IF
proc `IF=`*(this: var EflagsImpl, value: uint32) = this.field2.IF = value
proc DF*(this: EflagsImpl): uint32 = this.field2.DF
proc `DF=`*(this: var EflagsImpl, value: uint32) = this.field2.DF = value
proc OF*(this: EflagsImpl): uint32 = this.field2.OF
proc `OF=`*(this: var EflagsImpl, value: uint32) = this.field2.OF = value
proc IOPL*(this: EflagsImpl): uint32 = this.field2.IOPL
proc `IOPL=`*(this: var EflagsImpl, value: uint32) = this.field2.IOPL = value
proc NT*(this: EflagsImpl): uint32 = this.field2.NT
proc `NT=`*(this: var EflagsImpl, value: uint32) = this.field2.NT = value
proc RF*(this: EflagsImpl): uint32 = this.field2.RF
proc `RF=`*(this: var EflagsImpl, value: uint32) = this.field2.RF = value
proc VM*(this: EflagsImpl): uint32 = this.field2.VM
proc `VM=`*(this: var EflagsImpl, value: uint32) = this.field2.VM = value
proc AC*(this: EflagsImpl): uint32 = this.field2.AC
proc `AC=`*(this: var EflagsImpl, value: uint32) = this.field2.AC = value
proc VIF*(this: EflagsImpl): uint32 = this.field2.VIF
proc `VIF=`*(this: var EflagsImpl, value: uint32) = this.field2.VIF = value
proc VIP*(this: EflagsImpl): uint32 = this.field2.VIP
proc `VIP=`*(this: var EflagsImpl, value: uint32) = this.field2.VIP = value
proc ID*(this: EflagsImpl): uint32 = this.field2.ID
proc `ID=`*(this: var EflagsImpl, value: uint32) = this.field2.ID = value

type
  Eflags* = object
    eflags*: EflagsImpl

proc setEflags*(this: var Eflags, v: uint32): void = this.eflags.reg32 = v
proc setFlags*(this: var Eflags, v: uint16): void = this.eflags.reg16 = v

proc getEflags*(this: Eflags): uint32 = return this.eflags.reg32
proc getFlags*(this: Eflags): uint16 = return this.eflags.reg16
proc isCarry*(this: Eflags): bool = return this.eflags.CF.bool
proc isParity*(this: Eflags): bool = return this.eflags.PF.bool
proc isZero*(this: Eflags): bool = return this.eflags.ZF.bool
proc isSign*(this: Eflags): bool = return this.eflags.SF.bool
proc isOverflow*(this: Eflags): bool = return this.eflags.OF.bool
proc isInterrupt*(this: Eflags): bool = return this.eflags.IF.bool
proc isDirection*(this: Eflags): bool = return this.eflags.DF.bool

proc setCarry*(this: var Eflags, carry: bool): void =
  this.eflags.CF = carry.uint32

proc setParity*(this: var Eflags, parity: bool): void =
  this.eflags.PF = parity.uint32

proc setZero*(this: var Eflags, zero: bool): void =
  this.eflags.ZF = zero.uint32

proc setSign*(this: var Eflags, sign: bool): void =
  this.eflags.SF = sign.uint32

proc setOverflow*(this: var Eflags, over: bool): void =
  this.eflags.OF = over.uint32

proc setInterrupt*(this: var Eflags, interrupt: bool): void =
  this.eflags.IF = interrupt.uint32

proc setDirection*(this: var Eflags, dir: bool): void =
  this.eflags.DF = dir.uint32

import common
import std/[lenientops, bitops]

proc chk_parity*(this: var Eflags, v: uint8): bool =
  var p: bool = true
  for i in 0 ..< 8:
    p = (p xor toBool((v shr i) and 1))
  return p


proc updateAdd*[T](this: var Eflags, v1: T, v2: uint32) =
  var sr, s1, s2: bool
  var result: uint64
  var size: uint8
  var v2 = v2
  v2 = cast[T](v2)
  result = cast[uint64](v1) + v2
  size = sizeof(T) * 8
  s1 = toBool(v1 shr (size - 1))
  s2 = toBool(v2 shr (size - 1))
  sr = toBool((result shr (size - 1)) and 1)
  this.set_carry(toBool(result shr size))
  this.set_parity(this.chk_parity(uint8(result and 0xff)))
  this.set_zero(not(result.toBool()))
  this.set_sign(sr)
  this.set_overflow(not((s1 xor s2)) and s1 xor sr)




proc updateOr*[T](this: var Eflags, v1: T, v2: uint32) =
  var result: T
  var size: uint8
  var v2 = v2
  v2 = cast[T](v2)
  result = T(v1) or T(v2)
  size = sizeof(T) * 8
  this.set_carry(false)
  this.set_parity(this.chk_parity(uint8(result and 0xff)))
  this.set_zero(not(result.toBool()))
  this.set_sign(toBool((result shr (size - 1)) and 1))
  this.set_overflow(false)




proc updateAnd*[T](this: var Eflags, v1: T, v2: uint32) =
  var result: T
  var size: uint8
  var v2 = v2
  v2 = cast[T](v2)
  result = T(v1) and T(v2)
  size = sizeof(T) * 8
  this.set_carry(false)
  this.set_parity(this.chk_parity(uint8(result and 0xff)))
  this.set_zero(not(result.toBool()))
  this.set_sign(toBool((result shr (size - 1)) and 1))
  this.set_overflow(false)




proc updateSub*[T](this: var Eflags, v1: T, v2: uint32) =
  var sr, s1, s2: bool
  var result: uint64
  var size: uint8
  var v2 = v2
  v2 = cast[T](v2)
  result = cast[uint64](v1) - v2
  size = sizeof(T) * 8
  s1 = toBool(v1 shr (size - 1))
  s2 = toBool(v2 shr (size - 1))
  sr = toBool((result shr (size - 1)) and 1)
  this.set_carry(toBool(result shr size))
  this.set_parity(this.chk_parity(uint8(result and 0xff)))
  this.set_zero(not(result.toBool()))
  this.set_sign(sr)
  this.set_overflow(s1 xor s2 and s1 xor sr)




proc updateMul*[T](this: var Eflags, v1: T, v2: uint32) =
  var result: uint64
  var size: uint8
  var v2 = cast[T](v2)
  result = cast[uint64](v1) * v2
  size = sizeof(T) * 8
  this.set_carry(toBool(result shr size))
  this.set_overflow(toBool(result shr size))




proc updateImul*[T](this: var Eflags, v1: T, v2: int32) =
  var result: int64
  var size: uint8
  let v2 = cast[T](v2)
  result = cast[int64](v1) * v2
  size = sizeof(T) * 8
  this.set_carry((result shr size) != -1)
  this.set_overflow((result shr size) != -1)




proc updateShl*[T](this: var Eflags, v: T, c: uint8) =
  var result: T
  var size: uint8
  result = v shl c
  size = sizeof(T) * 8
  this.set_carry(toBool((v shr (size - c)) and 1))
  this.set_parity(this.chk_parity(uint8(result and 0xff)))
  this.set_zero(not(result.toBool()))
  this.set_sign(toBool(result shr (size - 1) and 1))
  if c == 1:
    this.set_overflow(toBool(
      ((v shr (size - 1)) and 1) xor
      ((v shr (size - 2)) and 1)))




proc updateShr*[T](this: var Eflags, v: T, c: uint8) =
  var result: T
  var size: uint8
  result = v shr c
  size = sizeof(T) * 8
  this.set_carry(toBool((v shr (c - 1)) and 1))
  this.set_parity(this.chk_parity(uint8(result and 0xff)))
  this.set_zero(not(result.toBool()))
  this.set_sign(toBool((result shr (size - 1)) and 1))
  if c == 1:
    this.set_overflow(toBool((v shr (size - 1)) and 1))
