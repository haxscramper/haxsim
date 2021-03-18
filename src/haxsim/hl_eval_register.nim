import ./hl_types

const regCount = 32

type
  HlReg* = object
    value*: HlValue

  HlRegOpKind = enum
    hrkAdd
    hrkCall
    hrkMove

  HlRegOp* = object
    kind*: HlRegOpKind
    rgA*: uint8
    rgB*: uint8
    rgC*: uint8

  HlTernOp* = object
    # case kind*: HlRegOpKind
    #   of hrkMove:

  HlRegVm = object
    registers: array[regCount, HlReg]

  HlRegisterEvalCtx* = object
    constants*: seq[HlValue]


proc compileRegister*(tree: HLNode): (seq[HLRegOp], HlRegisterEvalCtx) =
  discard

proc evalRegister*(code: seq[HlRegOp], ctx: HlRegisterEvalCtx) =
  discard
