import
  hardware/eflagshpp



proc update_eflags_add*[T](this: var Eflags, v1: T, v2: uint32): uint32 = 
  var sr: bool
  var result: uint64
  var size: uint8
  v2 = cast[T](v2)
  result = cast[uint64](v1) + v2
  size = sizeof((T) * 8)
  s1 = v1 shr (size - 1)
  s2 = v2 shr (size - 1)
  sr = (result shr (size - 1)) and 1
  set_carry(result shr size)
  set_parity(chk_parity(result and 0xff))
  set_zero(not(result))
  set_sign(sr)
  set_overflow(not((s1 xor s2)) and s1 xor sr)
  return eflags.reg32




proc update_eflags_or*[T](this: var Eflags, v1: T, v2: uint32): uint32 = 
  var result: T
  var size: uint8
  v2 = cast[T](v2)
  result = v1 or v2
  size = sizeof((T) * 8)
  set_carry(0)
  set_parity(chk_parity(result and 0xff))
  set_zero(not(result))
  set_sign((result shr (size - 1)) and 1)
  set_overflow(0)
  return eflags.reg32




proc update_eflags_and*[T](this: var Eflags, v1: T, v2: uint32): uint32 = 
  var result: T
  var size: uint8
  v2 = cast[T](v2)
  result = v1 and v2
  size = sizeof((T) * 8)
  set_carry(0)
  set_parity(chk_parity(result and 0xff))
  set_zero(not(result))
  set_sign((result shr (size - 1)) and 1)
  set_overflow(0)
  return eflags.reg32




proc update_eflags_sub*[T](this: var Eflags, v1: T, v2: uint32): uint32 = 
  var sr: bool
  var result: uint64
  var size: uint8
  v2 = cast[T](v2)
  result = cast[uint64](v1) - v2
  size = sizeof((T) * 8)
  s1 = v1 shr (size - 1)
  s2 = v2 shr (size - 1)
  sr = (result shr (size - 1)) and 1
  set_carry(result shr size)
  set_parity(chk_parity(result and 0xff))
  set_zero(not(result))
  set_sign(sr)
  set_overflow(s1 xor s2 and s1 xor sr)
  return eflags.reg32




proc update_eflags_mul*[T](this: var Eflags, v1: T, v2: uint32): uint32 = 
  var result: uint64
  var size: uint8
  v2 = cast[T](v2)
  result = cast[uint64](v1) * v2
  size = sizeof((T) * 8)
  set_carry(result shr size)
  set_overflow(result shr size)
  return eflags.reg32




proc update_eflags_imul*[T](this: var Eflags, v1: T, v2: int32): uint32 = 
  var result: int64
  var size: uint8
  v2 = cast[T](v2)
  result = cast[int64](v1) * v2
  size = sizeof((T) * 8)
  set_carry((result shr size) != -1)
  set_overflow((result shr size) != -1)
  return eflags.reg32




proc update_eflags_shl*[T](this: var Eflags, v: T, c: uint8): uint32 = 
  var result: T
  var size: uint8
  result = v shl c
  size = sizeof((T) * 8)
  set_carry((v shr (size - c)) and 1)
  set_parity(chk_parity(result and 0xff))
  set_zero(not(result))
  set_sign((result shr (size - 1)) and 1)
  if c == 1:
    set_overflow(((v shr (size - 1)) and 1) xor ((v shr (size - 2)) and 1))
  
  return eflags.reg32




proc update_eflags_shr*[T](this: var Eflags, v: T, c: uint8): uint32 = 
  var result: T
  var size: uint8
  result = v shr c
  size = sizeof((T) * 8)
  set_carry((v shr (c - 1)) and 1)
  set_parity(chk_parity(result and 0xff))
  set_zero(not(result))
  set_sign((result shr (size - 1)) and 1)
  if c == 1:
    set_overflow((v shr (size - 1)) and 1)
  
  return eflags.reg32

proc chk_parity*(this: var Eflags, v: uint8): bool = 
  var p: bool = true
  for i in 0 ..< 8:
    p = (p xor (v shr i) and 1)
  return p
