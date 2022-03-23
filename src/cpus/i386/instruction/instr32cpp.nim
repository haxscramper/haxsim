import instruction/[basehpp, instructionhpp]
import instr_basecpp
import commonhpp
import ./emucpp
import ./instr_basecpp
import ./execcpp
import ../hardware/eflagscpp
import hardware/[processorhpp, eflagshpp, iohpp]
import emulator/[exceptionhpp, emulatorhpp, accesshpp]

template instr32*(f: untyped): untyped {.dirty.} = 
  assert false, "Merge 16 and 32-bit instruction constructors together"
  instrfunc_t(nil)

proc select_segment*(this: var Instr32): sgreg_t =
  this.exec.select_segment()

proc add_rm32_r32*(this: var Instr32): void = 
  var r32, rm32: uint32
  rm32 = this.exec.get_rm32().uint32()
  r32 = this.exec.get_r32()
  this.exec.set_rm32(rm32 + r32)
  discard EFLAGS_UPDATE_ADD(rm32, r32)

proc add_r32_rm32*(this: var Instr32): void = 
  var rm32, r32: uint32
  r32 = this.exec.get_r32()
  rm32 = this.exec.get_rm32().uint32()
  this.exec.set_r32(r32 + rm32)
  discard EFLAGS_UPDATE_ADD(r32, rm32)

proc add_eax_imm32*(this: var Instr32): void = 
  var eax: uint32
  eax = GET_GPREG(EAX)
  SET_GPREG(EAX, eax + IMM32.uint32)
  discard EFLAGS_UPDATE_ADD(eax, IMM32.uint32)

proc push_es*(this: var Instr32): void = 
  PUSH32(ACS.get_segment(ES))

proc pop_es*(this: var Instr32): void = 
  ACS.set_segment(ES, POP32().uint16)

proc or_rm32_r32*(this: var Instr32): void = 
  var r32, rm32: uint32
  rm32 = this.exec.get_rm32().uint32()
  r32 = this.exec.get_r32()
  this.exec.set_rm32(rm32 or r32)
  discard EFLAGS_UPDATE_OR(rm32, r32)

proc or_r32_rm32*(this: var Instr32): void = 
  var rm32, r32: uint32
  r32 = this.exec.get_r32()
  rm32 = this.exec.get_rm32().uint32()
  this.exec.set_r32(r32 or rm32)
  discard EFLAGS_UPDATE_OR(r32, rm32)

proc or_eax_imm32*(this: var Instr32): void = 
  var eax: uint32
  eax = GET_GPREG(EAX)
  SET_GPREG(EAX, eax or IMM32.uint32)
  discard EFLAGS_UPDATE_OR(eax, IMM32.uint32)

proc push_ss*(this: var Instr32): void = 
  PUSH32(ACS.get_segment(SS))

proc pop_ss*(this: var Instr32): void = 
  ACS.set_segment(SS, POP32().uint16)

proc push_ds*(this: var Instr32): void = 
  PUSH32(ACS.get_segment(DS))

proc pop_ds*(this: var Instr32): void = 
  ACS.set_segment(DS, POP32().uint16)

proc and_rm32_r32*(this: var Instr32): void = 
  var r32, rm32: uint32
  rm32 = this.exec.get_rm32().uint32()
  r32 = this.exec.get_r32()
  this.exec.set_rm32(rm32 and r32)
  discard EFLAGS_UPDATE_AND(rm32, r32)

proc and_r32_rm32*(this: var Instr32): void = 
  var rm32, r32: uint32
  r32 = this.exec.get_r32()
  rm32 = this.exec.get_rm32().uint32()
  this.exec.set_r32(r32 and rm32)
  discard EFLAGS_UPDATE_AND(r32, rm32)

proc and_eax_imm32*(this: var Instr32): void = 
  var eax: uint32
  eax = GET_GPREG(EAX)
  SET_GPREG(EAX, eax and IMM32.uint32)
  discard EFLAGS_UPDATE_AND(eax, IMM32.uint32)

proc sub_rm32_r32*(this: var Instr32): void = 
  var r32, rm32: uint32
  rm32 = this.exec.get_rm32().uint32()
  r32 = this.exec.get_r32()
  this.exec.set_rm32(rm32 - r32)
  discard EFLAGS_UPDATE_SUB(rm32, r32)

proc sub_r32_rm32*(this: var Instr32): void = 
  var rm32, r32: uint32
  r32 = this.exec.get_r32()
  rm32 = this.exec.get_rm32().uint32()
  this.exec.set_r32(r32 - rm32)
  discard EFLAGS_UPDATE_SUB(r32, rm32)

proc sub_eax_imm32*(this: var Instr32): void = 
  var eax: uint32
  eax = GET_GPREG(EAX)
  SET_GPREG(EAX, eax - IMM32.uint32)
  discard EFLAGS_UPDATE_SUB(eax, IMM32.uint32)

proc xor_rm32_r32*(this: var Instr32): void = 
  var r32, rm32: uint32
  rm32 = this.exec.get_rm32().uint32()
  r32 = this.exec.get_r32()
  this.exec.set_rm32(rm32 xor r32)

proc xor_r32_rm32*(this: var Instr32): void = 
  var rm32, r32: uint32
  r32 = this.exec.get_r32()
  rm32 = this.exec.get_rm32().uint32()
  this.exec.set_r32(r32 xor rm32)

proc xor_eax_imm32*(this: var Instr32): void = 
  var eax: uint32
  eax = GET_GPREG(EAX)
  SET_GPREG(EAX, eax xor IMM32.uint32)

proc cmp_rm32_r32*(this: var Instr32): void = 
  var r32, rm32: uint32
  rm32 = this.exec.get_rm32().uint32()
  r32 = this.exec.get_r32()
  discard EFLAGS_UPDATE_SUB(rm32, r32)

proc cmp_r32_rm32*(this: var Instr32): void = 
  var rm32, r32: uint32
  r32 = this.exec.get_r32()
  rm32 = this.exec.get_rm32().uint32()
  discard EFLAGS_UPDATE_SUB(r32, rm32)

proc cmp_eax_imm32*(this: var Instr32): void = 
  var eax: uint32
  eax = GET_GPREG(EAX)
  discard EFLAGS_UPDATE_SUB(eax, IMM32.uint32)

proc inc_r32*(this: var Instr32): void = 
  var reg: uint8
  var r32: uint32
  reg = uint8(OPCODE and ((1 shl 3) - 1))
  r32 = GET_GPREG(cast[reg32_t](reg))
  SET_GPREG(cast[reg32_t](reg), r32 + 1)
  discard EFLAGS_UPDATE_ADD(r32, 1)

proc dec_r32*(this: var Instr32): void = 
  var reg: uint8
  var r32: uint32
  reg = uint8(OPCODE and ((1 shl 3) - 1))
  r32 = GET_GPREG(cast[reg32_t](reg))
  SET_GPREG(cast[reg32_t](reg), r32 - 1)
  discard EFLAGS_UPDATE_SUB(r32, 1)

proc push_r32*(this: var Instr32): void = 
  var reg: uint8
  reg = uint8(OPCODE and ((1 shl 3) - 1))
  PUSH32(GET_GPREG(cast[reg32_t](reg)))

proc pop_r32*(this: var Instr32): void = 
  var reg: uint8
  reg = uint8(OPCODE and ((1 shl 3) - 1))
  SET_GPREG(cast[reg32_t](reg), POP32())

proc pushad*(this: var Instr32): void = 
  var esp: uint32
  esp = GET_GPREG(ESP)
  PUSH32(GET_GPREG(EAX))
  PUSH32(GET_GPREG(ECX))
  PUSH32(GET_GPREG(EDX))
  PUSH32(GET_GPREG(EBX))
  PUSH32(esp)
  PUSH32(GET_GPREG(EBP))
  PUSH32(GET_GPREG(ESI))
  PUSH32(GET_GPREG(EDI))

proc popad*(this: var Instr32): void = 
  var esp: uint32
  SET_GPREG(EDI, POP32())
  SET_GPREG(ESI, POP32())
  SET_GPREG(EBP, POP32())
  esp = POP32()
  SET_GPREG(EBX, POP32())
  SET_GPREG(EDX, POP32())
  SET_GPREG(ECX, POP32())
  SET_GPREG(EAX, POP32())
  SET_GPREG(ESP, esp)

proc push_imm32*(this: var Instr32): void = 
  PUSH32(IMM32.uint32)

proc imul_r32_rm32_imm32*(this: var Instr32): void = 
  var rm32_s: int32
  rm32_s = this.exec.get_rm32().int32
  this.exec.set_r32(uint32(rm32_s * IMM32))
  discard EFLAGS_UPDATE_IMUL(rm32_s, IMM32)

proc push_imm8*(this: var Instr32): void = 
  PUSH32(IMM8.uint32)

proc imul_r32_rm32_imm8*(this: var Instr32): void = 
  var rm32_s: int32
  rm32_s = this.exec.get_rm32().int32
  this.exec.set_r32(uint32(rm32_s * IMM8))
  discard EFLAGS_UPDATE_IMUL(rm32_s, IMM8.int32)

proc test_rm32_r32*(this: var Instr32): void = 
  var r32, rm32: uint32
  rm32 = this.exec.get_rm32().uint32()
  r32 = this.exec.get_r32()
  discard EFLAGS_UPDATE_AND(rm32, r32)

proc xchg_r32_rm32*(this: var Instr32): void = 
  var rm32, r32: uint32
  r32 = this.exec.get_r32().uint32()
  rm32 = this.exec.get_rm32().uint32()
  this.exec.set_r32(rm32)
  this.exec.set_rm32(r32)

proc mov_rm32_r32*(this: var Instr32): void = 
  var r32: uint32
  r32 = this.exec.get_r32()
  this.exec.set_rm32(r32)

proc mov_r32_rm32*(this: var Instr32): void = 
  var rm32: uint32
  rm32 = this.exec.get_rm32().uint32()
  this.exec.set_r32(rm32)

proc mov_rm32_sreg*(this: var Instr32): void = 
  var sreg: uint16
  sreg = this.exec.get_sreg()
  this.exec.set_rm32(sreg)

proc lea_r32_m32*(this: var Instr32): void = 
  var m32: uint32
  m32 = this.exec.get_m()
  this.exec.set_r32(m32)

proc xchg_r32_eax*(this: var Instr32): void = 
  var eax, r32: uint32
  r32 = this.exec.get_r32()
  eax = GET_GPREG(EAX)
  this.exec.set_r32(eax)
  SET_GPREG(EAX, r32)

proc cwde*(this: var Instr32): void = 
  var ax_s: int16
  ax_s = GET_GPREG(AX).int16()
  SET_GPREG(EAX, ax_s.uint32)

proc cdq*(this: var Instr32): void = 
  var eax: uint32
  eax = GET_GPREG(EAX)
  SET_GPREG(EDX, uint32(if toBool(eax and (1 shl 31)): -1 else: 0))

proc callf_ptr16_32*(this: var Instr32): void = 
  this.emu.callf(PTR16.uint16, IMM32.uint32)

proc pushf*(this: var Instr32): void = 
  PUSH32(CPU.eflags.get_eflags())

proc popf*(this: var Instr32): void = 
  CPU.eflags.set_eflags(POP32())

proc mov_eax_moffs32*(this: var Instr32): void = 
  SET_GPREG(EAX, this.exec.get_moffs32())

proc mov_moffs32_eax*(this: var Instr32): void = 
  this.exec.set_moffs32(GET_GPREG(EAX))

proc cmps_m8_m8*(this: var Instr32): void = 
  var m8_d, m8_s: uint8
  block repeat:
    m8_s = ACS.get_data8(this.exec.select_segment(), GET_GPREG(ESI))
  m8_d = ACS.get_data8(ES, GET_GPREG(EDI))
  discard EFLAGS_UPDATE_SUB(m8_s, m8_d)
  discard UPDATE_GPREG(ESI, int32(if EFLAGS_DF: -1 else: 1))
  discard UPDATE_GPREG(EDI, int32(if EFLAGS_DF: -1 else: 1))
  if PRE_REPEAT.int.toBool():
    discard UPDATE_GPREG(ECX, -1)
    case PRE_REPEAT:
      of REPZ:
        if not(GET_GPREG(ECX)).toBool() or not(EFLAGS_ZF):
          {.warning: "[FIXME] break".}
        
        {.warning: "[FIXME] cxx_goto repeat".}
      of REPNZ:
        if not(GET_GPREG(ECX)).toBool() or EFLAGS_ZF:
          {.warning: "[FIXME] break".}
        
        {.warning: "[FIXME] cxx_goto repeat".}
      else:
        discard 
  

proc cmps_m32_m32*(this: var Instr32): void = 
  var m32_d, m32_s: uint32
  block repeat:
    m32_s = ACS.get_data32(this.exec.select_segment(), GET_GPREG(ESI))
  m32_d = ACS.get_data32(ES, GET_GPREG(EDI))
  discard EFLAGS_UPDATE_SUB(m32_s, m32_d)
  discard UPDATE_GPREG(ESI, int32(if EFLAGS_DF: -1 else: 1))
  discard UPDATE_GPREG(EDI, int32(if EFLAGS_DF: -1 else: 1))
  if PRE_REPEAT.int.toBool():
    discard UPDATE_GPREG(ECX, -1)
    case PRE_REPEAT:
      of REPZ:
        if not(GET_GPREG(ECX)).toBool() or not(EFLAGS_ZF):
          {.warning: "[FIXME] break".}
        
        {.warning: "[FIXME] cxx_goto repeat".}
      of REPNZ:
        if not(GET_GPREG(ECX)).toBool() or EFLAGS_ZF:
          {.warning: "[FIXME] break".}
        
        {.warning: "[FIXME] cxx_goto repeat".}
      else:
        discard 
  

proc test_eax_imm32*(this: var Instr32): void = 
  var eax: uint32
  eax = GET_GPREG(EAX)
  discard EFLAGS_UPDATE_AND(eax, IMM32.uint32)

proc mov_r32_imm32*(this: var Instr32): void = 
  var reg: uint8
  reg = uint8(OPCODE and ((1 shl 3) - 1))
  SET_GPREG(cast[reg32_t](reg), IMM32.uint32)

proc ret*(this: var Instr32): void = 
  SET_EIP(POP32())

proc mov_rm32_imm32*(this: var Instr32): void = 
  this.exec.set_rm32(IMM32.uint32)

proc leave*(this: var Instr32): void = 
  var ebp: uint32
  ebp = GET_GPREG(EBP)
  SET_GPREG(ESP, ebp)
  SET_GPREG(EBP, POP32())

proc in_eax_imm8*(this: var Instr32): void = 
  SET_GPREG(EAX, EIO.in_io32(IMM8.uint16))

proc out_imm8_eax*(this: var Instr32): void = 
  var eax: uint32
  eax = GET_GPREG(EAX)
  EIO.out_io32(IMM8.uint16, eax)

proc call_rel32*(this: var Instr32): void = 
  PUSH32(GET_EIP())
  discard UPDATE_EIP(IMM32)

proc jmp_rel32*(this: var Instr32): void = 
  discard UPDATE_EIP(IMM32)

proc jmpf_ptr16_32*(this: var Instr32): void = 
  this.emu.jmpf(PTR16.uint16, IMM32.uint32)

proc in_eax_dx*(this: var Instr32): void = 
  var dx: uint16
  dx = GET_GPREG(DX)
  SET_GPREG(EAX, EIO.in_io32(dx))

proc out_dx_eax*(this: var Instr32): void = 
  var dx: uint16
  var eax: uint32
  dx = GET_GPREG(DX)
  eax = GET_GPREG(EAX)
  EIO.out_io32(dx, eax)

template JCC_REL32*(cc: untyped, is_flag: untyped): untyped {.dirty.} = 
  proc `j cc rel32`*(this: var Instr32): void =
    if is_flag:
      discard UPDATE_EIP(IMM32)
    
  

JCC_REL32(o, EFLAGS_OF)
JCC_REL32(no, not(EFLAGS_OF))
JCC_REL32(b, EFLAGS_CF)
JCC_REL32(nb, not(EFLAGS_CF))
JCC_REL32(z, EFLAGS_ZF)
JCC_REL32(nz, not(EFLAGS_ZF))
JCC_REL32(be, EFLAGS_CF or EFLAGS_ZF)
JCC_REL32(a, not((EFLAGS_CF or EFLAGS_ZF)))
JCC_REL32(s, EFLAGS_SF)
JCC_REL32(ns, not(EFLAGS_SF))
JCC_REL32(p, EFLAGS_PF)
JCC_REL32(np, not(EFLAGS_PF))
JCC_REL32(l, EFLAGS_SF != EFLAGS_OF)
JCC_REL32(nl, EFLAGS_SF == EFLAGS_OF)
JCC_REL32(le, EFLAGS_ZF or (EFLAGS_SF != EFLAGS_OF))
JCC_REL32(nle, not(EFLAGS_ZF) and (EFLAGS_SF == EFLAGS_OF))
proc imul_r32_rm32*(this: var Instr32): void = 
  var rm32_s, r32_s: int16
  r32_s = this.exec.get_r32().int16()
  rm32_s = this.exec.get_rm32().int16()
  this.exec.set_r32(uint32(r32_s * rm32_s))
  discard EFLAGS_UPDATE_IMUL(r32_s, rm32_s)

proc movzx_r32_rm8*(this: var Instr32): void = 
  var rm8: uint8
  rm8 = this.exec.get_rm8()
  this.exec.set_r32(rm8)

proc movzx_r32_rm16*(this: var Instr32): void = 
  var rm16: uint16
  rm16 = this.exec.get_rm16()
  this.exec.set_r32(rm16)

proc movsx_r32_rm8*(this: var Instr32): void = 
  var rm8_s: int8
  rm8_s = this.exec.get_rm8().int8()
  this.exec.set_r32(uint32(rm8_s))

proc movsx_r32_rm16*(this: var Instr32): void = 
  var rm16_s: int16
  rm16_s = this.exec.get_rm16().int16()
  this.exec.set_r32(uint32(rm16_s))


proc add_rm32_imm32*(this: var Instr32): void =
  var rm32: uint32
  rm32 = this.exec.get_rm32().uint32()
  this.exec.set_rm32(rm32 + IMM32.uint32)
  discard EFLAGS_UPDATE_ADD(rm32, IMM32.uint32)

proc or_rm32_imm32*(this: var Instr32): void = 
  var rm32: uint32
  rm32 = this.exec.get_rm32().uint32()
  this.exec.set_rm32(rm32 or IMM32.uint32)
  discard EFLAGS_UPDATE_OR(rm32, IMM32.uint32)

proc adc_rm32_imm32*(this: var Instr32): void = 
  var rm32: uint32
  var cf: uint8
  rm32 = this.exec.get_rm32().uint32()
  cf = EFLAGS_CF.uint8
  this.exec.set_rm32(rm32 + IMM32.uint32 + cf)
  discard EFLAGS_UPDATE_ADD(rm32, IMM32.uint32 + cf)

proc sbb_rm32_imm32*(this: var Instr32): void = 
  var rm32: uint32
  var cf: uint8
  rm32 = this.exec.get_rm32().uint32()
  cf = EFLAGS_CF.uint8
  this.exec.set_rm32(rm32 - IMM32.uint32 - cf)
  discard EFLAGS_UPDATE_SUB(rm32, IMM32.uint32 + cf)

proc and_rm32_imm32*(this: var Instr32): void = 
  var rm32: uint32
  rm32 = this.exec.get_rm32().uint32()
  this.exec.set_rm32(rm32 and IMM32.uint32)
  discard EFLAGS_UPDATE_AND(rm32, IMM32.uint32)

proc sub_rm32_imm32*(this: var Instr32): void = 
  var rm32: uint32
  rm32 = this.exec.get_rm32().uint32()
  this.exec.set_rm32(rm32 - IMM32.uint32)
  discard EFLAGS_UPDATE_SUB(rm32, IMM32.uint32)

proc xor_rm32_imm32*(this: var Instr32): void = 
  var rm32: uint32
  rm32 = this.exec.get_rm32().uint32()
  this.exec.set_rm32(rm32 xor IMM32.uint32)

proc cmp_rm32_imm32*(this: var Instr32): void = 
  var rm32: uint32
  rm32 = this.exec.get_rm32().uint32()
  discard EFLAGS_UPDATE_SUB(rm32, IMM32.uint32)


proc add_rm32_imm8*(this: var Instr32): void = 
  var rm32: uint32
  rm32 = this.exec.get_rm32().uint32()
  this.exec.set_rm32(rm32 + IMM8.uint32)
  discard EFLAGS_UPDATE_ADD(rm32, IMM8.uint32)

proc or_rm32_imm8*(this: var Instr32): void = 
  var rm32: uint32
  rm32 = this.exec.get_rm32().uint32()
  this.exec.set_rm32(rm32 or IMM8.uint32)
  discard EFLAGS_UPDATE_OR(rm32, IMM8.uint32)

proc adc_rm32_imm8*(this: var Instr32): void = 
  var rm32: uint32
  var cf: uint8
  rm32 = this.exec.get_rm32().uint32()
  cf = EFLAGS_CF.uint8
  this.exec.set_rm32(rm32 + IMM8.uint32 + cf)
  discard EFLAGS_UPDATE_ADD(rm32, IMM8.uint32 + cf)

proc sbb_rm32_imm8*(this: var Instr32): void = 
  var rm32: uint32
  var cf: uint8
  rm32 = this.exec.get_rm32().uint32()
  cf = EFLAGS_CF.uint8
  this.exec.set_rm32(rm32 - IMM8.uint32 - cf)
  discard EFLAGS_UPDATE_SUB(rm32, IMM8.uint32 + cf)

proc and_rm32_imm8*(this: var Instr32): void = 
  var rm32: uint32
  rm32 = this.exec.get_rm32().uint32()
  this.exec.set_rm32(rm32 and IMM8.uint32)
  discard EFLAGS_UPDATE_AND(rm32, IMM8.uint32)

proc sub_rm32_imm8*(this: var Instr32): void = 
  var rm32: uint32
  rm32 = this.exec.get_rm32().uint32()
  this.exec.set_rm32(rm32 - IMM8.uint32)
  discard EFLAGS_UPDATE_SUB(rm32, IMM8.uint32)

proc xor_rm32_imm8*(this: var Instr32): void = 
  var rm32: uint32
  rm32 = this.exec.get_rm32().uint32()
  this.exec.set_rm32(rm32 xor IMM8.uint32)

proc cmp_rm32_imm8*(this: var Instr32): void = 
  var rm32: uint32
  rm32 = this.exec.get_rm32().uint32()
  discard EFLAGS_UPDATE_SUB(rm32, IMM8.uint32)


proc shl_rm32_imm8*(this: var Instr32): void = 
  var rm32: uint32
  rm32 = this.exec.get_rm32().uint32()
  this.exec.set_rm32(rm32 shl IMM8.uint32)
  discard EFLAGS_UPDATE_SHL(rm32, IMM8.uint8)

proc shr_rm32_imm8*(this: var Instr32): void = 
  var rm32: uint32
  rm32 = this.exec.get_rm32().uint32()
  this.exec.set_rm32(rm32 shr IMM8.uint32)
  discard EFLAGS_UPDATE_SHR(rm32, IMM8.uint8)

proc sal_rm32_imm8*(this: var Instr32): void = 
  var rm32_s: int32
  rm32_s = this.exec.get_rm32().int32()
  this.exec.set_rm32(uint32(rm32_s shl IMM8))
  

proc sar_rm32_imm8*(this: var Instr32): void = 
  var rm32_s: int32
  rm32_s = this.exec.get_rm32().int32()
  this.exec.set_rm32(uint32(rm32_s shr IMM8))
  


proc shl_rm32_cl*(this: var Instr32): void = 
  var rm32: uint32
  var cl: uint8
  rm32 = this.exec.get_rm32().uint32()
  cl = GET_GPREG(CL)
  this.exec.set_rm32(rm32 shl cl)
  discard EFLAGS_UPDATE_SHL(rm32, cl)

proc shr_rm32_cl*(this: var Instr32): void = 
  var rm32: uint32
  var cl: uint8
  rm32 = this.exec.get_rm32().uint32()
  cl = GET_GPREG(CL)
  this.exec.set_rm32(rm32 shr cl)
  discard EFLAGS_UPDATE_SHR(rm32, cl)

proc sal_rm32_cl*(this: var Instr32): void = 
  var rm32_s: int32
  var cl: uint8
  rm32_s = this.exec.get_rm32().int32()
  cl = GET_GPREG(CL)
  this.exec.set_rm32(uint32(rm32_s shl cl))
  

proc sar_rm32_cl*(this: var Instr32): void = 
  var rm32_s: int32
  var cl: uint8
  rm32_s = this.exec.get_rm32().int32()
  cl = GET_GPREG(CL)
  this.exec.set_rm32(uint32(rm32_s shr cl))
  


proc test_rm32_imm32*(this: var Instr32): void = 
  var imm32, rm32: uint32
  rm32 = this.exec.get_rm32().uint32()
  imm32 = ACS.get_code32(0)
  discard UPDATE_EIP(4)
  discard EFLAGS_UPDATE_AND(rm32, imm32)

proc not_rm32*(this: var Instr32): void = 
  var rm32: uint32
  rm32 = this.exec.get_rm32().uint32()
  this.exec.set_rm32(not(rm32))

proc neg_rm32*(this: var Instr32): void = 
  var rm32_s: int32
  rm32_s = this.exec.get_rm32().int32()
  this.exec.set_rm32(uint32(-(rm32_s)))
  discard EFLAGS_UPDATE_SUB(cast[uint32](0), rm32_s.uint32)

proc mul_edx_eax_rm32*(this: var Instr32): void = 
  var eax, rm32: uint32
  var val: uint64
  rm32 = this.exec.get_rm32().uint32()
  eax = GET_GPREG(EAX)
  val = eax * rm32
  SET_GPREG(EAX, uint32(val))
  SET_GPREG(EDX, uint32(val shr 32))
  discard EFLAGS_UPDATE_MUL(eax, rm32)

proc imul_edx_eax_rm32*(this: var Instr32): void = 
  var eax_s, rm32_s: int32
  var val_s: int64
  rm32_s = this.exec.get_rm32().int32()
  eax_s = GET_GPREG(EAX).int32()
  val_s = eax_s * rm32_s
  SET_GPREG(EAX, uint32(val_s))
  SET_GPREG(EDX, uint32(val_s shr 32))
  discard EFLAGS_UPDATE_IMUL(eax_s, rm32_s)

proc div_edx_eax_rm32*(this: var Instr32): void = 
  var rm32: uint32
  var val: uint64
  rm32 = this.exec.get_rm32().uint32()
  EXCEPTION(EXP_DE, not(rm32.toBool()))
  val = GET_GPREG(EDX)
  val = (val shl 32)
  val = (val or GET_GPREG(EAX))
  SET_GPREG(EAX, uint32(val div rm32))
  SET_GPREG(EDX, uint32(val mod rm32))

proc idiv_edx_eax_rm32*(this: var Instr32): void = 
  var rm32_s: int32
  var val_s: int64
  rm32_s = this.exec.get_rm32().int32()
  EXCEPTION(EXP_DE, not(rm32_s.toBool()))
  val_s = GET_GPREG(EDX).int64
  val_s = (val_s shl 32)
  val_s = (val_s or GET_GPREG(EAX).int64)
  SET_GPREG(EAX, uint32(val_s div rm32_s))
  SET_GPREG(EDX, uint32(val_s mod rm32_s))


proc inc_rm32*(this: var Instr32): void = 
  var rm32: uint32
  rm32 = this.exec.get_rm32().uint32()
  this.exec.set_rm32(rm32 + 1)
  discard EFLAGS_UPDATE_ADD(rm32, 1)

proc dec_rm32*(this: var Instr32): void = 
  var rm32: uint32
  rm32 = this.exec.get_rm32().uint32()
  this.exec.set_rm32(rm32 - 1)
  discard EFLAGS_UPDATE_SUB(rm32, 1)

proc call_rm32*(this: var Instr32): void = 
  var rm32: uint32
  rm32 = this.exec.get_rm32().uint32()
  PUSH32(GET_EIP())
  SET_EIP(rm32)

proc callf_m16_32*(this: var Instr32): void = 
  var eip, m48: uint32
  var cs: uint16
  m48 = this.exec.get_m()
  eip = READ_MEM32(m48)
  cs = READ_MEM16(m48 + 4)
  INFO(2, "cs = 0x%04x, eip = 0x%08x", cs, eip)
  this.emu.callf(cs, eip)

proc jmp_rm32*(this: var Instr32): void = 
  var rm32: uint32
  rm32 = this.exec.get_rm32().uint32()
  SET_EIP(rm32)

proc jmpf_m16_32*(this: var Instr32): void = 
  var eip, m48: uint32
  var sel: uint16
  m48 = this.exec.get_m()
  eip = READ_MEM32(m48)
  sel = READ_MEM16(m48 + 4)
  this.emu.jmpf(sel, eip)

proc push_rm32*(this: var Instr32): void = 
  var rm32: uint32
  rm32 = this.exec.get_rm32().uint32()
  PUSH32(rm32)


proc lgdt_m32*(this: var Instr32): void = 
  var base, m48: uint32
  var limit: uint16
  EXCEPTION(EXP_GP, not(this.emu.chk_ring(0)))
  m48 = this.exec.get_m()
  limit = READ_MEM16(m48)
  base = READ_MEM32(m48 + 2)
  INFO(2, "base = 0x%08x, limit = 0x%04x", base, limit)
  this.emu.set_gdtr(base, limit)

proc lidt_m32*(this: var Instr32): void = 
  var base, m48: uint32
  var limit: uint16
  EXCEPTION(EXP_GP, not(this.emu.chk_ring(0)))
  m48 = this.exec.get_m()
  limit = READ_MEM16(m48)
  base = READ_MEM32(m48 + 2)
  INFO(2, "base = 0x%08x, limit = 0x%04x", base, limit)
  this.emu.set_idtr(base, limit)


proc code_81*(this: var Instr32): void =
  case REG:
    of 0: this.add_rm32_imm32()
    of 1: this.or_rm32_imm32()
    of 2: this.adc_rm32_imm32()
    of 3: this.sbb_rm32_imm32()
    of 4: this.and_rm32_imm32()
    of 5: this.sub_rm32_imm32()
    of 6: this.xor_rm32_imm32()
    of 7: this.cmp_rm32_imm32()
    else:
      ERROR("not implemented: 0x81 /%d\\n", REG)

proc code_83*(this: var Instr32): void =
  case REG:
    of 0: this.add_rm32_imm8()
    of 1: this.or_rm32_imm8()
    of 2: this.adc_rm32_imm8()
    of 3: this.sbb_rm32_imm8()
    of 4: this.and_rm32_imm8()
    of 5: this.sub_rm32_imm8()
    of 6: this.xor_rm32_imm8()
    of 7: this.cmp_rm32_imm8()
    else:
      ERROR("not implemented: 0x83 /%d\\n", REG)

proc code_c1*(this: var Instr32): void =
  case REG:
    of 4: this.shl_rm32_imm8()
    of 5: this.shr_rm32_imm8()
    of 6: this.sal_rm32_imm8()
    of 7: this.sar_rm32_imm8()
    else:
      ERROR("not implemented: 0xc1 /%d\\n", REG)

proc code_d3*(this: var Instr32): void =
  case REG:
    of 4: this.shl_rm32_cl()
    of 5: this.shr_rm32_cl()
    of 6: this.sal_rm32_cl()
    of 7: this.sar_rm32_cl()
    else:
      ERROR("not implemented: 0xd3 /%d\\n", REG)

proc code_f7*(this: var Instr32): void =
  case REG:
    of 0: this.test_rm32_imm32()
    of 2: this.not_rm32()
    of 3: this.neg_rm32()
    of 4: this.mul_edx_eax_rm32()
    of 5: this.imul_edx_eax_rm32()
    of 6: this.div_edx_eax_rm32()
    of 7: this.idiv_edx_eax_rm32()
    else:
      ERROR("not implemented: 0xf7 /%d\\n", REG)

proc code_ff*(this: var Instr32): void =
  case REG:
    of 0: this.inc_rm32()
    of 1: this.dec_rm32()
    of 2: this.call_rm32()
    of 3: this.callf_m16_32()
    of 4: this.jmp_rm32()
    of 5: this.jmpf_m16_32()
    of 6: this.push_rm32()
    else:
      ERROR("not implemented: 0xff /%d\\n", REG)

proc code_0f00*(this: var Instr32): void =
  case REG:
    of 3: this.ltr_rm16()
    else:
      ERROR("not implemented: 0x0f00 /%d\\n", REG)

proc code_0f01*(this: var Instr32): void =
  case REG:
    of 2: this.lgdt_m32()
    of 3: this.lidt_m32()
    else:
      ERROR("not implemented: 0x0f01 /%d\\n", REG)




proc initInstr32*(r: var Instr32, e: ptr Emulator, id: ptr InstrData) =
  var i: cint
  r.set_funcflag(0x01, instr32(add_rm32_r32), CHK_MODRM)

  r.set_funcflag(0x03, instr32(add_r32_rm32), CHK_MODRM)

  r.set_funcflag(0x05, instr32(add_eax_imm32), CHK_IMM32)
  r.set_funcflag(0x06, instr32(push_es), 0)
  r.set_funcflag(0x07, instr32(pop_es), 0)

  r.set_funcflag(0x09, instr32(or_rm32_r32), CHK_MODRM)

  r.set_funcflag(0x0b, instr32(or_r32_rm32), CHK_MODRM)

  r.set_funcflag(0x0d, instr32(or_eax_imm32), CHK_IMM32)
  r.set_funcflag(0x16, instr32(push_ss), 0)
  r.set_funcflag(0x17, instr32(pop_ss), 0)
  r.set_funcflag(0x1e, instr32(push_ds), 0)
  r.set_funcflag(0x1f, instr32(pop_ds), 0)

  r.set_funcflag(0x21, instr32(and_rm32_r32), CHK_MODRM)

  r.set_funcflag(0x23, instr32(and_r32_rm32), CHK_MODRM)

  r.set_funcflag(0x25, instr32(and_eax_imm32), CHK_IMM32)

  r.set_funcflag(0x29, instr32(sub_rm32_r32), CHK_MODRM)

  r.set_funcflag(0x2b, instr32(sub_r32_rm32), CHK_MODRM)

  r.set_funcflag(0x2d, instr32(sub_eax_imm32), CHK_IMM32)

  r.set_funcflag(0x31, instr32(xor_rm32_r32), CHK_MODRM)

  r.set_funcflag(0x33, instr32(xor_r32_rm32), CHK_MODRM)

  r.set_funcflag(0x35, instr32(xor_eax_imm32), CHK_IMM32)

  r.set_funcflag(0x39, instr32(cmp_rm32_r32), CHK_MODRM)

  r.set_funcflag(0x3b, instr32(cmp_r32_rm32), CHK_MODRM)

  r.set_funcflag(0x3d, instr32(cmp_eax_imm32), CHK_IMM32)
  block:
    i = 0
    while i < 8:
      r.set_funcflag(uint16(0x40 + i), instr32(inc_r32), 0)
      postInc(i)
  block:
    i = 0
    while i < 8:
      r.set_funcflag(uint16(0x48 + i), instr32(dec_r32), 0)
      postInc(i)
  block:
    i = 0
    while i < 8:
      r.set_funcflag(uint16(0x50 + i), instr32(push_r32), 0)
      postInc(i)
  block:
    i = 0
    while i < 8:
      r.set_funcflag(uint16(0x58 + i), instr32(pop_r32), 0)
      postInc(i)
  r.set_funcflag(0x60, instr32(pushad), 0)
  r.set_funcflag(0x61, instr32(popad), 0)
  r.set_funcflag(0x68, instr32(push_imm32), CHK_IMM32)
  r.set_funcflag(0x69, instr32(imul_r32_rm32_imm32), CHK_MODRM or CHK_IMM32)
  r.set_funcflag(0x6a, instr32(push_imm8), CHK_IMM8)
  r.set_funcflag(0x6b, instr32(imul_r32_rm32_imm8), CHK_MODRM or CHK_IMM8)


  r.set_funcflag(0x85, instr32(test_rm32_r32), CHK_MODRM)

  r.set_funcflag(0x87, instr32(xchg_r32_rm32), CHK_MODRM)

  r.set_funcflag(0x89, instr32(mov_rm32_r32), CHK_MODRM)

  r.set_funcflag(0x8b, instr32(mov_r32_rm32), CHK_MODRM)
  r.set_funcflag(0x8c, instr32(mov_rm32_sreg), CHK_MODRM)
  r.set_funcflag(0x8d, instr32(lea_r32_m32), CHK_MODRM)


  block:
    i = 1
    while i < 8:
      r.set_funcflag(uint16(0x90 + i), instr32(xchg_r32_eax), CHK_IMM32)
      postInc(i)
  r.set_funcflag(0x98, instr32(cwde), 0)
  r.set_funcflag(0x99, instr32(cdq), 0)
  r.set_funcflag(0x9a, instr32(callf_ptr16_32), CHK_PTR16 or CHK_IMM32)
  r.set_funcflag(0x9c, instr32(pushf), 0)
  r.set_funcflag(0x9d, instr32(popf), 0)

  r.set_funcflag(0xa1, instr32(mov_eax_moffs32), CHK_MOFFS)

  r.set_funcflag(0xa3, instr32(mov_moffs32_eax), CHK_MOFFS)
  r.set_funcflag(0xa6, instr32(cmps_m8_m8), 0)
  r.set_funcflag(0xa7, instr32(cmps_m32_m32), 0)

  r.set_funcflag(0xa9, instr32(test_eax_imm32), CHK_IMM32)

  block:
    i = 0
    while i < 8:
      r.set_funcflag(uint16(0xb8 + i), instr32(mov_r32_imm32), CHK_IMM32)
      postInc(i)
  r.set_funcflag(0xc3, instr32(ret), 0)
  r.set_funcflag(0xc7, instr32(mov_rm32_imm32), CHK_MODRM or CHK_IMM32)
  r.set_funcflag(0xc9, instr32(leave), 0)





  r.set_funcflag(0xe5, instr32(in_eax_imm8), CHK_IMM8)

  r.set_funcflag(0xe7, instr32(out_imm8_eax), CHK_IMM8)
  r.set_funcflag(0xe8, instr32(call_rel32), CHK_IMM32)
  r.set_funcflag(0xe9, instr32(jmp_rel32), CHK_IMM32)
  r.set_funcflag(0xea, instr32(jmpf_ptr16_32), CHK_PTR16 or CHK_IMM32)


  r.set_funcflag(0xed, instr32(in_eax_dx), 0)

  r.set_funcflag(0xef, instr32(out_dx_eax), 0)
  r.set_funcflag(0x0f80, instr32(jo_rel32), CHK_IMM32)
  r.set_funcflag(0x0f81, instr32(jno_rel32), CHK_IMM32)
  r.set_funcflag(0x0f82, instr32(jb_rel32), CHK_IMM32)
  r.set_funcflag(0x0f83, instr32(jnb_rel32), CHK_IMM32)
  r.set_funcflag(0x0f84, instr32(jz_rel32), CHK_IMM32)
  r.set_funcflag(0x0f85, instr32(jnz_rel32), CHK_IMM32)
  r.set_funcflag(0x0f86, instr32(jbe_rel32), CHK_IMM32)
  r.set_funcflag(0x0f87, instr32(ja_rel32), CHK_IMM32)
  r.set_funcflag(0x0f88, instr32(js_rel32), CHK_IMM32)
  r.set_funcflag(0x0f89, instr32(jns_rel32), CHK_IMM32)
  r.set_funcflag(0x0f8a, instr32(jp_rel32), CHK_IMM32)
  r.set_funcflag(0x0f8b, instr32(jnp_rel32), CHK_IMM32)
  r.set_funcflag(0x0f8c, instr32(jl_rel32), CHK_IMM32)
  r.set_funcflag(0x0f8d, instr32(jnl_rel32), CHK_IMM32)
  r.set_funcflag(0x0f8e, instr32(jle_rel32), CHK_IMM32)
  r.set_funcflag(0x0f8f, instr32(jnle_rel32), CHK_IMM32)
  r.set_funcflag(0x0faf, instr32(imul_r32_rm32), CHK_MODRM)
  r.set_funcflag(0x0fb6, instr32(movzx_r32_rm8), CHK_MODRM)
  r.set_funcflag(0x0fb7, instr32(movzx_r32_rm16), CHK_MODRM)
  r.set_funcflag(0x0fbe, instr32(movsx_r32_rm8), CHK_MODRM)
  r.set_funcflag(0x0fbf, instr32(movsx_r32_rm16), CHK_MODRM)

  r.set_funcflag(0x81, instr32(code_81), CHK_MODRM or CHK_IMM32)

  r.set_funcflag(0x83, instr32(code_83), CHK_MODRM or CHK_IMM8)

  r.set_funcflag(0xc1, instr32(code_c1), CHK_MODRM or CHK_IMM8)
  r.set_funcflag(0xd3, instr32(code_d3), CHK_MODRM)
  r.set_funcflag(0xf7, instr32(code_f7), CHK_MODRM)
  r.set_funcflag(0xff, instr32(code_ff), CHK_MODRM)
  r.set_funcflag(0x0f00, instr32(code_0f00), CHK_MODRM)
  r.set_funcflag(0x0f01, instr32(code_0f01), CHK_MODRM)


proc initInstr32*(e: ptr Emulator, id: ptr InstrData): Instr32 =
  initInstr32(result, e, id)
