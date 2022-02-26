import
  commonhpp
type
  IRQ* {.bycopy, importcpp.} = object
    intr*: bool
  
proc initIRQ*(): IRQ = 
  intr = false

proc chk_intreq*(this: var IRQ): bool = 
  if intr:
    intr = false
    return true
  
  return false
