import common
import instruction

template instr*(b: InstrImpl): untyped = b.exec.instr

proc set_chsz_ad*(this: var InstrImpl, ad: bool): void =
  this.exec.chsz_ad = ad

