import
  stdinth
import
  instruction/basehpp
import
  emulator/exceptionhpp
template instr16*(f: untyped) {.dirty.} = 
  ((instrfunc_t) and Instr16.f)

proc initInstr16*(e: ptr Emulator, id: ptr InstrData): Instr16_Instr16 = 
  var i: cint
  
  set_funcflag(0x01, instr16(add_rm16_r16), CHK_MODRM)
  
  set_funcflag(0x03, instr16(add_r16_rm16), CHK_MODRM)
  
  set_funcflag(0x05, instr16(add_ax_imm16), CHK_IMM16)
  set_funcflag(0x06, instr16(push_es), 0)
  set_funcflag(0x07, instr16(pop_es), 0)
  
  set_funcflag(0x09, instr16(or_rm16_r16), CHK_MODRM)
  
  set_funcflag(0x0b, instr16(or_r16_rm16), CHK_MODRM)
  
  set_funcflag(0x0d, instr16(or_ax_imm16), CHK_IMM16)
  set_funcflag(0x16, instr16(push_ss), 0)
  set_funcflag(0x17, instr16(pop_ss), 0)
  set_funcflag(0x1e, instr16(push_ds), 0)
  set_funcflag(0x1f, instr16(pop_ds), 0)
  
  set_funcflag(0x21, instr16(and_rm16_r16), CHK_MODRM)
  
  set_funcflag(0x23, instr16(and_r16_rm16), CHK_MODRM)
  
  set_funcflag(0x25, instr16(and_ax_imm16), CHK_IMM16)
  
  set_funcflag(0x29, instr16(sub_rm16_r16), CHK_MODRM)
  
  set_funcflag(0x2b, instr16(sub_r16_rm16), CHK_MODRM)
  
  set_funcflag(0x2d, instr16(sub_ax_imm16), CHK_IMM16)
  
  set_funcflag(0x31, instr16(xor_rm16_r16), CHK_MODRM)
  
  set_funcflag(0x33, instr16(xor_r16_rm16), CHK_MODRM)
  
  set_funcflag(0x35, instr16(xor_ax_imm16), CHK_IMM16)
  
  set_funcflag(0x39, instr16(cmp_rm16_r16), CHK_MODRM)
  
  set_funcflag(0x3b, instr16(cmp_r16_rm16), CHK_MODRM)
  
  set_funcflag(0x3d, instr16(cmp_ax_imm16), CHK_IMM16)
  block:
    i = 0
    while i < 8:
      set_funcflag(0x40 + i, instr16(inc_r16), 0)
      postInc(i)
  block:
    i = 0
    while i < 8:
      set_funcflag(0x48 + i, instr16(dec_r16), 0)
      postInc(i)
  block:
    i = 0
    while i < 8:
      set_funcflag(0x50 + i, instr16(push_r16), 0)
      postInc(i)
  block:
    i = 0
    while i < 8:
      set_funcflag(0x58 + i, instr16(pop_r16), 0)
      postInc(i)
  set_funcflag(0x60, instr16(pusha), 0)
  set_funcflag(0x61, instr16(popa), 0)
  set_funcflag(0x68, instr16(push_imm16), CHK_IMM16)
  set_funcflag(0x69, instr16(imul_r16_rm16_imm16), CHK_MODRM or CHK_IMM16)
  set_funcflag(0x6a, instr16(push_imm8), CHK_IMM8)
  set_funcflag(0x6b, instr16(imul_r16_rm16_imm8), CHK_MODRM or CHK_IMM8)
  
  
  set_funcflag(0x85, instr16(test_rm16_r16), CHK_MODRM)
  
  set_funcflag(0x87, instr16(xchg_r16_rm16), CHK_MODRM)
  
  set_funcflag(0x89, instr16(mov_rm16_r16), CHK_MODRM)
  
  set_funcflag(0x8b, instr16(mov_r16_rm16), CHK_MODRM)
  set_funcflag(0x8c, instr16(mov_rm16_sreg), CHK_MODRM)
  set_funcflag(0x8d, instr16(lea_r16_m16), CHK_MODRM)
  
  
  block:
    i = 1
    while i < 8:
      set_funcflag(0x90 + i, instr16(xchg_r16_ax), CHK_IMM16)
      postInc(i)
  set_funcflag(0x98, instr16(cbw), 0)
  set_funcflag(0x99, instr16(cwd), 0)
  set_funcflag(0x9a, instr16(callf_ptr16_16), CHK_PTR16 or CHK_IMM16)
  set_funcflag(0x9c, instr16(pushf), 0)
  set_funcflag(0x9d, instr16(popf), 0)
  
  set_funcflag(0xa1, instr16(mov_ax_moffs16), CHK_MOFFS)
  
  set_funcflag(0xa3, instr16(mov_moffs16_ax), CHK_MOFFS)
  set_funcflag(0xa6, instr16(cmps_m8_m8), 0)
  set_funcflag(0xa7, instr16(cmps_m16_m16), 0)
  
  set_funcflag(0xa9, instr16(test_ax_imm16), CHK_IMM16)
  
  block:
    i = 0
    while i < 8:
      set_funcflag(0xb8 + i, instr16(mov_r16_imm16), CHK_IMM16)
      postInc(i)
  set_funcflag(0xc3, instr16(ret), 0)
  set_funcflag(0xc7, instr16(mov_rm16_imm16), CHK_MODRM or CHK_IMM16)
  set_funcflag(0xc9, instr16(leave), 0)
  
  
  
  
  
  set_funcflag(0xe5, instr16(in_ax_imm8), CHK_IMM8)
  
  set_funcflag(0xe7, instr16(out_imm8_ax), CHK_IMM8)
  set_funcflag(0xe8, instr16(call_rel16), CHK_IMM16)
  set_funcflag(0xe9, instr16(jmp_rel16), CHK_IMM16)
  set_funcflag(0xea, instr16(jmpf_ptr16_16), CHK_PTR16 or CHK_IMM16)
  
  
  set_funcflag(0xed, instr16(in_ax_dx), 0)
  
  set_funcflag(0xef, instr16(out_dx_ax), 0)
  set_funcflag(0x0f80, instr16(jo_rel16), CHK_IMM16)
  set_funcflag(0x0f81, instr16(jno_rel16), CHK_IMM16)
  set_funcflag(0x0f82, instr16(jb_rel16), CHK_IMM16)
  set_funcflag(0x0f83, instr16(jnb_rel16), CHK_IMM16)
  set_funcflag(0x0f84, instr16(jz_rel16), CHK_IMM16)
  set_funcflag(0x0f85, instr16(jnz_rel16), CHK_IMM16)
  set_funcflag(0x0f86, instr16(jbe_rel16), CHK_IMM16)
  set_funcflag(0x0f87, instr16(ja_rel16), CHK_IMM16)
  set_funcflag(0x0f88, instr16(js_rel16), CHK_IMM16)
  set_funcflag(0x0f89, instr16(jns_rel16), CHK_IMM16)
  set_funcflag(0x0f8a, instr16(jp_rel16), CHK_IMM16)
  set_funcflag(0x0f8b, instr16(jnp_rel16), CHK_IMM16)
  set_funcflag(0x0f8c, instr16(jl_rel16), CHK_IMM16)
  set_funcflag(0x0f8d, instr16(jnl_rel16), CHK_IMM16)
  set_funcflag(0x0f8e, instr16(jle_rel16), CHK_IMM16)
  set_funcflag(0x0f8f, instr16(jnle_rel16), CHK_IMM16)
  set_funcflag(0x0faf, instr16(imul_r16_rm16), CHK_MODRM)
  set_funcflag(0x0fb6, instr16(movzx_r16_rm8), CHK_MODRM)
  set_funcflag(0x0fb7, instr16(movzx_r16_rm16), CHK_MODRM)
  set_funcflag(0x0fbe, instr16(movsx_r16_rm8), CHK_MODRM)
  set_funcflag(0x0fbf, instr16(movsx_r16_rm16), CHK_MODRM)
  
  set_funcflag(0x81, instr16(code_81), CHK_MODRM or CHK_IMM16)
  
  set_funcflag(0x83, instr16(code_83), CHK_MODRM or CHK_IMM8)
  
  set_funcflag(0xc1, instr16(code_c1), CHK_MODRM or CHK_IMM8)
  set_funcflag(0xd3, instr16(code_d3), CHK_MODRM)
  set_funcflag(0xf7, instr16(code_f7), CHK_MODRM)
  set_funcflag(0xff, instr16(code_ff), CHK_MODRM)
  set_funcflag(0x0f00, instr16(code_0f00), CHK_MODRM)
  set_funcflag(0x0f01, instr16(code_0f01), CHK_MODRM)

proc add_rm16_r16*(this: var Instr16): void = 
  var r16: uint16
  rm16 = get_rm16()
  r16 = get_r16()
  set_rm16(rm16 + r16)
  EFLAGS_UPDATE_ADD(rm16, r16)

proc add_r16_rm16*(this: var Instr16): void = 
  var rm16: uint16
  r16 = get_r16()
  rm16 = get_rm16()
  set_r16(r16 + rm16)
  EFLAGS_UPDATE_ADD(r16, rm16)

proc add_ax_imm16*(this: var Instr16): void = 
  var ax: uint16
  ax = GET_GPREG(AX)
  SET_GPREG(AX, ax + IMM16)
  EFLAGS_UPDATE_ADD(ax, IMM16)

proc push_es*(this: var Instr16): void = 
  PUSH16(EMU.get_segment(ES))

proc pop_es*(this: var Instr16): void = 
  EMU.set_segment(ES, POP16())

proc or_rm16_r16*(this: var Instr16): void = 
  var r16: uint16
  rm16 = get_rm16()
  r16 = get_r16()
  set_rm16(rm16 or r16)
  EFLAGS_UPDATE_OR(rm16, r16)

proc or_r16_rm16*(this: var Instr16): void = 
  var rm16: uint16
  r16 = get_r16()
  rm16 = get_rm16()
  set_r16(r16 or rm16)
  EFLAGS_UPDATE_OR(r16, rm16)

proc or_ax_imm16*(this: var Instr16): void = 
  var ax: uint16
  ax = GET_GPREG(AX)
  SET_GPREG(AX, ax or IMM16)
  EFLAGS_UPDATE_OR(ax, IMM16)

proc push_ss*(this: var Instr16): void = 
  PUSH16(EMU.get_segment(SS))

proc pop_ss*(this: var Instr16): void = 
  EMU.set_segment(SS, POP16())

proc push_ds*(this: var Instr16): void = 
  PUSH16(EMU.get_segment(DS))

proc pop_ds*(this: var Instr16): void = 
  EMU.set_segment(DS, POP16())

proc and_rm16_r16*(this: var Instr16): void = 
  var r16: uint16
  rm16 = get_rm16()
  r16 = get_r16()
  set_rm16(rm16 and r16)
  EFLAGS_UPDATE_AND(rm16, r16)

proc and_r16_rm16*(this: var Instr16): void = 
  var rm16: uint16
  r16 = get_r16()
  rm16 = get_rm16()
  set_r16(r16 and rm16)
  EFLAGS_UPDATE_AND(r16, rm16)

proc and_ax_imm16*(this: var Instr16): void = 
  var ax: uint16
  ax = GET_GPREG(AX)
  SET_GPREG(AX, ax and IMM16)
  EFLAGS_UPDATE_AND(ax, IMM16)

proc sub_rm16_r16*(this: var Instr16): void = 
  var r16: uint16
  rm16 = get_rm16()
  r16 = get_r16()
  set_rm16(rm16 - r16)
  EFLAGS_UPDATE_SUB(rm16, r16)

proc sub_r16_rm16*(this: var Instr16): void = 
  var rm16: uint16
  r16 = get_r16()
  rm16 = get_rm16()
  set_r16(r16 - rm16)
  EFLAGS_UPDATE_SUB(r16, rm16)

proc sub_ax_imm16*(this: var Instr16): void = 
  var ax: uint16
  ax = GET_GPREG(AX)
  SET_GPREG(AX, ax - IMM16)
  EFLAGS_UPDATE_SUB(ax, IMM16)

proc xor_rm16_r16*(this: var Instr16): void = 
  var r16: uint16
  rm16 = get_rm16()
  r16 = get_r16()
  set_rm16(rm16 xor r16)

proc xor_r16_rm16*(this: var Instr16): void = 
  var rm16: uint16
  r16 = get_r16()
  rm16 = get_rm16()
  set_r16(r16 xor rm16)

proc xor_ax_imm16*(this: var Instr16): void = 
  var ax: uint16
  ax = GET_GPREG(AX)
  SET_GPREG(AX, ax xor IMM16)

proc cmp_rm16_r16*(this: var Instr16): void = 
  var r16: uint16
  rm16 = get_rm16()
  r16 = get_r16()
  EFLAGS_UPDATE_SUB(rm16, r16)

proc cmp_r16_rm16*(this: var Instr16): void = 
  var rm16: uint16
  r16 = get_r16()
  rm16 = get_rm16()
  EFLAGS_UPDATE_SUB(r16, rm16)

proc cmp_ax_imm16*(this: var Instr16): void = 
  var ax: uint16
  ax = GET_GPREG(AX)
  EFLAGS_UPDATE_SUB(ax, IMM16)

proc inc_r16*(this: var Instr16): void = 
  var reg: uint8
  var r16: uint16
  reg = OPCODE and ((1 shl 3) - 1)
  r16 = GET_GPREG(static_cast[reg16_t](reg))
  SET_GPREG(static_cast[reg16_t](reg), r16 + 1)
  EFLAGS_UPDATE_ADD(r16, 1)

proc dec_r16*(this: var Instr16): void = 
  var reg: uint8
  var r16: uint16
  reg = OPCODE and ((1 shl 3) - 1)
  r16 = GET_GPREG(static_cast[reg16_t](reg))
  SET_GPREG(static_cast[reg16_t](reg), r16 - 1)
  EFLAGS_UPDATE_SUB(r16, 1)

proc push_r16*(this: var Instr16): void = 
  var reg: uint8
  reg = OPCODE and ((1 shl 3) - 1)
  PUSH16(GET_GPREG(static_cast[reg16_t](reg)))

proc pop_r16*(this: var Instr16): void = 
  var reg: uint8
  reg = OPCODE and ((1 shl 3) - 1)
  SET_GPREG(static_cast[reg16_t](reg), POP16())

proc pusha*(this: var Instr16): void = 
  var sp: uint16
  sp = GET_GPREG(SP)
  PUSH16(GET_GPREG(AX))
  PUSH16(GET_GPREG(CX))
  PUSH16(GET_GPREG(DX))
  PUSH16(GET_GPREG(BX))
  PUSH16(sp)
  PUSH16(GET_GPREG(BP))
  PUSH16(GET_GPREG(SI))
  PUSH16(GET_GPREG(DI))

proc popa*(this: var Instr16): void = 
  var sp: uint16
  SET_GPREG(DI, POP16())
  SET_GPREG(SI, POP16())
  SET_GPREG(BP, POP16())
  sp = POP16()
  SET_GPREG(BX, POP16())
  SET_GPREG(DX, POP16())
  SET_GPREG(CX, POP16())
  SET_GPREG(AX, POP16())
  SET_GPREG(SP, sp)

proc push_imm16*(this: var Instr16): void = 
  PUSH16(IMM16)

proc imul_r16_rm16_imm16*(this: var Instr16): void = 
  var rm16_s: int16
  rm16_s = get_rm16()
  set_r16(rm16_s * IMM16)
  EFLAGS_UPDATE_IMUL(rm16_s, IMM16)

proc push_imm8*(this: var Instr16): void = 
  PUSH16(IMM8)

proc imul_r16_rm16_imm8*(this: var Instr16): void = 
  var rm16_s: int16
  rm16_s = get_rm16()
  set_r16(rm16_s * IMM8)
  EFLAGS_UPDATE_IMUL(rm16_s, IMM8)

proc test_rm16_r16*(this: var Instr16): void = 
  var r16: uint16
  rm16 = get_rm16()
  r16 = get_r16()
  EFLAGS_UPDATE_AND(rm16, r16)

proc xchg_r16_rm16*(this: var Instr16): void = 
  var rm16: uint16
  r16 = get_r16()
  rm16 = get_rm16()
  set_r16(rm16)
  set_rm16(r16)

proc mov_rm16_r16*(this: var Instr16): void = 
  var r16: uint16
  r16 = get_r16()
  set_rm16(r16)

proc mov_r16_rm16*(this: var Instr16): void = 
  var rm16: uint16
  rm16 = get_rm16()
  set_r16(rm16)

proc mov_rm16_sreg*(this: var Instr16): void = 
  var sreg: uint16
  sreg = get_sreg()
  set_rm16(sreg)

proc lea_r16_m16*(this: var Instr16): void = 
  var m16: uint16
  m16 = get_m()
  set_r16(m16)

proc xchg_r16_ax*(this: var Instr16): void = 
  var ax: uint16
  r16 = get_r16()
  ax = GET_GPREG(AX)
  set_r16(ax)
  SET_GPREG(AX, r16)

proc cbw*(this: var Instr16): void = 
  var al_s: int8
  al_s = GET_GPREG(AL)
  SET_GPREG(AX, al_s)

proc cwd*(this: var Instr16): void = 
  var ax: uint16
  ax = GET_GPREG(AX)
  SET_GPREG(DX, (if ax and (1 shl 15):
        -1
      
      else:
        0
      ))

proc callf_ptr16_16*(this: var Instr16): void = 
  EmuInstr.callf(PTR16, IMM16)

proc pushf*(this: var Instr16): void = 
  PUSH16(EMU.get_flags())

proc popf*(this: var Instr16): void = 
  EMU.set_flags(POP16())

proc mov_ax_moffs16*(this: var Instr16): void = 
  SET_GPREG(AX, get_moffs16())

proc mov_moffs16_ax*(this: var Instr16): void = 
  set_moffs16(GET_GPREG(AX))

proc cmps_m8_m8*(this: var Instr16): void = 
  var m8_d: uint8
  block repeat:
    m8_s = EMU.get_data8(select_segment(), GET_GPREG(SI))
  m8_d = EMU.get_data8(ES, GET_GPREG(DI))
  EFLAGS_UPDATE_SUB(m8_s, m8_d)
  UPDATE_GPREG(SI, (if EFLAGS_DF:
        -1
      
      else:
        1
      ))
  UPDATE_GPREG(DI, (if EFLAGS_DF:
        -1
      
      else:
        1
      ))
  if PRE_REPEAT:
    UPDATE_GPREG(CX, -1)
    case PRE_REPEAT:
      of REPZ:
        if not(GET_GPREG(CX)) or not(EFLAGS_ZF):
          break 
        
        cxx_goto repeat
      of REPNZ:
        if not(GET_GPREG(CX)) or EFLAGS_ZF:
          break 
        
        cxx_goto repeat
      else:
        discard 
  

proc cmps_m16_m16*(this: var Instr16): void = 
  var m16_d: uint16
  block repeat:
    m16_s = EMU.get_data16(select_segment(), GET_GPREG(SI))
  m16_d = EMU.get_data16(ES, GET_GPREG(DI))
  EFLAGS_UPDATE_SUB(m16_s, m16_d)
  UPDATE_GPREG(SI, (if EFLAGS_DF:
        -1
      
      else:
        1
      ))
  UPDATE_GPREG(DI, (if EFLAGS_DF:
        -1
      
      else:
        1
      ))
  if PRE_REPEAT:
    UPDATE_GPREG(CX, -1)
    case PRE_REPEAT:
      of REPZ:
        if not(GET_GPREG(CX)) or not(EFLAGS_ZF):
          break 
        
        cxx_goto repeat
      of REPNZ:
        if not(GET_GPREG(CX)) or EFLAGS_ZF:
          break 
        
        cxx_goto repeat
      else:
        discard 
  

proc test_ax_imm16*(this: var Instr16): void = 
  var ax: uint16
  ax = GET_GPREG(AX)
  EFLAGS_UPDATE_AND(ax, IMM16)

proc mov_r16_imm16*(this: var Instr16): void = 
  var reg: uint8
  reg = OPCODE and ((1 shl 3) - 1)
  SET_GPREG(static_cast[reg16_t](reg), IMM16)

proc ret*(this: var Instr16): void = 
  SET_IP(POP16())

proc mov_rm16_imm16*(this: var Instr16): void = 
  set_rm16(IMM16)

proc leave*(this: var Instr16): void = 
  var ebp: uint16
  ebp = GET_GPREG(EBP)
  SET_GPREG(ESP, ebp)
  SET_GPREG(EBP, POP16())

proc in_ax_imm8*(this: var Instr16): void = 
  SET_GPREG(AX, EMU.in_io16(IMM8))

proc out_imm8_ax*(this: var Instr16): void = 
  var ax: uint16
  ax = GET_GPREG(AX)
  EMU.out_io16(IMM8, ax)

proc call_rel16*(this: var Instr16): void = 
  PUSH16(GET_IP())
  UPDATE_IP(IMM16)

proc jmp_rel16*(this: var Instr16): void = 
  UPDATE_IP(IMM16)

proc jmpf_ptr16_16*(this: var Instr16): void = 
  EmuInstr.jmpf(PTR16, IMM16)

proc in_ax_dx*(this: var Instr16): void = 
  var dx: uint16
  dx = GET_GPREG(DX)
  SET_GPREG(AX, EMU.in_io16(dx))

proc out_dx_ax*(this: var Instr16): void = 
  var ax: uint16
  dx = GET_GPREG(DX)
  ax = GET_GPREG(AX)
  EMU.out_io16(dx, ax)

template JCC_REL16*(cc: untyped, is_flag: untyped) {.dirty.} = 
  proc `j cc`*(this: var Instr16): void = 
    if is_flag:
      UPDATE_EIP(IMM16)
    
  

JCC_REL16(o, EFLAGS_OF)
JCC_REL16(no, not(EFLAGS_OF))
JCC_REL16(b, EFLAGS_CF)
JCC_REL16(nb, not(EFLAGS_CF))
JCC_REL16(z, EFLAGS_ZF)
JCC_REL16(nz, not(EFLAGS_ZF))
JCC_REL16(be, EFLAGS_CF or EFLAGS_ZF)
JCC_REL16(a, not((EFLAGS_CF or EFLAGS_ZF)))
JCC_REL16(s, EFLAGS_SF)
JCC_REL16(ns, not(EFLAGS_SF))
JCC_REL16(p, EFLAGS_PF)
JCC_REL16(np, not(EFLAGS_PF))
JCC_REL16(l, EFLAGS_SF != EFLAGS_OF)
JCC_REL16(nl, EFLAGS_SF == EFLAGS_OF)
JCC_REL16(le, EFLAGS_ZF or (EFLAGS_SF != EFLAGS_OF))
JCC_REL16(nle, not(EFLAGS_ZF) and (EFLAGS_SF == EFLAGS_OF))
proc imul_r16_rm16*(this: var Instr16): void = 
  var rm16_s: int16
  r16_s = get_r16()
  rm16_s = get_rm16()
  set_r16(r16_s * rm16_s)
  EFLAGS_UPDATE_IMUL(r16_s, rm16_s)

proc movzx_r16_rm8*(this: var Instr16): void = 
  var rm8: uint8
  rm8 = get_rm8()
  set_r16(rm8)

proc movzx_r16_rm16*(this: var Instr16): void = 
  var rm16: uint16
  rm16 = get_rm16()
  set_r16(rm16)

proc movsx_r16_rm8*(this: var Instr16): void = 
  var rm8_s: int8
  rm8_s = get_rm8()
  set_r16(rm8_s)

proc movsx_r16_rm16*(this: var Instr16): void = 
  var rm16_s: int16
  rm16_s = get_rm16()
  set_r16(rm16_s)


proc code_81*(this: var Instr16): void = 
  case REG:
    of 0:
      add_rm16_imm16()
    of 1:
      or_rm16_imm16()
    of 2:
      adc_rm16_imm16()
    of 3:
      sbb_rm16_imm16()
    of 4:
      and_rm16_imm16()
    of 5:
      sub_rm16_imm16()
    of 6:
      xor_rm16_imm16()
    of 7:
      cmp_rm16_imm16()
    else:
      ERROR("not implemented: 0x81 /%d\\n", REG)

proc code_83*(this: var Instr16): void = 
  case REG:
    of 0:
      add_rm16_imm8()
    of 1:
      or_rm16_imm8()
    of 2:
      adc_rm16_imm8()
    of 3:
      sbb_rm16_imm8()
    of 4:
      and_rm16_imm8()
    of 5:
      sub_rm16_imm8()
    of 6:
      xor_rm16_imm8()
    of 7:
      cmp_rm16_imm8()
    else:
      ERROR("not implemented: 0x83 /%d\\n", REG)

proc code_c1*(this: var Instr16): void = 
  case REG:
    of 4:
      shl_rm16_imm8()
    of 5:
      shr_rm16_imm8()
    of 6:
      sal_rm16_imm8()
    of 7:
      sar_rm16_imm8()
    else:
      ERROR("not implemented: 0xc1 /%d\\n", REG)

proc code_d3*(this: var Instr16): void = 
  case REG:
    of 4:
      shl_rm16_cl()
    of 5:
      shr_rm16_cl()
    of 6:
      sal_rm16_cl()
    of 7:
      sar_rm16_cl()
    else:
      ERROR("not implemented: 0xd3 /%d\\n", REG)

proc code_f7*(this: var Instr16): void = 
  case REG:
    of 0:
      test_rm16_imm16()
    of 2:
      not_rm16()
    of 3:
      neg_rm16()
    of 4:
      mul_dx_ax_rm16()
    of 5:
      imul_dx_ax_rm16()
    of 6:
      div_dx_ax_rm16()
    of 7:
      idiv_dx_ax_rm16()
    else:
      ERROR("not implemented: 0xf7 /%d\\n", REG)

proc code_ff*(this: var Instr16): void = 
  case REG:
    of 0:
      inc_rm16()
    of 1:
      dec_rm16()
    of 2:
      call_rm16()
    of 3:
      callf_m16_16()
    of 4:
      jmp_rm16()
    of 5:
      jmpf_m16_16()
    of 6:
      push_rm16()
    else:
      ERROR("not implemented: 0xff /%d\\n", REG)

proc code_0f00*(this: var Instr16): void = 
  case REG:
    of 3:
      ltr_rm16()
    else:
      ERROR("not implemented: 0x0f00 /%d\\n", REG)

proc code_0f01*(this: var Instr16): void = 
  case REG:
    of 2:
      lgdt_m24()
    of 3:
      lidt_m24()
    else:
      ERROR("not implemented: 0x0f01 /%d\\n", REG)


proc add_rm16_imm16*(this: var Instr16): void = 
  var rm16: uint16
  rm16 = get_rm16()
  set_rm16(rm16 + IMM16)
  EFLAGS_UPDATE_ADD(rm16, IMM16)

proc or_rm16_imm16*(this: var Instr16): void = 
  var rm16: uint16
  rm16 = get_rm16()
  set_rm16(rm16 or IMM16)
  EFLAGS_UPDATE_OR(rm16, IMM16)

proc adc_rm16_imm16*(this: var Instr16): void = 
  var rm16: uint16
  var cf: uint8
  rm16 = get_rm16()
  cf = EFLAGS_CF
  set_rm16(rm16 + IMM16 + cf)
  EFLAGS_UPDATE_ADD(rm16, IMM16 + cf)

proc sbb_rm16_imm16*(this: var Instr16): void = 
  var rm16: uint16
  var cf: uint8
  rm16 = get_rm16()
  cf = EFLAGS_CF
  set_rm16(rm16 - IMM16 - cf)
  EFLAGS_UPDATE_SUB(rm16, IMM16 + cf)

proc and_rm16_imm16*(this: var Instr16): void = 
  var rm16: uint16
  rm16 = get_rm16()
  set_rm16(rm16 and IMM16)
  EFLAGS_UPDATE_AND(rm16, IMM16)

proc sub_rm16_imm16*(this: var Instr16): void = 
  var rm16: uint16
  rm16 = get_rm16()
  set_rm16(rm16 - IMM16)
  EFLAGS_UPDATE_SUB(rm16, IMM16)

proc xor_rm16_imm16*(this: var Instr16): void = 
  var rm16: uint16
  rm16 = get_rm16()
  set_rm16(rm16 xor IMM16)

proc cmp_rm16_imm16*(this: var Instr16): void = 
  var rm16: uint16
  rm16 = get_rm16()
  EFLAGS_UPDATE_SUB(rm16, IMM16)


proc add_rm16_imm8*(this: var Instr16): void = 
  var rm16: uint16
  rm16 = get_rm16()
  set_rm16(rm16 + IMM8)
  EFLAGS_UPDATE_ADD(rm16, IMM8)

proc or_rm16_imm8*(this: var Instr16): void = 
  var rm16: uint16
  rm16 = get_rm16()
  set_rm16(rm16 or IMM8)
  EFLAGS_UPDATE_OR(rm16, IMM8)

proc adc_rm16_imm8*(this: var Instr16): void = 
  var rm16: uint16
  var cf: uint8
  rm16 = get_rm16()
  cf = EFLAGS_CF
  set_rm16(rm16 + IMM8 + cf)
  EFLAGS_UPDATE_ADD(rm16, IMM8 + cf)

proc sbb_rm16_imm8*(this: var Instr16): void = 
  var rm16: uint16
  var cf: uint8
  rm16 = get_rm16()
  cf = EFLAGS_CF
  set_rm16(rm16 - IMM8 - cf)
  EFLAGS_UPDATE_SUB(rm16, IMM8 + cf)

proc and_rm16_imm8*(this: var Instr16): void = 
  var rm16: uint16
  rm16 = get_rm16()
  set_rm16(rm16 and IMM8)
  EFLAGS_UPDATE_AND(rm16, IMM8)

proc sub_rm16_imm8*(this: var Instr16): void = 
  var rm16: uint16
  rm16 = get_rm16()
  set_rm16(rm16 - IMM8)
  EFLAGS_UPDATE_SUB(rm16, IMM8)

proc xor_rm16_imm8*(this: var Instr16): void = 
  var rm16: uint16
  rm16 = get_rm16()
  set_rm16(rm16 xor IMM8)

proc cmp_rm16_imm8*(this: var Instr16): void = 
  var rm16: uint16
  rm16 = get_rm16()
  EFLAGS_UPDATE_SUB(rm16, IMM8)


proc shl_rm16_imm8*(this: var Instr16): void = 
  var rm16: uint16
  rm16 = get_rm16()
  set_rm16(rm16 shl IMM8)
  EFLAGS_UPDATE_SHL(rm16, IMM8)

proc shr_rm16_imm8*(this: var Instr16): void = 
  var rm16: uint16
  rm16 = get_rm16()
  set_rm16(rm16 shr IMM8)
  EFLAGS_UPDATE_SHR(rm16, IMM8)

proc sal_rm16_imm8*(this: var Instr16): void = 
  var rm16_s: int16
  rm16_s = get_rm16()
  set_rm16(rm16_s shl IMM8)
  

proc sar_rm16_imm8*(this: var Instr16): void = 
  var rm16_s: int16
  rm16_s = get_rm16()
  set_rm16(rm16_s shr IMM8)
  


proc shl_rm16_cl*(this: var Instr16): void = 
  var rm16: uint16
  var cl: uint8
  rm16 = get_rm16()
  cl = GET_GPREG(CL)
  set_rm16(rm16 shl cl)
  EFLAGS_UPDATE_SHL(rm16, cl)

proc shr_rm16_cl*(this: var Instr16): void = 
  var rm16: uint16
  var cl: uint8
  rm16 = get_rm16()
  cl = GET_GPREG(CL)
  set_rm16(rm16 shr cl)
  EFLAGS_UPDATE_SHR(rm16, cl)

proc sal_rm16_cl*(this: var Instr16): void = 
  var rm16_s: int16
  var cl: uint8
  rm16_s = get_rm16()
  cl = GET_GPREG(CL)
  set_rm16(rm16_s shl cl)
  

proc sar_rm16_cl*(this: var Instr16): void = 
  var rm16_s: int16
  var cl: uint8
  rm16_s = get_rm16()
  cl = GET_GPREG(CL)
  set_rm16(rm16_s shr cl)
  


proc test_rm16_imm16*(this: var Instr16): void = 
  var imm16: uint16
  rm16 = get_rm16()
  imm16 = EMU.get_code16(0)
  UPDATE_EIP(2)
  EFLAGS_UPDATE_AND(rm16, imm16)

proc not_rm16*(this: var Instr16): void = 
  var rm16: uint16
  rm16 = get_rm16()
  set_rm16(not(rm16))

proc neg_rm16*(this: var Instr16): void = 
  var rm16_s: int16
  rm16_s = get_rm16()
  set_rm16(-(rm16_s))
  EFLAGS_UPDATE_SUB(cast[uint16](0(, rm16_s)

proc mul_dx_ax_rm16*(this: var Instr16): void = 
  var ax: uint16
  var val: uint32
  rm16 = get_rm16()
  ax = GET_GPREG(AX)
  val = ax * rm16
  SET_GPREG(AX, val and ((1 shl 16) - 1))
  SET_GPREG(DX, (val shr 16) and ((1 shl 16) - 1))
  EFLAGS_UPDATE_MUL(ax, rm16)

proc imul_dx_ax_rm16*(this: var Instr16): void = 
  var ax_s: int16
  var val_s: int32
  rm16_s = get_rm16()
  ax_s = GET_GPREG(AX)
  val_s = ax_s * rm16_s
  SET_GPREG(AX, val_s and ((1 shl 16) - 1))
  SET_GPREG(DX, (val_s shr 16) and ((1 shl 16) - 1))
  EFLAGS_UPDATE_IMUL(ax_s, rm16_s)

proc div_dx_ax_rm16*(this: var Instr16): void = 
  var rm16: uint16
  var val: uint32
  rm16 = get_rm16()
  EXCEPTION(EXP_DE, not(rm16))
  val = (GET_GPREG(DX) shl 16) or GET_GPREG(AX)
  SET_GPREG(AX, val / rm16)
  SET_GPREG(DX, val mod rm16)

proc idiv_dx_ax_rm16*(this: var Instr16): void = 
  var rm16_s: int16
  var val_s: int32
  rm16_s = get_rm16()
  EXCEPTION(EXP_DE, not(rm16_s))
  val_s = (GET_GPREG(DX) shl 16) or GET_GPREG(AX)
  SET_GPREG(AX, val_s / rm16_s)
  SET_GPREG(DX, val_s mod rm16_s)


proc inc_rm16*(this: var Instr16): void = 
  var rm16: uint16
  rm16 = get_rm16()
  set_rm16(rm16 + 1)
  EFLAGS_UPDATE_ADD(rm16, 1)

proc dec_rm16*(this: var Instr16): void = 
  var rm16: uint16
  rm16 = get_rm16()
  set_rm16(rm16 - 1)
  EFLAGS_UPDATE_SUB(rm16, 1)

proc call_rm16*(this: var Instr16): void = 
  var rm16: uint16
  rm16 = get_rm16()
  PUSH16(GET_IP())
  SET_IP(rm16)

proc callf_m16_16*(this: var Instr16): void = 
  var ip: uint16
  m32 = get_m()
  ip = READ_MEM16(m32)
  cs = READ_MEM16(m32 + 2)
  EmuInstr.callf(cs, ip)

proc jmp_rm16*(this: var Instr16): void = 
  var rm16: uint16
  rm16 = get_rm16()
  SET_IP(rm16)

proc jmpf_m16_16*(this: var Instr16): void = 
  var ip: uint16
  m32 = get_m()
  ip = READ_MEM16(m32)
  sel = READ_MEM16(m32 + 2)
  EmuInstr.jmpf(sel, ip)

proc push_rm16*(this: var Instr16): void = 
  var rm16: uint16
  rm16 = get_rm16()
  PUSH16(rm16)


proc lgdt_m24*(this: var Instr16): void = 
  var limit: uint16
  EXCEPTION(EXP_GP, not(chk_ring(0)))
  m48 = get_m()
  limit = READ_MEM16(m48)
  base = READ_MEM32(m48 + 2) and ((1 shl 24) - 1)
  set_gdtr(base, limit)

proc lidt_m24*(this: var Instr16): void = 
  var limit: uint16
  EXCEPTION(EXP_GP, not(chk_ring(0)))
  m48 = get_m()
  limit = READ_MEM16(m48)
  base = READ_MEM32(m48 + 2) and ((1 shl 24) - 1)
  set_idtr(base, limit)
