import std/[strutils, parseutils, sequtils, strformat, options]
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
    htkCmp
    htkLess
    htkIncr
    htkPlus
    htkMinus
    htkDot
    htkStar

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
    hnkElifBranch
    hnkElseBranch

    hnkIntLit
    hnkStrLit

    hnkCall
    hnkBracket
    hnkInfix

    hnkIdent
    hnkStructDecl
    hnkIdentDefs
    hnkVarDecl
    hnkFieldExpr

    hnkFile
    hnkStmtList
    hnkEmptyNode

const
  hnkIntKinds* = {hnkIntLit}
  hnkStrKinds* = {hnkStrLit, hnkIdent}

type
  HLNode* = ref object
    case kind*: HLNodeKind
      of hnkIntKinds:
        intVal*: int

      of hnkStrKinds:
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


    if isNil(n):
      return pref & toCyan(" <nil>")


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

import hpprint, hpprint/hpprint_repr
import hmisc/types/colorstring

proc prettyPrintConverter*(
    val: HLNode,
    conf: var PPrintConf,
    path: ObjPath,
  ): ObjTree =

  if conf.idCounter.isVisited(val):
    return pptConst("<visisted>@" & $(cast[int](unsafeAddr val)))

  else:
    conf.idCounter.visit(val)
    case val.kind:
      of hnkIntKinds:
        pptObj($val.kind & " ", pptConst($val.intVal, initStyle(fgBlue)))

      of hnkStrKinds:
        pptObj($val.kind & " ", pptConst($val.strVal, initStyle(fgYellow)))

      else:
        var subn: seq[ObjTree]
        for node in items(val):
          subn.add prettyPrintConverter(node, conf, path)

        pptObj($val.kind, {
          "subnodes" : pptSeq(subn)
        })


type
  HLValueKind* = enum
    hvkInt
    hvkString
    hvkFloat
    hvkBool
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

      of hvkBool:
        boolVal*: bool

      of hvkRecord:
        discard

      of hvkArray:
        idx: int
        elements*: seq[HLValue]

func `==`*(a, b: HLValue): bool =
  a.kind == b.kind and
  (
    case a.kind:
      of hvkInt: a.intVal == b.intVal
      of hvkString: a.strVal == b.strVal
      of hvkFloat: a.floatVal == b.floatVal
      of hvkBool: a.boolVal == b.boolVal
      of hvkRecord: true
      of hvkArray: subnodesEq(a, b, elements)
  )

func nextValue*(value: var HLValue): Option[HLValue] =
  if value.idx < value.elements.len:
    result = some value.elements[value.idx]
    inc value.idx


func initHLValue*(val: bool): HLValue =
  HLValue(boolVal: val, kind: hvkBool)

func initHLValue*(val: int): HLValue =
  HLValue(intVal: val, kind: hvkInt)

func initHLValue*(val: string): HLValue =
  HLValue(strVal: val, kind: hvkString)

func initHLValue*(tree: HLNode): HLValue =
  case tree.kind:
    of hnkIntLit: result = initHLValue(tree.intVal)
    of hnkStrLit: result = initHLValue(tree.strVal)
    of hnkBracket:
      result = HLValue(kind: hvkArray)
      for node in tree:
        result.elements.add initHLValue(node)

    else:
      raiseImplementError("")

template opAux(a, b: HLValue, op: untyped): untyped =
  case a.kind:
    of hvkInt:
      case b.kind:
        of hvkInt:
          result = initHLValue(op(a.intVal, b.intVal))

        else:
          raiseImplementError($a.kind & " " & $b.kind)

    else:
      raiseImplementError($a.kind & " " & $b.kind)


func `+`*(a, b: HLValue): HLValue = opAux(a, b, `+`)
func `-`*(a, b: HLValue): HLValue = opAux(a, b, `-`)
func `*`*(a, b: HLValue): HLValue = opAux(a, b, `*`)

iterator items*(value: HLValue): HLValue =
  for item in value.elements:
    yield item
