import commonhpp
import instructionhpp


template instr*(b: InstrBase): untyped = b.exec.instr

# proc code_0f01*(this: var InstrBase): void =
#   discard

proc set_chsz_ad*(this: var InstrBase, ad: bool): void =
  this.exec.chsz_ad = ad

# proc code_0f00*(this: var InstrBase): void =
#   discard

# proc code_ff*(this: var InstrBase): void =
#   discard

# proc code_f7*(this: var InstrBase): void =
#   discard

# proc code_83*(this: var InstrBase): void =
#   discard

# proc code_81*(this: var InstrBase): void =
#   discard

# proc setnle_rm8*(this: var InstrBase): void =
#   discard

# proc setle_rm8*(this: var InstrBase): void =
#   discard

# proc setnl_rm8*(this: var InstrBase): void =
#   discard

# proc setl_rm8*(this: var InstrBase): void =
#   discard

# proc setnp_rm8*(this: var InstrBase): void =
#   discard

# proc setp_rm8*(this: var InstrBase): void =
#   discard

# proc setns_rm8*(this: var InstrBase): void =
#   discard

# proc sets_rm8*(this: var InstrBase): void =
#   discard

# proc seta_rm8*(this: var InstrBase): void =
#   discard

# proc setbe_rm8*(this: var InstrBase): void =
#   discard

# proc setnz_rm8*(this: var InstrBase): void =
#   discard

# proc setz_rm8*(this: var InstrBase): void =
#   discard

# proc setnb_rm8*(this: var InstrBase): void =
#   discard

# proc setb_rm8*(this: var InstrBase): void =
#   discard

# proc jo_rel8*(this: var InstrBase): void =
#   discard

# proc jno_rel8*(this: var InstrBase): void =
#   discard

# proc jb_rel8*(this: var InstrBase): void =
#   discard

# proc jnb_rel8*(this: var InstrBase): void =
#   discard

# proc jz_rel8*(this: var InstrBase): void =
#   discard

# proc jnz_rel8*(this: var InstrBase): void =
#   discard

# proc jbe_rel8*(this: var InstrBase): void =
#   discard

# proc ja_rel8*(this: var InstrBase): void =
#   discard

# proc js_rel8*(this: var InstrBase): void =
#   discard

# proc jns_rel8*(this: var InstrBase): void =
#   discard

# proc jp_rel8*(this: var InstrBase): void =
#   discard

# proc jnp_rel8*(this: var InstrBase): void =
#   discard

# proc jl_rel8*(this: var InstrBase): void =
#   discard

# proc jnl_rel8*(this: var InstrBase): void =
#   discard

# proc jle_rel8*(this: var InstrBase): void =
#   discard

# proc jnle_rel8*(this: var InstrBase): void =
#   discard

# proc setno_rm8*(this: var InstrBase): void =
#   discard

# proc seto_rm8*(this: var InstrBase): void =
#   discard

type
  Instr16* {.bycopy.} = object of InstrBase
  Instr32* {.bycopy.} = object of InstrBase
   
  
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
