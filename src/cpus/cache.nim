import std/[strutils, strformat, times, options]
import hmisc/core/all
import hmisc/algo/[clformat, clformat_interpolate]

type
  OpcKind = enum
    AddAA    = "add A, A"
    AddAB    = "add A, B"
    AddAMemB = "add A, (B)"
    AddANum  = "add A, $$$#"
    AddAMem  = "add A, @$#"
    SubAA    = "sub A, A"
    SubAB    = "sub A, B"
    SubAMemB = "sub A, (B)"
    SubANum  = "sub A, $$$#"
    SubAMem  = "sub A, @$#"
    IncA     = "inc A"
    IncB     = "inc B"
    DecA     = "dec A"
    DecB     = "dec B"
    ShlA     = "shl A"
    ShlB     = "shl B"
    ShrA     = "shr A"
    ShrB     = "shr B"
    MovAB    = "mov A, B"
    MovAMemA = "mov A, (A)"
    MovAMemB = "mov A, (B)"
    MovANum  = "mov A, $$$#"
    MovAMem  = "mov A, @$#"
    MovBA    = "mov B, A"
    MovBMemA = "mov B, (A)"
    MovBMemB = "mov B, (B)"
    MovBNum  = "mov B, $$$#"
    MovBMem  = "mov B, @$#"
    MovMemAB = "mov (A), B"
    MovMemBA = "mov (B), A"
    MovMemA  = "mov @$#, A"
    MovMemB  = "mov @$#, B"
    PushA    = "push A"
    PushB    = "push B"
    PopA     = "pop A"
    PopB     = "pop B"
    Jmp      = "jmp $#"
    Jzero    = "jz $#"
    JLess    = "jl $#"
    Jgreat   = "jg $#"
    Jcarry   = "jc $#"
    Nop      = "nop"


  Opc = object
    idx: int
    kind: OpcKind
    arg: uint8

func opc(kind: OpcKind, arg: uint8 = 0): Opc =
  Opc(kind: kind, arg: arg)

func `$`(opc: Opc): string =
  # result.addf("[$#]: ", $opc.idx)
  result.addf($opc.kind, $opc.arg)

type
  Cache[Lines: static[int]; T] = object
    lines: array[Lines, tuple[data: T, active: bool, address: Slice[uint32]]]

  Cpu = object
    pc: int
    sp: int
    regA: uint8
    regB: uint8
    mem: array[256, uint8]
    lastZero: bool
    lastPositive: bool
    lastNegative: bool
    lastCarry: bool

    memsetCount: int
    memgetCount: int
    opgetCount: int

    ops: seq[Opc]
    instrCache: Cache[4, Opc]
    dataCache: Cache[4, uint8]


proc getAt[L, T](c: Cache[L, T], address: uint32): Option[T] =
  for (data, active, ad) in c.lines:
    if address in ad:
      return some data

proc setAt[L, T](c: var Cache[L, T], address: uint32, value: T) =
  for idx in 0 ..< c.lines.len:
    if not c.lines[idx].active:
      c.lines[idx].active = true
      c.lines[idx].data = value
      c.lines[idx].address = address .. address + 7
      return

  c.lines[0] = (value, true, address .. address + 7)

proc memset(cpu: var Cpu, mem: uint, value: uint8) =
  inc cpu.memsetCount
  cpu.mem[mem] = uint8(value and 0xFF)

proc memget(cpu: var Cpu, mem: uint32): uint8 =
  let val = cpu.dataCache.getAt(mem)
  if val.isSome():
    echo "Data cache hit @", mem
    return val.get()

  else:
    inc cpu.memgetCount
    result = cpu.mem[mem]
    cpu.dataCache.setAt(mem, result)
  # echo clfmt"    {result} = [{mem:,fg-red}]"

proc opget(cpu: var Cpu): Opc =
  inc cpu.opgetCount
  return cpu.ops[cpu.pc]


proc loop(cpu: var Cpu) =
  var cnt = 0
  template cmdGet[T](arg: T): T =
    inc cpu.opgetCount
    arg

  while cpu.pc < cpu.ops.len:
    let op = cpu.opget()
    echo $clfmt"{cnt:<3}| {cpu.pc:<3,fg-blue} {op:<15} [A:{cpu.regA:^3,fg-red}][B:{cpu.regB:^3,fg-red}] "
         # $clfmt"0: {cpu.mem[0]:,fg-green} 4: {cpu.mem[4]:,fg-green}"
    inc cnt
    var math = false
    case op.kind.cmdGet():
      of AddANum: cpu.regA += op.arg.cmdGet()
      of MovMemA: cpu.memset(op.arg.cmdGet(), cpu.regA)
      of MovANum: cpu.regA = op.arg.cmdGet()
      of MovBNum: cpu.regB = op.arg.cmdGet()
      of MovMemBA: cpu.memset(cpu.regB, cpu.regA)
      of MovAMem: cpu.regA = cpu.memget(op.arg.cmdGet())
      of AddAMem: cpu.regA += cpu.memget(op.arg.cmdGet())
      of Nop: discard
      of Jmp:
        echo clfmt">>>  jump to {op.arg:,fg-red}"
        cpu.pc = int(op.arg.cmdGet())
        continue

      of Jzero:
        echo clfmt"???  if {cpu.lastZero} - jump to {op.arg:,fg-red}"
        if cpu.lastZero:
          echo ">>>  do jump"
          cpu.pc = int(op.arg.cmdGet())
          continue

      of DecB:
        math = true
        dec cpu.regB
        cpu.lastZero = cpu.regA == 0

      of DecA:
        math = true
        dec cpu.regA
        cpu.lastZero = cpu.regA == 0

      else:
        assert false, $op

    inc cpu.pc


var cpu: Cpu
cpu.ops = @[
  # [0] mov A, $5
  opc(MovANum, 5),
  # [1] mov @0, A
  opc(MovMemA, 0),
  # [2] mov A, $0
  opc(MovANum, 0),
  # [3[ mov @4, A
  opc(MovMemA, 4),
  # more:
  # [4] mov A, @4
  opc(MovAMem, 4),
  # [5] add A, @0
  opc(AddAMem, 0),
  # [6] mov @4, A
  opc(MovMemA, 4),
  # [7] mov A, @0
  opc(MovAMem, 0),
  # [8] dec A
  opc(DecA),
  # [9] jz end
  opc(JZero, 12),
  # [10] mov @0, A
  opc(MovMemA, 0),
  # [11] jmp more
  opc(Jmp, 4),
  # end:
  # [12] nop
  opc(Nop)
]

const N = 10
cpu.ops = @[
  opc(MovANum, N), # [0]
  opc(MovBNum, N), # [1]
  opc(MovMemBA), # [2]
  opc(DecA), # [3]
  opc(DecB), # [4]
  opc(JZero, 7), # [5]
  opc(Jmp, 2), # [6]
  opc(Nop), # [7]]
]

for idx, op in mpairs(cpu.ops):
  op.idx = idx

startHax()
let start = cpuTime()
loop(cpu)
echo cpuTime() - start

for i in 0 .. 12:
  echov cpu.mem[i]

echo &"""
direct memget: {cpu.memgetCount}
direct memset: {cpu.memsetCount}
opget count  : {cpu.opgetCount}
"""

echov cpu.memget(4)
