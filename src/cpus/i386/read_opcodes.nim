import std/parsecsv
import std/streams
import std/strutils
import hmisc/other/[hshell, oswrap]
import hmisc/core/all


type
  OpKind = enum
    opkGRegAH = "ah"
    opkGRegAL = "al"
    opkGRegAX = "ax"
    opkCR0 = "cr0"
    opkCRn = "crn"
    opkDI = "di"
    opkDRn = "drn"
    opkDS = "ds"
    opkDX = "dx"
    opkGRegEAX = "eax"
    opkeBP = "ebp"
    opkeCX = "ecx"
    opkEDI = "edi"
    opkEDX = "edx"
    opkESI = "esi"
    opkBP = "bp"
    opkEFlags = "eflags"
    opkMM = "m16/32&16/32"

    opkSRegES = "es"
    opkSRegCX = "cx"
    opkSRegFS = "fs"
    opkSRegCS = "cs"
    opkSRegCL = "cl"
    opkSRegGS = "gs"

    opkFlags = "flags"

    opkGDTR = "gdtr"
    opkIDTR = "idtr"
    opkImm16 = "imm16"
    opkImm16_32 = "imm16/32"
    opkImm8 = "imm8"
    opkLDTR ="ldtr"
    opkMem = "m"
    opkMem16 = "m16"
    opkMem32_48 = "m16:16/32"
    opkMem16_32 = "m16/32"
    opkMem32 = "m32"
    opkMem32int = "m32int"
    opkMem32real = "m32real"
    opkMem512 = "m512"
    opkMem64 = "m64"
    opkMem64int = "m64int"
    opkMem8 = "m8"
    opkm80dec = "80dec"
    opkmoffs16_32 = "moffs16/32"
    opkmoffs8 = "moffs8"
    opkMSW = "msw"
    opkptr32_48 = "ptr16:16/32"
    opkReg = "r"
    opkReg16_32 = "r16/32"
    opkReg32 = "r32"
    opkReg8 = "r8"
    opkReg16 = "r16"
    opkReg64 = "r64"
    opkrel16_32 = "rel16/32"
    opkrel8 = "rel8"
    opkRegMem16 = "r/m16"
    opkRegMem16_32 = "r/m16/32"
    opkRegMem8 = "r/m8"
    opkRegMem = "r/m"
    opkSreg = "sreg"
    opkSS = "ss"
    opkST = "st"
    opkST1 = "st1"
    opkST2 = "st2"
    opkSTi = "sti"
    opkSI = "si"
    opkTR = "tr"
    opkXCR = "xcr"
    opkStack = "..."
    opkXMM = "xmm"
    opkExec1 = "1"
    opkExec3 = "3"


echo "converting"

let abs = oswrap.currentSourceDir() / RelFile("opcodes.ods")

let cmd = shellCmd(
  "soffice",
  "--headless",
  "--convert-to",
  "csv:Text - txt - csv (StarCalc):44,34,76,,,,true",
  "--outdir",
  $oswrap.currentSourceDir(),
  $abs)

echo cmd
execShell cmd
assertExists(RelFile("opcodes.csv"))
echo "done"

let file = "opcodes.csv"
var s = newFileStream(file, fmRead)
var x: CsvParser

open(x, s, file)
x.readHeaderRow()

type
  OpFlagIO = enum
    opfO = "o"
    opfS = "s"
    opfZ = "z"
    opfA = "a"
    opfC = "c"
    opfG = "g"
    opfP = "p"
    opfI = "i"
    opfD = "d"

var res = """
type
  ICode* = enum
"""

while readRow(x):
  var args = ""
  var mne = ""
  for op in ["op1", "op2", "op3", "op4"]:
    let e = x.rowEntry(op)
    if e notin [""]:
      let en = parseEnum[OpKind](e.normalize())
      mne.add " " & $e
      args.add case en:
        of opkStack: "_Stack"
        of opkReg8: "_R8"
        of opkRegMem8: "_Rm8"
        of opkRegMem16: "_Rm16"
        of opkReg16_32: "_R16_32"
        of opkMem16_32: "_M16_32"
        of opkImm16_32: "_I16_32"
        of opkMM: "_M16and16_32and32"
        of opkPtr32_48: "_Ptr16_32"
        of opkRel16_32: "_Rel16_32"

        of opkMoffs16_32: "_Moffs16_32"
        of opkRegMem16_32: "_Rm16_32"
        of opkMem32_48: "_M32_48"
        else: "_" & capitalizeAscii($en)


  let num = align(
    join([
      x.rowEntry("po").toUpper().align(2, padding = '0'),
      x.rowEntry("so").toUpper().align(3, padding = '0'),
      x.rowEntry("o").toUpper().ternIt(it notin ["R", ""], it, "0"),
    ]), 6, padding = '0'
  )
  res.addf(
    "\n    op$# = (0x$#_$#_$#, \"$#\")",
    (x.rowEntry("mnemonic") & args).alignLeft(30),
    num[0..1], num[2..3], num[4..5],
    x.rowEntry("mnemonic") & mne,
  )

  assert validIdentifier("a" & args), args & $x.row


  for flag in ["test f", "mod f", "def f", "undef f"]:
    let e = x.rowEntry(flag)
    if e notin [""]:
      for ch in e.normalize():
        if ch != '.':
          discard parseEnum[OpFlagIO]($ch)

writeFile("instruction/opcodes.nim", res)
execShell shellCmd(nim, check, "instruction/opcodes.nim")
