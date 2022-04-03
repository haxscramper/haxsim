import common
import dev_io
type
  COM* = object
    portio*: PortIO

proc in8*(this: var COM, memAddr: uint16): uint8 =
  assert false
  # return getchar()

proc out8*(this: var COM, memAddr: uint16, v: uint8): void =
  assert false
  # putchar(v)
