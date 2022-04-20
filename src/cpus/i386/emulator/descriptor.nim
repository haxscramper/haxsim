import common

const
  TYPE_TSS* = 0x01
  TYPE_LDT* = 0x02
  TYPE_CALL* = 0x04
  TYPE_TASK* = 0x05
  TYPE_INTERRUPT* = 0x06
  TYPE_TRAP* = 0x07
  TYPE_DATA* = 0x10
  TYPE_CODE* = 0x18

type
  Descriptor* = object
    limit_l*:           U16
    base_l*:            U16
    base_m*:            U8
    Type*    {.bitsize: 3.}: U8
    D*       {.bitsize: 1.}: U8
    S*       {.bitsize: 1.}: U8
    DPL*     {.bitsize: 2.}: U8
    P*       {.bitsize: 1.}: U8
    limit_h* {.bitsize: 4.}: U8
    AVL*     {.bitsize: 1.}: U8
    field10* {.bitsize: 2.}: U8
    G*       {.bitsize: 1.}: U8
    base_h*:            U8

type
  data* = object
    field0* {.bitsize: 1.}: U8
    w*      {.bitsize: 1.}: U8
    exd*    {.bitsize: 1.}: U8
    field3* {.bitsize: 5.}: U8

type
  code* = object
    field0* {.bitsize: 1.}: U8
    r*      {.bitsize: 1.}: U8
    cnf*    {.bitsize: 1.}: U8
    field3* {.bitsize: 5.}: U8



type
  SegDesc* = object
    limit_l*:           U16
    base_l*:            U16
    base_m*:            U8
    field3*:            SegDesc_field3
    limit_h* {.bitsize: 4.}: U8
    AVL*     {.bitsize: 1.}: U8
    field6*  {.bitsize: 1.}: U8
    DB*      {.bitsize: 1.}: U8
    G*       {.bitsize: 1.}: U8
    base_h*:            U8

  Type* {.union.} = object
    data*: data
    code*: code
    field2*: type_field2

  type_field2* = object
    A*      {.bitsize: 1.}: U8
    field1* {.bitsize: 2.}: U8
    segc*   {.bitsize: 1.}: U8
    field3* {.bitsize: 4.}: U8

  SegDesc_field3* {.union.} = object
    Type*: Type
    field1*: SegDesc_field3_field1

  SegDesc_field3_field1* = object
    field0* {.bitsize: 4.}: U8
    S*      {.bitsize: 1.}: U8
    DPL*    {.bitsize: 2.}: U8
    P*      {.bitsize: 1.}: U8



proc A*(this: Type): U8 = this.field2.A
proc `A=`*(this: var Type, value: U8) = this.field2.A = value
proc segc*(this: Type): U8 = this.field2.segc
proc `segc=`*(this: var Type, value: U8) = this.field2.segc = value
proc S*(this: SegDesc_field3): U8 = this.field1.S
proc `S=`*(this: var SegDesc_field3, value: U8) = this.field1.S = value
proc DPL*(this: SegDesc_field3): U8 = this.field1.DPL
proc `DPL=`*(this: var SegDesc_field3, value: U8) = this.field1.DPL = value
proc P*(this: SegDesc_field3): U8 = this.field1.P
proc `P=`*(this: var SegDesc_field3, value: U8) = this.field1.P = value
proc getType*(this: SegDesc): Type = this.field3.Type
proc getType*(this: var SegDesc): var Type = this.field3.Type
proc `Type=`*(this: var SegDesc, value: Type) = this.field3.Type = value
proc S*(this: SegDesc): U8 = this.field3.field1.S
proc `S=`*(this: var SegDesc, value: U8) = this.field3.field1.S = value
proc DPL*(this: SegDesc): U8 = this.field3.field1.DPL
proc `DPL=`*(this: var SegDesc, value: U8) = this.field3.field1.DPL = value
proc P*(this: SegDesc): U8 = this.field3.field1.P
proc `P=`*(this: var SegDesc, value: U8) = this.field3.field1.P = value

type
  TSSDesc_field3* {.bycopy, union.} = object
    field0*: TSSDesc_field3_field0
    field1*: TSSDesc_field3_field1

  TSSDesc* = object
    limit_l*:        U16
    base_l*:        U16
    base_m*:        U8
    field3*:        TSSDesc_field3
    limit_h* {.bitsize: 4.}: U8
    AVL* {.bitsize: 1.}: U8
    field6* {.bitsize: 2.}: U8
    G* {.bitsize: 1.}: U8
    base_h*:        U8

  TSSDesc_field3_field0* = object
    field0* {.bitsize: 1.}: U8
    B* {.bitsize: 1.}: U8

  TSSDesc_field3_field1* = object
    Type* {.bitsize: 3.}: U8
    D* {.bitsize: 1.}: U8
    S* {.bitsize: 1.}: U8
    DPL* {.bitsize: 2.}: U8
    P* {.bitsize: 1.}: U8



proc B*(this: TSSDesc_field3): U8 = this.field0.B
proc `B=`*(this: var TSSDesc_field3, value: U8) = this.field0.B = value
proc `Type=`*(this: var TSSDesc_field3, value: U8) = this.field1.Type = value
proc D*(this: TSSDesc_field3): U8 = this.field1.D
proc `D=`*(this: var TSSDesc_field3, value: U8) = this.field1.D = value
proc S*(this: TSSDesc_field3): U8 = this.field1.S
proc `S=`*(this: var TSSDesc_field3, value: U8) = this.field1.S = value
proc DPL*(this: TSSDesc_field3): U8 = this.field1.DPL
proc `DPL=`*(this: var TSSDesc_field3, value: U8) = this.field1.DPL = value
proc P*(this: TSSDesc_field3): U8 = this.field1.P
proc `P=`*(this: var TSSDesc_field3, value: U8) = this.field1.P = value
proc B*(this: TSSDesc): U8 = this.field3.field0.B
proc `B=`*(this: var TSSDesc, value: U8) = this.field3.field0.B = value
proc `Type=`*(this: var TSSDesc, value: U8) = this.field3.field1.Type = value
proc getType*(this: TSSDesc): U8 = this.field3.field1.Type
proc D*(this: TSSDesc): U8 = this.field3.field1.D
proc `D=`*(this: var TSSDesc, value: U8) = this.field3.field1.D = value
proc S*(this: TSSDesc): U8 = this.field3.field1.S
proc `S=`*(this: var TSSDesc, value: U8) = this.field3.field1.S = value
proc DPL*(this: TSSDesc): U8 = this.field3.field1.DPL
proc `DPL=`*(this: var TSSDesc, value: U8) = this.field3.field1.DPL = value
proc P*(this: TSSDesc): U8 = this.field3.field1.P
proc `P=`*(this: var TSSDesc, value: U8) = this.field3.field1.P = value

type
  LDTDesc* = object
    limit_l*:        U16
    base_l*:        U16
    base_m*:        U8
    Type* {.bitsize: 3.}: U8
    D* {.bitsize: 1.}: U8
    S* {.bitsize: 1.}: U8
    DPL* {.bitsize: 2.}: U8
    P* {.bitsize: 1.}: U8
    limit_h* {.bitsize: 4.}: U8
    AVL* {.bitsize: 1.}: U8
    field10* {.bitsize: 2.}: U8
    G* {.bitsize: 1.}: U8
    base_h*:        U8


type
  CallGateDesc* = object
    offset_l*:        U16
    seg_sel*:        U16
    pc* {.bitsize: 5.}: U8
    field3* {.bitsize: 3.}: U8
    Type* {.bitsize: 3.}: U8
    D* {.bitsize: 1.}: U8
    S* {.bitsize: 1.}: U8
    DPL* {.bitsize: 2.}: U8
    P* {.bitsize: 1.}: U8
    offset_h*:        U16

type
  TaskGateDesc* = object
    field0* {.bitsize: 16.}: U16
    tss_sel*:        U16
    field2* {.bitsize: 8.}: U8
    Type* {.bitsize: 3.}: U8
    field4* {.bitsize: 1.}: U8
    S* {.bitsize: 1.}: U8
    DPL* {.bitsize: 2.}: U8
    P* {.bitsize: 1.}: U8
    field8* {.bitsize: 16.}: U16

type
  IntGateDesc* = object
    offset_l*:        U16
    seg_sel*:        U16
    field2* {.bitsize: 8.}: U8
    Type* {.bitsize: 3.}: U8
    D* {.bitsize: 1.}: U8
    S* {.bitsize: 1.}: U8
    DPL* {.bitsize: 2.}: U8
    P* {.bitsize: 1.}: U8
    offset_h*:        U16

type
  TrapGateDesc* = object
    offset_l*:        U16
    seg_sel*:        U16
    field2* {.bitsize: 8.}: U8
    Type* {.bitsize: 3.}: U8
    D* {.bitsize: 1.}: U8
    S* {.bitsize: 1.}: U8
    DPL* {.bitsize: 2.}: U8
    P* {.bitsize: 1.}: U8
    offset_h*:        U16

type
  TSS* = object
    prev_sel*:          U16
    field1*  {.bitsize: 16.}: U16
    esp0*:              U32
    ss0*:               U16
    field4*  {.bitsize: 16.}: U16
    esp1*:              U32
    ss1*:               U16
    field7*  {.bitsize: 16.}: U16
    esp2*:              U32
    ss2*:               U16
    field10* {.bitsize: 16.}: U16
    cr3*:               U32
    eip*:               U32
    eflags*:            U32
    eax*:               U32
    ecx*:               U32
    edx*:               U32
    ebx*:               U32
    esp*:               U32
    ebp*:               U32
    esi*:               U32
    edi*:               U32
    es*:                U16
    field23* {.bitsize: 16.}: U16
    cs*:                U16
    field25* {.bitsize: 16.}: U16
    ss*:                U16
    field27* {.bitsize: 16.}: U16
    ds*:                U16
    field29* {.bitsize: 16.}: U16
    fs*:                U16
    field31* {.bitsize: 16.}: U16
    gs*:                U16
    field33* {.bitsize: 16.}: U16
    ldtr*:              U16
    field35* {.bitsize: 16.}: U16
    T*       {.bitsize: 1.}:  U16
    field37* {.bitsize: 15.}: U16
    io_base*:           U16
