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

proc selectSegment*(this: var InstrImpl): SgRegT =
  this.exec.selectSegment()

proc addRm16R16*(this: var InstrImpl): void =
  var r16, rm16: uint16
  rm16 = this.exec.getRm16()
  r16 = this.exec.getR16()
  this.exec.setRm16(rm16 + r16)
  CPU.eflags.updateADD(rm16, r16)

proc addR16Rm16*(this: var InstrImpl): void =
  var rm16, r16: uint16
  r16 = this.exec.getR16()
  rm16 = this.exec.getRm16()
  this.exec.setR16(r16 + rm16)
  CPU.eflags.updateADD(r16, rm16)

proc addAxImm16*(this: var InstrImpl): void =
  var ax: uint16
  ax = CPU.getGPreg(AX)
  CPU.setGPreg(AX, ax + this.imm16.uint16)
  CPU.eflags.updateADD(ax, this.imm16.uint16)

proc pushEs*(this: var InstrImpl): void =
  this.push16(ACS.getSegment(ES))

proc popEs*(this: var InstrImpl): void =
  ACS.setSegment(ES, this.pop16())

proc orRm16R16*(this: var InstrImpl): void =
  var r16, rm16: uint16
  rm16 = this.exec.getRm16()
  r16 = this.exec.getR16()
  this.exec.setRm16(rm16 or r16)
  CPU.eflags.updateOR(rm16, r16)

proc orR16Rm16*(this: var InstrImpl): void =
  var rm16, r16: uint16
  r16 = this.exec.getR16()
  rm16 = this.exec.getRm16()
  this.exec.setR16(r16 or rm16)
  CPU.eflags.updateOR(r16, rm16)

proc orAxImm16*(this: var InstrImpl): void =
  var ax: uint16
  ax = CPU.getGPreg(AX)
  CPU.setGPreg(AX, ax or this.imm16.uint16)
  CPU.eflags.updateOR(ax, this.imm16.uint16)

proc pushSs*(this: var InstrImpl): void =
  this.push16(ACS.getSegment(SS))

proc popSs*(this: var InstrImpl): void =
  ACS.setSegment(SS, this.pop16())

proc pushDs*(this: var InstrImpl): void =
  this.push16(ACS.getSegment(DS))

proc popDs*(this: var InstrImpl): void =
  ACS.setSegment(DS, this.pop16())

proc andRm16R16*(this: var InstrImpl): void =
  var r16, rm16: uint16
  rm16 = this.exec.getRm16()
  r16 = this.exec.getR16()
  this.exec.setRm16(rm16 and r16)
  CPU.eflags.updateAND(rm16, r16)

proc andR16Rm16*(this: var InstrImpl): void =
  var rm16, r16: uint16
  r16 = this.exec.getR16()
  rm16 = this.exec.getRm16()
  this.exec.setR16(r16 and rm16)
  CPU.eflags.updateAND(r16, rm16)

proc andAxImm16*(this: var InstrImpl): void =
  var ax: uint16
  ax = CPU.getGPreg(AX)
  CPU.setGPreg(AX, ax and this.imm16.uint16)
  CPU.eflags.updateAND(ax, this.imm16.uint16)

proc subRm16R16*(this: var InstrImpl): void =
  var r16, rm16: uint16
  rm16 = this.exec.getRm16()
  r16 = this.exec.getR16()
  this.exec.setRm16(rm16 - r16)
  CPU.eflags.updateSUB(rm16, r16)

proc subR16Rm16*(this: var InstrImpl): void =
  var rm16, r16: uint16
  r16 = this.exec.getR16()
  rm16 = this.exec.getRm16()
  this.exec.setR16(r16 - rm16)
  CPU.eflags.updateSUB(r16, rm16)

proc subAxImm16*(this: var InstrImpl): void =
  var ax: uint16
  ax = CPU.getGPreg(AX)
  CPU.setGPreg(AX, ax - this.imm16.uint16)
  CPU.eflags.updateSUB(ax, this.imm16.uint16)

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
  ax = CPU.getGPreg(AX)
  CPU.setGPreg(AX, ax xor this.imm16.uint16)

proc cmpRm16R16*(this: var InstrImpl): void =
  var r16, rm16: uint16
  rm16 = this.exec.getRm16()
  r16 = this.exec.getR16()
  CPU.eflags.updateSUB(rm16, r16)

proc cmpR16Rm16*(this: var InstrImpl): void =
  var rm16, r16: uint16
  r16 = this.exec.getR16()
  rm16 = this.exec.getRm16()
  CPU.eflags.updateSUB(r16, rm16)

proc cmpAxImm16*(this: var InstrImpl): void =
  var ax: uint16
  ax = CPU.getGPreg(AX)
  CPU.eflags.updateSUB(ax, this.imm16.uint16)

proc incR16*(this: var InstrImpl): void =
  var reg: uint8
  var r16: uint16
  reg = uint8(this.idata.opcode and ((1 shl 3) - 1))
  r16 = CPU.getGPreg(Reg16T(reg))
  CPU.setGPreg(Reg16T(reg), r16 + 1)
  CPU.eflags.updateADD(r16, 1)

proc decR16*(this: var InstrImpl): void =
  let reg: uint8 = uint8(this.idata.opcode and ((1 shl 3) - 1))
  let r16: uint16 = CPU.getGPreg(Reg16T(reg))
  CPU.setGPreg(Reg16T(reg), r16 - 1)
  CPU.eflags.updateSUB(r16, 1)

proc pushR16*(this: var InstrImpl): void =
  let reg: uint8 = uint8(this.idata.opcode and ((1 shl 3) - 1))
  this.push16(CPU.getGPreg(Reg16T(reg)))

proc popR16*(this: var InstrImpl): void =
  let reg: uint8 = uint8(this.idata.opcode and ((1 shl 3) - 1))
  CPU.setGPreg(Reg16T(reg), this.pop16())

proc pusha*(this: var InstrImpl): void =
  let sp: uint16 = CPU.getGPreg(SP)
  this.push16(CPU.getGPreg(AX))
  this.push16(CPU.getGPreg(CX))
  this.push16(CPU.getGPreg(DX))
  this.push16(CPU.getGPreg(BX))
  this.push16(sp)
  this.push16(CPU.getGPreg(BP))
  this.push16(CPU.getGPreg(SI))
  this.push16(CPU.getGPreg(DI))

proc popa*(this: var InstrImpl): void =
  var sp: uint16
  CPU.setGPreg(DI, this.pop16())
  CPU.setGPreg(SI, this.pop16())
  CPU.setGPreg(BP, this.pop16())
  sp = this.pop16()
  CPU.setGPreg(BX, this.pop16())
  CPU.setGPreg(DX, this.pop16())
  CPU.setGPreg(CX, this.pop16())
  CPU.setGPreg(AX, this.pop16())
  CPU.setGPreg(SP, sp)

proc pushImm16*(this: var InstrImpl): void =
  this.push16(this.imm16.uint16)

proc imulR16Rm16Imm16*(this: var InstrImpl): void =
  var rm16S: int16
  rm16S = this.exec.getRm16().int16
  this.exec.setR16(uint16(rm16S * this.imm16()))
  CPU.eflags.updateIMUL(rm16S, this.imm16())

proc pushImm8*(this: var InstrImpl): void =
  this.push16(this.imm8.uint8)

proc imulR16Rm16Imm8*(this: var InstrImpl): void =
  var rm16S: int16
  rm16S = this.exec.getRm16().int16
  this.exec.setR16(uint16(rm16S * this.imm8))
  CPU.eflags.updateIMUL(rm16S, this.imm8)

proc testRm16R16*(this: var InstrImpl): void =
  var r16, rm16: uint16
  rm16 = this.exec.getRm16()
  r16 = this.exec.getR16()
  CPU.eflags.updateAND(rm16, r16)

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
  ax = CPU.getGPreg(AX)
  this.exec.setR16(ax)
  CPU.setGPreg(AX, r16)

proc cbw*(this: var InstrImpl): void =
  var alS: int8
  alS = CPU.getGPreg(AL).int8
  CPU.setGPreg(AX, alS.uint16)

proc cwd*(this: var InstrImpl): void =
  var ax: uint16
  ax = CPU.getGPreg(AX)
  CPU.setGPreg(DX, uint16(if toBool(ax and (1 shl 15)): -1 else: 0))

proc callfPtr1616*(this: var InstrImpl): void =
  this.exec.callf(this.ptr16.uint16, this.imm16.uint32)

proc pushf*(this: var InstrImpl): void =
  this.push16(CPU.eflags.getFlags())

proc popf*(this: var InstrImpl): void =
  CPU.eflags.setFlags(this.pop16())

proc movAxMoffs16*(this: var InstrImpl): void =
  CPU.setGPreg(AX, this.exec.getMoffs16())

proc movMoffs16Ax*(this: var InstrImpl): void =
  this.exec.setMoffs16(CPU.getGPreg(AX))

proc cmpsM8M8*(this: var InstrImpl): void =
  var m8D, m8S: uint8
  var repeat = true
  while repeat:
    m8S = ACS.getData8(this.exec.selectSegment(), CPU.getGPreg(SI))
    m8D = ACS.getData8(ES, CPU.getGPreg(DI))
    CPU.eflags.updateSUB(m8S, m8D)
    discard UPDATEGPREG(SI, int16(if EFLAGSDF: -1 else: 1))
    discard UPDATEGPREG(DI, int16(if EFLAGSDF: -1 else: 1))
    if this.getPreRepeat() != NONE:
      discard UPDATEGPREG(CX, -1)
      case this.getPreRepeat():
        of REPZ:
          if not(CPU.getGPreg(CX)).toBool() or not(EFLAGSZF):
            repeat = false

        of REPNZ:
          if not(CPU.getGPreg(CX)).toBool() or EFLAGSZF:
            repeat = false

        else:
          discard


proc cmpsM16M16*(this: var InstrImpl): void =
  var m16D, m16S: uint16
  block repeat:
    m16S = ACS.getData16(this.exec.selectSegment(), CPU.getGPreg(SI))
  m16D = ACS.getData16(ES, CPU.getGPreg(DI))
  CPU.eflags.updateSUB(m16S, m16D)
  discard UPDATEGPREG(SI, (if EFLAGSDF: -1 else: 1))
  discard UPDATEGPREG(DI, (if EFLAGSDF: -1 else: 1))
  if this.getPreRepeat() != NONE:
    discard UPDATEGPREG(CX, -1)
    case this.getPreRepeat():
      of REPZ:
        if not(CPU.getGPreg(CX)).toBool() or not(EFLAGSZF):
          {.warning: "[FIXME] break".}

        {.warning: "[FIXME] cxxGoto repeat".}
      of REPNZ:
        if not(CPU.getGPreg(CX)).toBool() or EFLAGSZF:
          {.warning: "[FIXME] break".}

        {.warning: "[FIXME] cxxGoto repeat".}
      else:
        discard


proc testAxImm16*(this: var InstrImpl): void =
  var ax: uint16
  ax = CPU.getGPreg(AX)
  CPU.eflags.updateAND(ax, this.imm16.uint16)

proc movR16Imm16*(this: var InstrImpl): void =
  let reg: uint8 = uint8(this.idata.opcode and ((1 shl 3) - 1))
  CPU.setGPreg(Reg16T(reg), this.imm16.uint16)

proc ret*(this: var InstrImpl): void =
  SETIP(this.pop16())

proc movRm16Imm16*(this: var InstrImpl): void =
  this.exec.setRm16(this.imm16.uint16)

proc leave*(this: var InstrImpl): void =
  var ebp: uint16
  ebp = CPU.getGPreg(EBP).uint16()
  CPU.setGPreg(ESP, ebp)
  CPU.setGPreg(EBP, this.pop16())

proc inAxImm8*(this: var InstrImpl): void =
  CPU.setGPreg(AX, EIO.inIo16(this.imm8.uint16))

proc outImm8Ax*(this: var InstrImpl): void =
  var ax: uint16
  ax = CPU.getGPreg(AX).uint16()
  EIO.outIo16(this.imm8.uint16, ax)

proc callRel16*(this: var InstrImpl): void =
  this.push16(GETIP().uint16)
  CPU.updateIp(this.imm16.int32)

proc jmpRel16*(this: var InstrImpl): void =
  CPU.updateIp(this.imm16.int32)

proc jmpfPtr1616*(this: var InstrImpl): void =
  this.exec.jmpf(this.ptr16.uint16, this.imm16.uint32)

proc inAxDx*(this: var InstrImpl): void =
  var dx: uint16
  dx = CPU.getGPreg(DX).uint16()
  CPU.setGPreg(AX, EIO.inIo16(dx))

proc outDxAx*(this: var InstrImpl): void =
  var ax, dx: uint16
  dx = CPU.getGPreg(DX)
  ax = CPU.getGPreg(AX)
  EIO.outIo16(dx, ax)

template JCCREL16*(cc: untyped, isFlag: untyped): untyped {.dirty.} =
  proc `j cc rel16`*(this: var InstrImpl): void =
    if isFlag:
      CPU.updateEIp(this.imm16.int32)

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
  CPU.eflags.updateIMUL(r16S, rm16S)

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
  this.exec.setRm16(rm16 + this.imm16.uint16)
  CPU.eflags.updateADD(rm16, this.imm16.uint16)

proc orRm16Imm16*(this: var InstrImpl): void =
  var rm16: uint16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(rm16 or this.imm16.uint16)
  CPU.eflags.updateOR(rm16, this.imm16.uint16)

proc adcRm16Imm16*(this: var InstrImpl): void =
  var rm16: uint16
  var cf: uint8
  rm16 = this.exec.getRm16()
  cf = EFLAGSCF.uint8
  this.exec.setRm16(rm16 + this.imm16.uint16 + cf)
  CPU.eflags.updateADD(rm16, this.imm16.uint16 + cf)

proc sbbRm16Imm16*(this: var InstrImpl): void =
  var rm16: uint16
  var cf: uint8
  rm16 = this.exec.getRm16()
  cf = EFLAGSCF.uint8
  this.exec.setRm16(rm16 - this.imm16.uint16 - cf)
  CPU.eflags.updateSUB(rm16, this.imm16.uint16 + cf)

proc andRm16Imm16*(this: var InstrImpl): void =
  var rm16: uint16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(rm16 and this.imm16.uint16)
  CPU.eflags.updateAND(rm16, this.imm16.uint16)

proc subRm16Imm16*(this: var InstrImpl): void =
  var rm16: uint16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(rm16 - this.imm16.uint16)
  CPU.eflags.updateSUB(rm16, this.imm16.uint16)

proc xorRm16Imm16*(this: var InstrImpl): void =
  var rm16: uint16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(rm16 xor this.imm16.uint16)

proc cmpRm16Imm16*(this: var InstrImpl): void =
  var rm16: uint16
  rm16 = this.exec.getRm16()
  CPU.eflags.updateSUB(rm16, this.imm16.uint16)


proc addRm16Imm8*(this: var InstrImpl): void =
  var rm16: uint16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(rm16 + this.imm8.uint16)
  CPU.eflags.updateADD(rm16, this.imm8.uint16)

proc orRm16Imm8*(this: var InstrImpl): void =
  var rm16: uint16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(rm16 or this.imm8.uint16)
  CPU.eflags.updateOR(rm16, this.imm8.uint16)

proc adcRm16Imm8*(this: var InstrImpl): void =
  var rm16: uint16
  var cf: uint8
  rm16 = this.exec.getRm16()
  cf = EFLAGSCF.uint8
  this.exec.setRm16(rm16 + this.imm8.uint16 + cf)
  CPU.eflags.updateADD(rm16, this.imm8.uint8 + cf)

proc sbbRm16Imm8*(this: var InstrImpl): void =
  var rm16: uint16
  var cf: uint8
  rm16 = this.exec.getRm16()
  cf = EFLAGSCF.uint8
  this.exec.setRm16(rm16 - this.imm8.uint8 - cf)
  CPU.eflags.updateSUB(rm16, this.imm8.uint8 + cf)

proc andRm16Imm8*(this: var InstrImpl): void =
  var rm16: uint16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(rm16 and this.imm8.uint16)
  CPU.eflags.updateAND(rm16, this.imm8.uint16)

proc subRm16Imm8*(this: var InstrImpl): void =
  var rm16: uint16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(rm16 - this.imm8.uint8)
  CPU.eflags.updateSUB(rm16, this.imm8.uint16)

proc xorRm16Imm8*(this: var InstrImpl): void =
  var rm16: uint16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(rm16 xor this.imm8.uint16)

proc cmpRm16Imm8*(this: var InstrImpl): void =
  var rm16: uint16
  rm16 = this.exec.getRm16()
  CPU.eflags.updateSUB(rm16, this.imm8.uint16)


proc shlRm16Imm8*(this: var InstrImpl): void =
  var rm16: uint16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(rm16 shl this.imm8)
  CPU.eflags.updateSHL(rm16, this.imm8.uint8)

proc shrRm16Imm8*(this: var InstrImpl): void =
  var rm16: uint16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(rm16 shr this.imm8)
  CPU.eflags.updateSHR(rm16, this.imm8.uint8)

proc salRm16Imm8*(this: var InstrImpl): void =
  var rm16S: int16
  rm16S = this.exec.getRm16().int16
  this.exec.setRm16(uint16(rm16S shl this.imm8))


proc sarRm16Imm8*(this: var InstrImpl): void =
  var rm16S: int16
  rm16S = this.exec.getRm16().int16
  this.exec.setRm16(uint16(rm16S shr this.imm8))



proc shlRm16Cl*(this: var InstrImpl): void =
  var rm16: uint16
  var cl: uint8
  rm16 = this.exec.getRm16()
  cl = CPU.getGPreg(CL)
  this.exec.setRm16(rm16 shl cl)
  CPU.eflags.updateSHL(rm16, cl.uint8)

proc shrRm16Cl*(this: var InstrImpl): void =
  var rm16: uint16
  var cl: uint8
  rm16 = this.exec.getRm16()
  cl = CPU.getGPreg(CL)
  this.exec.setRm16(rm16 shr cl)
  CPU.eflags.updateSHR(rm16, cl.uint8)

proc salRm16Cl*(this: var InstrImpl): void =
  var rm16S: int16
  var cl: uint8
  rm16S = this.exec.getRm16().int16
  cl = CPU.getGPreg(CL)
  this.exec.setRm16(uint16(rm16S shl cl))


proc sarRm16Cl*(this: var InstrImpl): void =
  var rm16S: int16
  var cl: uint8
  rm16S = this.exec.getRm16().int16
  cl = CPU.getGPreg(CL)
  this.exec.setRm16(uint16(rm16S shr cl))



proc testRm16Imm16*(this: var InstrImpl): void =
  var imm16, rm16: uint16
  rm16 = this.exec.getRm16()
  imm16 = ACS.getCode16(0)
  CPU.updateEIp(2)
  CPU.eflags.updateAND(rm16, this.imm16().uint16)

proc notRm16*(this: var InstrImpl): void =
  var rm16: uint16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(not(rm16))

proc negRm16*(this: var InstrImpl): void =
  var rm16S: int16
  rm16S = this.exec.getRm16().int16
  this.exec.setRm16(uint16(-(rm16S)))
  CPU.eflags.updateSUB(cast[uint16](0), rm16S.uint32)

proc mulDxAxRm16*(this: var InstrImpl): void =
  var ax, rm16: uint16
  var val: uint32
  rm16 = this.exec.getRm16()
  ax = CPU.getGPreg(AX)
  val = ax * rm16
  CPU.setGPreg(AX, uint16(val and ((1 shl 16) - 1)))
  CPU.setGPreg(DX, uint16((val shr 16) and ((1 shl 16) - 1)))
  CPU.eflags.updateMUL(ax, rm16)

proc imulDxAxRm16*(this: var InstrImpl): void =
  var axS, rm16S: int16
  var valS: int32
  rm16S = this.exec.getRm16().int16
  axS = CPU.getGPreg(AX).int16
  valS = axS * rm16S
  CPU.setGPreg(AX, uint16(valS and ((1 shl 16) - 1)))
  CPU.setGPreg(DX, uint16((valS shr 16) and ((1 shl 16) - 1)))
  CPU.eflags.updateIMUL(axS, rm16S)

proc divDxAxRm16*(this: var InstrImpl): void =
  var rm16: uint16
  var val: uint32
  rm16 = this.exec.getRm16()
  EXCEPTION(EXPDE, not(rm16.toBool()))
  val = (CPU.getGPreg(DX) shl 16) or CPU.getGPreg(AX)
  CPU.setGPreg(AX, uint16(val div rm16))
  CPU.setGPreg(DX, uint16(val mod rm16))

proc idivDxAxRm16*(this: var InstrImpl): void =
  var rm16S: int16
  var valS: int32
  rm16S = this.exec.getRm16().int16
  EXCEPTION(EXPDE, not(rm16S.toBool()))
  valS = int32((CPU.getGPreg(DX) shl 16) or CPU.getGPreg(AX))
  CPU.setGPreg(AX, uint16(valS div rm16S))
  CPU.setGPreg(DX, uint16(valS mod rm16S))


proc incRm16*(this: var InstrImpl): void =
  var rm16: uint16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(rm16 + 1)
  CPU.eflags.updateADD(rm16, 1)

proc decRm16*(this: var InstrImpl): void =
  var rm16: uint16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(rm16 - 1)
  CPU.eflags.updateSUB(rm16, 1)

proc callRm16*(this: var InstrImpl): void =
  var rm16: uint16
  rm16 = this.exec.getRm16()
  this.push16(GETIP().uint16)
  SETIP(rm16)

proc callfM1616*(this: var InstrImpl): void =
  var ip, m32, cs: uint16
  m32 = this.exec.getM().uint16
  ip = READMEM16(m32)
  cs = READMEM16(m32 + 2)
  this.exec.callf(cs, ip.uint32)

proc jmpRm16*(this: var InstrImpl): void =
  var rm16: uint16
  rm16 = this.exec.getRm16()
  SETIP(rm16)

proc jmpfM1616*(this: var InstrImpl): void =
  var ip, m32, sel: uint16
  m32 = this.exec.getM().uint16
  ip = READMEM16(m32)
  sel = READMEM16(m32 + 2)
  this.exec.jmpf(sel, ip.uint32)

proc pushRm16*(this: var InstrImpl): void =
  var rm16: uint16
  rm16 = this.exec.getRm16()
  this.push16(rm16)


proc lgdtM24*(this: var InstrImpl): void =
  var limit, m48, base: uint16
  EXCEPTION(EXPGP, not(this.exec.chkRing(0)))
  m48 = this.exec.getM().uint16
  limit = READMEM16(m48)
  base = uint16(READMEM32(m48 + 2) and ((1 shl 24) - 1))
  this.exec.setGdtr(base.uint32, limit)

proc lidtM24*(this: var InstrImpl): void =
  var limit, base, m48: uint16
  EXCEPTION(EXPGP, not(this.exec.chkRing(0)))
  m48 = this.exec.getM().uint16
  limit = READMEM16(m48)
  base = uint16(READMEM32(m48 + 2) and ((1 shl 24) - 1))
  this.exec.setIdtr(base.uint32, limit)

proc code81*(this: var InstrImpl): void =
  case this.getModrmReg():
    of 0: this.addRm16Imm16()
    of 1: this.orRm16Imm16()
    of 2: this.adcRm16Imm16()
    of 3: this.sbbRm16Imm16()
    of 4: this.andRm16Imm16()
    of 5: this.subRm16Imm16()
    of 6: this.xorRm16Imm16()
    of 7: this.cmpRm16Imm16()
    else:
      ERROR("not implemented: 0x81 /%d\\n", this.getModrmReg())

proc code83*(this: var InstrImpl): void =
  case this.getModrmReg():
    of 0: this.addRm16Imm8()
    of 1: this.orRm16Imm8()
    of 2: this.adcRm16Imm8()
    of 3: this.sbbRm16Imm8()
    of 4: this.andRm16Imm8()
    of 5: this.subRm16Imm8()
    of 6: this.xorRm16Imm8()
    of 7: this.cmpRm16Imm8()
    else:
      ERROR("not implemented: 0x83 /%d\\n", this.getModrmReg())

proc codeC1*(this: var InstrImpl): void =
  case this.getModrmReg():
    of 4: this.shlRm16Imm8()
    of 5: this.shrRm16Imm8()
    of 6: this.salRm16Imm8()
    of 7: this.sarRm16Imm8()
    else:
      ERROR("not implemented: 0xc1 /%d\\n", this.getModrmReg())

proc codeD3*(this: var InstrImpl): void =
  case this.getModrmReg():
    of 4: this.shlRm16Cl()
    of 5: this.shrRm16Cl()
    of 6: this.salRm16Cl()
    of 7: this.sarRm16Cl()
    else:
      ERROR("not implemented: 0xd3 /%d\\n", this.getModrmReg())

proc codeF7*(this: var InstrImpl): void =
  case this.getModrmReg():
    of 0: this.testRm16Imm16()
    of 2: this.notRm16()
    of 3: this.negRm16()
    of 4: this.mulDxAxRm16()
    of 5: this.imulDxAxRm16()
    of 6: this.divDxAxRm16()
    of 7: this.idivDxAxRm16()
    else:
      ERROR("not implemented: 0xf7 /%d\\n", this.getModrmReg())

proc codeFf*(this: var InstrImpl): void =
  case this.getModrmReg():
    of 0: this.incRm16()
    of 1: this.decRm16()
    of 2: this.callRm16()
    of 3: this.callfM1616()
    of 4: this.jmpRm16()
    of 5: this.jmpfM1616()
    of 6: this.pushRm16()
    else:
      ERROR("not implemented: 0xff /%d\\n", this.getModrmReg())

proc code0f00*(this: var InstrImpl): void =
  case this.getModrmReg():
    of 3: this.ltrRm16()
    else: ERROR("not implemented: 0x0f00 /%d\\n", this.getModrmReg())

proc code0f01*(this: var InstrImpl): void =
  case this.getModrmReg():
    of 2: this.lgdtM24()
    of 3: this.lidtM24()
    else:
      ERROR("not implemented: 0x0f01 /%d\\n", this.getModrmReg())


proc initInstrImpl16*(r: var InstrImpl, instr: ExecInstr) =
  initInstrImpl(r, instr)
  assertRef(r.exec.get_emu())

  r.setFuncflag(ICode(0x01), instr16(addRm16R16),       CHKMODRM)

  r.setFuncflag(ICode(0x03), instr16(addR16Rm16),       CHKMODRM)

  r.setFuncflag(ICode(0x05), instr16(addAxImm16),       CHKIMM16)
  r.setFuncflag(ICode(0x06), instr16(pushEs),           {})
  r.setFuncflag(ICode(0x07), instr16(popEs),            {})

  r.setFuncflag(ICode(0x09), instr16(orRm16R16),        CHKMODRM)

  r.setFuncflag(ICode(0x0b), instr16(orR16Rm16),        CHKMODRM)

  r.setFuncflag(ICode(0x0d), instr16(orAxImm16),        CHKIMM16)
  r.setFuncflag(ICode(0x16), instr16(pushSs),           {})
  r.setFuncflag(ICode(0x17), instr16(popSs),            {})
  r.setFuncflag(ICode(0x1e), instr16(pushDs),           {})
  r.setFuncflag(ICode(0x1f), instr16(popDs),            {})

  r.setFuncflag(ICode(0x21), instr16(andRm16R16),       CHKMODRM)

  r.setFuncflag(ICode(0x23), instr16(andR16Rm16),       CHKMODRM)

  r.setFuncflag(ICode(0x25), instr16(andAxImm16),       CHKIMM16)

  r.setFuncflag(ICode(0x29), instr16(subRm16R16),       CHKMODRM)

  r.setFuncflag(ICode(0x2b), instr16(subR16Rm16),       CHKMODRM)

  r.setFuncflag(ICode(0x2d), instr16(subAxImm16),       CHKIMM16)

  r.setFuncflag(ICode(0x31), instr16(xorRm16R16),       CHKMODRM)

  r.setFuncflag(ICode(0x33), instr16(xorR16Rm16),       CHKMODRM)

  r.setFuncflag(ICode(0x35), instr16(xorAxImm16),       CHKIMM16)

  r.setFuncflag(ICode(0x39), instr16(cmpRm16R16),       CHKMODRM)

  r.setFuncflag(ICode(0x3b), instr16(cmpR16Rm16),       CHKMODRM)

  r.setFuncflag(ICode(0x3d), instr16(cmpAxImm16),       CHKIMM16)

  r.setFuncflag(ICode(0x40), instr16(incR16),           {})
  r.setFuncflag(ICode(0x48), instr16(decR16),           {})
  r.setFuncflag(ICode(0x50), instr16(pushR16),          {})
  r.setFuncflag(ICode(0x58), instr16(popR16),           {})

  r.setFuncflag(ICode(0x60), instr16(pusha),            {})
  r.setFuncflag(ICode(0x61), instr16(popa),             {})
  r.setFuncflag(ICode(0x68), instr16(pushImm16),        CHKIMM16)
  r.setFuncflag(ICode(0x69), instr16(imulR16Rm16Imm16), CHKMODRM + CHKIMM16)
  r.setFuncflag(ICode(0x6a), instr16(pushImm8),         CHKIMM8)
  r.setFuncflag(ICode(0x6b), instr16(imulR16Rm16Imm8),  CHKMODRM + CHKIMM8)


  r.setFuncflag(ICode(0x85), instr16(testRm16R16),  CHKMODRM)

  r.setFuncflag(ICode(0x87), instr16(xchgR16Rm16),  CHKMODRM)

  r.setFuncflag(ICode(0x89), instr16(movRm16R16),   CHKMODRM)

  r.setFuncflag(ICode(0x8b), instr16(movR16Rm16),   CHKMODRM)
  r.setFuncflag(ICode(0x8c), instr16(movRm16Sreg),  CHKMODRM)
  r.setFuncflag(ICode(0x8d), instr16(leaR16M16),    CHKMODRM)

  r.setFuncflag(ICode(0x90), instr16(xchgR16Ax),    CHKIMM16)

  r.setFuncflag(ICode(0x98), instr16(cbw),          {})
  r.setFuncflag(ICode(0x99), instr16(cwd),          {})
  r.setFuncflag(ICode(0x9a), instr16(callfPtr1616), CHKPTR16 + CHKIMM16)
  r.setFuncflag(ICode(0x9c), instr16(pushf),        {})
  r.setFuncflag(ICode(0x9d), instr16(popf),         {})

  r.setFuncflag(ICode(0xa1), instr16(movAxMoffs16), CHKMOFFS)

  r.setFuncflag(ICode(0xa3), instr16(movMoffs16Ax), CHKMOFFS)
  r.setFuncflag(ICode(0xa6), instr16(cmpsM8M8),     {})
  r.setFuncflag(ICode(0xa7), instr16(cmpsM16M16),   {})

  r.setFuncflag(ICode(0xa9), instr16(testAxImm16),  CHKIMM16)

  r.setFuncflag(ICOde(0xb8), instr16(movR16Imm16),  CHKIMM16)

  r.setFuncflag(ICode(0xc3), instr16(ret),          {})
  r.setFuncflag(ICode(0xc7), instr16(movRm16Imm16), CHKMODRM + CHKIMM16)
  r.setFuncflag(ICode(0xc9), instr16(leave),        {})


  r.setFuncflag(ICode(0xe5), instr16(inAxImm8),    CHKIMM8)

  r.setFuncflag(ICode(0xe7), instr16(outImm8Ax),   CHKIMM8)
  r.setFuncflag(ICode(0xe8), instr16(callRel16),   CHKIMM16)
  r.setFuncflag(ICode(0xe9), instr16(jmpRel16),    CHKIMM16)
  r.setFuncflag(ICode(0xea), instr16(jmpfPtr1616), CHKPTR16 + CHKIMM16)


  r.setFuncflag(ICode(0xed), instr16(inAxDx), {})

  r.setFuncflag(ICode(0xef), instr16(outDxAx), {})
  r.setFuncflag(ICode(0x0f80), instr16(joRel16), CHKIMM16)
  r.setFuncflag(ICode(0x0f81), instr16(jnoRel16), CHKIMM16)
  r.setFuncflag(ICode(0x0f82), instr16(jbRel16), CHKIMM16)
  r.setFuncflag(ICode(0x0f83), instr16(jnbRel16), CHKIMM16)
  r.setFuncflag(ICode(0x0f84), instr16(jzRel16), CHKIMM16)
  r.setFuncflag(ICode(0x0f85), instr16(jnzRel16), CHKIMM16)
  r.setFuncflag(ICode(0x0f86), instr16(jbeRel16), CHKIMM16)
  r.setFuncflag(ICode(0x0f87), instr16(jaRel16), CHKIMM16)
  r.setFuncflag(ICode(0x0f88), instr16(jsRel16), CHKIMM16)
  r.setFuncflag(ICode(0x0f89), instr16(jnsRel16), CHKIMM16)
  r.setFuncflag(ICode(0x0f8a), instr16(jpRel16), CHKIMM16)
  r.setFuncflag(ICode(0x0f8b), instr16(jnpRel16), CHKIMM16)
  r.setFuncflag(ICode(0x0f8c), instr16(jlRel16), CHKIMM16)
  r.setFuncflag(ICode(0x0f8d), instr16(jnlRel16), CHKIMM16)
  r.setFuncflag(ICode(0x0f8e), instr16(jleRel16), CHKIMM16)
  r.setFuncflag(ICode(0x0f8f), instr16(jnleRel16), CHKIMM16)
  r.setFuncflag(ICode(0x0faf), instr16(imulR16Rm16), CHKMODRM)
  r.setFuncflag(ICode(0x0fb6), instr16(movzxR16Rm8), CHKMODRM)
  r.setFuncflag(ICode(0x0fb7), instr16(movzxR16Rm16), CHKMODRM)
  r.setFuncflag(ICode(0x0fbe), instr16(movsxR16Rm8), CHKMODRM)
  r.setFuncflag(ICode(0x0fbf), instr16(movsxR16Rm16), CHKMODRM)

  r.setFuncflag(ICode(0x81), instr16(code81), CHKMODRM + CHKIMM16)

  r.setFuncflag(ICode(0x83), instr16(code83), CHKMODRM + CHKIMM8)

  r.setFuncflag(ICode(0xc1), instr16(codeC1), CHKMODRM + CHKIMM8)
  r.setFuncflag(ICode(0xd3), instr16(codeD3), CHKMODRM)
  r.setFuncflag(ICode(0xf7), instr16(codeF7), CHKMODRM)
  r.setFuncflag(ICode(0xff), instr16(codeFf), CHKMODRM)
  r.setFuncflag(ICode(0x0f00), instr16(code0f00), CHKMODRM)
  r.setFuncflag(ICode(0x0f01), instr16(code0f01), CHKMODRM)


proc initInstrImpl16*(instr: ExecInstr): InstrImpl =
  initInstrImpl16(result, instr)
  assertRef(result.exec.get_emu())
