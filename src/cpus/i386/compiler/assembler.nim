import instruction/[opcodes, syntaxes, instruction]
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
    indirect*: bool
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

  elif addrKind in { opAddrImm } and
       target.kind in { iokImmediate }:
    result = true

  elif addrKind in { opAddrGRegEAX } and
       target.kind in { iokReg32 }:
    result = true


func dedupOpcodes*(code: ICode): ICode =
  case code:
    # https://stackoverflow.com/questions/44335265/difference-between-mov-r-m8-r8-and-mov-r8-r-m8
    of opMOV_Reg_B_RegMem_B: opMOV_RegMem_B_Reg_B
    of opSUB_Reg_V_RegMem_V: opSUB_RegMem_V_Reg_V
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
          (dk == opData16_32 and dataKind in { opData16, opData32 }) or
          (dk == opData16 and dataKind == opData1632) or
          (dk == opData32 and dataKind == opData1632)
        ):
          # echov "data:", dk, dataKind
          allMatch = false

        elif not matchingTarget(operand.target, addrKind):
          # echov "target:", operand.target, addrKind
          allMatch = false

      if allMatch:
        match.incl op.dedupOpcodes()

      # else:
      #   echov "fail", op

  assert match.len == 1, $match
  instr.opcode = toSeq(match)[0]

proc regCode*(target: InstrOperandTarget): uint8 =
  case target.kind:
    of iokReg8: uint8(target.reg8)
    of iokReg16: uint8(target.reg16)
    of iokReg32: uint8(target.reg32)
    else: assert false; 0'u8

proc compileInstr*(instr: InstrDesc): seq[uint8] =
  let opc = instr.opcode
  # echov "------------"
  # echov opc
  # echov opc.hasModrm()
  if opc.isExtended():
    echov opc.opIdx()
    result.add cast[array[2, uint8]](opc.opIdx())

  else:
    result.add opc.opIdx().uint8()

  if opc.hasModrm():
    var rm = ModRM()
    var trail: seq[EByte]
    if instr.operands[0].canGet(arg):
      if arg.indirect:
        if arg.offset.canGet(offset):
          if offset in -128 .. +127:
            rm.mod = modDispByte
            trail.add cast[EByte](offset.int8)

          else:
            rm.mod = modDispDWord
            trail.add cast[array[4, EByte]](offset)

        else:
          rm.mod = modIndSib

      else:
        if arg.offset.canGet(offset):
          assert false

        else:
          # Register addressing mode - source and target elements are
          # registers.
          rm.mod = modRegAddr

      if arg.target.kind in { iokReg8, iokReg16, iokReg32 }:
        rm.rm = arg.target.regCode()

      if instr.operands[1].canGet(src) and
         src.target.kind in { iokReg8, iokReg16, iokReg32 }:
          rm.reg = src.target.regCode()

    if opc.isExtendedOpcode():
      rm.reg = opc.opExt()

    result.add cast[EByte](rm)
    result.add trail

  if instr.operands[1].canGet(src):
    if opc.hasImm8():
      result.add cast[EByte](src.target.value.uint8)

    elif opc.hasImm16_32():
      result.add cast[array[2, EByte]](src.target.value.uint16)


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
    result.indirect = true
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

proc test(code: string, dbg: bool = false) =
  let instr = parseInstr(code)
  if dbg:
    echov code
    pprinte instr

  echo hshow(compileInstr(instr), clShowHex)

test("mov al, ah")
test("sub BYTE [ebx + 8], 17")
test("sub BYTE [ebx], 17")
test("sub eax, ebx")
test("sub eax, ecx")
test("sub ebx, ebx")
test("sub ebx, ecx")
