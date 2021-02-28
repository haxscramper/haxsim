import ctypes
import std/[tables, strformat]
import hmisc/base_errors

type
  CEvalCtx* = object
    scope: seq[Table[string, CValue]]

proc pushScope*(ctx: var CEvalCtx) =
  ctx.scope.add initTable[string, CValue]()

proc popScope*(ctx: var CEvalCtx) =
  discard ctx.scope.pop

proc `[]=`(ctx: var CEvalCtx; varname: string, value: CValue) =
  ctx.scope[^1][varname] = value

proc `[]`(ctx: CEvalCtx; varname: string): CValue =
  for scope in ctx.scope:
    if varname in scope:
      return scope[varname]

  raiseImplementError("")

proc eval*(tree: CNode, ctx: var CEvalCtx): CValue =
  case tree.kind:
    of cnkFile, cnkStmtList:
      for node in tree:
        discard eval(node, ctx)

    of cnkForStmt:
      let expr = eval(tree[1], ctx)
      for value in expr:
        ctx.pushScope()
        ctx[tree[0].strVal] = value
        discard eval(tree[2], ctx)
        ctx.popScope()

    of cnkBracket:
      result = CValue(kind: cvkArray)
      for item in tree:
        result.elements.add eval(item, ctx)

    of cnkIntLit:
      result = CValue(kind: cvkInt, intVal: tree.intVal)

    of cnkCall:
      let name = tree[0].strVal
      var args: seq[CValue]
      for arg in tree[1 .. ^1]:
        args.add eval(arg, ctx)

      echo name, $args

    of cnkIdent:
      result = ctx[tree.strVal]

    else:
      raiseImplementError(&"Kind {tree.kind}" & treeRepr(tree))
