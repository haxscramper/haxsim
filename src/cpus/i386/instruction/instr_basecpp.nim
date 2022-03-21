import instruction/[basehpp, instructionhpp]
import commonhpp, execcpp
import emulator/exceptionhpp

template instrbase*(f: untyped): untyped {.dirty.} = 
  ((instrfunc_t) and InstrBase.f)

proc set_funcflag*(this: var InstrBase, opcode: uint16, `func`: instrfunc_t, flags: uint8): void =
  var opcode = opcode
  if opcode shr 8 == 0x0f:
    opcode = (opcode and 0xff) or 0x0100

  ASSERT(opcode < MAX_OPCODE)
  this.exec.instrfuncs[opcode] = `func`
  this.parse.chk[opcode].flags = flags
  


proc add_rm8_r8*(this: var InstrBase): void = 
  var r8, rm8: uint8
  rm8 = get_rm8()
  r8 = get_r8()
  set_rm8(rm8 + r8)
  EFLAGS_UPDATE_ADD(rm8, r8)

proc add_r8_rm8*(this: var InstrBase): void = 
  var rm8: uint8
  r8 = get_r8()
  rm8 = get_rm8()
  set_r8(r8 + rm8)
  EFLAGS_UPDATE_ADD(r8, rm8)

proc add_al_imm8*(this: var InstrBase): void = 
  var al: uint8
  al = GET_GPREG(AL)
  SET_GPREG(AL, al + IMM8)
  EFLAGS_UPDATE_ADD(al, IMM8)

proc or_rm8_r8*(this: var InstrBase): void = 
  var r8: uint8
  rm8 = get_rm8()
  r8 = get_r8()
  set_rm8(rm8 or r8)
  EFLAGS_UPDATE_OR(rm8, r8)

proc or_al_imm8*(this: var InstrBase): void = 
  var al: uint8
  al = GET_GPREG(AL)
  SET_GPREG(AL, al or IMM8)
  EFLAGS_UPDATE_OR(al, IMM8)

proc or_r8_rm8*(this: var InstrBase): void = 
  var rm8: uint8
  r8 = get_r8()
  rm8 = get_rm8()
  set_r8(r8 or rm8)
  EFLAGS_UPDATE_OR(r8, rm8)

proc and_rm8_r8*(this: var InstrBase): void = 
  var r8: uint8
  rm8 = get_rm8()
  r8 = get_r8()
  set_rm8(rm8 and r8)
  EFLAGS_UPDATE_AND(rm8, r8)

proc and_r8_rm8*(this: var InstrBase): void = 
  var rm8: uint8
  r8 = get_r8()
  rm8 = get_rm8()
  set_r8(r8 and rm8)
  EFLAGS_UPDATE_AND(r8, rm8)

proc and_al_imm8*(this: var InstrBase): void = 
  var al: uint8
  al = GET_GPREG(AL)
  SET_GPREG(AL, al and IMM8)
  EFLAGS_UPDATE_AND(al, IMM8)

proc sub_rm8_r8*(this: var InstrBase): void = 
  var r8: uint8
  rm8 = get_rm8()
  r8 = get_r8()
  set_rm8(rm8 - r8)
  EFLAGS_UPDATE_SUB(rm8, r8)

proc sub_r8_rm8*(this: var InstrBase): void = 
  var rm8: uint8
  r8 = get_r8()
  rm8 = get_rm8()
  set_r8(r8 - rm8)
  EFLAGS_UPDATE_SUB(r8, rm8)

proc sub_al_imm8*(this: var InstrBase): void = 
  var al: uint8
  al = GET_GPREG(AL)
  SET_GPREG(AL, al - IMM8)
  EFLAGS_UPDATE_SUB(al, IMM8)

proc xor_rm8_r8*(this: var InstrBase): void = 
  var r8: uint8
  rm8 = get_rm8()
  r8 = get_r8()
  set_rm8(rm8 xor r8)

proc xor_r8_rm8*(this: var InstrBase): void = 
  var rm8: uint8
  r8 = get_r8()
  rm8 = get_rm8()
  set_r8(r8 xor rm8)

proc xor_al_imm8*(this: var InstrBase): void = 
  var al: uint8
  al = GET_GPREG(AL)
  SET_GPREG(AL, al xor IMM8)

proc cmp_rm8_r8*(this: var InstrBase): void = 
  var r8: uint8
  rm8 = get_rm8()
  r8 = get_r8()
  EFLAGS_UPDATE_SUB(rm8, r8)

proc cmp_r8_rm8*(this: var InstrBase): void = 
  var rm8: uint8
  r8 = get_r8()
  rm8 = get_rm8()
  EFLAGS_UPDATE_SUB(r8, rm8)

proc cmp_al_imm8*(this: var InstrBase): void = 
  var al: uint8
  al = GET_GPREG(AL)
  EFLAGS_UPDATE_SUB(al, IMM8)

template JCC_REL8*(cc: untyped, is_flag: untyped): untyped {.dirty.} = 
  proc `j cc`*(this: var InstrBase): void = 
    if is_flag:
      UPDATE_IP(IMM8)
    
  

JCC_REL8(o, EFLAGS_OF)
JCC_REL8(no, not(EFLAGS_OF))
JCC_REL8(b, EFLAGS_CF)
JCC_REL8(nb, not(EFLAGS_CF))
JCC_REL8(z, EFLAGS_ZF)
JCC_REL8(nz, not(EFLAGS_ZF))
JCC_REL8(be, EFLAGS_CF or EFLAGS_ZF)
JCC_REL8(a, not((EFLAGS_CF or EFLAGS_ZF)))
JCC_REL8(s, EFLAGS_SF)
JCC_REL8(ns, not(EFLAGS_SF))
JCC_REL8(p, EFLAGS_PF)
JCC_REL8(np, not(EFLAGS_PF))
JCC_REL8(l, EFLAGS_SF != EFLAGS_OF)
JCC_REL8(nl, EFLAGS_SF == EFLAGS_OF)
JCC_REL8(le, EFLAGS_ZF or (EFLAGS_SF != EFLAGS_OF))
JCC_REL8(nle, not(EFLAGS_ZF) and (EFLAGS_SF == EFLAGS_OF))
proc test_rm8_r8*(this: var InstrBase): void = 
  var r8: uint8
  rm8 = get_rm8()
  r8 = get_r8()
  EFLAGS_UPDATE_AND(rm8, r8)

proc xchg_r8_rm8*(this: var InstrBase): void = 
  var rm8: uint8
  r8 = get_r8()
  rm8 = get_rm8()
  set_r8(rm8)
  set_rm8(r8)

proc mov_rm8_r8*(this: var InstrBase): void = 
  var r8: uint8
  r8 = get_r8()
  set_rm8(r8)

proc mov_r8_rm8*(this: var InstrBase): void = 
  var rm8: uint8
  rm8 = get_rm8()
  set_r8(rm8)

proc mov_sreg_rm16*(this: var InstrBase): void = 
  var rm16: uint16
  rm16 = get_rm16()
  set_sreg(rm16)

proc nop*(this: var InstrBase): void = 
  discard 


proc mov_al_moffs8*(this: var InstrBase): void = 
  SET_GPREG(AL, get_moffs8())

proc mov_moffs8_al*(this: var InstrBase): void = 
  set_moffs8(GET_GPREG(AL))

proc test_al_imm8*(this: var InstrBase): void = 
  var al: uint8
  al = GET_GPREG(AL)
  EFLAGS_UPDATE_AND(al, IMM8)

proc mov_r8_imm8*(this: var InstrBase): void = 
  var reg: uint8
  reg = OPCODE and ((1 shl 3) - 1)
  SET_GPREG(static_cast[reg8_t](reg), IMM8)

proc mov_rm8_imm8*(this: var InstrBase): void = 
  set_rm8(IMM8)

proc retf*(this: var InstrBase): void = 
  EmuInstr.retf()

proc int3*(this: var InstrBase): void = 
  EMU.dump_regs()
  EMU.dump_mem((EMU.get_segment(SS) shl 4) + EMU.get_gpreg(ESP) - 0x40, 0x80)

proc int_imm8*(this: var InstrBase): void = 
  EMU.queue_interrupt(IMM8, false)

proc iret*(this: var InstrBase): void = 
  EmuInstr.iret()

proc in_al_imm8*(this: var InstrBase): void = 
  SET_GPREG(AL, EMU.in_io8(cast[uint8](IMM8)))

proc out_imm8_al*(this: var InstrBase): void = 
  var al: uint8
  al = GET_GPREG(AL)
  EMU.out_io8(cast[uint8](IMM8), al)

proc jmp*(this: var InstrBase): void = 
  UPDATE_IP(IMM8)

proc in_al_dx*(this: var InstrBase): void = 
  var dx: uint16
  dx = GET_GPREG(DX)
  SET_GPREG(AL, EMU.in_io8(dx))

proc out_dx_al*(this: var InstrBase): void = 
  var dx: uint16
  var al: uint8
  dx = GET_GPREG(DX)
  al = GET_GPREG(AL)
  EMU.out_io8(dx, al)

proc cli*(this: var InstrBase): void = 
  EMU.set_interrupt(false)

proc sti*(this: var InstrBase): void = 
  EMU.set_interrupt(true)

proc cld*(this: var InstrBase): void = 
  EMU.set_direction(false)

proc std*(this: var InstrBase): void = 
  EMU.set_direction(true)

proc hlt*(this: var InstrBase): void = 
  EXCEPTION(EXP_GP, not(chk_ring(0)))
  EMU.do_halt(true)
  

proc ltr_rm16*(this: var InstrBase): void = 
  var rm16: uint16
  EXCEPTION(EXP_GP, not(chk_ring(0)))
  rm16 = get_rm16()
  set_tr(rm16)

proc mov_r32_crn*(this: var InstrBase): void = 
  var crn: uint32
  crn = get_crn()
  SET_GPREG(static_cast[reg32_t](RM), crn)
  

proc mov_crn_r32*(this: var InstrBase): void = 
  var r32: uint32
  EXCEPTION(EXP_GP, not(chk_ring(0)))
  r32 = GET_GPREG(static_cast[reg32_t](RM))
  
  set_crn(r32)

template SETCC_RM8*(cc: untyped, is_flag: untyped): untyped {.dirty.} = 
  proc `set cc`*(this: var InstrBase): void = 
    SET_GPREG(static_cast[reg32_t](RM), is_flag)
  

SETCC_RM8(o, EFLAGS_OF)
SETCC_RM8(no, not(EFLAGS_OF))
SETCC_RM8(b, EFLAGS_CF)
SETCC_RM8(nb, not(EFLAGS_CF))
SETCC_RM8(z, EFLAGS_ZF)
SETCC_RM8(nz, not(EFLAGS_ZF))
SETCC_RM8(be, EFLAGS_CF or EFLAGS_ZF)
SETCC_RM8(a, not((EFLAGS_CF or EFLAGS_ZF)))
SETCC_RM8(s, EFLAGS_SF)
SETCC_RM8(ns, not(EFLAGS_SF))
SETCC_RM8(p, EFLAGS_PF)
SETCC_RM8(np, not(EFLAGS_PF))
SETCC_RM8(l, EFLAGS_SF != EFLAGS_OF)
SETCC_RM8(nl, EFLAGS_SF == EFLAGS_OF)
SETCC_RM8(le, EFLAGS_ZF or (EFLAGS_SF != EFLAGS_OF))
SETCC_RM8(nle, not(EFLAGS_ZF) and (EFLAGS_SF == EFLAGS_OF))

proc code_80*(this: var InstrBase): void = 
  case REG:
    of 0:
      add_rm8_imm8()
    of 1:
      or_rm8_imm8()
    of 2:
      adc_rm8_imm8()
    of 3:
      sbb_rm8_imm8()
    of 4:
      and_rm8_imm8()
    of 5:
      sub_rm8_imm8()
    of 6:
      xor_rm8_imm8()
    of 7:
      cmp_rm8_imm8()
    else:
      ERROR("not implemented: 0x80 /%d\\n", REG)

proc code_82*(this: var InstrBase): void = 
  code_80()

proc code_c0*(this: var InstrBase): void = 
  case REG:
    of 4:
      shl_rm8_imm8()
    of 5:
      shr_rm8_imm8()
    of 6:
      sal_rm8_imm8()
    of 7:
      sar_rm8_imm8()
    else:
      ERROR("not implemented: 0xc0 /%d\\n", REG)

proc code_f6*(this: var InstrBase): void = 
  case REG:
    of 0:
      test_rm8_imm8()
    of 2:
      not_rm8()
    of 3:
      neg_rm8()
    of 4:
      mul_ax_al_rm8()
    of 5:
      imul_ax_al_rm8()
    of 6:
      div_al_ah_rm8()
    of 7:
      idiv_al_ah_rm8()
    else:
      ERROR("not implemented: 0xf6 /%d\\n", REG)


proc add_rm8_imm8*(this: var InstrBase): void = 
  var rm8: uint8
  rm8 = get_rm8()
  set_rm8(rm8 + IMM8)
  EFLAGS_UPDATE_ADD(rm8, IMM8)

proc or_rm8_imm8*(this: var InstrBase): void = 
  var rm8: uint8
  rm8 = get_rm8()
  set_rm8(rm8 or IMM8)
  EFLAGS_UPDATE_OR(rm8, IMM8)

proc adc_rm8_imm8*(this: var InstrBase): void = 
  var cf: uint8
  rm8 = get_rm8()
  cf = EFLAGS_CF
  set_rm8(rm8 + IMM8 + cf)
  EFLAGS_UPDATE_ADD(rm8, IMM8 + cf)

proc sbb_rm8_imm8*(this: var InstrBase): void = 
  var cf: uint8
  rm8 = get_rm8()
  cf = EFLAGS_CF
  set_rm8(rm8 - IMM8 - cf)
  EFLAGS_UPDATE_SUB(rm8, IMM8 + cf)

proc and_rm8_imm8*(this: var InstrBase): void = 
  var rm8: uint8
  rm8 = get_rm8()
  set_rm8(rm8 and IMM8)
  EFLAGS_UPDATE_AND(rm8, IMM8)

proc sub_rm8_imm8*(this: var InstrBase): void = 
  var rm8: uint8
  rm8 = get_rm8()
  set_rm8(rm8 - IMM8)
  EFLAGS_UPDATE_SUB(rm8, IMM8)

proc xor_rm8_imm8*(this: var InstrBase): void = 
  var rm8: uint8
  rm8 = get_rm8()
  set_rm8(rm8 xor IMM8)

proc cmp_rm8_imm8*(this: var InstrBase): void = 
  var rm8: uint8
  rm8 = get_rm8()
  EFLAGS_UPDATE_SUB(rm8, IMM8)


proc shl_rm8_imm8*(this: var InstrBase): void = 
  var rm8: uint8
  rm8 = get_rm8()
  set_rm8(rm8 shl IMM8)
  EFLAGS_UPDATE_SHL(rm8, IMM8)

proc shr_rm8_imm8*(this: var InstrBase): void = 
  var rm8: uint8
  rm8 = get_rm8()
  set_rm8(rm8 shr IMM8)
  EFLAGS_UPDATE_SHR(rm8, IMM8)

proc sal_rm8_imm8*(this: var InstrBase): void = 
  var rm8_s: int8
  rm8_s = get_rm8()
  set_rm8(rm8_s shl IMM8)
  

proc sar_rm8_imm8*(this: var InstrBase): void = 
  var rm8_s: int8
  rm8_s = get_rm8()
  set_rm8(rm8_s shr IMM8)
  


proc test_rm8_imm8*(this: var InstrBase): void = 
  var imm8: uint8
  rm8 = get_rm8()
  imm8 = EMU.get_code8(0)
  UPDATE_EIP(1)
  EFLAGS_UPDATE_AND(rm8, imm8)

proc not_rm8*(this: var InstrBase): void = 
  var rm8: uint8
  rm8 = get_rm8()
  set_rm8(not(rm8))

proc neg_rm8*(this: var InstrBase): void = 
  var rm8_s: int8
  rm8_s = get_rm8()
  set_rm8(-(rm8_s))
  EFLAGS_UPDATE_SUB(cast[uint8](0), rm8_s)

proc mul_ax_al_rm8*(this: var InstrBase): void = 
  var al: uint8
  var val: uint16
  rm8 = get_rm8()
  al = GET_GPREG(AL)
  val = al * rm8
  SET_GPREG(AX, val)
  EFLAGS_UPDATE_MUL(al, rm8)

proc imul_ax_al_rm8*(this: var InstrBase): void = 
  var al_s: int8
  var val_s: int16
  rm8_s = get_rm8()
  al_s = GET_GPREG(AL)
  val_s = al_s * rm8_s
  SET_GPREG(AX, val_s)
  EFLAGS_UPDATE_IMUL(al_s, rm8_s)

proc div_al_ah_rm8*(this: var InstrBase): void = 
  var rm8: uint8
  var ax: uint16
  rm8 = get_rm8()
  ax = GET_GPREG(AX)
  SET_GPREG(AL, ax / rm8)
  SET_GPREG(AH, ax mod rm8)

proc idiv_al_ah_rm8*(this: var InstrBase): void = 
  var rm8_s: int8
  var ax_s: int16
  rm8_s = get_rm8()
  ax_s = GET_GPREG(AX)
  SET_GPREG(AL, ax_s / rm8_s)
  SET_GPREG(AH, ax_s mod rm8_s)

 proc initInstrBase*(): InstrBase =
  var i: cint
  set_funcflag(0x00, instrbase(add_rm8_r8), CHK_MODRM)
  set_funcflag(0x02, instrbase(add_r8_rm8), CHK_MODRM)
  set_funcflag(0x04, instrbase(add_al_imm8), CHK_IMM8)
  set_funcflag(0x08, instrbase(or_rm8_r8), CHK_MODRM)
  set_funcflag(0x0a, instrbase(or_r8_rm8), CHK_MODRM)
  set_funcflag(0x0c, instrbase(or_al_imm8), CHK_IMM8)
  set_funcflag(0x20, instrbase(and_rm8_r8), CHK_MODRM)
  set_funcflag(0x22, instrbase(and_r8_rm8), CHK_MODRM)
  set_funcflag(0x24, instrbase(and_al_imm8), CHK_IMM8)
  set_funcflag(0x28, instrbase(sub_rm8_r8), CHK_MODRM)
  set_funcflag(0x2a, instrbase(sub_r8_rm8), CHK_MODRM)
  set_funcflag(0x2c, instrbase(sub_al_imm8), CHK_IMM8)
  set_funcflag(0x30, instrbase(xor_rm8_r8), CHK_MODRM)
  set_funcflag(0x32, instrbase(xor_r8_rm8), CHK_MODRM)
  set_funcflag(0x34, instrbase(xor_al_imm8), CHK_IMM8)
  set_funcflag(0x38, instrbase(cmp_rm8_r8), CHK_MODRM)
  set_funcflag(0x3a, instrbase(cmp_r8_rm8), CHK_MODRM)
  set_funcflag(0x3c, instrbase(cmp_al_imm8), CHK_IMM8)
  set_funcflag(0x70, instrbase(jo_rel8), CHK_IMM8)
  set_funcflag(0x71, instrbase(jno_rel8), CHK_IMM8)
  set_funcflag(0x72, instrbase(jb_rel8), CHK_IMM8)
  set_funcflag(0x73, instrbase(jnb_rel8), CHK_IMM8)
  set_funcflag(0x74, instrbase(jz_rel8), CHK_IMM8)
  set_funcflag(0x75, instrbase(jnz_rel8), CHK_IMM8)
  set_funcflag(0x76, instrbase(jbe_rel8), CHK_IMM8)
  set_funcflag(0x77, instrbase(ja_rel8), CHK_IMM8)
  set_funcflag(0x78, instrbase(js_rel8), CHK_IMM8)
  set_funcflag(0x79, instrbase(jns_rel8), CHK_IMM8)
  set_funcflag(0x7a, instrbase(jp_rel8), CHK_IMM8)
  set_funcflag(0x7b, instrbase(jnp_rel8), CHK_IMM8)
  set_funcflag(0x7c, instrbase(jl_rel8), CHK_IMM8)
  set_funcflag(0x7d, instrbase(jnl_rel8), CHK_IMM8)
  set_funcflag(0x7e, instrbase(jle_rel8), CHK_IMM8)
  set_funcflag(0x7f, instrbase(jnle_rel8), CHK_IMM8)
  set_funcflag(0x84, instrbase(test_rm8_r8), CHK_MODRM)
  set_funcflag(0x86, instrbase(xchg_r8_rm8), CHK_MODRM)
  set_funcflag(0x88, instrbase(mov_rm8_r8), CHK_MODRM)
  set_funcflag(0x8a, instrbase(mov_r8_rm8), CHK_MODRM)
  set_funcflag(0x8e, instrbase(mov_sreg_rm16), CHK_MODRM)
  set_funcflag(0x90, instrbase(nop), 0)
  set_funcflag(0xa0, instrbase(mov_al_moffs8), CHK_MOFFS)
  set_funcflag(0xa2, instrbase(mov_moffs8_al), CHK_MOFFS)
  set_funcflag(0xa8, instrbase(test_al_imm8), CHK_IMM8)
  block:
    i = 0
    while i < 8:
      set_funcflag(0xb0 + i, instrbase(mov_r8_imm8), CHK_IMM8)
      postInc(i)
  set_funcflag(0xc6, instrbase(mov_rm8_imm8), CHK_MODRM or CHK_IMM8)
  set_funcflag(0xcb, instrbase(retf), 0)
  set_funcflag(0xcc, instrbase(int3), 0)
  set_funcflag(0xcd, instrbase(int_imm8), CHK_IMM8)
  set_funcflag(0xcf, instrbase(iret), 0)
  set_funcflag(0xe4, instrbase(in_al_imm8), CHK_IMM8)
  set_funcflag(0xe6, instrbase(out_imm8_al), CHK_IMM8)
  set_funcflag(0xeb, instrbase(jmp), CHK_IMM8)
  set_funcflag(0xec, instrbase(in_al_dx), 0)
  set_funcflag(0xee, instrbase(out_dx_al), 0)
  set_funcflag(0xfa, instrbase(cli), 0)
  set_funcflag(0xfb, instrbase(sti), 0)
  set_funcflag(0xfc, instrbase(cld), 0)
  set_funcflag(0xfd, instrbase(std), 0)
  set_funcflag(0xf4, instrbase(hlt), 0)
  set_funcflag(0x0f20, instrbase(mov_r32_crn), CHK_MODRM)
  set_funcflag(0x0f22, instrbase(mov_crn_r32), CHK_MODRM)
  set_funcflag(0x0f90, instrbase(seto_rm8), CHK_MODRM)
  set_funcflag(0x0f91, instrbase(setno_rm8), CHK_MODRM)
  set_funcflag(0x0f92, instrbase(setb_rm8), CHK_MODRM)
  set_funcflag(0x0f93, instrbase(setnb_rm8), CHK_MODRM)
  set_funcflag(0x0f94, instrbase(setz_rm8), CHK_MODRM)
  set_funcflag(0x0f95, instrbase(setnz_rm8), CHK_MODRM)
  set_funcflag(0x0f96, instrbase(setbe_rm8), CHK_MODRM)
  set_funcflag(0x0f97, instrbase(seta_rm8), CHK_MODRM)
  set_funcflag(0x0f98, instrbase(sets_rm8), CHK_MODRM)
  set_funcflag(0x0f99, instrbase(setns_rm8), CHK_MODRM)
  set_funcflag(0x0f9a, instrbase(setp_rm8), CHK_MODRM)
  set_funcflag(0x0f9b, instrbase(setnp_rm8), CHK_MODRM)
  set_funcflag(0x0f9c, instrbase(setl_rm8), CHK_MODRM)
  set_funcflag(0x0f9d, instrbase(setnl_rm8), CHK_MODRM)
  set_funcflag(0x0f9e, instrbase(setle_rm8), CHK_MODRM)
  set_funcflag(0x0f9f, instrbase(setnle_rm8), CHK_MODRM)
  set_funcflag(0x80, instrbase(code_80), CHK_MODRM or CHK_IMM8)
  set_funcflag(0x82, instrbase(code_82), CHK_MODRM or CHK_IMM8)
  set_funcflag(0xc0, instrbase(code_c0), CHK_MODRM or CHK_IMM8)
  set_funcflag(0xf6, instrbase(code_f6), CHK_MODRM)
