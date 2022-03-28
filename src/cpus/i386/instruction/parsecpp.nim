import instruction/instructionhpp
import commonhpp
import emulator/[accesshpp, emulatorhpp]
import hardware/processorhpp

proc getEmu*(this: var InstrImpl): Emulator =
  result = this.exec.getEmu()
  assertRef(result)

template PRESEGMENT*(): untyped {.dirty.} =
  (this.exec.instr.preSegment)

template PREREPEAT*(): untyped {.dirty.} =
  (this.exec.instr.preRepeat)

template OPCODE*(): untyped {.dirty.} =
  (this.exec.instr.opcode)

template MOD*(): untyped {.dirty.} =
  (this.exec.instr.modrm.`mod`)

template RM*(): untyped {.dirty.} =
  (this.exec.instr.modrm.rm)

template BASE*(): untyped {.dirty.} =
  (this.exec.instr.sib.base)

template DISP32*(): untyped {.dirty.} =
  (this.exec.instr.disp32)

template INSTR(): untyped = this.exec.instr

proc parsePrefix*(this: var InstrImpl): uint8 =
  var chsz, code: uint8 = 0
  while (true):
    code = this.getEmu().accs.getCode8(0)
    echov code
    var setPre = false
    case code:
      of 0x26:
        PRESEGMENT = ES
        setPre = true

      of 0x2e:
        PRESEGMENT = CS
        setPre = true

      of 0x36:
        PRESEGMENT = SS
        setPre = true

      of 0x3e:
        PRESEGMENT = DS
        setPre = true

      of 0x64:
        PRESEGMENT = FS
        setPre = true

      of 0x65:
        PRESEGMENT = GS
        setPre = true

      of 0x66:
        chsz = (chsz or CHSZOP)

      of 0x67:
        chsz = (chsz or CHSZAD)

      of 0xf2:
        PREREPEAT = REPNZ

      of 0xf3:
        PREREPEAT = REPZ

      else:
        return chsz

    if setPre:
      PREFIX = code

    discard UPDATEEIP(1)

proc parseOpcode*(this: var InstrImpl): void =
  OPCODE = ACS.getCode8(0)
  echov OPCODE
  discard UPDATEEIP(1)
  
  if OPCODE == 0x0f:
    OPCODE = (OPCODE shl 8) + ACS.getCode8(0)
    discard UPDATEEIP(1)
  


proc parseModrm32*(this: var InstrImpl): void =
  if MOD != 3 and RM == 4:
    INSTR.dSIB = ACS.getCode8(0)
    discard UPDATEEIP(1)
    DEBUGMSG(5, "[scale:0x%02x index:0x%02x base:0x%02x] ", SCALE, INDEX, BASE)
  
  if MOD == 2 or (MOD == 0 and RM == 5) or (MOD == 0 and BASE == 5):
    INSTR.disp32 = ACS.getCode32(0).int32()
    discard UPDATEEIP(4)
    DEBUGMSG(5, "disp32:0x%08x ", DISP32)
  
  else:
    if MOD == 1:
      INSTR.disp8 = cast[int8](ACS.getCode8(0))
      discard UPDATEEIP(1)
      DEBUGMSG(5, "disp8:0x%02x ", DISP8)
    
  

proc parseModrm16*(this: var InstrImpl): void =
  if (MOD == 0 and RM == 6) or MOD == 2:
    INSTR.disp16 = ACS.getCode32(0).int16()
    discard UPDATEEIP(2)
    DEBUGMSG(5, "disp16:0x%04x ", DISP16)
  
  else:
    if MOD == 1:
      INSTR.disp8 = cast[int8](ACS.getCode8(0))
      discard UPDATEEIP(1)
      DEBUGMSG(5, "disp8:0x%02x ", DISP8)
    

proc parseModrmSibDisp*(this: var InstrImpl): void =
  INSTR.dmodrm = ACS.getCode8(0)
  discard UPDATEEIP(1)
  DEBUGMSG(5, "[mod:0x%02x reg:0x%02x rm:0x%02x] ", MOD, REG, RM)
  if CPU.isMode32() xor this.exec.chszAd:
    this.parseModrm32()

  else:
    this.parseModrm16()

  

proc parseMoffs*(this: var InstrImpl): void =
  if CPU.isMode32() xor this.exec.chszAd:
    INSTR.moffs = ACS.getCode32(0)
    discard UPDATEEIP(4)
  
  else:
    INSTR.moffs = ACS.getCode16(0)
    discard UPDATEEIP(2)
  
  DEBUGMSG(5, "moffs:0x%04x ", MOFFS)

proc parse*(this: var InstrImpl): void =
  this.parseOpcode()
  var op = OPCODE
  # REVIEW not sure if this bithack is really necessary - implementation
  # uses values like `0x0F81` explicitly, so I doubt this is really
  # necessary.
  if op shr 8 == 0x0f:
    op = (op and 0xff) or 0x0100

  if iParseModrm in this.parse.chk[op]:
    this.parseModrmSibDisp()

  if iParseImm32 in this.parse.chk[op]:
    INSTR.imm32 = ACS.getCode32(0).int32()
    discard UPDATEEIP(4)

  elif iParseImm16 in this.parse.chk[op]:
    INSTR.imm16 = ACS.getCode16(0).int16()
    discard UPDATEEIP(2)

  elif iParseImm8 in this.parse.chk[op]:
    INSTR.imm8 = cast[int8](ACS.getCode8(0))
    discard UPDATEEIP(1)

  if iParsePtr16 in this.parse.chk[op]:
    PTR16 = ACS.getCode16(0).int8()
    discard UPDATEEIP(2)

  if iParseMoffs in this.parse.chk[op]:
    this.parseMoffs()

  pprinte this.exec.instr.opcode
