import ctypes
export ctypes

import std/[re]
import hmisc/[helpers, hdebug_misc]

startHax()

type
  CLexer = object
    str: string
    pos: int
    line: int
    column: int

func at(lex: var CLexer): char = lex.str[lex.pos]
func finished(lex: CLexer): bool = lex.pos >= lex.str.high
func match(lex: CLexer, re: Regex, matches: var openarray[string]): bool =
  result = match(lex.str, re, matches, lex.pos)

func `[]`(lex: CLexer, slice: HSlice[int, BackwardsIndex]): string =
  lex.str[lex.pos + slice.a .. slice.b]

func advance(lex: var CLexer, chars: int) =
  for _ in 0 ..< chars:
    inc lex.pos
    if lex.at() == '\n':
      inc lex.line
      lex.column = 0
    else:
      inc lex.column

func initTok(kind: CTokenKind, lex: CLexer, str: string): CToken =
  initTok(kind, lex.pos, str, line = lex.line, column = lex.column)

proc tokenize*(str: string): seq[CToken] =
  var lex = CLexer(str: str)

  template ok(regex: Regex): untyped =
    var matches {.inject.}: array[10, string]
    let res = match(lex, regex, matches)
    res

  template push(kind: CTokenKind, group: int): untyped =
    result.add initTok(kind, lex, matches[group])
    lex.advance matches[group].len

  template skip(group: int): untyped =
    lex.advance matches[group].len

  while not lex.finished:
    if ok(re"(for)"):               push(ctkForKwd,    0)
    elif ok(re"(while)"):           push(ctkWhileKwd,  0)
    elif ok(re"(if)"):              push(ctkIfKwd,     0)
    elif ok(re"(else)"):            push(ctkElseKwd,   0)
    elif ok(re"(enum)"):            push(ctkEnumKwd,   0)
    elif ok(re"(struct)"):          push(ctkEnumKwd,   0)
    elif ok(re"(\()"):              push(ctkLPar,      0)
    elif ok(re"(\))"):              push(ctkRPar,      0)
    elif ok(re"(<)"):               push(ctkLess,      0)
    elif ok(re"(\+\+)"):            push(ctkIncr,      0)
    elif ok(re"({)"):               push(ctkLCurly,    0)
    elif ok(re"(})"):               push(ctkRCurly,    0)
    elif ok(re"([_a-zA-Z0-9]+)"):   push(ctkIdent,     0)
    elif ok(re"(\s+)"):             skip(0)
    elif ok(re"(=)"):               push(ctkEq,        0)
    elif ok(re"(0|([1-9][0-9]+))"): push(ctkIntLit,    0)
    elif ok(re"(;)"):               push(ctkSemicolon, 0)
    elif ok(re"(\.)"):              push(ctkDot,       0)
    elif ok(re"""(".*?")"""):       push(ctkStrLit,    0)


    else:
      echov "ignore: ", lex[0 .. ^1]
      raiseImplementError("")
