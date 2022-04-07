import instruction/[opcodes, syntaxes, instruction]
import common
import hmisc/core/all
import std/[options, strutils, sequtils, math, enumutils, sets, tables]
import hmisc/other/hpprint
import hmisc/algo/[hlex_base, lexcast, clformat, clformat_interpolate]

type
  InstrOperandKind* = enum
    iokReg8
    iokReg16
    iokReg32
    iokOffset
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

      of iokOffset:
        section*: string
        offset*: int

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

type
  InstrParseError* = object of CatchableError


  InstrErrorOperands* = object of InstrParseError


proc matchingTarget(given: InstrOperand, expect: OpAddrKind): bool =
  let k = given.target.kind
  let t = given.target
  const regs = { iokReg8, iokReg16, iokReg32 }
  case expect:
    of opAddrReg:
      if k in regs:
        result = not given.indirect

    of opAddrRegMem:
      if k in regs:
        result = true

    of opAddrImm:
      result = k in { iokImmediate }

    of opAddr32Kinds:
      result = k == iokReg32 and t.reg32 == opAddrToReg32[expect].get()

    of opAddr16Kinds:
      result = k == iokReg16 and t.reg16 == opAddrToReg16[expect].get()

    of opAddr8Kinds:
      result = k == iokReg8 and t.reg8 == opAddrToReg8[expect].get()

    of opAddrOffs:
      result = k == iokOffset

    of opAddrMem:
      result = false

    of opAddrSReg:
      result = false

    else:
      assert false, $expect.symbolName()

  # if (
  #   (expect in { opAddrReg } and not given.indirect) or
  #   (expect in { opAddrRegMem } and operand.indirect)
  # ) and k in { iokReg8, iokReg16, iokReg32 }:
  #   result = true

  # elif expect in { opAddrImm } and
  #      tk in { iokImmediate }:
  #   result = true

  # elif expect in { opAddrGRegEAX } and
  #      tk in { iokReg32 }:
  #   result = true

  # echov tk, expect, result


let
  opMoreSpecialized* = toTable({
    # Map from more specialied instructions into their generalized
    # counterparts.
    opMOV_EAX_D_Imm_V: opMOV_RegMem_V_Imm_V,
    opMOV_AH_B_Imm_B: opMOV_RegMem_B_Imm_B,
    opMOV_AL_B_Imm_B: opMOV_RegMem_B_Imm_B
  })

func dedupOpcodes*(code: ICode): ICode =
  case code:
    # https://stackoverflow.com/questions/44335265/difference-between-mov-r-m8-r8-and-mov-r8-r-m8
    of opMOV_Reg_B_RegMem_B: opMOV_RegMem_B_Reg_B
    of opSUB_Reg_V_RegMem_V: opSUB_RegMem_V_Reg_V
    # of opMov_Reg_B_RegMem_B: opMov_RegMem_B_Reg_B
    # of opMOV_Reg_V_Imm_V: opMOV_EAX_D_Imm_V
    else: code

func `$`*(instr: InstrOperandTarget): string =
  case instr.kind:
    of iokReg8: "R8:" & $instr.reg8
    of iokReg16: "R16:" & $instr.reg16
    of iokReg32: "R32:" & $instr.reg32
    of iokImmediate: "M:" & $instr.value
    of iokOffset: "O:" & $instr.value

func `$`*(instr: InstrOperand): string =
  "[$# k:$# ind:$#$#]" % [
    $instr.target,
    tern(?instr.dataKind, $instr.dataKind.get(), "?"),
    $instr.indirect,
    tern(?instr.offset, "+" & $instr.offset.get(), "")
  ]

func hshow*(instr: InstrOperandTarget, opts: HDisplayOpts = defaultHDIsplay): ColoredText =
  toCyan($instr)

func hshow*(instr: InstrOperand, opts: HDisplayOpts = defaultHDisplay): ColoredText =
  let dat = tern(?instr.dataKind, hshow(instr.dataKind.get(), opts), clt"?")
  let offset = tern(?instr.offset, "+" & hshow(instr.offset.get(), opts), clt"")

  return clfmt"[{hshow(instr.target, opts)} k:{dat} ind:{hshow(instr.indirect)}{offset}]"

func formatKind*(k: OpDataKind): string =
  case k:
    of opFlag: "F (flag)"
    of opData1616_32_32: "A"
    of opData8: "B (Byte)"
    of opData16: "W (Word)"
    of opData32: "D (DWord)"
    of opData16_32: "V (16/32)"
    of opData48: "P (48)"

func usedLen[R, T](arr: array[R, Option[T]]): int =
  for item in arr:
    if isSome(item):
      inc result

proc skippedOperands(desc: InstrDesc): seq[InstrOperand] =
  case desc.mnemonic:
    of opMneIMUL:
      if desc.operands.usedLen() == 2:
        result.add desc.operands[0].get()

    else:
      discard

proc selectOpcode*(instr: var InstrDesc) =
  var match: HashSet[ICode]

  # Get all explicitly given operands
  var givenOperands = instr.operands.filterIt(?it).mapIt(it.get())
  # Fill in missing elements, for instructions like `imul ax, 0x12` which
  # need to be translated into `imul ax, ax, 0x12`.
  givenOperands.insert(skippedOperands(instr))
  let giveLen = givenOperands.len()
  # Collect parts of the error message in case of malformed input
  var failures: seq[(ICode, string)]

  for op in instr.mnemonic.getOpcodes():
    let expected = op.getUsedOperands()
    let expectedLen = expected.mapIt(tern(it.isSome(), 1, 0)).sum()
    if giveLen != expectedLen:
      failures.add(
        op,
        "Invalid number of operands - expected '$#' ($#), but got '$#' ($#)" % [
          $toGreen($expectedLen),
          $hshow(expected),
          $toRed($giveLen),
          $hshow(givenOperands)
      ])

    else:
      var allMatch = true
      var failDesc: seq[string]
      for idx in 0 ..< giveLen:
        if not allMatch:
          continue

        let (expectAddr, expectData) = expected[idx].get()
        let given = givenOperands[idx]
        let givenData = given.dataKind.get()
        if not(
          givenData == expectData or
          (givenData == opData16_32 and expectData in { opData16, opData32 }) or
          (givenData == opData16 and expectData == opData1632) or
          (givenData == opData32 and expectData == opData1632)
        ):
          failDesc.add format(
            "Data kind mismatch - wanted '$#' for '$#', but got '$#'",
            $expectData.formatKind().toGreen(), idx,
            $givenData.formatKind().toRed())

          allMatch = false

        elif not matchingTarget(given, expectAddr):
          failDesc.add format(
            "Target mismatch - wanted '$#' for '$#', but got '$#'",
            $toGreen($expectAddr), idx, $toRed($given))

          allMatch = false

      if allMatch:
        match.incl op.dedupOpcodes()

      else:
        failures.add(op, failDesc.join("\n"))

  # Some instructions have more specialized versions implemented - for
  # example general `mov r/m16/32 imm16/32` can be encoded using operand
  # `C6`, but if target register is `EAX`, then it is an `B8`. I think some
  # of these alternative encodings are redundant.
  var toRemove: seq[ICode]
  for item in match:
    if item in opMoreSpecialized and
       opMoreSpecialized[item] in match:
      toRemove.add opMoreSpecialized[item]

  for item in toRemove:
    match.excl item

  if match.len == 0:
    # No possible matches most likely indicates error in the user input code.
    raise newException(
      InstrErrorOperands, "No matching code for $# - alternatives:\n$#" % [
        $instr.mnemonic,
        failures.mapIt("$#:\n$#" % [
          $toUpperAscii($it[0]).toYellow(),
          it[1].indent(2)]).join("\n").indent(2)
      ])

  else:

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
    id = str.asStrSlice():
      discard str.trySkip('-')
      discard str.trySkip('0')
      if str.trySkip('x'):
        str.skipWhile(strutils.HexDigits + {'_'})

      elif str.trySkip('o'):
        str.skipWhile({'0' .. '7', '_'})

      elif str.trySkip('b'):
        str.skipWhile({'0', '1', '_'})

      else:
        str.skipWhile(IdentChars + Digits + {'_'})

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

when isMainModule:
  test("mov al, ah")
  test("sub BYTE [ebx + 8], 17")
  test("sub BYTE [ebx], 17")
  test("sub eax, ebx")
  test("sub eax, ecx")
  test("sub ebx, ebx")
  test("sub ebx, ecx")
