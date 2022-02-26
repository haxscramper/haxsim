import
  stdioh
import
  device/comhpp
proc in8*(this: var COM, `addr`: uint16): uint8 = 
  return getchar()

proc out8*(this: var COM, `addr`: uint16, v: uint8): void = 
  putchar(v)
