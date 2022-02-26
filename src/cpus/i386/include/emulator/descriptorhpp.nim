const TYPE_TSS* = 0x01
const TYPE_LDT* = 0x02
const TYPE_CALL* = 0x04
const TYPE_TASK* = 0x05
const TYPE_INTERRUPT* = 0x06
const TYPE_TRAP* = 0x07
const TYPE_DATA* = 0x10
const TYPE_CODE* = 0x18
type
  Descriptor* {.bycopy, importcpp.} = object
    limit_l*:        uint16
    base_l*:        uint16
    base_m*:        uint8
    type* {.bitsize: 3.}: uint8
    D* {.bitsize: 1.}: uint8
    S* {.bitsize: 1.}: uint8
    DPL* {.bitsize: 2.}: uint8
    P* {.bitsize: 1.}: uint8
    limit_h* {.bitsize: 4.}: uint8
    AVL* {.bitsize: 1.}: uint8
    * {.bitsize: 2.}: uint8
    G* {.bitsize: 1.}: uint8
    base_h*:        uint8
  

type
  SegDesc* {.bycopy, importcpp.} = object
    limit_l*:        uint16
    base_l*:        uint16
    base_m*:        uint8
    field3*:        SegDesc_field3_Type
    limit_h* {.bitsize: 4.}: uint8
    AVL* {.bitsize: 1.}: uint8
    * {.bitsize: 1.}: uint8
    DB* {.bitsize: 1.}: uint8
    G* {.bitsize: 1.}: uint8
    base_h*:        uint8
  
type
  data_Type* {.bycopy.} = object
    * {.bitsize: 1.}: uint8
    w* {.bitsize: 1.}: uint8
    exd* {.bitsize: 1.}: uint8
    * {.bitsize: 5.}: uint8
  
type
  code_Type* {.bycopy.} = object
    * {.bitsize: 1.}: uint8
    r* {.bitsize: 1.}: uint8
    cnf* {.bitsize: 1.}: uint8
    * {.bitsize: 5.}: uint8
  
type
  field2_Type* {.bycopy.} = object
    A* {.bitsize: 1.}: uint8
    * {.bitsize: 2.}: uint8
    segc* {.bitsize: 1.}: uint8
    * {.bitsize: 4.}: uint8
  
proc A*(this: type_Type): uint8 = 
  this.field2.A

proc `A =`*(this: var type_Type): uint8 = 
  this.field2.A

proc *(this: type_Type): uint8 = 
  this.field2.

proc ` =`*(this: var type_Type): uint8 = 
  this.field2.

proc segc*(this: type_Type): uint8 = 
  this.field2.segc

proc `segc =`*(this: var type_Type): uint8 = 
  this.field2.segc

proc *(this: type_Type): uint8 = 
  this.field2.

proc ` =`*(this: var type_Type): uint8 = 
  this.field2.

type
  type_Type* {.bycopy, union.} = object
    data*: data_Type
    code*: code_Type
    field2*: field2_Type
  
type
  field1_Type* {.bycopy.} = object
    * {.bitsize: 4.}: uint8
    S* {.bitsize: 1.}: uint8
    DPL* {.bitsize: 2.}: uint8
    P* {.bitsize: 1.}: uint8
  
proc *(this: SegDesc_field3_Type): uint8 = 
  this.field1.

proc ` =`*(this: var SegDesc_field3_Type): uint8 = 
  this.field1.

proc S*(this: SegDesc_field3_Type): uint8 = 
  this.field1.S

proc `S =`*(this: var SegDesc_field3_Type): uint8 = 
  this.field1.S

proc DPL*(this: SegDesc_field3_Type): uint8 = 
  this.field1.DPL

proc `DPL =`*(this: var SegDesc_field3_Type): uint8 = 
  this.field1.DPL

proc P*(this: SegDesc_field3_Type): uint8 = 
  this.field1.P

proc `P =`*(this: var SegDesc_field3_Type): uint8 = 
  this.field1.P

type
  SegDesc_field3_Type* {.bycopy, union.} = object
    type*: type_Type
    field1*: field1_Type
  
type
  data_Type* {.bycopy.} = object
    * {.bitsize: 1.}: uint8
    w* {.bitsize: 1.}: uint8
    exd* {.bitsize: 1.}: uint8
    * {.bitsize: 5.}: uint8
  
type
  code_Type* {.bycopy.} = object
    * {.bitsize: 1.}: uint8
    r* {.bitsize: 1.}: uint8
    cnf* {.bitsize: 1.}: uint8
    * {.bitsize: 5.}: uint8
  
type
  field2_Type* {.bycopy.} = object
    A* {.bitsize: 1.}: uint8
    * {.bitsize: 2.}: uint8
    segc* {.bitsize: 1.}: uint8
    * {.bitsize: 4.}: uint8
  
proc A*(this: type_Type): uint8 = 
  this.field2.A

proc `A =`*(this: var type_Type): uint8 = 
  this.field2.A

proc *(this: type_Type): uint8 = 
  this.field2.

proc ` =`*(this: var type_Type): uint8 = 
  this.field2.

proc segc*(this: type_Type): uint8 = 
  this.field2.segc

proc `segc =`*(this: var type_Type): uint8 = 
  this.field2.segc

proc *(this: type_Type): uint8 = 
  this.field2.

proc ` =`*(this: var type_Type): uint8 = 
  this.field2.

type
  type_Type* {.bycopy, union.} = object
    data*: data_Type
    code*: code_Type
    field2*: field2_Type
  
proc `type`*(this: SegDesc): type_Type = 
  this.field3.`type`

type
  data_Type* {.bycopy.} = object
    * {.bitsize: 1.}: uint8
    w* {.bitsize: 1.}: uint8
    exd* {.bitsize: 1.}: uint8
    * {.bitsize: 5.}: uint8
  
type
  code_Type* {.bycopy.} = object
    * {.bitsize: 1.}: uint8
    r* {.bitsize: 1.}: uint8
    cnf* {.bitsize: 1.}: uint8
    * {.bitsize: 5.}: uint8
  
type
  field2_Type* {.bycopy.} = object
    A* {.bitsize: 1.}: uint8
    * {.bitsize: 2.}: uint8
    segc* {.bitsize: 1.}: uint8
    * {.bitsize: 4.}: uint8
  
proc A*(this: type_Type): uint8 = 
  this.field2.A

proc `A =`*(this: var type_Type): uint8 = 
  this.field2.A

proc *(this: type_Type): uint8 = 
  this.field2.

proc ` =`*(this: var type_Type): uint8 = 
  this.field2.

proc segc*(this: type_Type): uint8 = 
  this.field2.segc

proc `segc =`*(this: var type_Type): uint8 = 
  this.field2.segc

proc *(this: type_Type): uint8 = 
  this.field2.

proc ` =`*(this: var type_Type): uint8 = 
  this.field2.

type
  type_Type* {.bycopy, union.} = object
    data*: data_Type
    code*: code_Type
    field2*: field2_Type
  
proc ``type` =`*(this: var SegDesc): type_Type = 
  this.field3.`type`

proc *(this: SegDesc): uint8 = 
  this.field3.field1.

proc ` =`*(this: var SegDesc): uint8 = 
  this.field3.field1.

proc S*(this: SegDesc): uint8 = 
  this.field3.field1.S

proc `S =`*(this: var SegDesc): uint8 = 
  this.field3.field1.S

proc DPL*(this: SegDesc): uint8 = 
  this.field3.field1.DPL

proc `DPL =`*(this: var SegDesc): uint8 = 
  this.field3.field1.DPL

proc P*(this: SegDesc): uint8 = 
  this.field3.field1.P

proc `P =`*(this: var SegDesc): uint8 = 
  this.field3.field1.P


type
  TSSDesc* {.bycopy, importcpp.} = object
    limit_l*:        uint16
    base_l*:        uint16
    base_m*:        uint8
    field3*:        TSSDesc_field3_Type
    limit_h* {.bitsize: 4.}: uint8
    AVL* {.bitsize: 1.}: uint8
    * {.bitsize: 2.}: uint8
    G* {.bitsize: 1.}: uint8
    base_h*:        uint8
  
type
  field0_Type* {.bycopy.} = object
    * {.bitsize: 1.}: uint8
    B* {.bitsize: 1.}: uint8
  
proc *(this: TSSDesc_field3_Type): uint8 = 
  this.field0.

proc ` =`*(this: var TSSDesc_field3_Type): uint8 = 
  this.field0.

proc B*(this: TSSDesc_field3_Type): uint8 = 
  this.field0.B

proc `B =`*(this: var TSSDesc_field3_Type): uint8 = 
  this.field0.B

type
  field1_Type* {.bycopy.} = object
    type* {.bitsize: 3.}: uint8
    D* {.bitsize: 1.}: uint8
    S* {.bitsize: 1.}: uint8
    DPL* {.bitsize: 2.}: uint8
    P* {.bitsize: 1.}: uint8
  
proc `type`*(this: TSSDesc_field3_Type): uint8 = 
  this.field1.`type`

proc ``type` =`*(this: var TSSDesc_field3_Type): uint8 = 
  this.field1.`type`

proc D*(this: TSSDesc_field3_Type): uint8 = 
  this.field1.D

proc `D =`*(this: var TSSDesc_field3_Type): uint8 = 
  this.field1.D

proc S*(this: TSSDesc_field3_Type): uint8 = 
  this.field1.S

proc `S =`*(this: var TSSDesc_field3_Type): uint8 = 
  this.field1.S

proc DPL*(this: TSSDesc_field3_Type): uint8 = 
  this.field1.DPL

proc `DPL =`*(this: var TSSDesc_field3_Type): uint8 = 
  this.field1.DPL

proc P*(this: TSSDesc_field3_Type): uint8 = 
  this.field1.P

proc `P =`*(this: var TSSDesc_field3_Type): uint8 = 
  this.field1.P

type
  TSSDesc_field3_Type* {.bycopy, union.} = object
    field0*: field0_Type
    field1*: field1_Type
  
proc *(this: TSSDesc): uint8 = 
  this.field3.field0.

proc ` =`*(this: var TSSDesc): uint8 = 
  this.field3.field0.

proc B*(this: TSSDesc): uint8 = 
  this.field3.field0.B

proc `B =`*(this: var TSSDesc): uint8 = 
  this.field3.field0.B

proc `type`*(this: TSSDesc): uint8 = 
  this.field3.field1.`type`

proc ``type` =`*(this: var TSSDesc): uint8 = 
  this.field3.field1.`type`

proc D*(this: TSSDesc): uint8 = 
  this.field3.field1.D

proc `D =`*(this: var TSSDesc): uint8 = 
  this.field3.field1.D

proc S*(this: TSSDesc): uint8 = 
  this.field3.field1.S

proc `S =`*(this: var TSSDesc): uint8 = 
  this.field3.field1.S

proc DPL*(this: TSSDesc): uint8 = 
  this.field3.field1.DPL

proc `DPL =`*(this: var TSSDesc): uint8 = 
  this.field3.field1.DPL

proc P*(this: TSSDesc): uint8 = 
  this.field3.field1.P

proc `P =`*(this: var TSSDesc): uint8 = 
  this.field3.field1.P

type
  LDTDesc* {.bycopy, importcpp.} = object
    limit_l*:        uint16
    base_l*:        uint16
    base_m*:        uint8
    type* {.bitsize: 3.}: uint8
    D* {.bitsize: 1.}: uint8
    S* {.bitsize: 1.}: uint8
    DPL* {.bitsize: 2.}: uint8
    P* {.bitsize: 1.}: uint8
    limit_h* {.bitsize: 4.}: uint8
    AVL* {.bitsize: 1.}: uint8
    * {.bitsize: 2.}: uint8
    G* {.bitsize: 1.}: uint8
    base_h*:        uint8
  

type
  CallGateDesc* {.bycopy, importcpp.} = object
    offset_l*:        uint16
    seg_sel*:        uint16
    pc* {.bitsize: 5.}: uint8
    * {.bitsize: 3.}: uint8
    type* {.bitsize: 3.}: uint8
    D* {.bitsize: 1.}: uint8
    S* {.bitsize: 1.}: uint8
    DPL* {.bitsize: 2.}: uint8
    P* {.bitsize: 1.}: uint8
    offset_h*:        uint16
  
type
  TaskGateDesc* {.bycopy, importcpp.} = object
    * {.bitsize: 16.}: uint16
    tss_sel*:        uint16
    * {.bitsize: 8.}: uint8
    type* {.bitsize: 3.}: uint8
    * {.bitsize: 1.}: uint8
    S* {.bitsize: 1.}: uint8
    DPL* {.bitsize: 2.}: uint8
    P* {.bitsize: 1.}: uint8
    * {.bitsize: 16.}: uint16
  
type
  IntGateDesc* {.bycopy, importcpp.} = object
    offset_l*:        uint16
    seg_sel*:        uint16
    * {.bitsize: 8.}: uint8
    type* {.bitsize: 3.}: uint8
    D* {.bitsize: 1.}: uint8
    S* {.bitsize: 1.}: uint8
    DPL* {.bitsize: 2.}: uint8
    P* {.bitsize: 1.}: uint8
    offset_h*:        uint16
  
type
  TrapGateDesc* {.bycopy, importcpp.} = object
    offset_l*:        uint16
    seg_sel*:        uint16
    * {.bitsize: 8.}: uint8
    type* {.bitsize: 3.}: uint8
    D* {.bitsize: 1.}: uint8
    S* {.bitsize: 1.}: uint8
    DPL* {.bitsize: 2.}: uint8
    P* {.bitsize: 1.}: uint8
    offset_h*:        uint16
  
type
  TSS* {.bycopy, importcpp.} = object
    prev_sel*:        uint16
    * {.bitsize: 16.}: uint16
    esp0*:        uint32
    ss0*:        uint16
    * {.bitsize: 16.}: uint16
    esp1*:        uint32
    ss1*:        uint16
    * {.bitsize: 16.}: uint16
    esp2*:        uint32
    ss2*:        uint16
    * {.bitsize: 16.}: uint16
    cr3*:        uint32
    eip*:        uint32
    eflags*:        uint32
    eax*:        uint32
    ecx*:        uint32
    edx*:        uint32
    ebx*:        uint32
    esp*:        uint32
    ebp*:        uint32
    esi*:        uint32
    edi*:        uint32
    es*:        uint16
    * {.bitsize: 16.}: uint16
    cs*:        uint16
    * {.bitsize: 16.}: uint16
    ss*:        uint16
    * {.bitsize: 16.}: uint16
    ds*:        uint16
    * {.bitsize: 16.}: uint16
    fs*:        uint16
    * {.bitsize: 16.}: uint16
    gs*:        uint16
    * {.bitsize: 16.}: uint16
    ldtr*:        uint16
    * {.bitsize: 16.}: uint16
    T* {.bitsize: 1.}: uint16
    * {.bitsize: 15.}: uint16
    io_base*:        uint16
  