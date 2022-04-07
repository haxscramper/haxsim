import instruction/[base, instruction]
import instr_base
import common
import ./emu
import ./exec
import hardware/eflags
import hardware/[processor, eflags, io]
import emulator/[exception, emulator, access]

template instr32*(f: untyped): untyped {.dirty.} = 
  instrfuncT(f)

proc selectSegment*(this: var InstrImpl): SgRegT =
  this.exec.selectSegment()

proc addRm32R32*(this: var InstrImpl): void =
  var r32, rm32: uint32
  rm32 = this.exec.getRm32().uint32()
  r32 = this.exec.getR32()
  this.exec.setRm32(rm32 + r32)
  CPU.eflags.updateADD(rm32, r32)

proc addR32Rm32*(this: var InstrImpl): void =
  var rm32, r32: uint32
  r32 = this.exec.getR32()
  rm32 = this.exec.getRm32().uint32()
  this.exec.setR32(r32 + rm32)
  CPU.eflags.updateADD(r32, rm32)

proc addEaxImm32*(this: var InstrImpl): void =
  var eax: uint32
  eax = CPU.getGPreg(EAX)
  CPU.setGPreg(EAX, eax + this.imm32.uint32)
  CPU.eflags.updateADD(eax, this.imm32.uint32)

proc pushEs*(this: var InstrImpl): void =
  this.push32(ACS.getSegment(ES))

proc popEs*(this: var InstrImpl): void =
  ACS.setSegment(ES, this.pop32().uint16)

proc orRm32R32*(this: var InstrImpl): void =
  var r32, rm32: uint32
  rm32 = this.exec.getRm32().uint32()
  r32 = this.exec.getR32()
  this.exec.setRm32(rm32 or r32)
  CPU.eflags.updateOR(rm32, r32)

proc orR32Rm32*(this: var InstrImpl): void =
  var rm32, r32: uint32
  r32 = this.exec.getR32()
  rm32 = this.exec.getRm32().uint32()
  this.exec.setR32(r32 or rm32)
  CPU.eflags.updateOR(r32, rm32)

proc orEaxImm32*(this: var InstrImpl): void =
  var eax: uint32
  eax = CPU.getGPreg(EAX)
  CPU.setGPreg(EAX, eax or this.imm32.uint32)
  CPU.eflags.updateOR(eax, this.imm32.uint32)

proc pushSs*(this: var InstrImpl): void =
  this.push32(ACS.getSegment(SS))

proc popSs*(this: var InstrImpl): void =
  ACS.setSegment(SS, this.pop32().uint16)

proc pushDs*(this: var InstrImpl): void =
  this.push32(ACS.getSegment(DS))

proc popDs*(this: var InstrImpl): void =
  ACS.setSegment(DS, this.pop32().uint16)

proc andRm32R32*(this: var InstrImpl): void =
  var r32, rm32: uint32
  rm32 = this.exec.getRm32().uint32()
  r32 = this.exec.getR32()
  this.exec.setRm32(rm32 and r32)
  CPU.eflags.updateAND(rm32, r32)

proc andR32Rm32*(this: var InstrImpl): void =
  var rm32, r32: uint32
  r32 = this.exec.getR32()
  rm32 = this.exec.getRm32().uint32()
  this.exec.setR32(r32 and rm32)
  CPU.eflags.updateAND(r32, rm32)

proc andEaxImm32*(this: var InstrImpl): void =
  var eax: uint32
  eax = CPU.getGPreg(EAX)
  CPU.setGPreg(EAX, eax and this.imm32.uint32)
  CPU.eflags.updateAND(eax, this.imm32.uint32)

proc subRm32R32*(this: var InstrImpl): void =
  var r32, rm32: uint32
  rm32 = this.exec.getRm32().uint32()
  r32 = this.exec.getR32()
  this.exec.setRm32(rm32 - r32)
  CPU.eflags.updateSUB(rm32, r32)

proc subR32Rm32*(this: var InstrImpl): void =
  var rm32, r32: uint32
  r32 = this.exec.getR32()
  rm32 = this.exec.getRm32().uint32()
  this.exec.setR32(r32 - rm32)
  CPU.eflags.updateSUB(r32, rm32)

proc subEaxImm32*(this: var InstrImpl): void =
  var eax: uint32
  eax = CPU.getGPreg(EAX)
  CPU.setGPreg(EAX, eax - this.imm32.uint32)
  CPU.eflags.updateSUB(eax, this.imm32.uint32)

proc xorRm32R32*(this: var InstrImpl): void =
  var r32, rm32: uint32
  rm32 = this.exec.getRm32().uint32()
  r32 = this.exec.getR32()
  this.exec.setRm32(rm32 xor r32)

proc xorR32Rm32*(this: var InstrImpl): void =
  var rm32, r32: uint32
  r32 = this.exec.getR32()
  rm32 = this.exec.getRm32().uint32()
  this.exec.setR32(r32 xor rm32)

proc xorEaxImm32*(this: var InstrImpl): void =
  var eax: uint32
  eax = CPU.getGPreg(EAX)
  CPU.setGPreg(EAX, eax xor this.imm32.uint32)

proc cmpRm32R32*(this: var InstrImpl): void =
  var r32, rm32: uint32
  rm32 = this.exec.getRm32().uint32()
  r32 = this.exec.getR32()
  CPU.eflags.updateSUB(rm32, r32)

proc cmpR32Rm32*(this: var InstrImpl): void =
  var rm32, r32: uint32
  r32 = this.exec.getR32()
  rm32 = this.exec.getRm32().uint32()
  CPU.eflags.updateSUB(r32, rm32)

proc cmpEaxImm32*(this: var InstrImpl): void =
  var eax: uint32
  eax = CPU.getGPreg(EAX)
  CPU.eflags.updateSUB(eax, this.imm32.uint32)

proc incR32*(this: var InstrImpl): void =
  var reg: uint8
  var r32: uint32
  reg = uint8(this.idata.opcode and ((1 shl 3) - 1))
  r32 = CPU.getGPreg(Reg32T(reg))
  CPU.setGPreg(Reg32T(reg), r32 + 1)
  CPU.eflags.updateADD(r32, 1)

proc decR32*(this: var InstrImpl): void =
  var reg: uint8
  var r32: uint32
  reg = uint8(this.idata.opcode and ((1 shl 3) - 1))
  r32 = CPU.getGPreg(Reg32T(reg))
  CPU.setGPreg(Reg32T(reg), r32 - 1)
  CPU.eflags.updateSUB(r32, 1)

proc pushR32*(this: var InstrImpl): void =
  var reg: uint8
  reg = uint8(this.idata.opcode and ((1 shl 3) - 1))
  this.push32(CPU.getGPreg(Reg32T(reg)))

proc popR32*(this: var InstrImpl): void =
  var reg: uint8 = uint8(this.idata.opcode and ((1 shl 3) - 1))
  CPU.setGPreg(Reg32T(reg), this.pop32())

proc pushad*(this: var InstrImpl): void =
  var esp: uint32
  esp = CPU.getGPreg(ESP)
  this.push32(CPU.getGPreg(EAX))
  this.push32(CPU.getGPreg(ECX))
  this.push32(CPU.getGPreg(EDX))
  this.push32(CPU.getGPreg(EBX))
  this.push32(esp)
  this.push32(CPU.getGPreg(EBP))
  this.push32(CPU.getGPreg(ESI))
  this.push32(CPU.getGPreg(EDI))

proc popad*(this: var InstrImpl): void =
  var esp: uint32
  CPU.setGPreg(EDI, this.pop32())
  CPU.setGPreg(ESI, this.pop32())
  CPU.setGPreg(EBP, this.pop32())
  esp = this.pop32()
  CPU.setGPreg(EBX, this.pop32())
  CPU.setGPreg(EDX, this.pop32())
  CPU.setGPreg(ECX, this.pop32())
  CPU.setGPreg(EAX, this.pop32())
  CPU.setGPreg(ESP, esp)

proc pushImm32*(this: var InstrImpl): void =
  this.push32(this.imm32.uint32)

proc imulR32Rm32Imm32*(this: var InstrImpl): void =
  var rm32S: int32
  rm32S = this.exec.getRm32().int32
  this.exec.setR32(uint32(rm32S * this.imm32))
  CPU.eflags.updateIMUL(rm32S, this.imm32)

proc pushImm8*(this: var InstrImpl): void =
  this.push32(this.imm8.uint32)

proc imulR32Rm32Imm8*(this: var InstrImpl): void =
  var rm32S: int32
  rm32S = this.exec.getRm32().int32
  this.exec.setR32(uint32(rm32S * this.imm8))
  CPU.eflags.updateIMUL(rm32S, this.imm8.int32)

proc testRm32R32*(this: var InstrImpl): void =
  var r32, rm32: uint32
  rm32 = this.exec.getRm32().uint32()
  r32 = this.exec.getR32()
  CPU.eflags.updateAND(rm32, r32)

proc xchgR32Rm32*(this: var InstrImpl): void =
  var rm32, r32: uint32
  r32 = this.exec.getR32().uint32()
  rm32 = this.exec.getRm32().uint32()
  this.exec.setR32(rm32)
  this.exec.setRm32(r32)

proc movRm32R32*(this: var InstrImpl): void =
  var r32: uint32
  r32 = this.exec.getR32()
  this.exec.setRm32(r32)

proc movR32Rm32*(this: var InstrImpl): void =
  var rm32: uint32
  rm32 = this.exec.getRm32().uint32()
  this.exec.setR32(rm32)

proc movRm32Sreg*(this: var InstrImpl): void =
  var sreg: uint16
  sreg = this.exec.getSreg()
  this.exec.setRm32(sreg)

proc leaR32M32*(this: var InstrImpl): void =
  var m32: uint32
  m32 = this.exec.getM()
  this.exec.setR32(m32)

proc xchgR32Eax*(this: var InstrImpl): void =
  var eax, r32: uint32
  r32 = this.exec.getR32()
  eax = CPU.getGPreg(EAX)
  this.exec.setR32(eax)
  CPU.setGPreg(EAX, r32)

proc cwde*(this: var InstrImpl): void =
  var axS: int16
  axS = CPU.getGPreg(AX).int16()
  CPU.setGPreg(EAX, axS.uint32)

proc cdq*(this: var InstrImpl): void =
  var eax: uint32
  eax = CPU.getGPreg(EAX)
  CPU.setGPreg(EDX, uint32(if toBool(eax and (1 shl 31)): -1 else: 0))

proc callfPtr16_32*(this: var InstrImpl): void =
  this.exec.callf(this.ptr16.uint16, this.imm32.uint32)

proc pushf*(this: var InstrImpl): void =
  this.push32(CPU.eflags.getEflags())

proc popf*(this: var InstrImpl): void =
  CPU.eflags.setEflags(this.pop32())

proc movEaxMoffs32*(this: var InstrImpl): void =
  CPU.setGPreg(EAX, this.exec.getMoffs32())

proc movMoffs32Eax*(this: var InstrImpl): void =
  this.exec.setMoffs32(CPU.getGPreg(EAX))

proc cmpsM8M8*(this: var InstrImpl): void =
  var m8D, m8S: uint8
  var repeat = true
  while repeat:
    m8S = ACS.getData8(this.exec.selectSegment(), CPU.getGPreg(ESI))
    m8D = ACS.getData8(ES, CPU.getGPreg(EDI))
    CPU.eflags.updateSUB(m8S, m8D)
    this.cpu.updateGPreg(ESI, int32(if this.eflags.isDirection(): -1 else: 1))
    this.cpu.updateGPreg(EDI, int32(if this.eflags.isDirection(): -1 else: 1))
    if this.getPreRepeat() != NONE:
      this.cpu.updateGPreg(ECX, -1)
      case this.getPreRepeat():
        of REPZ:
          if not(CPU.getGPreg(ECX)).toBool() or not(this.eflags.isZero()):
            repeat = false

        of REPNZ:
          if not(CPU.getGPreg(ECX)).toBool() or this.eflags.isZero():
            repeat = false

        else:
          repeat = false
  

proc cmpsM32M32*(this: var InstrImpl): void =
  var m32D, m32S: uint32
  var repeat = true

  while repeat:
    m32S = ACS.getData32(this.exec.selectSegment(), CPU.getGPreg(ESI))
    m32D = ACS.getData32(ES, CPU.getGPreg(EDI))
    CPU.eflags.updateSUB(m32S, m32D)
    this.cpu.updateGPreg(ESI, int32(if this.eflags.isDirection(): -1 else: 1))
    this.cpu.updateGPreg(EDI, int32(if this.eflags.isDirection(): -1 else: 1))
    if this.getPreRepeat() != NONE:
      this.cpu.updateGPreg(ECX, -1)
      case this.getPreRepeat():
        of REPZ:
          if not(CPU.getGPreg(ECX)).toBool() or not(this.eflags.isZero()):
            repeat = false

        of REPNZ:
          if not(CPU.getGPreg(ECX)).toBool() or this.eflags.isZero():
            repeat = false

        else:
          repeat = false
  

proc testEaxImm32*(this: var InstrImpl): void =
  var eax: uint32
  eax = CPU.getGPreg(EAX)
  CPU.eflags.updateAND(eax, this.imm32.uint32)

proc movR32Imm32*(this: var InstrImpl): void =
  var reg: uint8 = uint8(this.idata.opcode and ((1 shl 3) - 1))
  CPU.setGPreg(Reg32T(reg), this.imm32.uint32)

proc ret*(this: var InstrImpl): void =
  this.cpu.setEIP(this.pop32())

proc movRm32Imm32*(this: var InstrImpl): void =
  this.exec.setRm32(this.imm32.uint32)

proc leave*(this: var InstrImpl): void =
  var ebp: uint32 = CPU.getGPreg(EBP)
  CPU.setGPreg(ESP, ebp)
  CPU.setGPreg(EBP, this.pop32())

proc inEaxImm8*(this: var InstrImpl): void =
  CPU.setGPreg(EAX, EIO.inIo32(this.imm8.uint16))

proc outImm8Eax*(this: var InstrImpl): void =
  var eax: uint32
  eax = CPU.getGPreg(EAX)
  EIO.outIo32(this.imm8.uint16, eax)

proc callRel32*(this: var InstrImpl): void =
  this.push32(this.cpu.getEIP())
  CPU.updateEIp(this.imm32)

proc jmpRel32*(this: var InstrImpl): void =
  CPU.updateEIp(this.imm32)

proc jmpfPtr16_32*(this: var InstrImpl): void =
  this.exec.jmpf(this.ptr16.uint16, this.imm32.uint32)

proc inEaxDx*(this: var InstrImpl): void =
  var dx: uint16 = CPU.getGPreg(DX)
  CPU.setGPreg(EAX, EIO.inIo32(dx))

proc outDxEax*(this: var InstrImpl): void =
  var dx: uint16 = CPU.getGPreg(DX)
  var eax: uint32 = CPU.getGPreg(EAX)
  EIO.outIo32(dx, eax)

template JCCREL32*(cc: untyped, isFlag: untyped): untyped {.dirty.} =
  proc `j cc rel32`*(this: var InstrImpl): void =
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

proc imulR32Rm32*(this: var InstrImpl): void =
  var rm32S, r32S: int16
  r32S = this.exec.getR32().int16()
  rm32S = this.exec.getRm32().int16()
  this.exec.setR32(uint32(r32S * rm32S))
  CPU.eflags.updateIMUL(r32S, rm32S)

proc movzxR32Rm8*(this: var InstrImpl): void =
  var rm8: uint8 = this.exec.getRm8()
  this.exec.setR32(rm8)

proc movzxR32Rm16*(this: var InstrImpl): void =
  var rm16: uint16 = this.exec.getRm16()
  this.exec.setR32(rm16)

proc movsxR32Rm8*(this: var InstrImpl): void =
  var rm8S: int8 = this.exec.getRm8().int8()
  this.exec.setR32(uint32(rm8S))

proc movsxR32Rm16*(this: var InstrImpl): void =
  var rm16S: int16 = this.exec.getRm16().int16()
  this.exec.setR32(uint32(rm16S))


proc addRm32Imm32*(this: var InstrImpl): void =
  var rm32: uint32
  rm32 = this.exec.getRm32().uint32()
  this.exec.setRm32(rm32 + this.imm32.uint32)
  CPU.eflags.updateADD(rm32, this.imm32.uint32)

proc orRm32Imm32*(this: var InstrImpl): void =
  var rm32: uint32 = this.exec.getRm32().uint32()
  this.exec.setRm32(rm32 or this.imm32.uint32)
  CPU.eflags.updateOR(rm32, this.imm32.uint32)

proc adcRm32Imm32*(this: var InstrImpl): void =
  var rm32: uint32
  var cf: uint8
  rm32 = this.exec.getRm32().uint32()
  cf = this.eflags.isCarry().uint8
  this.exec.setRm32(rm32 + this.imm32.uint32 + cf)
  CPU.eflags.updateADD(rm32, this.imm32.uint32 + cf)

proc sbbRm32Imm32*(this: var InstrImpl): void =
  var rm32: uint32
  var cf: uint8
  rm32 = this.exec.getRm32().uint32()
  cf = this.eflags.isCarry().uint8
  this.exec.setRm32(rm32 - this.imm32.uint32 - cf)
  CPU.eflags.updateSUB(rm32, this.imm32.uint32 + cf)

proc andRm32Imm32*(this: var InstrImpl): void =
  var rm32: uint32 = this.exec.getRm32().uint32()
  this.exec.setRm32(rm32 and this.imm32.uint32)
  CPU.eflags.updateAND(rm32, this.imm32.uint32)

proc subRm32Imm32*(this: var InstrImpl): void =
  var rm32: uint32
  rm32 = this.exec.getRm32().uint32()
  this.exec.setRm32(rm32 - this.imm32.uint32)
  CPU.eflags.updateSUB(rm32, this.imm32.uint32)

proc xorRm32Imm32*(this: var InstrImpl): void =
  var rm32: uint32 = this.exec.getRm32().uint32()
  this.exec.setRm32(rm32 xor this.imm32.uint32)

proc cmpRm32Imm32*(this: var InstrImpl): void =
  var rm32: uint32
  rm32 = this.exec.getRm32().uint32()
  CPU.eflags.updateSUB(rm32, this.imm32.uint32)


proc addRm32Imm8*(this: var InstrImpl): void =
  var rm32: uint32 = this.exec.getRm32().uint32()
  this.exec.setRm32(rm32 + this.imm8.uint32)
  CPU.eflags.updateADD(rm32, this.imm8.uint32)

proc orRm32Imm8*(this: var InstrImpl): void =
  var rm32: uint32 = this.exec.getRm32().uint32()
  this.exec.setRm32(rm32 or this.imm8.uint32)
  CPU.eflags.updateOR(rm32, this.imm8.uint32)

proc adcRm32Imm8*(this: var InstrImpl): void =
  var rm32: uint32
  var cf: uint8
  rm32 = this.exec.getRm32().uint32()
  cf = this.eflags.isCarry().uint8
  this.exec.setRm32(rm32 + this.imm8.uint32 + cf)
  CPU.eflags.updateADD(rm32, this.imm8.uint32 + cf)

proc sbbRm32Imm8*(this: var InstrImpl): void =
  var rm32: uint32
  var cf: uint8
  rm32 = this.exec.getRm32().uint32()
  cf = this.eflags.isCarry().uint8
  this.exec.setRm32(rm32 - this.imm8.uint32 - cf)
  CPU.eflags.updateSUB(rm32, this.imm8.uint32 + cf)

proc andRm32Imm8*(this: var InstrImpl): void =
  var rm32: uint32
  rm32 = this.exec.getRm32().uint32()
  this.exec.setRm32(rm32 and this.imm8.uint32)
  CPU.eflags.updateAND(rm32, this.imm8.uint32)

proc subRm32Imm8*(this: var InstrImpl): void =
  var rm32: uint32 = this.exec.getRm32().uint32()
  this.exec.setRm32(rm32 - this.imm8.uint32)
  CPU.eflags.updateSUB(rm32, this.imm8.uint32)

proc xorRm32Imm8*(this: var InstrImpl): void =
  var rm32: uint32
  rm32 = this.exec.getRm32().uint32()
  this.exec.setRm32(rm32 xor this.imm8.uint32)

proc cmpRm32Imm8*(this: var InstrImpl): void =
  var rm32: uint32 = this.exec.getRm32().uint32()
  CPU.eflags.updateSUB(rm32, this.imm8.uint32)


proc shlRm32Imm8*(this: var InstrImpl): void =
  var rm32: uint32 = this.exec.getRm32().uint32()
  this.exec.setRm32(rm32 shl this.imm8.uint32)
  CPU.eflags.updateSHL(rm32, this.imm8.uint8)

proc shrRm32Imm8*(this: var InstrImpl): void =
  var rm32: uint32 = this.exec.getRm32().uint32()
  this.exec.setRm32(rm32 shr this.imm8.uint32)
  CPU.eflags.updateSHR(rm32, this.imm8.uint8)

proc salRm32Imm8*(this: var InstrImpl): void =
  var rm32S: int32
  rm32S = this.exec.getRm32().int32()
  this.exec.setRm32(uint32(rm32S shl this.imm8))
  

proc sarRm32Imm8*(this: var InstrImpl): void =
  var rm32S: int32
  rm32S = this.exec.getRm32().int32()
  this.exec.setRm32(uint32(rm32S shr this.imm8))
  


proc shlRm32Cl*(this: var InstrImpl): void =
  var rm32: uint32
  var cl: uint8
  rm32 = this.exec.getRm32().uint32()
  cl = CPU.getGPreg(CL)
  this.exec.setRm32(rm32 shl cl)
  CPU.eflags.updateSHL(rm32, cl)

proc shrRm32Cl*(this: var InstrImpl): void =
  var rm32: uint32
  var cl: uint8
  rm32 = this.exec.getRm32().uint32()
  cl = CPU.getGPreg(CL)
  this.exec.setRm32(rm32 shr cl)
  CPU.eflags.updateSHR(rm32, cl)

proc salRm32Cl*(this: var InstrImpl): void =
  var rm32S: int32
  var cl: uint8
  rm32S = this.exec.getRm32().int32()
  cl = CPU.getGPreg(CL)
  this.exec.setRm32(uint32(rm32S shl cl))
  

proc sarRm32Cl*(this: var InstrImpl): void =
  var rm32S: int32 = this.exec.getRm32().int32()
  var cl: uint8 = CPU.getGPreg(CL)
  this.exec.setRm32(uint32(rm32S shr cl))
  


proc testRm32Imm32*(this: var InstrImpl): void =
  var imm32, rm32: uint32
  rm32 = this.exec.getRm32().uint32()
  imm32 = ACS.getCode32(0)
  CPU.updateEIp(4)
  CPU.eflags.updateAND(rm32, this.imm32.uint32)

proc notRm32*(this: var InstrImpl): void =
  var rm32: uint32
  rm32 = this.exec.getRm32().uint32()
  this.exec.setRm32(not(rm32))

proc negRm32*(this: var InstrImpl): void =
  var rm32S: int32 = this.exec.getRm32().int32()
  this.exec.setRm32(uint32(-(rm32S)))
  CPU.eflags.updateSUB(cast[uint32](0), rm32S.uint32)

proc mulEdxEaxRm32*(this: var InstrImpl): void =
  var eax, rm32: uint32
  var val: uint64
  rm32 = this.exec.getRm32().uint32()
  eax = CPU.getGPreg(EAX)
  val = eax * rm32
  CPU.setGPreg(EAX, uint32(val))
  CPU.setGPreg(EDX, uint32(val shr 32))
  CPU.eflags.updateMUL(eax, rm32)

proc imulEdxEaxRm32*(this: var InstrImpl): void =
  var eaxS, rm32S: int32
  var valS: int64
  rm32S = this.exec.getRm32().int32()
  eaxS = CPU.getGPreg(EAX).int32()
  valS = eaxS * rm32S
  CPU.setGPreg(EAX, uint32(valS))
  CPU.setGPreg(EDX, uint32(valS shr 32))
  CPU.eflags.updateIMUL(eaxS, rm32S)

proc divEdxEaxRm32*(this: var InstrImpl): void =
  var rm32: uint32
  var val: uint64
  rm32 = this.exec.getRm32().uint32()
  EXCEPTION(EXPDE, not(rm32.toBool()))
  val = CPU.getGPreg(EDX)
  val = (val shl 32)
  val = (val or CPU.getGPreg(EAX))
  CPU.setGPreg(EAX, uint32(val div rm32))
  CPU.setGPreg(EDX, uint32(val mod rm32))

proc idivEdxEaxRm32*(this: var InstrImpl): void =
  var rm32S: int32 = this.exec.getRm32().int32()
  EXCEPTION(EXPDE, not(rm32S.toBool()))
  var valS: int64 = CPU.getGPreg(EDX).int64
  valS = (valS shl 32)
  valS = (valS or CPU.getGPreg(EAX).int64)
  CPU.setGPreg(EAX, uint32(valS div rm32S))
  CPU.setGPreg(EDX, uint32(valS mod rm32S))


proc incRm32*(this: var InstrImpl): void =
  var rm32: uint32
  rm32 = this.exec.getRm32().uint32()
  this.exec.setRm32(rm32 + 1)
  CPU.eflags.updateADD(rm32, 1)

proc decRm32*(this: var InstrImpl): void =
  var rm32: uint32
  rm32 = this.exec.getRm32().uint32()
  this.exec.setRm32(rm32 - 1)
  CPU.eflags.updateSUB(rm32, 1)

proc callRm32*(this: var InstrImpl): void =
  var rm32: uint32
  rm32 = this.exec.getRm32().uint32()
  this.push32(this.cpu.getEIP())
  this.cpu.setEIP(rm32)

proc callfM16_32*(this: var InstrImpl): void =
  var eip, m48: uint32
  var cs: uint16
  m48 = this.exec.getM()
  eip = READMEM32(m48)
  cs = READMEM16(m48 + 4)
  INFO(2, "cs = 0x%04x, eip = 0x%08x", cs, eip)
  this.exec.callf(cs, eip)

proc jmpRm32*(this: var InstrImpl): void =
  var rm32: uint32
  rm32 = this.exec.getRm32().uint32()
  this.cpu.setEIP(rm32)

proc jmpfM16_32*(this: var InstrImpl): void =
  var eip, m48: uint32
  var sel: uint16
  m48 = this.exec.getM()
  eip = READMEM32(m48)
  sel = READMEM16(m48 + 4)
  this.exec.jmpf(sel, eip)

proc pushRm32*(this: var InstrImpl): void =
  var rm32: uint32
  rm32 = this.exec.getRm32().uint32()
  this.push32(rm32)


proc lgdtM32*(this: var InstrImpl): void =
  var base, m48: uint32
  var limit: uint16
  EXCEPTION(EXPGP, not(this.exec.chkRing(0)))
  m48 = this.exec.getM()
  limit = READMEM16(m48)
  base = READMEM32(m48 + 2)
  INFO(2, "base = 0x%08x, limit = 0x%04x", base, limit)
  this.exec.setGdtr(base, limit)

proc lidtM32*(this: var InstrImpl): void =
  var base, m48: uint32
  var limit: uint16
  EXCEPTION(EXPGP, not(this.exec.chkRing(0)))
  m48 = this.exec.getM()
  limit = READMEM16(m48)
  base = READMEM32(m48 + 2)
  INFO(2, "base = 0x%08x, limit = 0x%04x", base, limit)
  this.exec.setIdtr(base, limit)


proc code_81*(this: var InstrImpl): void =
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

# proc code_83*(this: var InstrImpl): void =
#   case this.getModrmReg():
#     of 0: this.addRm32Imm8()
#     of 1: this.orRm32Imm8()
#     of 2: this.adcRm32Imm8()
#     of 3: this.sbbRm32Imm8()
#     of 4: this.andRm32Imm8()
#     of 5: this.subRm32Imm8()
#     of 6: this.xorRm32Imm8()
#     of 7: this.cmpRm32Imm8()
#     else:
#       ERROR("not implemented: 0x83 /%d\\n", this.getModrmReg())

proc codeC1*(this: var InstrImpl): void =
  case this.getModrmReg():
    of 4: this.shlRm32Imm8()
    of 5: this.shrRm32Imm8()
    of 6: this.salRm32Imm8()
    of 7: this.sarRm32Imm8()
    else:
      ERROR("not implemented: 0xc1 /%d\\n", this.getModrmReg())

proc codeD3*(this: var InstrImpl): void =
  case this.getModrmReg():
    of 4: this.shlRm32Cl()
    of 5: this.shrRm32Cl()
    of 6: this.salRm32Cl()
    of 7: this.sarRm32Cl()
    else:
      ERROR("not implemented: 0xd3 /%d\\n", this.getModrmReg())

proc codeF7*(this: var InstrImpl): void =
  case this.getModrmReg():
    of 0: this.testRm32Imm32()
    of 2: this.notRm32()
    of 3: this.negRm32()
    of 4: this.mulEdxEaxRm32()
    of 5: this.imulEdxEaxRm32()
    of 6: this.divEdxEaxRm32()
    of 7: this.idivEdxEaxRm32()
    else:
      ERROR("not implemented: 0xf7 /%d\\n", this.getModrmReg())

proc codeFf*(this: var InstrImpl): void =
  case this.getModrmReg():
    of 0: this.incRm32()
    of 1: this.decRm32()
    of 2: this.callRm32()
    of 3: this.callfM16_32()
    of 4: this.jmpRm32()
    of 5: this.jmpfM16_32()
    of 6: this.pushRm32()
    else:
      ERROR("not implemented: 0xff /%d\\n", this.getModrmReg())

proc code_0f00*(this: var InstrImpl): void =
  case this.getModrmReg():
    of 3: this.ltrRm16()
    else:
      ERROR("not implemented: 0x0f00 /%d\\n", this.getModrmReg())

proc code_0f01*(this: var InstrImpl): void =
  case this.getModrmReg():
    of 2: this.lgdtM32()
    of 3: this.lidtM32()
    else:
      ERROR("not implemented: 0x0f01 /%d\\n", this.getModrmReg())




proc initInstrImpl32*(r: var InstrImpl, instr: ExecInstr) =
  initInstrImpl(r, instr)

  r.setFuncflag(uint16(0x01), instr32(addRm32R32), CHKMODRM)

  r.setFuncflag(uint16(0x03), instr32(addR32Rm32), CHKMODRM)

  r.setFuncflag(uint16(0x05), instr32(addEaxImm32), CHKIMM32)
  r.setFuncflag(uint16(0x06), instr32(pushEs), {})
  r.setFuncflag(uint16(0x07), instr32(popEs), {})

  r.setFuncflag(uint16(0x09), instr32(orRm32R32), CHKMODRM)

  r.setFuncflag(uint16(0x0b), instr32(orR32Rm32), CHKMODRM)

  r.setFuncflag(uint16(0x0d), instr32(orEaxImm32), CHKIMM32)
  r.setFuncflag(uint16(0x16), instr32(pushSs), {})
  r.setFuncflag(uint16(0x17), instr32(popSs), {})
  r.setFuncflag(uint16(0x1e), instr32(pushDs), {})
  r.setFuncflag(uint16(0x1f), instr32(popDs), {})

  r.setFuncflag(uint16(0x21), instr32(andRm32R32), CHKMODRM)

  r.setFuncflag(uint16(0x23), instr32(andR32Rm32), CHKMODRM)

  r.setFuncflag(uint16(0x25), instr32(andEaxImm32), CHKIMM32)

  r.setFuncflag(uint16(0x29), instr32(subRm32R32), CHKMODRM)

  r.setFuncflag(uint16(0x2b), instr32(subR32Rm32), CHKMODRM)

  r.setFuncflag(uint16(0x2d), instr32(subEaxImm32), CHKIMM32)

  r.setFuncflag(uint16(0x31), instr32(xorRm32R32), CHKMODRM)

  r.setFuncflag(uint16(0x33), instr32(xorR32Rm32), CHKMODRM)

  r.setFuncflag(uint16(0x35), instr32(xorEaxImm32), CHKIMM32)

  r.setFuncflag(uint16(0x39), instr32(cmpRm32R32), CHKMODRM)

  r.setFuncflag(uint16(0x3b), instr32(cmpR32Rm32), CHKMODRM)

  r.setFuncflag(uint16(0x3d), instr32(cmpEaxImm32), CHKIMM32)

  for i in 0 .. 7: r.setFuncflag(uint16(0x40 + i), instr32(incR32), {})
  for i in 0 .. 7: r.setFuncflag(uint16(0x48 + i), instr32(decR32), {})
  for i in 0 .. 7: r.setFuncflag(uint16(0x50 + i), instr32(pushR32), {})
  for i in 0 .. 7: r.setFuncflag(uint16(0x58 + i), instr32(popR32), {})

  r.setFuncflag(uint16(0x60), instr32(pushad), {})
  r.setFuncflag(uint16(0x61), instr32(popad), {})
  r.setFuncflag(uint16(0x68), instr32(pushImm32), CHKIMM32)
  r.setFuncflag(uint16(0x69), instr32(imulR32Rm32Imm32), CHKMODRM + CHKIMM32)
  r.setFuncflag(uint16(0x6a), instr32(pushImm8), CHKIMM8)
  r.setFuncflag(uint16(0x6b), instr32(imulR32Rm32Imm8), CHKMODRM + CHKIMM8)


  r.setFuncflag(uint16(0x85), instr32(testRm32R32), CHKMODRM)

  r.setFuncflag(uint16(0x87), instr32(xchgR32Rm32), CHKMODRM)

  r.setFuncflag(uint16(0x89), instr32(movRm32R32), CHKMODRM)

  r.setFuncflag(uint16(0x8b), instr32(movR32Rm32), CHKMODRM)
  r.setFuncflag(uint16(0x8c), instr32(movRm32Sreg), CHKMODRM)
  r.setFuncflag(uint16(0x8d), instr32(leaR32M32), CHKMODRM)

  for i in 0 .. 7: r.setFuncflag(uint16(0x90 + i), instr32(xchgR32Eax), CHKIMM32)

  r.setFuncflag(uint16(0x98), instr32(cwde), {})
  r.setFuncflag(uint16(0x99), instr32(cdq), {})
  r.setFuncflag(uint16(0x9a), instr32(callfPtr16_32), CHKPTR16 + CHKIMM32)
  r.setFuncflag(uint16(0x9c), instr32(pushf), {})
  r.setFuncflag(uint16(0x9d), instr32(popf), {})

  r.setFuncflag(uint16(0xa1), instr32(movEaxMoffs32), CHKMOFFS)

  r.setFuncflag(uint16(0xa3), instr32(movMoffs32Eax), CHKMOFFS)
  r.setFuncflag(uint16(0xa6), instr32(cmpsM8M8), {})
  r.setFuncflag(uint16(0xa7), instr32(cmpsM32M32), {})

  r.setFuncflag(uint16(0xa9), instr32(testEaxImm32), CHKIMM32)

  r.setFuncflag(uint16(0xb8), instr32(movR32Imm32), CHKIMM32)

  r.setFuncflag(uint16(0xc3), instr32(ret), {})
  r.setFuncflag(uint16(0xc7), instr32(movRm32Imm32), CHKMODRM + CHKIMM32)
  r.setFuncflag(uint16(0xc9), instr32(leave), {})





  r.setFuncflag(uint16(0xe5),   instr32(inEaxImm8),    CHKIMM8)

  r.setFuncflag(uint16(0xe7),   instr32(outImm8Eax),   CHKIMM8)
  r.setFuncflag(uint16(0xe8),   instr32(callRel32),    CHKIMM32)
  r.setFuncflag(uint16(0xe9),   instr32(jmpRel32),     CHKIMM32)
  r.setFuncflag(uint16(0xea),   instr32(jmpfPtr16_32), CHKPTR16 + CHKIMM32)


  r.setFuncflag(uint16(0xed),   instr32(inEaxDx),      {})

  r.setFuncflag(uint16(0xef),   instr32(outDxEax),     {})
  r.setFuncflag(uint16(0x0f80), instr32(joRel32),      CHKIMM32)
  r.setFuncflag(uint16(0x0f81), instr32(jnoRel32),     CHKIMM32)
  r.setFuncflag(uint16(0x0f82), instr32(jbRel32),      CHKIMM32)
  r.setFuncflag(uint16(0x0f83), instr32(jnbRel32),     CHKIMM32)
  r.setFuncflag(uint16(0x0f84), instr32(jzRel32),      CHKIMM32)
  r.setFuncflag(uint16(0x0f85), instr32(jnzRel32),     CHKIMM32)
  r.setFuncflag(uint16(0x0f86), instr32(jbeRel32),     CHKIMM32)
  r.setFuncflag(uint16(0x0f87), instr32(jaRel32),      CHKIMM32)
  r.setFuncflag(uint16(0x0f88), instr32(jsRel32),      CHKIMM32)
  r.setFuncflag(uint16(0x0f89), instr32(jnsRel32),     CHKIMM32)
  r.setFuncflag(uint16(0x0f8a), instr32(jpRel32),      CHKIMM32)
  r.setFuncflag(uint16(0x0f8b), instr32(jnpRel32),     CHKIMM32)
  r.setFuncflag(uint16(0x0f8c), instr32(jlRel32),      CHKIMM32)
  r.setFuncflag(uint16(0x0f8d), instr32(jnlRel32),     CHKIMM32)
  r.setFuncflag(uint16(0x0f8e), instr32(jleRel32),     CHKIMM32)
  r.setFuncflag(uint16(0x0f8f), instr32(jnleRel32),    CHKIMM32)
  r.setFuncflag(uint16(0x0faf), instr32(imulR32Rm32),  CHKMODRM)
  r.setFuncflag(uint16(0x0fb6), instr32(movzxR32Rm8),  CHKMODRM)
  r.setFuncflag(uint16(0x0fb7), instr32(movzxR32Rm16), CHKMODRM)
  r.setFuncflag(uint16(0x0fbe), instr32(movsxR32Rm8),  CHKMODRM)
  r.setFuncflag(uint16(0x0fbf), instr32(movsxR32Rm16), CHKMODRM)

  r.setFuncflag(uint16(0x81), instr32(code81), CHKMODRM + CHKIMM32)
  r.setFuncflag(uint16(0x83), instr32(code81), CHKMODRM + CHKIMM8)

  r.setFuncflag(uint16(0xc1), instr32(codeC1), CHKMODRM + CHKIMM8)
  r.setFuncflag(uint16(0xd3), instr32(codeD3), CHKMODRM)
  r.setFuncflag(uint16(0xf7), instr32(codeF7), CHKMODRM)
  r.setFuncflag(uint16(0xff), instr32(codeFf), CHKMODRM)
  r.setFuncflag(uint16(0x0f00), instr32(code_0f00), CHKMODRM)
  r.setFuncflag(uint16(0x0f01), instr32(code_0f01), CHKMODRM)


proc initInstrImpl32*(instr: ExecInstr): InstrImpl =
  initInstrImpl32(result, instr)
