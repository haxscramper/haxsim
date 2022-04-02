import hardware/[processorhpp, eflagshpp]
import std/tables
import ../instruction/opcodes
import commonhpp
import emulator/[emulatorhpp, accesshpp]

template EMU*(): untyped =
  let tmp = this.getEmu()
  assertRef(tmp)
  tmp


template CPU*(): untyped {.dirty.} = EMU.accs.cpu
template EFLAGS*(): untyped = CPU.eflags
template MEM*(): untyped {.dirty.} = EMU.accs.mem
template ACS*(): untyped {.dirty.} = EMU.accs
template INT*(): untyped {.dirty.} = EMU.intr
template EIO*(): untyped {.dirty.} = EMU.accs.io

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
    modrm*: ModRM
    fieldDSib*: InstrDataDSib
    fieldDisp*: InstrDataDisp
    fieldImm*: InstrDataImm
    ptr16*: int16
    moffs*: uint32

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

  InstrParseFlag* = enum
    iParseModrm ## Instruction contains modrm flag
    iParseImm32 ## Parse 32 bit immediate
    iParseImm16 ## Parse 16 bit immediate
    iParseImm8 ## Parse 8 bit immediate
    iParsePtr16 ## Parse pointer
    iParseMoffs ## Parse offset
    iParseMoffs8 ## Parse 8-bit offset

  ExecInstr* = object
    idata*: InstrData
    chszAd*: bool
    emu*: Emulator
    mode32*: bool
    instrfuncs*: array[MAXOPCODE, instrfuncT]

  InstrImpl* = object
    ## Instruction caller implementation.
    exec*: ExecInstr ## Executed instruction
    chk*: array[MAXOPCODE, set[InstrParseFlag]] ## Configuration for parsing
    ## different opcodes.


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

proc initExecInstr*(e: Emulator, i: InstrData, m: bool): ExecInstr =
  assertRef(i)
  assertRef(e)
  result.emu = e
  result.idata = i
  result.mode32 = m

proc getEmu*(this: ExecInstr): Emulator =
  result = this.emu
  assertRef(result)

proc isMode32*(this: ExecInstr): bool =
  return this.mode32

proc selectSegment*(this: var ExecInstr): SgRegT =
  if this.idata.prefix.toBool():
    this.idata.preSegment
  else:
    this.idata.segment

proc initExecInstr*(): ExecInstr =
  for i in 0 ..< MAXOPCODE:
    result.instrfuncs[i] = nil

func idata*(impl: InstrImpl): InstrData = impl.exec.idata
func idata*(impl: var InstrImpl): var InstrData = impl.exec.idata
func emu*(impl: InstrImpl): Emulator = impl.exec.emu
template cpu*(impl: InstrImpl): Processor = impl.exec.emu.cpu
func eflags*(impl: InstrImpl): Eflags = impl.exec.emu.cpu.eflags

proc push32*(this: InstrImpl, v: EDWord) = this.emu.accs.push32(v)
proc push16*(this: InstrImpl, v: EWord)  = this.emu.accs.push16(v)
proc pop32*(this: InstrImpl): EDWord  = this.emu.accs.pop32()
proc pop16*(this: InstrImpl): EWord  = this.emu.accs.pop16()

template prefix*(this: InstrImpl | ExecInstr) : untyped = this.idata.prefix
template Dsib*(this: InstrImpl | ExecInstr)   : untyped = this.idata.dsib
template `mod`*(this: InstrImpl | ExecInstr)  : untyped = this.idata.modrm.`mod`
template rm*(this: InstrImpl | ExecInstr)  : untyped = this.idata.modrm.rm
template reg*(this: InstrImpl | ExecInstr)   : untyped = this.idata.modrm.reg
template scale*(this: InstrImpl | ExecInstr)  : untyped = this.idata.sib.scale
template index*(this: InstrImpl | ExecInstr)  : untyped = this.idata.sib.index
template base*(this: InstrImpl | ExecInstr)   : untyped = this.idata.sib.base
template disp32*(this: InstrImpl | ExecInstr) : untyped = this.idata.disp32
template disp16*(this: InstrImpl | ExecInstr) : untyped = this.idata.disp16
template disp8*(this: InstrImpl | ExecInstr)  : untyped = this.idata.disp8
template imm32*(this: InstrImpl | ExecInstr)  : untyped = this.idata.imm32
template imm16*(this: InstrImpl | ExecInstr)  : untyped = this.idata.imm16
template imm8*(this: InstrImpl | ExecInstr)   : untyped = this.idata.imm8
template ptr16*(this: InstrImpl | ExecInstr)  : untyped = this.idata.ptr16
template moffs*(this: InstrImpl | ExecInstr)  : untyped = this.idata.moffs




# func mod*(idata: InstrData): NBits[3] =

proc getPreRepeat*(this: InstrImpl): repT = this.exec.idata.prerepeat

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

declareGetPart(getModrmMod, 2, this.idata.modrm.mod, evs2)
declareGetPart(getModrmRm, 3, this.idata.modrm.rm, evs2)
declareGetPart(getModrmReg, 3, this.idata.modrm.reg, evs2)

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
