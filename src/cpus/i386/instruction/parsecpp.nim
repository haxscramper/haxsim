import
  map
import
  instruction/instructionhpp
proc parse_prefix*(this: var ParseInstr): uint8 = 
  var chsz: uint8 = 0
  while (true):
    code = get_emu().get_code8(0)
    case code:
      of 0x26:
        PRE_SEGMENT = ES
        cxx_goto set_pre
      of 0x2e:
        PRE_SEGMENT = CS
        cxx_goto set_pre
      of 0x36:
        PRE_SEGMENT = SS
        cxx_goto set_pre
      of 0x3e:
        PRE_SEGMENT = DS
        cxx_goto set_pre
      of 0x64:
        PRE_SEGMENT = FS
        cxx_goto set_pre
      of 0x65:
        PRE_SEGMENT = GS
        cxx_goto set_pre
      of 0x66:
        chsz = (chsz or CHSZ_OP)
        cxx_goto next
      of 0x67:
        chsz = (chsz or CHSZ_AD)
        cxx_goto next
      of 0xf2:
        PRE_REPEAT = REPNZ
        cxx_goto next
      of 0xf3:
        PRE_REPEAT = REPZ
        cxx_goto next
      else:
        return chsz
        block set_pre:
          PREFIX = code
        block next:
          UPDATE_EIP(1)

proc parse*(this: var ParseInstr): void = 
  var opcode: uint16
  parse_opcode()
  opcode = OPCODE
  if opcode shr 8 == 0x0f:
    opcode = (opcode and 0xff) or 0x0100
  
  
  if chk[opcode].modrm:
    parse_modrm_sib_disp()
  
  if chk[opcode].imm32:
    IMM32 = get_emu().get_code32(0)
    DEBUG_MSG(5, "imm32:0x%08x ", IMM32)
    UPDATE_EIP(4)
  
  else:
    if chk[opcode].imm16:
      IMM16 = get_emu().get_code16(0)
      DEBUG_MSG(5, "imm16:0x%04x ", IMM16)
      UPDATE_EIP(2)
    
    else:
      if chk[opcode].imm8:
        IMM8 = cast[int8](get_emu().get_code8(0))
        DEBUG_MSG(5, "imm8:0x%02x ", IMM8)
        UPDATE_EIP(1)
      
    
  
  if chk[opcode].ptr16:
    PTR16 = get_emu().get_code16(0)
    DEBUG_MSG(5, "ptr16:0x%04x", PTR16)
    UPDATE_EIP(2)
  
  if chk[opcode].moffs:
    parse_moffs()
  
  DEBUG_MSG(5, "\\n")

proc parse_opcode*(this: var ParseInstr): void = 
  OPCODE = get_emu().get_code8(0)
  UPDATE_EIP(1)
  
  if OPCODE == 0x0f:
    OPCODE = (OPCODE shl 8) + get_emu().get_code8(0)
    UPDATE_EIP(1)
  
  if is_mode32():
    DEBUG_MSG(5, "CS:%04x EIP:0x%04x opcode:%02x ", EMU.get_segment(CS), GET_EIP() - 1, OPCODE)
  
  else:
    DEBUG_MSG(5, "CS:%04x  IP:0x%04x opcode:%02x ", EMU.get_segment(CS), GET_IP() - 1, OPCODE)
  

proc parse_modrm_sib_disp*(this: var ParseInstr): void = 
  _MODRM = get_emu().get_code8(0)
  UPDATE_EIP(1)
  DEBUG_MSG(5, "[mod:0x%02x reg:0x%02x rm:0x%02x] ", MOD, REG, RM)
  if is_mode32() xor chsz_ad:
    parse_modrm32()
  
  else:
    parse_modrm16()
  

proc parse_modrm32*(this: var ParseInstr): void = 
  if MOD != 3 and RM == 4:
    _SIB = get_emu().get_code8(0)
    UPDATE_EIP(1)
    DEBUG_MSG(5, "[scale:0x%02x index:0x%02x base:0x%02x] ", SCALE, INDEX, BASE)
  
  if MOD == 2 or (MOD == 0 and RM == 5) or (MOD == 0 and BASE == 5):
    DISP32 = get_emu().get_code32(0)
    UPDATE_EIP(4)
    DEBUG_MSG(5, "disp32:0x%08x ", DISP32)
  
  else:
    if MOD == 1:
      DISP8 = cast[int8](get_emu().get_code8(0))
      UPDATE_EIP(1)
      DEBUG_MSG(5, "disp8:0x%02x ", DISP8)
    
  

proc parse_modrm16*(this: var ParseInstr): void = 
  if (MOD == 0 and RM == 6) or MOD == 2:
    DISP16 = get_emu().get_code32(0)
    UPDATE_EIP(2)
    DEBUG_MSG(5, "disp16:0x%04x ", DISP16)
  
  else:
    if MOD == 1:
      DISP8 = cast[int8](get_emu().get_code8(0))
      UPDATE_EIP(1)
      DEBUG_MSG(5, "disp8:0x%02x ", DISP8)
    
  

proc parse_moffs*(this: var ParseInstr): void = 
  if is_mode32() xor chsz_ad:
    MOFFS = get_emu().get_code32(0)
    UPDATE_EIP(4)
  
  else:
    MOFFS = get_emu().get_code16(0)
    UPDATE_EIP(2)
  
  DEBUG_MSG(5, "moffs:0x%04x ", MOFFS)
