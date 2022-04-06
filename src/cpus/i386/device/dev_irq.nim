type
  IRQ* {.inheritable.} = ref object
    intr*: bool
  
proc initIRQ*(): IRQ = 
  result.intr = false

proc chk_intreq*(this: IRQ): bool =
  if this.intr:
    this.intr = false
    return true
  
  return false
