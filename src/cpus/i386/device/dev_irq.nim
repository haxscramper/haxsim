type
  IRQ* {.inheritable.} = ref object
    ## Interrupt request - base object for devices that can create hardware
    ## interrupts. Keyboard, mouse, FDD, PIT.
    intr*: bool ## Whether interrupt must be sent from device to the CPU
  
proc initIRQ*(): IRQ = 
  result.intr = false

proc chk_intreq*(this: IRQ): bool =
  ## Check for interrupt presence. If interrupt exists, reset it to
  ## `false`.
  if this.intr:
    this.intr = false
    return true
  
  return false
