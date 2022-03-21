import instruction/instructionhpp
import hardware/[processorhpp, crhpp]
import emulator/accesshpp
import commonhpp

proc exec*(this: var ExecInstr): bool = 
  var opcode: uint16 = OPCODE
  if opcode shr 8 == 0x0f:
    opcode = (opcode and 0xff) or 0x0100
  
  
  if this.instrfuncs[opcode].isNil():
    ERROR("not implemented OPCODE 0x%02x", OPCODE)
    return false

  this.instrfuncs[opcode]()
  return true

proc calc_modrm16*(this: var ExecInstr): uint32 =
  var `addr`: uint32 = 0
  case MOD:
    of 1: `addr` = (`addr` + DISP8.uint32)
    of 2: `addr` = (`addr` + DISP16.uint32)
    else: assert false
  case RM:
    of 0, 1, 7:
      `addr` = (`addr` + GET_GPREG(BX))
    of 2, 3, 6:
      if MOD == 0 and RM == 6:
        `addr` = (`addr` + DISP16.uint32)

      else:
        `addr` = (`addr` + GET_GPREG(BP))
        SEGMENT = SS

    else:
      assert false

  if RM < 6:
    if toBool(RM mod 2):
      `addr` = (`addr` + GET_GPREG(DI))

    else:
      `addr` = (`addr` + GET_GPREG(SI))


  return `addr`

proc calc_sib*(this: var ExecInstr): uint32 =
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
      base = GET_GPREG(cast[reg32_t](BASE))


  return base + GET_GPREG(cast[reg32_t](INDEX)) * (1 shl SCALE).uint32


proc calc_modrm32*(this: var ExecInstr): uint32 =
  var `addr`: uint32 = 0
  case MOD:
    of 1: `addr` = (`addr` + DISP8.uint32)
    of 2: `addr` = (`addr` + DISP32.uint32)
    else: assert false
  case RM:
    of 4:
      `addr` = (`addr` + this.calc_sib())
    of 5:
      if MOD == 0:
        `addr` = (`addr` + DISP32.uint32)

    else:
      SEGMENT = (if (RM == 5): SS else: DS)
      `addr` = (`addr` + GET_GPREG(cast[reg32_t](RM)))

  return `addr`


proc calc_modrm*(this: var ExecInstr): uint32 =
  ASSERT(MOD != 3)
  SEGMENT = DS
  if this.is_mode32() xor this.chsz_ad:
    return this.calc_modrm32()

  else:
    return this.calc_modrm16()
  
proc set_rm32*(this: var ExecInstr, value: uint32): void = 
  if MOD == 3:
    SET_GPREG(cast[reg32_t](RM), value)
  
  else:
    WRITE_MEM32(this.calc_modrm(), value)
  

proc get_rm32*(this: var ExecInstr): uint32 = 
  if MOD == 3:
    return GET_GPREG(cast[reg32_t](RM))
  
  else:
    return READ_MEM32(this.calc_modrm())
  

proc set_r32*(this: var ExecInstr, value: uint32): void = 
  SET_GPREG(cast[reg32_t](REG), value)

proc get_r32*(this: var ExecInstr): uint32 = 
  return GET_GPREG(cast[reg32_t](REG))

proc set_moffs32*(this: var ExecInstr, value: uint32): void = 
  SEGMENT = DS
  WRITE_MEM32(MOFFS, value)

proc get_moffs32*(this: var ExecInstr): uint32 = 
  SEGMENT = DS
  return READ_MEM32(MOFFS)

proc set_rm16*(this: var ExecInstr, value: uint16): void = 
  if MOD == 3:
    SET_GPREG(cast[reg16_t](RM), value)
  
  else:
    WRITE_MEM16(this.calc_modrm(), value)
  

proc get_rm16*(this: var ExecInstr): uint16 = 
  if MOD == 3:
    return GET_GPREG(cast[reg16_t](RM))
  
  else:
    return READ_MEM16(this.calc_modrm())
  

proc set_r16*(this: var ExecInstr, value: uint16): void = 
  SET_GPREG(cast[reg16_t](REG), value)

proc get_r16*(this: var ExecInstr): uint16 = 
  return GET_GPREG(cast[reg16_t](REG))

proc set_moffs16*(this: var ExecInstr, value: uint16): void = 
  SEGMENT = DS
  WRITE_MEM16(MOFFS, value)

proc get_moffs16*(this: var ExecInstr): uint16 = 
  SEGMENT = DS
  return READ_MEM16(MOFFS)

proc set_rm8*(this: var ExecInstr, value: uint8): void = 
  if MOD == 3:
    SET_GPREG(cast[reg8_t](RM), value)
  
  else:
    WRITE_MEM8(this.calc_modrm(), value)
  

proc get_rm8*(this: var ExecInstr): uint8 = 
  if MOD == 3:
    return GET_GPREG(cast[reg8_t](RM))
  
  else:
    return READ_MEM8(this.calc_modrm())
  

proc set_r8*(this: var ExecInstr, value: uint8): void = 
  SET_GPREG(cast[reg8_t](REG), value)

proc set_moffs8*(this: var ExecInstr, value: uint8): void = 
  SEGMENT = DS
  WRITE_MEM8(MOFFS, value)

proc get_moffs8*(this: var ExecInstr): uint8 = 
  SEGMENT = DS
  return READ_MEM8(MOFFS)

proc get_r8*(this: var ExecInstr): uint8 = 
  return GET_GPREG(cast[reg8_t](REG))

proc get_m*(this: var ExecInstr): uint32 = 
  return this.calc_modrm()

proc set_sreg*(this: var ExecInstr, value: uint16): void = 
  EMU.accs.set_segment(cast[sgreg_t](REG), value)

proc get_sreg*(this: var ExecInstr): uint16 = 
  return EMU.accs.get_segment(cast[sgreg_t](REG))

proc set_crn*(this: var ExecInstr, value: uint32): void = 
  INFO(2, "set CR%d = %x", REG, value)
  EMU.accs.cpu.set_crn(REG, value)

proc get_crn*(this: var ExecInstr): uint32 = 
  return CPU.get_crn(REG)
