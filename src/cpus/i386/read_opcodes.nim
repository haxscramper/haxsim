import std/parsecsv
import std/streams
import std/strformat
import std/strutils
import std/enumutils
import hmisc/other/[hshell, oswrap]
import hmisc/core/all
import instruction/syntaxes

let abs = oswrap.currentSourceDir() / RelFile("opcodes.ods")

let cmd = shellCmd(
  "soffice",
  "--headless",
  "--convert-to",
  "csv:Text - txt - csv (StarCalc):44,34,76,,,,true",
  "--outdir",
  $oswrap.currentSourceDir(),
  $abs)

execShell cmd
assertExists(RelFile("opcodes.csv"))

let file = "opcodes.csv"
var s = newFileStream(file, fmRead)
var x: CsvParser

open(x, s, file)
x.readHeaderRow()

var res = """
type
  ICode* = enum"""

var operands = """
func getUsedOperands*(code: ICode): array[4, Option[(OpAddrKind, OpDataKind)]] =
  const nop = none((OpAddrKind, OpDataKind))"""

for data in OpDataKind:
  operands.addf("\n  const $# = $#", $data, symbolName(data))

for akind in OpAddrKind:
  operands.addf("\n  const $# = $#", $akind, symbolName(akind))

operands.add "\n  case code:"

var flags = {
  "test f": "",
  "mod f": "",
  "def f": "",
  "undef f": ""
}

while readRow(x):
  var args = ""
  var mne = ""

  let num = align(
    join([
      x.rowEntry("po").toUpper().align(2, padding = '0'),
      x.rowEntry("so").toUpper().align(3, padding = '0'),
      x.rowEntry("o").toUpper().ternIt(it notin ["R", ""], it, "0"),
    ]), 6, padding = '0')


  var operandsTmp = ""
  for op in ["op1", "op2", "op3", "op4"]:
    let e = x.rowEntry(op)
    if e in [""]:
      operandsTmp.addf("$#, ", "nop".alignLeft(20))

    else:
      let en = parseEnum[OpKind](e.normalize())

      mne.add " " & $e

      let addrMeth = case en:
        of opkImm16_32, opkImm8, opkImm16: opAddrImm
        of opkReg16_32, opkReg8, opkReg16, opkReg32: opAddrReg
        of opkMem16_32, opkMem8, opkMem16, opkMem32: opAddrMem
        of opkRegMem16_32, opkRegMem8: opAddrRegMem
        of opkGRegAH: opAddrGRegAH
        of opkGRegAL: opAddrGRegAL
        of opkGRegAX: opAddrGRegAX
        of opkGRegEAX: opAddrGRegEAX
        else:
          # assert false, $en
          opAddrImm

      let dataKind = case en:
        of opkImm16_32, opkMem16_32, opkReg16_32, opkRegMem16_32: opData16_32
        of opkImm8, opkReg8, opkMem8, opkRegMem8: opData8
        of opkImm16, opkReg16, opkMem16, opkRegMem16: opData16
        of opkReg32, opkMem32: opData32
        of opkGRegAH, opkGRegAL: opData8
        of opkGRegAX: opData16
        of opkGRegEAX: opData32
        else:
          # assert false, $en
          opData16_32


      operandsTmp.add ("some(($#, $#))" % [$addrMeth, $dataKind]).alignLeft(20)
      operandsTmp.add ", "

      args.addf("_$#_$#", addrMeth, dataKind)

      # args.add case en:
      #   of opkStack: "_Stack"
      #   of opkReg8: "_R_B"
      #   of opkRegMem8: "_Rm_B"
      #   of opkRegMem16: "_Rm_W"
      #   of opkReg16_32: "_R_Vs"
      #   of opkMem16_32: "_M_Vs"
      #   of opkImm16_32: "_I_Vs"
      #   of opkMM: "_M_2Wor2DW"
      #   of opkPtr32_48: "_PtrP"
      #   of opkRel16_32: "_Rel_Vs"

      #   of opkMoffs16_32: "_Moffs_Vs"
      #   of opkRegMem16_32: "_Rm_Vs"
      #   of opkMem32_48: "_M_P"
      #   else: "_" & capitalizeAscii($en)

  let opname = "op" & x.rowEntry("mnemonic") & args
  operands.addf("\n    of $#: [$#]", opname.alignLeft(30), operandsTmp)


  res.addf(
    "\n    $# = (0x$#_$#_$#, \"$#\")",
    opname.alignLeft(30),
    num[0..1], num[2..3], num[4..5],
    x.rowEntry("mnemonic") & mne,)

  assert validIdentifier("a" & args), args & $x.row


  for _, (name, body) in mpairs(flags):
    body.addf("\n    of $#: set[OpFlagIO]({", opname.alignLeft(30))
    let e = x.rowEntry(name)
    if e notin [""]:
      for ch in e.normalize():
        if ch != '.':
          body.addf("$#, ", symbolName(parseEnum[OpFlagIO]($ch)))

    body.add "})"

writeFile(
  "instruction/opcodes.nim",
  join([
    "import ./syntaxes, std/options",
    res,
    &"""
func getTestedFlags*(code: ICode): set[OpFlagIO] =
  case code:{flags[0][1]}

func getModifiedFlags*(code: ICode): set[OpFlagIO] =
  case code:{flags[1][1]}

{operands}
"""
  ], "\n\n")
)

execShell shellCmd(nim, check, "instruction/opcodes.nim")
