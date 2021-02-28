import hl_types

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
      else:
        discard


using ctx: var HLStackEvalCtx

proc pushScope*(ctx) = discard


proc toStackOps(tree: HLNode): seq[HLStackOp] =
  discard

proc evalStack*(tree: HLNode, ctx): HLValue =
  let ops = toStackOps(tree)

  var idx = 0
  while idx < ops.len:
    case ops[idx].kind:
      else:
        discard
