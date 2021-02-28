import std/[strutils, parseutils, sequtils, strformat]
import hmisc/[base_errors]
import hmisc/types/[colorstring]
import hmisc/helpers
import std/[enumerate]


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

#==========================  Token definitions  ==========================#

type
  HLTokenKind* = enum
    htkIntLit
    htkCharLit
    htkStrLit

    htkEq
    htkLess
    htkIncr
    htkPlus
    htkDot

    htkIdent
    htkSemicolon
    htkComma
    htkLPar
    htkRPar
    htkLCurly
    htkRCurly
    htkLBrack
    htkRBrack

    htkForKwd
    htkIfKwd
    htkElseKwd
    htkWhileKwd
    htkInKwd

    htkStructKwd
    htkEnumKwd
    htkTypedefKwd

  HLToken* = object
    kind*: HLTokenKind
    str*: string
    line* {.requiresinit.}: int
    column* {.requiresinit.}: int
    extent*: Slice[int]

proc initTok*(
    kind: HLTokenKind, start: int, tokenStr: string,
    line, column: int
  ): HLToken =
  HLToken(
    kind: kind, extent: start ..< (start + tokenStr.len),
    str: tokenStr, line: line, column: column
  )

proc lispRepr*(tok: HLToken, colored: bool = true): string =
  "(" & toBlue(($tok.kind)[3 ..^ 1], colored) & " " &
    toYellow("\"" & tok.str & "\"", colored) & ")"

proc lispRepr*(toks: seq[HLToken], colored: bool = true): string =
  "(" & mapPairs(toks, lispRepr(rhs)).join(" ") & ")"

#===========================  AST definitions  ===========================#

type
  HLNodeKind* = enum
    hnkForStmt
    hnkWhileStmt
    hnkIfStmt
    hnkElseStmt

    hnkIntLit
    hnkStrLit

    hnkCall
    hnkBracket

    hnkIdent
    hnkStructDecl
    hnkIdentDefs
    hnkVarDecl
    hnkFieldExpr

    hnkFile
    hnkStmtList
    hnkEmptyNode

  HLNode* = ref object
    case kind*: HLNodeKind
      of hnkIntLit:
        intVal*: int

      of hnkStrLit, hnkIdent:
        strVal*: string

      else:
        subnodes*: seq[HLNode]

const
  hnkTokenKinds* = {hnkIntLit, hnkStrLit, hnkIdent}

func add*(node: var HLNode, node2: HLNode) = node.subnodes.add node2
func len*(node: HLNode): int = node.subnodes.len
iterator items*(node: HLNode): HLNode =
  for subnode in node.subnodes:
    yield subnode

proc `[]`*(node: HLNode, idx: int | HSLice[int, BackwardsIndex]): auto =
  node.subnodes[idx]

proc newTree*(kind: HLNodeKind, subnodes: varargs[HLNode]): HLNode =
  result = HLNode(kind: kind)
  for node in subnodes:
    result.subnodes.add node

proc newTree*(kind: HLNodeKind, token: HLToken): HLNode =
  result = HLNode(kind: kind)
  case kind:
    of hnkIntLit:
      result.intVal = parseInt(token.str)

    of hnkStrLit, hnkIdent:
      result.strVal = token.str

    else:
      raiseImplementError("")

proc newEmptyCNode*(): HLNode = newTree(hnkEmptyNode)


proc treeRepr*(
    pnode: HLNode, colored: bool = true,
    indexed: bool = false, maxdepth: int = 120
  ): string =

  proc aux(n: HLNode, level: int, idx: seq[int]): string =
    let pref =
      if indexed:
        idx.join("", ("[", "]")) & "    "
      else:
        "  ".repeat(level)

    if level > maxdepth:
      return pref & " ..."



    result &= pref & ($n.kind)[3 ..^ 1]
    case n.kind:
      of hnkStrLit:
        result &= " \"" & toYellow(n.strVal, colored) & "\""

      of hnkIntLit:
        result &= " " & toBlue($n.intVal, colored)

      of hnkIdent:
        result &= " " & toGreen(n.strVal, colored)

      else:
        if n.len > 0:
          result &= "\n"

        for newIdx, subn in enumerate(n):
          result &= aux(subn, level + 1, idx & newIdx)
          if newIdx < n.len - 1:
            result &= "\n"

  return aux(pnode, 0, @[])

type
  HLValueKind* = enum
    hvkInt
    hvkString
    hvkFloat
    hvkRecord
    hvkArray

  HLValue* = object
    case kind*: HLValueKind
      of hvkInt:
        intVal*: int

      of hvkString:
        strVal*: string

      of hvkFloat:
        floatVal*: float

      of hvkRecord:
        discard

      of hvkArray:
        elements*: seq[HLValue]

iterator items*(value: HLValue): HLValue =
  for item in value.elements:
    yield item
