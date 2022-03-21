import hardware/processorhpp
import std/tables
import commonhpp
import emulator/emulatorhpp
template EMU*(): untyped {.dirty.} =
  this.get_emu()

template GET_EIP*(): untyped {.dirty.} =
  EMU.get_eip()

template GET_IP*(): untyped {.dirty.} =
  EMU.get_ip()

template SET_EIP*(v: untyped): untyped {.dirty.} =
  EMU.set_eip(v)

template SET_IP*(v: untyped): untyped {.dirty.} =
  EMU.set_ip(v)

template UPDATE_EIP*(v: untyped): untyped {.dirty.} =
  EMU.update_eip(v)

template UPDATE_IP*(v: untyped): untyped {.dirty.} =
  EMU.update_ip(v)

template GET_GPREG*(reg: untyped): untyped {.dirty.} =
  EMU.get_gpreg(reg)

template SET_GPREG*(reg: untyped, v: untyped): untyped {.dirty.} =
  EMU.set_gpreg(reg, v)

template UPDATE_GPREG*(reg: untyped, v: untyped): untyped {.dirty.} =
  EMU.update_gpreg(reg, v)

template EFLAGS_UPDATE_ADD*(v1: untyped, v2: untyped): untyped {.dirty.} =
  EMU.update_eflags_add(v1, v2)

template EFLAGS_UPDATE_OR*(v1: untyped, v2: untyped): untyped {.dirty.} =
  EMU.update_eflags_or(v1, v2)

template EFLAGS_UPDATE_AND*(v1: untyped, v2: untyped): untyped {.dirty.} =
  EMU.update_eflags_and(v1, v2)

template EFLAGS_UPDATE_SUB*(v1: untyped, v2: untyped): untyped {.dirty.} =
  EMU.update_eflags_sub(v1, v2)

template EFLAGS_UPDATE_MUL*(v1: untyped, v2: untyped): untyped {.dirty.} =
  EMU.update_eflags_mul(v1, v2)

template EFLAGS_UPDATE_IMUL*(v1: untyped, v2: untyped): untyped {.dirty.} =
  EMU.update_eflags_imul(v1, v2)

template EFLAGS_UPDATE_SHL*(v1: untyped, v2: untyped): untyped {.dirty.} =
  EMU.update_eflags_shl(v1, v2)

template EFLAGS_UPDATE_SHR*(v1: untyped, v2: untyped): untyped {.dirty.} =
  EMU.update_eflags_shr(v1, v2)

template EFLAGS_CF*(): untyped {.dirty.} =
  EMU.is_carry()

template EFLAGS_PF*(): untyped {.dirty.} =
  EMU.is_parity()

template EFLAGS_ZF*(): untyped {.dirty.} =
  EMU.is_zero()

template EFLAGS_SF*(): untyped {.dirty.} =
  EMU.is_sign()

template EFLAGS_OF*(): untyped {.dirty.} =
  EMU.is_overflow()

template EFLAGS_DF*(): untyped {.dirty.} =
  EMU.is_direction()

template READ_MEM32*(`addr`: untyped): untyped {.dirty.} =
  EMU.get_data32(select_segment(), `addr`)

template READ_MEM16*(`addr`: untyped): untyped {.dirty.} =
  EMU.get_data16(select_segment(), `addr`)

template READ_MEM8*(`addr`: untyped): untyped {.dirty.} =
  EMU.get_data8(select_segment(), `addr`)

template WRITE_MEM32*(`addr`: untyped, v: untyped): untyped {.dirty.} =
  EMU.put_data32(select_segment(), `addr`, v)

template WRITE_MEM16*(`addr`: untyped, v: untyped): untyped {.dirty.} =
  EMU.put_data16(select_segment(), `addr`, v)

template WRITE_MEM8*(`addr`: untyped, v: untyped): untyped {.dirty.} =
  EMU.put_data8(select_segment(), `addr`, v)

template PUSH32*(v: untyped): untyped {.dirty.} =
  EMU.push32(v)

template PUSH16*(v: untyped): untyped {.dirty.} =
  EMU.push16(v)

template POP32*(): untyped {.dirty.} =
  EMU.pop32()

template POP16*(): untyped {.dirty.} =
  EMU.pop16()

template PREFIX*(): untyped {.dirty.} =
  (this.instr.prefix)

template OPCODE*(): untyped {.dirty.} =
  (this.instr.opcode)

template dMODRM*(): untyped {.dirty.} =
  (this.instr.dmodrm)

template MOD*(): untyped {.dirty.} =
  (this.instr.modrm.`mod`)

template REG*(): untyped {.dirty.} =
  (this.instr.modrm.reg)

template RM*(): untyped {.dirty.} =
  (this.instr.modrm.rm)

template dSIB*(): untyped {.dirty.} =
  (this.instr.dsib)

template SCALE*(): untyped {.dirty.} =
  (this.instr.sib.scale)

template INDEX*(): untyped {.dirty.} =
  (this.instr.sib.index)

template BASE*(): untyped {.dirty.} =
  (this.instr.sib.base)

template DISP32*(): untyped {.dirty.} =
  (this.instr.disp32)

template DISP16*(): untyped {.dirty.} =
  (this.instr.disp16)

template DISP8*(): untyped {.dirty.} =
  (this.instr.disp8)

template IMM32*(): untyped {.dirty.} =
  (this.instr.imm32)

template IMM16*(): untyped {.dirty.} =
  (this.instr.imm16)

template IMM8*(): untyped {.dirty.} =
  (this.instr.imm8)

template PTR16*(): untyped {.dirty.} =
  (this.instr.ptr16)

template MOFFS*(): untyped {.dirty.} =
  (this.instr.moffs)

template PRE_SEGMENT*(): untyped {.dirty.} =
  (this.instr.pre_segment)

template PRE_REPEAT*(): untyped {.dirty.} =
  (this.instr.pre_repeat)

template SEGMENT*(): untyped {.dirty.} =
  (this.instr.segment)

const MAX_OPCODE* = 0x200
type
  ModRM* {.bycopy.} = object
    rm* {.bitsize: 3.}: uint8
    reg* {.bitsize: 3.}: uint8
    `mod`* {.bitsize: 2.}: uint8

  SIB* {.bycopy.} = object
    base* {.bitsize: 3.}: uint8
    index* {.bitsize: 3.}: uint8
    scale* {.bitsize: 2.}: uint8

  rep_t* {.size: sizeof(cint).} = enum
    NONE
    REPZ
    REPNZ

  InstrData* {.bycopy.} = object
    prefix*: uint16
    pre_segment*: sgreg_t
    pre_repeat*: rep_t
    segment*: sgreg_t
    opcode*: uint16
    field5*: InstrData_field5
    field6*: InstrData_field6
    field7*: InstrData_field7
    field8*: InstrData_field8
    ptr16*: int16
    moffs*: uint32

  InstrData_field5* {.bycopy, union.} = object
    dmodrm*: uint8
    modrm*: ModRM

  InstrData_field6* {.bycopy, union.} = object
    dsib*: uint8
    sib*: SIB

  InstrData_field7* {.bycopy, union.} = object
    disp8*: int8
    disp16*: int16
    disp32*: int32

  InstrData_field8* {.bycopy, union.} = object
    imm8*: int8
    imm16*: int16
    imm32*: int32

  Instruction* {.bycopy, inheritable.} = object
    instr*: ptr InstrData
    chsz_ad*: bool
    emu*: ptr Emulator
    mode32*: bool

  InstrFlags* {.bycopy, union.} = object
    flags*: uint8
    field1*: InstrFlags_field1

  InstrFlags_field1* {.bycopy.} = object
    modrm* {.bitsize: 1.}: uint8
    imm32* {.bitsize: 1.}: uint8
    imm16* {.bitsize: 1.}: uint8
    imm8* {.bitsize: 1.}: uint8
    ptr16* {.bitsize: 1.}: uint8
    moffs* {.bitsize: 1.}: uint8
    moffs8* {.bitsize: 1.}: uint8

  ParseInstr* {.bycopy.} = object
    chk*: array[MAX_OPCODE, InstrFlags]

  EmuInstr* {.bycopy.} = object of Instruction

  instrfunc_t* = proc(arg0: void)

  ExecInstr* {.bycopy.} = object
    instrfuncs*: array[MAX_OPCODE, instrfunc_t]

proc dmodrm*(this: InstrData): uint8 =
  this.field5.dmodrm

proc `dmodrm=`*(this: var InstrData, value: uint8) =
  this.field5.dmodrm = value

proc modrm*(this: InstrData): ModRM =
  this.field5.modrm

proc `modrm=`*(this: var InstrData, value: ModRM) =
  this.field5.modrm = value

proc dsib*(this: InstrData): uint8 =
  this.field6.dsib

proc `dsib=`*(this: var InstrData, value: uint8) =
  this.field6.dsib = value

proc sib*(this: InstrData): SIB =
  this.field6.sib

proc `sib=`*(this: var InstrData, value: SIB) =
  this.field6.sib = value

proc disp8*(this: InstrData): int8 =
  this.field7.disp8

proc `disp8=`*(this: var InstrData, value: int8) =
  this.field7.disp8 = value

proc disp16*(this: InstrData): int16 =
  this.field7.disp16

proc `disp16=`*(this: var InstrData, value: int16) =
  this.field7.disp16 = value

proc disp32*(this: InstrData): int32 =
  this.field7.disp32

proc `disp32=`*(this: var InstrData, value: int32) =
  this.field7.disp32 = value

proc imm8*(this: InstrData): int8 =
  this.field8.imm8

proc `imm8=`*(this: var InstrData, value: int8) =
  this.field8.imm8 = value

proc imm16*(this: InstrData): int16 =
  this.field8.imm16

proc `imm16=`*(this: var InstrData, value: int16) =
  this.field8.imm16 = value

proc imm32*(this: InstrData): int32 =
  this.field8.imm32

proc `imm32=`*(this: var InstrData, value: int32) =
  this.field8.imm32 = value


proc initInstruction*(): Instruction =
  discard

proc initInstruction*(e: ptr Emulator, i: ptr InstrData, m: bool): Instruction =
  result.emu = e
  result.instr = i
  result.mode32 = m

proc get_emu*(this: var Instruction): ptr Emulator =
  return this.emu

proc is_mode32*(this: var Instruction): bool =
  return this.mode32

proc select_segment*(this: var Instruction): sgreg_t =
  return (if this.instr.prefix.toBool(): PRE_SEGMENT else: SEGMENT)

proc initExecInstr*(): ExecInstr =
  for i in 0 ..< MAX_OPCODE:
    result.instrfuncs[i] = nil


const CHKdMODRM* = (1 shl 0)
const CHK_IMM32* = (1 shl 1)
const CHK_IMM16* = (1 shl 2)
const CHK_IMM8* = (1 shl 3)
const CHK_PTR16* = (1 shl 4)
const CHK_MOFFS* = (1 shl 5)
const CHSZ_NONE* = 0
const CHSZ_OP* = 1
const CHSZ_AD* = 2



proc modrm*(this: InstrFlags): uint8 =
  this.field1.modrm

proc `modrm=`*(this: var InstrFlags, value: uint8) =
  this.field1.modrm = value

proc imm32*(this: InstrFlags): uint8 =
  this.field1.imm32

proc `imm32=`*(this: var InstrFlags, value: uint8) =
  this.field1.imm32 = value

proc imm16*(this: InstrFlags): uint8 =
  this.field1.imm16

proc `imm16=`*(this: var InstrFlags, value: uint8) =
  this.field1.imm16 = value

proc imm8*(this: InstrFlags): uint8 =
  this.field1.imm8

proc `imm8=`*(this: var InstrFlags, value: uint8) =
  this.field1.imm8 = value

proc ptr16*(this: InstrFlags): uint8 =
  this.field1.ptr16

proc `ptr16=`*(this: var InstrFlags, value: uint8) =
  this.field1.ptr16 = value

proc moffs*(this: InstrFlags): uint8 =
  this.field1.moffs

proc `moffs=`*(this: var InstrFlags, value: uint8) =
  this.field1.moffs = value

proc moffs8*(this: InstrFlags): uint8 =
  this.field1.moffs8

proc `moffs8=`*(this: var InstrFlags, value: uint8) =
  this.field1.moffs8 = value



proc set_gdtr*(this: var EmuInstr, base: uint32, limit: uint16): void =
  EMU.accs.cpu.set_dtreg(GDTR, 0, base, limit)

proc set_idtr*(this: var EmuInstr, base: uint32, limit: uint16): void =
  EMU.accs.cpu.set_dtreg(IDTR, 0, base, limit)

proc get_tr*(this: var EmuInstr): uint16 =
  return EMU.accs.cpu.get_dtreg_selector(TR).uint16()

proc get_ldtr*(this: var EmuInstr): uint16 =
  return EMU.accs.cpu.get_dtreg_selector(LDTR).uint16()
