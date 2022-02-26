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
    Type* {.bitsize: 3.}: uint8
    D* {.bitsize: 1.}: uint8
    S* {.bitsize: 1.}: uint8
    DPL* {.bitsize: 2.}: uint8
    P* {.bitsize: 1.}: uint8
    limit_h* {.bitsize: 4.}: uint8
    AVL* {.bitsize: 1.}: uint8
    field10* {.bitsize: 2.}: uint8
    G* {.bitsize: 1.}: uint8
    base_h*:        uint8


  SegDesc* {.bycopy, importcpp.} = object
    limit_l*:        uint16
    base_l*:        uint16
    base_m*:        uint8
    field3*:        SegDesc_field3
    limit_h* {.bitsize: 4.}: uint8
    AVL* {.bitsize: 1.}: uint8
    field6* {.bitsize: 1.}: uint8
    DB* {.bitsize: 1.}: uint8
    G* {.bitsize: 1.}: uint8
    base_h*:        uint8

  Type* {.bycopy, union.} = object
    data*: data
    code*: code
    field2*: type_field2

  data* {.bycopy.} = object
    field0* {.bitsize: 1.}: uint8
    w* {.bitsize: 1.}: uint8
    exd* {.bitsize: 1.}: uint8
    field3* {.bitsize: 5.}: uint8

  code* {.bycopy.} = object
    field0* {.bitsize: 1.}: uint8
    r* {.bitsize: 1.}: uint8
    cnf* {.bitsize: 1.}: uint8
    field3* {.bitsize: 5.}: uint8

  type_field2* {.bycopy.} = object
    A* {.bitsize: 1.}: uint8
    field1* {.bitsize: 2.}: uint8
    segc* {.bitsize: 1.}: uint8
    field3* {.bitsize: 4.}: uint8

  SegDesc_field3* {.bycopy, union.} = object
    Type*: Type
    field1*: SegDesc_field3_field1

  SegDesc_field3_field1* {.bycopy.} = object
    field0* {.bitsize: 4.}: uint8
    S* {.bitsize: 1.}: uint8
    DPL* {.bitsize: 2.}: uint8
    P* {.bitsize: 1.}: uint8


proc A*(this: Type): uint8 =
  this.field2.A

proc `A =`*(this: var Type, value: uint8) =
  this.field2.A = value

proc segc*(this: Type): uint8 =
  this.field2.segc

proc `segc =`*(this: var Type, value: uint8) =
  this.field2.segc = value

proc S*(this: SegDesc_field3): uint8 =
  this.field1.S

proc `S =`*(this: var SegDesc_field3, value: uint8) =
  this.field1.S = value

proc DPL*(this: SegDesc_field3): uint8 =
  this.field1.DPL

proc `DPL =`*(this: var SegDesc_field3, value: uint8) =
  this.field1.DPL = value

proc P*(this: SegDesc_field3): uint8 =
  this.field1.P

proc `P =`*(this: var SegDesc_field3, value: uint8) =
  this.field1.P = value

proc `Type =`*(this: var SegDesc, value: Type) =
  this.field3.Type = value

proc S*(this: SegDesc): uint8 =
  this.field3.field1.S

proc `S =`*(this: var SegDesc, value: uint8) =
  this.field3.field1.S = value

proc DPL*(this: SegDesc): uint8 =
  this.field3.field1.DPL

proc `DPL =`*(this: var SegDesc, value: uint8) =
  this.field3.field1.DPL = value

proc P*(this: SegDesc): uint8 =
  this.field3.field1.P

proc `P =`*(this: var SegDesc, value: uint8) =
  this.field3.field1.P = value


type
  TSSDesc_field3* {.bycopy, union.} = object
    field0*: TSSDesc_field3_field0
    field1*: TSSDesc_field3_field1

  TSSDesc* {.bycopy, importcpp.} = object
    limit_l*:        uint16
    base_l*:        uint16
    base_m*:        uint8
    field3*:        TSSDesc_field3
    limit_h* {.bitsize: 4.}: uint8
    AVL* {.bitsize: 1.}: uint8
    field6* {.bitsize: 2.}: uint8
    G* {.bitsize: 1.}: uint8
    base_h*:        uint8

  TSSDesc_field3_field0* {.bycopy.} = object
    field0* {.bitsize: 1.}: uint8
    B* {.bitsize: 1.}: uint8

  TSSDesc_field3_field1* {.bycopy.} = object
    Type* {.bitsize: 3.}: uint8
    D* {.bitsize: 1.}: uint8
    S* {.bitsize: 1.}: uint8
    DPL* {.bitsize: 2.}: uint8
    P* {.bitsize: 1.}: uint8



proc B*(this: TSSDesc_field3): uint8 =
  this.field0.B

proc `B =`*(this: var TSSDesc_field3, value: uint8) =
  this.field0.B = value

proc `Type =`*(this: var TSSDesc_field3, value: uint8) =
  this.field1.Type = value

proc D*(this: TSSDesc_field3): uint8 =
  this.field1.D

proc `D =`*(this: var TSSDesc_field3, value: uint8) =
  this.field1.D = value

proc S*(this: TSSDesc_field3): uint8 =
  this.field1.S

proc `S =`*(this: var TSSDesc_field3, value: uint8) =
  this.field1.S = value

proc DPL*(this: TSSDesc_field3): uint8 =
  this.field1.DPL

proc `DPL =`*(this: var TSSDesc_field3, value: uint8) =
  this.field1.DPL = value

proc P*(this: TSSDesc_field3): uint8 =
  this.field1.P

proc `P =`*(this: var TSSDesc_field3, value: uint8) =
  this.field1.P = value

proc B*(this: TSSDesc): uint8 =
  this.field3.field0.B

proc `B =`*(this: var TSSDesc, value: uint8) =
  this.field3.field0.B = value

proc `Type =`*(this: var TSSDesc, value: uint8) =
  this.field3.field1.Type = value

proc D*(this: TSSDesc): uint8 =
  this.field3.field1.D

proc `D =`*(this: var TSSDesc, value: uint8) =
  this.field3.field1.D = value

proc S*(this: TSSDesc): uint8 =
  this.field3.field1.S

proc `S =`*(this: var TSSDesc, value: uint8) =
  this.field3.field1.S = value

proc DPL*(this: TSSDesc): uint8 =
  this.field3.field1.DPL

proc `DPL =`*(this: var TSSDesc, value: uint8) =
  this.field3.field1.DPL = value

proc P*(this: TSSDesc): uint8 =
  this.field3.field1.P

proc `P =`*(this: var TSSDesc, value: uint8) =
  this.field3.field1.P = value

type
  LDTDesc* {.bycopy, importcpp.} = object
    limit_l*:        uint16
    base_l*:        uint16
    base_m*:        uint8
    Type* {.bitsize: 3.}: uint8
    D* {.bitsize: 1.}: uint8
    S* {.bitsize: 1.}: uint8
    DPL* {.bitsize: 2.}: uint8
    P* {.bitsize: 1.}: uint8
    limit_h* {.bitsize: 4.}: uint8
    AVL* {.bitsize: 1.}: uint8
    field10* {.bitsize: 2.}: uint8
    G* {.bitsize: 1.}: uint8
    base_h*:        uint8


type
  CallGateDesc* {.bycopy, importcpp.} = object
    offset_l*:        uint16
    seg_sel*:        uint16
    pc* {.bitsize: 5.}: uint8
    field3* {.bitsize: 3.}: uint8
    Type* {.bitsize: 3.}: uint8
    D* {.bitsize: 1.}: uint8
    S* {.bitsize: 1.}: uint8
    DPL* {.bitsize: 2.}: uint8
    P* {.bitsize: 1.}: uint8
    offset_h*:        uint16

type
  TaskGateDesc* {.bycopy, importcpp.} = object
    field0* {.bitsize: 16.}: uint16
    tss_sel*:        uint16
    field2* {.bitsize: 8.}: uint8
    Type* {.bitsize: 3.}: uint8
    field4* {.bitsize: 1.}: uint8
    S* {.bitsize: 1.}: uint8
    DPL* {.bitsize: 2.}: uint8
    P* {.bitsize: 1.}: uint8
    field8* {.bitsize: 16.}: uint16

type
  IntGateDesc* {.bycopy, importcpp.} = object
    offset_l*:        uint16
    seg_sel*:        uint16
    field2* {.bitsize: 8.}: uint8
    Type* {.bitsize: 3.}: uint8
    D* {.bitsize: 1.}: uint8
    S* {.bitsize: 1.}: uint8
    DPL* {.bitsize: 2.}: uint8
    P* {.bitsize: 1.}: uint8
    offset_h*:        uint16

type
  TrapGateDesc* {.bycopy, importcpp.} = object
    offset_l*:        uint16
    seg_sel*:        uint16
    field2* {.bitsize: 8.}: uint8
    Type* {.bitsize: 3.}: uint8
    D* {.bitsize: 1.}: uint8
    S* {.bitsize: 1.}: uint8
    DPL* {.bitsize: 2.}: uint8
    P* {.bitsize: 1.}: uint8
    offset_h*:        uint16

type
  TSS* {.bycopy, importcpp.} = object
    prev_sel*:        uint16
    field1* {.bitsize: 16.}: uint16
    esp0*:        uint32
    ss0*:        uint16
    field4* {.bitsize: 16.}: uint16
    esp1*:        uint32
    ss1*:        uint16
    field7* {.bitsize: 16.}: uint16
    esp2*:        uint32
    ss2*:        uint16
    field10* {.bitsize: 16.}: uint16
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
    field23* {.bitsize: 16.}: uint16
    cs*:        uint16
    field25* {.bitsize: 16.}: uint16
    ss*:        uint16
    field27* {.bitsize: 16.}: uint16
    ds*:        uint16
    field29* {.bitsize: 16.}: uint16
    fs*:        uint16
    field31* {.bitsize: 16.}: uint16
    gs*:        uint16
    field33* {.bitsize: 16.}: uint16
    ldtr*:        uint16
    field35* {.bitsize: 16.}: uint16
    T* {.bitsize: 1.}: uint16
    field37* {.bitsize: 15.}: uint16
    io_base*:        uint16
