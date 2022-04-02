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

# template UPDATEEIP*(v: untyped): untyped {.dirty.} =
#   CPU.updateEip(v)

# template UPDATEIP*(v: untyped): untyped {.dirty.} =
#   CPU.updateIp(v)

# template GETGPREG*(reg: untyped): untyped {.dirty.} =
#   CPU.getGpreg(reg)

# template SETGPREG*(reg: untyped, v: untyped): untyped {.dirty.} =
#   CPU.setGpreg(reg, v)



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

# template MOD*(): untyped {.dirty.} =
#   (this.instr.modrm.`mod`)

# template REG*(): untyped {.dirty.} =
#   (this.getModrmReg())

# template RM*(): untyped {.dirty.} =
#   (this.instr.modrm.rm)

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
  ModRM* = object
    ## The ModR/M byte encodes a register or an opcode extension, and a
    ## register or a memory address.
    ## https://wiki.osdev.org/X86-64_Instruction_Encoding#ModR.2FM
    rm* {.bitsize: 3.}: NBits[3]
    reg* {.bitsize: 3.}: NBits[3]
    `mod`* {.bitsize: 2.}: NBits[2]

  SIB* {.bycopy.} = object
    base* {.bitsize: 3.}: uint8
    index* {.bitsize: 3.}: uint8
    scale* {.bitsize: 2.}: uint8

  repT* {.size: sizeof(cint).} = enum
    NONE
    REPZ
    REPNZ

  OpcodeData* {.union.} = object
    code*: uint16

  InstrData* = ref object
    prefix*: uint16
    preSegment*: SgRegT
    preRepeat*: repT
    segment*: SgRegT
    opcodeData*: OpcodeData
    fieldModRM*: InstrDataModRM
    fieldDSib*: InstrDataDSib
    fieldDisp*: InstrDataDisp
    fieldImm*: InstrDataImm
    ptr16*: int16
    moffs*: uint32

  InstrDataModRM* {.union.} = object
    ## Parsed ModRM instruction byte. Controls execution of the several
    ## commands.
    dmodrm*: uint8
    modrm*: ModRM

  InstrDataDSib* {.union.} = object
    dsib*: uint8
    sib*: SIB

  InstrDataDisp* {.union.} = object
    disp8*: int8
    disp16*: int16
    disp32*: int32

  InstrDataImm* {.union.} = object
    imm8*: int8
    imm16*: int16
    imm32*: int32

  Instruction* {.inheritable.} = object
    instr*: InstrData
    chszAd*: bool
    emu*: Emulator
    mode32*: bool

  InstrParseFlag* = enum
    iParseModrm ## Instruction contains modrm flag
    iParseImm32 ## Parse 32 bit immediate
    iParseImm16 ## Parse 16 bit immediate
    iParseImm8 ## Parse 8 bit immediate
    iParsePtr16 ## Parse pointer
    iParseMoffs ## Parse offset
    iParseMoffs8 ## Parse 8-bit offset

  ParseInstr* = object
    chk*: array[MAXOPCODE, set[InstrParseFlag]] ## Configuration for parsing
    ## different opcodes.
  ExecInstr* = object of Instruction
    instrfuncs*: array[MAXOPCODE, instrfuncT]

  InstrImpl* = object
    logger*: EmuLogger
    exec*: ExecInstr
    parse*: ParseInstr

  EmuInstrEvent* = ref object of EmuEvent
    instr*: InstrData

  instrfuncT* = proc(this: var InstrImpl)

template log*(instr: InstrImpl, ev: EmuEvent): untyped =
  instr.exec.emu.logger.log(ev, -2)

template log*(instr: ExecInstr, ev: EmuEvent, depth: int = -2): untyped =
  instr.emu.logger.log(ev, depth)

proc toPPrintTree*(
    val: OpcodeData, conf: var PPrintConf, path: PPrintPath): PPrintTree =
  result = newPPrintConst(
    formatOpcode(val.code),
    "int", conf.getId(val), fgCyan, path)

  result.updateCounts(conf.sortBySize)

proc opcode*(this: InstrData): uint16 = this.opcodeData.code
proc opcode*(this: var InstrData): var uint16 = this.opcodeData.code
proc `opcode=`*(this: var InstrData, code: uint16) = this.opcodeData.code = code

proc dmodrm*(this: InstrData): uint8 = this.fieldModRM.dmodrm
proc `dmodrm=`*(this: var InstrData, value: uint8) = this.fieldModRM.dmodrm = value
proc modrm*(this: InstrData): ModRM = this.fieldModRM.modrm
proc `modrm=`*(this: var InstrData, value: ModRM) = this.fieldModRM.modrm = value
proc dsib*(this: InstrData): uint8 = this.fieldDSib.dsib
proc `dsib=`*(this: var InstrData, value: uint8) = this.fieldDSib.dsib = value
proc sib*(this: InstrData): SIB = this.fieldDSib.sib
proc `sib=`*(this: var InstrData, value: SIB) = this.fieldDSib.sib = value
proc disp8*(this: InstrData): int8 = this.fieldDisp.disp8
proc `disp8=`*(this: var InstrData, value: int8) = this.fieldDisp.disp8 = value
proc disp16*(this: InstrData): int16 = this.fieldDisp.disp16
proc `disp16=`*(this: var InstrData, value: int16) = this.fieldDisp.disp16 = value
proc disp32*(this: InstrData): int32 = this.fieldDisp.disp32
proc `disp32=`*(this: var InstrData, value: int32) = this.fieldDisp.disp32 = value
proc imm8*(this: InstrData): int8 = this.fieldImm.imm8
proc `imm8=`*(this: var InstrData, value: int8) = this.fieldImm.imm8 = value
proc imm16*(this: InstrData): int16 = this.fieldImm.imm16
proc `imm16=`*(this: var InstrData, value: int16) = this.fieldImm.imm16 = value
proc imm32*(this: InstrData): int32 = this.fieldImm.imm32
proc `imm32=`*(this: var InstrData, value: int32) = this.fieldImm.imm32 = value

proc initInstruction*(): Instruction =
  discard

proc initInstruction*(e: Emulator, i: InstrData, m: bool): Instruction =
  assertRef(i)
  assertRef(e)
  let t = globalTick()

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

template declareGetPart*(name, size, expr, system: untyped): untyped =
  template name*(this {.inject.}: ExecInstr): NBits[size] =
    block:
      let result = expr
      let e = ev(`eek name`).withIt do:
        it.value = evalue(result.uint8, size, system)
      this.log(e, -3)
      result

  template name*(this {.inject.}: InstrImpl): NBits[size] =
    this.exec.name()

declareGetPart(getModrmMod, 2, this.instr.modrm.mod, evs2)
declareGetPart(getModrmRm, 3, this.instr.modrm.rm, evs2)
declareGetPart(getModrmReg, 3, this.instr.modrm.reg, evs2)

# proc getModrmRM*(this: ExecInstr): NBits[3] =
#   result = this.instr.modrm.rm
#   this.log ev(eekGetModrmRM).withIt do:
#     it.value = evalue(result.uint8, 3, evs2)

# proc getModrmRM*(this: InstrImpl): NBits[3] =
#   result = this.exec.getModrmRM()

# proc getModrmReg*(this: ExecInstr): NBits[3] =
#   result = this.instr.modrm.reg
#   this.log ev(eekGetModrmReg).withIt do:
#     it.value = evalue(result.uint8, 3, evs2)

# proc getModrmReg*(this: InstrImpl): NBits[3] =
#   result = this.exec.getModrmReg()




const
  CHKMODRM* = {iParseModrm} # (1 shl 0)
  CHKIMM32* = {iParseImm32} # (1 shl 1)
  CHKIMM16* = {iParseImm16} # (1 shl 2)
  CHKIMM8*  = {iParseImm8} # (1 shl 3)
  CHKPTR16* = {iParsePtr16} # (1 shl 4)
  CHKMOFFS* = {iParseMoffs} # (1 shl 5)
  CHSZNONE* = 0
  CHSZOP*   = 1
  CHSZAD*   = 2

# proc modrm*(this: InstrFlags): uint8 = this.field1.modrm
# proc `modrm=`*(this: var InstrFlags, value: uint8) = this.field1.modrm = value
# proc imm32*(this: InstrFlags): uint8 = this.field1.imm32
# proc `imm32=`*(this: var InstrFlags, value: uint8) = this.field1.imm32 = value
# proc imm16*(this: InstrFlags): uint8 = this.field1.imm16
# proc `imm16=`*(this: var InstrFlags, value: uint8) = this.field1.imm16 = value
# proc imm8*(this: InstrFlags): uint8 = this.field1.imm8
# proc `imm8=`*(this: var InstrFlags, value: uint8) = this.field1.imm8 = value
# proc ptr16*(this: InstrFlags): uint8 = this.field1.ptr16
# proc `ptr16=`*(this: var InstrFlags, value: uint8) = this.field1.ptr16 = value
# proc moffs*(this: InstrFlags): uint8 = this.field1.moffs
# proc `moffs=`*(this: var InstrFlags, value: uint8) = this.field1.moffs = value
# proc moffs8*(this: InstrFlags): uint8 = this.field1.moffs8
# proc `moffs8=`*(this: var InstrFlags, value: uint8) = this.field1.moffs8 = value

proc setGdtr*(this: var ExecInstr, base: uint32, limit: uint16): void =
  CPU.setDtreg(GDTR, 0, base, limit)

proc setIdtr*(this: var ExecInstr, base: uint32, limit: uint16): void =
  CPU.setDtreg(IDTR, 0, base, limit)

proc getTr*(this: var ExecInstr): uint16 =
  return CPU.getDtregSelector(TR).uint16()

proc getLdtr*(this: var ExecInstr): uint16 =
  return CPU.getDtregSelector(LDTR).uint16()
