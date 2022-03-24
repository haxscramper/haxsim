import std/parsecsv
import std/streams
import std/strutils

let file = "opcodes.csv"
var s = newFileStream(file, fmRead)
var x: CsvParser

open(x, s, file)
x.readHeaderRow()

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

while readRow(x):
  # echo x.rowEntry("po"), x.rowEntry("so")
  for op in ["op1", "op2", "op3", "op4"]:
    let e = x.rowEntry(op)
    if e notin ["", "1", "3"]:
      echo parseEnum[OpKind](e.normalize())
