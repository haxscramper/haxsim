import std/[
  strutils, parseutils, sequtils, strformat,
  options, tables, hashes, macros
]
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
    htkVarKwd

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
proc newIdentHLNode*(id: string): HLNode =
  HLNode(kind: hnkIdent, strVal: id)


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
    hvkTable
    hvkProc
    hvkNil
    hvkAny

  HLProcImpl* = proc(args: seq[HLValue]): Option[HLValue]
  HLProcImplTable* = Table[string, seq[HLValue]]

  HLType* = ref object
    case kind*: HLValueKind
      of hvkProc:
        argTypes*: seq[HLType]
        returnType*: HLType

      of hvkArray:
        elemType*: HLType

      of hvkTable:
        keyType*: HLType
        valType*: HLType

      else:
        discard


  HLValue* = ref HLValueObj
  HLValueObj* = object
    hlType*: HLType
    case kind*: HLValueKind
      of hvkInt:
        intVal*: int

      of hvkString:
        strVal*: string

      of hvkFloat:
        floatVal*: float

      of hvkBool:
        boolVal*: bool

      of hvkNil:
        discard

      of hvkRecord:
        discard

      of hvkAny:
        anyVal*: HLValue

      of hvkTable:
        table*: Table[HLValue, HLValue]

      of hvkProc:
        impl*: HLProcImpl

      of hvkArray:
        idx: int
        elements*: seq[HLValue]


func hash*(a: HLValue): Hash =
  var h = hash(a.kind)
  case a.kind:
    of hvkNil: discard
    of hvkAny: h = h !& hash(a.anyVal)
    of hvkInt: h = h !& hash(a.intVal)
    of hvkString: h = h !& hash(a.strVal)
    of hvkFloat: h = h !& hash(a.floatVal)
    of hvkBool: h = h !& hash(a.boolVal)
    of hvkProc: h = h !& hash(a.impl)
    of hvkRecord: discard
    of hvkArray:
      for element in pairs(a.elements):
        h = h !& hash(element)

    of hvkTable:
      for (key, value) in pairs(a.table):
        h = h !& hash(key) !& hash(value)

  result = !$(h)

func `==`*(a, b: HLValue): bool =
  a.kind == b.kind and
  (
    case a.kind:
      of hvkNil: true
      of hvkAny: a.anyVal == b.anyVal
      of hvkInt: a.intVal == b.intVal
      of hvkString: a.strVal == b.strVal
      of hvkFloat: a.floatVal == b.floatVal
      of hvkBool: a.boolVal == b.boolVal
      of hvkProc: a.impl == b.impl
      of hvkRecord: true
      of hvkArray: subnodesEq(a, b, elements)
      of hvkTable: a.table == b.table
  )

func initHLType*(T: typedesc[int|float|string|bool|HLValue|void]): HLType

func initHLType*[R, T0, T1](pr: type proc(a: T0, b: T1): R): HLType =
  HLType(
    kind: hvkProc,
    argTypes: @[initHLType(T0), initHLType(T1)],
    returnType: initHLType(R)
  )


func initHLType*[T0, T1, T2](pr: type proc(a: T0, b: T1, c: T2)): HLType =
  HLType(
    kind: hvkProc,
    argTypes: @[initHLType(T0), initHLType(T1), initHLType(T2)],
    returnType: initHLType(void)
  )


func initHLType*[T0](pr: type proc(a: T0)): HLType =
  HLType(
    kind: hvkProc,
    argTypes: @[initHLType(T0)],
    returnType: initHLType(void)
  )

func initHLType*(T: typedesc[int|float|string|bool|HLValue|void]): HLType =
  when T is int: result = HLType(kind: hvkInt)
  elif T is float: result = HLType(kind: hvkFloat)
  elif T is string: result = HLType(kind: hvkString)
  elif T is bool: result = HLType(kind: hvkBool)
  elif T is HLValue: result = HLType(kind: hvkAny)
  elif T is void: result = HLType(kind: hvkNil)

func nextValue*(value: var HLValue): Option[HLValue] =
  if value.idx < value.elements.len:
    result = some value.elements[value.idx]
    inc value.idx


func initHLValue*(val: bool): HLValue =
  HLValue(boolVal: val, kind: hvkBool, hlType: initHLType(bool))

func initHLValue*(val: int): HLValue =
  HLValue(intVal: val, kind: hvkInt, hlType: initHLType(int))

func initHLValue*(val: string): HLValue =
  HLValue(strVal: val, kind: hvkString, hlType: initHLType(string))

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


proc getSignature*(pr: NimNode): (seq[NimNode], NimNode) =
  let sign = pr.getTypeImpl()[0]
  if sign.len > 0:
    for arg in sign[1 .. ^1]:
      result[0].add arg[1]

  result[1] = sign[0]

macro argHLTypes*(pr: typed): untyped =
  let (args, retType) = getSignature(pr)
  result = nnkBracket.newTree()
  for arg in args:
    result.add newCall("initHLType", arg)

  result = quote do:
    let argTypes {.inject.}: seq[HLType] = @`result`
    let returnType {.inject.}: HLType = initHLType(`retType`)


func get(val: HLValue, T: typedesc): auto =
  when T is int: return val.intVal
  elif T is float: return val.floatVal
  elif T is string: return val.stringVal
  elif T is bool: return val.boolVal
  elif T is HLValue: return val
  elif T is seq:
    var res: T
    for entry in val.elements:
      res.add entry.get(typeof res[0])

    return res


  else:
    static:
      {.error: "Unhanled type for `get()`, ", $typeof(T).}

func initHLValue*[R, T0, T1](pr: proc(a: T0, b: T1): R): HLValue =
  HLValue(
    kind: hvkProc,
    hlType: initHLType(typeof pr),
    impl: (
      proc(args: seq[HLValue]): Option[HLValue] =
        let res = pr(args[0].get(T0), args[1].get(T1))
        return some initHLValue(res)
    )
  )


func initHLValue*[T0, T1, T2](pr: proc(a: T0, b: T1, c: T2)): HLValue =
  HLValue(
    kind: hvkProc,
    hlType: initHLType(typeof pr),
    impl: (
      proc(args: seq[HLValue]): Option[HLValue] =
        pr(args[0].get(T0), args[1].get(T1), args[2].get(T2))
    )
  )

func initHLValue*[T0](pr: proc(a: T0)): HLValue =
  HLValue(
    kind: hvkProc, hlType: initHLType(typeof pr),
    impl: (
      proc(args: seq[HLValue]): Option[HLValue] =
        pr(args[0].get(T0))
    )
  )



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


func `$`*(hlType: HLType): string =
  if isNil(hlType):
    result = "<nil>"

  else:
    case hlType.kind:
      of hvkAny: result = "any"
      of hvkNil: result = "nil"
      of hvkInt: result = "int"
      of hvkFloat: result = "float"
      of hvkString: result = "string"
      of hvkBool: result = "bool"
      of hvkArray: result = &"array[{hlType.elemType}]"
      of hvkRecord: result = "object"
      of hvkTable: result = &"table[{hlType.keyType}, {hlType.valType}]"
      of hvkProc:
        result &= "proc("
        for idx, arg in pairs(hlType.argTypes):
          if idx > 0:
            result &= ", "

          result &= $arg

        result &= "): " & $hlType.returnType

func `$`*(val: HLValue): string =
  case val.kind:
    of hvkNil: result = "nil"
    of hvkProc: result = $val.hlType
    of hvkInt: result = $val.intVal
    of hvkString: result = $val.strVal
    of hvkFloat: result = $val.floatVal
    of hvkBool: result = $val.boolVal
    of hvkAny: result = "~" & $val.anyVal
    of hvkArray:
      result = "["
      for idx, elem in pairs(val.elements):
        if idx > 0:
          result &= ", "

        result &= $elem

      result &= "]"

    of hvkTable:
      result = "{"
      for idx, (key, val) in enumerate(pairs(val.table)):
        if idx > 0:
          result &= ", "

          result &= $key & ": " & $val

      result &= "}"

    of hvkRecord:
      raiseImplementKindError(val)

func `+`*(a, b: HLValue): HLValue = opAux(a, b, `+`)
func `-`*(a, b: HLValue): HLValue = opAux(a, b, `-`)
func `*`*(a, b: HLValue): HLValue = opAux(a, b, `*`)

func `[]=`*(arr, key, val: HLValue): void =
  case arr.kind:
    of hvkArray:
      arr.elements[key.intVal] = val

    of hvkTable:
      arr.table[key] = val

    else:
      raiseArgumentError(
        $arr.kind & " does not support array assignments " &
          &"{arr.kind}[{key.kind}] = {val.kind}"
      )

func unif*(a, b: HLType): bool =
  a.kind == hvkAny or
  b.kind == hvkAny or
  (
    a.kind == b.kind and (
      case a.kind:
        of hvkArray: unif(a.elemType, b.elemType)
        of hvkTable: unif(a.keyType, b.keyType) and
                     unif(a.valType, b.valType)


        of hvkInt, hvkString, hvkFloat, hvkBool:
          true

        else:
          raiseImplementKindError(a)
    )
  )

func matchesForArgs*(impl: HLValue, argTypes: seq[HLType]): bool =
  if impl.hlType.argTypes.len != argTypes.len:
    return false

  else:
    for (expected, given) in zip(impl.hlType.argTypes, argTypes):
      if not unif(expected, given):
        return false

    return true

func resolveOverloadedCall*(
  table: HLProcImplTable, name: string, argTypes: seq[HLType]): HLValue =

  for candidate in table[name]:
    if candidate.matchesForArgs(argTypes):
      return candidate

  raiseImplementError(
    &"Could not find matching overload for {name}({argTypes})")

iterator items*(value: HLValue): HLValue =
  for item in value.elements:
    yield item
