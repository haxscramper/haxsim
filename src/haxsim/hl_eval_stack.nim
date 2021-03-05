import hl_types
import hmisc/[base_errors, hdebug_misc]
import std/[
  options, tables, macros, strformat,
  strutils, algorithm, sequtils
]
import hpprint, hpprint/hpprint_repr
import hmisc/types/colorstring
import fusion/matching

type
  HLStackEvalCtx* = object
    names*: Table[string, HLValue]
    procImpls*: HLProcImplTable

  HLStackOpKind = enum
    hsoLoad
    hsoCallFunc
    hsoForIter
    hsoJump
    hsoIfNotJump
    hsoPopTop
    hsoGetIter
    hsoStoreName
    hsoLoadName

  HLStackOp = object
    annotation*: string
    case kind*: HLStackOpKind
      of hsoLoad:
        value*: HLValue

      of hsoCallFunc:
        argc*: int

      of hsoForIter, hsoJump, hsoIfNotJump:
        jumpOffset*: int

      of hsoStoreName, hsoLoadName:
        varName*: string

      else:
        discard

using ctx: var HLStackEvalCtx

func `$`(op: HLStackOp): string =
  result &= alignLeft(($op.kind)[3 ..^ 1], 10)
  case op.kind:
    of hsoLoad:
      result &= " " & $op.value

    of hsoCallFunc:
      result &= " " & toBlue($op.argc)

    of hsoJump, hsoIfNotJump:
      result &= " " & toGreen($op.jumpOffset) & " >>"

    of hsoStoreName, hsoLoadName:
      result &= " " & $op.varName

    else:
      discard

func `$`(ops: seq[HLStackOp]): string =
  var targets: Table[int, seq[int]]

  var opw: int
  for idx, op in pairs(ops):
    if op.kind in {hsoForIter, hsoJump, hsoIfNotJump}:
      targets.mgetOrPut(idx - op.jumpOffset, @[]).add idx
    opw = max(opw, termLen($op))

  var buf: seq[string]
  for idx, op in pairs(ops):
    if idx in targets:
      buf.add toRed(">>") & &" {idx:<4} {termAlignLeft($op, opw)} from {toRed($targets[idx])}"

    else:
      buf.add &"   {idx:<4} {op}"


  result = buf.join("\n")

proc prettyPrintConverter*(
  op: HLStackOp | HLValue, conf: var PPRintConf, path: ObjPath): ObjTree =
  prettyPrintConverterFields(op, conf, path)

proc pushScope*(ctx) = discard

func initOpCallFunc*(call: HLNode): HLStackOp =
  HLStackOp(kind: hsoCallFunc, argc: call.len - 1)

func initOpLoadConst*(call: HLNode): HLStackOp =
  HLStackOp(kind: hsoLoad, value: initHLValue(call))

macro initOp*(kind: HLStackOpKind, args: varargs[untyped]): HLStackOp =
  result = newStmtList()
  let res = genSym(nskVar)
  result.add quote do:
    var `res` = HLStackOp(kind: `kind`)

  for arg in args:
    ExprEqExpr[@fldName, @value] := arg
    result.add quote do:
      `res`.`fldname` = `value`

  result.add res

func msg*(op: sink HLStackOp, msg: string): HLStackOp =
  result = op
  result.annotation = msg

proc compileStack*(tree: HLNode): seq[HLStackOp] =
  case tree.kind:
    of hnkFile, hnkStmtList:
      for node in tree:
        result.add compileStack(node)

    of hnkCall, hnkInfix:
      for arg in tree:
        result.add compileStack(arg)

      result.add initOpCallFunc(tree)

    # of hnkInfix:
    #   result.add compileStack(tree[1])
    #   result.add compileStack(tree[2])
    #   result.add initOpCallFunc(tree)

    of hnkIntLit, hnkStrLit:
      result.add initOpLoadConst(tree)

    of hnkIdent:
      result.add initOp(hsoLoadName, varName = tree.strVal)

    of hnkForStmt:
      result.add compileStack(tree[1])
      let forPos = result.len
      result.add initOp(hsoForIter).msg("For loop target")
      result.add initOp(hsoStoreName, varName = tree[0].getStrVal())
        .msg("Store iteration variable value")

      result.add compileStack(tree[2])
      result.add initOp(hsoPopTop)
        .msg("Pop iteration variable from stack")

      result.add initOp(hsoJump, jumpOffset = forPos - result.len)
        .msg("Next iteration jump")

      result[forPos].jumpOffset = result.len

    of hnkBracket:
      result.add initOp(hsoLoad, value = initHLValue(tree))

    of hnkVarDecl:
      result.add compileStack(tree[1])
      result.add initOp(hsoStoreName, varName = tree[0].getStrVal())

    of hnkSym:
      if tree.symImpl.isSome():
        result.add initOp(hsoLoad, value = tree.symImpl.get())

      else:
        result.add initOp(hsoLoadName, varName = tree.getStrVal())

    of hnkIfStmt:
      var falseJump = -1
      var endJumps: seq[int]
      for branch in tree:
        if falseJump > 0:
          result[falseJump].jumpOffset = result.len - falseJump

        if branch.kind == hnkElifBranch:
          result.add compileStack(branch[0])
          falseJump = result.len
          result.add initOp(hsoIfNotJump)
            .msg("Elif branch condition jump")

          result.add compileStack(branch[1])
          endJumps.add result.len
          result.add initOp(hsoJump)
            .msg("Successful elif branch end")

        else:
          result.add compileStack(branch[0])

      for jump in endJumps:
        result[jump].jumpOffset = result.len - jump

    else:
      echo treeRepr(tree)
      raiseImplementError($tree.kind)

proc evalFunc(ctx; name: string, args: seq[HLValue]): Option[HLValue] =
  let impl = ctx.procImpls.resolveOverloadedCall(name, args.mapIt(it.hlType))
  result = impl.impl(args)
  # case name:
  #   of "+": result = some(args[0] + args[1])
  #   of "-": result = some(args[0] - args[1])
  #   of "*": result = some(args[0] * args[1])
  #   of "==": result = some(initHLValue(args[0] == args[1]))
  #   of "[]=":
  #     args[0][args[1]] = args[2]

  #   of "print":
  #     echo "Called print ", args[0]

  #   else:
  #     raiseImplementError("Unimplemented function " & name)


template top[T](s: seq[T]): untyped = s[^1]

import hmisc/hasts/graphviz_ast

proc dotRepr(ops: seq[HLStackOp]): DotGraph =
  result = makeDotGraph()
  # result.splines = spsOrtho
  for idx, op in pairs(ops):
    result.add makeColoredDotNode(
      idx, &"#{idx} {op}\n[{op.annotation}]", cellAttrs = {"border": "0"})
    if op.kind != hsoJump:
      result.add makeDotEdge(idx, idx + 1, "next")

    case op.kind:
      of hsoJump, hsoIfNotJump, hsoForIter:
        result.add makeDotEdge(idx, idx + op.jumpOffset, "jump")

      else:
        discard


proc newStackEvalCtx*(): HLStackEvalCtx =
  result.procImpls = newProcTable()

proc evalStack*(ops: seq[HLStackOp], ctx): HLValue =
  var idx = 0
  # pprint(ops, ignore = @["**/annotation*"]) # FIXME `ignore` does not work,
  # # but this is most certainly a compound bug - I don't set path correctly
  # # **and** it is not fully checked somewhere like `prettyPrintConverter`
  echo ops
  var stack: seq[HLValue]
  ops.dotRepr().toPng("/tmp/graph.png")
  while idx < ops.len:
    let op = ops[idx]
    case op.kind:
      of hsoLoad:
        stack.add op.value

        inc idx

      of hsoCallFunc:
        var args: seq[HLValue]
        for _ in 0 ..< op.argc:
          args.add stack.pop()

        let impl = stack.pop()

        let res = impl.impl(args.reversed())
        if res.isSome():
          stack.add res.get()

        inc idx

      of hsoForIter:
        let val = stack.top().nextValue()
        if val.isSome():
          stack.add val.get()

          inc idx

        else:
          idx += op.jumpOffset

      of hsoStoreName:
        ctx.names[op.varName] = stack.top()

        inc idx

      of hsoLoadName:
        stack.add ctx.names[op.varName]

        inc idx

      of hsoPopTop:
        discard stack.pop()

        inc idx

      of hsoJump:
        idx += op.jumpOffset

      of hsoIfNotJump:
        let val = stack.pop()
        if val.boolVal == false:
          idx += op.jumpOffset

        else:
          inc idx

      else:
        raiseImplementError(&"Kind {op.kind}")
