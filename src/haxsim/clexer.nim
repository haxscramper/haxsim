import ctypes
export ctypes

import std/[re]
import hmisc/[helpers, hdebug_misc]

startHax()

proc tokenize*(str: string): seq[CToken] =
  var pos = 0

  template ok(regex: Regex): untyped =
    var matches {.inject.}: array[10, string]
    let res = match(str, regex, matches, pos)
    res

  template push(kind: CTokenKind, group: int): untyped =
    result.add initTok(kind, pos, matches[group])
    pos += matches[group].len

  template skip(group: int): untyped =
    pos += matches[group].len

  while pos < str.len:
    if ok(re"(for)"):               push(ctkForKwd, 0)
    elif ok(re"(while)"):           push(ctkWhileKwd, 0)
    elif ok(re"(if)"):              push(ctkIfKwd, 0)
    elif ok(re"(else)"):            push(ctkElseKwd, 0)
    elif ok(re"(enum)"):            push(ctkEnumKwd, 0)
    elif ok(re"(struct)"):          push(ctkEnumKwd, 0)
    elif ok(re"(\()"):              push(ctkLPar, 0)
    elif ok(re"(\))"):              push(ctkRPar, 0)
    elif ok(re"(<)"):               push(ctkLess, 0)
    elif ok(re"(\+\+)"):            push(ctkIncr, 0)
    elif ok(re"({)"):               push(ctkLCurly, 0)
    elif ok(re"(})"):               push(ctkRCurly, 0)
    elif ok(re"([_a-zA-Z0-9]+)"):   push(ctkIdent, 0)
    elif ok(re"(\s+)"):             skip(0)
    elif ok(re"(=)"):               push(ctkEq, 0)
    elif ok(re"(0|([1-9][0-9]+))"): push(ctkIntLit, 0)
    elif ok(re"(;)"):               push(ctkSemicolon, 0)
    elif ok(re"(\.)"):              push(ctkDot, 0)
    elif ok(re"""(".*?")"""):       push(ctkStrLit, 0)


    else:
      echov "ignore: ", str[pos .. ^1]
      raiseImplementError("")
