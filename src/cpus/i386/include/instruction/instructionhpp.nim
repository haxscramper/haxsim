import hardware/processorhpp
import std/tables
import ../instruction/opcodes
import commonhpp
import emulator/emulatorhpp
template EMU*(): untyped =
  let tmp = this.getEmu()
  assertRef(tmp)
  tmp

template CPU*(): untyped {.dirty.} = EMU.accs.cpu
template MEM*(): untyped {.dirty.} = EMU.accs.mem
template ACS*(): untyped {.dirty.} = EMU.accs
template INT*(): untyped {.dirty.} = EMU.intr
template EIO*(): untyped {.dirty.} = EMU.accs.io

template GETEIP*(): untyped {.dirty.} =
  CPU.getEip()

template GETIP*(): untyped {.dirty.} =
  CPU.getIp()

template SETEIP*(v: untyped): untyped {.dirty.} =
  CPU.setEip(v)

template SETIP*(v: untyped): untyped {.dirty.} =
  CPU.setIp(v)

template UPDATEEIP*(v: untyped): untyped {.dirty.} =
  CPU.updateEip(v)

template UPDATEIP*(v: untyped): untyped {.dirty.} =
  CPU.updateIp(v)

template GETGPREG*(reg: untyped): untyped {.dirty.} =
  CPU.getGpreg(reg)

template SETGPREG*(reg: untyped, v: untyped): untyped {.dirty.} =
  CPU.setGpreg(reg, v)

template UPDATEGPREG*(reg: untyped, v: untyped): untyped {.dirty.} =
  CPU.updateGpreg(reg, v)

template EFLAGSUPDATEADD*(v1: untyped, v2: untyped): untyped {.dirty.} =
  CPU.eflags.updateEflagsAdd(v1, v2)

template EFLAGSUPDATEOR*(v1: untyped, v2: untyped): untyped {.dirty.} =
  CPU.eflags.updateEflagsOr(v1, v2)

template EFLAGSUPDATEAND*(v1: untyped, v2: untyped): untyped {.dirty.} =
  CPU.eflags.updateEflagsAnd(v1, v2)

template EFLAGSUPDATESUB*(v1: untyped, v2: untyped): untyped {.dirty.} =
  CPU.eflags.updateEflagsSub(v1, v2)

template EFLAGSUPDATEMUL*(v1: untyped, v2: untyped): untyped {.dirty.} =
  CPU.eflags.updateEflagsMul(v1, v2)

template EFLAGSUPDATEIMUL*(v1: untyped, v2: untyped): untyped {.dirty.} =
  CPU.eflags.updateEflagsImul(v1, v2)

template EFLAGSUPDATESHL*(v1: untyped, v2: untyped): untyped {.dirty.} =
  CPU.eflags.updateEflagsShl(v1, v2)

template EFLAGSUPDATESHR*(v1: untyped, v2: untyped): untyped {.dirty.} =
  CPU.eflags.updateEflagsShr(v1, v2)

template EFLAGSCF*(): untyped {.dirty.} =
  CPU.eflags.isCarry()

template EFLAGSPF*(): untyped {.dirty.} =
  CPU.eflags.isParity()

template EFLAGSZF*(): untyped {.dirty.} =
  CPU.eflags.isZero()

template EFLAGSSF*(): untyped {.dirty.} =
  CPU.eflags.isSign()

template EFLAGSOF*(): untyped {.dirty.} =
  CPU.eflags.isOverflow()

template EFLAGSDF*(): untyped {.dirty.} =
  CPU.eflags.isDirection()

template READMEM32*(addrD: untyped): untyped {.dirty.} =
  EMU.accs.getData32(this.selectSegment(), addrD)

template READMEM16*(addrD: untyped): untyped {.dirty.} =
  EMU.accs.getData16(this.selectSegment(), addrD)

template READMEM8*(addrD: untyped): untyped {.dirty.} =
  EMU.accs.getData8(this.selectSegment(), addrD)

template WRITEMEM32*(addrD: untyped, v: untyped): untyped {.dirty.} =
  EMU.accs.putData32(this.selectSegment(), addrD, v)

template WRITEMEM16*(addrD: untyped, v: untyped): untyped {.dirty.} =
  EMU.accs.putData16(this.selectSegment(), addrD, v)

template WRITEMEM8*(addrD: untyped, v: untyped): untyped {.dirty.} =
  EMU.accs.putData8(this.selectSegment(), addrD, v)

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

template PRESEGMENT*(): untyped {.dirty.} =
  (this.instr.preSegment)

template PREREPEAT*(): untyped {.dirty.} =
  (this.instr.preRepeat)

template SEGMENT*(): untyped {.dirty.} =
  (this.instr.segment)

const MAXOPCODE* = 0x200
type
  ModRM* {.bycopy.} = object
    rm* {.bitsize: 3.}: uint8
    reg* {.bitsize: 3.}: uint8
    `mod`* {.bitsize: 2.}: uint8

  SIB* {.bycopy.} = object
    base* {.bitsize: 3.}: uint8
    index* {.bitsize: 3.}: uint8
    scale* {.bitsize: 2.}: uint8

  repT* {.size: sizeof(cint).} = enum
    NONE
    REPZ
    REPNZ

  OpcodeData* {.union.} = object
    name*: ICode
    code*: uint16

  InstrData* = object
    prefix*: uint16
    preSegment*: SgRegT
    preRepeat*: repT
    segment*: SgRegT
    opcodeData*: OpcodeData
    field5*: InstrDataField5
    field6*: InstrDataField6
    field7*: InstrDataField7
    field8*: InstrDataField8
    ptr16*: int16
    moffs*: uint32

  InstrDataField5* {.bycopy, union.} = object
    ## Parsed ModRM instruction byte. Controls execution of the several
    ## commands.
    dmodrm*: uint8
    modrm*: ModRM

  InstrDataField6* {.bycopy, union.} = object
    dsib*: uint8
    sib*: SIB

  InstrDataField7* {.bycopy, union.} = object
    disp8*: int8
    disp16*: int16
    disp32*: int32

  InstrDataField8* {.bycopy, union.} = object
    imm8*: int8
    imm16*: int16
    imm32*: int32

  Instruction* {.bycopy, inheritable.} = object
    instr*: InstrData
    chszAd*: bool
    emu*: Emulator
    mode32*: bool

  InstrFlags* {.bycopy, union.} = object
    flags*: uint8
    field1*: InstrFlagsField1

  InstrFlagsField1* {.bycopy.} = object
    modrm* {.bitsize: 1.}: uint8 ## Instruction contains modrm flag
    imm32* {.bitsize: 1.}: uint8 ## Parse 32 bit immediate
    imm16* {.bitsize: 1.}: uint8 ## Parse 16 bit immediate
    imm8* {.bitsize: 1.}: uint8 ## Parse 8 bit immediate
    ptr16* {.bitsize: 1.}: uint8 ## Parse pointer
    moffs* {.bitsize: 1.}: uint8 ## Parse offset
    moffs8* {.bitsize: 1.}: uint8 ## Parse 8-bit offset

  ParseInstr* = object
    chk*: array[MAXOPCODE, InstrFlags] ## Configuration for parsing
    ## different opcodes.

  EmuInstr* {.bycopy.} = object of Instruction


  ExecInstr* {.bycopy.} = object of Instruction
    instrfuncs*: array[MAXOPCODE, instrfuncT]

  InstrImpl* {.bycopy, inheritable.} = object
    exec*: ExecInstr
    parse*: ParseInstr
    emu*: EmuInstr

  instrfuncT* = proc(this: var InstrImpl)


proc opcode*(this: InstrData): uint16 = this.opcodeData.code
proc opcode*(this: var InstrData): var uint16 = this.opcodeData.code
proc `opcode=`*(this: var InstrData, code: uint16) = this.opcodeData.code = code

proc dmodrm*(this: InstrData): uint8 = this.field5.dmodrm
proc `dmodrm=`*(this: var InstrData, value: uint8) = this.field5.dmodrm = value
proc modrm*(this: InstrData): ModRM = this.field5.modrm
proc `modrm=`*(this: var InstrData, value: ModRM) = this.field5.modrm = value
proc dsib*(this: InstrData): uint8 = this.field6.dsib
proc `dsib=`*(this: var InstrData, value: uint8) = this.field6.dsib = value
proc sib*(this: InstrData): SIB = this.field6.sib
proc `sib=`*(this: var InstrData, value: SIB) = this.field6.sib = value
proc disp8*(this: InstrData): int8 = this.field7.disp8
proc `disp8=`*(this: var InstrData, value: int8) = this.field7.disp8 = value
proc disp16*(this: InstrData): int16 = this.field7.disp16
proc `disp16=`*(this: var InstrData, value: int16) = this.field7.disp16 = value
proc disp32*(this: InstrData): int32 = this.field7.disp32
proc `disp32=`*(this: var InstrData, value: int32) = this.field7.disp32 = value
proc imm8*(this: InstrData): int8 = this.field8.imm8
proc `imm8=`*(this: var InstrData, value: int8) = this.field8.imm8 = value
proc imm16*(this: InstrData): int16 = this.field8.imm16
proc `imm16=`*(this: var InstrData, value: int16) = this.field8.imm16 = value
proc imm32*(this: InstrData): int32 = this.field8.imm32
proc `imm32=`*(this: var InstrData, value: int32) = this.field8.imm32 = value

proc initInstruction*(): Instruction =
  discard

proc initInstruction*(e: Emulator, i: InstrData, m: bool): Instruction =
  result.emu = e
  result.instr = i
  result.mode32 = m

proc getEmu*(this: var Instruction): Emulator =
  result = this.emu
  assertRef(result)

proc isMode32*(this: var Instruction): bool =
  return this.mode32

proc selectSegment*(this: var Instruction): SgRegT =
  return (if this.instr.prefix.toBool(): PRESEGMENT else: SEGMENT)

proc initExecInstr*(): ExecInstr =
  for i in 0 ..< MAXOPCODE:
    result.instrfuncs[i] = nil


const
  CHKMODRM* = (1 shl 0)
  CHKIMM32* = (1 shl 1)
  CHKIMM16* = (1 shl 2)
  CHKIMM8*  = (1 shl 3)
  CHKPTR16* = (1 shl 4)
  CHKMOFFS* = (1 shl 5)
  CHSZNONE* = 0
  CHSZOP*   = 1
  CHSZAD*   = 2

proc modrm*(this: InstrFlags): uint8 = this.field1.modrm
proc `modrm=`*(this: var InstrFlags, value: uint8) = this.field1.modrm = value
proc imm32*(this: InstrFlags): uint8 = this.field1.imm32
proc `imm32=`*(this: var InstrFlags, value: uint8) = this.field1.imm32 = value
proc imm16*(this: InstrFlags): uint8 = this.field1.imm16
proc `imm16=`*(this: var InstrFlags, value: uint8) = this.field1.imm16 = value
proc imm8*(this: InstrFlags): uint8 = this.field1.imm8
proc `imm8=`*(this: var InstrFlags, value: uint8) = this.field1.imm8 = value
proc ptr16*(this: InstrFlags): uint8 = this.field1.ptr16
proc `ptr16=`*(this: var InstrFlags, value: uint8) = this.field1.ptr16 = value
proc moffs*(this: InstrFlags): uint8 = this.field1.moffs
proc `moffs=`*(this: var InstrFlags, value: uint8) = this.field1.moffs = value
proc moffs8*(this: InstrFlags): uint8 = this.field1.moffs8
proc `moffs8=`*(this: var InstrFlags, value: uint8) = this.field1.moffs8 = value

proc setGdtr*(this: var EmuInstr, base: uint32, limit: uint16): void =
  CPU.setDtreg(GDTR, 0, base, limit)

proc setIdtr*(this: var EmuInstr, base: uint32, limit: uint16): void =
  CPU.setDtreg(IDTR, 0, base, limit)

proc getTr*(this: var EmuInstr): uint16 =
  return CPU.getDtregSelector(TR).uint16()

proc getLdtr*(this: var EmuInstr): uint16 =
  return CPU.getDtregSelector(LDTR).uint16()
