import hl_types
import hmisc/[base_errors, hdebug_misc]
import std/[options]
import hpprint, hpprint/hpprint_repr

type
  HLStackEvalCtx* = object

  HLStackOpKind = enum
    hsoLoad
    hsoCallFunc
    hsoForIter
    hsoJumpForward
    hsoJumpAbsolute

  HLStackOp = object
    case kind*: HLStackOpKind
      of hsoLoad:
        value*: HLValue

      of hsoCallFunc:
        name*: string
        argc*: int

      else:
        discard


using ctx: var HLStackEvalCtx

proc prettyPrintConverter*(
  op: HLStackOp | HLValue, conf: var PPRintConf, path: ObjPath): ObjTree =
  prettyPrintConverterFields(op, conf, path)

proc pushScope*(ctx) = discard

func initOpCallFunc*(call: HLNode): HLStackOp =
  HLStackOp(kind: hsoCallFunc, name: call[0].strVal, argc: call.len - 1)

func initOpLoadConst*(call: HLNode): HLStackOp =
  HLStackOp(kind: hsoLoad, value: initHLValue(call))

proc compileStack*(tree: HLNode): seq[HLStackOp] =
  case tree.kind:
    of hnkFile, hnkStmtList:
      for node in tree:
        result.add compileStack(node)

    of hnkCall:
      for arg in tree[1 ..^ 1]:
        result.add compileStack(arg)

      result.add initOpCallFunc(tree)

    of hnkInfix:
      result.add compileStack(tree[1])
      result.add compileStack(tree[2])
      result.add initOpCallFunc(tree)

    of hnkIntLit:
      result.add initOpLoadConst(tree)

    else:
      echo treeRepr(tree)
      raiseImplementError("")

proc evalFunc(name: string, args: seq[HLValue]): Option[HLValue] =
  case name:
    of "+": result = some(args[0] + args[1])
    of "-": result = some(args[0] - args[1])
    of "*": result = some(args[0] * args[1])
    of "print":
      echo args[0]

    else:
      raiseImplementError(name)



proc evalStack*(ops: seq[HLStackOp], ctx): HLValue =
  var idx = 0
  var stack: seq[HLValue]
  while idx < ops.len:
    let op = ops[idx]
    case op.kind:
      of hsoLoad:
        stack.add op.value

      of hsoCallFunc:
        var args: seq[HLValue]
        for _ in 0 ..< op.argc:
          args.add stack.pop()

        let res = evalFunc(op.name, args)
        if res.isSome():
          stack.add res.get()

      else:
        discard

    inc idx
