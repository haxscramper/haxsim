import
  stringh
import
  hardware/processorhpp
proc initProcessor*(): Processor_Processor = 
  memset(gpregs, 0, sizeof((gpregs)))
  memset(sgregs, 0, sizeof((sgregs)))
  set_eip(0x0000fff0)
  set_crn(0, 0x60000010)
  set_eflags(0x00000002)
  sgregs[CS].raw = 0xf000
  sgregs[CS].cache.base = 0xffff0000
  sgregs[CS].cache.flags.`type`.segc = 1
  for i in 0 ..< SGREGS_COUNT:
    sgregs[i].cache.limit = 0xffff
    sgregs[i].cache.flags.P = 1
    sgregs[i].cache.flags.`type`.A = 1
    sgregs[i].cache.flags.`type`.data.w = 1
  dtregs[IDTR].base = 0x0000
  dtregs[IDTR].limit = 0xffff
  dtregs[GDTR].base = 0x0000
  dtregs[GDTR].limit = 0xffff
  dtregs[LDTR].base = 0x0000
  dtregs[LDTR].limit = 0xffff
  halt = false

proc dump_regs*(this: var Processor): void = 
  var i: cint
  var gpreg_name: ptr UncheckedArray[cstring] = ("EAX", "ECX", "EDX", "EBX", "ESP", "EBP", "ESI", "EDI")
  var sgreg_name: ptr UncheckedArray[cstring] = ("ES", "CS", "SS", "DS", "FS", "GS")
  var dtreg_name: ptr UncheckedArray[cstring] = ("GDTR", "IDTR", "LDTR", " TR ")
  MSG("EIP = 0x%08x\\n", eip)
  block:
    i = 0
    while i < GPREGS_COUNT:
      MSG("%s = 0x%08x : 0x%04x (0x%02x/0x%02x)\\n", gpreg_name[i], gpregs[i].reg32, gpregs[i].reg16, gpregs[i].reg8_h, gpregs[i].reg8_l)
      postInc(i)
  MSG("EFLAGS = 0x%08x\\n", get_eflags())
  block:
    i = 0
    while i < SGREGS_COUNT:
      var cache: SGRegCache = sgregs[i].cache
      MSG("%s = 0x%04x {base = 0x%08x, limit = %08x, flags = %04x}\\n", sgreg_name[i], sgregs[i].raw, cache.base, cache.limit, cache.flags.raw)
      postInc(i)
  block:
    i = 0
    while i < LDTR:
      MSG("%s =        {base = 0x%08x, limit = %08x}\\n", dtreg_name[i], dtregs[i].base, dtregs[i].limit)
      postInc(i)
  while i < DTREGS_COUNT:
    MSG("%s = 0x%04x {base = 0x%08x, limit = %08x}\\n", dtreg_name[i], dtregs[i].selector, dtregs[i].base, dtregs[i].limit)
    postInc(i)
  block:
    i = 0
    while i < 5:
      MSG("CR%d=0x%08x ", i, get_crn(i))
      postInc(i)
  MSG("\\n")
