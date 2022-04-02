import instruction/[basehpp, instructionhpp]
import commonhpp, execcpp
import ../hardware/[eflagscpp, processorcpp]
import hardware/[processorhpp, memoryhpp, eflagshpp, iohpp]
import ../instruction/emucpp
import emulator/[exceptionhpp, emulatorhpp, accesshpp, interrupthpp]
import ./opcodes

template instrbase*(f: untyped): untyped {.dirty.} =
 instrfuncT(f)

proc setFuncflag*(
    this: var InstrImpl,
    opcode: ICode,
    implF: instrfuncT,
    flags: set[InstrParseFlag]
  ): void =

  var opcode = opcode.uint16
  if opcode shr 8 == 0x0f:
    opcode = (opcode and 0xff) or 0x0100

  ASSERT(opcode < MAXOPCODE)
  this.exec.instrfuncs[opcode] = implF
  this.parse.chk[opcode] = flags
  
proc getEmu*(this: var InstrImpl): Emulator =
  result = this.exec.getEmu()
  assertRef(result)

proc addRm8R8*(this: var InstrImpl): void =
  let rm8 = this.exec.getRm8()
  let r8 = this.exec.getR8()
  this.exec.setRm8(rm8 + r8)
  discard EFLAGSUPDATEADD(rm8, r8)

proc addR8Rm8*(this: var InstrImpl): void =
  let r8 = this.exec.getR8()
  let rm8 = this.exec.getRm8()
  this.exec.setR8(r8 + rm8)
  discard EFLAGSUPDATEADD(r8, rm8)

proc addAlImm8*(this: var InstrImpl): void =
  let al = GETGPREG(AL)
  CPU.setGPreg(AL, al + IMM8.uint8)
  discard EFLAGSUPDATEADD(al, IMM8.uint32)

proc orRm8R8*(this: var InstrImpl): void =
  let rm8 = this.exec.getRm8()
  let r8 = this.exec.getR8()
  this.exec.setRm8(rm8 or r8)
  discard EFLAGSUPDATEOR(rm8, r8)

proc orAlImm8*(this: var InstrImpl): void =
  let al = GETGPREG(AL)
  CPU.setGPreg(AL, al or IMM8.uint8)
  discard EFLAGSUPDATEOR(al, IMM8.uint8)

proc orR8Rm8*(this: var InstrImpl): void =
  let r8 = this.exec.getR8()
  let rm8 = this.exec.getRm8()
  this.exec.setR8(r8 or rm8)
  discard EFLAGSUPDATEOR(r8, rm8)

proc andRm8R8*(this: var InstrImpl): void =
  let rm8 = this.exec.getRm8()
  let r8 = this.exec.getR8()
  this.exec.setRm8(rm8 and r8)
  discard EFLAGSUPDATEAND(rm8, r8)

proc andR8Rm8*(this: var InstrImpl): void =
  let r8 = this.exec.getR8()
  let rm8 = this.exec.getRm8()
  this.exec.setR8(r8 and rm8)
  discard EFLAGSUPDATEAND(r8, rm8)

proc andAlImm8*(this: var InstrImpl): void =
  let al = GETGPREG(AL)
  CPU.setGPreg(AL, al and IMM8.uint8)
  discard EFLAGSUPDATEAND(al, IMM8.uint8)

proc subRm8R8*(this: var InstrImpl): void =
  let rm8 = this.exec.getRm8()
  let r8 = this.exec.getR8()
  this.exec.setRm8(rm8 - r8)
  discard EFLAGSUPDATESUB(rm8, r8)

proc subR8Rm8*(this: var InstrImpl): void =
  let r8 = this.exec.getR8()
  let rm8 = this.exec.getRm8()
  this.exec.setR8(r8 - rm8)
  discard EFLAGSUPDATESUB(r8, rm8)

proc subAlImm8*(this: var InstrImpl): void =
  let al = GETGPREG(AL)
  CPU.setGPreg(AL, al - IMM8.uint8)
  discard EFLAGSUPDATESUB(al, IMM8.uint8)

proc xorRm8R8*(this: var InstrImpl): void =
  let rm8 = this.exec.getRm8()
  let r8 = this.exec.getR8()
  this.exec.setRm8(rm8 xor r8)

proc xorR8Rm8*(this: var InstrImpl): void =
  let r8 = this.exec.getR8()
  let rm8 = this.exec.getRm8()
  this.exec.setR8(r8 xor rm8)

proc xorAlImm8*(this: var InstrImpl): void =
  let al = GETGPREG(AL)
  CPU.setGPreg(AL, al xor IMM8.uint8)

proc cmpRm8R8*(this: var InstrImpl): void =
  let rm8 = this.exec.getRm8()
  let r8 = this.exec.getR8()
  discard EFLAGSUPDATESUB(rm8, r8)

proc cmpR8Rm8*(this: var InstrImpl): void =
  let r8 = this.exec.getR8()
  let rm8 = this.exec.getRm8()
  discard EFLAGSUPDATESUB(r8, rm8)

proc cmpAlImm8*(this: var InstrImpl): void =
  let al = GETGPREG(AL)
  discard EFLAGSUPDATESUB(al, IMM8.uint8)

template JCCREL8*(cc: untyped, isFlag: untyped): untyped {.dirty.} =
  proc `j cc rel8`*(this: var InstrImpl): void =
    if isFlag:
      discard UPDATEIP(IMM8)

JCCREL8(o, EFLAGSOF)
JCCREL8(no, not(EFLAGSOF))
JCCREL8(b, EFLAGSCF)
JCCREL8(nb, not(EFLAGSCF))
JCCREL8(z, EFLAGSZF)
JCCREL8(nz, not(EFLAGSZF))
JCCREL8(be, EFLAGSCF or EFLAGSZF)
JCCREL8(a, not((EFLAGSCF or EFLAGSZF)))
JCCREL8(s, EFLAGSSF)
JCCREL8(ns, not(EFLAGSSF))
JCCREL8(p, EFLAGSPF)
JCCREL8(np, not(EFLAGSPF))
JCCREL8(l, EFLAGSSF != EFLAGSOF)
JCCREL8(nl, EFLAGSSF == EFLAGSOF)
JCCREL8(le, EFLAGSZF or (EFLAGSSF != EFLAGSOF))
JCCREL8(nle, not(EFLAGSZF) and (EFLAGSSF == EFLAGSOF))

proc testRm8R8*(this: var InstrImpl): void =
  var r8, rm8: uint8
  rm8 = this.exec.getRm8()
  r8 = this.exec.getR8()
  discard EFLAGSUPDATEAND(rm8, r8)

proc xchgR8Rm8*(this: var InstrImpl): void =
  var rm8, r8: uint8
  r8 = this.exec.getR8()
  rm8 = this.exec.getRm8()
  this.exec.setR8(rm8)
  this.exec.setRm8(r8)

proc movRm8R8*(this: var InstrImpl): void =
  var r8, rm8: uint8
  r8 = this.exec.getR8()
  this.exec.setRm8(r8)

proc movR8Rm8*(this: var InstrImpl): void =
  var rm8, r8: uint8
  rm8 = this.exec.getRm8()
  this.exec.setR8(rm8)

proc movSregRm16*(this: var InstrImpl): void =
  var rm16: uint16
  rm16 = this.exec.getRm16()
  setSreg(this.exec, rm16)

proc nop*(this: var InstrImpl): void =
  discard 


proc movAlMoffs8*(this: var InstrImpl): void =
  CPU.setGPreg(AL, this.exec.getMoffs8())

proc movMoffs8Al*(this: var InstrImpl): void =
  this.exec.setMoffs8(GETGPREG(AL))

proc testAlImm8*(this: var InstrImpl): void =
  var al: uint8
  al = GETGPREG(AL)
  discard EFLAGSUPDATEAND(al, IMM8.uint8)

proc movR8Imm8*(this: var InstrImpl): void =
  var reg: uint8
  reg = uint8(OPCODE and ((1 shl 3) - 1))
  CPU.setGPreg(cast[Reg8T](reg), IMM8.uint8)

proc movRm8Imm8*(this: var InstrImpl): void =
  this.exec.setRm8(IMM8.uint8)

proc retf*(this: var InstrImpl): void =
  this.emu.retf()

proc int3*(this: var InstrImpl): void =
  CPU.dumpRegs()
  MEM.dumpMem((ACS.getSegment(SS) shl 4) + CPU.getGpreg(ESP) - 0x40, 0x80.csizeT)

proc intImm8*(this: var InstrImpl): void =
  INT.queueInterrupt(IMM8.uint8, false)

proc iret*(this: var InstrImpl): void =
  this.emu.iret()

proc inAlImm8*(this: var InstrImpl): void =
  CPU.setGPreg(AL, EIO.inIo8(cast[uint8](IMM8)))

proc outImm8Al*(this: var InstrImpl): void =
  var al: uint8
  al = GETGPREG(AL)
  EIO.outIo8(cast[uint8](IMM8), al)

proc jmp*(this: var InstrImpl): void =
  discard UPDATEIP(IMM8)

proc inAlDx*(this: var InstrImpl): void =
  var dx: uint16
  dx = GETGPREG(DX)
  CPU.setGPreg(AL, EIO.inIo8(dx))

proc outDxAl*(this: var InstrImpl): void =
  var dx: uint16
  var al: uint8
  dx = GETGPREG(DX)
  al = GETGPREG(AL)
  EIO.outIo8(dx, al)

proc cli*(this: var InstrImpl): void =
  CPU.eflags.setInterrupt(false)

proc sti*(this: var InstrImpl): void =
  CPU.eflags.setInterrupt(true)

proc cld*(this: var InstrImpl): void =
  CPU.eflags.setDirection(false)

proc std*(this: var InstrImpl): void =
  CPU.eflags.setDirection(true)

proc hlt*(this: var InstrImpl): void =
  EXCEPTION(EXPGP, not(this.emu.chkRing(0)))
  CPU.doHalt(true)

proc ltrRm16*(this: var InstrImpl): void =
  var rm16: uint16
  EXCEPTION(EXPGP, not(this.emu.chkRing(0)))
  rm16 = this.exec.getRm16()
  this.emu.setTr(rm16)

proc movR32Crn*(this: var InstrImpl): void =
  var crn: uint32
  crn = this.exec.getCrn()
  CPU.setGPreg(cast[Reg32T](this.getModRmRM()), crn)
  

proc movCrnR32*(this: var InstrImpl): void =
  var r32: uint32
  EXCEPTION(EXPGP, not(this.emu.chkRing(0)))
  r32 = GETGPREG(cast[Reg32T](this.getModRmRM()))
  this.exec.setCrn(r32)

template SETCCRM8*(cc: untyped, isFlag: untyped): untyped {.dirty.} =
  proc `set cc rm8`*(this: var InstrImpl): void =
    CPU.setGPreg(cast[Reg32T](this.getModRmRM()), uint32(isFlag))
  

SETCCRM8(o, EFLAGSOF)
SETCCRM8(no, not(EFLAGSOF))
SETCCRM8(b, EFLAGSCF)
SETCCRM8(nb, not(EFLAGSCF))
SETCCRM8(z, EFLAGSZF)
SETCCRM8(nz, not(EFLAGSZF))
SETCCRM8(be, EFLAGSCF or EFLAGSZF)
SETCCRM8(a, not((EFLAGSCF or EFLAGSZF)))
SETCCRM8(s, EFLAGSSF)
SETCCRM8(ns, not(EFLAGSSF))
SETCCRM8(p, EFLAGSPF)
SETCCRM8(np, not(EFLAGSPF))
SETCCRM8(l, EFLAGSSF != EFLAGSOF)
SETCCRM8(nl, EFLAGSSF == EFLAGSOF)
SETCCRM8(le, EFLAGSZF or (EFLAGSSF != EFLAGSOF))
SETCCRM8(nle, not(EFLAGSZF) and (EFLAGSSF == EFLAGSOF))

proc addRm8Imm8*(this: var InstrImpl): void =
  var rm8: uint8
  rm8 = this.exec.getRm8()
  this.exec.setRm8(rm8 + IMM8.uint8)
  discard EFLAGSUPDATEADD(rm8, IMM8.uint8)

proc orRm8Imm8*(this: var InstrImpl): void =
  var rm8: uint8
  rm8 = this.exec.getRm8()
  this.exec.setRm8(rm8 or IMM8.uint8)
  discard EFLAGSUPDATEOR(rm8, IMM8.uint8)

proc adcRm8Imm8*(this: var InstrImpl): void =
  var cf, rm8: uint8
  rm8 = this.exec.getRm8()
  cf = EFLAGSCF.uint8
  this.exec.setRm8(rm8 + IMM8.uint8 + cf)
  discard EFLAGSUPDATEADD(rm8, IMM8.uint8 + cf)

proc sbbRm8Imm8*(this: var InstrImpl): void =
  var cf, rm8: uint8
  rm8 = this.exec.getRm8()
  cf = EFLAGSCF.uint8
  this.exec.setRm8(rm8 - IMM8.uint8 - cf)
  discard EFLAGSUPDATESUB(rm8, IMM8.uint8 + cf)

proc andRm8Imm8*(this: var InstrImpl): void =
  var rm8: uint8
  rm8 = this.exec.getRm8()
  this.exec.setRm8(rm8 and IMM8.uint8)
  discard EFLAGSUPDATEAND(rm8, IMM8.uint8)

proc subRm8Imm8*(this: var InstrImpl): void =
  var rm8: uint8
  rm8 = this.exec.getRm8()
  this.exec.setRm8(rm8 - IMM8.uint8)
  discard EFLAGSUPDATESUB(rm8, IMM8.uint8)

proc xorRm8Imm8*(this: var InstrImpl): void =
  var rm8: uint8
  rm8 = this.exec.getRm8()
  this.exec.setRm8(rm8 xor IMM8.uint8)

proc cmpRm8Imm8*(this: var InstrImpl): void =
  var rm8: uint8
  rm8 = this.exec.getRm8()
  discard EFLAGSUPDATESUB(rm8, IMM8.uint8)


proc shlRm8Imm8*(this: var InstrImpl): void =
  var rm8: uint8
  rm8 = this.exec.getRm8()
  this.exec.setRm8(rm8 shl IMM8.uint8)
  discard EFLAGSUPDATESHL(rm8, IMM8.uint8)

proc shrRm8Imm8*(this: var InstrImpl): void =
  var rm8: uint8
  rm8 = this.exec.getRm8()
  this.exec.setRm8(rm8 shr IMM8.uint8)
  discard EFLAGSUPDATESHR(rm8, IMM8.uint8)

proc salRm8Imm8*(this: var InstrImpl): void =
  var rm8S: int8
  rm8S = this.exec.getRm8().int8()
  this.exec.setRm8(uint8(rm8S shl IMM8))


proc sarRm8Imm8*(this: var InstrImpl): void =
  var rm8S: int8
  rm8S = this.exec.getRm8().int8
  this.exec.setRm8(uint8(rm8S shr IMM8))



proc testRm8Imm8*(this: var InstrImpl): void =
  var imm8, rm8: uint8
  rm8 = this.exec.getRm8()
  imm8 = ACS.getCode8(0)
  discard UPDATEEIP(1)
  discard EFLAGSUPDATEAND(rm8, imm8)

proc notRm8*(this: var InstrImpl): void =
  var rm8: uint8
  rm8 = this.exec.getRm8()
  this.exec.setRm8(not(rm8))

proc negRm8*(this: var InstrImpl): void =
  var rm8S: int8
  rm8S = this.exec.getRm8().int8
  this.exec.setRm8(uint8(-(rm8S)))
  discard EFLAGSUPDATESUB(cast[uint8](0), rm8S.uint8)

proc mulAxAlRm8*(this: var InstrImpl): void =
  var al, rm8: uint8
  var val: uint16
  rm8 = this.exec.getRm8()
  al = GETGPREG(AL)
  val = al * rm8
  CPU.setGPreg(AX, val)
  discard EFLAGSUPDATEMUL(al, rm8)

proc imulAxAlRm8*(this: var InstrImpl): void =
  var alS, rm8S: int8
  var valS: int16
  rm8S = this.exec.getRm8().int8
  alS = GETGPREG(AL).int8
  valS = alS * rm8S
  CPU.setGPreg(AX, valS.uint8)
  discard EFLAGSUPDATEIMUL(alS, rm8S)

proc divAlAhRm8*(this: var InstrImpl): void =
  var rm8: uint8
  var ax: uint16
  rm8 = this.exec.getRm8()
  ax = GETGPREG(AX)
  CPU.setGPreg(AL, uint8(ax div rm8))
  CPU.setGPreg(AH, uint8(ax mod rm8))

proc idivAlAhRm8*(this: var InstrImpl): void =
  var rm8S: int8
  var axS: int16
  rm8S = this.exec.getRm8().int8
  axS = GETGPREG(AX).int16
  CPU.setGPreg(AL, uint8(axS div rm8S))
  CPU.setGPreg(AH, uint8(axS mod rm8S))


proc code_80*(this: var InstrImpl): void =
  case this.getModrmReg():
    of 0: this.addRm8Imm8()
    of 1: this.orRm8Imm8()
    of 2: this.adcRm8Imm8()
    of 3: this.sbbRm8Imm8()
    of 4: this.andRm8Imm8()
    of 5: this.subRm8Imm8()
    of 6: this.xorRm8Imm8()
    of 7: this.cmpRm8Imm8()
    else:
      ERROR("not implemented: 0x80 /%d\\n", this.getModrmReg())

proc code_82*(this: var InstrImpl): void =
  code_80(this)

proc codeC0*(this: var InstrImpl): void =
  case this.getModrmReg():
    of 4: this.shlRm8Imm8()
    of 5: this.shrRm8Imm8()
    of 6: this.salRm8Imm8()
    of 7: this.sarRm8Imm8()
    else:
      ERROR("not implemented: 0xc0 /%d\\n", this.getModrmReg())

proc codeF6*(this: var InstrImpl): void =
  case this.getModrmReg():
    of 0: this.testRm8Imm8()
    of 2: this.notRm8()
    of 3: this.negRm8()
    of 4: this.mulAxAlRm8()
    of 5: this.imulAxAlRm8()
    of 6: this.divAlAhRm8()
    of 7: this.idivAlAhRm8()
    else:
      ERROR("not implemented: 0xf6 /%d\\n", this.getModrmReg())

proc incRm8*(this: var InstrImpl) =
  let val = this.exec.getRm8().uint8()
  this.exec.setRm8(val + 1)
  discard EFLAGSUPDATEADD(val, 0)

proc codeFE*(this: var InstrImpl) =
  case this.getModrmReg():
    of 0: this.incRm8()
    else:
      assert false, $this.getModrmReg()

proc initInstrImpl*(r: var InstrImpl, instr: Instruction) =
  asgnAux[Instruction](r.exec, instr)
  assertRef(r.exec.get_emu())
  r.emu.emu = instr.emu

  r.setFuncflag(ICode(0x00), instrbase(addRm8R8),    CHKMODRM)
  r.setFuncflag(ICode(0x02), instrbase(addR8Rm8),    CHKMODRM)
  r.setFuncflag(ICode(0x04), instrbase(addAlImm8),   CHKIMM8)
  r.setFuncflag(ICode(0x08), instrbase(orRm8R8),     CHKMODRM)
  r.setFuncflag(ICode(0x0a), instrbase(orR8Rm8),     CHKMODRM)
  r.setFuncflag(ICode(0x0c), instrbase(orAlImm8),    CHKIMM8)
  r.setFuncflag(ICode(0x20), instrbase(andRm8R8),    CHKMODRM)
  r.setFuncflag(ICode(0x22), instrbase(andR8Rm8),    CHKMODRM)
  r.setFuncflag(ICode(0x24), instrbase(andAlImm8),   CHKIMM8)
  r.setFuncflag(ICode(0x28), instrbase(subRm8R8),    CHKMODRM)
  r.setFuncflag(ICode(0x2a), instrbase(subR8Rm8),    CHKMODRM)
  r.setFuncflag(ICode(0x2c), instrbase(subAlImm8),   CHKIMM8)
  r.setFuncflag(ICode(0x30), instrbase(xorRm8R8),    CHKMODRM)
  r.setFuncflag(ICode(0x32), instrbase(xorR8Rm8),    CHKMODRM)
  r.setFuncflag(ICode(0x34), instrbase(xorAlImm8),   CHKIMM8)
  r.setFuncflag(ICode(0x38), instrbase(cmpRm8R8),    CHKMODRM)
  r.setFuncflag(ICode(0x3a), instrbase(cmpR8Rm8),    CHKMODRM)
  r.setFuncflag(ICode(0x3c), instrbase(cmpAlImm8),   CHKIMM8)
  r.setFuncflag(ICode(0x70), instrbase(joRel8),      CHKIMM8)
  r.setFuncflag(ICode(0x71), instrbase(jnoRel8),     CHKIMM8)
  r.setFuncflag(ICode(0x72), instrbase(jbRel8),      CHKIMM8)
  r.setFuncflag(ICode(0x73), instrbase(jnbRel8),     CHKIMM8)
  r.setFuncflag(ICode(0x74), instrbase(jzRel8),      CHKIMM8)
  r.setFuncflag(ICode(0x75), instrbase(jnzRel8),     CHKIMM8)
  r.setFuncflag(ICode(0x76), instrbase(jbeRel8),     CHKIMM8)
  r.setFuncflag(ICode(0x77), instrbase(jaRel8),      CHKIMM8)
  r.setFuncflag(ICode(0x78), instrbase(jsRel8),      CHKIMM8)
  r.setFuncflag(ICode(0x79), instrbase(jnsRel8),     CHKIMM8)
  r.setFuncflag(ICode(0x7a), instrbase(jpRel8),      CHKIMM8)
  r.setFuncflag(ICode(0x7b), instrbase(jnpRel8),     CHKIMM8)
  r.setFuncflag(ICode(0x7c), instrbase(jlRel8),      CHKIMM8)
  r.setFuncflag(ICode(0x7d), instrbase(jnlRel8),     CHKIMM8)
  r.setFuncflag(ICode(0x7e), instrbase(jleRel8),     CHKIMM8)
  r.setFuncflag(ICode(0x7f), instrbase(jnleRel8),    CHKIMM8)
  r.setFuncflag(ICode(0x84), instrbase(testRm8R8),   CHKMODRM)
  r.setFuncflag(ICode(0x86), instrbase(xchgR8Rm8),   CHKMODRM)
  r.setFuncflag(ICode(0x88), instrbase(movRm8R8),    CHKMODRM)
  r.setFuncflag(ICode(0x8a), instrbase(movR8Rm8),    CHKMODRM)
  r.setFuncflag(ICode(0x8e), instrbase(movSregRm16), CHKMODRM)
  r.setFuncflag(ICode(0x90), instrbase(nop),         {})
  r.setFuncflag(ICode(0xa0), instrbase(movAlMoffs8), CHKMOFFS)
  r.setFuncflag(ICode(0xa2), instrbase(movMoffs8Al), CHKMOFFS)
  r.setFuncflag(ICode(0xa8), instrbase(testAlImm8),  CHKIMM8)

  r.setFuncflag(ICode(0xb0), instrbase(movR8Imm8), CHKIMM8)

  r.setFuncflag(ICode(0xc6),   instrbase(movRm8Imm8), CHKMODRM + CHKIMM8)
  r.setFuncflag(ICode(0xcb),   instrbase(retf),       {})
  r.setFuncflag(ICode(0xcc),   instrbase(int3),       {})
  r.setFuncflag(ICode(0xcd),   instrbase(intImm8),    CHKIMM8)
  r.setFuncflag(ICode(0xcf),   instrbase(iret),       {})
  r.setFuncflag(ICode(0xe4),   instrbase(inAlImm8),   CHKIMM8)
  r.setFuncflag(ICode(0xe6),   instrbase(outImm8Al),  CHKIMM8)
  r.setFuncflag(ICode(0xeb),   instrbase(jmp),        CHKIMM8)
  r.setFuncflag(ICode(0xec),   instrbase(inAlDx),     {})
  r.setFuncflag(ICode(0xee),   instrbase(outDxAl),    {})
  r.setFuncflag(ICode(0xfa),   instrbase(cli),        {})
  r.setFuncflag(ICode(0xfb),   instrbase(sti),        {})
  r.setFuncflag(ICode(0xfc),   instrbase(cld),        {})
  r.setFuncflag(ICode(0xfd),   instrbase(std),        {})
  r.setFuncflag(ICode(0xf4),   instrbase(hlt),        {})
  r.setFuncflag(ICode(0x0f20), instrbase(movR32Crn),  CHKMODRM)
  r.setFuncflag(ICode(0x0f22), instrbase(movCrnR32),  CHKMODRM)
  r.setFuncflag(ICode(0x0f90), instrbase(setoRm8),    CHKMODRM)
  r.setFuncflag(ICode(0x0f91), instrbase(setnoRm8),   CHKMODRM)
  r.setFuncflag(ICode(0x0f92), instrbase(setbRm8),    CHKMODRM)
  r.setFuncflag(ICode(0x0f93), instrbase(setnbRm8),   CHKMODRM)
  r.setFuncflag(ICode(0x0f94), instrbase(setzRm8),    CHKMODRM)
  r.setFuncflag(ICode(0x0f95), instrbase(setnzRm8),   CHKMODRM)
  r.setFuncflag(ICode(0x0f96), instrbase(setbeRm8),   CHKMODRM)
  r.setFuncflag(ICode(0x0f97), instrbase(setaRm8),    CHKMODRM)
  r.setFuncflag(ICode(0x0f98), instrbase(setsRm8),    CHKMODRM)
  r.setFuncflag(ICode(0x0f99), instrbase(setnsRm8),   CHKMODRM)
  r.setFuncflag(ICode(0x0f9a), instrbase(setpRm8),    CHKMODRM)
  r.setFuncflag(ICode(0x0f9b), instrbase(setnpRm8),   CHKMODRM)
  r.setFuncflag(ICode(0x0f9c), instrbase(setlRm8),    CHKMODRM)
  r.setFuncflag(ICode(0x0f9d), instrbase(setnlRm8),   CHKMODRM)
  r.setFuncflag(ICode(0x0f9e), instrbase(setleRm8),   CHKMODRM)
  r.setFuncflag(ICode(0x0f9f), instrbase(setnleRm8),  CHKMODRM)
  r.setFuncflag(ICode(0x80),   instrbase(code_80),    CHKMODRM + CHKIMM8)
  r.setFuncflag(ICode(0x82),   instrbase(code_82),    CHKMODRM + CHKIMM8)
  r.setFuncflag(ICode(0xc0),   instrbase(codeC0),     CHKMODRM + CHKIMM8)
  r.setFuncflag(ICode(0xf6),   instrbase(codeF6),     CHKMODRM)
  r.setFuncFlag(ICode(0xfe),   instrbase(codeFE),     CHKMODRM)


proc initInstrImpl*(instr: Instruction): InstrImpl =
  initInstrImpl(result, instr)
