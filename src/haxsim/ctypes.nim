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
    ctkComma
    ctkLPar
    ctkRPar
    ctkLCurly
    ctkRCurly
    ctkLBrack
    ctkRBrack

    ctkForKwd
    ctkIfKwd
    ctkElseKwd
    ctkWhileKwd
    ctkInKwd

    ctkStructKwd
    ctkEnumKwd
    ctkTypedefKwd

  CToken* = object
    kind*: CTokenKind
    str*: string
    line* {.requiresinit.}: int
    column* {.requiresinit.}: int
    extent*: Slice[int]

proc initTok*(
    kind: CTokenKind, start: int, tokenStr: string,
    line, column: int
  ): CToken =
  CToken(
    kind: kind, extent: start ..< (start + tokenStr.len),
    str: tokenStr, line: line, column: column
  )

proc lispRepr*(tok: CToken, colored: bool = true): string =
  "(" & toBlue(($tok.kind)[3 ..^ 1], colored) & " " &
    toYellow("\"" & tok.str & "\"", colored) & ")"

proc lispRepr*(toks: seq[CToken], colored: bool = true): string =
  "(" & mapPairs(toks, lispRepr(rhs)).join(" ") & ")"

#===========================  AST definitions  ===========================#

type
  CNodeKind* = enum
    cnkForStmt
    cnkWhileStmt
    cnkIfStmt
    cnkElseStmt

    cnkIntLit
    cnkStrLit

    cnkCall
    cnkBracket

    cnkIdent
    cnkStructDecl
    cnkIdentDefs
    cnkVarDecl
    cnkFieldExpr

    cnkFile
    cnkStmtList
    cnkEmptyNode

  CNode* = ref object
    case kind*: CNodeKind
      of cnkIntLit:
        intVal*: int

      of cnkStrLit, cnkIdent:
        strVal*: string

      else:
        subnodes*: seq[CNode]

const
  cnkTokenKinds* = {cnkIntLit, cnkStrLit, cnkIdent}

func add*(node: var CNode, node2: CNode) = node.subnodes.add node2
func len*(node: CNode): int = node.subnodes.len
iterator items*(node: CNode): CNode =
  for subnode in node.subnodes:
    yield subnode

proc `[]`*(node: CNode, idx: int | HSLice[int, BackwardsIndex]): auto =
  node.subnodes[idx]

proc newTree*(kind: CNodeKind, subnodes: varargs[CNode]): CNode =
  result = CNode(kind: kind)
  for node in subnodes:
    result.subnodes.add node

proc newTree*(kind: CNodeKind, token: CToken): CNode =
  result = CNode(kind: kind)
  case kind:
    of cnkIntLit:
      result.intVal = parseInt(token.str)

    of cnkStrLit, cnkIdent:
      result.strVal = token.str

    else:
      raiseImplementError("")

proc newEmptyCNode*(): CNode = newTree(cnkEmptyNode)


proc treeRepr*(
    pnode: CNode, colored: bool = true,
    indexed: bool = false, maxdepth: int = 120
  ): string =

  proc aux(n: CNode, level: int, idx: seq[int]): string =
    let pref =
      if indexed:
        idx.join("", ("[", "]")) & "    "
      else:
        "  ".repeat(level)

    if level > maxdepth:
      return pref & " ..."



    result &= pref & ($n.kind)[3 ..^ 1]
    case n.kind:
      of cnkStrLit:
        result &= " \"" & toYellow(n.strVal, colored) & "\""

      of cnkIntLit:
        result &= " " & toBlue($n.intVal, colored)

      of cnkIdent:
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
  CValueKind* = enum
    cvkInt
    cvkString
    cvkFloat
    cvkRecord
    cvkArray

  CValue* = object
    case kind*: CValueKind
      of cvkInt:
        intVal*: int

      of cvkString:
        strVal*: string

      of cvkFloat:
        floatVal*: float

      of cvkRecord:
        discard

      of cvkArray:
        elements*: seq[CValue]

iterator items*(value: CValue): CValue =
  for item in value.elements:
    yield item
