import common
import dev_io
import hardware/memory

type
  SysControl* = ref object
    portio*: PortIO
    mem*: Memory

proc in8*(this: var SysControl, memAddr: uint16): uint8 =
  return this.mem.is_ena_a20gate().uint8() shl 1

proc out8*(this: var SysControl, memAddr: uint16, v: uint8): void =
  this.mem.set_a20gate(toBool((v shr 1) and 1))

proc initSysControl*(m: Memory): SysControl =
  var con = SysControl(mem: m)
  con.portio = wrapPortIO(con, in8, out8)
  return con
