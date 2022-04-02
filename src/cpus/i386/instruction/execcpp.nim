import instruction/instructionhpp
import hardware/[processorhpp, crhpp]
import emulator/accesshpp
import commonhpp

template INSTR(): untyped = this.exec.instr

proc exec*(this: var InstrImpl): bool =
  var opcode: uint16 = INSTR.opcode
  var size = 8
  if opcode shr 8 == 0x0f:
    opcode = (opcode and 0xff) or 0x0100
    size += 8
  
  
  if this.exec.instrfuncs[opcode].isNil():
    assert(false, "not implemented OPCODE " & pstring(INSTR.opcodeData))
    return false

  this.log ev(EmuInstrEvent, eekCallOpcodeImpl).withIt do:
    it.value = evalue(INSTR.opcode, size)
    it.instr = INSTR

  this.exec.instrfuncs[opcode](this)
  this.log evEnd()

  return true

proc calcModrm16*(this: var ExecInstr): uint32 =
  var memAddr: uint32 = 0
  case this.getModRmMod():
    of 1: memAddr = (memAddr + DISP8.uint32)
    of 2: memAddr = (memAddr + DISP16.uint32)
    else: assert false
  case this.getModRmRM():
    of 0, 1, 7:
      memAddr = (memAddr + CPU.getGPreg(BX))
    of 2, 3, 6:
      if this.getModRmMod() == 0 and this.getModRmRM() == 6:
        memAddr = (memAddr + DISP16.uint32)

      else:
        memAddr = (memAddr + CPU.getGPreg(BP))
        SEGMENT = SS

    else:
      assert false

  if this.getModRmRM() < 6:
    if toBool(this.getModRmRM() mod 2):
      memAddr = (memAddr + CPU.getGPreg(DI))

    else:
      memAddr = (memAddr + CPU.getGPreg(SI))


  return memAddr

proc calcSib*(this: var ExecInstr): uint32 =
  var base: uint32
  if BASE == 5 and this.getModRmMod() == 0:
    base = DISP32.uint32

  else:
    if BASE == 4:
      if SCALE == 0:
        SEGMENT = SS
        base = 0

      else:
        ERROR("not implemented SIB (base = %d, index = %d, scale = %d)\\n", BASE, INDEX, SCALE)


    else:
      SEGMENT = (if (this.getModRmRM() == 5):
            SS

          else:
            DS
          )
      base = CPU.getGPreg(Reg32T(BASE))


  return base + CPU.getGPreg(Reg32T(INDEX)) * (1 shl SCALE).uint32


proc calcModrm32*(this: var ExecInstr): uint32 =
  var memAddr: uint32 = 0
  case this.getModRmMod():
    of 1: memAddr = (memAddr + DISP8.uint32)
    of 2: memAddr = (memAddr + DISP32.uint32)
    else: assert false
  case this.getModRmRM():
    of 4:
      memAddr = (memAddr + this.calcSib())
    of 5:
      if this.getModRmMod() == 0:
        memAddr = (memAddr + DISP32.uint32)

    else:
      SEGMENT = (if (this.getModRmRM() == 5): SS else: DS)
      memAddr = (memAddr + CPU.getGPreg(Reg32T(this.getModRmRM())))

  return memAddr


proc calcModrm*(this: var ExecInstr): uint32 =
  ASSERT(this.getModRmMod() != 3)
  SEGMENT = DS
  if this.isMode32() xor this.chszAd:
    return this.calcModrm32()

  else:
    return this.calcModrm16()
  
proc setRm32*(this: var ExecInstr, value: uint32): void =
  if this.getModRmMod() == 3:
    CPU.setGPreg(Reg32T(this.getModRmRM()), value)
  
  else:
    WRITEMEM32(this.calcModrm(), value)


proc getRm32*(this: var ExecInstr): uint32 =
  if this.getModRmMod() == 3:
    return CPU.getGPreg(Reg32T(this.getModRmRM()))
  
  else:
    return READMEM32(this.calcModrm())


proc setR32*(this: var ExecInstr, value: uint32): void =
  CPU.setGPreg(Reg32T(this.getModrmReg()), value)

proc getR32*(this: var ExecInstr): uint32 =
  return CPU.getGPreg(Reg32T(this.getModrmReg()))

proc setMoffs32*(this: var ExecInstr, value: uint32): void =
  SEGMENT = DS
  WRITEMEM32(MOFFS, value)

proc getMoffs32*(this: var ExecInstr): uint32 =
  SEGMENT = DS
  return READMEM32(MOFFS)

proc setRm16*(this: var ExecInstr, value: uint16): void =
  if this.getModRmMod() == 3:
    CPU.setGPreg(Reg16T(this.getModRmRM()), value)
  
  else:
    WRITEMEM16(this.calcModrm(), value)
  

proc getRm16*(this: var ExecInstr): uint16 =
  if this.getModRmMod() == 3:
    return CPU.getGPreg(Reg16T(this.getModRmRM()))
  
  else:
    return READMEM16(this.calcModrm())
  

proc setR16*(this: var ExecInstr, value: uint16): void =
  CPU.setGPreg(Reg16T(this.getModrmReg()), value)

proc getR16*(this: var ExecInstr): uint16 =
  return CPU.getGPreg(Reg16T(this.getModrmReg()))

proc setMoffs16*(this: var ExecInstr, value: uint16): void =
  SEGMENT = DS
  WRITEMEM16(MOFFS, value)

proc getMoffs16*(this: var ExecInstr): uint16 =
  SEGMENT = DS
  return READMEM16(MOFFS)

proc setRm8*(this: var ExecInstr, value: uint8): void =
  if this.getModRmMod() == 3:
    CPU.setGPreg(Reg8T(this.getModRmRM()), value)
  
  else:
    WRITEMEM8(this.calcModrm(), value)
  

proc getRm8*(this: var ExecInstr): uint8 =
  if this.getModRmMod() == 3:
    return CPU.getGPreg(Reg8T(this.getModRmRM()))
  
  else:
    return READMEM8(this.calcModrm())
  

proc setR8*(this: var ExecInstr, value: uint8): void =
  CPU.setGPreg(Reg8T(this.getModrmReg()), value)

proc setMoffs8*(this: var ExecInstr, value: uint8): void =
  SEGMENT = DS
  WRITEMEM8(MOFFS, value)

proc getMoffs8*(this: var ExecInstr): uint8 =
  SEGMENT = DS
  return READMEM8(MOFFS)

proc getR8*(this: var ExecInstr): uint8 =
  return CPU.getGPreg(Reg8T(this.getModrmReg()))

proc getM*(this: var ExecInstr): uint32 =
  return this.calcModrm()

proc setSreg*(this: var ExecInstr, value: uint16): void =
  EMU.accs.setSegment(cast[SgRegT](this.getModrmReg()), value)

proc getSreg*(this: var ExecInstr): uint16 =
  return EMU.accs.getSegment(cast[SgRegT](this.getModrmReg()))

proc setCrn*(this: var ExecInstr, value: uint32): void =
  INFO(2, "set CR%d = %x", REG, value)
  EMU.accs.cpu.setCrn(this.getModrmReg().uint8(), value)

proc getCrn*(this: var ExecInstr): uint32 =
  return CPU.getCrn(this.getModrmReg())
