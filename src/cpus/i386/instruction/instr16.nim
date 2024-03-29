import instruction/[instruction]
import instr_base
import common
import ./emu
import ./exec
import hardware/eflags
import hardware/[processor, eflags, io]
import emulator/[emulator, access]

template instr16*(f: untyped): untyped {.dirty.} =
  instrfuncT(f)

proc addRm16R16*(this: var InstrImpl) =
  var r16, rm16: U16
  rm16 = this.exec.getRm16()
  r16 = this.exec.getR16()
  this.exec.setRm16(rm16 + r16)
  CPU.eflags.updateADD(rm16, r16)

proc addR16Rm16*(this: var InstrImpl) =
  var rm16, r16: U16
  r16 = this.exec.getR16()
  rm16 = this.exec.getRm16()
  this.exec.setR16(r16 + rm16)
  CPU.eflags.updateADD(r16, rm16)

proc addAxImm16*(this: var InstrImpl) =
  var ax: U16
  ax = CPU[AX]
  CPU[AX] = ax + this.imm16.U16
  CPU.eflags.updateADD(ax, this.imm16.U16)

proc pushEs*(this: var InstrImpl) =
  this.push16(ACS.getSegment(ES))

proc popEs*(this: var InstrImpl) =
  ACS.setSegment(ES, this.pop16())

proc orRm16R16*(this: var InstrImpl) =
  var r16, rm16: U16
  rm16 = this.exec.getRm16()
  r16 = this.exec.getR16()
  this.exec.setRm16(rm16 or r16)
  CPU.eflags.updateOR(rm16, r16)

proc orR16Rm16*(this: var InstrImpl) =
  var rm16, r16: U16
  r16 = this.exec.getR16()
  rm16 = this.exec.getRm16()
  this.exec.setR16(r16 or rm16)
  CPU.eflags.updateOR(r16, rm16)

proc orAxImm16*(this: var InstrImpl) =
  var ax: U16
  ax = CPU[AX]
  CPU[AX] = ax or this.imm16.U16
  CPU.eflags.updateOR(ax, this.imm16.U16)

proc pushSs*(this: var InstrImpl) =
  this.push16(ACS.getSegment(SS))

proc popSs*(this: var InstrImpl) =
  ACS.setSegment(SS, this.pop16())

proc pushDs*(this: var InstrImpl) =
  this.push16(ACS.getSegment(DS))

proc popDs*(this: var InstrImpl) =
  ACS.setSegment(DS, this.pop16())

proc andRm16R16*(this: var InstrImpl) =
  var r16, rm16: U16
  rm16 = this.exec.getRm16()
  r16 = this.exec.getR16()
  this.exec.setRm16(rm16 and r16)
  CPU.eflags.updateAND(rm16, r16)

proc andR16Rm16*(this: var InstrImpl) =
  var rm16, r16: U16
  r16 = this.exec.getR16()
  rm16 = this.exec.getRm16()
  this.exec.setR16(r16 and rm16)
  CPU.eflags.updateAND(r16, rm16)

proc andAxImm16*(this: var InstrImpl) =
  var ax: U16
  ax = CPU[AX]
  CPU[AX] = ax and this.imm16.U16
  CPU.eflags.updateAND(ax, this.imm16.U16)

proc subRm16R16*(this: var InstrImpl) =
  let rm16 = this.exec.getRm16()
  let r16 = this.exec.getR16()
  this.exec.setRm16(rm16 - r16)
  CPU.eflags.updateSUB(rm16, r16)

proc subR16Rm16*(this: var InstrImpl) =
  var rm16, r16: U16
  r16 = this.exec.getR16()
  rm16 = this.exec.getRm16()
  this.exec.setR16(r16 - rm16)
  CPU.eflags.updateSUB(r16, rm16)

proc subAxImm16*(this: var InstrImpl) =
  var ax: U16
  ax = CPU[AX]
  CPU[AX] = ax - this.imm16.U16
  CPU.eflags.updateSUB(ax, this.imm16.U16)

proc xorRm16R16*(this: var InstrImpl) =
  var r16, rm16: U16
  rm16 = this.exec.getRm16()
  r16 = this.exec.getR16()
  this.exec.setRm16(rm16 xor r16)

proc xorR16Rm16*(this: var InstrImpl) =
  var rm16, r16: U16
  r16 = this.exec.getR16()
  rm16 = this.exec.getRm16()
  this.exec.setR16(r16 xor rm16)

proc xorAxImm16*(this: var InstrImpl) =
  var ax: U16
  ax = CPU[AX]
  CPU[AX] = ax xor this.imm16.U16

proc cmpRm16R16*(this: var InstrImpl) =
  var r16, rm16: U16
  rm16 = this.exec.getRm16()
  r16 = this.exec.getR16()
  CPU.eflags.updateSUB(rm16, r16)

proc cmpR16Rm16*(this: var InstrImpl) =
  var rm16, r16: U16
  r16 = this.exec.getR16()
  rm16 = this.exec.getRm16()
  CPU.eflags.updateSUB(r16, rm16)

proc cmpAxImm16*(this: var InstrImpl) =
  var ax: U16
  ax = CPU[AX]
  CPU.eflags.updateSUB(ax, this.imm16.U16)

proc incR16*(this: var InstrImpl) =
  var reg: U8
  var r16: U16
  reg = U8(this.idata.opcode and ((1 shl 3) - 1))
  r16 = CPU.getGPreg(Reg16T(reg))
  CPU[Reg16T(reg)] = r16 + 1
  CPU.eflags.updateADD(r16, 1)

proc decR16*(this: var InstrImpl) =
  let reg: U8 = U8(this.idata.opcode and ((1 shl 3) - 1))
  let r16: U16 = CPU.getGPreg(Reg16T(reg))
  CPU[Reg16T(reg)] = r16 - 1
  CPU.eflags.updateSUB(r16, 1)

proc pushR16*(this: var InstrImpl) =
  let reg: U8 = U8(this.idata.opcode and ((1 shl 3) - 1))
  this.push16(CPU[Reg16T(reg)])

proc popR16*(this: var InstrImpl) =
  let reg: U8 = U8(this.idata.opcode and ((1 shl 3) - 1))
  CPU[Reg16T(reg)] = this.pop16()

proc pusha*(this: var InstrImpl) =
  let sp: U16 = CPU[SP]
  this.push16(CPU[AX])
  this.push16(CPU[CX])
  this.push16(CPU[DX])
  this.push16(CPU[BX])
  this.push16(sp)
  this.push16(CPU[BP])
  this.push16(CPU[SI])
  this.push16(CPU[DI])

proc popa*(this: var InstrImpl) =
  var sp: U16
  CPU[DI] = this.pop16()
  CPU[SI] = this.pop16()
  CPU[BP] = this.pop16()
  sp = this.pop16()
  CPU[BX] = this.pop16()
  CPU[DX] = this.pop16()
  CPU[CX] = this.pop16()
  CPU[AX] = this.pop16()
  CPU[SP] = sp

proc pushImm16*(this: var InstrImpl) =
  this.push16(this.imm16.U16)

proc imulR16Rm16Imm16*(this: var InstrImpl) =
  var rm16S: int16
  rm16S = this.exec.getRm16().int16
  this.exec.setR16(U16(rm16S * this.imm16()))
  CPU.eflags.updateIMUL(rm16S, this.imm16())

proc pushImm8*(this: var InstrImpl) =
  this.push16(this.imm8.U8)

proc imulR16Rm16Imm8*(this: var InstrImpl) =
  var rm16S: int16
  rm16S = this.exec.getRm16().int16
  this.exec.setR16(U16(rm16S * this.imm8))
  CPU.eflags.updateIMUL(rm16S, this.imm8)

proc testRm16R16*(this: var InstrImpl) =
  var r16, rm16: U16
  rm16 = this.exec.getRm16()
  r16 = this.exec.getR16()
  CPU.eflags.updateAND(rm16, r16)

proc xchgR16Rm16*(this: var InstrImpl) =
  var rm16, r16: U16
  r16 = this.exec.getR16()
  rm16 = this.exec.getRm16()
  this.exec.setR16(rm16)
  this.exec.setRm16(r16)

proc movRm16R16*(this: var InstrImpl) =
  var r16: U16
  r16 = this.exec.getR16()
  this.exec.setRm16(r16)

proc movR16Rm16*(this: var InstrImpl) =
  var rm16: U16
  rm16 = this.exec.getRm16()
  this.exec.setR16(rm16)

proc movRm16Sreg*(this: var InstrImpl) =
  var sreg: U16
  sreg = this.exec.getSreg()
  this.exec.setRm16(sreg)

proc leaR16M16*(this: var InstrImpl) =
  var m16: U16
  m16 = this.exec.getM().U16
  this.exec.setR16(m16)

proc xchgR16Ax*(this: var InstrImpl) =
  var ax, r16: U16
  r16 = this.exec.getR16()
  ax = CPU[AX]
  this.exec.setR16(ax)
  CPU[AX] = r16

proc cbw*(this: var InstrImpl) =
  var alS: int8
  alS = CPU[AL].int8
  CPU[AX] = alS.U16

proc cwd*(this: var InstrImpl) =
  var ax: U16
  ax = CPU[AX]
  CPU[DX] = U16(if toBool(ax and (1 shl 15)): -1 else: 0)

proc callfPtr1616*(this: var InstrImpl) =
  this.exec.callf(this.ptr16.U16, this.imm16.U32)

proc pushf*(this: var InstrImpl) =
  this.push16(CPU.eflags.getFlags())

proc popf*(this: var InstrImpl) =
  CPU.eflags.setFlags(this.pop16())

proc movAxMoffs16*(this: var InstrImpl) =
  CPU[AX] = this.exec.getMoffs16()

proc movMoffs16Ax*(this: var InstrImpl) =
  this.exec.setMoffs16(CPU[AX])

proc cmpsM8M8*(this: var InstrImpl) =
  var m8D, m8S: U8
  var repeat = true
  while repeat:
    m8S = ACS.getData8(this.exec.selectSegment(), CPU[SI])
    m8D = ACS.getData8(ES, CPU[DI])
    CPU.eflags.updateSUB(m8S, m8D)
    CPU.updateGPreg(SI, int16(if this.eflags.isDirection(): -1 else: 1))
    CPU.updateGPreg(DI, int16(if this.eflags.isDirection(): -1 else: 1))
    if this.getPreRepeat() != NONE:
      CPU.updateGPreg(CX, -1)
      case this.getPreRepeat():
        of REPZ:
          if not(CPU[CX]).toBool() or not(this.eflags.isZero()):
            repeat = false

        of REPNZ:
          if not(CPU[CX]).toBool() or this.eflags.isZero():
            repeat = false

        else:
          discard


proc cmpsM16M16*(this: var InstrImpl) =
  var m16D, m16S: U16
  var repeat = true
  while repeat:
    m16S = ACS.getData16(this.exec.selectSegment(), CPU[SI])
    m16D = ACS.getData16(ES, CPU[DI])
    CPU.eflags.updateSUB(m16S, m16D)
    CPU.updateGPreg(SI, (if this.eflags.isDirection(): -1 else: 1))
    CPU.updateGPreg(DI, (if this.eflags.isDirection(): -1 else: 1))
    if this.getPreRepeat() != NONE:
      CPU.updateGPreg(CX, -1)
      case this.getPreRepeat():
        of REPZ:
          if not(CPU[CX]).toBool() or not(this.eflags.isZero()):
            repeat = false

        of REPNZ:
          if not(CPU[CX]).toBool() or this.eflags.isZero():
            repeat = false

        else:
          repeat = false


proc testAxImm16*(this: var InstrImpl) =
  var ax: U16
  ax = CPU[AX]
  CPU.eflags.updateAND(ax, this.imm16.U16)

proc movR16Imm16*(this: var InstrImpl) =
  let reg: U8 = U8(this.idata.opcode and ((1 shl 3) - 1))
  CPU[Reg16T(reg)] = this.imm16.U16

proc ret*(this: var InstrImpl) =
  this.cpu.setIp(this.pop16())

proc movRm16Imm16*(this: var InstrImpl) =
  this.exec.setRm16(this.imm16.U16)

proc leave*(this: var InstrImpl) =
  var ebp: U16
  ebp = CPU[EBP].U16()
  CPU[ESP] = ebp
  CPU[EBP] = this.pop16()

proc inAxImm8*(this: var InstrImpl) =
  CPU[AX] = EIO.inIo16(this.imm8.U16)

proc outImm8Ax*(this: var InstrImpl) =
  var ax: U16
  ax = CPU[AX].U16()
  EIO.outIo16(this.imm8.U16, ax)

proc callRel16*(this: var InstrImpl) =
  this.push16(this.cpu.getIP().U16)
  CPU.updateIp(this.imm16.int32)

proc jmpRel16*(this: var InstrImpl) =
  CPU.updateIp(this.imm16.int32)

proc jmpfPtr1616*(this: var InstrImpl) =
  this.exec.jmpf(this.ptr16.U16, this.imm16.U32)

proc inAxDx*(this: var InstrImpl) =
  var dx: U16
  dx = CPU[DX].U16()
  CPU[AX] = EIO.inIo16(dx)

proc outDxAx*(this: var InstrImpl) =
  var ax, dx: U16
  dx = CPU[DX]
  ax = CPU[AX]
  EIO.outIo16(dx, ax)

template JCCREL16*(cc: untyped, isFlag: untyped): untyped {.dirty.} =
  proc `j cc rel16`*(this: var InstrImpl) =
    if isFlag:
      CPU.updateEIp(this.imm16.int32)

JCCREL16(o, this.eflags.isOverflow())
JCCREL16(no, not(this.eflags.isOverflow()))
JCCREL16(b, this.eflags.isCarry())
JCCREL16(nb, not(this.eflags.isCarry()))
JCCREL16(z, this.eflags.isZero())
JCCREL16(nz, not(this.eflags.isZero()))
JCCREL16(be, this.eflags.isCarry() or this.eflags.isZero())
JCCREL16(a, not((this.eflags.isCarry() or this.eflags.isZero())))
JCCREL16(s, this.eflags.isSign())
JCCREL16(ns, not(this.eflags.isSign()))
JCCREL16(p, this.eflags.isParity())
JCCREL16(np, not(this.eflags.isParity()))
JCCREL16(l, this.eflags.isSign() != this.eflags.isOverflow())
JCCREL16(nl, this.eflags.isSign() == this.eflags.isOverflow())
JCCREL16(le, this.eflags.isZero() or (this.eflags.isSign() != this.eflags.isOverflow()))
JCCREL16(nle, not(this.eflags.isZero()) and (this.eflags.isSign() == this.eflags.isOverflow()))

proc imulR16Rm16*(this: var InstrImpl) =
  var rm16S, r16S: int16
  r16S = this.exec.getR16().int16
  rm16S = this.exec.getRm16().int16
  this.exec.setR16(U16(r16S * rm16S))
  CPU.eflags.updateIMUL(r16S, rm16S)

proc movzxR16Rm8*(this: var InstrImpl) =
  var rm8: U8
  rm8 = this.exec.getRm8().U8
  this.exec.setR16(rm8)

proc movzxR16Rm16*(this: var InstrImpl) =
  var rm16: U16
  rm16 = this.exec.getRm16().U16
  this.exec.setR16(rm16)

proc movsxR16Rm8*(this: var InstrImpl) =
  var rm8S: int8
  rm8S = this.exec.getRm8().int8
  this.exec.setR16(rm8S.U16)

proc movsxR16Rm16*(this: var InstrImpl) =
  var rm16S: int16
  rm16S = this.exec.getRm16().int16
  this.exec.setR16(rm16S.U16)




proc addRm16Imm16*(this: var InstrImpl) =
  var rm16: U16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(rm16 + this.imm16.U16)
  CPU.eflags.updateADD(rm16, this.imm16.U16)

proc orRm16Imm16*(this: var InstrImpl) =
  var rm16: U16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(rm16 or this.imm16.U16)
  CPU.eflags.updateOR(rm16, this.imm16.U16)

proc adcRm16Imm16*(this: var InstrImpl) =
  var rm16: U16
  var cf: U8
  rm16 = this.exec.getRm16()
  cf = this.eflags.isCarry().U8
  this.exec.setRm16(rm16 + this.imm16.U16 + cf)
  CPU.eflags.updateADD(rm16, this.imm16.U16 + cf)

proc sbbRm16Imm16*(this: var InstrImpl) =
  var rm16: U16
  var cf: U8
  rm16 = this.exec.getRm16()
  cf = this.eflags.isCarry().U8
  this.exec.setRm16(rm16 - this.imm16.U16 - cf)
  CPU.eflags.updateSUB(rm16, this.imm16.U16 + cf)

proc andRm16Imm16*(this: var InstrImpl) =
  var rm16: U16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(rm16 and this.imm16.U16)
  CPU.eflags.updateAND(rm16, this.imm16.U16)

proc subRm16Imm16*(this: var InstrImpl) =
  var rm16: U16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(rm16 - this.imm16.U16)
  CPU.eflags.updateSUB(rm16, this.imm16.U16)

proc xorRm16Imm16*(this: var InstrImpl) =
  var rm16: U16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(rm16 xor this.imm16.U16)

proc cmpRm16Imm16*(this: var InstrImpl) =
  var rm16: U16
  rm16 = this.exec.getRm16()
  CPU.eflags.updateSUB(rm16, this.imm16.U16)


proc addRm16Imm8*(this: var InstrImpl) =
  var rm16: U16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(rm16 + this.imm8.U16)
  CPU.eflags.updateADD(rm16, this.imm8.U16)

proc orRm16Imm8*(this: var InstrImpl) =
  var rm16: U16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(rm16 or this.imm8.U16)
  CPU.eflags.updateOR(rm16, this.imm8.U16)

proc adcRm16Imm8*(this: var InstrImpl) =
  var rm16: U16
  var cf: U8
  rm16 = this.exec.getRm16()
  cf = this.eflags.isCarry().U8
  this.exec.setRm16(rm16 + this.imm8.U16 + cf)
  CPU.eflags.updateADD(rm16, this.imm8.U8 + cf)

proc sbbRm16Imm8*(this: var InstrImpl) =
  var rm16: U16
  var cf: U8
  rm16 = this.exec.getRm16()
  cf = this.eflags.isCarry().U8
  this.exec.setRm16(rm16 - this.imm8.U8 - cf)
  CPU.eflags.updateSUB(rm16, this.imm8.U8 + cf)

proc andRm16Imm8*(this: var InstrImpl) =
  var rm16: U16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(rm16 and this.imm8.U16)
  CPU.eflags.updateAND(rm16, this.imm8.U16)

proc subRm16Imm8*(this: var InstrImpl) =
  var rm16: U16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(rm16 - this.imm8.U8)
  CPU.eflags.updateSUB(rm16, this.imm8.U16)

proc xorRm16Imm8*(this: var InstrImpl) =
  var rm16: U16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(rm16 xor this.imm8.U16)

proc cmpRm16Imm8*(this: var InstrImpl) =
  var rm16: U16
  rm16 = this.exec.getRm16()
  CPU.eflags.updateSUB(rm16, this.imm8.U16)


proc shlRm16Imm8*(this: var InstrImpl) =
  var rm16: U16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(rm16 shl this.imm8)
  CPU.eflags.updateSHL(rm16, this.imm8.U8)

proc shrRm16Imm8*(this: var InstrImpl) =
  var rm16: U16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(rm16 shr this.imm8)
  CPU.eflags.updateSHR(rm16, this.imm8.U8)

proc salRm16Imm8*(this: var InstrImpl) =
  var rm16S: int16
  rm16S = this.exec.getRm16().int16
  this.exec.setRm16(U16(rm16S shl this.imm8))


proc sarRm16Imm8*(this: var InstrImpl) =
  var rm16S: int16
  rm16S = this.exec.getRm16().int16
  this.exec.setRm16(U16(rm16S shr this.imm8))



proc shlRm16Cl*(this: var InstrImpl) =
  var rm16: U16
  var cl: U8
  rm16 = this.exec.getRm16()
  cl = CPU[CL]
  this.exec.setRm16(rm16 shl cl)
  CPU.eflags.updateSHL(rm16, cl.U8)

proc shrRm16Cl*(this: var InstrImpl) =
  var rm16: U16
  var cl: U8
  rm16 = this.exec.getRm16()
  cl = CPU[CL]
  this.exec.setRm16(rm16 shr cl)
  CPU.eflags.updateSHR(rm16, cl.U8)

proc salRm16Cl*(this: var InstrImpl) =
  var rm16S: int16
  var cl: U8
  rm16S = this.exec.getRm16().int16
  cl = CPU[CL]
  this.exec.setRm16(U16(rm16S shl cl))


proc sarRm16Cl*(this: var InstrImpl) =
  var rm16S: int16
  var cl: U8
  rm16S = this.exec.getRm16().int16
  cl = CPU[CL]
  this.exec.setRm16(U16(rm16S shr cl))



proc testRm16Imm16*(this: var InstrImpl) =
  var imm16, rm16: U16
  rm16 = this.exec.getRm16()
  imm16 = ACS.getCode16(0)
  CPU.updateEIp(2)
  CPU.eflags.updateAND(rm16, this.imm16().U16)

proc notRm16*(this: var InstrImpl) =
  var rm16: U16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(not(rm16))

proc negRm16*(this: var InstrImpl) =
  var rm16S: int16
  rm16S = this.exec.getRm16().int16
  this.exec.setRm16(U16(-(rm16S)))
  CPU.eflags.updateSUB(cast[U16](0), rm16S.U32)

proc mulDxAxRm16*(this: var InstrImpl) =
  var ax, rm16: U16
  var val: U32
  rm16 = this.exec.getRm16()
  ax = CPU[AX]
  val = ax * rm16
  CPU[AX] = U16(val and ((1 shl 16) - 1))
  CPU[DX] = U16((val shr 16) and ((1 shl 16) - 1))
  CPU.eflags.updateMUL(ax, rm16)

proc imulDxAxRm16*(this: var InstrImpl) =
  var axS, rm16S: int16
  var valS: int32
  rm16S = this.exec.getRm16().int16
  axS = CPU[AX].int16
  valS = axS * rm16S
  CPU[AX] = U16(valS and ((1 shl 16) - 1))
  CPU[DX] = U16((valS shr 16) and ((1 shl 16) - 1))
  CPU.eflags.updateIMUL(axS, rm16S)

proc divDxAxRm16*(this: var InstrImpl) =
  var rm16: U16 = this.exec.getRm16()

  if rm16 == 0:
    raise newException(EXP_DE, "divider was zero")

  var val: U32 = (CPU[DX] shl 16) or CPU[AX]
  CPU[AX] = U16(val div rm16)
  CPU[DX] = U16(val mod rm16)

proc idivDxAxRm16*(this: var InstrImpl) =
  var rm16S: int16 = this.exec.getRm16().int16
  echov "w"
  if rm16S == 0:
    raise newException(EXP_DE, "divider was zero")
  # if not(rm16S.toBool()): raise newException(EXPDE, "")

  var valS: int32 = int32((CPU[DX] shl 16) or CPU[AX])
  CPU[AX] = U16(valS div rm16S)
  CPU[DX] = U16(valS mod rm16S)


proc incRm16*(this: var InstrImpl) =
  var rm16: U16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(rm16 + 1)
  CPU.eflags.updateADD(rm16, 1)

proc decRm16*(this: var InstrImpl) =
  var rm16: U16
  rm16 = this.exec.getRm16()
  this.exec.setRm16(rm16 - 1)
  CPU.eflags.updateSUB(rm16, 1)

proc callRm16*(this: var InstrImpl) =
  var rm16: U16
  rm16 = this.exec.getRm16()
  this.push16(this.cpu.getIP().U16)
  this.cpu.setIp(rm16)

proc callfM1616*(this: var InstrImpl) =
  var ip, m32, cs: U16
  m32 = this.exec.getM().U16
  ip = this.readMem16(m32)
  cs = this.readMem16(m32 + 2)
  this.exec.callf(cs, ip.U32)

proc jmpRm16*(this: var InstrImpl) =
  var rm16: U16
  rm16 = this.exec.getRm16()
  this.cpu.setIp(rm16)

proc jmpfM1616*(this: var InstrImpl) =
  var ip, m32, sel: U16
  m32 = this.exec.getM().U16
  ip = this.readMem16(m32)
  sel = this.readMem16(m32 + 2)
  this.exec.jmpf(sel, ip.U32)

proc pushRm16*(this: var InstrImpl) =
  var rm16: U16
  rm16 = this.exec.getRm16()
  this.push16(rm16)


proc lgdtM24*(this: var InstrImpl) =
  var limit, m48, base: U16
  if not(this.exec.chkRing(0)): raise newException(EXPGP, "")
  m48 = this.exec.getM().U16
  limit = this.readMem16(m48)
  base = U16(this.readMem32(m48 + 2) and ((1 shl 24) - 1))
  this.exec.setGdtr(base.U32, limit)

proc lidtM24*(this: var InstrImpl) =
  var limit, base, m48: U16
  if not(this.exec.chkRing(0)): raise newException(EXPGP, "")
  m48 = this.exec.getM().U16
  limit = this.readMem16(m48)
  base = U16(this.readMem32(m48 + 2) and ((1 shl 24) - 1))
  this.exec.setIdtr(base.U32, limit)

proc code81*(this: var InstrImpl) =
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

# proc code83*(this: var InstrImpl) =
#   case this.getModrmReg():
#     of 0: this.addRm16Imm8()
#     of 1: this.orRm16Imm8()
#     of 2: this.adcRm16Imm8()
#     of 3: this.sbbRm16Imm8()
#     of 4: this.andRm16Imm8()
#     of 5: this.subRm16Imm8()
#     of 6: this.xorRm16Imm8()
#     of 7: this.cmpRm16Imm8()
#     else:
#       ERROR("not implemented: 0x83 /%d\\n", this.getModrmReg())

proc codeC1*(this: var InstrImpl) =
  case this.getModrmReg():
    of 4: this.shlRm16Imm8()
    of 5: this.shrRm16Imm8()
    of 6: this.salRm16Imm8()
    of 7: this.sarRm16Imm8()
    else:
      ERROR("not implemented: 0xC1 /%d\\n", this.getModrmReg())

proc codeD3*(this: var InstrImpl) =
  case this.getModrmReg():
    of 4: this.shlRm16Cl()
    of 5: this.shrRm16Cl()
    of 6: this.salRm16Cl()
    of 7: this.sarRm16Cl()
    else:
      ERROR("not implemented: 0xD3 /%d\\n", this.getModrmReg())

proc codeF7*(this: var InstrImpl) =
  case this.getModrmReg():
    of 0: this.testRm16Imm16()
    of 2: this.notRm16()
    of 3: this.negRm16()
    of 4: this.mulDxAxRm16()
    of 5: this.imulDxAxRm16()
    of 6: this.divDxAxRm16()
    of 7: this.idivDxAxRm16()
    else:
      ERROR("not implemented: 0xF7 /%d\\n", this.getModrmReg())

proc codeFf*(this: var InstrImpl) =
  case this.getModrmReg():
    of 0: this.incRm16()
    of 1: this.decRm16()
    of 2: this.callRm16()
    of 3: this.callfM1616()
    of 4: this.jmpRm16()
    of 5: this.jmpfM1616()
    of 6: this.pushRm16()
    else:
      ERROR("not implemented: 0xFF /%d\\n", this.getModrmReg())

proc code0f00*(this: var InstrImpl) =
  case this.getModrmReg():
    of 3: this.ltrRm16()
    else: ERROR("not implemented: 0x0F00 /%d\\n", this.getModrmReg())

proc code0f01*(this: var InstrImpl) =
  case this.getModrmReg():
    of 2: this.lgdtM24()
    of 3: this.lidtM24()
    else:
      ERROR("not implemented: 0x0F01 /%d\\n", this.getModrmReg())


proc initInstrImpl16*(r: var InstrImpl, instr: ExecInstr) =
  initInstrImpl(r, instr)
  assertRef(r.exec.get_emu())

  r.setFuncflag(U16(0x01), instr16(addRm16R16),       CHKMODRM)

  r.setFuncflag(U16(0x03), instr16(addR16Rm16),       CHKMODRM)

  r.setFuncflag(U16(0x05), instr16(addAxImm16),       CHKIMM16)
  r.setFuncflag(U16(0x06), instr16(pushEs),           {})
  r.setFuncflag(U16(0x07), instr16(popEs),            {})

  r.setFuncflag(U16(0x09), instr16(orRm16R16),        CHKMODRM)

  r.setFuncflag(U16(0x0B), instr16(orR16Rm16),        CHKMODRM)

  r.setFuncflag(U16(0x0D), instr16(orAxImm16),        CHKIMM16)
  r.setFuncflag(U16(0x16), instr16(pushSs),           {})
  r.setFuncflag(U16(0x17), instr16(popSs),            {})
  r.setFuncflag(U16(0x1E), instr16(pushDs),           {})
  r.setFuncflag(U16(0x1F), instr16(popDs),            {})

  r.setFuncflag(U16(0x21), instr16(andRm16R16),       CHKMODRM)

  r.setFuncflag(U16(0x23), instr16(andR16Rm16),       CHKMODRM)

  r.setFuncflag(U16(0x25), instr16(andAxImm16),       CHKIMM16)

  r.setFuncflag(U16(0x29), instr16(subRm16R16),       CHKMODRM)

  r.setFuncflag(U16(0x2B), instr16(subR16Rm16),       CHKMODRM)

  r.setFuncflag(U16(0x2D), instr16(subAxImm16),       CHKIMM16)

  r.setFuncflag(U16(0x31), instr16(xorRm16R16),       CHKMODRM)

  r.setFuncflag(U16(0x33), instr16(xorR16Rm16),       CHKMODRM)

  r.setFuncflag(U16(0x35), instr16(xorAxImm16),       CHKIMM16)

  r.setFuncflag(U16(0x39), instr16(cmpRm16R16),       CHKMODRM)

  r.setFuncflag(U16(0x3B), instr16(cmpR16Rm16),       CHKMODRM)

  r.setFuncflag(U16(0x3D), instr16(cmpAxImm16),       CHKIMM16)

  for i in 0 .. 7: r.setFuncflag(U16(0x40 + i), instr16(incR16), {})
  for i in 0 .. 7: r.setFuncflag(U16(0x48 + i), instr16(decR16), {})
  for i in 0 .. 7: r.setFuncflag(U16(0x50 + i), instr16(pushR16), {})
  for i in 0 .. 7: r.setFuncflag(U16(0x58 + i), instr16(popR16), {})

  r.setFuncflag(U16(0x60), instr16(pusha),            {})
  r.setFuncflag(U16(0x61), instr16(popa),             {})
  r.setFuncflag(U16(0x68), instr16(pushImm16),        CHKIMM16)
  r.setFuncflag(U16(0x69), instr16(imulR16Rm16Imm16), CHKMODRM + CHKIMM16)
  r.setFuncflag(U16(0x6A), instr16(pushImm8),         CHKIMM8)
  r.setFuncflag(U16(0x6B), instr16(imulR16Rm16Imm8),  CHKMODRM + CHKIMM8)


  r.setFuncflag(U16(0x85), instr16(testRm16R16),  CHKMODRM)

  r.setFuncflag(U16(0x87), instr16(xchgR16Rm16),  CHKMODRM)

  r.setFuncflag(U16(0x89), instr16(movRm16R16),   CHKMODRM)

  r.setFuncflag(U16(0x8B), instr16(movR16Rm16),   CHKMODRM)
  r.setFuncflag(U16(0x8C), instr16(movRm16Sreg),  CHKMODRM)
  r.setFuncflag(U16(0x8D), instr16(leaR16M16),    CHKMODRM)

  for i in 0 .. 7: r.setFuncflag(U16(0x90 + i), instr16(xchgR16Ax), CHKIMM16)

  r.setFuncflag(U16(0x98), instr16(cbw),          {})
  r.setFuncflag(U16(0x99), instr16(cwd),          {})
  r.setFuncflag(U16(0x9A), instr16(callfPtr1616), CHKPTR16 + CHKIMM16)
  r.setFuncflag(U16(0x9C), instr16(pushf),        {})
  r.setFuncflag(U16(0x9D), instr16(popf),         {})

  r.setFuncflag(U16(0xA1), instr16(movAxMoffs16), CHKMOFFS)

  r.setFuncflag(U16(0xA3), instr16(movMoffs16Ax), CHKMOFFS)
  r.setFuncflag(U16(0xA6), instr16(cmpsM8M8),     {})
  r.setFuncflag(U16(0xA7), instr16(cmpsM16M16),   {})

  r.setFuncflag(U16(0xA9), instr16(testAxImm16),  CHKIMM16)

  for i in 0 .. 7:
    r.setFuncflag(U16(0xB8 + i), instr16(movR16Imm16),  CHKIMM16)

  r.setFuncflag(U16(0xC3), instr16(ret),          {})
  r.setFuncflag(U16(0xC7), instr16(movRm16Imm16), CHKMODRM + CHKIMM16)
  r.setFuncflag(U16(0xC9), instr16(leave),        {})


  r.setFuncflag(U16(0xE5), instr16(inAxImm8),    CHKIMM8)

  r.setFuncflag(U16(0xE7), instr16(outImm8Ax),   CHKIMM8)
  r.setFuncflag(U16(0xE8), instr16(callRel16),   CHKIMM16)
  r.setFuncflag(U16(0xE9), instr16(jmpRel16),    CHKIMM16)
  r.setFuncflag(U16(0xEA), instr16(jmpfPtr1616), CHKPTR16 + CHKIMM16)


  r.setFuncflag(U16(0xED), instr16(inAxDx), {})

  r.setFuncflag(U16(0xEF), instr16(outDxAx), {})
  r.setFuncflag(U16(0x0F80), instr16(joRel16), CHKIMM16)
  r.setFuncflag(U16(0x0F81), instr16(jnoRel16), CHKIMM16)
  r.setFuncflag(U16(0x0F82), instr16(jbRel16), CHKIMM16)
  r.setFuncflag(U16(0x0F83), instr16(jnbRel16), CHKIMM16)
  r.setFuncflag(U16(0x0F84), instr16(jzRel16), CHKIMM16)
  r.setFuncflag(U16(0x0F85), instr16(jnzRel16), CHKIMM16)
  r.setFuncflag(U16(0x0F86), instr16(jbeRel16), CHKIMM16)
  r.setFuncflag(U16(0x0F87), instr16(jaRel16), CHKIMM16)
  r.setFuncflag(U16(0x0F88), instr16(jsRel16), CHKIMM16)
  r.setFuncflag(U16(0x0F89), instr16(jnsRel16), CHKIMM16)
  r.setFuncflag(U16(0x0F8A), instr16(jpRel16), CHKIMM16)
  r.setFuncflag(U16(0x0F8B), instr16(jnpRel16), CHKIMM16)
  r.setFuncflag(U16(0x0F8C), instr16(jlRel16), CHKIMM16)
  r.setFuncflag(U16(0x0F8D), instr16(jnlRel16), CHKIMM16)
  r.setFuncflag(U16(0x0F8E), instr16(jleRel16), CHKIMM16)
  r.setFuncflag(U16(0x0F8F), instr16(jnleRel16), CHKIMM16)
  r.setFuncflag(U16(0x0FAF), instr16(imulR16Rm16), CHKMODRM)
  r.setFuncflag(U16(0x0FB6), instr16(movzxR16Rm8), CHKMODRM)
  r.setFuncflag(U16(0x0FB7), instr16(movzxR16Rm16), CHKMODRM)
  r.setFuncflag(U16(0x0FBE), instr16(movsxR16Rm8), CHKMODRM)
  r.setFuncflag(U16(0x0FBF), instr16(movsxR16Rm16), CHKMODRM)

  r.setFuncflag(U16(0x81), instr16(code81), CHKMODRM + CHKIMM16)
  r.setFuncflag(U16(0x83), instr16(code81), CHKMODRM + CHKIMM8)

  r.setFuncflag(U16(0xC1), instr16(codeC1), CHKMODRM + CHKIMM8)
  r.setFuncflag(U16(0xD3), instr16(codeD3), CHKMODRM)
  r.setFuncflag(U16(0xF7), instr16(codeF7), CHKMODRM)
  r.setFuncflag(U16(0xFF), instr16(codeFf), CHKMODRM)
  r.setFuncflag(U16(0x0F00), instr16(code0f00), CHKMODRM)
  r.setFuncflag(U16(0x0F01), instr16(code0f01), CHKMODRM)


proc initInstrImpl16*(instr: ExecInstr): InstrImpl =
  initInstrImpl16(result, instr)
  assertRef(result.exec.get_emu())
