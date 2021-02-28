const memorySize = 1024 * 1024 * 512

type
  Byte* = uint8
  Word* = uint16
  DWord* = uint32
  Ptr* = uint32

  Reg3Mode = enum
    r3m8Bit
    r3m16Bit
    r3m32Bit

  Split16 = object
    rHigh*: Byte
    rLow*: Byte

  Reg3 {.union.} = object
    rSplit*: Split16
    rReg*: Word
    rExt*: DWord

  Reg2Mode = enum
    r2m16Bit
    r2m32Bit

  Reg2 {.union.} = object
    rReg*: Word
    rExt*: DWord

  Reg1 = object
    rReg*: Word

  RegEFlags = object

  Cpu* = object
    acc*: Reg3 ## Accumulator register `eax`/`ax`/`ah`/`al`
    base*: Reg3 ## Base register `ebx`/`bx`/`bh`/`bl`
    count*: Reg3 ## Count register `ecx`/`cx`/`ch`/`cl`
    data*: Reg3 ## Data register `edx`/`dx`/`dh`/`dl`

    sourceIdx*: Reg2
    destIdx*: Reg2
    basePtr*: Reg2
    stackPtr*: Reg2

    instrPtr*: Reg2

    codeSegm*: Reg1
    dataSegm*: Reg1
    extraSegm*: Reg1
    fSegm*: Reg1
    gSegm*: Reg1
    stackSegm*: Reg1

  Emulator* = object
    cpu*: Cpu
    memory*: ref array[memorySize , Byte]

  OpcodeImpl = proc(emu: var Emulator)

var opcodeTable*: array[256, OpcodeImpl]

using
  cpu: var Cpu
  emu: var Emulator

template eip*(cpu: var Cpu): untyped = cpu.instrPtr.rExt
template ip*(cpu: var Cpu): untyped = cpu.instrPtr.rReg
template esp*(cpu: var Cpu): untyped = cpu.stackPtr.rExt
template sp*(cpu: var Cpu): untyped = cpu.stackPtr.rReg


static:
  doAssert sizeof(Reg2) == sizeof(DWord)
  doAssert sizeof(Reg3) == sizeof(DWord)


proc getPhysAddr(emu; segIdx: int, offset: uint32, write: uint8): Ptr =
  discard

proc getByteCode(emu; idx: int): Byte =
  # let addr = getPhysAddr(emu, )
  var xAddr: Ptr
  emu.memory[xAddr]

proc mainLoop*(emu) =
  while emu.cpu.eip < memorySize:
    let op: Byte = getByteCode(emu, 0)
