import instruction/instructionhpp
import hardware/[processorhpp, crhpp]
import emulator/accesshpp
import commonhpp

template INSTR(): untyped = this.exec.instr

proc exec*(this: var InstrImpl): bool =
  var opcode: uint16 = INSTR.opcode
  if opcode shr 8 == 0x0f:
    opcode = (opcode and 0xff) or 0x0100
  
  
  if this.exec.instrfuncs[opcode].isNil():
    assert(false, "not implemented OPCODE " & pstring(INSTR.opcodeData))
    return false

  this.log ev(eekCallOpcodeImpl)
  this.exec.instrfuncs[opcode](this)
  this.log ev(eekCallOpcodeEnd)

  return true

proc calcModrm16*(this: var ExecInstr): uint32 =
  var memAddr: uint32 = 0
  case MOD:
    of 1: memAddr = (memAddr + DISP8.uint32)
    of 2: memAddr = (memAddr + DISP16.uint32)
    else: assert false
  case RM:
    of 0, 1, 7:
      memAddr = (memAddr + GETGPREG(BX))
    of 2, 3, 6:
      if MOD == 0 and RM == 6:
        memAddr = (memAddr + DISP16.uint32)

      else:
        memAddr = (memAddr + GETGPREG(BP))
        SEGMENT = SS

    else:
      assert false

  if RM < 6:
    if toBool(RM mod 2):
      memAddr = (memAddr + GETGPREG(DI))

    else:
      memAddr = (memAddr + GETGPREG(SI))


  return memAddr

proc calcSib*(this: var ExecInstr): uint32 =
  var base: uint32
  if BASE == 5 and MOD == 0:
    base = DISP32.uint32

  else:
    if BASE == 4:
      if SCALE == 0:
        SEGMENT = SS
        base = 0

      else:
        ERROR("not implemented SIB (base = %d, index = %d, scale = %d)\\n", BASE, INDEX, SCALE)


    else:
      SEGMENT = (if (RM == 5):
            SS

          else:
            DS
          )
      base = GETGPREG(cast[Reg32T](BASE))


  return base + GETGPREG(cast[Reg32T](INDEX)) * (1 shl SCALE).uint32


proc calcModrm32*(this: var ExecInstr): uint32 =
  var memAddr: uint32 = 0
  case MOD:
    of 1: memAddr = (memAddr + DISP8.uint32)
    of 2: memAddr = (memAddr + DISP32.uint32)
    else: assert false
  case RM:
    of 4:
      memAddr = (memAddr + this.calcSib())
    of 5:
      if MOD == 0:
        memAddr = (memAddr + DISP32.uint32)

    else:
      SEGMENT = (if (RM == 5): SS else: DS)
      memAddr = (memAddr + GETGPREG(cast[Reg32T](RM)))

  return memAddr


proc calcModrm*(this: var ExecInstr): uint32 =
  ASSERT(MOD != 3)
  SEGMENT = DS
  if this.isMode32() xor this.chszAd:
    return this.calcModrm32()

  else:
    return this.calcModrm16()
  
proc setRm32*(this: var ExecInstr, value: uint32): void =
  if MOD == 3:
    SETGPREG(cast[Reg32T](RM), value)
  
  else:
    WRITEMEM32(this.calcModrm(), value)


proc getRm32*(this: var ExecInstr): uint32 =
  if MOD == 3:
    return GETGPREG(cast[Reg32T](RM))
  
  else:
    return READMEM32(this.calcModrm())


proc setR32*(this: var ExecInstr, value: uint32): void =
  SETGPREG(cast[Reg32T](REG), value)

proc getR32*(this: var ExecInstr): uint32 =
  return GETGPREG(cast[Reg32T](REG))

proc setMoffs32*(this: var ExecInstr, value: uint32): void =
  SEGMENT = DS
  WRITEMEM32(MOFFS, value)

proc getMoffs32*(this: var ExecInstr): uint32 =
  SEGMENT = DS
  return READMEM32(MOFFS)

proc setRm16*(this: var ExecInstr, value: uint16): void =
  if MOD == 3:
    SETGPREG(cast[Reg16T](RM), value)
  
  else:
    WRITEMEM16(this.calcModrm(), value)
  

proc getRm16*(this: var ExecInstr): uint16 =
  if MOD == 3:
    return GETGPREG(cast[Reg16T](RM))
  
  else:
    return READMEM16(this.calcModrm())
  

proc setR16*(this: var ExecInstr, value: uint16): void =
  SETGPREG(cast[Reg16T](REG), value)

proc getR16*(this: var ExecInstr): uint16 =
  return GETGPREG(cast[Reg16T](REG))

proc setMoffs16*(this: var ExecInstr, value: uint16): void =
  SEGMENT = DS
  WRITEMEM16(MOFFS, value)

proc getMoffs16*(this: var ExecInstr): uint16 =
  SEGMENT = DS
  return READMEM16(MOFFS)

proc setRm8*(this: var ExecInstr, value: uint8): void =
  if MOD == 3:
    SETGPREG(cast[Reg8T](RM), value)
  
  else:
    WRITEMEM8(this.calcModrm(), value)
  

proc getRm8*(this: var ExecInstr): uint8 =
  echov MOD
  if MOD == 3:
    return GETGPREG(cast[Reg8T](RM))
  
  else:
    return READMEM8(this.calcModrm())
  

proc setR8*(this: var ExecInstr, value: uint8): void =
  SETGPREG(cast[Reg8T](REG), value)

proc setMoffs8*(this: var ExecInstr, value: uint8): void =
  SEGMENT = DS
  WRITEMEM8(MOFFS, value)

proc getMoffs8*(this: var ExecInstr): uint8 =
  SEGMENT = DS
  return READMEM8(MOFFS)

proc getR8*(this: var ExecInstr): uint8 =
  return GETGPREG(cast[Reg8T](REG))

proc getM*(this: var ExecInstr): uint32 =
  return this.calcModrm()

proc setSreg*(this: var ExecInstr, value: uint16): void =
  EMU.accs.setSegment(cast[SgRegT](REG), value)

proc getSreg*(this: var ExecInstr): uint16 =
  return EMU.accs.getSegment(cast[SgRegT](REG))

proc setCrn*(this: var ExecInstr, value: uint32): void =
  INFO(2, "set CR%d = %x", REG, value)
  EMU.accs.cpu.setCrn(REG, value)

proc getCrn*(this: var ExecInstr): uint32 =
  return CPU.getCrn(REG)
