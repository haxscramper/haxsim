type
  exception_t* = enum
    EXP_DE
    EXP_DB
    EXP_BP
    EXP_OF
    EXP_BR
    EXP_UD
    EXP_NM
    EXP_DF
    EXP_TS
    EXP_NP
    EXP_SS
    EXP_GP
    EXP_PF
    EXP_MF
    EXP_AC
    EXP_MC
    EXP_XF
    EXP_VE
    EXP_SX

template EXCEPTION*(n: untyped, c: untyped): untyped {.dirty.} =
  if c:
    WARN("exception interrupt %d (%s)", n, astToStr(c))
    when false:
      # FIXME wrap expression
      raise n


template EXCEPTION_WITH*(n: untyped, c: untyped, e: untyped): untyped {.dirty.} =
  if c:
    WARN("exception interrupt %d (%s)", n, astToStr(c))
    e
    when false:
      # FIXME wrap expression
      raise n
