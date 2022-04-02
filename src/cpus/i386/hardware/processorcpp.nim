import hardware/[processorhpp, crhpp, eflagshpp]
import commonhpp

proc initProcessor*(logger: EmuLogger): Processor =
  # memset(gpregs, 0, sizeof(gpregs))
  # memset(sgregs, 0, sizeof(sgregs))
  result = Processor(logger: logger)
  initCR(result)
  # asgnAux[CR](result, initCR())

  result.set_eip(0x0000fff0)
  result.set_crn(0, 0x60000010)
  result.eflags.set_eflags(0x00000002)
  result.sgregs[CS].raw = 0xf000
  result.sgregs[CS].cache.base = 0xffff0000u32
  result.sgregs[CS].cache.flags.`type`.segc = 1
  for i in ES .. GS:
    result.sgregs[i].cache.limit = 0xffff
    result.sgregs[i].cache.flags.P = 1
    result.sgregs[i].cache.flags.`type`.A = 1
    result.sgregs[i].cache.flags.`type`.data.w = 1

  result.dtregs[IDTR].base  = 0x0000
  result.dtregs[IDTR].limit = 0xffff
  result.dtregs[GDTR].base  = 0x0000
  result.dtregs[GDTR].limit = 0xffff
  result.dtregs[LDTR].base  = 0x0000
  result.dtregs[LDTR].limit = 0xffff
  result.halt = false

proc dump_regs*(this: var Processor): void = 
  var i: cint
  var gpreg_name = ["EAX", "ECX", "EDX", "EBX", "ESP", "EBP", "ESI", "EDI"]
  var sgreg_name = ["ES", "CS", "SS", "DS", "FS", "GS"]
  var dtreg_name = ["GDTR", "IDTR", "LDTR", " TR "]

  # MSG("EIP = 0x%08x\\n", eip)
  # for i in low(gpregs_t) ..< high(gpregs_t):
  #   MSG(
  #     "%s = 0x%08x : 0x%04x (0x%02x/0x%02x)\\n",
  #     gpreg_name[i], gpregs[i].reg32, gpregs[i].reg16, gpregs[i].reg8_h, gpregs[i].reg8_l)

  # MSG("EFLAGS = 0x%08x\\n", get_eflags())
  # for i in lwo(sgrets_t) ..< high(sgregs_t):
  #   var cache: SGRegCache = sgregs[i].cache
  #   MSG(
  #     "%s = 0x%04x {base = 0x%08x, limit = %08x, flags = %04x}\\n",
  #     sgreg_name[i], sgregs[i].raw, cache.base, cache.limit, cache.flags.raw)

  # for i in low(dtreg_t) ..< high(dtreg_t):
  #   MSG(
  #     "%s =        {base = 0x%08x, limit = %08x}\\n",
  #     dtreg_name[i], dtregs[i].base, dtregs[i].limit)

  # while i < DTREGS_COUNT:
  #   MSG("%s = 0x%04x {base = 0x%08x, limit = %08x}\\n", dtreg_name[i], dtregs[i].selector, dtregs[i].base, dtregs[i].limit)
  #   postInc(i)
  # block:
  #   i = 0
  #   while i < 5:
  #     MSG("CR%d=0x%08x ", i, get_crn(i))
  #     postInc(i)
  # MSG("\\n")
