import instruction/instruction
import common
import emulator/[access, emulator]
import hardware/processor

proc getEmu*(this: var InstrImpl): Emulator =
  result = this.exec.getEmu()
  assertRef(result)

proc parsePrefix*(this: var InstrImpl): uint8 =
  var chsz, code: uint8 = 0
  while (true):
    code = this.getEmu().accs.getCode8(0)
    var setPre = false
    case code:
      of 0x26: this.idata.preSegment = ES ; setPre = true
      of 0x2e: this.idata.preSegment = CS ; setPre = true
      of 0x36: this.idata.preSegment = SS ; setPre = true
      of 0x3e: this.idata.preSegment = DS ; setPre = true
      of 0x64: this.idata.preSegment = FS ; setPre = true
      of 0x65: this.idata.preSegment = GS ; setPre = true
      of 0x66: chsz = (chsz or CHSZOP)
      of 0x67: chsz = (chsz or CHSZAD)
      of 0xf2: this.idata.preRepeat = REPNZ
      of 0xf3: this.idata.preRepeat = REPZ
      else: return chsz

    if setPre:
      this.idata.prefix = code

    CPU.updateEIp(1)

proc parseOpcode*(this: var InstrImpl): void =
  this.idata.opcode = ACS.getCode8(0)
  CPU.updateEIp(1)
  
  if this.idata.opcode == 0x0f:
    this.idata.opcode = (this.idata.opcode shl 8) + ACS.getCode8(0)
    CPU.updateEIp(1)
  


proc parseModrm32*(this: var InstrImpl): void =
  if this.mod != modRegAddr and this.rm == 4:
    this.idata.dSIB = ACS.getCode8(0)
    CPU.updateEIp(1)

  if # If doubleword displacement explicitly follows addressing byte
     this.mod == modDispDWord or
     # indirect SIB with no displacement
    (this.mod == modIndSib and this.rm == 5) or
     # displacement with only addressing mode
    (this.mod == modIndSib and this.base == 5):

    this.idata.disp32 = ACS.getCode32(0).int32()
    CPU.updateEIp(4)

  elif this.mod == modDispByte:
    # Byte displacement
    this.idata.disp8 = ACS.getCode8(0).int8
    CPU.updateEIp(1)


proc parseModrm16*(this: var InstrImpl): void =
  if # Indirect SIB with no displacement.
     #
     # FIXME - `rm` should be `== 5`?
     # http://www.c-jump.com/CIS77/CPU/x86/lecture.html#X77_0060_mod_reg_r_m_byte
    (this.mod == modIndSib and this.rm == 6) or
     # Doubleword displacement
     this.mod == modDispDWord:

    this.idata.disp16 = ACS.getCode32(0).int16()
    CPU.updateEIp(2)

  elif this.mod == modDispByte:
    # Byte signed displacement
    this.idata.disp8 = ACS.getCode8(0).int8
    CPU.updateEIp(1)

proc parseModrmSibDisp*(this: var InstrImpl): void =
  ## Parse MODRM byte and potential subsequent SIB and displacement bytes
  this.idata.modrm = cast[ModRM](ACS.getCode8(0))
  CPU.updateEIp(1)
  if CPU.isMode32() xor this.exec.chszAd:
    this.parseModrm32()

  else:
    this.parseModrm16()

  

proc parseMoffs*(this: var InstrImpl): void =
  if CPU.isMode32() xor this.exec.chszAd:
    this.idata.moffs = ACS.getCode32(0)
    CPU.updateEIp(4)
  
  else:
    this.idata.moffs = ACS.getCode16(0)
    CPU.updateEIp(2)

proc parse*(this: var InstrImpl): void =
  ## Parser new instruction into `this.idata` field, advancing `EIP` as
  ## needed.
  ##
  ## Data parsed:
  ##
  ## - Opcode with prefixes (1-4 bytes, required)
  ## - ModR/M (1 byte, if required)
  ## - SIB (1 byte, if required)
  ## - Displacement (1, 2 or 4 bytes, if required)
  ## - Immediate (1, 2 or 4 bytes, if required)

  this.parseOpcode()
  var op = this.idata.opcode
  # REVIEW not sure if this bithack is really necessary - implementation
  # uses values like `0x0F81` explicitly, so I doubt this is really
  # necessary.
  if op shr 8 == 0x0f:
    op = (op and 0xff) or 0x0100

  if iParseModrm in this.chk[op]:
    # Whether MODRM is used in the instruction is encoded in the parser
    # flags, this information is not available from the opcode alone.
    this.parseModrmSibDisp()

  if iParseImm32 in this.chk[op]:
    this.idata.imm32 = ACS.getCode32(0).int32()
    CPU.updateEIp(4)

  elif iParseImm16 in this.chk[op]:
    this.idata.imm16 = ACS.getCode16(0).int16()
    CPU.updateEIp(2)

  elif iParseImm8 in this.chk[op]:
    this.idata.imm8 = cast[int8](ACS.getCode8(0))
    CPU.updateEIp(1)

  if iParsePtr16 in this.chk[op]:
    ptr16(this) = ACS.getCode16(0).int8()
    CPU.updateEIp(2)

  if iParseMoffs in this.chk[op]:
    this.parseMoffs()
