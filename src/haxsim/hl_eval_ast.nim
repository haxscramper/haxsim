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

    of hnkIntLit: result = initHLValue(tree.intVal)
    of hnkStrLit: result = initHLValue(tree.strVal)

    of hnkCall:
      let name = tree[0].strVal
      var args: seq[HLValue]
      for arg in tree[1 .. ^1]:
        args.add evalAst(arg, ctx)

      echo name, " ", $args

    of hnkIdent:
      result = ctx[tree.strVal]

    of hnkIfStmt:
      for branch in tree:
        if branch.kind == hnkElifBranch:
          let val = evalAst(branch[0], ctx)
          if val.boolVal == true:
            discard evalAst(branch[1], ctx)
            break

        else:
          discard evalAst(branch[0], ctx)


    of hnkInfix:
      let lhs = evalAst(tree[1], ctx)
      let rhs = evalAst(tree[2], ctx)
      case tree[0].strVal:
        of "==": result = initHLValue(lhs == rhs)
        of "+": result = lhs + rhs
        of "-": result = lhs - rhs
        of "*": result = lhs * rhs
        else:
          raiseImplementError(&"Unhandled infix operator: {tree[0].strVal}")

    else:
      raiseImplementError(&"Kind {tree.kind} " & treeRepr(tree))
