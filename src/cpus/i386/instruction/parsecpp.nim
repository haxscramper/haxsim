import instruction/instructionhpp
import commonhpp
import emulator/[accesshpp, emulatorhpp]
import hardware/processorhpp

proc getEmu*(this: var InstrImpl): Emulator =
  result = this.exec.getEmu()
  assertRef(result)

proc parsePrefix*(this: var InstrImpl): uint8 =
  var chsz, code: uint8 = 0
  while (true):
    code = this.getEmu().accs.getCode8(0)
    var setPre = false
    case code:
      of 0x26:
        this.idata.preSegment = ES
        setPre = true

      of 0x2e:
        this.idata.preSegment = CS
        setPre = true

      of 0x36:
        this.idata.preSegment = SS
        setPre = true

      of 0x3e:
        this.idata.preSegment = DS
        setPre = true

      of 0x64:
        this.idata.preSegment = FS
        setPre = true

      of 0x65:
        this.idata.preSegment = GS
        setPre = true

      of 0x66:
        chsz = (chsz or CHSZOP)

      of 0x67:
        chsz = (chsz or CHSZAD)

      of 0xf2:
        this.idata.preRepeat = REPNZ

      of 0xf3:
        this.idata.preRepeat = REPZ

      else:
        return chsz

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
  if this.idata.modrm.mod != 3 and
     this.idata.modrm.rm == 4:
    this.idata.dSIB = ACS.getCode8(0)
    CPU.updateEIp(1)

  if this.idata.modrm.mod == 2 or
    (this.idata.modrm.mod == 0 and
     this.idata.modrm.rm == 5) or
    (this.idata.modrm.mod == 0 and this.base == 5):

    this.idata.disp32 = ACS.getCode32(0).int32()
    CPU.updateEIp(4)

  else:
    if this.idata.modrm.mod == 1:
      this.idata.disp8 = cast[int8](ACS.getCode8(0))
      CPU.updateEIp(1)


proc parseModrm16*(this: var InstrImpl): void =
  if (this.idata.modrm.mod == 0 and
      this.idata.modrm.rm == 6) or

     this.idata.modrm.mod == 2:

    this.idata.disp16 = ACS.getCode32(0).int16()
    CPU.updateEIp(2)

  else:
    if this.idata.modrm.mod == 1:
      this.idata.disp8 = cast[int8](ACS.getCode8(0))
      CPU.updateEIp(1)

proc parseModrmSibDisp*(this: var InstrImpl): void =
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
  this.parseOpcode()
  var op = this.idata.opcode
  # REVIEW not sure if this bithack is really necessary - implementation
  # uses values like `0x0F81` explicitly, so I doubt this is really
  # necessary.
  if op shr 8 == 0x0f:
    op = (op and 0xff) or 0x0100

  if iParseModrm in this.chk[op]:
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
