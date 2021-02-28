import hl_types
export hl_types

import std/[strformat]
import hmisc/[base_errors, hdebug_misc]

type
  HLParser* = object
    pos: int
    toks: seq[HLToken]

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

proc skip(par; expected: HLTokenKind) =
  if par.at(expected):
    par.next()

  else:
    raiseImplementError(
      &"Expected {expected}, but parser is at {par.at()}")

proc parseIdent(par): HLNode = newTree(hnkIdent, par.pop())
proc parseStmtList(par): HLNode
proc parseFieldExpr(par): HLNode =
  let obj = par.parseIdent()
  par.skip(htkDot)
  let fld = par.parseIdent()
  result = newTree(hnkFieldExpr, obj, fld)


proc parseExpr(par): HLNode =
  case par.at().kind:
    of htkIntLit:
      result = newTree(hnkIntLit, par.pop())

    of htkIdent:
      result = newTree(hnkIdent, par.pop())

    of htkStrLit:
      result = newTree(hnkStrLit, par.pop())

    of htkLBrack:
      result = newTree(hnkBracket)
      par.skip(htkLBrack)
      while not par.at(htkRBrack):
        result.add parseExpr(par)
        if not par.at(htkRBrack):
          par.skip(htkComma)

      par.skip(htkRBrack)

    else:
      raiseImplementError($par.at().kind)

proc parseVarDecl(par): HLNode =
  result = newTree(hnkVarDecl)
  var buf: seq[HLToken]
  while not par.at({htkSemicolon, htkEq, htkComma}):
    buf.add par.pop()

  var initExpr = newEmptyCNode()
  if par.at(htkEq):
    par.skip(htkEq)
    initExpr.add par.parseExpr()

  let id = newTree(hnkIdent, buf.pop)


proc parseCallStmt(par): HLNode =
  result = newTree(hnkCall, newTree(hnkIdent, par.pop()))
  par.skip(htkLPar)
  while not par.at(htkRPar):
    result.add parseExpr(par)
    if par.at(htkComma):
      par.skip(htkComma)

  par.skip(htkRPar)
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

proc parseStmtList(par): HLNode =
  result = newTree(hnkStmtList)

  while not par.at(htkRCurly) and not par.finished():
    case par.at().kind:
      of htkForKwd: result.add parseForStmt(par)
      of htkIdent:
        if par.at(+1, htkLPar):
          result.add parseCallStmt(par)
          # par.skip(htkSemicolon)

        elif par.at(+1, htkIdent):
          result.add parseVarDecl(par)
          par.skip(htkSemicolon)

        elif par.at(+1, htkDot):
          result.add parseFieldExpr(par)
          par.skip(htkSemicolon)

        else:
          raiseImplementError("")

      else:
        raiseImplementError(&"Kind {par.at().kind} {instantiationInfo()} ]#")


proc parseFile(par): HLNode =
  newTree(hnkFile, parseStmtList(par))

proc parse*(toks: seq[HLToken]): HLNode =
  var pars = HLParser(toks: toks)
  return parseFile(pars)
