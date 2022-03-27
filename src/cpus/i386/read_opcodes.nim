import std/parsecsv
import std/streams
import std/tables
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
  const nop = none((OpAddrKind, OpDataKind))
  const"""

for data in OpDataKind:
  operands.addf("\n    Da$# = $#", $data, symbolName(data))

for akind in OpAddrKind:
  operands.addf("\n    Ad$# = $#", $akind, symbolName(akind))

operands.add "\n  case code:"

var flags = {
  "test f": "",
  "mod f": "",
  "def f": "",
  "undef f": ""
}

var resMnemonics: Table[string, seq[string]]

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
      operandsTmp.addf("$#, ", "nop".alignLeft(24))

    else:
      let en = parseEnum[OpKind](e.normalize())

      mne.add " " & $e

      operandsTmp.add ("some((Ad$#, Da$#))" % [
        $getAddrKind(en), $getDataKind(en)]).alignLeft(24)

      operandsTmp.add ", "

      args.addf("_$#_$#", getAddrKind(en), getDataKind(en))

  let mneName = x.rowEntry("mnemonic")
  let opname = "op" & mneName & args
  resMnemonics.mgetOrPut(mneName, @[]).add opname
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

res.add """

  ICodeMnemonic* = enum"""

for mne, impl in resMnemonics:
  res.addf("\n    opMne$# = \"$#\"", mne.alignLeft(12), mne)

res.add """


func getOpcodes*(code: ICodeMnemonic): seq[ICode] =
  case code:"""

for mne, impl in resMnemonics:
  res.addf("\n    of opMne$#: @[ $# ]", mne.alignLeft(12), impl.join(", "))

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
