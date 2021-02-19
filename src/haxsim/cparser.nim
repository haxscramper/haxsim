import ctypes
export ctypes

import std/[strformat]
import hmisc/[base_errors]

type
  CParser* = object
    pos: int
    toks: seq[CToken]

using
  par: var CParser

proc next(par) = inc par.pos
proc at(par; tokKind: CTokenKind): bool = par.toks[par.pos].kind == tokKind
proc at(par; tokKinds: set[CTokenKind]): bool =
  par.toks[par.pos].kind in tokKinds

proc at(par): CToken = par.toks[par.pos]
proc pop(par): CToken =
  result = par.at()
  par.next()

proc skip(par; expected: CTokenKind) =
  if par.at(expected):
    par.next()

  else:
    raiseImplementError(
      &"Expected {expected}, but parser is at {par.at()}")


proc parseStmtList(par): CNode
proc parseExpr(par): CNode =
  case par.at().kind:
    of ctkIntLit:
      par.next()
      result = newTree(cnkIntLit)

    else:
      raiseImplementError("")

proc parseVarDecl(par): CNode =
  result = newTree(cnkVarDecl)
  var buf: seq[CToken]
  while not par.at({ctkSemicolon, ctkEq, ctkComma}):
    buf.add par.pop()

  var initExpr = newEmptyCNode()
  if par.at(ctkEq):
    par.skip(ctkEq)
    initExpr.add par.parseExpr()

  let id = newTree(cnkIdent, buf.pop)




proc parseForStmt(par): CNode =
  result = newTree(cnkForStmt)
  par.skip(ctkForKwd)
  par.skip(ctkLPar)

  for exprIdx in [0, 1, 2]:
    if par.at(ctkSemicolon):
      result.add newEmptyCNode()

    else:
      case exprIdx:
        of 0: result.add parseVarDecl(par)
        else: result.add parseExpr(par)

    if exprIdx != 2:
      par.skip(ctkSemicolon)

  par.skip(ctkRPar)
  par.skip(ctkLCurly)
  result.add parseStmtList(par)
  par.skip(ctkRCurly)

proc parseStmtList(par): CNode =
  result = newTree(cnkStmtList)

  case par.at().kind:
    of ctkForKwd: result.add parseForStmt(par)

    else:
      raiseImplementError(&"Kind {par.at().kind} {instantiationInfo()} ]#")


proc parseFile(par): CNode =
  newTree(cnkFile, parseStmtList(par))

proc parse*(toks: seq[CToken]): CNode =
  var pars = CParser(toks: toks)
  return parseFile(pars)
