import hardware/processorhpp
import std/tables
import commonhpp
import emulator/emulatorhpp
template EMU*(): untyped =
  let tmp = this.get_emu()
  assertRef(tmp)
  tmp

template CPU*(): untyped {.dirty.} = EMU.accs.cpu
template MEM*(): untyped {.dirty.} = EMU.accs.mem
template ACS*(): untyped {.dirty.} = EMU.accs
template INT*(): untyped {.dirty.} = EMU.intr
template EIO*(): untyped {.dirty.} = EMU.accs.io

template GET_EIP*(): untyped {.dirty.} =
  CPU.get_eip()

template GET_IP*(): untyped {.dirty.} =
  CPU.get_ip()

template SET_EIP*(v: untyped): untyped {.dirty.} =
  CPU.set_eip(v)

template SET_IP*(v: untyped): untyped {.dirty.} =
  CPU.set_ip(v)

template UPDATE_EIP*(v: untyped): untyped {.dirty.} =
  CPU.update_eip(v)

template UPDATE_IP*(v: untyped): untyped {.dirty.} =
  CPU.update_ip(v)

template GET_GPREG*(reg: untyped): untyped {.dirty.} =
  CPU.get_gpreg(reg)

template SET_GPREG*(reg: untyped, v: untyped): untyped {.dirty.} =
  CPU.set_gpreg(reg, v)

template UPDATE_GPREG*(reg: untyped, v: untyped): untyped {.dirty.} =
  CPU.update_gpreg(reg, v)

template EFLAGS_UPDATE_ADD*(v1: untyped, v2: untyped): untyped {.dirty.} =
  CPU.eflags.update_eflags_add(v1, v2)

template EFLAGS_UPDATE_OR*(v1: untyped, v2: untyped): untyped {.dirty.} =
  CPU.eflags.update_eflags_or(v1, v2)

template EFLAGS_UPDATE_AND*(v1: untyped, v2: untyped): untyped {.dirty.} =
  CPU.eflags.update_eflags_and(v1, v2)

template EFLAGS_UPDATE_SUB*(v1: untyped, v2: untyped): untyped {.dirty.} =
  CPU.eflags.update_eflags_sub(v1, v2)

template EFLAGS_UPDATE_MUL*(v1: untyped, v2: untyped): untyped {.dirty.} =
  CPU.eflags.update_eflags_mul(v1, v2)

template EFLAGS_UPDATE_IMUL*(v1: untyped, v2: untyped): untyped {.dirty.} =
  CPU.eflags.update_eflags_imul(v1, v2)

template EFLAGS_UPDATE_SHL*(v1: untyped, v2: untyped): untyped {.dirty.} =
  CPU.eflags.update_eflags_shl(v1, v2)

template EFLAGS_UPDATE_SHR*(v1: untyped, v2: untyped): untyped {.dirty.} =
  CPU.eflags.update_eflags_shr(v1, v2)

template EFLAGS_CF*(): untyped {.dirty.} =
  CPU.eflags.is_carry()

template EFLAGS_PF*(): untyped {.dirty.} =
  CPU.eflags.is_parity()

template EFLAGS_ZF*(): untyped {.dirty.} =
  CPU.eflags.is_zero()

template EFLAGS_SF*(): untyped {.dirty.} =
  CPU.eflags.is_sign()

template EFLAGS_OF*(): untyped {.dirty.} =
  CPU.eflags.is_overflow()

template EFLAGS_DF*(): untyped {.dirty.} =
  CPU.eflags.is_direction()

template READ_MEM32*(addr_d: untyped): untyped {.dirty.} =
  EMU.accs.get_data32(this.select_segment(), addr_d)

template READ_MEM16*(addr_d: untyped): untyped {.dirty.} =
  EMU.accs.get_data16(this.select_segment(), addr_d)

template READ_MEM8*(addr_d: untyped): untyped {.dirty.} =
  EMU.accs.get_data8(this.select_segment(), addr_d)

template WRITE_MEM32*(addr_d: untyped, v: untyped): untyped {.dirty.} =
  EMU.accs.put_data32(this.select_segment(), addr_d, v)

template WRITE_MEM16*(addr_d: untyped, v: untyped): untyped {.dirty.} =
  EMU.accs.put_data16(this.select_segment(), addr_d, v)

template WRITE_MEM8*(addr_d: untyped, v: untyped): untyped {.dirty.} =
  EMU.accs.put_data8(this.select_segment(), addr_d, v)

template PUSH32*(v: untyped): untyped {.dirty.} =
  ACS.push32(v)

template PUSH16*(v: untyped): untyped {.dirty.} =
  ACS.push16(v)

template POP32*(): untyped {.dirty.} =
  ACS.pop32()

template POP16*(): untyped {.dirty.} =
  ACS.pop16()

template PREFIX*(): untyped {.dirty.} =
  (this.exec.instr.prefix)

template OPCODE*(): untyped {.dirty.} =
  (this.instr.opcode)

template dMODRM*(): untyped {.dirty.} =
  (this.exec.instr.dmodrm)

template MOD*(): untyped {.dirty.} =
  (this.instr.modrm.`mod`)

template REG*(): untyped {.dirty.} =
  (this.instr.modrm.reg)

template RM*(): untyped {.dirty.} =
  (this.instr.modrm.rm)

template dSIB*(): untyped {.dirty.} =
  (this.exec.instr.dsib)

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
  (this.exec.instr.imm32)

template IMM16*(): untyped {.dirty.} =
  (this.exec.instr.imm16)

template IMM8*(): untyped {.dirty.} =
  (this.exec.instr.imm8)

template PTR16*(): untyped {.dirty.} =
  (this.exec.instr.ptr16)

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
    ## Parsed ModRM instruction byte. Controls execution of the several
    ## commands.
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
    instr*: InstrData
    chsz_ad*: bool
    emu*: Emulator
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


  ExecInstr* {.bycopy.} = object of Instruction
    instrfuncs*: array[MAX_OPCODE, instrfunc_t]

  InstrImpl* {.bycopy, inheritable.} = object
    exec*: ExecInstr
    parse*: ParseInstr
    emu*: EmuInstr

  instrfunc_t* = proc(this: var InstrImpl)


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

proc initInstruction*(e: Emulator, i: InstrData, m: bool): Instruction =
  result.emu = e
  result.instr = i
  result.mode32 = m

proc get_emu*(this: var Instruction): Emulator =
  result = this.emu
  assertRef(result)

proc is_mode32*(this: var Instruction): bool =
  return this.mode32

proc select_segment*(this: var Instruction): sgreg_t =
  return (if this.instr.prefix.toBool(): PRE_SEGMENT else: SEGMENT)

proc initExecInstr*(): ExecInstr =
  for i in 0 ..< MAX_OPCODE:
    result.instrfuncs[i] = nil


const
  CHK_MODRM* = (1 shl 0)
  CHK_IMM32* = (1 shl 1)
  CHK_IMM16* = (1 shl 2)
  CHK_IMM8* = (1 shl 3)
  CHK_PTR16* = (1 shl 4)
  CHK_MOFFS* = (1 shl 5)
  CHSZ_NONE* = 0
  CHSZ_OP* = 1
  CHSZ_AD* = 2



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
  CPU.set_dtreg(GDTR, 0, base, limit)

proc set_idtr*(this: var EmuInstr, base: uint32, limit: uint16): void =
  CPU.set_dtreg(IDTR, 0, base, limit)

proc get_tr*(this: var EmuInstr): uint16 =
  return CPU.get_dtreg_selector(TR).uint16()

proc get_ldtr*(this: var EmuInstr): uint16 =
  return CPU.get_dtreg_selector(LDTR).uint16()


