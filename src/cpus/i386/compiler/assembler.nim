import instruction/[opcodes, syntaxes, instruction]
import common
import hmisc/core/all
import hmisc/algo/halgorithm
import hmisc/macros/henumutils
import std/[options, strutils, sequtils, math, sets, tables, re]
import hmisc/other/hpprint
import hmisc/algo/[hlex_base, lexcast, clformat, clformat_interpolate]

type
  InstrOperandKind* = enum
    iokReg8
    iokReg16
    iokReg32
    iokSgReg
    iokOffset
    iokLabel
    iokImmediate

  InstrOperandTarget* = object
    segmentOverride*: Option[SgRegT]
    case kind*: InstrOperandKind
      of iokReg8:
        reg8*: Reg8T

      of iokReg16:
        reg16*: Reg16T

      of iokReg32:
        reg32*: Reg32T

      of iokSgReg:
        sgReg*: SgRegT

      of iokImmediate:
        value*: int

      of iokLabel:
        name*: string

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
    text*: string
    mnemonic*: ICodeMnemonic
    opcode*: ICode
    line*, col*: int
    operands*: array[4, Option[InstrOperand]]

  InstrStmtKind* = enum
    iskCommand
    iskComment ## Standalone comment
    iskLabel
    iskConfig
    iskGlobal
    iskDataDB ## Sequence of bytes
    iskDataDW ## Word data
    iskDataDD ## Doubleword data

  InstrBinaryPart* = object
    location*: typeof(instantiationInfo())
    data*: seq[U8]
    pos*: int

  InstrBinary* = seq[InstrBinaryPart]

  InstrStmt* = object
    ## Single instruction statement. It jams all the data into single
    ## object in order to allow further instrospection - correlation
    ## between single instruction and specific chunk of program code.
    text*: string ## Text of the standalone or trailing comment, label
                  ## name (normalized: uppercased).
    origin*: tuple[line, col: int] ## Original position of the instruction
    binary*: InstrBinary ## Compiled code of the statement
    case kind*: InstrStmtKind
      of iskCommand:
        desc*: InstrDesc

      of iskGlobal:
        globalDecls*: seq[string]

      of iskConfig:
        config*: string
        param*: string

      of iskComment, iskLabel:
        discard

      of iskDataDB:
        dataDB*: seq[U8]

      of iskDataDW:
        dataDW*: U16

      of iskDataDD:
        dataDD*: U32

  InstrProgram* = object
    labels*: Table[string, int] ## Map between normalized (uppercased)
                                ## label names and
    stmts*: seq[InstrStmt] ## Full list of statements in the program

type
  InstrParseError* = object of ParseError
  InstrBadMnemonic* = object of InstrParseError
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
      result = (k in regs) or
               (k in {iokImmediate, iokLabel} and given.indirect)

    of opAddrImm:
      result = k in { iokImmediate, iokLabel } and
              not given.indirect

    of opAddr32Kinds:
      if (k == iokReg32 and t.reg32 == opAddrToReg32[expect].get()) or
         (k == iokReg16 and
          t.reg16 == Reg16T(opAddrToReg32[expect].get().uint8())):
        return true

    of opAddr16Kinds:
      result = k == iokReg16 and t.reg16 == opAddrToReg16[expect].get()

    of opAddr8Kinds:
      result = k == iokReg8 and t.reg8 == opAddrToReg8[expect].get()

    of opAddrOffs:
      result = k == iokOffset

    of opAddrMem:
      result = false

    of opAddrSReg:
      result = k == iokSgReg

    of opAddrSgKinds:
      result = k == iokSgReg and t.sgReg == opAddrToSgReg[expect].get()

    else:
      assert false, $expect.symbolName()

let
  opMoreSpecialized* = toTable({
    # Map from more specialied instructions into their generalized
    # counterparts.

    # MOV
    opMOV_EAX_V_Imm_V: opMOV_RegMem_V_Imm_V,
    opMOV_EDX_V_Imm_V: opMOV_RegMem_V_Imm_V,
    opMOV_EBX_V_Imm_V: opMOV_RegMem_V_Imm_V,
    opMOV_ECX_V_Imm_V: opMOV_RegMem_V_Imm_V,
    opMOV_EDI_V_Imm_V: opMOV_RegMem_V_Imm_V,

    opMOV_AH_B_Imm_B: opMOV_RegMem_B_Imm_B,
    opMOV_AL_B_Imm_B: opMOV_RegMem_B_Imm_B,
    opMOV_BL_B_Imm_B: opMOV_RegMem_B_Imm_B,
    opMOV_DL_B_Imm_B: opMOV_RegMem_B_Imm_B,

    # ADD
    opADD_Reg_V_RegMem_V: opADD_RegMem_V_Reg_V,

    # CMP
    opCMP_AL_B_Imm_B: opCMP_RegMem_B_Imm_B,

    # DEC
    opDEC_ECX_V: opDEC_RegMem_V,

    # INC
    opINC_EDI_V: opINC_RegMem_V,
    opINC_EBP_V: opINC_RegMem_V,
    opINC_ECX_V: opINC_RegMem_V,

    # POP
    opPOP_EDX_V: opPOP_RegMem_V,

    # PUSH
    opPUSH_EDX_V: opPUSH_RegMem_V,

    # TEST
    opTEST_AL_B_Imm_B: opTEST_RegMem_B_Imm_B
  })

func dedupOpcodes*(code: ICode): ICode =
  case code:
    # https://stackoverflow.com/questions/44335265/difference-between-mov-r-m8-r8-and-mov-r8-r-m8
    of opMOV_Reg_B_RegMem_B: opMOV_RegMem_B_Reg_B
    of opSUB_Reg_V_RegMem_V: opSUB_RegMem_V_Reg_V
    of opXOR_Reg_V_RegMem_V: opXOR_RegMem_V_Reg_V
    of opXor_Reg_B_RegMem_B: opXor_RegMem_B_Reg_B
    of opMOV_Reg_V_RegMem_V: opMOV_RegMem_V_Reg_V
    else: code

func `$`*(instr: InstrOperandTarget): string =
  case instr.kind:
    of iokReg8: "R8:" & $instr.reg8
    of iokReg16: "R16:" & $instr.reg16
    of iokReg32: "R32:" & $instr.reg32
    of iokSgReg: "S:" & $instr.sgReg
    of iokImmediate: "M:" & $instr.value
    of iokOffset: "O:" & $instr.value
    of iokLabel: "L:" & instr.name

func `$`*(instr: InstrOperand): string =
  "[$# k:$# ind:$#$#]" % [
    $instr.target,
    tern(?instr.dataKind, $instr.dataKind.get(), "?"),
    $instr.indirect,
    tern(?instr.offset, "+" & $instr.offset.get(), "")
  ]

func hshow*(
    instr: InstrOperandTarget,
    opts: HDisplayOpts = defaultHDIsplay): ColoredText =
  toCyan($instr)

func hshow*(
    instr: InstrOperand,
    opts: HDisplayOpts = defaultHDisplay): ColoredText =
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

func usedSize(instr: InstrDesc): uint8 =
  ## Size of values used for this particular instruction.
  for op in instr.operands:
    if op.isSome():
      let op = op.get()
      if op.indirect or op.target of { iokImmediate, iokLabel }:
        # If indirect addressing is used, operand sizes depend on the
        # explicitly specified data size, such as `byte [ebx]`, `word
        # [eax]` and so on..
        #
        # Immediate values don't have dedicated size based on address, so
        # they go through specified data kind as well.
        #
        # Size of the label target is based on the 'real/protected' mode
        # state at the time of parsing (it can be altered using `bits 16`,
        # `bits 32` directive).
        case op.dataKind.get():
          of opData8: return 1
          of opData16: return 2
          of opData32: return 4
          else: assert false, $op.dataKind

      else:
        # If direct qddressing is used, operand size depends on the size of
        # the register.
        case op.target.kind:
          of iokReg8: return 1
          of iokReg16, iokSgReg: return 2
          of iokReg32: return 4
          else: assert false, $op.target.kind

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
      var matching: seq[string]
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
          let msg = format(
            "Target mismatch - wanted '$#' for '$#', but got '$#'",
            $toGreen($expectAddr), idx, $toRed($given))
          failDesc.add msg
          allMatch = false

        else:
          matching.add "Target data #$#: $#=$#, addr: $#=$#" % [
            $idx,
            $expectData.formatKind(), $givenData.formatKind(),
            $expectAddr, $given
          ]

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
      InstrErrorOperands,
      "No matching code for $# $# at $#:$# - alternatives:\n$#" % [
        $instr.mnemonic,
        givenOperands.mapIt("[" & $it & "]").join(" "),
        $instr.line,
        $instr.col,
        failures.mapIt("$# ($# = $#):\n$#" % [
          $toUpperAscii($it[0]).toYellow(),
          symbolName(it[0]),
          $hshow(it[0].int, clShowHex),
          it[1].indent(2)]).join("\n").indent(2)
      ])

  else:
    if match.len != 1:
      pprinte instr
      pprinte match
      assert false, "$# ($#) at $#:$#" % [
        $match,
        match.mapIt(symbolName(it) & ":" & toHexTrim(it.int)).join(", "),
        $instr.line,
        $instr.col
      ]

    instr.opcode = toSeq(match)[0]

proc regCode*(target: InstrOperandTarget): uint8 =
  case target.kind:
    of iokReg8: uint8(target.reg8)
    of iokReg16: uint8(target.reg16)
    of iokReg32: uint8(target.reg32)
    else: assert false; 0'u8

template bin(it: untyped, inPos: int): untyped =
  var res = InstrBinaryPart(
    location: instantiationInfo(fullPaths = false),
    pos: inPos)

  res.data.add it
  res

proc compileInstr*(
    instr: InstrDesc,
    labelPatches: var Table[int, string],
    pos: var int,
    protMode: bool = false,
  ): InstrBinary =

  let opc = instr.opcode
  for op in instr.operands:
    if op.isSome() and op.get().target.segmentOverride.canGet(seg):
      case seg:
        of CS: result.add bin(0x2E, postInc(pos))
        of SS: result.add bin(0x36, postInc(pos))
        of DS: result.add bin(0x3E, postInc(pos))
        of ES: result.add bin(0x26, postInc(pos))
        of FS: result.add bin(0x64, postInc(pos))
        of GS: result.add bin(0x65, postInc(pos))

  if (instr.usedSize() == 4 and not protMode) or
     (instr.usedSize() == 2 and protMode):
    # If instruction used size is different from currently selected
    # bitness, add operand size override prefix
    result.add bin(0x66, postInc(pos))

  if opc.isExtended():
    let opc: U16 = opc.opIdx()
    result.add bin(U8(opc shr 0x8), postInc(pos))
    result.add bin(U8(opc and 0xFF), postInc(pos))

  else:
    result.add bin(opc.opIdx().uint8(), postInc(pos))

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
          if arg.target.kind in { iokImmediate }:
            # Special value of the `rm` register that indicates use of the
            # immediate 16/32-bit offset.
            rm.rm = 0b101
            if protMode:
              trail.add cast[array[4, EByte]](arg.target.value.U32)

            else:
              trail.add cast[array[2, EByte]](arg.target.value.U16)

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

    result.add bin(cast[EByte](rm), postInc(pos))
    result.add bin(trail, postInc(pos))

  if opc.hasImm8() or opc.hasImm1632():
    var value: int
    for op in ritems(instr.operands):
      if op.isSome():
        if op.get().target of iokImmediate:
          value = op.get().target.value

        elif op.get().target of iokLabel:
          # If label is used instead of a regular integer it is replaced with dummy
          # value of zero, and then patched back later, when all label values are
          # known.
          value = 0
          labelPatches[pos] = op.get().target.name

    # If instruction requires encoding immediate values, determine target
    # size and cast provided value.
    case instr.usedSize():
      of 1: result.add bin(cast[EByte](U8(value)), postInc(pos))
      of 2: result.add bin(cast[array[2, EByte]](U16(value)), postInc(pos))
      of 4: result.add bin(cast[array[4, EByte]](U32(value)), postInc(pos))
      else: assert false, $instr.usedSize()

proc compileInstr*(instr: InstrDesc, protMode: bool = false): InstrBinary =
  var table: Table[int, string]
  return compileInstr(instr, table, asVar(0), protMode = protMode)

proc compile*(prog: var InstrProgram) =
  var pos: int
  var patches: Table[int, string]
  for stmt in mitems(prog.stmts):
    case stmt.kind:
      of iskCommand, iskDataDW:
        case stmt.kind:
          of iskCommand:
            stmt.binary = compileInstr(stmt.desc, patches, pos)

          of iskDataDW:
            stmt.binary.add bin(cast[array[2, U8]](stmt.dataDW), pos)

          else: discard

      of iskLabel:
        prog.labels[stmt.text.toUpperAscii()] = pos

      else:
        discard

  for stmt in mitems(prog.stmts):
    if stmt of iskCommand:
      for slice in mitems(stmt.binary):
        if slice.pos in patches:
          let target = prog.labels[patches[slice.pos]]
          if slice.data.len == 2:
            slice.data = toSeq(cast[array[2, U8]](target))

          elif slice.data.len == 4:
            slice.data = toSeq(cast[array[4, U8]](target))

          else:
            echov slice.data.len, slice.location
            assert false, "!!!!!!!!!!!!!!!!!!!!!AAAAAAAAAAAAAAAA SHIT"

proc enumNames[E: enum](): seq[string] =
  for val in low(E) .. high(E):
    result.add $val

proc parseOperand*(str: var PosStr, protMode: bool): InstrOperand =
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
    if str[':']:
      str.skip(':')
      result.target.segmentOverride = some parseEnum[SgRegT](id)
      id = str.popIdent()

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
    if dat.isNone() and not result.indirect:
      dat = some opData16

  elif id in asConst(enumNames[Reg32T]()):
    tar = T(kind: iokReg32, reg32: parseEnum[Reg32T](id))
    if dat.isNone() and not result.indirect:
      dat = some opData32

  elif id in asConst(enumNames[SgRegT]()):
    tar = T(kind: iokSgReg, sgReg: parseEnum[SgRegT](id))
    if dat.isNone() and not result.indirect:
      dat = some opData16

  elif id[0] notin Digits:
    tar = T(kind: iokLabel, name: id)
    if dat.isNone() and not result.indirect:
      if protMode:
        dat = some opData32
      else:
        dat = some opData16

  else:
    let v = lexcast[int](id)
    tar = T(kind: iokImmediate, value: v)
    if dat.isNone() and not result.indirect:
      # If used data size is not yet known, determine it based on the
      # provided value.
      if v in low(U8).int .. high(U8).int:
        dat = some opData8

      elif v in low(U16).int .. high(U16).int:
        dat = some opData16

      elif v in low(U32).int .. high(U32).int:
        dat = some opData32

  result.target = tar
  result.dataKind = dat

proc mapMnemonic(str: string): string =
  const map = toTable({
    "JE": "JZ"
  })

  if str in map:
    return map[str]

  else:
    return str

proc parseInstrRaw*(
    text: string,
    protMode: bool,
    pos: tuple[line, column: int]): InstrDesc =
  var str = initPosStr(text.toUpperAscii(), pos)
  let mnemonic = str.popIdent().toUpperAscii()
  try:
    result.mnemonic = parseEnum[ICodeMnemonic](mnemonic.mapMnemonic())

  except ValueError:
    raise newException(
      InstrBadMnemonic,
      "Unknown instruction mnemonic - '$#' $#" % [
        mnemonic,
        describeAtPosition(str)
    ]).withIt do:
      it.setLineInfo(str)


  str.space()
  var idx = 0
  while ?str:
    result.operands[idx] = some parseOperand(str, protMode)
    inc idx
    if ?str:
      str.skipWhile({',', ' '})

  block:
    # Patch operand sizes
    var known: Option[OpDataKind]
    for op in result.operands:
      if op.isSome() and op.get().dataKind.isSome():
        known = op.get().dataKind

    for op in mitems(result.operands):
      if op.isSome() and op.get().dataKind.isNone():
        if known.isNone() and op.get().target.kind in { iokLabel }:
          op.get().dataKind = some opData32
        else:
          op.get().dataKind = known

  result.text = text
  result.line = pos.line
  result.col = pos.column

proc parseInstr*(
    text: string,
    protMode: bool = false,
    pos: tuple[line, column: int] = (0, 0)): InstrDesc =

  result = parseInstrRaw(text, protMode, pos)
  selectOpcode(result)

func instrComment*(text: string): InstrStmt =
  InstrStmt(kind: iskComment, text: text)

func instrLabel*(name: string): InstrStmt =
  InstrStmt(kind: iskLabel, text: name)

func instrCommand*(desc: InstrDesc): InstrStmt =
  InstrStmt(desc: desc, kind: iskCommand)

func rei*(str: string): Regex =
  re(str, {reIgnoreCase, reStudy})

proc parseProgram*(prog: string): InstrProgram =
  var lineNum = 0
  var protMode = false
  for line in splitLines(prog):
    var commentStart = line.high
    while 0 <= commentStart and line[commentStart] != ';':
      dec commentStart

    let comment = tern(commentStart < 0, "", line[(commentStart + 1) .. ^1])
    let text = strip(
      line[0 .. tern(commentStart < 0, line.high, commentStart - 1)])

    if text.empty():
      if not comment.empty():
        result.stmts.add instrComment(comment)

    elif text[^1] == ':':
      result.stmts.add instrLabel(text[0..^2])

    else:
      if text =~ rei"\s*global ":
        var str = initPosStr(text)
        str.space()
        discard str.popIdent()
        str.space()
        var names: seq[string]
        while str[IdentChars]:
          names.add str.popIdent()
          str.space()
          if str[',']:
            str.next()

        result.stmts.add InstrStmt(
          kind: iskGlobal, globalDecls: names)

      elif text =~ rei"\s*bits\s+(.*)":
        result.stmts.add InstrStmt(
          kind: iskConfig, config: "bits", param: matches[0])

        if matches[0] == "32":
          protMode = true

        elif matches[0] == "16":
          protMode = false

      elif text =~ rei"\s*dw\s+(.*)":
        result.stmts.add InstrStmt(
          kind: iskDataDW, dataDW: lexcast[U16](matches[0]))

      else:
        result.stmts.add parseInstr(
            text, protMode = protMode, (lineNum, 0)
        ).instrCommand().withIt do:
          it.text = strip(comment)

    inc lineNum

func data*(bin: InstrBinary): seq[U8] =
  for slice in bin:
    result.add slice.data


proc parseCompileProgram*(prog: string): seq[U8] =
  var prog = parseProgram(prog)
  prog.compile()
  for stmt in prog.stmts:
    if stmt of iskCommand:
      result.add stmt.binary.data()

startHax()

proc test(code: string, dbg: bool = false) =
  let instr = parseInstr(code, false, (0, 0))
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
