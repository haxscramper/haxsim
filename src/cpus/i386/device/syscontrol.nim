import common
import dev_io
import hardware/memory

type
  SysControl* = object
    portio*: PortIO
    mem*: Memory
  
proc initSysControl*(m: Memory): SysControl =
  result.mem = m

proc in8*(this: var SysControl, memAddr: uint16): uint8 =
  return this.mem.is_ena_a20gate().uint8() shl 1

proc out8*(this: var SysControl, memAddr: uint16, v: uint8): void =
  this.mem.set_a20gate(toBool((v shr 1) and 1))
