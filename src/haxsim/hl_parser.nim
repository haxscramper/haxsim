import ./hl_types, ./hl_error
export hl_types

import std/[strformat]
import hmisc/[base_errors, hdebug_misc]
import hpprint

type
  HLParser* = object
    pos*: int
    toks*: seq[HLToken]
    baseStr*: string

using
  par: var HLParser

proc next(par) = inc par.pos
proc finished(par; offset: int = 0): bool =
  (par.pos + offset) >= par.toks.len

proc at(par; tokKind: HLTokenKind): bool =
  not par.finished() and par.toks[par.pos].kind == tokKind

proc at(par; tokKinds: set[HLTokenKind]): bool =
  not par.finished() and par.toks[par.pos].kind in tokKinds

proc ahead(par; offset: int = 5): seq[HLToken] =
  par.toks[par.pos ..< min(par.pos + offset, par.toks.len)]

proc at(par; offset: int): HLToken =
  par.toks[par.pos + offset]

proc at(par; offset: int, kind: HLTokenKind): bool =
  not par.finished(offset) and par.at(offset).kind == kind

proc at(par): HLToken = par.toks[par.pos]
proc pop(par): HLToken =
  result = par.at()
  par.next()

proc message(par; message: string) =
  par.baseStr.errorAt(par.at().extent, message)

proc skip(par; expected: HLTokenKind | set[HLTokenKind]) =
  if par.at(expected):
    par.next()

  else:
    par.message(&"Expected {expected}, but parser is at {par.at()}")
    raiseImplementError("")



proc parseIdent(par): HLNode = newTree(hnkIdent, par.pop())
proc parseStmtList(par): HLNode
proc parseFieldExpr(par): HLNode =
  let obj = par.parseIdent()
  par.skip(htkDot)
  let fld = par.parseIdent()
  result = newTree(hnkFieldExpr, obj, fld)


proc parseExpr(par): HLNode

proc getInfix(par): seq[HLNode] =
  var cnt = 1
  par.skip({htkLPar, htkLBrack})
  while cnt > 0:
    case par.at().kind:
      of htkRPar, htkRBrack:
        dec cnt
        par.next()

      of htkCmp, htkStar, htkMinus, htkPlus:
        result.add newTree(hnkIdent, par.pop())

      else:
        result.add parseExpr(par)

proc precLevel(node: HLNode): int =
  if node.kind == hnkIdent:
    case node.strVal:
      of "+": 8
      of "-": 8
      of "*": 9
      of "/": 9
      of "==": 5
      else: 0

  else:
    0

proc foldExprAux(tokens: seq[HLNode], pos: var int, prec: int = 0): HLNode

proc foldInfix(
    left: HLNode, token: HLNode, tokens: seq[HLNode], pos: var int, prec: int
  ): HLNode =

  if token.kind in {hnkIdent} and token.strVal in ["+", "-", "*", "/", "=="]:
    result = newTree(hnkInfix, token, left, foldExprAux(tokens, pos, precLevel(token)))

proc foldExprAux(tokens: seq[HLNode], pos: var int, prec: int = 0): HLNode =
  result = tokens[pos]
  inc(pos)
  while pos < tokens.len and prec < tokens[pos].precLevel():
    let token = tokens[pos]
    if pos >= tokens.len:
      break

    inc(pos)
    result = foldInfix(result, token, tokens, pos, prec)


proc parseExpr(par): HLNode =
  case par.at().kind:
    of htkIntLit: result = newTree(hnkIntLit, par.pop())
    of htkIdent: result = newTree(hnkIdent, par.pop())
    of htkStrLit: result = newTree(hnkStrLit, par.pop())
    of htkLBrack:
      result = newTree(hnkBracket)
      par.skip(htkLBrack)
      while not par.at(htkRBrack):
        result.add parseExpr(par)
        if not par.at(htkRBrack):
          par.skip(htkComma)

      par.skip(htkRBrack)

    of htkLPar:
      var pos: int = 0
      result = foldExprAux(getInfix(par), pos)

    else:
      raiseImplementError($par.at().kind)

proc parseVarDecl(par): HLNode =
  result = newTree(hnkVarDecl)
  par.skip(htkVarKwd)
  result.add parseIdent(par)
  par.skip(htkEq)
  result.add parseExpr(par)
  par.skip(htkSemicolon)
  # while not par.at({htkSemicolon, htkEq, htkComma}):
  #   buf.add parseExpr(par)

  # var initExpr = newEmptyCNode()
  # if par.at(htkEq):
  #   par.skip(htkEq)
  #   initExpr.add par.parseExpr()

  # let id = newTree(hnkIdent, buf.pop)

proc parseCallStmt(par): HLNode =
  result = newTree(hnkCall, newTree(hnkIdent, par.pop()))
  var pos: int = 0
  result.add foldExprAux(getInfix(par), pos)
  par.skip(htkSemicolon)

proc parseForStmt(par): HLNode =
  result = newTree(hnkForStmt)
  par.skip(htkForKwd)
  result.add par.parseIdent()
  par.skip(htkInKwd)
  result.add par.parseExpr()
  par.skip(htkLCurly)
  result.add parseStmtList(par)
  par.skip(htkRCurly)

proc parseIfStmt(par): HLNode =
  result = newTree(hnkIfStmt)
  par.skip(htkIfKwd)
  result.add newTree(hnkElifBranch, parseExpr(par), parseStmtList(par))

  # while par.at(htkElseKwd):
  #   par.skip(htkElifKwd)
  #   result.add newTree(hnkElifBranch, parseStmtList(par))

  if par.at(htkElseKwd):
    par.skip(htkElseKwd)
    result.add newTree(hnkElseBranch, parseStmtList(par))

proc parseArrayAsgn(par): HLNode =
  result = newTree(hnkCall)
  result.add newIdentHLNode("[]=")
  result.add par.parseIdent()
  result.add foldExprAux(par.getInfix(), (var tmp: int; tmp))
  par.skip(htkEq)
  result.add par.parseExpr()

proc parseStmtList(par): HLNode =

  if par.at(htkLCurly):
    par.skip(htkLCurly)
    result = parseStmtList(par)
    par.skip(htkRCurly)

  else:
    result = newTree(hnkStmtList)
    while not par.at(htkRCurly) and not par.finished():
      case par.at().kind:
        of htkForKwd: result.add parseForStmt(par)
        of htkIfKwd: result.add parseIfStmt(par)
        of htkVarKwd: result.add parseVarDecl(par)
        of htkIdent:
          if par.at(+1, htkLPar):
            result.add parseCallStmt(par)
            # par.skip(htkSemicolon)

          elif par.at(+1, htkDot):
            result.add parseFieldExpr(par)
            par.skip(htkSemicolon)

          elif par.at(+1, htkLBrack):
            result.add parseArrayAsgn(par)
            par.skip(htkSemicolon)

          else:
            errorAt(
              par.baseStr, par.at(+1).extent,
              &"""Unexpected token for variable declaration
Found after {par.at().lispRepr(false)}
"""
            )

            raiseImplementError(par.at(+1).lispRepr())

        else:
          par.message(&"Kind {par.at().kind}")
          raiseImplementError(&"Kind {par.at().kind}")


proc parseFile(par): HLNode =
  newTree(hnkFile, parseStmtList(par))

proc parse*(toks: seq[HLToken], baseStr: string): HLNode =
  var pars = HLParser(toks: toks, baseStr: baseStr)
  return parseFile(pars)
