import std/[enumutils, options]
import hmisc/core/all

type
  Reg32T* = enum
    EAX = 0b000
    ECX = 0b001
    EDX = 0b010 ## Called the Data register It is used for I/O port access,
    ## arithmetic, some interrupt calls.
    EBX = 0b011
    ESP = 0b100 ## Stack pointer register Holds the top address of the stack
    EBP = 0b101 ## Stack Base pointer register. Holds the base address of the stack
    ESI = 0b110 ## Source index register. Used for string and memory array copying
    EDI = 0b111 ## Destination index register Used for string, memory array
    ## copying and setting and for far pointer addressing with ES

  Reg16T* = enum
    AX = 0b000
    CX = 0b001
    DX = 0b010
    BX = 0b011
    SP = 0b100 ## Part of ESP
    BP = 0b101 ## Part of EBP
    SI = 0b110 ## Part of ESI
    DI = 0b111 ## Part of EDI

  Reg8T* = enum
    AL = 0b000
    CL = 0b001
    DL = 0b010
    BL = 0b011
    AH = 0b100
    CH = 0b101
    DH = 0b110
    BH = 0b111


  SgRegT* = enum
    ES
    CS ## 'Code Segment' Holds the Code segment in which your program runs.
    SS ## 'Stack Segment' Holds the Stack segment your program uses.
    DS ## 'Data Segment' Holds the Data segment that your program accesses.
    FS
    GS

  DTregT* = enum
    GDTR
    IDTR
    LDTR
    TR


type
  OpAddrKind* = enum
    opAddrImm1 = "One"
    opAddrImm3 = "Three"

    opAddrImm = "Imm" ## Immediate value operand
    opAddrOffs = "Offs" ## Offset from section start
    opAddrReg = "Reg" ## Register
    opAddrMem = "Mem" ## Memory location
    opAddrRegMem = "RegMem" ## Register or indirect register
    opAddrPtr = "A"

    opAddrGRegAH = "AH"
    opAddrGRegAL = "AL"
    opAddrGRegAX = "AX"

    opAddrGRegCH = "CH"
    opAddrGRegCL = "CL"
    opAddrGRegCX = "CX"

    opAddrGRegSI = "SI"
    opAddrGRegDI = "DI"
    opAddrGRegBP = "BP"
    opAddrGRegSP = "SP"

    opAddrGRegDL = "DL"
    opAddrGRegDH = "DH"
    opAddrGRegDX = "DX"

    opAddrGRegBL = "BL"
    opAddrGRegBH = "BH"
    opAddrGRegBX = "BX"

    opAddrGRegEAX = "EAX"
    opAddrGRegEBX = "EBX"
    opAddrGRegECX = "ECX"
    opAddrGRegEDX = "EDX"
    opAddrGRegEDI = "EDI"
    opAddrGRegEBP = "EBP"
    opAddrGRegESI = "ESI"
    opAddrGRegESP = "ESP"

    opAddrSReg = "SREG"
    opAddrSRegDS = "DS"
    opAddrSRegES = "ES"
    # opAddrSRegCX = "CX"
    opAddrSRegFS = "FS"
    opAddrSRegCS = "CS"
    opAddrSRegGS = "GS"
    opAddrSRegSS = "SS"

    opAddrDTregGDTR = "GDTR"
    opAddrDTregIDTR = "IDTR"
    opAddrDTregLDTR = "LDTR"

    opAddrDTregTR = "TR"
    opAddrMSW = "MSW"

    opAddrCR = "CR"
    opAddrDR = "DR"
    opAddrStack = "STACK"
    opAddrEflags = "EFLAGS"

const
  opAddrToReg8* = toSparseMapArray({
    opAddrGregAL: AL,
    opAddrGregCL: CL,
    opAddrGregDL: DL,
    opAddrGregBL: BL,
    opAddrGregAH: AH,
    opAddrGregCH: CH,
    opAddrGregDH: DH,
    opAddrGregBH: BH,
  })


  opAddrToReg16* = toSparseMapArray({
    opAddrGregAX: AX,
    opAddrGregCX: CX,
    opAddrGregDX: DX,
    opAddrGregBX: BX,
    opAddrGregSP: SP,
    opAddrGregBP: BP,
    opAddrGregSI: SI,
    opAddrGregDI: DI,
  })

  opAddrToReg32* = toSparseMapArray({
    opAddrGregEAX: EAX,
    opAddrGregECX: ECX,
    opAddrGregEDX: EDX,
    opAddrGregEBX: EBX,
    opAddrGregESP: ESP,
    opAddrGregEBP: EBP,
    opAddrGregESI: ESI,
    opAddrGregEDI: EDI,
  })

  opAddr8Kinds* = toKeySet(opAddrToReg8)
  opAddr16Kinds* = toKeySet(opAddrToReg16)
  opAddr32Kinds* = toKeySet(opAddrToReg32)


type
  OpDataKind* = enum
    opFlag = "F"

    opData1616_3232 = "A"
    opData8 = "B"
    opData32 = "D"
    opData16 = "W"
    opData16_32 = "V"
    opData48 = "P"

  OpKind* = enum
    opkCR0 = "cr0"
    opkCRn = "crn"
    opkDRn = "drn"

    opkDTregGDTR = "gdtr"
    opkDTregIDTR = "idtr"
    opkDTregLDTR = "ldtr"

    opkEFlags = "eflags"
    opkExec1 = "1"
    opkExec3 = "3"
    opkFlags = "flags"

    opkGRegAH = "ah"
    opkGRegAL = "al"
    opkGRegDL = "dl"
    opkGRegCL = "cl"
    opkGRegAX = "ax"
    opkGRegBP = "bp"
    opkGRegDI = "di"
    opkGRegDX = "dx"
    opkGRegBL = "bl"
    opkGRegCH = "ch"
    opkGRegCX = "cx"
    opkGRegDH = "dh"
    opkGRegBH = "bh"

    opkGRegEAX = "eax"
    opkGRegECX = "ecx"
    opkGRegEDX = "edx"
    opkGRegEBX = "ebx"
    opkGRegEBP = "ebp"
    opkGRegEDI = "edi"
    opkGRegESI = "esi"
    opkGRegESP = "esp"
    opkGregSI = "si"

    opkImm16 = "imm16"
    opkImm16_32 = "imm16/32"
    opkImm8 = "imm8"

    opkMM = "m16/32&16/32"
    opkMSW = "msw"

    opkMem16 = "m16"
    opkMem16_32 = "m16/32"
    opkMem32 = "m32"
    opkMem32_48 = "m16:16/32"
    opkMem48 = "m16&32"
    opkMem8 = "m8"

    opkReg = "r"
    opkReg16 = "r16"
    opkReg16_32 = "r16/32"
    opkReg32 = "r32"
    opkReg8 = "r8"

    opkRegMem = "r/m"
    opkRegMem16 = "r/m16"
    opkRegMem16_32 = "r/m16/32"
    opkRegMem8 = "r/m8"

    opkRel16_32 = "rel16/32"
    opkRel8 = "rel8"

    opkSRegCS = "cs"
    opkSRegDS = "ds"
    opkSRegES = "es"
    opkSRegFS = "fs"
    opkSRegGS = "gs"
    opkSRegSS = "ss"
    opkSreg = "sreg"

    opkStack = "..."
    opkTR = "tr"
    opkMoffs16_32 = "moffs16/32"
    opkMoffs8 = "moffs8"
    opkPtr32_48 = "ptr16:16/32"

  OpFlagIO* = enum
    opfOverflow = "o"
    opfSigned = "s"
    opfZero = "z"
    opfAbove = "a"
    opfCarry = "c"
    opfGreater = "g"
    opfParity = "p"
    opfInterrupt = "i"
    opfDirection = "d"

func getDataKind*(en: OpKind): OpDataKind =
  case en:
    of opkImm16_32, opkMem16_32, opkReg16_32,
       opkRegMem16_32, opkRel16_32, opkStack, opkMoffs16_32:
      opData16_32

    of opkImm8, opkReg8, opkMem8, opkRegMem8, opkRel8, opkMoffs8,
       opkExec1, opkExec3:
      opData8

    of opkImm16, opkReg16, opkMem16, opkRegMem16, opkGRegDI,
       opkGregSI, opkSReg:
      opData16

    of opkReg32, opkMem32: opData32
    of opkGRegAH, opkGRegAL, opkGRegCL, opkSRegGS, opkSRegSS,
       opkGRegDL, opkGRegBL, opkGRegCH, opkGRegDH, opkGRegBH:
      opData8

    of opkGRegAX, opkSRegDS, opkGregDX, opkGRegBP, opkSRegES, opkSRegCS,
       opkSRegFS, opkGRegCX,
       opkDTregGDTR, opkDTregIDTR, opkDTregLDTR, opkTR, opkMSW:
      opData16

    of opkGRegEAX, opkGRegEBP, opkGRegECX, opkGRegEBX,
       opkGRegEDI, opkGREgEDX, opkGRegESI, opkGRegESP,
       opkEFlags:
      opData1632

    of opkMem48, opkMem32_48, opkPtr32_48:
      opData48

    of opkCR0, opkCRN:
      opFlag

    of opkDRn:
      opFlag

    of opkMM:
      opData1616_3232

    else:
      assert false, $symbolName(en)
      opData16_32

func getAddrKind*(en: OpKind): OpAddrKind =
  case en:
    of opkImm16_32, opkImm8, opkImm16,
       opkRel16_32, opkRel8:
      opAddrImm

    of opkMoffs8, opkMoffs16_32:
      opAddrOffs

    of opkExec1:
      opAddrImm1

    of opkExec3:
      opAddrImm3

    of opkReg16_32, opkReg8, opkReg16, opkReg32:
      opAddrReg

    of opkMem16_32, opkMem8, opkMem16, opkMem32,
       opkMem48, opkMem32_48, opkMM:
      opAddrMem

    of opkRegMem16_32, opkRegMem8, opkRegMem16:
      opAddrRegMem

    of opkMSW: opAddrMSW
    of opkCR0, opkCRn: opAddrCR
    of opkDRn: opAddrDR
    of opkEflags: opAddrEflags

    of opkGRegAH: opAddrGRegAH
    of opkGRegAL: opAddrGRegAL
    of opkGRegCH: opAddrGRegCH
    of opkGRegAX: opAddrGRegAX
    of opkGRegDX: opAddrGRegDX
    of opkGRegBP: opAddrGRegBP
    of opkGRegDI: opAddrGRegDI
    of opkGRegDL: opAddrGRegDL
    of opkGRegBL: opAddrGRegBL
    of opkGRegSI: opAddrGregSI
    of opkGRegDH: opAddrGregDH
    of opkGRegBH: opAddrGregBH

    of opkGRegEAX: opAddrGRegEAX
    of opkGRegEBP: opAddrGRegEBP
    of opkGRegEBX: opAddrGRegEBX
    of opkGRegECX: opAddrGRegECX
    of opkGRegEDI: opAddrGRegEDI
    of opkGRegEDX: opAddrGRegEDX
    of opkGRegESI: opAddrGRegESI
    of opkGRegESP: opAddrGRegESP

    of opkSReg: opAddrSReg
    of opkSRegDS: opAddrSRegDS
    of opkSRegES: opAddrSRegES
    of opkGRegCX: opAddrGRegCX
    of opkSRegFS: opAddrSRegFS
    of opkSRegCS: opAddrSRegCS
    of opkGRegCL: opAddrGRegCL
    of opkSRegGS: opAddrSRegGS
    of opkSRegSS: opAddrSRegSS

    of opkDTregGDTR: opAddrDTregGDTR
    of opkDTregIDTR: opAddrDTregIDTR
    of opkDTregLDTR: opAddrDTregLDTR
    of opkTR: opAddrDTregTR
    of opkStack: opAddrStack
    of opkPtr32_48: opAddrPtr
    else:
      assert false, $symbolName(en)
      opAddrImm
