import commonhpp
import std/lenientops

## Implementation of the control register and associated logic.

type
  CR_cr0_field1* {.bycopy.} = object
    PE* {.bitsize: 1.}: uint32 ## If 1, system is in protected mode, else system is in real mode
    MP* {.bitsize: 1.}: uint32 ## Controls interaction of WAIT/FWAIT instructions with TS flag in CR0
    EM* {.bitsize: 1.}: uint32 ## If set, no x87 floating-point unit present, if clear, x87 FPU present
    TS* {.bitsize: 1.}: uint32 ## Allows saving x87 task context upon a
                               ## task switch only after x87 instruction
                               ## used
    ET* {.bitsize: 1.}: uint32 ## Allowed to specify whether the
                               ## external math coprocessor was an 80287 or
                               ## 80387
    NE* {.bitsize: 1.}: uint32 ## Enable internal x87 floating point error
                               ## reporting when set, else enables PC style
                               ## x87 error detection
    field6* {.bitsize: 10.}: uint32
    WP* {.bitsize: 1.}: uint32 ## Bit 16, When set, the CPU can't write to
                               ## read-only pages when privilege level is 0
    field8* {.bitsize: 1.}: uint32
    AM* {.bitsize: 1.}: uint32 ## Bit 18, Alignment check enabled if AM
                               ## set, AC flag (in EFLAGS register) set,
                               ## and privilege level is 3
    field10* {.bitsize: 10.}: uint32
    NW* {.bitsize: 1.}: uint32 ## Bit 29, Globally enables/disable
                               ## write-through caching
    CD* {.bitsize: 1.}: uint32 ## Bit 30, Globally enables/disable the
                               ## memory cache
    PG* {.bitsize: 1.}: uint32 ## Bit 31, If 1, enable paging and use the §
                               ## CR3 register, else disable paging.

  CR_cr0* {.union.} = object
    ## CR0 has various control flags that modify the basic operation of the
    ## processor.
    raw*: uint32
    field1*: CR_cr0_field1

  CR_cr1* {.union.} = object
    raw*: uint32

  CR_cr2* {.union.} = object
    raw*: uint32

  CR_cr3_field1* = object
    field0*      {.bitsize: 3.}: uint32
    PWT*         {.bitsize: 1.}: uint32
    PCD*         {.bitsize: 1.}: uint32
    field3*      {.bitsize: 7.}: uint32
    PageDirBase* {.bitsize: 20.}: uint32

  CR_cr3* {.union.} = object
    raw*: uint32
    field1*: CR_cr3_field1

  CR_cr4* {.union.} = object
    ## Used in protected mode to control operations such as virtual-8086
    ## support, enabling I/O breakpoints, page size extension and
    ## machine-check exceptions.
    raw*: uint32
    field1*: CR_cr4_field1

  CR_cr4_field1* = object
    VME*        {.bitsize: 1.}: uint32
    PVI*        {.bitsize: 1.}: uint32
    TSD*        {.bitsize: 1.}: uint32
    DE*         {.bitsize: 1.}: uint32
    PSE*        {.bitsize: 1.}: uint32
    PAE*        {.bitsize: 1.}: uint32
    MCE*        {.bitsize: 1.}: uint32
    PGE*        {.bitsize: 1.}: uint32
    PCE*        {.bitsize: 1.}: uint32
    OSFXSR*     {.bitsize: 1.}: uint32
    OSXMMEXCPT* {.bitsize: 1.}: uint32
    field11*    {.bitsize: 21.}: uint32

  
  CR* {.inheritable.} = ref object
    ## A control register is a processor register which changes or controls
    ## the general behavior of a CPU or other digital device. Common tasks
    ## performed by control registers include interrupt control, switching
    ## the addressing mode, paging control, and coprocessor control.
    cr0*: CR_cr0
    cr1*: CR_cr1
    cr2*: CR_cr2
    cr3*: CR_cr3
    cr4*: CR_cr4
    cr*: array[5, ptr uint32] ## Access ref registers by index

proc get_crn*(this: CR, n: uint8): uint32 =
  if n >= sizeof(this.cr).uint8:
    ERROR("")

  return this.cr[n][]

proc set_crn*(this: CR, n: uint8, v: uint32): void =
  if n >= sizeof(this.cr).uint8:
    ERROR("")

  this.cr[n][] = v

proc initCR*(result: CR) =
  ## Fill control register implementation
  result.cr[0] = addr result.cr0.raw
  result.cr[1] = addr result.cr1.raw
  result.cr[2] = addr result.cr2.raw
  result.cr[3] = addr result.cr3.raw
  result.cr[4] = addr result.cr4.raw
  for i in 0 ..< 5:
    result.set_crn(i.uint8, 0)

proc initCR*(): CR = initCR(result)

proc PE*(this: CR_cr0): uint32 = this.field1.PE
proc `PE=`*(this: var CR_cr0, value: uint32) = this.field1.PE = value
proc MP*(this: CR_cr0): uint32 = this.field1.MP
proc `MP=`*(this: var CR_cr0, value: uint32) = this.field1.MP = value
proc EM*(this: CR_cr0): uint32 = this.field1.EM
proc `EM=`*(this: var CR_cr0, value: uint32) = this.field1.EM = value
proc TS*(this: CR_cr0): uint32 = this.field1.TS
proc `TS=`*(this: var CR_cr0, value: uint32) = this.field1.TS = value
proc ET*(this: CR_cr0): uint32 = this.field1.ET
proc `ET=`*(this: var CR_cr0, value: uint32) = this.field1.ET = value
proc NE*(this: CR_cr0): uint32 = this.field1.NE
proc `NE=`*(this: var CR_cr0, value: uint32) = this.field1.NE = value
proc WP*(this: CR_cr0): uint32 = this.field1.WP
proc `WP=`*(this: var CR_cr0, value: uint32) = this.field1.WP = value
proc AM*(this: CR_cr0): uint32 = this.field1.AM
proc `AM=`*(this: var CR_cr0, value: uint32) = this.field1.AM = value
proc NW*(this: CR_cr0): uint32 = this.field1.NW
proc `NW=`*(this: var CR_cr0, value: uint32) = this.field1.NW = value
proc CD*(this: CR_cr0): uint32 = this.field1.CD
proc `CD=`*(this: var CR_cr0, value: uint32) = this.field1.CD = value
proc PG*(this: CR_cr0): uint32 = this.field1.PG
proc `PG=`*(this: var CR_cr0, value: uint32) = this.field1.PG = value
proc PWT*(this: CR_cr3): uint32 = this.field1.PWT
proc `PWT=`*(this: var CR_cr3, value: uint32) = this.field1.PWT = value
proc PCD*(this: CR_cr3): uint32 = this.field1.PCD
proc `PCD=`*(this: var CR_cr3, value: uint32) = this.field1.PCD = value
proc PageDirBase*(this: CR_cr3): uint32 = this.field1.PageDirBase
proc `PageDirBase=`*(this: var CR_cr3, value: uint32) = this.field1.PageDirBase = value
proc VME*(this: CR_cr4): uint32 = this.field1.VME
proc `VME=`*(this: var CR_cr4, value: uint32) = this.field1.VME = value
proc PVI*(this: CR_cr4): uint32 = this.field1.PVI
proc `PVI=`*(this: var CR_cr4, value: uint32) = this.field1.PVI = value
proc TSD*(this: CR_cr4): uint32 = this.field1.TSD
proc `TSD=`*(this: var CR_cr4, value: uint32) = this.field1.TSD = value
proc DE*(this: CR_cr4): uint32 = this.field1.DE
proc `DE=`*(this: var CR_cr4, value: uint32) = this.field1.DE = value
proc PSE*(this: CR_cr4): uint32 = this.field1.PSE
proc `PSE=`*(this: var CR_cr4, value: uint32) = this.field1.PSE = value
proc PAE*(this: CR_cr4): uint32 = this.field1.PAE
proc `PAE=`*(this: var CR_cr4, value: uint32) = this.field1.PAE = value
proc MCE*(this: CR_cr4): uint32 = this.field1.MCE
proc `MCE=`*(this: var CR_cr4, value: uint32) = this.field1.MCE = value
proc PGE*(this: CR_cr4): uint32 = this.field1.PGE
proc `PGE=`*(this: var CR_cr4, value: uint32) = this.field1.PGE = value
proc PCE*(this: CR_cr4): uint32 = this.field1.PCE
proc `PCE=`*(this: var CR_cr4, value: uint32) = this.field1.PCE = value
proc OSFXSR*(this: CR_cr4): uint32 = this.field1.OSFXSR
proc `OSFXSR=`*(this: var CR_cr4, value: uint32) = this.field1.OSFXSR = value
proc OSXMMEXCPT*(this: CR_cr4): uint32 = this.field1.OSXMMEXCPT
proc `OSXMMEXCPT=`*(this: var CR_cr4, value: uint32) = this.field1.OSXMMEXCPT = value

proc is_protected*(this: CR): bool =
  ## Check if control register flag is set in 'protected' mode.
  return this.cr0.PE.bool

proc is_ena_paging*(this: CR): bool =
  ## Check if paging is enabled
  return this.cr0.PG.bool

proc get_pdir_base*(this: CR): uint32 =
  return this.cr3.PageDirBase
