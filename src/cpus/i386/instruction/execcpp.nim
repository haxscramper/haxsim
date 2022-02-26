import
  instruction/instructionhpp
proc exec*(this: var ExecInstr): bool = 
  var opcode: uint16 = OPCODE
  if opcode shr 8 == 0x0f:
    opcode = (opcode and 0xff) or 0x0100
  
  
  if not(instrfuncs[opcode]):
    ERROR("not implemented OPCODE 0x%02x", OPCODE)
    return false
  
  (this.CXX_SYNTAX_ERROR("*")[opcode])()
  return true

proc set_rm32*(this: var ExecInstr, value: uint32): void = 
  if MOD == 3:
    SET_GPREG(static_cast[reg32_t](RM), value)
  
  else:
    WRITE_MEM32(calc_modrm(), value)
  

proc get_rm32*(this: var ExecInstr): uint32 = 
  if MOD == 3:
    return GET_GPREG(static_cast[reg32_t](RM))
  
  else:
    return READ_MEM32(calc_modrm())
  

proc set_r32*(this: var ExecInstr, value: uint32): void = 
  SET_GPREG(static_cast[reg32_t](REG), value)

proc get_r32*(this: var ExecInstr): uint32 = 
  return GET_GPREG(static_cast[reg32_t](REG))

proc set_moffs32*(this: var ExecInstr, value: uint32): void = 
  SEGMENT = DS
  return WRITE_MEM32(MOFFS, value)

proc get_moffs32*(this: var ExecInstr): uint32 = 
  SEGMENT = DS
  return READ_MEM32(MOFFS)

proc set_rm16*(this: var ExecInstr, value: uint16): void = 
  if MOD == 3:
    SET_GPREG(static_cast[reg16_t](RM), value)
  
  else:
    WRITE_MEM16(calc_modrm(), value)
  

proc get_rm16*(this: var ExecInstr): uint16 = 
  if MOD == 3:
    return GET_GPREG(static_cast[reg16_t](RM))
  
  else:
    return READ_MEM16(calc_modrm())
  

proc set_r16*(this: var ExecInstr, value: uint16): void = 
  SET_GPREG(static_cast[reg16_t](REG), value)

proc get_r16*(this: var ExecInstr): uint16 = 
  return GET_GPREG(static_cast[reg16_t](REG))

proc set_moffs16*(this: var ExecInstr, value: uint16): void = 
  SEGMENT = DS
  return WRITE_MEM16(MOFFS, value)

proc get_moffs16*(this: var ExecInstr): uint16 = 
  SEGMENT = DS
  return READ_MEM16(MOFFS)

proc set_rm8*(this: var ExecInstr, value: uint8): void = 
  if MOD == 3:
    SET_GPREG(static_cast[reg8_t](RM), value)
  
  else:
    WRITE_MEM8(calc_modrm(), value)
  

proc get_rm8*(this: var ExecInstr): uint8 = 
  if MOD == 3:
    return GET_GPREG(static_cast[reg8_t](RM))
  
  else:
    return READ_MEM8(calc_modrm())
  

proc set_r8*(this: var ExecInstr, value: uint8): void = 
  SET_GPREG(static_cast[reg8_t](REG), value)

proc set_moffs8*(this: var ExecInstr, value: uint8): void = 
  SEGMENT = DS
  return WRITE_MEM8(MOFFS, value)

proc get_moffs8*(this: var ExecInstr): uint8 = 
  SEGMENT = DS
  return READ_MEM8(MOFFS)

proc get_r8*(this: var ExecInstr): uint8 = 
  return GET_GPREG(static_cast[reg8_t](REG))

proc get_m*(this: var ExecInstr): uint32 = 
  return calc_modrm()

proc set_sreg*(this: var ExecInstr, value: uint16): void = 
  EMU.set_segment(static_cast[sgreg_t](REG), value)

proc get_sreg*(this: var ExecInstr): uint16 = 
  return EMU.get_segment(static_cast[sgreg_t](REG))

proc set_crn*(this: var ExecInstr, value: uint32): void = 
  INFO(2, "set CR%d = %x", REG, value)
  EMU.set_crn(REG, value)

proc get_crn*(this: var ExecInstr): uint32 = 
  return EMU.get_crn(REG)

proc calc_modrm*(this: var ExecInstr): uint32 = 
  ASSERT(MOD != 3)
  SEGMENT = DS
  if is_mode32() xor chsz_ad:
    return calc_modrm32()
  
  else:
    return calc_modrm16()
  

proc calc_modrm16*(this: var ExecInstr): uint32 = 
  var `addr`: uint32 = 0
  case MOD:
    of 1:
      `addr` = (`addr` + DISP8)
    of 2:
      `addr` = (`addr` + DISP16)
  case RM:
    of 0, 1, 7:
      `addr` = (`addr` + GET_GPREG(BX))
    of 2, 3, 6:
      if MOD == 0 and RM == 6:
        `addr` = (`addr` + DISP16)
      
      else:
        `addr` = (`addr` + GET_GPREG(BP))
        SEGMENT = SS
      
  if RM < 6:
    if RM mod 2:
      `addr` = (`addr` + GET_GPREG(DI))
    
    else:
      `addr` = (`addr` + GET_GPREG(SI))
    
  
  return `addr`

proc calc_modrm32*(this: var ExecInstr): uint32 = 
  var `addr`: uint32 = 0
  case MOD:
    of 1:
      `addr` = (`addr` + DISP8)
    of 2:
      `addr` = (`addr` + DISP32)
  case RM:
    of 4:
      `addr` = (`addr` + calc_sib())
    of 5:
      if MOD == 0:
        `addr` = (`addr` + DISP32)
        break 
      
    else:
      SEGMENT = (if (RM == 5):
            SS
          
          else:
            DS
          )
      `addr` = (`addr` + GET_GPREG(static_cast[reg32_t](RM)))
  return `addr`

proc calc_sib*(this: var ExecInstr): uint32 = 
  var base: uint32
  if BASE == 5 and MOD == 0:
    base = DISP32
  
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
      base = GET_GPREG(static_cast[reg32_t](BASE))
    
  
  return base + GET_GPREG(static_cast[reg32_t](INDEX)) * (1 shl SCALE)
  
