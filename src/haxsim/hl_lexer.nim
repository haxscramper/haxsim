import ./hl_types, ./hl_error
export hl_types

import std/[re]
import hmisc/[helpers, hdebug_misc]

startHax()

type
  HLLexer = object
    str: string
    pos: int
    line: int
    column: int

func at(lex: var HLLexer): char =
  if lex.pos >= lex.str.len:
    '\x00'
  else:
    lex.str[lex.pos]

func finished(lex: HLLexer): bool = lex.pos >= lex.str.len
func match(lex: HLLexer, re: Regex, matches: var openarray[string]): bool =
  result = match(lex.str, re, matches, lex.pos)

func `[]`(lex: HLLexer, slice: HSlice[int, BackwardsIndex]): string =
  lex.str[lex.pos + slice.a .. slice.b]

func advance(lex: var HLLexer, chars: int) =
  for _ in 0 ..< chars:
    inc lex.pos
    if lex.at() == '\n':
      inc lex.line
      lex.column = 0
    else:
      inc lex.column

func initTok(kind: HLTokenKind, lex: HLLexer, str: string): HLToken =
  initTok(kind, lex.pos, str, line = lex.line, column = lex.column)

proc tokenize*(str: string): seq[HLToken] =
  var lex = HLLexer(str: str)

  template ok(regex: Regex): untyped =
    var matches {.inject.}: array[10, string]
    let res = match(lex, regex, matches)
    res

  template push(kind: HLTokenKind, group: int): untyped =
    result.add initTok(kind, lex, matches[group])
    lex.advance matches[group].len

  template skip(group: int): untyped =
    lex.advance matches[group].len

  var tokens: seq[(Regex, HlTokenKind)]
  for (patt, kind) in {
    r"\(":              htkLPar,
    r"\)":              htkRPar,
    r"\[":              htkLBrack,
    r"]":               htkRBrack,
    r"<":               htkLess,
    r"\+\+":            htkIncr,
    r"\+":              htkPlus,
    r"\*":              htkStar,
    r"\-":              htkMinus,
    r"{":               htkLCurly,
    r"}":               htkRCurly,
    r"0|([1-9][0-9]*)": htkIntLit,
    r"[_a-zA-Z0-9]+":   htkIdent,
    r"\s+":             htkSpace,
    r"==":              htkCmp,
    r"=":               htkEq,
    r";":               htkSemicolon,
    r":":               htkColon,
    r",":               htkComma,
    r"\.":             htkDot,
    r"""".*?"""":       htkStrLit,
  }:
    tokens.add (re("(" & patt & ")"), kind)

  const kwdList = {
    r"for":             htkForKwd,
    r"while":           htkWhileKwd,
    r"if":              htkIfKwd,
    r"else":            htkElseKwd,
    r"enum":            htkEnumKwd,
    r"struct":          htkEnumKwd,
    r"in":              htkInKwd,
    r"var":             htkVarKwd,
    r"proc":            htkProcKwd,
  }


  while not lex.finished:
    var foundOk = false
    for (patt, kind) in tokens:
      if ok(patt):
        var kind = kind
        if kind == htkIdent:
          for kwd in kwdList:
            if kwd[0] == matches[0]:
              kind = kwd[1]

        foundOk = true
        if kind != htkSpace:
          push(kind, 0)

        else:
          skip(0)

    if not foundOk:
      str.errorAt(lex.pos .. lex.pos + 5, "Undefined token")
      raiseImplementError("")


when isMainModule:
  import hmisc/other/oswrap
  let tokens: seq[HLToken] = tokenize(paramStr(0))
  for tok in tokens:
    echo tok.lispRepr()
