import hl_types
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

func at(lex: var HLLexer): char = lex.str[lex.pos]
func finished(lex: HLLexer): bool = lex.pos >= lex.str.high
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

  while not lex.finished:
    if ok(re"(for)"):               push(htkForKwd,    0)
    elif ok(re"(while)"):           push(htkWhileKwd,  0)
    elif ok(re"(if)"):              push(htkIfKwd,     0)
    elif ok(re"(else)"):            push(htkElseKwd,   0)
    elif ok(re"(enum)"):            push(htkEnumKwd,   0)
    elif ok(re"(struct)"):          push(htkEnumKwd,   0)
    elif ok(re"(in)"): push(htkInKwd, 0)
    elif ok(re"(\()"):              push(htkLPar,      0)
    elif ok(re"(\))"):              push(htkRPar,      0)
    elif ok(re"(\[)"):              push(htkLBrack, 0)
    elif ok(re"(])"):               push(htkRBrack, 0)
    elif ok(re"(<)"):               push(htkLess,      0)
    elif ok(re"(\+\+)"):            push(htkIncr,      0)
    elif ok(re"({)"):               push(htkLCurly,    0)
    elif ok(re"(})"):               push(htkRCurly,    0)
    elif ok(re"(0|([1-9][0-9]*))"): push(htkIntLit,    0)
    elif ok(re"([_a-zA-Z0-9]+)"):   push(htkIdent,     0)
    elif ok(re"(\s+)"):             skip(0)
    elif ok(re"(=)"):               push(htkEq,        0)
    elif ok(re"(;)"):               push(htkSemicolon, 0)
    elif ok(re"(,)"):               push(htkComma, 0)
    elif ok(re"(\.)"):              push(htkDot,       0)
    elif ok(re"""(".*?")"""):       push(htkStrLit,    0)


    else:
      echov "ignore: ", lex[0 .. ^1]
      raiseImplementError("")
