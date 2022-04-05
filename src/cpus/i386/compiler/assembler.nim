import instruction/[opcodes, syntaxes]
import common
import hmisc/core/all
import std/[options, strutils, sequtils, math, enumutils, sets]
import hmisc/other/hpprint
import hmisc/algo/[hlex_base, lexcast, clformat]

type
  InstrOperandKind* = enum
    iokReg8
    iokReg16
    iokReg32
    iokImmediate

  InstrOperandTarget* = object
    case kind*: InstrOperandKind
      of iokReg8:
        reg8*: Reg8T

      of iokReg16:
        reg16*: Reg16T

      of iokReg32:
        reg32*: Reg32T

      of iokImmediate:
        value*: int

  InstrOperand* = object
    text*: string
    target*: InstrOperandTarget
    dataKind*: Option[OpDataKind] # made optional for the sake of parsing
    # algorithm that does post-correction after elements are parsed. If
    # previous one is not known, but new one *is* known, then correction
    # will be made.
    offset*: Option[int]

  InstrDesc* = object
    mnemonic*: ICodeMnemonic
    opcode*: ICode
    operands*: array[4, Option[InstrOperand]]


proc matchingTarget(target: InstrOperandTarget, addrKind: OpAddrKind): bool =
  if addrKind in { opAddrReg, opAddrRegMem } and
     target.kind in { iokReg8, iokReg16, iokReg32 }:
    result = true

  elif addrKind in { opAddrImm } and target.kind in { iokImmediate }:
    result = true


func dedupOpcodes*(code: ICode): ICode =
  case code:
    # https://stackoverflow.com/questions/44335265/difference-between-mov-r-m8-r8-and-mov-r8-r-m8
    of opMOV_Reg_B_RegMem_B: opMOV_RegMem_B_Reg_B
    else: code


proc selectOpcode*(instr: var InstrDesc) =
  var match: HashSet[ICode]
  let giveLen = instr.operands.mapIt(tern(it.isSome(), 1, 0)).sum()
  echov instr.mnemonic.symbolName()
  for op in instr.mnemonic.getOpcodes():
    let args = op.getUsedOperands()
    let argsLen = args.mapIt(tern(it.isSome(), 1, 0)).sum()
    if giveLen == argsLen:
      var allMatch = true
      for idx in 0 ..< giveLen:
        let (addrKind, dataKind) = args[idx].get()
        let operand = instr.operands[idx].get()
        let dk = operand.dataKind.get()
        if not(
          dk == dataKind or
          (dk == opData16_32 and dataKind in {opData16, opData32})
        ):
          allMatch = false

        elif not matchingTarget(operand.target, addrKind):
          allMatch = false

      if allMatch:
        match.incl op.dedupOpcodes()

  assert match.len == 1, $match
  instr.opcode = toSeq(match)[0]

proc compileInstr*(instr: InstrDesc): seq[uint8] =
  let opc = instr.opcode
  if opc.isExtended():
    echov opc.opIdx()
    result.add cast[array[2, uint8]](opc.opIdx())

  else:
    result.add opc.opIdx().uint8()


proc enumNames[E: enum](): seq[string] =
  for val in low(E) .. high(E):
    result.add $val

proc parseOperand*(str: var PosStr): InstrOperand =
  var dat: Option[OpDataKind]
  var adr: OpAddrKind
  if str.trySkip("BYTE"):
    dat = some opData8

  elif str.trySkip("WORD"):
    dat = some opData16

  elif str.trySkip("DWORD"):
    dat = some opData32

  str.space()

  var id: string
  if str['[']:
    str.skip('[')
    id = str.popIdent()
    str.space()
    if str['+']:
      str.skip('+')
      str.space()
      result.offset = some lexcast[int](str.popDigit())

    str.skip(']')

  else:
    id = str.popIdent()

  type T = InstrOperandTarget
  var tar: T
  if id in asConst(enumNames[Reg8T]()):
    tar = T(kind: iokReg8, reg8: parseEnum[Reg8T](id))
    if dat.isNone(): dat = some opData8

  elif id in asConst(enumNames[Reg16T]()):
    tar = T(kind: iokReg16, reg16: parseEnum[Reg16T](id))
    if dat.isNone(): dat = some opData16

  elif id in asConst(enumNames[Reg32T]()):
    tar = T(kind: iokReg32, reg32: parseEnum[Reg32T](id))
    if dat.isNone(): dat = some opData32

  else:
    tar = T(kind: iokImmediate, value: lexcast[int](id))

  result.target = tar
  result.dataKind = dat

proc parseInstr*(text: string): InstrDesc =
  var str = initPosStr(text.toUpperAscii())
  result.mnemonic = parseEnum[ICodeMnemonic](str.popIdent().toUpperAscii())
  str.space()
  var idx = 0
  while ?str:
    result.operands[idx] = some parseOperand(str)
    inc idx
    if ?str:
      str.skipWhile({',', ' '})

  var known: Option[OpDataKind]
  for op in result.operands:
    if op.isSome() and op.get().dataKind.isSome():
      known = op.get().dataKind

  for op in mitems(result.operands):
    if op.isSome() and op.get().dataKind.isNone():
      op.get().dataKind = known

  selectOpcode(result)

startHax()

proc test(code: string) =
  let instr = parseInstr(code)
  echov code
  pprinte instr
  echo hshow(compileInstr(instr), clShowHex)

test("mov al, ah")
test("sub BYTE [eax + 8], 17")
