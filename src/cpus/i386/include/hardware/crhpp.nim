import
  commonhpp
type
  CR* {.bycopy, importcpp.} = object
    cr0*: CR_cr0_Type        
    cr1*: CR_cr1_Type        
    cr2*: CR_cr2_Type        
    cr3*: CR_cr3_Type        
    cr4*: CR_cr4_Type        
    cr*: array[5, ptr uint32]
  
proc initCR*(): CR = 
  cr[0] = addr cr0.raw
  cr[1] = addr cr1.raw
  cr[2] = addr cr2.raw
  cr[3] = addr cr3.raw
  cr[4] = addr cr4.raw
  for i in 0 ..< 5:
    set_crn(i, 0)

proc get_crn*(this: var CR, n: uint8): uint32 = 
  if n >= sizeof((cr)):
    ERROR("")
  
  return cr[n][]

proc set_crn*(this: var CR, n: uint8, v: uint32): void = 
  if n >= sizeof((cr)):
    ERROR("")
  
  cr[n][] = v

proc is_protected*(this: var CR): bool = 
  return cr0.PE

proc is_ena_paging*(this: var CR): bool = 
  return cr0.PG

proc get_pdir_base*(this: var CR): uint32 = 
  return cr3.PageDirBase

type
  field1_Type* {.bycopy.} = object
    PE* {.bitsize: 1.}: uint32
    MP* {.bitsize: 1.}: uint32
    EM* {.bitsize: 1.}: uint32
    TS* {.bitsize: 1.}: uint32
    ET* {.bitsize: 1.}: uint32
    NE* {.bitsize: 1.}: uint32
    * {.bitsize: 10.}: uint32
    WP* {.bitsize: 1.}: uint32
    * {.bitsize: 1.}: uint32
    AM* {.bitsize: 1.}: uint32
    * {.bitsize: 10.}: uint32
    NW* {.bitsize: 1.}: uint32
    CD* {.bitsize: 1.}: uint32
    PG* {.bitsize: 1.}: uint32
  
proc PE*(this: CR_cr0_Type): uint32 = 
  this.field1.PE

proc `PE =`*(this: var CR_cr0_Type): uint32 = 
  this.field1.PE

proc MP*(this: CR_cr0_Type): uint32 = 
  this.field1.MP

proc `MP =`*(this: var CR_cr0_Type): uint32 = 
  this.field1.MP

proc EM*(this: CR_cr0_Type): uint32 = 
  this.field1.EM

proc `EM =`*(this: var CR_cr0_Type): uint32 = 
  this.field1.EM

proc TS*(this: CR_cr0_Type): uint32 = 
  this.field1.TS

proc `TS =`*(this: var CR_cr0_Type): uint32 = 
  this.field1.TS

proc ET*(this: CR_cr0_Type): uint32 = 
  this.field1.ET

proc `ET =`*(this: var CR_cr0_Type): uint32 = 
  this.field1.ET

proc NE*(this: CR_cr0_Type): uint32 = 
  this.field1.NE

proc `NE =`*(this: var CR_cr0_Type): uint32 = 
  this.field1.NE

proc *(this: CR_cr0_Type): uint32 = 
  this.field1.

proc ` =`*(this: var CR_cr0_Type): uint32 = 
  this.field1.

proc WP*(this: CR_cr0_Type): uint32 = 
  this.field1.WP

proc `WP =`*(this: var CR_cr0_Type): uint32 = 
  this.field1.WP

proc *(this: CR_cr0_Type): uint32 = 
  this.field1.

proc ` =`*(this: var CR_cr0_Type): uint32 = 
  this.field1.

proc AM*(this: CR_cr0_Type): uint32 = 
  this.field1.AM

proc `AM =`*(this: var CR_cr0_Type): uint32 = 
  this.field1.AM

proc *(this: CR_cr0_Type): uint32 = 
  this.field1.

proc ` =`*(this: var CR_cr0_Type): uint32 = 
  this.field1.

proc NW*(this: CR_cr0_Type): uint32 = 
  this.field1.NW

proc `NW =`*(this: var CR_cr0_Type): uint32 = 
  this.field1.NW

proc CD*(this: CR_cr0_Type): uint32 = 
  this.field1.CD

proc `CD =`*(this: var CR_cr0_Type): uint32 = 
  this.field1.CD

proc PG*(this: CR_cr0_Type): uint32 = 
  this.field1.PG

proc `PG =`*(this: var CR_cr0_Type): uint32 = 
  this.field1.PG

type
  CR_cr0_Type* {.bycopy, union.} = object
    raw*: uint32
    field1*: field1_Type
  
type
  CR_cr1_Type* {.bycopy, union.} = object
    raw*: uint32
  
type
  CR_cr2_Type* {.bycopy, union.} = object
    raw*: uint32
  
type
  field1_Type* {.bycopy.} = object
    * {.bitsize: 3.}: uint32
    PWT* {.bitsize: 1.}: uint32
    PCD* {.bitsize: 1.}: uint32
    * {.bitsize: 7.}: uint32
    PageDirBase* {.bitsize: 20.}: uint32
  
proc *(this: CR_cr3_Type): uint32 = 
  this.field1.

proc ` =`*(this: var CR_cr3_Type): uint32 = 
  this.field1.

proc PWT*(this: CR_cr3_Type): uint32 = 
  this.field1.PWT

proc `PWT =`*(this: var CR_cr3_Type): uint32 = 
  this.field1.PWT

proc PCD*(this: CR_cr3_Type): uint32 = 
  this.field1.PCD

proc `PCD =`*(this: var CR_cr3_Type): uint32 = 
  this.field1.PCD

proc *(this: CR_cr3_Type): uint32 = 
  this.field1.

proc ` =`*(this: var CR_cr3_Type): uint32 = 
  this.field1.

proc PageDirBase*(this: CR_cr3_Type): uint32 = 
  this.field1.PageDirBase

proc `PageDirBase =`*(this: var CR_cr3_Type): uint32 = 
  this.field1.PageDirBase

type
  CR_cr3_Type* {.bycopy, union.} = object
    raw*: uint32
    field1*: field1_Type
  
type
  field1_Type* {.bycopy.} = object
    VME* {.bitsize: 1.}: uint32
    PVI* {.bitsize: 1.}: uint32
    TSD* {.bitsize: 1.}: uint32
    DE* {.bitsize: 1.}: uint32
    PSE* {.bitsize: 1.}: uint32
    PAE* {.bitsize: 1.}: uint32
    MCE* {.bitsize: 1.}: uint32
    PGE* {.bitsize: 1.}: uint32
    PCE* {.bitsize: 1.}: uint32
    OSFXSR* {.bitsize: 1.}: uint32
    OSXMMEXCPT* {.bitsize: 1.}: uint32
    * {.bitsize: 21.}: uint32
  
proc VME*(this: CR_cr4_Type): uint32 = 
  this.field1.VME

proc `VME =`*(this: var CR_cr4_Type): uint32 = 
  this.field1.VME

proc PVI*(this: CR_cr4_Type): uint32 = 
  this.field1.PVI

proc `PVI =`*(this: var CR_cr4_Type): uint32 = 
  this.field1.PVI

proc TSD*(this: CR_cr4_Type): uint32 = 
  this.field1.TSD

proc `TSD =`*(this: var CR_cr4_Type): uint32 = 
  this.field1.TSD

proc DE*(this: CR_cr4_Type): uint32 = 
  this.field1.DE

proc `DE =`*(this: var CR_cr4_Type): uint32 = 
  this.field1.DE

proc PSE*(this: CR_cr4_Type): uint32 = 
  this.field1.PSE

proc `PSE =`*(this: var CR_cr4_Type): uint32 = 
  this.field1.PSE

proc PAE*(this: CR_cr4_Type): uint32 = 
  this.field1.PAE

proc `PAE =`*(this: var CR_cr4_Type): uint32 = 
  this.field1.PAE

proc MCE*(this: CR_cr4_Type): uint32 = 
  this.field1.MCE

proc `MCE =`*(this: var CR_cr4_Type): uint32 = 
  this.field1.MCE

proc PGE*(this: CR_cr4_Type): uint32 = 
  this.field1.PGE

proc `PGE =`*(this: var CR_cr4_Type): uint32 = 
  this.field1.PGE

proc PCE*(this: CR_cr4_Type): uint32 = 
  this.field1.PCE

proc `PCE =`*(this: var CR_cr4_Type): uint32 = 
  this.field1.PCE

proc OSFXSR*(this: CR_cr4_Type): uint32 = 
  this.field1.OSFXSR

proc `OSFXSR =`*(this: var CR_cr4_Type): uint32 = 
  this.field1.OSFXSR

proc OSXMMEXCPT*(this: CR_cr4_Type): uint32 = 
  this.field1.OSXMMEXCPT

proc `OSXMMEXCPT =`*(this: var CR_cr4_Type): uint32 = 
  this.field1.OSXMMEXCPT

proc *(this: CR_cr4_Type): uint32 = 
  this.field1.

proc ` =`*(this: var CR_cr4_Type): uint32 = 
  this.field1.

type
  CR_cr4_Type* {.bycopy, union.} = object
    raw*: uint32
    field1*: field1_Type
  