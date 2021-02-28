import ctypes
export ctypes

import std/[strformat]
import hmisc/[base_errors, hdebug_misc]

type
  CParser* = object
    pos: int
    toks: seq[CToken]

using
  par: var CParser

proc next(par) = inc par.pos
proc finished(par; offset: int = 0): bool =
  (par.pos + offset) >= par.toks.len

proc at(par; tokKind: CTokenKind): bool =
  not par.finished() and par.toks[par.pos].kind == tokKind

proc at(par; tokKinds: set[CTokenKind]): bool =
  not par.finished() and par.toks[par.pos].kind in tokKinds

proc ahead(par; offset: int = 5): seq[CToken] =
  par.toks[par.pos ..< min(par.pos + offset, par.toks.len)]

proc at(par; offset: int): CToken =
  par.toks[par.pos + offset]

proc at(par; offset: int, kind: CTokenKind): bool =
  not par.finished(offset) and par.at(offset).kind == kind

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

proc parseIdent(par): CNode = newTree(cnkIdent, par.pop())
proc parseStmtList(par): CNode
proc parseFieldExpr(par): CNode =
  let obj = par.parseIdent()
  par.skip(ctkDot)
  let fld = par.parseIdent()
  result = newTree(cnkFieldExpr, obj, fld)


proc parseExpr(par): CNode =
  case par.at().kind:
    of ctkIntLit:
      result = newTree(cnkIntLit, par.pop())

    of ctkIdent:
      result = newTree(cnkIdent, par.pop())

    of ctkStrLit:
      result = newTree(cnkStrLit, par.pop())

    of ctkLBrack:
      result = newTree(cnkBracket)
      par.skip(ctkLBrack)
      while not par.at(ctkRBrack):
        result.add parseExpr(par)
        if not par.at(ctkRBrack):
          par.skip(ctkComma)

      par.skip(ctkRBrack)

    else:
      raiseImplementError($par.at().kind)

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


proc parseCallStmt(par): CNode =
  result = newTree(cnkCall, newTree(cnkIdent, par.pop()))
  par.skip(ctkLPar)
  while not par.at(ctkRPar):
    result.add parseExpr(par)
    if par.at(ctkComma):
      par.skip(ctkComma)

  par.skip(ctkRPar)
  par.skip(ctkSemicolon)

proc parseForStmt(par): CNode =
  result = newTree(cnkForStmt)
  par.skip(ctkForKwd)
  result.add par.parseIdent()
  par.skip(ctkInKwd)
  result.add par.parseExpr()
  par.skip(ctkLCurly)
  result.add parseStmtList(par)
  par.skip(ctkRCurly)

proc parseStmtList(par): CNode =
  result = newTree(cnkStmtList)

  while not par.at(ctkRCurly) and not par.finished():
    case par.at().kind:
      of ctkForKwd: result.add parseForStmt(par)
      of ctkIdent:
        if par.at(+1, ctkLPar):
          result.add parseCallStmt(par)
          # par.skip(ctkSemicolon)

        elif par.at(+1, ctkIdent):
          result.add parseVarDecl(par)
          par.skip(ctkSemicolon)

        elif par.at(+1, ctkDot):
          result.add parseFieldExpr(par)
          par.skip(ctkSemicolon)

        else:
          raiseImplementError("")

      else:
        raiseImplementError(&"Kind {par.at().kind} {instantiationInfo()} ]#")


proc parseFile(par): CNode =
  newTree(cnkFile, parseStmtList(par))

proc parse*(toks: seq[CToken]): CNode =
  var pars = CParser(toks: toks)
  return parseFile(pars)
