import instruction/[base, instruction]
import instr_base
import common
import ./emu
import ./exec
import hardware/eflags
import hardware/[processor, eflags, io]
import emulator/[emulator, access]

template instr32*(f: untyped): untyped {.dirty.} = 
  instrfuncT(f)

proc addRm32R32*(this: var InstrImpl) =
  var r32, rm32: U32
  rm32 = this.exec.getRm32().U32()
  r32 = this.exec.getR32()
  this.exec.setRm32(rm32 + r32)
  CPU.eflags.updateADD(rm32, r32)

proc addR32Rm32*(this: var InstrImpl) =
  var rm32, r32: U32
  r32 = this.exec.getR32()
  rm32 = this.exec.getRm32().U32()
  this.exec.setR32(r32 + rm32)
  CPU.eflags.updateADD(r32, rm32)

proc addEaxImm32*(this: var InstrImpl) =
  var eax: U32
  eax = CPU[EAX]
  CPU[EAX] = eax + this.imm32.U32
  CPU.eflags.updateADD(eax, this.imm32.U32)

proc pushEs*(this: var InstrImpl) =
  this.push32(ACS.getSegment(ES))

proc popEs*(this: var InstrImpl) =
  ACS.setSegment(ES, this.pop32().U16)

proc orRm32R32*(this: var InstrImpl) =
  var r32, rm32: U32
  rm32 = this.exec.getRm32().U32()
  r32 = this.exec.getR32()
  this.exec.setRm32(rm32 or r32)
  CPU.eflags.updateOR(rm32, r32)

proc orR32Rm32*(this: var InstrImpl) =
  var rm32, r32: U32
  r32 = this.exec.getR32()
  rm32 = this.exec.getRm32().U32()
  this.exec.setR32(r32 or rm32)
  CPU.eflags.updateOR(r32, rm32)

proc orEaxImm32*(this: var InstrImpl) =
  var eax: U32
  eax = CPU[EAX]
  CPU[EAX] = eax or this.imm32.U32
  CPU.eflags.updateOR(eax, this.imm32.U32)

proc pushSs*(this: var InstrImpl) =
  this.push32(ACS.getSegment(SS))

proc popSs*(this: var InstrImpl) =
  ACS.setSegment(SS, this.pop32().U16)

proc pushDs*(this: var InstrImpl) =
  this.push32(ACS.getSegment(DS))

proc popDs*(this: var InstrImpl) =
  ACS.setSegment(DS, this.pop32().U16)

proc andRm32R32*(this: var InstrImpl) =
  var r32, rm32: U32
  rm32 = this.exec.getRm32().U32()
  r32 = this.exec.getR32()
  this.exec.setRm32(rm32 and r32)
  CPU.eflags.updateAND(rm32, r32)

proc andR32Rm32*(this: var InstrImpl) =
  var rm32, r32: U32
  r32 = this.exec.getR32()
  rm32 = this.exec.getRm32().U32()
  this.exec.setR32(r32 and rm32)
  CPU.eflags.updateAND(r32, rm32)

proc andEaxImm32*(this: var InstrImpl) =
  var eax: U32
  eax = CPU[EAX]
  CPU[EAX] = eax and this.imm32.U32
  CPU.eflags.updateAND(eax, this.imm32.U32)

proc subRm32R32*(this: var InstrImpl) =
  var r32, rm32: U32
  rm32 = this.exec.getRm32().U32()
  r32 = this.exec.getR32()
  this.exec.setRm32(rm32 - r32)
  CPU.eflags.updateSUB(rm32, r32)

proc subR32Rm32*(this: var InstrImpl) =
  var rm32, r32: U32
  r32 = this.exec.getR32()
  rm32 = this.exec.getRm32().U32()
  this.exec.setR32(r32 - rm32)
  CPU.eflags.updateSUB(r32, rm32)

proc subEaxImm32*(this: var InstrImpl) =
  var eax: U32
  eax = CPU[EAX]
  CPU[EAX] = eax - this.imm32.U32
  CPU.eflags.updateSUB(eax, this.imm32.U32)

proc xorRm32R32*(this: var InstrImpl) =
  var r32, rm32: U32
  rm32 = this.exec.getRm32().U32()
  r32 = this.exec.getR32()
  this.exec.setRm32(rm32 xor r32)

proc xorR32Rm32*(this: var InstrImpl) =
  var rm32, r32: U32
  r32 = this.exec.getR32()
  rm32 = this.exec.getRm32().U32()
  this.exec.setR32(r32 xor rm32)

proc xorEaxImm32*(this: var InstrImpl) =
  var eax: U32
  eax = CPU[EAX]
  CPU[EAX] = eax xor this.imm32.U32

proc cmpRm32R32*(this: var InstrImpl) =
  var r32, rm32: U32
  rm32 = this.exec.getRm32().U32()
  r32 = this.exec.getR32()
  CPU.eflags.updateSUB(rm32, r32)

proc cmpR32Rm32*(this: var InstrImpl) =
  var rm32, r32: U32
  r32 = this.exec.getR32()
  rm32 = this.exec.getRm32().U32()
  CPU.eflags.updateSUB(r32, rm32)

proc cmpEaxImm32*(this: var InstrImpl) =
  var eax: U32
  eax = CPU[EAX]
  CPU.eflags.updateSUB(eax, this.imm32.U32)

proc incR32*(this: var InstrImpl) =
  var reg: U8
  var r32: U32
  reg = U8(this.idata.opcode and ((1 shl 3) - 1))
  r32 = CPU.getGPreg(Reg32T(reg))
  CPU.setGPreg(Reg32T(reg), r32 + 1)
  CPU.eflags.updateADD(r32, 1)

proc decR32*(this: var InstrImpl) =
  var reg: U8
  var r32: U32
  reg = U8(this.idata.opcode and ((1 shl 3) - 1))
  r32 = CPU.getGPreg(Reg32T(reg))
  CPU.setGPreg(Reg32T(reg), r32 - 1)
  CPU.eflags.updateSUB(r32, 1)

proc pushR32*(this: var InstrImpl) =
  var reg: U8
  reg = U8(this.idata.opcode and ((1 shl 3) - 1))
  this.push32(CPU.getGPreg(Reg32T(reg)))

proc popR32*(this: var InstrImpl) =
  var reg: U8 = U8(this.idata.opcode and ((1 shl 3) - 1))
  CPU.setGPreg(Reg32T(reg), this.pop32())

proc pushad*(this: var InstrImpl) =
  var esp: U32
  esp = CPU[ESP]
  this.push32(CPU[EAX])
  this.push32(CPU[ECX])
  this.push32(CPU[EDX])
  this.push32(CPU[EBX])
  this.push32(esp)
  this.push32(CPU[EBP])
  this.push32(CPU[ESI])
  this.push32(CPU[EDI])

proc popad*(this: var InstrImpl) =
  var esp: U32
  CPU[EDI] = this.pop32()
  CPU[ESI] = this.pop32()
  CPU[EBP] = this.pop32()
  esp = this.pop32()
  CPU[EBX] = this.pop32()
  CPU[EDX] = this.pop32()
  CPU[ECX] = this.pop32()
  CPU[EAX] = this.pop32()
  CPU[ESP] = esp

proc pushImm32*(this: var InstrImpl) =
  this.push32(this.imm32.U32)

proc imulR32Rm32Imm32*(this: var InstrImpl) =
  var rm32S: I32
  rm32S = this.exec.getRm32().I32
  this.exec.setR32(U32(rm32S * this.imm32))
  CPU.eflags.updateIMUL(rm32S, this.imm32)

proc pushImm8*(this: var InstrImpl) =
  this.push32(this.imm8.U32)

proc imulR32Rm32Imm8*(this: var InstrImpl) =
  var rm32S: I32
  rm32S = this.exec.getRm32().I32
  this.exec.setR32(U32(rm32S * this.imm8))
  CPU.eflags.updateIMUL(rm32S, this.imm8.I32)

proc testRm32R32*(this: var InstrImpl) =
  var r32, rm32: U32
  rm32 = this.exec.getRm32().U32()
  r32 = this.exec.getR32()
  CPU.eflags.updateAND(rm32, r32)

proc xchgR32Rm32*(this: var InstrImpl) =
  var rm32, r32: U32
  r32 = this.exec.getR32().U32()
  rm32 = this.exec.getRm32().U32()
  this.exec.setR32(rm32)
  this.exec.setRm32(r32)

proc movRm32R32*(this: var InstrImpl) =
  var r32: U32
  r32 = this.exec.getR32()
  this.exec.setRm32(r32)

proc movR32Rm32*(this: var InstrImpl) =
  var rm32: U32
  rm32 = this.exec.getRm32().U32()
  this.exec.setR32(rm32)

proc movRm32Sreg*(this: var InstrImpl) =
  var sreg: U16
  sreg = this.exec.getSreg()
  this.exec.setRm32(sreg)

proc leaR32M32*(this: var InstrImpl) =
  var m32: U32
  m32 = this.exec.getM()
  this.exec.setR32(m32)

proc xchgR32Eax*(this: var InstrImpl) =
  var eax, r32: U32
  r32 = this.exec.getR32()
  eax = CPU[EAX]
  this.exec.setR32(eax)
  CPU[EAX] = r32

proc cwde*(this: var InstrImpl) =
  var axS: I16
  axS = CPU[AX].I16()
  CPU[EAX] = axS.U32

proc cdq*(this: var InstrImpl) =
  var eax: U32
  eax = CPU[EAX]
  CPU[EDX] = U32(if toBool(eax and (1 shl 31)): -1 else: 0)

proc callfPtr16_32*(this: var InstrImpl) =
  this.exec.callf(this.ptr16.U16, this.imm32.U32)

proc pushf*(this: var InstrImpl) =
  this.push32(CPU.eflags.getEflags())

proc popf*(this: var InstrImpl) =
  CPU.eflags.setEflags(this.pop32())

proc movEaxMoffs32*(this: var InstrImpl) =
  CPU[EAX] = this.exec.getMoffs32()

proc movMoffs32Eax*(this: var InstrImpl) =
  this.exec.setMoffs32(CPU[EAX])

proc cmpsM8M8*(this: var InstrImpl) =
  var m8D, m8S: U8
  var repeat = true
  while repeat:
    m8S = ACS.getData8(this.exec.selectSegment(), CPU[ESI])
    m8D = ACS.getData8(ES, CPU[EDI])
    CPU.eflags.updateSUB(m8S, m8D)
    this.cpu.updateGPreg(ESI, I32(if this.eflags.isDirection(): -1 else: 1))
    this.cpu.updateGPreg(EDI, I32(if this.eflags.isDirection(): -1 else: 1))
    if this.getPreRepeat() != NONE:
      this.cpu.updateGPreg(ECX, -1)
      case this.getPreRepeat():
        of REPZ:
          if not(CPU[ECX]).toBool() or not(this.eflags.isZero()):
            repeat = false

        of REPNZ:
          if not(CPU[ECX]).toBool() or this.eflags.isZero():
            repeat = false

        else:
          repeat = false
  

proc cmpsM32M32*(this: var InstrImpl) =
  var m32D, m32S: U32
  var repeat = true

  while repeat:
    m32S = ACS.getData32(this.exec.selectSegment(), CPU[ESI])
    m32D = ACS.getData32(ES, CPU[EDI])
    CPU.eflags.updateSUB(m32S, m32D)
    this.cpu.updateGPreg(ESI, I32(if this.eflags.isDirection(): -1 else: 1))
    this.cpu.updateGPreg(EDI, I32(if this.eflags.isDirection(): -1 else: 1))
    if this.getPreRepeat() != NONE:
      this.cpu.updateGPreg(ECX, -1)
      case this.getPreRepeat():
        of REPZ:
          if not(CPU[ECX]).toBool() or not(this.eflags.isZero()):
            repeat = false

        of REPNZ:
          if not(CPU[ECX]).toBool() or this.eflags.isZero():
            repeat = false

        else:
          repeat = false
  

proc testEaxImm32*(this: var InstrImpl) =
  var eax: U32
  eax = CPU[EAX]
  CPU.eflags.updateAND(eax, this.imm32.U32)

proc movR32Imm32*(this: var InstrImpl) =
  var reg: U8 = U8(this.idata.opcode and ((1 shl 3) - 1))
  CPU.setGPreg(Reg32T(reg), this.imm32.U32)

proc ret*(this: var InstrImpl) =
  this.cpu.setEIP(this.pop32())

proc movRm32Imm32*(this: var InstrImpl) =
  this.exec.setRm32(this.imm32.U32)

proc leave*(this: var InstrImpl) =
  var ebp: U32 = CPU[EBP]
  CPU[ESP] = ebp
  CPU[EBP] = this.pop32()

proc inEaxImm8*(this: var InstrImpl) =
  CPU[EAX] = EIO.inIo32(this.imm8.U16)

proc outImm8Eax*(this: var InstrImpl) =
  var eax: U32
  eax = CPU[EAX]
  EIO.outIo32(this.imm8.U16, eax)

proc callRel32*(this: var InstrImpl) =
  this.push32(this.cpu.getEIP())
  CPU.updateEIp(this.imm32)

proc jmpRel32*(this: var InstrImpl) =
  CPU.updateEIp(this.imm32)

proc jmpfPtr16_32*(this: var InstrImpl) =
  this.exec.jmpf(this.ptr16.U16, this.imm32.U32)

proc inEaxDx*(this: var InstrImpl) =
  var dx: U16 = CPU[DX]
  CPU[EAX] = EIO.inIo32(dx)

proc outDxEax*(this: var InstrImpl) =
  var dx: U16 = CPU[DX]
  var eax: U32 = CPU[EAX]
  EIO.outIo32(dx, eax)

template JCCREL32*(cc: untyped, isFlag: untyped): untyped {.dirty.} =
  proc `j cc rel32`*(this: var InstrImpl) =
    if isFlag:
      CPU.updateEIp(this.imm32)
    
  

JCCREL32(o, this.eflags.isOverflow())
JCCREL32(no, not(this.eflags.isOverflow()))
JCCREL32(b, this.eflags.isCarry())
JCCREL32(nb, not(this.eflags.isCarry()))
JCCREL32(z, this.eflags.isZero())
JCCREL32(nz, not(this.eflags.isZero()))
JCCREL32(be, this.eflags.isCarry() or this.eflags.isZero())
JCCREL32(a, not((this.eflags.isCarry() or this.eflags.isZero())))
JCCREL32(s, this.eflags.isSign())
JCCREL32(ns, not(this.eflags.isSign()))
JCCREL32(p, this.eflags.isParity())
JCCREL32(np, not(this.eflags.isParity()))
JCCREL32(l, this.eflags.isSign() != this.eflags.isOverflow())
JCCREL32(nl, this.eflags.isSign() == this.eflags.isOverflow())
JCCREL32(le, this.eflags.isZero() or (this.eflags.isSign() != this.eflags.isOverflow()))
JCCREL32(nle, not(this.eflags.isZero()) and (this.eflags.isSign() == this.eflags.isOverflow()))

proc imulR32Rm32*(this: var InstrImpl) =
  var rm32S, r32S: I16
  r32S = this.exec.getR32().I16()
  rm32S = this.exec.getRm32().I16()
  this.exec.setR32(U32(r32S * rm32S))
  CPU.eflags.updateIMUL(r32S, rm32S)

proc movzxR32Rm8*(this: var InstrImpl) =
  var rm8: U8 = this.exec.getRm8()
  this.exec.setR32(rm8)

proc movzxR32Rm16*(this: var InstrImpl) =
  var rm16: U16 = this.exec.getRm16()
  this.exec.setR32(rm16)

proc movsxR32Rm8*(this: var InstrImpl) =
  var rm8S: I8 = this.exec.getRm8().I8()
  this.exec.setR32(U32(rm8S))

proc movsxR32Rm16*(this: var InstrImpl) =
  var rm16S: I16 = this.exec.getRm16().I16()
  this.exec.setR32(U32(rm16S))


proc addRm32Imm32*(this: var InstrImpl) =
  var rm32: U32
  rm32 = this.exec.getRm32().U32()
  this.exec.setRm32(rm32 + this.imm32.U32)
  CPU.eflags.updateADD(rm32, this.imm32.U32)

proc orRm32Imm32*(this: var InstrImpl) =
  var rm32: U32 = this.exec.getRm32().U32()
  this.exec.setRm32(rm32 or this.imm32.U32)
  CPU.eflags.updateOR(rm32, this.imm32.U32)

proc adcRm32Imm32*(this: var InstrImpl) =
  var rm32: U32
  var cf: U8
  rm32 = this.exec.getRm32().U32()
  cf = this.eflags.isCarry().U8
  this.exec.setRm32(rm32 + this.imm32.U32 + cf)
  CPU.eflags.updateADD(rm32, this.imm32.U32 + cf)

proc sbbRm32Imm32*(this: var InstrImpl) =
  var rm32: U32
  var cf: U8
  rm32 = this.exec.getRm32().U32()
  cf = this.eflags.isCarry().U8
  this.exec.setRm32(rm32 - this.imm32.U32 - cf)
  CPU.eflags.updateSUB(rm32, this.imm32.U32 + cf)

proc andRm32Imm32*(this: var InstrImpl) =
  var rm32: U32 = this.exec.getRm32().U32()
  this.exec.setRm32(rm32 and this.imm32.U32)
  CPU.eflags.updateAND(rm32, this.imm32.U32)

proc subRm32Imm32*(this: var InstrImpl) =
  var rm32: U32
  rm32 = this.exec.getRm32().U32()
  this.exec.setRm32(rm32 - this.imm32.U32)
  CPU.eflags.updateSUB(rm32, this.imm32.U32)

proc xorRm32Imm32*(this: var InstrImpl) =
  var rm32: U32 = this.exec.getRm32().U32()
  this.exec.setRm32(rm32 xor this.imm32.U32)

proc cmpRm32Imm32*(this: var InstrImpl) =
  var rm32: U32
  rm32 = this.exec.getRm32().U32()
  CPU.eflags.updateSUB(rm32, this.imm32.U32)


proc addRm32Imm8*(this: var InstrImpl) =
  var rm32: U32 = this.exec.getRm32().U32()
  this.exec.setRm32(rm32 + this.imm8.U32)
  CPU.eflags.updateADD(rm32, this.imm8.U32)

proc orRm32Imm8*(this: var InstrImpl) =
  var rm32: U32 = this.exec.getRm32().U32()
  this.exec.setRm32(rm32 or this.imm8.U32)
  CPU.eflags.updateOR(rm32, this.imm8.U32)

proc adcRm32Imm8*(this: var InstrImpl) =
  var rm32: U32
  var cf: U8
  rm32 = this.exec.getRm32().U32()
  cf = this.eflags.isCarry().U8
  this.exec.setRm32(rm32 + this.imm8.U32 + cf)
  CPU.eflags.updateADD(rm32, this.imm8.U32 + cf)

proc sbbRm32Imm8*(this: var InstrImpl) =
  var rm32: U32
  var cf: U8
  rm32 = this.exec.getRm32().U32()
  cf = this.eflags.isCarry().U8
  this.exec.setRm32(rm32 - this.imm8.U32 - cf)
  CPU.eflags.updateSUB(rm32, this.imm8.U32 + cf)

proc andRm32Imm8*(this: var InstrImpl) =
  var rm32: U32
  rm32 = this.exec.getRm32().U32()
  this.exec.setRm32(rm32 and this.imm8.U32)
  CPU.eflags.updateAND(rm32, this.imm8.U32)

proc subRm32Imm8*(this: var InstrImpl) =
  var rm32: U32 = this.exec.getRm32().U32()
  this.exec.setRm32(rm32 - this.imm8.U32)
  CPU.eflags.updateSUB(rm32, this.imm8.U32)

proc xorRm32Imm8*(this: var InstrImpl) =
  var rm32: U32
  rm32 = this.exec.getRm32().U32()
  this.exec.setRm32(rm32 xor this.imm8.U32)

proc cmpRm32Imm8*(this: var InstrImpl) =
  var rm32: U32 = this.exec.getRm32().U32()
  CPU.eflags.updateSUB(rm32, this.imm8.U32)


proc shlRm32Imm8*(this: var InstrImpl) =
  var rm32: U32 = this.exec.getRm32().U32()
  this.exec.setRm32(rm32 shl this.imm8.U32)
  CPU.eflags.updateSHL(rm32, this.imm8.U8)

proc shrRm32Imm8*(this: var InstrImpl) =
  var rm32: U32 = this.exec.getRm32().U32()
  this.exec.setRm32(rm32 shr this.imm8.U32)
  CPU.eflags.updateSHR(rm32, this.imm8.U8)

proc salRm32Imm8*(this: var InstrImpl) =
  var rm32S: I32
  rm32S = this.exec.getRm32().I32()
  this.exec.setRm32(U32(rm32S shl this.imm8))
  

proc sarRm32Imm8*(this: var InstrImpl) =
  var rm32S: I32
  rm32S = this.exec.getRm32().I32()
  this.exec.setRm32(U32(rm32S shr this.imm8))
  


proc shlRm32Cl*(this: var InstrImpl) =
  var rm32: U32
  var cl: U8
  rm32 = this.exec.getRm32().U32()
  cl = CPU[CL]
  this.exec.setRm32(rm32 shl cl)
  CPU.eflags.updateSHL(rm32, cl)

proc shrRm32Cl*(this: var InstrImpl) =
  var rm32: U32
  var cl: U8
  rm32 = this.exec.getRm32().U32()
  cl = CPU[CL]
  this.exec.setRm32(rm32 shr cl)
  CPU.eflags.updateSHR(rm32, cl)

proc salRm32Cl*(this: var InstrImpl) =
  var rm32S: I32
  var cl: U8
  rm32S = this.exec.getRm32().I32()
  cl = CPU[CL]
  this.exec.setRm32(U32(rm32S shl cl))
  

proc sarRm32Cl*(this: var InstrImpl) =
  var rm32S: I32 = this.exec.getRm32().I32()
  var cl: U8 = CPU[CL]
  this.exec.setRm32(U32(rm32S shr cl))
  


proc testRm32Imm32*(this: var InstrImpl) =
  var imm32, rm32: U32
  rm32 = this.exec.getRm32().U32()
  imm32 = ACS.getCode32(0)
  CPU.updateEIp(4)
  CPU.eflags.updateAND(rm32, this.imm32.U32)

proc notRm32*(this: var InstrImpl) =
  var rm32: U32
  rm32 = this.exec.getRm32().U32()
  this.exec.setRm32(not(rm32))

proc negRm32*(this: var InstrImpl) =
  var rm32S: I32 = this.exec.getRm32().I32()
  this.exec.setRm32(U32(-(rm32S)))
  CPU.eflags.updateSUB(cast[U32](0), rm32S.U32)

proc mulEdxEaxRm32*(this: var InstrImpl) =
  var eax, rm32: U32
  var val: U64
  rm32 = this.exec.getRm32().U32()
  eax = CPU[EAX]
  val = eax * rm32
  CPU[EAX] = U32(val)
  CPU[EDX] = U32(val shr 32)
  CPU.eflags.updateMUL(eax, rm32)

proc imulEdxEaxRm32*(this: var InstrImpl) =
  var eaxS, rm32S: I32
  var valS: int64
  rm32S = this.exec.getRm32().I32()
  eaxS = CPU[EAX].I32()
  valS = eaxS * rm32S
  CPU[EAX] = U32(valS)
  CPU[EDX] = U32(valS shr 32)
  CPU.eflags.updateIMUL(eaxS, rm32S)

proc divEdxEaxRm32*(this: var InstrImpl) =
  var rm32: U32
  var val: U64
  rm32 = this.exec.getRm32().U32()
  if not(rm32.toBool()): raise newException(EXPDE, "")
  val = CPU[EDX]
  val = (val shl 32)
  val = (val or CPU[EAX])
  CPU[EAX] = U32(val div rm32)
  CPU[EDX] = U32(val mod rm32)

proc idivEdxEaxRm32*(this: var InstrImpl) =
  var rm32S: I32 = this.exec.getRm32().I32()
  if not(rm32S.toBool()): raise newException(EXPDE, "")
  var valS: int64 = CPU[EDX].int64
  valS = (valS shl 32)
  valS = (valS or CPU[EAX].int64)
  CPU[EAX] = U32(valS div rm32S)
  CPU[EDX] = U32(valS mod rm32S)


proc incRm32*(this: var InstrImpl) =
  var rm32: U32
  rm32 = this.exec.getRm32().U32()
  this.exec.setRm32(rm32 + 1)
  CPU.eflags.updateADD(rm32, 1)

proc decRm32*(this: var InstrImpl) =
  var rm32: U32
  rm32 = this.exec.getRm32().U32()
  this.exec.setRm32(rm32 - 1)
  CPU.eflags.updateSUB(rm32, 1)

proc callRm32*(this: var InstrImpl) =
  var rm32: U32
  rm32 = this.exec.getRm32().U32()
  this.push32(this.cpu.getEIP())
  this.cpu.setEIP(rm32)

proc callfM16_32*(this: var InstrImpl) =
  var eip, m48: U32
  var cs: U16
  m48 = this.exec.getM()
  eip = this.readMem32(m48)
  cs = this.readMem16(m48 + 4)
  INFO(2, "cs = 0x%04x, eip = 0x%08x", cs, eip)
  this.exec.callf(cs, eip)

proc jmpRm32*(this: var InstrImpl) =
  var rm32: U32
  rm32 = this.exec.getRm32().U32()
  this.cpu.setEIP(rm32)

proc jmpfM16_32*(this: var InstrImpl) =
  var eip, m48: U32
  var sel: U16
  m48 = this.exec.getM()
  eip = this.readMem32(m48)
  sel = this.readMem16(m48 + 4)
  this.exec.jmpf(sel, eip)

proc pushRm32*(this: var InstrImpl) =
  var rm32: U32
  rm32 = this.exec.getRm32().U32()
  this.push32(rm32)


proc lgdtM32*(this: var InstrImpl) =
  var base, m48: U32
  var limit: U16
  if not(this.exec.chkRing(0)): raise newException(EXPGP, "")
  m48 = this.exec.getM()
  limit = this.readMem16(m48)
  base = this.readMem32(m48 + 2)
  INFO(2, "base = 0x%08x, limit = 0x%04x", base, limit)
  this.exec.setGdtr(base, limit)

proc lidtM32*(this: var InstrImpl) =
  var base, m48: U32
  var limit: U16
  if not(this.exec.chkRing(0)): raise newException(EXPGP, "")
  m48 = this.exec.getM()
  limit = this.readMem16(m48)
  base = this.readMem32(m48 + 2)
  INFO(2, "base = 0x%08x, limit = 0x%04x", base, limit)
  this.exec.setIdtr(base, limit)


proc code_81*(this: var InstrImpl) =
  case this.getModrmReg():
    of 0: this.addRm32Imm32()
    of 1: this.orRm32Imm32()
    of 2: this.adcRm32Imm32()
    of 3: this.sbbRm32Imm32()
    of 4: this.andRm32Imm32()
    of 5: this.subRm32Imm32()
    of 6: this.xorRm32Imm32()
    of 7: this.cmpRm32Imm32()
    else:
      ERROR("not implemented: 0x81 /%d\\n", this.getModrmReg())

proc codeC1*(this: var InstrImpl) =
  case this.getModrmReg():
    of 4: this.shlRm32Imm8()
    of 5: this.shrRm32Imm8()
    of 6: this.salRm32Imm8()
    of 7: this.sarRm32Imm8()
    else:
      ERROR("not implemented: 0xC1 /%d\\n", this.getModrmReg())

proc codeD3*(this: var InstrImpl) =
  case this.getModrmReg():
    of 4: this.shlRm32Cl()
    of 5: this.shrRm32Cl()
    of 6: this.salRm32Cl()
    of 7: this.sarRm32Cl()
    else:
      ERROR("not implemented: 0xD3 /%d\\n", this.getModrmReg())

proc codeF7*(this: var InstrImpl) =
  case this.getModrmReg():
    of 0: this.testRm32Imm32()
    of 2: this.notRm32()
    of 3: this.negRm32()
    of 4: this.mulEdxEaxRm32()
    of 5: this.imulEdxEaxRm32()
    of 6: this.divEdxEaxRm32()
    of 7: this.idivEdxEaxRm32()
    else:
      ERROR("not implemented: 0xF7 /%d\\n", this.getModrmReg())

proc codeFf*(this: var InstrImpl) =
  case this.getModrmReg():
    of 0: this.incRm32()
    of 1: this.decRm32()
    of 2: this.callRm32()
    of 3: this.callfM16_32()
    of 4: this.jmpRm32()
    of 5: this.jmpfM16_32()
    of 6: this.pushRm32()
    else:
      ERROR("not implemented: 0xFF /%d\\n", this.getModrmReg())

proc code_0f00*(this: var InstrImpl) =
  case this.getModrmReg():
    of 3: this.ltrRm16()
    else:
      ERROR("not implemented: 0x0F00 /%d\\n", this.getModrmReg())

proc code_0f01*(this: var InstrImpl) =
  case this.getModrmReg():
    of 2: this.lgdtM32()
    of 3: this.lidtM32()
    else:
      ERROR("not implemented: 0x0F01 /%d\\n", this.getModrmReg())




proc initInstrImpl32*(r: var InstrImpl, instr: ExecInstr) =
  initInstrImpl(r, instr)

  r.setFuncflag(U16(0x01), instr32(addRm32R32), CHKMODRM)

  r.setFuncflag(U16(0x03), instr32(addR32Rm32), CHKMODRM)

  r.setFuncflag(U16(0x05), instr32(addEaxImm32), CHKIMM32)
  r.setFuncflag(U16(0x06), instr32(pushEs), {})
  r.setFuncflag(U16(0x07), instr32(popEs), {})

  r.setFuncflag(U16(0x09), instr32(orRm32R32), CHKMODRM)

  r.setFuncflag(U16(0x0B), instr32(orR32Rm32), CHKMODRM)

  r.setFuncflag(U16(0x0D), instr32(orEaxImm32), CHKIMM32)
  r.setFuncflag(U16(0x16), instr32(pushSs), {})
  r.setFuncflag(U16(0x17), instr32(popSs), {})
  r.setFuncflag(U16(0x1E), instr32(pushDs), {})
  r.setFuncflag(U16(0x1F), instr32(popDs), {})

  r.setFuncflag(U16(0x21), instr32(andRm32R32), CHKMODRM)

  r.setFuncflag(U16(0x23), instr32(andR32Rm32), CHKMODRM)

  r.setFuncflag(U16(0x25), instr32(andEaxImm32), CHKIMM32)

  r.setFuncflag(U16(0x29), instr32(subRm32R32), CHKMODRM)

  r.setFuncflag(U16(0x2B), instr32(subR32Rm32), CHKMODRM)

  r.setFuncflag(U16(0x2D), instr32(subEaxImm32), CHKIMM32)

  r.setFuncflag(U16(0x31), instr32(xorRm32R32), CHKMODRM)

  r.setFuncflag(U16(0x33), instr32(xorR32Rm32), CHKMODRM)

  r.setFuncflag(U16(0x35), instr32(xorEaxImm32), CHKIMM32)

  r.setFuncflag(U16(0x39), instr32(cmpRm32R32), CHKMODRM)

  r.setFuncflag(U16(0x3B), instr32(cmpR32Rm32), CHKMODRM)

  r.setFuncflag(U16(0x3D), instr32(cmpEaxImm32), CHKIMM32)

  for i in 0 .. 7: r.setFuncflag(U16(0x40 + i), instr32(incR32), {})
  for i in 0 .. 7: r.setFuncflag(U16(0x48 + i), instr32(decR32), {})
  for i in 0 .. 7: r.setFuncflag(U16(0x50 + i), instr32(pushR32), {})
  for i in 0 .. 7: r.setFuncflag(U16(0x58 + i), instr32(popR32), {})

  r.setFuncflag(U16(0x60), instr32(pushad), {})
  r.setFuncflag(U16(0x61), instr32(popad), {})
  r.setFuncflag(U16(0x68), instr32(pushImm32), CHKIMM32)
  r.setFuncflag(U16(0x69), instr32(imulR32Rm32Imm32), CHKMODRM + CHKIMM32)
  r.setFuncflag(U16(0x6A), instr32(pushImm8), CHKIMM8)
  r.setFuncflag(U16(0x6B), instr32(imulR32Rm32Imm8), CHKMODRM + CHKIMM8)


  r.setFuncflag(U16(0x85), instr32(testRm32R32), CHKMODRM)

  r.setFuncflag(U16(0x87), instr32(xchgR32Rm32), CHKMODRM)

  r.setFuncflag(U16(0x89), instr32(movRm32R32), CHKMODRM)

  r.setFuncflag(U16(0x8B), instr32(movR32Rm32), CHKMODRM)
  r.setFuncflag(U16(0x8C), instr32(movRm32Sreg), CHKMODRM)
  r.setFuncflag(U16(0x8D), instr32(leaR32M32), CHKMODRM)

  for i in 0 .. 7: r.setFuncflag(U16(0x90 + i), instr32(xchgR32Eax), CHKIMM32)

  r.setFuncflag(U16(0x98), instr32(cwde), {})
  r.setFuncflag(U16(0x99), instr32(cdq), {})
  r.setFuncflag(U16(0x9A), instr32(callfPtr16_32), CHKPTR16 + CHKIMM32)
  r.setFuncflag(U16(0x9C), instr32(pushf), {})
  r.setFuncflag(U16(0x9D), instr32(popf), {})

  r.setFuncflag(U16(0xA1), instr32(movEaxMoffs32), CHKMOFFS)

  r.setFuncflag(U16(0xA3), instr32(movMoffs32Eax), CHKMOFFS)
  r.setFuncflag(U16(0xA6), instr32(cmpsM8M8), {})
  r.setFuncflag(U16(0xA7), instr32(cmpsM32M32), {})

  r.setFuncflag(U16(0xA9), instr32(testEaxImm32), CHKIMM32)

  for i in 0 .. 7:
    r.setFuncflag(U16(0xB8 + i), instr32(movR32Imm32), CHKIMM32)

  r.setFuncflag(U16(0xC3), instr32(ret), {})
  r.setFuncflag(U16(0xC7), instr32(movRm32Imm32), CHKMODRM + CHKIMM32)
  r.setFuncflag(U16(0xC9), instr32(leave), {})





  r.setFuncflag(U16(0xE5),   instr32(inEaxImm8),    CHKIMM8)

  r.setFuncflag(U16(0xE7),   instr32(outImm8Eax),   CHKIMM8)
  r.setFuncflag(U16(0xE8),   instr32(callRel32),    CHKIMM32)
  r.setFuncflag(U16(0xE9),   instr32(jmpRel32),     CHKIMM32)
  r.setFuncflag(U16(0xEA),   instr32(jmpfPtr16_32), CHKPTR16 + CHKIMM32)


  r.setFuncflag(U16(0xED),   instr32(inEaxDx),      {})

  r.setFuncflag(U16(0xEF),   instr32(outDxEax),     {})
  r.setFuncflag(U16(0x0F80), instr32(joRel32),      CHKIMM32)
  r.setFuncflag(U16(0x0F81), instr32(jnoRel32),     CHKIMM32)
  r.setFuncflag(U16(0x0F82), instr32(jbRel32),      CHKIMM32)
  r.setFuncflag(U16(0x0F83), instr32(jnbRel32),     CHKIMM32)
  r.setFuncflag(U16(0x0F84), instr32(jzRel32),      CHKIMM32)
  r.setFuncflag(U16(0x0F85), instr32(jnzRel32),     CHKIMM32)
  r.setFuncflag(U16(0x0F86), instr32(jbeRel32),     CHKIMM32)
  r.setFuncflag(U16(0x0F87), instr32(jaRel32),      CHKIMM32)
  r.setFuncflag(U16(0x0F88), instr32(jsRel32),      CHKIMM32)
  r.setFuncflag(U16(0x0F89), instr32(jnsRel32),     CHKIMM32)
  r.setFuncflag(U16(0x0F8A), instr32(jpRel32),      CHKIMM32)
  r.setFuncflag(U16(0x0F8B), instr32(jnpRel32),     CHKIMM32)
  r.setFuncflag(U16(0x0F8C), instr32(jlRel32),      CHKIMM32)
  r.setFuncflag(U16(0x0F8D), instr32(jnlRel32),     CHKIMM32)
  r.setFuncflag(U16(0x0F8E), instr32(jleRel32),     CHKIMM32)
  r.setFuncflag(U16(0x0F8F), instr32(jnleRel32),    CHKIMM32)
  r.setFuncflag(U16(0x0FAF), instr32(imulR32Rm32),  CHKMODRM)
  r.setFuncflag(U16(0x0FB6), instr32(movzxR32Rm8),  CHKMODRM)
  r.setFuncflag(U16(0x0FB7), instr32(movzxR32Rm16), CHKMODRM)
  r.setFuncflag(U16(0x0FBE), instr32(movsxR32Rm8),  CHKMODRM)
  r.setFuncflag(U16(0x0FBF), instr32(movsxR32Rm16), CHKMODRM)

  r.setFuncflag(U16(0x81), instr32(code81), CHKMODRM + CHKIMM32)
  r.setFuncflag(U16(0x83), instr32(code81), CHKMODRM + CHKIMM8)

  r.setFuncflag(U16(0xC1), instr32(codeC1), CHKMODRM + CHKIMM8)
  r.setFuncflag(U16(0xD3), instr32(codeD3), CHKMODRM)
  r.setFuncflag(U16(0xF7), instr32(codeF7), CHKMODRM)
  r.setFuncflag(U16(0xFF), instr32(codeFf), CHKMODRM)
  r.setFuncflag(U16(0x0F00), instr32(code_0f00), CHKMODRM)
  r.setFuncflag(U16(0x0F01), instr32(code_0f01), CHKMODRM)


proc initInstrImpl32*(instr: ExecInstr): InstrImpl =
  initInstrImpl32(result, instr)
