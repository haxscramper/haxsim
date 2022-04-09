import
  commonh
type
  IVT* = object
    offset*: uint16
    segment*: uint16
  
proc init_ivt*(): void = 
  discard 

proc set_ivt*(n: cint, offset: uint32, cs: uint16): void = 
  discard 
