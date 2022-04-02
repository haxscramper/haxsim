import std/enumutils

type
  Reg32T* = enum
    EAX
    ECX
    EDX ## Called the Data register It is used for I/O port access,
    ## arithmetic, some interrupt calls.
    EBX
    ESP ## Stack pointer register Holds the top address of the stack
    EBP ## Stack Base pointer register. Holds the base address of the stack
    ESI ## Source index register. Used for string and memory array copying
    EDI ## Destination index register Used for string, memory array copying
    ## and setting and for far pointer addressing with ES
    GPREGSCOUNT

  Reg16T* = enum
    AX
    CX
    DX
    BX
    SP ## Part of ESP
    BP ## Part of EBP
    SI ## Part of ESI
    DI ## Part of EDI

  Reg8T* = enum
    AL
    CL
    DL
    BL
    AH
    CH
    DH
    BH


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

    opAddrImm = "Imm"
    opAddrReg = "Reg"
    opAddrMem = "Mem"
    opAddrRegMem = "RegMem"
    opAddrPtr = "A"

    opAddrGRegAX = "AX"
    opAddrGRegAH = "AH"
    opAddrGRegAL = "AL"
    opAddrGRegDI = "DI"
    opAddrGRegDX = "DX"
    opAddrGRegBP = "BP"
    opAddrGRegCL = "CL"
    opAddrGRegSI = "SI"

    opAddrGRegEAX = "EAX"
    opAddrGRegEBP = "EBP"
    opAddrGRegECX = "ECX"
    opAddrGRegEDI = "EDI"
    opAddrGRegEDX = "EDX"
    opAddrGRegESI = "ESI"

    opAddrSReg = "SREG"
    opAddrSRegDS = "DS"
    opAddrSRegES = "ES"
    opAddrSRegCX = "CX"
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
    opkGRegAX = "ax"
    opkGRegBP = "bp"
    opkGRegCL = "cl"
    opkGRegDI = "di"
    opkGRegDX = "dx"
    opkGRegEAX = "eax"
    opkGRegEBP = "ebp"
    opkGRegECX = "ecx"
    opkGRegEDI = "edi"
    opkGRegEDX = "edx"
    opkGRegESI = "esi"
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
    opkSRegCX = "cx"
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
    of opkGRegAH, opkGRegAL, opkGRegCL, opkSRegGS, opkSRegSS:
      opData8

    of opkGRegAX, opkSRegDS, opkGregDX, opkGRegBP, opkSRegES, opkSRegCS,
       opkSRegFS, opkSRegCX,
       opkDTregGDTR, opkDTregIDTR, opkDTregLDTR, opkTR, opkMSW:
      opData16

    of opkGRegEAX, opkGRegEBP, opkGRegECX,
       opkGRegEDI, opkGREgEDX, opkGRegESI,
       opkEFlags:
      opData32

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
       opkRel16_32, opkRel8,
       opkMoffs8, opkMoffs16_32:
      opAddrImm

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
    of opkGRegAX: opAddrGRegAX
    of opkGRegDX: opAddrGRegDX
    of opkGRegBP: opAddrGRegBP
    of opkGRegDI: opAddrGRegDI
    of opkGRegSI: opAddrGregSI

    of opkGRegEAX: opAddrGRegEAX
    of opkGRegEBP: opAddrGRegEBP
    of opkGRegECX: opAddrGRegECX
    of opkGRegEDI: opAddrGRegEDI
    of opkGRegEDX: opAddrGRegEDX
    of opkGRegESI: opAddrGRegESI

    of opkSReg: opAddrSReg
    of opkSRegDS: opAddrSRegDS
    of opkSRegES: opAddrSRegES
    of opkSRegCX: opAddrSRegCX
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
