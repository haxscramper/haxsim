import
  map
import
  commonhpp
import
  emulator/emulatorhpp
template EMU*() {.dirty.} = 
  get_emu()

template GET_EIP*() {.dirty.} = 
  EMU.get_eip()

template GET_IP*() {.dirty.} = 
  EMU.get_ip()

template SET_EIP*(v: untyped) {.dirty.} = 
  EMU.set_eip(v)

template SET_IP*(v: untyped) {.dirty.} = 
  EMU.set_ip(v)

template UPDATE_EIP*(v: untyped) {.dirty.} = 
  EMU.update_eip(v)

template UPDATE_IP*(v: untyped) {.dirty.} = 
  EMU.update_ip(v)

template GET_GPREG*(reg: untyped) {.dirty.} = 
  EMU.get_gpreg(reg)

template SET_GPREG*(reg: untyped, v: untyped) {.dirty.} = 
  EMU.set_gpreg(reg, v)

template UPDATE_GPREG*(reg: untyped, v: untyped) {.dirty.} = 
  EMU.update_gpreg(reg, v)

template EFLAGS_UPDATE_ADD*(v1: untyped, v2: untyped) {.dirty.} = 
  EMU.update_eflags_add(v1, v2)

template EFLAGS_UPDATE_OR*(v1: untyped, v2: untyped) {.dirty.} = 
  EMU.update_eflags_or(v1, v2)

template EFLAGS_UPDATE_AND*(v1: untyped, v2: untyped) {.dirty.} = 
  EMU.update_eflags_and(v1, v2)

template EFLAGS_UPDATE_SUB*(v1: untyped, v2: untyped) {.dirty.} = 
  EMU.update_eflags_sub(v1, v2)

template EFLAGS_UPDATE_MUL*(v1: untyped, v2: untyped) {.dirty.} = 
  EMU.update_eflags_mul(v1, v2)

template EFLAGS_UPDATE_IMUL*(v1: untyped, v2: untyped) {.dirty.} = 
  EMU.update_eflags_imul(v1, v2)

template EFLAGS_UPDATE_SHL*(v1: untyped, v2: untyped) {.dirty.} = 
  EMU.update_eflags_shl(v1, v2)

template EFLAGS_UPDATE_SHR*(v1: untyped, v2: untyped) {.dirty.} = 
  EMU.update_eflags_shr(v1, v2)

template EFLAGS_CF*() {.dirty.} = 
  EMU.is_carry()

template EFLAGS_PF*() {.dirty.} = 
  EMU.is_parity()

template EFLAGS_ZF*() {.dirty.} = 
  EMU.is_zero()

template EFLAGS_SF*() {.dirty.} = 
  EMU.is_sign()

template EFLAGS_OF*() {.dirty.} = 
  EMU.is_overflow()

template EFLAGS_DF*() {.dirty.} = 
  EMU.is_direction()

template READ_MEM32*(`addr`: untyped) {.dirty.} = 
  EMU.get_data32(select_segment(), `addr`)

template READ_MEM16*(`addr`: untyped) {.dirty.} = 
  EMU.get_data16(select_segment(), `addr`)

template READ_MEM8*(`addr`: untyped) {.dirty.} = 
  EMU.get_data8(select_segment(), `addr`)

template WRITE_MEM32*(`addr`: untyped, v: untyped) {.dirty.} = 
  EMU.put_data32(select_segment(), `addr`, v)

template WRITE_MEM16*(`addr`: untyped, v: untyped) {.dirty.} = 
  EMU.put_data16(select_segment(), `addr`, v)

template WRITE_MEM8*(`addr`: untyped, v: untyped) {.dirty.} = 
  EMU.put_data8(select_segment(), `addr`, v)

template PUSH32*(v: untyped) {.dirty.} = 
  EMU.push32(v)

template PUSH16*(v: untyped) {.dirty.} = 
  EMU.push16(v)

template POP32*() {.dirty.} = 
  EMU.pop32()

template POP16*() {.dirty.} = 
  EMU.pop16()

template PREFIX*() {.dirty.} = 
  (instr.prefix)

template OPCODE*() {.dirty.} = 
  (instr.opcode)

template _MODRM*() {.dirty.} = 
  (instr._modrm)

template MOD*() {.dirty.} = 
  (instr.modrm.`mod`)

template REG*() {.dirty.} = 
  (instr.modrm.reg)

template RM*() {.dirty.} = 
  (instr.modrm.rm)

template _SIB*() {.dirty.} = 
  (instr._sib)

template SCALE*() {.dirty.} = 
  (instr.sib.scale)

template INDEX*() {.dirty.} = 
  (instr.sib.index)

template BASE*() {.dirty.} = 
  (instr.sib.base)

template DISP32*() {.dirty.} = 
  (instr.disp32)

template DISP16*() {.dirty.} = 
  (instr.disp16)

template DISP8*() {.dirty.} = 
  (instr.disp8)

template IMM32*() {.dirty.} = 
  (instr.imm32)

template IMM16*() {.dirty.} = 
  (instr.imm16)

template IMM8*() {.dirty.} = 
  (instr.imm8)

template PTR16*() {.dirty.} = 
  (instr.ptr16)

template MOFFS*() {.dirty.} = 
  (instr.moffs)

template PRE_SEGMENT*() {.dirty.} = 
  (instr.pre_segment)

template PRE_REPEAT*() {.dirty.} = 
  (instr.pre_repeat)

template SEGMENT*() {.dirty.} = 
  (instr.segment)

const MAX_OPCODE = 0x200
type
  ModRM* {.bycopy, importcpp.} = object
    rm* {.bitsize: 3.}: uint8
    reg* {.bitsize: 3.}: uint8
    mod* {.bitsize: 2.}: uint8
  
type
  SIB* {.bycopy, importcpp.} = object
    base* {.bitsize: 3.}: uint8
    index* {.bitsize: 3.}: uint8
    scale* {.bitsize: 2.}: uint8
  
type
  REPNZ* {.size: sizeof(cint).} = enum
    NONE
    REPZ
    REPNZ
  
type
  InstrData* {.bycopy, importcpp.} = object
    prefix*: uint16
    pre_segment*: sgreg_t
    pre_repeat*: rep_t
    segment*: sgreg_t
    opcode*: uint16
    field5*: InstrData_field5_Type
    field6*: InstrData_field6_Type
    field7*: InstrData_field7_Type
    field8*: InstrData_field8_Type
    ptr16*: int16
    moffs*: uint32
  
type
  InstrData_field5_Type* {.bycopy, union.} = object
    _modrm*: uint8
    modrm*: ModRM
  
proc _modrm*(this: InstrData): uint8 = 
  this.field5._modrm

proc `_modrm =`*(this: var InstrData): uint8 = 
  this.field5._modrm

proc modrm*(this: InstrData): ModRM = 
  this.field5.modrm

proc `modrm =`*(this: var InstrData): ModRM = 
  this.field5.modrm

type
  InstrData_field6_Type* {.bycopy, union.} = object
    _sib*: uint8
    sib*: SIB
  
proc _sib*(this: InstrData): uint8 = 
  this.field6._sib

proc `_sib =`*(this: var InstrData): uint8 = 
  this.field6._sib

proc sib*(this: InstrData): SIB = 
  this.field6.sib

proc `sib =`*(this: var InstrData): SIB = 
  this.field6.sib

type
  InstrData_field7_Type* {.bycopy, union.} = object
    disp8*: int8
    disp16*: int16
    disp32*: int32
  
proc disp8*(this: InstrData): int8 = 
  this.field7.disp8

proc `disp8 =`*(this: var InstrData): int8 = 
  this.field7.disp8

proc disp16*(this: InstrData): int16 = 
  this.field7.disp16

proc `disp16 =`*(this: var InstrData): int16 = 
  this.field7.disp16

proc disp32*(this: InstrData): int32 = 
  this.field7.disp32

proc `disp32 =`*(this: var InstrData): int32 = 
  this.field7.disp32

type
  InstrData_field8_Type* {.bycopy, union.} = object
    imm8*: int8
    imm16*: int16
    imm32*: int32
  
proc imm8*(this: InstrData): int8 = 
  this.field8.imm8

proc `imm8 =`*(this: var InstrData): int8 = 
  this.field8.imm8

proc imm16*(this: InstrData): int16 = 
  this.field8.imm16

proc `imm16 =`*(this: var InstrData): int16 = 
  this.field8.imm16

proc imm32*(this: InstrData): int32 = 
  this.field8.imm32

proc `imm32 =`*(this: var InstrData): int32 = 
  this.field8.imm32

type
  Instruction* {.bycopy, importcpp.} = object
    instr*: ptr InstrData
    chsz_ad*: bool    
    emu*: ptr Emulator
    mode32*: bool    
  
proc initInstruction*(): Instruction = 
  discard 

proc initInstruction*(e: ptr Emulator, i: ptr InstrData, m: bool): Instruction = 
  emu = e
  instr = i
  mode32 = m

proc get_emu*(this: var Instruction): ptr Emulator = 
  return emu

proc is_mode32*(this: var Instruction): bool = 
  return mode32

proc select_segment*(this: var Instruction): sgreg_t = 
  return (if instr.prefix:
            PRE_SEGMENT
          
          else:
            SEGMENT
          )

type
  ExecInstr* {.bycopy, importcpp.} = object
    instrfuncs*: array[, instrfunc_t]
  
proc initExecInstr*(): ExecInstr = 
  for i in 0 ..< MAX_OPCODE:
    instrfuncs[i] = `nil`

type
  instrfunc_t* = 
    proc(arg0: void): void {.cdecl.}
  
const CHK_MODRM = (1 shl 0)
const CHK_IMM32 = (1 shl 1)
const CHK_IMM16 = (1 shl 2)
const CHK_IMM8 = (1 shl 3)
const CHK_PTR16 = (1 shl 4)
const CHK_MOFFS = (1 shl 5)
const CHSZ_NONE = 0
const CHSZ_OP = 1
const CHSZ_AD = 2
type
  InstrFlags* {.bycopy, union, importcpp.} = object
    flags*: uint8
    field1*: InstrFlags_field1_Type
  
type
  InstrFlags_field1_Type* {.bycopy.} = object
    modrm* {.bitsize: 1.}: uint8
    imm32* {.bitsize: 1.}: uint8
    imm16* {.bitsize: 1.}: uint8
    imm8* {.bitsize: 1.}: uint8
    ptr16* {.bitsize: 1.}: uint8
    moffs* {.bitsize: 1.}: uint8
    moffs8* {.bitsize: 1.}: uint8
  
proc modrm*(this: InstrFlags): uint8 = 
  this.field1.modrm

proc `modrm =`*(this: var InstrFlags): uint8 = 
  this.field1.modrm

proc imm32*(this: InstrFlags): uint8 = 
  this.field1.imm32

proc `imm32 =`*(this: var InstrFlags): uint8 = 
  this.field1.imm32

proc imm16*(this: InstrFlags): uint8 = 
  this.field1.imm16

proc `imm16 =`*(this: var InstrFlags): uint8 = 
  this.field1.imm16

proc imm8*(this: InstrFlags): uint8 = 
  this.field1.imm8

proc `imm8 =`*(this: var InstrFlags): uint8 = 
  this.field1.imm8

proc ptr16*(this: InstrFlags): uint8 = 
  this.field1.ptr16

proc `ptr16 =`*(this: var InstrFlags): uint8 = 
  this.field1.ptr16

proc moffs*(this: InstrFlags): uint8 = 
  this.field1.moffs

proc `moffs =`*(this: var InstrFlags): uint8 = 
  this.field1.moffs

proc moffs8*(this: InstrFlags): uint8 = 
  this.field1.moffs8

proc `moffs8 =`*(this: var InstrFlags): uint8 = 
  this.field1.moffs8

type
  ParseInstr* {.bycopy, importcpp.} = object
    chk*: array[, InstrFlags]
  
type
  EmuInstr* {.bycopy, importcpp.} = object
    
  
proc set_gdtr*(this: var EmuInstr, base: uint32, limit: uint16): void = 
  EMU.set_dtreg(GDTR, 0, base, limit)

proc set_idtr*(this: var EmuInstr, base: uint32, limit: uint16): void = 
  EMU.set_dtreg(IDTR, 0, base, limit)

proc get_tr*(this: var EmuInstr): uint16 = 
  return EMU.get_dtreg_selector(TR)

proc get_ldtr*(this: var EmuInstr): uint16 = 
  return EMU.get_dtreg_selector(LDTR)
