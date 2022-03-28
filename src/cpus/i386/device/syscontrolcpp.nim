import
  device/syscontrolhpp
proc in8*(this: var SysControl, memAddr: uint16): uint8 =
  return mem.is_ena_a20gate() shl 1

proc out8*(this: var SysControl, memAddr: uint16, v: uint8): void =
  mem.set_a20gate((v shr 1) and 1)
  INFO(2, "set A20 gate : %d", mem.is_ena_a20gate())
