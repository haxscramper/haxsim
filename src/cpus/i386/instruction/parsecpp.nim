import instruction/instructionhpp
import commonhpp
import emulator/[accesshpp, emulatorhpp]
import hardware/processorhpp

proc get_emu*(this: var InstrImpl): ptr Emulator =
  this.exec.get_emu()

template PRE_SEGMENT*(): untyped {.dirty.} =
  (this.exec.instr.pre_segment)

template PRE_REPEAT*(): untyped {.dirty.} =
  (this.exec.instr.pre_repeat)

template OPCODE*(): untyped {.dirty.} =
  (this.exec.instr.opcode)

template MOD*(): untyped {.dirty.} =
  (this.exec.instr[].modrm.`mod`)

template RM*(): untyped {.dirty.} =
  (this.exec.instr[].modrm.rm)

template BASE*(): untyped {.dirty.} =
  (this.exec.instr[].sib.base)

template DISP32*(): untyped {.dirty.} =
  (this.exec.instr[].disp32)

template INSTR(): untyped = this.exec.instr[]

proc parse_prefix*(this: var InstrImpl): uint8 =
  var chsz, code: uint8 = 0
  while (true):
    code = ACS.get_code8(0)
    case code:
      of 0x26:
        PRE_SEGMENT = ES
        {.warning: "[FIXME] 'cxx_goto set_pre'".}
      of 0x2e:
        PRE_SEGMENT = CS
        {.warning: "[FIXME] 'cxx_goto set_pre'".}
      of 0x36:
        PRE_SEGMENT = SS
        {.warning: "[FIXME] 'cxx_goto set_pre'".}
      of 0x3e:
        PRE_SEGMENT = DS
        {.warning: "[FIXME] 'cxx_goto set_pre'".}
      of 0x64:
        PRE_SEGMENT = FS
        {.warning: "[FIXME] 'cxx_goto set_pre'".}
      of 0x65:
        PRE_SEGMENT = GS
        {.warning: "[FIXME] 'cxx_goto set_pre'".}
      of 0x66:
        chsz = (chsz or CHSZ_OP)
        {.warning: "[FIXME] 'cxx_goto next'".}
      of 0x67:
        chsz = (chsz or CHSZ_AD)
        {.warning: "[FIXME] 'cxx_goto next'".}
      of 0xf2:
        PRE_REPEAT = REPNZ
        {.warning: "[FIXME] 'cxx_goto next'".}
      of 0xf3:
        PRE_REPEAT = REPZ
        {.warning: "[FIXME] 'cxx_goto next'".}
      else:
        return chsz
        block set_pre:
          PREFIX = code
        block next:
          discard UPDATE_EIP(1)

proc parse_opcode*(this: var InstrImpl): void =
  OPCODE = ACS.get_code8(0)
  discard UPDATE_EIP(1)
  
  if OPCODE == 0x0f:
    OPCODE = (OPCODE shl 8) + ACS.get_code8(0)
    discard UPDATE_EIP(1)
  
  if CPU.is_mode32():
    DEBUG_MSG(5, "CS:%04x EIP:0x%04x opcode:%02x ", EMU.get_segment(CS), GET_EIP() - 1, OPCODE)
  
  else:
    DEBUG_MSG(5, "CS:%04x  IP:0x%04x opcode:%02x ", EMU.get_segment(CS), GET_IP() - 1, OPCODE)
  

proc parse_modrm32*(this: var InstrImpl): void =
  if MOD != 3 and RM == 4:
    INSTR.dSIB = ACS.get_code8(0)
    discard UPDATE_EIP(1)
    DEBUG_MSG(5, "[scale:0x%02x index:0x%02x base:0x%02x] ", SCALE, INDEX, BASE)
  
  if MOD == 2 or (MOD == 0 and RM == 5) or (MOD == 0 and BASE == 5):
    INSTR.disp32 = ACS.get_code32(0).int32()
    discard UPDATE_EIP(4)
    DEBUG_MSG(5, "disp32:0x%08x ", DISP32)
  
  else:
    if MOD == 1:
      INSTR.disp8 = cast[int8](ACS.get_code8(0))
      discard UPDATE_EIP(1)
      DEBUG_MSG(5, "disp8:0x%02x ", DISP8)
    
  

proc parse_modrm16*(this: var InstrImpl): void =
  if (MOD == 0 and RM == 6) or MOD == 2:
    INSTR.disp16 = ACS.get_code32(0).int16()
    discard UPDATE_EIP(2)
    DEBUG_MSG(5, "disp16:0x%04x ", DISP16)
  
  else:
    if MOD == 1:
      INSTR.disp8 = cast[int8](ACS.get_code8(0))
      discard UPDATE_EIP(1)
      DEBUG_MSG(5, "disp8:0x%02x ", DISP8)
    

proc parse_modrm_sib_disp*(this: var InstrImpl): void =
  INSTR.dmodrm = ACS.get_code8(0)
  discard UPDATE_EIP(1)
  DEBUG_MSG(5, "[mod:0x%02x reg:0x%02x rm:0x%02x] ", MOD, REG, RM)
  if CPU.is_mode32() xor this.exec.chsz_ad:
    this.parse_modrm32()

  else:
    this.parse_modrm16()

  

proc parse_moffs*(this: var InstrImpl): void =
  if CPU.is_mode32() xor this.exec.chsz_ad:
    INSTR.moffs = ACS.get_code32(0)
    discard UPDATE_EIP(4)
  
  else:
    INSTR.moffs = ACS.get_code16(0)
    discard UPDATE_EIP(2)
  
  DEBUG_MSG(5, "moffs:0x%04x ", MOFFS)

proc parse*(this: var InstrImpl): void =
  var opcode: uint16
  this.parse_opcode()
  opcode = OPCODE
  if opcode shr 8 == 0x0f:
    opcode = (opcode and 0xff) or 0x0100


  if this.parse.chk[opcode].modrm.toBool():
    this.parse_modrm_sib_disp()

  if this.parse.chk[opcode].imm32.toBool():
    INSTR.imm32 = ACS.get_code32(0).int32()
    DEBUG_MSG(5, "imm32:0x%08x ", IMM32)
    discard UPDATE_EIP(4)

  else:
    if this.parse.chk[opcode].imm16.toBool():
      INSTR.imm16 = ACS.get_code16(0).int16()
      DEBUG_MSG(5, "imm16:0x%04x ", IMM16)
      discard UPDATE_EIP(2)

    else:
      if this.parse.chk[opcode].imm8.toBool():
        INSTR.imm8 = cast[int8](ACS.get_code8(0))
        DEBUG_MSG(5, "imm8:0x%02x ", IMM8)
        discard UPDATE_EIP(1)



  if this.parse.chk[opcode].ptr16.toBool():
    PTR16 = ACS.get_code16(0).int8()
    DEBUG_MSG(5, "ptr16:0x%04x", PTR16)
    discard UPDATE_EIP(2)

  if this.parse.chk[opcode].moffs.toBool():
    this.parse_moffs()

  DEBUG_MSG(5, "\\n")
