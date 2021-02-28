import hl_types
import std/[tables, strformat]
import hmisc/base_errors

type
  HLAstEvalCtx* = object
    scope: seq[Table[string, HLValue]]

using ctx: var HLAstEvalCtx

proc pushScope*(ctx) =
  ctx.scope.add initTable[string, HLValue]()

proc popScope*(ctx) =
  discard ctx.scope.pop

proc `[]=`(ctx; varname: string, value: HLValue) =
  ctx.scope[^1][varname] = value

proc `[]`(ctx; varname: string): HLValue =
  for scope in ctx.scope:
    if varname in scope:
      return scope[varname]

  raiseImplementError("")

proc evalAst*(tree: HLNode, ctx): HLValue =
  case tree.kind:
    of hnkFile, hnkStmtList:
      for node in tree:
        discard evalAst(node, ctx)

    of hnkForStmt:
      let expr = evalAst(tree[1], ctx)
      for value in expr:
        ctx.pushScope()
        ctx[tree[0].strVal] = value
        discard evalAst(tree[2], ctx)
        ctx.popScope()

    of hnkBracket:
      result = HLValue(kind: hvkArray)
      for item in tree:
        result.elements.add evalAst(item, ctx)

    of hnkIntLit:
      result = HLValue(kind: hvkInt, intVal: tree.intVal)

    of hnkCall:
      let name = tree[0].strVal
      var args: seq[HLValue]
      for arg in tree[1 .. ^1]:
        args.add evalAst(arg, ctx)

      echo name, $args

    of hnkIdent:
      result = ctx[tree.strVal]

    else:
      raiseImplementError(&"Kind {tree.kind}" & treeRepr(tree))
