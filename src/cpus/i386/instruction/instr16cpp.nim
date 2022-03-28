import instruction/[basehpp, instructionhpp]
import instr_basecpp
import commonhpp
import ./emucpp
import ./execcpp
import ../hardware/eflagscpp
import ./opcodes
import hardware/[processorhpp, eflagshpp, iohpp]
import emulator/[exceptionhpp, emulatorhpp, accesshpp]

template instr16*(f: untyped): untyped {.dirty.} =
  instrfuncT(f)

proc selectSegment*(this: var InstrImpl): sgregT =
  this.exec.selectSegment()

proc addRm16R16*(this: var InstrImpl): void =
  var r16, rm16: uint16
  rm16 = this.exec.getRm16()
  r16 = this.exec.getR16()
  this.exec.setRm16(rm16 + r16)
  discard EFLAGSUPDATEADD(rm16, r16)

proc addR16Rm16*(this: var InstrImpl): void =
  var rm16, r16: uint16
  r16 = this.exec.getR16()
  rm16 = this.exec.getRm16()
  this.exec.setR16(r16 + rm16)
  discard EFLAGSUPDATEADD(r16, rm16)

proc addAxImm16*(this: var InstrImpl): void =
  var ax: uint16
  ax = GETGPREG(AX)
  SETGPREG(AX, ax + IMM16.uint16)
  discard EFLAGSUPDATEADD(ax, IMM16.uint16)

proc pushEs*(this: var InstrImpl): void =
  PUSH16(ACS.getSegment(ES))

proc popEs*(this: var InstrImpl): void =
  ACS.setSegment(ES, POP16())

proc orRm16R16*(this: var InstrImpl): void =
  var r16, rm16: uint16
  rm16 = this.exec.getRm16()
  r16 = this.exec.getR16()
  this.exec.setRm16(rm16 or r16)
  discard EFLAGSUPDATEOR(rm16, r16)

proc orR16Rm16*(this: var InstrImpl): void =
  var rm16, r16: uint16
  r16 = this.exec.getR16()
  rm16 = this.exec.getRm16()
  this.exec.setR16(r16 or rm16)
  discard EFLAGSUPDATEOR(r16, rm16)

proc orAxImm16*(this: var InstrImpl): void =
  var ax: uint16
  ax = GETGPREG(AX)
  SETGPREG(AX, ax or IMM16.uint16)
  discard EFLAGSUPDATEOR(ax, IMM16.uint16)

proc pushSs*(this: var InstrImpl): void =
  PUSH16(ACS.getSegment(SS))

proc popSs*(this: var InstrImpl): void =
  ACS.setSegment(SS, POP16())

proc pushDs*(this: var InstrImpl): void =
  PUSH16(ACS.getSegment(DS))

proc popDs*(this: var InstrImpl): void =
  ACS.setSegment(DS, POP16())

proc andRm16R16*(this: var InstrImpl): void =
  var r16, rm16: uint16
  rm16 = this.exec.getRm16()
  r16 = this.exec.getR16()
  this.exec.setRm16(rm16 and r16)
  discard EFLAGSUPDATEAND(rm16, r16)

proc andR16Rm16*(this: var InstrImpl): void =
  var rm16, r16: uint16
  r16 = this.exec.getR16()
  rm16 = this.exec.getRm16()
  this.exec.setR16(r16 and rm16)
  discard EFLAGSUPDATEAND(r16, rm16)

proc andAxImm16*(this: var InstrImpl): void =
  var ax: uint16
  ax = GETGPREG(AX)
  SETGPREG(AX, ax and IMM16.uint16)
  discard EFLAGSUPDATEAND(ax, IMM16.uint16)

proc subRm16R16*(this: var InstrImpl): void =
  var r16, rm16: uint16
  rm16 = this.exec.getRm16()
  r16 = this.exec.getR16()
  this.exec.setRm16(rm16 - r16)
  discard EFLAGSUPDATESUB(rm16, r16)

proc subR16Rm16*(this: var InstrImpl): void =
  var rm16, r16: uint16
  r16 = this.exec.getR16()
  rm16 = this.exec.getRm16()
  this.exec.setR16(r16 - rm16)
  discard EFLAGSUPDATESUB(r16, rm16)

proc subAxImm16*(this: var InstrImpl): void =
  var ax: uint16
  ax = GETGPREG(AX)
  SETGPREG(AX, ax - IMM16.uint16)
  discard EFLAGSUPDATESUB(ax, IMM16.uint16)

proc xorRm16R16*(this: var InstrImpl): void =
  var r16, rm16: uint16
  rm16 = this.exec.getRm16()
  r16 = this.exec.getR16()
  this.exec.setRm16(rm16 xor r16)

proc xorR16Rm16*(this: var InstrImpl): void =
  var rm16, r16: uint16
  r16 = this.exec.getR16()
  rm16 = this.exec.getRm16()
  this.exec.setR16(r16 xor rm16)

proc xorAxImm16*(this: var InstrImpl): void =
  var ax: uint16
  ax = GETGPREG(AX)
  SETGPREG(AX, ax xor IMM16.uint16)

proc cmpRm16R16*(this: var InstrImpl): void =
  var r16, rm16: uint16
  rm16 = this.exec.getRm16()
  r16 = this.exec.getR16()
  discard EFLAGSUPDATESUB(rm16, r16)

proc cmpR16Rm16*(this: var InstrImpl): void =
  var rm16, r16: uint16
  r16 = this.exec.getR16()
  rm16 = this.exec.getRm16()
  discard EFLAGSUPDATESUB(r16, rm16)

proc cmpAxImm16*(this: var InstrImpl): void =
  var ax: uint16
  ax = GETGPREG(AX)
  discard EFLAGSUPDATESUB(ax, IMM16.uint16)

proc incR16*(this: var InstrImpl): void =
  var reg: uint8
  var r16: uint16
  reg = uint8(OPCODE and ((1 shl 3) - 1))
  r16 = GETGPREG(cast[Reg16T](reg))
  SETGPREG(cast[Reg16T](reg), r16 + 1)
  discard EFLAGSUPDATEADD(r16, 1)

proc decR16*(this: var InstrImpl): void =
  var reg: uint8
  var r16: uint16
  reg = uint8(OPCODE and ((1 shl 3) - 1))
  r16 = GETGPREG(cast[Reg16T](reg))
  SETGPREG(cast[Reg16T](reg), r16 - 1)
  discard EFLAGSUPDATESUB(r16, 1)

proc pushR16*(this: var InstrImpl): void =
  var reg: uint8
  reg = uint8(OPCODE and ((1 shl 3) - 1))
  PUSH16(GETGPREG(cast[Reg16T](reg)))

proc popR16*(this: var InstrImpl): void =
  var reg: uint8
  reg = uint8(OPCODE and ((1 shl 3) - 1))
  SETGPREG(cast[Reg16T](reg), POP16())

proc pusha*(this: var InstrImpl): void =
  var sp: uint16
  sp = GETGPREG(SP)
  PUSH16(GETGPREG(AX))
  PUSH16(GETGPREG(CX))
  PUSH16(GETGPREG(DX))
  PUSH16(GETGPREG(BX))
  PUSH16(sp)
  PUSH16(GETGPREG(BP))
  PUSH16(GETGPREG(SI))
  PUSH16(GETGPREG(DI))

proc popa*(this: var InstrImpl): void =
  var sp: uint16
  SETGPREG(DI, POP16())
  SETGPREG(SI, POP16())
  SETGPREG(BP, POP16())
  sp = POP16()
  SETGPREG(BX, POP16())
  SETGPREG(DX, POP16())
  SETGPREG(CX, POP16())
  SETGPREG(AX, POP16())
  SETGPREG(SP, sp)

proc pushImm16*(this: var InstrImpl): void =
  PUSH16(IMM16.uint16)

proc imulR16Rm16Imm16*(this: var InstrImpl): void =
  var rm16S: int16
  rm16S = this.exec.getRm16().int16
  this.exec.setR16(uint16(rm16S * IMM16))
  discard EFLAGSUPDATEIMUL(rm16S, IMM16)

proc pushImm8*(this: var InstrImpl): void =
  PUSH16(IMM8.uint8)

proc imulR16Rm16Imm8*(this: var InstrImpl): void =
  var rm16S: int16
  rm16S = this.exec.getRm16().int16
  this.exec.setR16(uint16(rm16S * IMM8))
  discard EFLAGSUPDATEIMUL(rm16S, IMM8)

proc testRm16R16*(this: var InstrImpl): void =
  var r16, rm16: uint16
  rm16 = this.exec.getRm16()
  r16 = this.exec.getR16()
  discard EFLAGSUPDATEAND(rm16, r16)

proc xchgR16Rm16*(this: var InstrImpl): void =
  var rm16, r16: uint16
  r16 = this.exec.getR16()
  rm16 = this.exec.getRm16()
  this.exec.setR16(rm16)
  this.exec.setRm16(r16)

proc movRm16R16*(this: var InstrImpl): void =
  var r16: uint16
  r16 = this.exec.getR16()
  this.exec.setRm16(r16)

proc movR16Rm16*(this: var InstrImpl): void =
  var rm16: uint16
  rm16 = this.exec.getRm16()
  this.exec.setR16(rm16)

proc movRm16Sreg*(this: var InstrImpl): void =
  var sreg: uint16
  sreg = this.exec.getSreg()
  this.exec.setRm16(sreg)

proc leaR16M16*(this: var InstrImpl): void =
  var m16: uint16
  m16 = this.exec.getM().uint16
  this.exec.setR16(m16)

proc xchgR16Ax*(this: var InstrImpl): void =
  var ax, r16: uint16
  r16 = this.exec.getR16()
  ax = GETGPREG(AX)
  this.exec.setR16(ax)
  SETGPREG(AX, r16)

proc cbw*(this: var InstrImpl): void =
  var alS: int8
  alS = GETGPREG(AL).int8
  SETGPREG(AX, alS.uint16)

proc cwd*(this: var InstrImpl): void =
  var ax: uint16
  ax = GETGPREG(AX)
  SETGPREG(DX, uint16(if toBool(ax and (1 shl 15)): -1 else: 0))

proc callfPtr1616*(this: var InstrImpl): void =
  this.emu.callf(PTR16.uint16, IMM16.uint32)

proc pushf*(this: var InstrImpl): void =
  PUSH16(CPU.eflags.getFlags())

proc popf*(this: var InstrImpl): void =
  CPU.eflags.setFlags(POP16())

proc movAxMoffs16*(this: var InstrImpl): void =
  SETGPREG(AX, this.exec.getMoffs16())

proc movMoffs16Ax*(this: var InstrImpl): void =
  this.exec.setMoffs16(GETGPREG(AX))

proc cmpsM8M8*(this: var InstrImpl): void =
  var m8D, m8S: uint8
  var repeat = true
  while repeat:
    m8S = ACS.getData8(this.exec.selectSegment(), GETGPREG(SI))
    m8D = ACS.getData8(ES, GETGPREG(DI))
    discard EFLAGSUPDATESUB(m8S, m8D)
    discard UPDATEGPREG(SI, int16(if EFLAGSDF: -1 else: 1))
    discard UPDATEGPREG(DI, int16(if EFLAGSDF: -1 else: 1))
    if PREREPEAT.int.toBool():
      discard UPDATEGPREG(CX, -1)
      case PREREPEAT:
        of REPZ:
          if not(GETGPREG(CX)).toBool() or not(EFLAGSZF):
            repeat = false

        of REPNZ:
          if not(GETGPREG(CX)).toBool() or EFLAGSZF:
            repeat = false

        else:
          discard


proc cmpsM16M16*(this: var InstrImpl): void =
  var m16D, m16S: uint16
  block repeat:
    m16S = ACS.getData16(this.exec.selectSegment(), GETGPREG(SI))
  m16D = ACS.getData16(ES, GETGPREG(DI))
  discard EFLAGSUPDATESUB(m16S, m16D)
  discard UPDATEGPREG(SI, (if EFLAGSDF: -1 else: 1))
  discard UPDATEGPREG(DI, (if EFLAGSDF: -1 else: 1))
  if PREREPEAT.int.toBool():
    discard UPDATEGPREG(CX, -1)
    case PREREPEAT:
      of REPZ:
        if not(GETGPREG(CX)).toBool() or not(EFLAGSZF):
          {.warning: "[FIXME] break".}

        {.warning: "[FIXME] cxxGoto repeat".}
      of REPNZ:
        if not(GETGPREG(CX)).toBool() or EFLAGSZF:
          {.warning: "[FIXME] break".}

        {.warning: "[FIXME] cxxGoto repeat".}
      else:
        discard


proc testAxImm16*(this: var InstrImpl): void =
  var ax: uint16
  ax = GETGPREG(AX)
  discard EFLAGSUPDATEAND(ax, IMM16.uint16)

proc movR16Imm16*(this: var InstrImpl): void =
  var reg: uint8
  reg = uint8(OPCODE and ((1 shl 3) - 1))
  SETGPREG(cast[Reg16T](reg), IMM16.uint16)

proc ret*(this: var InstrImpl): void =
  SETIP(POP16())

proc movRm16Imm16*(this: var InstrImpl): void =
  this.exec.setRm16(IMM16.uint16)

proc leave*(this: var InstrImpl): void =
  var ebp: uint16
  ebp = GETGPREG(EBP).uint16()
  SETGPREG(ESP, ebp)
  SETGPREG(EBP, POP16())

proc inAxImm8*(this: var InstrImpl): void =
  SETGPREG(AX, EIO.inIo16(IMM8.uint16))

proc outImm8Ax*(this: var InstrImpl): void =
  var ax: uint16
  ax = GETGPREG(AX).uint16()
  EIO.outIo16(IMM8.uint16, ax)

proc callRel16*(this: var InstrImpl): void =
  PUSH16(GETIP().uint16)
  discard UPDATEIP(IMM16.int32)

proc jmpRel16*(this: var InstrImpl): void =
  discard UPDATEIP(IMM16.int32)

proc jmpfPtr1616*(this: var InstrImpl): void =
  this.emu.jmpf(PTR16.uint16, IMM16.uint32)

proc inAxDx*(this: var InstrImpl): void =
  var dx: uint16
  dx = GETGPREG(DX).uint16()
  SETGPREG(AX, EIO.inIo16(dx))

proc outDxAx*(this: var InstrImpl): void =
  var ax, dx: uint16
  dx = GETGPREG(DX)
  ax = GETGPREG(AX)
  EIO.outIo16(dx, ax)

template JCCREL16*(cc: untyped, isFlag: untyped): untyped {.dirty.} =
  proc `j cc rel16`*(this: var InstrImpl): void =
    if isFlag:
      discard UPDATEEIP(IMM16.int32)

JCCREL16(o, EFLAGSOF)
JCCREL16(no, not(EFLAGSOF))
JCCREL16(b, EFLAGSCF)
JCCREL16(nb, not(EFLAGSCF))
JCCREL16(z, EFLAGSZF)
JCCREL16(nz, not(EFLAGSZF))
JCCREL16(be, EFLAGSCF or EFLAGSZF)
JCCREL16(a, not((EFLAGSCF or EFLAGSZF)))
JCCREL16(s, EFLAGSSF)
JCCREL16(ns, not(EFLAGSSF))
JCCREL16(p, EFLAGSPF)
JCCREL16(np, not(EFLAGSPF))
JCCREL16(l, EFLAGSSF != EFLAGSOF)
JCCREL16(nl, EFLAGSSF == EFLAGSOF)
JCCREL16(le, EFLAGSZF or (EFLAGSSF != EFLAGSOF))
JCCREL16(nle, not(EFLAGSZF) and (EFLAGSSF == EFLAGSOF))

proc imulR16Rm16*(this: var InstrImpl): void =
  var rm16S, r16S: int16
  r16S = this.exec.getR16().int16
  rm16S = this.exec.getRm16().int16
  this.exec.setR16(uint16(r16S * rm16S))
  discard EFLAGSUPDATEIMUL(r16S, rm16S)

proc movzxR16Rm8*(this: var InstrImpl): void =
  var rm8: uint8
  rm8 = this.exec.getRm8().uint8
  this.exec.setR16(rm8)

proc movzxR16Rm16*(this: var InstrImpl): void =
  var rm16: uint16
  rm16 = this.exec.getRm16().uint16
  this.exec.setR16(rm16)

proc movsxR16Rm8*(this: var InstrImpl): void =
  var rm8S: int8
  rm8S = this.exec.getRm8().int8
  this.exec.setR16(rm8S.uint16)

proc movsxR16Rm16*(this: var InstrImpl): void =
  var rm16S: int16
  rm16S = this.exec.getRm16().int16
  this.exec.setR16(rm16S.uint16)




proc addRm16Imm16*(this: var InstrImpl): void =
  var rm16: uint16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(rm16 + IMM16.uint16)
  discard EFLAGSUPDATEADD(rm16, IMM16.uint16)

proc orRm16Imm16*(this: var InstrImpl): void =
  var rm16: uint16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(rm16 or IMM16.uint16)
  discard EFLAGSUPDATEOR(rm16, IMM16.uint16)

proc adcRm16Imm16*(this: var InstrImpl): void =
  var rm16: uint16
  var cf: uint8
  rm16 = this.exec.getRm16()
  cf = EFLAGSCF.uint8
  this.exec.setRm16(rm16 + IMM16.uint16 + cf)
  discard EFLAGSUPDATEADD(rm16, IMM16.uint16 + cf)

proc sbbRm16Imm16*(this: var InstrImpl): void =
  var rm16: uint16
  var cf: uint8
  rm16 = this.exec.getRm16()
  cf = EFLAGSCF.uint8
  this.exec.setRm16(rm16 - IMM16.uint16 - cf)
  discard EFLAGSUPDATESUB(rm16, IMM16.uint16 + cf)

proc andRm16Imm16*(this: var InstrImpl): void =
  var rm16: uint16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(rm16 and IMM16.uint16)
  discard EFLAGSUPDATEAND(rm16, IMM16.uint16)

proc subRm16Imm16*(this: var InstrImpl): void =
  var rm16: uint16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(rm16 - IMM16.uint16)
  discard EFLAGSUPDATESUB(rm16, IMM16.uint16)

proc xorRm16Imm16*(this: var InstrImpl): void =
  var rm16: uint16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(rm16 xor IMM16.uint16)

proc cmpRm16Imm16*(this: var InstrImpl): void =
  var rm16: uint16
  rm16 = this.exec.getRm16()
  discard EFLAGSUPDATESUB(rm16, IMM16.uint16)


proc addRm16Imm8*(this: var InstrImpl): void =
  var rm16: uint16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(rm16 + IMM8.uint16)
  discard EFLAGSUPDATEADD(rm16, IMM8.uint16)

proc orRm16Imm8*(this: var InstrImpl): void =
  var rm16: uint16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(rm16 or IMM8.uint16)
  discard EFLAGSUPDATEOR(rm16, IMM8.uint16)

proc adcRm16Imm8*(this: var InstrImpl): void =
  var rm16: uint16
  var cf: uint8
  rm16 = this.exec.getRm16()
  cf = EFLAGSCF.uint8
  this.exec.setRm16(rm16 + IMM8.uint16 + cf)
  discard EFLAGSUPDATEADD(rm16, IMM8.uint8 + cf)

proc sbbRm16Imm8*(this: var InstrImpl): void =
  var rm16: uint16
  var cf: uint8
  rm16 = this.exec.getRm16()
  cf = EFLAGSCF.uint8
  this.exec.setRm16(rm16 - IMM8.uint8 - cf)
  discard EFLAGSUPDATESUB(rm16, IMM8.uint8 + cf)

proc andRm16Imm8*(this: var InstrImpl): void =
  var rm16: uint16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(rm16 and IMM8.uint16)
  discard EFLAGSUPDATEAND(rm16, IMM8.uint16)

proc subRm16Imm8*(this: var InstrImpl): void =
  var rm16: uint16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(rm16 - IMM8.uint8)
  discard EFLAGSUPDATESUB(rm16, IMM8.uint16)

proc xorRm16Imm8*(this: var InstrImpl): void =
  var rm16: uint16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(rm16 xor IMM8.uint16)

proc cmpRm16Imm8*(this: var InstrImpl): void =
  var rm16: uint16
  rm16 = this.exec.getRm16()
  discard EFLAGSUPDATESUB(rm16, IMM8.uint16)


proc shlRm16Imm8*(this: var InstrImpl): void =
  var rm16: uint16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(rm16 shl IMM8)
  discard EFLAGSUPDATESHL(rm16, IMM8.uint8)

proc shrRm16Imm8*(this: var InstrImpl): void =
  var rm16: uint16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(rm16 shr IMM8)
  discard EFLAGSUPDATESHR(rm16, IMM8.uint8)

proc salRm16Imm8*(this: var InstrImpl): void =
  var rm16S: int16
  rm16S = this.exec.getRm16().int16
  this.exec.setRm16(uint16(rm16S shl IMM8))


proc sarRm16Imm8*(this: var InstrImpl): void =
  var rm16S: int16
  rm16S = this.exec.getRm16().int16
  this.exec.setRm16(uint16(rm16S shr IMM8))



proc shlRm16Cl*(this: var InstrImpl): void =
  var rm16: uint16
  var cl: uint8
  rm16 = this.exec.getRm16()
  cl = GETGPREG(CL)
  this.exec.setRm16(rm16 shl cl)
  discard EFLAGSUPDATESHL(rm16, cl.uint8)

proc shrRm16Cl*(this: var InstrImpl): void =
  var rm16: uint16
  var cl: uint8
  rm16 = this.exec.getRm16()
  cl = GETGPREG(CL)
  this.exec.setRm16(rm16 shr cl)
  discard EFLAGSUPDATESHR(rm16, cl.uint8)

proc salRm16Cl*(this: var InstrImpl): void =
  var rm16S: int16
  var cl: uint8
  rm16S = this.exec.getRm16().int16
  cl = GETGPREG(CL)
  this.exec.setRm16(uint16(rm16S shl cl))


proc sarRm16Cl*(this: var InstrImpl): void =
  var rm16S: int16
  var cl: uint8
  rm16S = this.exec.getRm16().int16
  cl = GETGPREG(CL)
  this.exec.setRm16(uint16(rm16S shr cl))



proc testRm16Imm16*(this: var InstrImpl): void =
  var imm16, rm16: uint16
  rm16 = this.exec.getRm16()
  imm16 = ACS.getCode16(0)
  discard UPDATEEIP(2)
  discard EFLAGSUPDATEAND(rm16, imm16)

proc notRm16*(this: var InstrImpl): void =
  var rm16: uint16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(not(rm16))

proc negRm16*(this: var InstrImpl): void =
  var rm16S: int16
  rm16S = this.exec.getRm16().int16
  this.exec.setRm16(uint16(-(rm16S)))
  discard EFLAGSUPDATESUB(cast[uint16](0), rm16S.uint32)

proc mulDxAxRm16*(this: var InstrImpl): void =
  var ax, rm16: uint16
  var val: uint32
  rm16 = this.exec.getRm16()
  ax = GETGPREG(AX)
  val = ax * rm16
  SETGPREG(AX, uint16(val and ((1 shl 16) - 1)))
  SETGPREG(DX, uint16((val shr 16) and ((1 shl 16) - 1)))
  discard EFLAGSUPDATEMUL(ax, rm16)

proc imulDxAxRm16*(this: var InstrImpl): void =
  var axS, rm16S: int16
  var valS: int32
  rm16S = this.exec.getRm16().int16
  axS = GETGPREG(AX).int16
  valS = axS * rm16S
  SETGPREG(AX, uint16(valS and ((1 shl 16) - 1)))
  SETGPREG(DX, uint16((valS shr 16) and ((1 shl 16) - 1)))
  discard EFLAGSUPDATEIMUL(axS, rm16S)

proc divDxAxRm16*(this: var InstrImpl): void =
  var rm16: uint16
  var val: uint32
  rm16 = this.exec.getRm16()
  EXCEPTION(EXPDE, not(rm16.toBool()))
  val = (GETGPREG(DX) shl 16) or GETGPREG(AX)
  SETGPREG(AX, uint16(val div rm16))
  SETGPREG(DX, uint16(val mod rm16))

proc idivDxAxRm16*(this: var InstrImpl): void =
  var rm16S: int16
  var valS: int32
  rm16S = this.exec.getRm16().int16
  EXCEPTION(EXPDE, not(rm16S.toBool()))
  valS = int32((GETGPREG(DX) shl 16) or GETGPREG(AX))
  SETGPREG(AX, uint16(valS div rm16S))
  SETGPREG(DX, uint16(valS mod rm16S))


proc incRm16*(this: var InstrImpl): void =
  var rm16: uint16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(rm16 + 1)
  discard EFLAGSUPDATEADD(rm16, 1)

proc decRm16*(this: var InstrImpl): void =
  var rm16: uint16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(rm16 - 1)
  discard EFLAGSUPDATESUB(rm16, 1)

proc callRm16*(this: var InstrImpl): void =
  var rm16: uint16
  rm16 = this.exec.getRm16()
  PUSH16(GETIP().uint16)
  SETIP(rm16)

proc callfM1616*(this: var InstrImpl): void =
  var ip, m32, cs: uint16
  m32 = this.exec.getM().uint16
  ip = READMEM16(m32)
  cs = READMEM16(m32 + 2)
  this.emu.callf(cs, ip.uint32)

proc jmpRm16*(this: var InstrImpl): void =
  var rm16: uint16
  rm16 = this.exec.getRm16()
  SETIP(rm16)

proc jmpfM1616*(this: var InstrImpl): void =
  var ip, m32, sel: uint16
  m32 = this.exec.getM().uint16
  ip = READMEM16(m32)
  sel = READMEM16(m32 + 2)
  this.emu.jmpf(sel, ip.uint32)

proc pushRm16*(this: var InstrImpl): void =
  var rm16: uint16
  rm16 = this.exec.getRm16()
  PUSH16(rm16)


proc lgdtM24*(this: var InstrImpl): void =
  var limit, m48, base: uint16
  EXCEPTION(EXPGP, not(this.emu.chkRing(0)))
  m48 = this.exec.getM().uint16
  limit = READMEM16(m48)
  base = uint16(READMEM32(m48 + 2) and ((1 shl 24) - 1))
  this.emu.setGdtr(base.uint32, limit)

proc lidtM24*(this: var InstrImpl): void =
  var limit, base, m48: uint16
  EXCEPTION(EXPGP, not(this.emu.chkRing(0)))
  m48 = this.exec.getM().uint16
  limit = READMEM16(m48)
  base = uint16(READMEM32(m48 + 2) and ((1 shl 24) - 1))
  this.emu.setIdtr(base.uint32, limit)

proc code81*(this: var InstrImpl): void =
  case REG:
    of 0: this.addRm16Imm16()
    of 1: this.orRm16Imm16()
    of 2: this.adcRm16Imm16()
    of 3: this.sbbRm16Imm16()
    of 4: this.andRm16Imm16()
    of 5: this.subRm16Imm16()
    of 6: this.xorRm16Imm16()
    of 7: this.cmpRm16Imm16()
    else:
      ERROR("not implemented: 0x81 /%d\\n", REG)

proc code83*(this: var InstrImpl): void =
  case REG:
    of 0: this.addRm16Imm8()
    of 1: this.orRm16Imm8()
    of 2: this.adcRm16Imm8()
    of 3: this.sbbRm16Imm8()
    of 4: this.andRm16Imm8()
    of 5: this.subRm16Imm8()
    of 6: this.xorRm16Imm8()
    of 7: this.cmpRm16Imm8()
    else:
      ERROR("not implemented: 0x83 /%d\\n", REG)

proc codeC1*(this: var InstrImpl): void =
  case REG:
    of 4: this.shlRm16Imm8()
    of 5: this.shrRm16Imm8()
    of 6: this.salRm16Imm8()
    of 7: this.sarRm16Imm8()
    else:
      ERROR("not implemented: 0xc1 /%d\\n", REG)

proc codeD3*(this: var InstrImpl): void =
  case REG:
    of 4: this.shlRm16Cl()
    of 5: this.shrRm16Cl()
    of 6: this.salRm16Cl()
    of 7: this.sarRm16Cl()
    else:
      ERROR("not implemented: 0xd3 /%d\\n", REG)

proc codeF7*(this: var InstrImpl): void =
  case REG:
    of 0: this.testRm16Imm16()
    of 2: this.notRm16()
    of 3: this.negRm16()
    of 4: this.mulDxAxRm16()
    of 5: this.imulDxAxRm16()
    of 6: this.divDxAxRm16()
    of 7: this.idivDxAxRm16()
    else:
      ERROR("not implemented: 0xf7 /%d\\n", REG)

proc codeFf*(this: var InstrImpl): void =
  case REG:
    of 0: this.incRm16()
    of 1: this.decRm16()
    of 2: this.callRm16()
    of 3: this.callfM1616()
    of 4: this.jmpRm16()
    of 5: this.jmpfM1616()
    of 6: this.pushRm16()
    else:
      ERROR("not implemented: 0xff /%d\\n", REG)

proc code0f00*(this: var InstrImpl): void =
  case REG:
    of 3: this.ltrRm16()
    else: ERROR("not implemented: 0x0f00 /%d\\n", REG)

proc code0f01*(this: var InstrImpl): void =
  case REG:
    of 2: this.lgdtM24()
    of 3: this.lidtM24()
    else:
      ERROR("not implemented: 0x0f01 /%d\\n", REG)


proc initInstrImpl16*(r: var InstrImpl, instr: Instruction) =
  initInstrImpl(r, instr)
  assertRef(r.exec.get_emu())

  r.setFuncflag(ICode(0x01), instr16(addRm16R16), CHKMODRM)

  r.setFuncflag(ICode(0x03), instr16(addR16Rm16), CHKMODRM)

  r.setFuncflag(ICode(0x05), instr16(addAxImm16), CHKIMM16.uint8)
  r.setFuncflag(ICode(0x06), instr16(pushEs), 0)
  r.setFuncflag(ICode(0x07), instr16(popEs), 0)

  r.setFuncflag(ICode(0x09), instr16(orRm16R16), CHKMODRM)

  r.setFuncflag(ICode(0x0b), instr16(orR16Rm16), CHKMODRM)

  r.setFuncflag(ICode(0x0d), instr16(orAxImm16), CHKIMM16.uint8)
  r.setFuncflag(ICode(0x16), instr16(pushSs), 0)
  r.setFuncflag(ICode(0x17), instr16(popSs), 0)
  r.setFuncflag(ICode(0x1e), instr16(pushDs), 0)
  r.setFuncflag(ICode(0x1f), instr16(popDs), 0)

  r.setFuncflag(ICode(0x21), instr16(andRm16R16), CHKMODRM)

  r.setFuncflag(ICode(0x23), instr16(andR16Rm16), CHKMODRM)

  r.setFuncflag(ICode(0x25), instr16(andAxImm16), CHKIMM16.uint8)

  r.setFuncflag(ICode(0x29), instr16(subRm16R16), CHKMODRM)

  r.setFuncflag(ICode(0x2b), instr16(subR16Rm16), CHKMODRM)

  r.setFuncflag(ICode(0x2d), instr16(subAxImm16), CHKIMM16.uint8)

  r.setFuncflag(ICode(0x31), instr16(xorRm16R16), CHKMODRM)

  r.setFuncflag(ICode(0x33), instr16(xorR16Rm16), CHKMODRM)

  r.setFuncflag(ICode(0x35), instr16(xorAxImm16), CHKIMM16.uint8)

  r.setFuncflag(ICode(0x39), instr16(cmpRm16R16), CHKMODRM)

  r.setFuncflag(ICode(0x3b), instr16(cmpR16Rm16), CHKMODRM)

  r.setFuncflag(ICode(0x3d), instr16(cmpAxImm16), CHKIMM16.uint8)

  r.setFuncflag(ICode(0x40), instr16(incR16), 0)
  r.setFuncflag(ICode(0x48), instr16(decR16), 0)
  r.setFuncflag(ICode(0x50), instr16(pushR16), 0)
  r.setFuncflag(ICode(0x58), instr16(popR16), 0)

  r.setFuncflag(ICode(0x60), instr16(pusha), 0)
  r.setFuncflag(ICode(0x61), instr16(popa), 0)
  r.setFuncflag(ICode(0x68), instr16(pushImm16), CHKIMM16.uint8)
  r.setFuncflag(ICode(0x69), instr16(imulR16Rm16Imm16), CHKMODRM or CHKIMM16.uint8)
  r.setFuncflag(ICode(0x6a), instr16(pushImm8), CHKIMM8)
  r.setFuncflag(ICode(0x6b), instr16(imulR16Rm16Imm8), CHKMODRM or CHKIMM8)


  r.setFuncflag(ICode(0x85), instr16(testRm16R16), CHKMODRM)

  r.setFuncflag(ICode(0x87), instr16(xchgR16Rm16), CHKMODRM)

  r.setFuncflag(ICode(0x89), instr16(movRm16R16), CHKMODRM)

  r.setFuncflag(ICode(0x8b), instr16(movR16Rm16), CHKMODRM)
  r.setFuncflag(ICode(0x8c), instr16(movRm16Sreg), CHKMODRM)
  r.setFuncflag(ICode(0x8d), instr16(leaR16M16), CHKMODRM)

  r.setFuncflag(ICode(0x90), instr16(xchgR16Ax), CHKIMM16.uint8)

  r.setFuncflag(ICode(0x98), instr16(cbw), 0)
  r.setFuncflag(ICode(0x99), instr16(cwd), 0)
  r.setFuncflag(ICode(0x9a), instr16(callfPtr1616), uint8(CHKPTR16 or CHKIMM16.uint16))
  r.setFuncflag(ICode(0x9c), instr16(pushf), 0)
  r.setFuncflag(ICode(0x9d), instr16(popf), 0)

  r.setFuncflag(ICode(0xa1), instr16(movAxMoffs16), CHKMOFFS)

  r.setFuncflag(ICode(0xa3), instr16(movMoffs16Ax), CHKMOFFS)
  r.setFuncflag(ICode(0xa6), instr16(cmpsM8M8), 0)
  r.setFuncflag(ICode(0xa7), instr16(cmpsM16M16), 0)

  r.setFuncflag(ICode(0xa9), instr16(testAxImm16), CHKIMM16.uint8)

  r.setFuncflag(ICOde(0xb8), instr16(movR16Imm16), CHKIMM16.uint8)

  r.setFuncflag(ICode(0xc3), instr16(ret), 0)
  r.setFuncflag(ICode(0xc7), instr16(movRm16Imm16), CHKMODRM or CHKIMM16.uint8)
  r.setFuncflag(ICode(0xc9), instr16(leave), 0)





  r.setFuncflag(ICode(0xe5), instr16(inAxImm8), CHKIMM8)

  r.setFuncflag(ICode(0xe7), instr16(outImm8Ax), CHKIMM8)
  r.setFuncflag(ICode(0xe8), instr16(callRel16), CHKIMM16.uint8)
  r.setFuncflag(ICode(0xe9), instr16(jmpRel16), CHKIMM16.uint8)
  r.setFuncflag(ICode(0xea), instr16(jmpfPtr1616), CHKPTR16 or CHKIMM16.uint8)


  r.setFuncflag(ICode(0xed), instr16(inAxDx), 0)

  r.setFuncflag(ICode(0xef), instr16(outDxAx), 0)
  r.setFuncflag(ICode(0x0f80), instr16(joRel16), CHKIMM16.uint8)
  r.setFuncflag(ICode(0x0f81), instr16(jnoRel16), CHKIMM16.uint8)
  r.setFuncflag(ICode(0x0f82), instr16(jbRel16), CHKIMM16.uint8)
  r.setFuncflag(ICode(0x0f83), instr16(jnbRel16), CHKIMM16.uint8)
  r.setFuncflag(ICode(0x0f84), instr16(jzRel16), CHKIMM16.uint8)
  r.setFuncflag(ICode(0x0f85), instr16(jnzRel16), CHKIMM16.uint8)
  r.setFuncflag(ICode(0x0f86), instr16(jbeRel16), CHKIMM16.uint8)
  r.setFuncflag(ICode(0x0f87), instr16(jaRel16), CHKIMM16.uint8)
  r.setFuncflag(ICode(0x0f88), instr16(jsRel16), CHKIMM16.uint8)
  r.setFuncflag(ICode(0x0f89), instr16(jnsRel16), CHKIMM16.uint8)
  r.setFuncflag(ICode(0x0f8a), instr16(jpRel16), CHKIMM16.uint8)
  r.setFuncflag(ICode(0x0f8b), instr16(jnpRel16), CHKIMM16.uint8)
  r.setFuncflag(ICode(0x0f8c), instr16(jlRel16), CHKIMM16.uint8)
  r.setFuncflag(ICode(0x0f8d), instr16(jnlRel16), CHKIMM16.uint8)
  r.setFuncflag(ICode(0x0f8e), instr16(jleRel16), CHKIMM16.uint8)
  r.setFuncflag(ICode(0x0f8f), instr16(jnleRel16), CHKIMM16.uint8)
  r.setFuncflag(ICode(0x0faf), instr16(imulR16Rm16), CHKMODRM)
  r.setFuncflag(ICode(0x0fb6), instr16(movzxR16Rm8), CHKMODRM)
  r.setFuncflag(ICode(0x0fb7), instr16(movzxR16Rm16), CHKMODRM)
  r.setFuncflag(ICode(0x0fbe), instr16(movsxR16Rm8), CHKMODRM)
  r.setFuncflag(ICode(0x0fbf), instr16(movsxR16Rm16), CHKMODRM)

  r.setFuncflag(ICode(0x81), instr16(code81), CHKMODRM or CHKIMM16.uint8)

  r.setFuncflag(ICode(0x83), instr16(code83), CHKMODRM or CHKIMM8)

  r.setFuncflag(ICode(0xc1), instr16(codeC1), CHKMODRM or CHKIMM8)
  r.setFuncflag(ICode(0xd3), instr16(codeD3), CHKMODRM)
  r.setFuncflag(ICode(0xf7), instr16(codeF7), CHKMODRM)
  r.setFuncflag(ICode(0xff), instr16(codeFf), CHKMODRM)
  r.setFuncflag(ICode(0x0f00), instr16(code0f00), CHKMODRM)
  r.setFuncflag(ICode(0x0f01), instr16(code0f01), CHKMODRM)


proc initInstrImpl16*(instr: Instruction): InstrImpl =
  initInstrImpl16(result, instr)
  assertRef(result.exec.get_emu())
