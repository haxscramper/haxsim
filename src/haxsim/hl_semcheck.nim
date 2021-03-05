import std/[tables, options]
import hmisc/base_errors
import hl_types, hl_parser

type
  HLSemContext* = object
    symbolTable: seq[Table[string, HLType]]
    procTable*: HLProcImplTable

using ctx: var HLSemContext

proc `[]`(ctx; name: string): HLType =
  for scope in ctx.symbolTable:
    if name in scope:
      return scope[name]

  raiseImplementError(name)

proc `[]=`(ctx; name: string, symType: HLType) =
  ctx.symbolTable[^1][name] = symType

proc pushScope*(ctx) = ctx.symbolTable.add initTable[string, HLType]()
proc popScope*(ctx) = discard ctx.symbolTable.pop


proc typeOfAst(ctx; node: HLNode): HLType

proc resolveOverload(ctx; node: HLNode): HLValue =
  var args: seq[HLType]
  for arg in node[1..^1]:
    args.add ctx.typeOfAst(arg)

  ctx.procTable.resolveOverloadedCall(node[0].strVal, args)

proc typeOfAst(ctx; node: HLNode): HLType =
  case node.kind:
    of hnkIdent: result = ctx[node.strVal]
    of hnkIntLit: result = initHLType(int)
    of hnkStrLit: result = initHLType(string)
    of hnkSym: result = node.symType
    of hnkBracket:
      var elemTypes: seq[HLType]
      for elem in node:
        elemTypes.add ctx.typeOfAst(elem)

      result = initHLType(hvkArray, @[elemTypes[0]])

    of hnkCall, hnkInfix:
      result = ctx.resolveOverload(node).hlType

    else:

      raiseImplementKindError(node)

proc newSymNode*(node: HLNode, semType: HLType): HLNode =
  HLNode(symStr: node.strVal, symType: semType, kind: hnkSym)

proc updateTypes*(node: var HLNode, ctx) =

  case node.kind:
    of hnkFile, hnkStmtList, hnkIfStmt:
      for subnode in mitems(node):
        updateTypes(subnode, ctx)

    of hnkElifBranch, hnkElseBranch:
      ctx.pushScope()

      for subnode in mitems(node):
        updateTypes(subnode, ctx)

      ctx.popScope()

    of hnkSym, hnkStrLit, hnkIntLit:
      discard

    of hnkIdent:
      node = newSymNode(node, typeOfAst(ctx, node))

    of hnkCall, hnkInfix:
      let impl = resolveOverload(ctx, node)
      node[0] = HLNode(
        kind: hnkSym,
        symStr: node[0].strVal,
        symType: impl.hlType,
        symImpl: some impl
      )

      for arg in mitems(node):
        updateTypes(arg, ctx)

    of hnkForStmt:
      ctx.pushScope()

      node[0] = newSymNode(node[0], typeOfAst(ctx, node[1]).elemType)
      ctx[node[0].symStr] = typeOfAst(ctx, node[0])
      updateTypes(node[2], ctx)

      ctx.popScope()

    of hnkVarDecl:
      node[0] = newSymNode(node[0], typeOfAst(ctx, node[1]))
      ctx[node[0].symStr] = typeOfAst(ctx, node[0])

    else:
      echo treeRepr(node)
      raiseImplementKindError(node)
