import instruction/instruction
import common
import emulator/[access, emulator]
import hardware/[processor, memory]



proc getEmu*(this: var InstrImpl): Emulator =
  result = this.exec.getEmu()
  assertRef(result)


proc assertCodeAhead*(this: var InstrImpl, ahead: int, part: string) =
  this.cpu.logger.noLog():
    let pos = ACS.transVirtualToPhysical(MODEEXEC, CS, this.cpu.getEIP())
    if ACS.mem.len() < pos.int + ahead:
      raise newException(
        OomInstrReadError,
        "Cannot read '$#' starting from 0x$# (EIP: 0x$#). Part len $#" % [
          $part,
          toHex(pos),
          toHex(this.cpu.getEIP()),
          $ahead,
        ]
      )


proc parsePrefix*(this: var InstrImpl) =

  ## Parse opcode prefix for the command. Change
  while (true):
    assertCodeAhead(this, 1, "instruction prefix")
    let code = this.getEmu().accs.getCode8(0).U8


    var ev = ev(eekCodePrefix, evalue(code))
    case code:
      # Override segments for addresses
      of 0x26:
        this.idata.preSegment = some ES
        ev.msg = "overide segment to ES"

      of 0x2e:
        this.idata.preSegment = some CS
        ev.msg = "override segment to CS"

      of 0x36:
        this.idata.preSegment = some SS
        ev.msg = "override segment to SS"

      of 0x3e:
        this.idata.preSegment = some DS
        ev.msg = "override segment to DS"

      of 0x64:
        this.idata.preSegment = some FS
        ev.msg = "override segment to FS"

      of 0x65:
        this.idata.preSegment = some GS
        ev.msg = "override segment to GS"

      # Switch operand size to the opposite one
      of 0x66:
        this.idata.opSizeOverride = true
        ev.msg = "operand side override"

      # Switch address size to the opposite
      of 0x67:
        this.idata.addrSizeOverride = true
        ev.msg = "address size override"

      # Repeat string operations until non-zero
      of 0xf2:
        this.idata.preRepeat = REPNZ
        ev.msg = "repnz prefix"

      # Repeat string operations until zero
      of 0xf3:
        this.idata.preRepeat = REPZ
        ev.msg = "repz prefix"

      else:
        return

    this.cpu.logger.log(ev)
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
  this.idata.startsFrom = this.cpu.eip()
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

  if (iParseImm32 in this.chk[op] and not this.idata.opSizeOverride) or
     (iParseImm16 in this.chk[op] and this.idata.opSizeOverride):
    # Instruction uses 32-bit immediate operand, *or* it uses 16-bit one by
    # default, and override was in order to access 32-bit data blob.
    this.assertCodeAhead(4, "4-byte immediate" & tern(
      this.idata.opSizeOverride, " due to override", ""))
    this.idata.imm32 = cast[int32](ACS.getCode32(0))
    CPU.updateEIp(4)

  elif (iParseImm16 in this.chk[op] and not this.idata.opSizeOverride) or
       (iParseImm32 in this.chk[op] and this.idata.opSizeOverride):
    this.assertCodeAhead(2, "2-byte immediate" & tern(
      this.idata.opSizeOverride, " due to override", ""))

    this.idata.imm16 = cast[int16](ACS.getCode16(0))
    CPU.updateEIp(2)

  elif iParseImm8 in this.chk[op]:
    this.assertCodeAhead(1, "1-byte immediate")
    this.idata.imm8 = cast[int8](ACS.getCode8(0))
    CPU.updateEIp(1)

  if iParsePtr16 in this.chk[op]:
    this.assertCodeAhead(2, "2-byte ptr")
    ptr16(this) = ACS.getCode16(0).int8()
    CPU.updateEIp(2)

  if iParseMoffs in this.chk[op]:
    this.parseMoffs()
