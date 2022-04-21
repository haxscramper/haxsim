import instruction/instruction
import hardware/[processor, cr]
import emulator/access
import std/lenientops
import common

template INSTR(): untyped = this.exec.idata

proc writeMem8*(this: var ExecInstr, addrD: EPointer, v: U8) =
  ACS.putData8(this.selectSegment(), addrD, v)

proc exec*(this: var InstrImpl): bool =
  var opcode: U16 = INSTR.opcode
  var size = 8
  if opcode shr 8 == 0x0f:
    opcode = (opcode and 0xff) or 0x0100
    size += 8
  
  
  if this.exec.instrfuncs[opcode].isNil():
    assert(false, $("not implemented OPCODE " & hshow(INSTR.opcode, clShowHex)))
    return false

  this.log ev(EmuInstrEvent, eekCallOpcodeImpl).withIt do:
    it.value = evalue(INSTR.opcode, size)
    it.instr = INSTR

  this.exec.instrfuncs[opcode](this)
  this.log evEnd()

  return true

func `+=`*(i: var int, other: U8 | U16 | U32) = i += int(other)

proc calcModrm16*(this: var ExecInstr): U32 =
  # 8-bit or 8-bit displacement immediately following the operand.
  this.logger.scope "Calculate 16-bit MODRM value"
  var res: int
  case this.getModRmMod():
    of modDispByte: res += this.disp8
    of modDispDWord: res += this.disp16
    else: discard

  # MODRM encoding for indirect adressing does fall into the same pattern
  # as regular register adressing, and instead uses `BX/SI/DI/BP`
  # registers. For table source seee 2.1.5 "instruction format" section in
  # the intel manual, table 2-1
  case this.getModRmRM():
    of 0b000: res += CPU[BX] + CPU[SI]
    of 0b001: res += CPU[BX] + CPU[DI]
    of 0b010: res += CPU[BP] + CPU[SI]
    of 0b011: res += CPU[BP] + CPU[DI]
    of 0b100: res += CPU[DI]
    of 0b101: res += CPU[SI]
    of 0b110:
      if this.getModRmMod() == modIndSib:
        res += this.disp16
    of 0b111: res += CPU[BX]
    else: discard

  return res.U32

proc calcSib*(this: var ExecInstr): U32 =
  ## Calculate value of the scaled index byte. Refer to manual section
  ## 2.1.5, table 2-3 for elaboration on the calculation logic.
  this.logger.scope "Calculate SIB value"
  case this.getModRmMod():
    of modIndSib: result += this.disp32.U32
    of modDispByte: result += this.disp8.U8 + CPU[EBP]
    of modDispDWord: result += this.disp32.U32 + CPU[EBP]
    else: discard

  if not(this.base == 0b101 and this.getModRmMod() == modIndSib):
    result += CPU[Reg32T(this.index)] * U32(1 shl this.scale)

proc calcModrm32*(this: var ExecInstr): U32 =
  this.logger.scope "Calculate 32-bit MODRM value"
  var res: int # Intermediate values can be negative, so using `int` here
  case this.getModRmMod():
    of modDispByte: res += this.disp8.U32
    of modDispDWord: res += this.disp32.U32
    else: discard

  # Intel manual, section 2.1.5, table 2-2
  case this.getModRmRM():
    of 0b000: res += CPU[EAX]
    of 0b001: res += CPU[ECX]
    of 0b010: res += CPU[EDX]
    of 0b011: res += CPU[EBX]
    of 0b100: res += this.calcSib()
    of 0b101:
      if this.getModRmMod() == modIndSib:
        res += this.disp32
    of 0b110: res += CPU[ESI]
    of 0b111: res += CPU[EDI]
    else: discard

  return res.U32


proc calcModrm*(this: var ExecInstr): U32 =
  ## Calculate memory address for current instructin's operand using parsed
  ## MODRM byte value. NOTE: Current instruction must not use register
  ## addressing `mod=11`
  assert(this.getModRmMod() != modRegAddr)
  let is32 = this.isMode32() xor this.idata.addrSizeOverride
  this.logger.scope("Calc modrm " & tern(is32, "32", "16"))
  this.idata.segment = DS
  if is32:
    return this.calcModrm32()

  else:
    return this.calcModrm16()
  
proc setRm32*(this: var ExecInstr, value: U32): void =
  ## Set 32-bit value into location designated by current MODRM config.
  if this.getModRmMod() == modRegAddr:
    CPU.setGPreg(Reg32T(this.getModRmRM()), value)
  
  else:
    WRITEMEM32(this.calcModrm(), value)

proc getRm32*(this: var ExecInstr): U32 =
  if this.getModRmMod() == modRegAddr:
    return CPU.getGPreg(Reg32T(this.getModRmRM()))
  
  else:
    return READMEM32(this.calcModrm())


proc setR32*(this: var ExecInstr, value: U32): void =
  CPU.setGPreg(Reg32T(this.getModrmReg()), value)

proc getR32*(this: var ExecInstr): U32 =
  return CPU.getGPreg(Reg32T(this.getModrmReg()))

proc setMoffs32*(this: var ExecInstr, value: U32): void =
  this.idata.segment = DS
  WRITEMEM32(this.moffs, value)

proc getMoffs32*(this: var ExecInstr): U32 =
  this.idata.segment = DS
  return READMEM32(this.moffs)

proc setRm16*(this: var ExecInstr, value: U16): void =
  if this.getModRmMod() == modRegAddr:
    CPU.setGPreg(Reg16T(this.getModRmRM()), value)
  
  else:
    WRITEMEM16(this.calcModrm(), value)
  

proc getRm16*(this: var ExecInstr): U16 =
  if this.getModRmMod() == modRegAddr:
    return CPU.getGPreg(Reg16T(this.getModRmRM()))
  
  else:
    return READMEM16(this.calcModrm())
  

proc setR16*(this: var ExecInstr, value: U16): void =
  CPU.setGPreg(Reg16T(this.getModrmReg()), value)

proc getR16*(this: var ExecInstr): U16 =
  return CPU.getGPreg(Reg16T(this.getModrmReg()))

proc setMoffs16*(this: var ExecInstr, value: U16): void =
  this.idata.segment = DS
  WRITEMEM16(this.moffs, value)

proc getMoffs16*(this: var ExecInstr): U16 =
  this.idata.segment = DS
  return READMEM16(this.moffs)

proc setRm8*(this: var ExecInstr, value: U8): void =
  if this.getModRmMod() == modRegAddr:
    CPU.setGPreg(Reg8T(this.getModRmRM()), value)
  
  else:
    writeMem8(this, this.calcModrm(), value)
  

proc getRm8*(this: var ExecInstr): U8 =
  if this.getModRmMod() == modRegAddr:
    return CPU.getGPreg(Reg8T(this.getModRmRM()))
  
  else:
    return READMEM8(this.calcModrm())
  

proc setR8*(this: var ExecInstr, value: U8): void =
  CPU.setGPreg(Reg8T(this.getModrmReg()), value)

proc setMoffs8*(this: var ExecInstr, value: U8): void =
  this.idata.segment = DS
  writeMem8(this, this.moffs, value)

proc getMoffs8*(this: var ExecInstr): U8 =
  this.idata.segment = DS
  return READMEM8(this.moffs)

proc getR8*(this: var ExecInstr): U8 =
  return CPU.getGPreg(Reg8T(this.getModrmReg()))

proc getM*(this: var ExecInstr): U32 =
  return this.calcModrm()

proc setSreg*(this: var ExecInstr, value: U16): void =
  EMU.accs.setSegment(SgRegT(this.getModrmReg()), value)

proc getSreg*(this: var ExecInstr): U16 =
  return EMU.accs.getSegment(SgRegT(this.getModrmReg()))

proc setCrn*(this: var ExecInstr, value: U32): void =
  INFO(2, "set CR%d = %x", REG, value)
  EMU.accs.cpu.setCrn(this.getModrmReg().U8(), value)

proc getCrn*(this: var ExecInstr): U32 =
  return CPU.getCrn(this.getModrmReg())
