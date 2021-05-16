import std/[
  strutils, parseutils, sequtils, strformat,
  options, tables, hashes, macros, lists
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

macro genInitHL*(count: static[int], typeGen: static[bool]): untyped =
  result = newStmtList()

  for argc in 0 .. count:
    for hasRet in [true, false]:
      var
        gen = nnkIdentDefs.newTree()
        cbFormal = nnkFormalParams.newTree()
        cbCall = newCall("pr")
        impl = newStmtList()

      block:
        if hasRet:
          cbFormal.add ident("R")

        else:
          cbFormal.add newEmptyNode()


        for arg in 0 ..< argc:
          let t = ident("T" & $arg)
          cbCall.add newCall(
            "get", nnkBracketExpr.newTree(ident("args"), newLit(arg)), t)
          gen.add ident("T" & $arg)
          cbFormal.add nnkIdentDefs.newTree(
            ident("a" & $arg), t, newEmptyNode())

        if hasRet:
          gen.add ident("R")
          impl.add quote do:
            let res = `cbCall`
            return some initHLValue(res)

        else:
          impl.add cbCall

        gen.add newEmptyNode()
        gen.add newEmptyNode()

      let prGen =
        if gen.len > 0:
          nnkGenericParams.newTree(gen)

        else:
          newEmptyNode()

      if typeGen:
        let cbSig = nnkIdentDefs.newTree(
          ident("pr"),
          nnkBracketExpr.newTree(
            ident("typedesc"),
            nnkProcTy.newTree(cbFormal, newEmptyNode())),
          newEmptyNode())

        let argInit =
          if hasRet:
            newCall("initHLType", ident("R"))
          else:
            newCall("initHLType", ident("void"))

        var argTypes = nnkBracket.newTree()
        for idx in 0 ..< argc:
          argTypes.add newCall("initHLType", ident("T" & $idx))

        result.add nnkProcDef.newTree(
          nnkPostfix.newTree(ident("*"), ident("initHLType")),
          newEmptyNode(),
          prGen,
          nnkFormalParams.newTree(ident("HLType"), cbSig),
          newEmptyNode(),
          newEmptyNode(),
          (
            quote do:
              HLType(
                kind: hvkProc,
                argTypes: @`argTypes`,
                returnType: `argInit`
              )
          )
        )

      else:
        let cbSig = nnkIdentDefs.newTree(
          ident("pr"),
          nnkProcTy.newTree(cbFormal, newEmptyNode()),
          newEmptyNode())



        result.add nnkProcDef.newTree(
          nnkPostfix.newTree(ident("*"), ident("initHLValue")),
          newEmptyNode(),
          prGen,
          nnkFormalParams.newTree(ident("HLValue"), cbSig),
          newEmptyNode(),
          newEmptyNode(),
          (
            quote do:
              HLValue(
                kind: hvkProc,
                hlType: initHLType(typeof pr),
                impl: (
                  proc(args {.inject.}: seq[HLValue]): Option[HLValue] =
                    `impl`
                )
              )
          )
        )

#==========================  Token definitions  ==========================#

type
  HLTokenKind* = enum
    htkComment

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

    htkSpace
    htkIdent
    htkSemicolon
    htkColon
    htkComma
    htkLPar
    htkRPar
    htkLCurly
    htkRCurly
    htkLBrack
    htkRBrack

    htkForKwd
    htkNewKwd
    htkIfKwd
    htkElseKwd
    htkWhileKwd
    htkInKwd
    htkVarKwd
    htkProcKwd

    htkStructKwd
    htkEnumKwd
    htkTypedefKwd

  HLToken* = object
    kind*: HLTokenKind
    str*: string
    line*: int
    column*: int
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

    hnkProc
    hnkParams

    hnkIntLit
    hnkStrLit

    hnkCall
    hnkBracket
    hnkInfix

    hnkSym
    hnkIdent
    hnkStructDecl
    hnkIdentDefs
    hnkVarDecl
    hnkFieldExpr
    hnkNewExpr

    hnkFile
    hnkStmtList
    hnkEmptyNode

const
  hnkIntKinds* = {hnkIntLit}
  hnkStrKinds* = {hnkStrLit, hnkIdent}

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
    hvkList
    hvkNil
    hvkAny

  HLProcImpl* = proc(args: seq[HLValue]): Option[HLValue]
  HLProcImplTable* = Table[string, seq[HLValue]]

  HLType* = ref object
    case kind*: HLValueKind
      of hvkProc:
        argTypes*: seq[HLType]
        returnType*: HLType

      of hvkArray, hvkList:
        elemType*: HLType

      of hvkTable:
        keyType*: HLType
        valType*: HLType

      else:
        discard


  HLTable* = ref object
    buckets: seq[seq[tuple[key, value: HLValue]]]
    count: int

  HLList* = ref object
    next*: HLList
    value*: HLValue

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
        table*: HLTable

      of hvkProc:
        impl*: HLProcImpl

      of hvkList:
        list*: HLList

      of hvkArray:
        idx: int
        elements*: seq[HLValue]

  HlSymKind* = enum
    hskVar
    hskProc

  HLNode* = ref object
    token*: HLToken
    case kind*: HLNodeKind
      of hnkIntKinds:
        intVal*: int

      of hnkStrKinds:
        strVal*: string

      of hnkSym:
        symStr*: string
        symType*: HLType
        symKind*: HLSymKind
        symImpl*: Option[HLValue]

      else:
        subnodes*: seq[HLNode]

const
  hnkTokenKinds* = {hnkIntLit, hnkStrLit, hnkIdent}




func add*(node: var HLNode, node2: HLNode) = node.subnodes.add node2
func len*(node: HLNode): int = node.subnodes.len
iterator items*(node: HLNode): HLNode =
  for subnode in node.subnodes:
    yield subnode


iterator mitems*(node: var HLNode): var HLNode =
  for subnode in mitems(node.subnodes):
    yield subnode

proc `[]`*(node: HLNode, idx: int | HSLice[int, BackwardsIndex]): auto =
  node.subnodes[idx]

proc getStrVal*(node: HLNode): string =
  case node.kind:
    of hnkIdent: node.strVal
    of hnkSym: node.symStr
    else: raiseImplementError("")

proc `[]`*(node: var HLNode, idx: int | BackwardsIndex): var HLNode =
  node.subnodes[idx]

proc `[]=`*(node: var HLNode, idx: int, val: HLNode) =
  node.subnodes[idx] = val

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



iterator items*(table: HLList): HLValue =
  var next = table
  while not isNIl(next):
    yield next.value
    next = next.next

iterator pairs*(table: HLTable): (HLValue, HLValue) =
  for buck in table.buckets:
    for pair in buck:
      yield pair


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
    of hvkList:
      for element in items(a.list):
        h = h !& hash(element)

    of hvkArray:
      for element in pairs(a.elements):
        h = h !& hash(element)

    of hvkTable:
      for (key, value) in pairs(a.table):
        h = h !& hash(key) !& hash(value)

  result = abs(!$(h))

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
      of hvkList:
        var res = true
        var aVal = a.list.next
        var bVal = b.list.next

        while (not isNil(aVal)) and (not isNil(bVal)):
          if aVal.value != bVal.value:
            res = false
            break

          aVal = aVal.next
          bVal = bVal.next

        if not (isNil(aVal) and isNil(bVal)):
          res = false

        res
      of hvkTable: a.table == b.table
  )


func newHLTable*(): HLTable = new(result)
func newHLList*(): HLList = new(result)

func add*(l: HLList, val: HLValue) =
  var node = l
  while not isNil(node.next):
    node = node.next

  node.next = newHLList()
  node.next.value = val


func `[]`*(table: HLTable, key: HLValue): HLValue =
  let idx = key.hash() mod table.buckets.len()
  for (key, val) in table.buckets[idx]:
    if key == key:
      return val



func `[]=`*(table: HLTable, key, val: HLValue; inResize: bool = false)

func resize(table: HLTable) =
  let old = move(table.buckets)
  table.buckets = newSeqWith(
    max(old.len, 1) * 2,
    newSeq[typeof(old[0][0])]()
  )

  for buck in old:
    for (key, val) in buck:
      `[]=`(table, key, val, true)

func `[]=`*(table: HLTable, key, val: HLValue; inResize: bool = false) =
  if not(inResize) and
     (table.buckets.len() == 0 or table.count * 2 > table.buckets.len):
    resize(table)

  let idx = key.hash() mod table.buckets.len()
  for buck in mitems(table.buckets[idx]):
    if buck.key == key:
      buck.value = val
      return

  table.buckets[idx].add (key, val)
  if not inResize:
    inc table.count

type HlConv = int|float|string|bool|HLValue|void|HLTable|HLList

func initHLType*(T: typedesc[HlConv]): HLType


genInitHL(3, true)

func initHLType*(T: typedesc[HLConv]): HLType =
  when T is int:     result = HLType(kind: hvkInt)
  elif T is float:   result = HLType(kind: hvkFloat)
  elif T is string:  result = HLType(kind: hvkString)
  elif T is bool:    result = HLType(kind: hvkBool)
  elif T is HLValue: result = HLType(kind: hvkAny)
  elif T is void:    result = HLType(kind: hvkNil)
  elif T is HLList:  result = HLType(kind: hvkList)
  elif T is HLTable: result =
    HLTYpe(kind: hvkTable,
           keyType: HLType(kind: hvkAny),
           valType: HLType(kind: hvkAny))

func initHLType*[T](val: typedesc[seq[T]]): HLType =
  HLType(kind: hvkArray, elemType: initHLType(T))



func initHLType*(typeKind: HLValueKind, subtypes: seq[HLType]): HLType =
  result = HLType(kind: typeKind)
  case result.kind:
    of hvkList, hvkArray:
      result.elemType = subtypes[0]

    of hvkTable:
      result.keyType = subtypes[0]
      result.valType = subtypes[1]

    else:
      discard

func nextValue*(value: var HLValue): Option[HLValue] =
  if value.idx < value.elements.len:
    result = some value.elements[value.idx]
    inc value.idx


func initHLValue*(val: bool): HLValue =
  HLValue(boolVal: val, kind: hvkBool, hlType: initHLType(bool))

func initHLValue*(val: int): HLValue =
  HLValue(intVal: val, kind: hvkInt, hlType: initHLType(int))

func initHLValue*(val: float): HLValue =
  HLValue(floatVal: val, kind: hvkFloat, hlType: initHLType(float))

func initHLValue*(val: string): HLValue =
  HLValue(strVal: val, kind: hvkString, hlType: initHLType(string))

func initHLValue*(val: HLTable): HLValue =
  HLValue(table: val, kind: hvkTable, hlType: initHLType(HLTable))

func initHLValue*(val: HLValue): HLValue = val

func initHLValue*(val: HLList): HLValue =
  HLValue(list: val, kind: hvkList, hlType: initHLType(HLList))

func initHLValue*(tree: HLNode): HLValue =
  case tree.kind:
    of hnkIntLit: result = initHLValue(tree.intVal)
    of hnkStrLit: result = initHLValue(tree.strVal)
    of hnkIdent:
      case tree.strVal:
        of "Table": result = newHLTable().initHLValue()
        of "List": result = newHLList().initHLValue()
        else:
          raiseImplementError(tree.strVal)

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
  elif T is HLTable: return val.table
  elif T is HLList: return val.list
  elif T is seq:
    var res: T
    for entry in val.elements:
      res.add entry.get(typeof res[0])

    return res


  else:
    static:
      {.error: "Unhanled type for `get()`, ", $typeof(T).}


genInitHL(5, false)

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
      of hvkAny: result = "any".toMagenta
      of hvkNil: result = "nil".toCyan
      of hvkInt: result = "int".toBlue
      of hvkFloat: result = "float".toMagenta
      of hvkString: result = "string".toYellow
      of hvkBool: result = "bool".toBlue
      of hvkArray: result = &"array[{hlType.elemType}]"
      of hvkList: result = &"list[{hlType.elemType}]"
      of hvkRecord: result = "object"
      of hvkTable: result = &"table[{hlType.keyType}, {hlType.valType}]"
      of hvkProc:
        result &= toRed("proc") & "("
        for idx, arg in pairs(hlType.argTypes):
          if idx > 0:
            result &= ", "

          result &= $arg

        result &= "): " & $hlType.returnType

func `$`*(val: HLValue): string =
  case val.kind:
    of hvkNil: result = toCyan("nil")
    of hvkProc: result = $val.hlType
    of hvkInt: result = toBlue($val.intVal)
    of hvkString: result = toYellow($val.strVal)
    of hvkFloat: result = toMagenta($val.floatVal)
    of hvkBool: result = toBlue($val.boolVal)
    of hvkAny: result = "~" & $val.anyVal
    of hvkArray:
      result = "["
      for idx, elem in pairs(val.elements):
        if idx > 0:
          result &= ", "

        result &= $elem

      result &= "]"


    of hvkList:
      result = "<"
      for idx, elem in pairs(val.elements):
        if idx > 0:
          result &= ", "

        result &= $elem

      result &= ">"

    of hvkTable:
      result = "{"
      for idx, (key, val) in enumerate(pairs(val.table)):
        if idx > 0:
          result &= ", "

          result &= $key & ": " & $val

      result &= "}"

    of hvkRecord:
      raiseImplementKindError(val)

func `$`*(list: HLList): string =
  var
    node = list
    idx = 0

  result = "["
  while not isNil(node):
    if idx > 0:
      result &= " -> "


    if isNil(node.value):
      result &= "no-data"

    else:
      result &= $node.value

    result &= "@" & $idx
    node = node.next
    inc idx

  result &= "]"



func `+`*(a, b: HLValue): HLValue = opAux(a, b, `+`)
func `-`*(a, b: HLValue): HLValue = opAux(a, b, `-`)
func `*`*(a, b: HLValue): HLValue = opAux(a, b, `*`)
func `/`*(a, b: HLValue): HLValue = opAux(a, b, `/`)


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

  if name in table:
    for candidate in table[name]:
      if candidate.matchesForArgs(argTypes):
        return candidate

  raiseImplementError(
    &"Could not find matching overload for {name}({argTypes})")


proc newProcTable*(): HLProcImplTable =
  var d: HLProcImplTable

  template i(arg: untyped): untyped = initHLValue(arg)

  d["+"] = @[
    i(proc(a, b: int): int = a + b)
  ]

  d["print"] = @[
    i(proc(a: HLValue): void = echo a)
  ]

  d["=="] = @[
    i(proc(a, b: HLValue): bool = a == b)
  ]

  d["[]="] = @[
    i(proc(a, b, c: HLValue) = a[b] = c),
    i(proc(t: HLTable, key, val: HLValue) = t[key] = val),
  ]

  d["[]"] = @[
    i(proc(s: seq[HLValue], idx: int): HLValue = s[idx]),
    i(proc(t: HLTable, key: HLValue): HLValue = t[key])
  ]

  d["add"] = @[
    i(proc(list: HLList, value: HLValue) = list.add value)
  ]

  return d



iterator items*(value: HLValue): HLValue =
  for item in value.elements:
    yield item

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

      of hnkSym:
        result &= " " & toGreen(n.symStr) & " ("

        case n.symKind:
          of hskProc: result &= toBlue("proc")
          of hskVar: result &= toBlue("var")

        result &= ") <" & toCyan($n.symType) & ">"

      else:
        if n.len > 0:
          result &= "\n"

        for newIdx, subn in enumerate(n):
          result &= aux(subn, level + 1, idx & newIdx)
          if newIdx < n.len - 1:
            result &= "\n"

  return aux(pnode, 0, @[])
