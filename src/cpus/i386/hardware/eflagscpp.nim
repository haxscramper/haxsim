import hardware/eflagshpp
import commonhpp
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
