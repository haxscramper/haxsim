import std/[strutils]


template toArray*[N, T](arg: typed): array[N, T] =
  var result: array[N, T]
  for (k, v) in arg:
    result[k] = v

  result

proc toMapString*[T, N](arr: array[N, T]): string =
  result &= "["
  for idx, item in arr:
    result &= $idx & ": \"" & $item & "\""
    if idx < arr.high:
      result &= ", "


  result &= "]"


type
  CTokenKind* = enum
    ctkIntLit
    ctkCharLit
    ctkStrLit

    ctkEq
    ctkLess
    ctkIncr
    ctkPlus
    ctkDot

    ctkIdent
    ctkSemicolon
    ctkLPar
    ctkRPar
    ctkLCurly
    ctkRCurly

    ctkForKwd
    ctkIfKwd
    ctkElseKwd
    ctkWhileKwd

    ctkStructKwd
    ctkEnumKwd
    ctkTypedefKwd

  CToken* = object
    kind*: CTokenKind
    str*: string
    extent*: Slice[int]

proc initTok*(kind: CTokenKind, start: int, tokenStr: string): CToken =
  CToken(kind: kind, extent: start ..< (start + tokenStr.len), str: tokenStr)

proc lispRepr*(tok: CToken, colored: bool = true): string =
  "(" & alignLeft(($tok.kind)[3 ..^ 1], 8) & " \"" & tok.str & "\")"
