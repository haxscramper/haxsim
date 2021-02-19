import std/[strutils, parseutils]
import hmisc/[base_errors]


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

    cnkIdent
    cnkStructDecl
    cnkIdentDefs
    cnkVarDecl

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

func add*(node: var CNode, node2: CNode) = node.subnodes.add node2
func len*(node: CNode): int = node.subnodes.len
iterator items*(node: CNode): CNode =
  for subnode in node.subnodes:
    yield subnode

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
