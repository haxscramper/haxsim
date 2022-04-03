import commonhpp
import instructionhpp


template instr*(b: InstrImpl): untyped = b.exec.instr

# proc code_0f01*(this: var InstrImpl): void =
#   discard

proc set_chsz_ad*(this: var InstrImpl, ad: bool): void =
  this.exec.chsz_ad = ad

# proc code_0f00*(this: var InstrImpl): void =
#   discard

# proc code_ff*(this: var InstrImpl): void =
#   discard

# proc code_f7*(this: var InstrImpl): void =
#   discard

# proc code_83*(this: var InstrImpl): void =
#   discard

# proc code_81*(this: var InstrImpl): void =
#   discard

# proc setnle_rm8*(this: var InstrImpl): void =
#   discard

# proc setle_rm8*(this: var InstrImpl): void =
#   discard

# proc setnl_rm8*(this: var InstrImpl): void =
#   discard

# proc setl_rm8*(this: var InstrImpl): void =
#   discard

# proc setnp_rm8*(this: var InstrImpl): void =
#   discard

# proc setp_rm8*(this: var InstrImpl): void =
#   discard

# proc setns_rm8*(this: var InstrImpl): void =
#   discard

# proc sets_rm8*(this: var InstrImpl): void =
#   discard

# proc seta_rm8*(this: var InstrImpl): void =
#   discard

# proc setbe_rm8*(this: var InstrImpl): void =
#   discard

# proc setnz_rm8*(this: var InstrImpl): void =
#   discard

# proc setz_rm8*(this: var InstrImpl): void =
#   discard

# proc setnb_rm8*(this: var InstrImpl): void =
#   discard

# proc setb_rm8*(this: var InstrImpl): void =
#   discard

# proc jo_rel8*(this: var InstrImpl): void =
#   discard

# proc jno_rel8*(this: var InstrImpl): void =
#   discard

# proc jb_rel8*(this: var InstrImpl): void =
#   discard

# proc jnb_rel8*(this: var InstrImpl): void =
#   discard

# proc jz_rel8*(this: var InstrImpl): void =
#   discard

# proc jnz_rel8*(this: var InstrImpl): void =
#   discard

# proc jbe_rel8*(this: var InstrImpl): void =
#   discard

# proc ja_rel8*(this: var InstrImpl): void =
#   discard

# proc js_rel8*(this: var InstrImpl): void =
#   discard

# proc jns_rel8*(this: var InstrImpl): void =
#   discard

# proc jp_rel8*(this: var InstrImpl): void =
#   discard

# proc jnp_rel8*(this: var InstrImpl): void =
#   discard

# proc jl_rel8*(this: var InstrImpl): void =
#   discard

# proc jnl_rel8*(this: var InstrImpl): void =
#   discard

# proc jle_rel8*(this: var InstrImpl): void =
#   discard

# proc jnle_rel8*(this: var InstrImpl): void =
#   discard

# proc setno_rm8*(this: var InstrImpl): void =
#   discard

# proc seto_rm8*(this: var InstrImpl): void =
#   discard

# proc jnle_rel16*(this: var Instr16): void =
#   discard

# proc jle_rel16*(this: var Instr16): void =
#   discard

# proc jnl_rel16*(this: var Instr16): void =
#   discard

# proc jl_rel16*(this: var Instr16): void =
#   discard

# proc jnp_rel16*(this: var Instr16): void =
#   discard

# proc jp_rel16*(this: var Instr16): void =
#   discard

# proc jns_rel16*(this: var Instr16): void =
#   discard

# proc js_rel16*(this: var Instr16): void =
#   discard

# proc ja_rel16*(this: var Instr16): void =
#   discard

# proc jbe_rel16*(this: var Instr16): void =
#   discard

# proc jnz_rel16*(this: var Instr16): void =
#   discard

# proc jz_rel16*(this: var Instr16): void =
#   discard

# proc jnb_rel16*(this: var Instr16): void =
#   discard

# proc jb_rel16*(this: var Instr16): void =
#   discard

# proc jno_rel16*(this: var Instr16): void =
#   discard

# proc jo_rel16*(this: var Instr16): void =
#   discard



# proc jnle_rel32*(this: var Instr32): void =
#   discard

# proc jle_rel32*(this: var Instr32): void =
#   discard

# proc jnl_rel32*(this: var Instr32): void =
#   discard

# proc jl_rel32*(this: var Instr32): void =
#   discard

# proc jnp_rel32*(this: var Instr32): void =
#   discard

# proc jp_rel32*(this: var Instr32): void =
#   discard

# proc jns_rel32*(this: var Instr32): void =
#   discard

# proc js_rel32*(this: var Instr32): void =
#   discard

# proc ja_rel32*(this: var Instr32): void =
#   discard

# proc jbe_rel32*(this: var Instr32): void =
#   discard

# proc jnz_rel32*(this: var Instr32): void =
#   discard

# proc jz_rel32*(this: var Instr32): void =
#   discard

# proc jnb_rel32*(this: var Instr32): void =
#   discard

# proc jb_rel32*(this: var Instr32): void =
#   discard

# proc jno_rel32*(this: var Instr32): void =
#   discard

# proc jo_rel32*(this: var Instr32): void =
#   discard
