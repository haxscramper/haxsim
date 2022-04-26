import std/[strformat, strutils, macros, tables]

import hmisc/core/all
import hmisc/algo/clformat
import hmisc/other/hpprint

var opcodesCycles = [
  4.uint8, 10, 7,  5,  5,  5,  7,  4,  4,  10, 7,  5,  5,  5,
  7,       4,  4,  10, 7,  5,  5,  5,  7,  4,  4,  10, 7,  5,
  5,       5,  7,  4,  4,  10, 16, 5,  5,  5,  7,  4,  4,  10,
  16,      5,  5,  5,  7,  4,  4,  10, 13, 5,  10, 10, 10,
  4,       4,  10, 13, 5,  5,  5,  7,  4,  5,  5,  5,  5,  5,
  5,       7,  5,  5,  5,  5,  5,  5,  5,  7,  5,  5,  5,  5,  5,
  5,       5,  7,  5,  5,  5,  5,  5,  5,  5,  7,  5,  5,  5,  5,
  5,       5,  5,  7,  5,  5,  5,  5,  5,  5,  5,  7,  5,  7,  7,
  7,       7,  7,  7,  7,  7,  5,  5,  5,  5,  5,  5,  7,  5,  4,
  4,       4,  4,  4,  4,  7,  4,  4,  4,  4,  4,  4,  4,  7,  4,
  4,       4,  4,  4,  4,  4,  7,  4,  4,  4,  4,  4,  4,  4,  7,
  4,       4,  4,  4,  4,  4,  4,  7,  4,  4,  4,  4,  4,  4,  4,
  7,       4,  4,  4,  4,  4,  4,  4,  7,  4,  4,  4,  4,  4,  4,
  4,       7,  4,  5,  10, 10, 10, 11, 11, 7,  11, 5,
  10,      10, 10, 11, 17, 7,  11, 5,  10, 10, 10,
  11,      11, 7,  11, 5,  10, 10, 10, 11, 17, 7,  11,
  5,       10, 10, 18, 11, 11, 7,  11, 5,  5,  10, 4,
  11,      17, 7,  11, 5,  10, 10, 4,  11, 11, 7,  11,
  5,       5,  10, 4,  11, 17, 7,  11,
]



type
  Opc* = enum
    opNop     = (0x00, "nop")
    opLxib    = (0x01, "lxi b,#")
    opStaxb   = (0x02, "stax b")
    opInxb    = (0x03, "inx b")
    opInrb    = (0x04, "inr b")
    opDcrb    = (0x05, "dcr b")
    opMvib    = (0x06, "mvi b,#")
    opRlc     = (0x07, "rlc")
    opIll     = (0x08, "ill")
    opDadb    = (0x09, "dad b")
    opLdaxb   = (0x0A, "ldax b")
    opDcxb    = (0x0B, "dcx b")
    opInrc    = (0x0C, "inr c")
    opDcrc    = (0x0D, "dcr c")
    opMvic    = (0x0E, "mvi c,#")
    opRrc     = (0x0F, "rrc")
    opIll1    = (0x10, "ill")
    opLxid    = (0x11, "lxi d,#")
    opStaxd   = (0x12, "stax d")
    opInxd    = (0x13, "inx d")
    opInrd    = (0x14, "inr d")
    opDcrd    = (0x15, "dcr d")
    opMvid    = (0x16, "mvi d,#")
    opRal     = (0x17, "ral")
    opIll2    = (0x18, "ill")
    opDadd    = (0x19, "dad d")
    opLdaxd   = (0x1A, "ldax d")
    opDcxd    = (0x1B, "dcx d")
    opInre    = (0x1C, "inr e")
    opDcre    = (0x1D, "dcr e")
    opMvie    = (0x1E, "mvi e,#")
    opRar     = (0x1F, "rar")
    opIll3    = (0x20, "ill")
    opLxih    = (0x21, "lxi h,#")
    opShld    = (0x22, "shld")
    opInxh    = (0x23, "inx h")
    opInrh    = (0x24, "inr h")
    opDcrh    = (0x25, "dcr h")
    opMvih    = (0x26, "mvi h,#")
    opDaa     = (0x27, "daa")
    opIll4    = (0x28, "ill")
    opDadh    = (0x29, "dad h")
    opLhld    = (0x2A, "lhld")
    opDcxh    = (0x2B, "dcx h")
    opInrl    = (0x2C, "inr l")
    opDcrl    = (0x2D, "dcr l")
    opMvil    = (0x2E, "mvi l,#")
    opCma     = (0x2F, "cma")
    opIll5    = (0x30, "ill")
    opLxisp   = (0x31, "lxi sp,#")
    opStaAbs  = (0x32, "sta $")
    opInxsp   = (0x33, "inx sp")
    opInrM    = (0x34, "inr M")
    opDcrM    = (0x35, "dcr M")
    opMviM    = (0x36, "mvi M,#")
    opStc     = (0x37, "stc")
    opIll6    = (0x38, "ill")
    opDadsp   = (0x39, "dad sp")
    opLdaAbs  = (0x3A, "lda $")
    opDcxsp   = (0x3B, "dcx sp")
    opInra    = (0x3C, "inr a")
    opDcra    = (0x3D, "dcr a")
    opMvia    = (0x3E, "mvi a,#")
    opCmc     = (0x3F, "cmc")
    opMovb_b  = (0x40, "mov b,b")
    opMovb_c  = (0x41, "mov b,c")
    opMovb_d  = (0x42, "mov b,d")
    opMovb_e  = (0x43, "mov b,e")
    opMovb_h  = (0x44, "mov b,h")
    opMovb_l  = (0x45, "mov b,l")
    opMovb_M  = (0x46, "mov b,M")
    opMovb_a  = (0x47, "mov b,a")
    opMovc_b  = (0x48, "mov c,b")
    opMovc_c  = (0x49, "mov c,c")
    opMovc_d  = (0x4A, "mov c,d")
    opMovc_e  = (0x4B, "mov c,e")
    opMovc_h  = (0x4C, "mov c,h")
    opMovc_l  = (0x4D, "mov c,l")
    opMovc_M  = (0x4E, "mov c,M")
    opMovc_a  = (0x4F, "mov c,a")
    opMovd_b  = (0x50, "mov d,b")
    opMovd_c  = (0x51, "mov d,c")
    opMovd_d  = (0x52, "mov d,d")
    opMovd_e  = (0x53, "mov d,e")
    opMovd_h  = (0x54, "mov d,h")
    opMovd_l  = (0x55, "mov d,l")
    opMovd_M  = (0x56, "mov d,M")
    opMovd_a  = (0x57, "mov d,a")
    opMove_b  = (0x58, "mov e,b")
    opMove_c  = (0x59, "mov e,c")
    opMove_d  = (0x5A, "mov e,d")
    opMove_e  = (0x5B, "mov e,e")
    opMove_h  = (0x5C, "mov e,h")
    opMove_l  = (0x5D, "mov e,l")
    opMove_M  = (0x5E, "mov e,M")
    opMove_a  = (0x5F, "mov e,a")
    opMovh_b  = (0x60, "mov h,b")
    opMovh_c  = (0x61, "mov h,c")
    opMovh_d  = (0x62, "mov h,d")
    opMovh_e  = (0x63, "mov h,e")
    opMovh_h  = (0x64, "mov h,h")
    opMovh_l  = (0x65, "mov h,l")
    opMovh_M  = (0x66, "mov h,M")
    opMovh_a  = (0x67, "mov h,a")
    opMovl_b  = (0x68, "mov l,b")
    opMovl_c  = (0x69, "mov l,c")
    opMovl_d  = (0x6A, "mov l,d")
    opMovl_e  = (0x6B, "mov l,e")
    opMovl_h  = (0x6C, "mov l,h")
    opMovl_l  = (0x6D, "mov l,l")
    opMovl_M  = (0x6E, "mov l,M")
    opMovl_a  = (0x6F, "mov l,a")
    opMovM_b  = (0x70, "mov M,b")
    opMovM_c  = (0x71, "mov M,c")
    opMovM_d  = (0x72, "mov M,d")
    opMovM_e  = (0x73, "mov M,e")
    opMovM_h  = (0x74, "mov M,h")
    opMovM_l  = (0x75, "mov M,l")
    opHlt     = (0x76, "hlt")
    opMovM_a  = (0x77, "mov M,a")
    opMova_b  = (0x78, "mov a,b")
    opMova_c  = (0x79, "mov a,c")
    opMova_d  = (0x7A, "mov a,d")
    opMova_e  = (0x7B, "mov a,e")
    opMova_h  = (0x7C, "mov a,h")
    opMova_l  = (0x7D, "mov a,l")
    opMova_M  = (0x7E, "mov a,M")
    opMova_a  = (0x7F, "mov a,a")
    opAddb    = (0x80, "add b")
    opAddc    = (0x81, "add c")
    opAddd    = (0x82, "add d")
    opAdde    = (0x83, "add e")
    opAddh    = (0x84, "add h")
    opAddl    = (0x85, "add l")
    opAddM    = (0x86, "add M")
    opAdda    = (0x87, "add a")
    opAdcb    = (0x88, "adc b")
    opAdcc    = (0x89, "adc c")
    opAdcd    = (0x8A, "adc d")
    opAdce    = (0x8B, "adc e")
    opAdch    = (0x8C, "adc h")
    opAdcl    = (0x8D, "adc l")
    opAdcM    = (0x8E, "adc M")
    opAdca    = (0x8F, "adc a")
    opSubb    = (0x90, "sub b")
    opSubc    = (0x91, "sub c")
    opSubd    = (0x92, "sub d")
    opSube    = (0x93, "sub e")
    opSubh    = (0x94, "sub h")
    opSubl    = (0x95, "sub l")
    opSubM    = (0x96, "sub M")
    opSuba    = (0x97, "sub a")
    opSbbb    = (0x98, "sbb b")
    opSbbc    = (0x99, "sbb c")
    opSbbd    = (0x9A, "sbb d")
    opSbbe    = (0x9B, "sbb e")
    opSbbh    = (0x9C, "sbb h")
    opSbbl    = (0x9D, "sbb l")
    opSbbM    = (0x9E, "sbb M")
    opSbba    = (0x9F, "sbb a")
    opAnab    = (0xA0, "ana b")
    opAnac    = (0xA1, "ana c")
    opAnad    = (0xA2, "ana d")
    opAnae    = (0xA3, "ana e")
    opAnah    = (0xA4, "ana h")
    opAnal    = (0xA5, "ana l")
    opAnaM    = (0xA6, "ana M")
    opAnaa    = (0xA7, "ana a")
    opXrab    = (0xA8, "xra b")
    opXrac    = (0xA9, "xra c")
    opXrad    = (0xAA, "xra d")
    opXrae    = (0xAB, "xra e")
    opXrah    = (0xAC, "xra h")
    opXral    = (0xAD, "xra l")
    opXraM    = (0xAE, "xra M")
    opXraa    = (0xAF, "xra a")
    opOrab    = (0xB0, "ora b")
    opOrac    = (0xB1, "ora c")
    opOrad    = (0xB2, "ora d")
    opOrae    = (0xB3, "ora e")
    opOrah    = (0xB4, "ora h")
    opOral    = (0xB5, "ora l")
    opOraM    = (0xB6, "ora M")
    opOraa    = (0xB7, "ora a")
    opCmpb    = (0xB8, "cmp b")
    opCmpc    = (0xB9, "cmp c")
    opCmpd    = (0xBA, "cmp d")
    opCmpe    = (0xBB, "cmp e")
    opCmph    = (0xBC, "cmp h")
    opCmpl    = (0xBD, "cmp l")
    opCmpM    = (0xBE, "cmp M")
    opCmpa    = (0xBF, "cmp a")
    opRnz     = (0xC0, "rnz")
    opPopb    = (0xC1, "pop b")
    opJnzAbs  = (0xC2, "jnz $")
    opJmpAbs  = (0xC3, "jmp $")
    opCnzAbs  = (0xC4, "cnz $")
    opPushb   = (0xC5, "push b")
    opAdiImm  = (0xC6, "adi #")
    opRst0    = (0xC7, "rst 0")
    opRz      = (0xC8, "rz")
    opRet     = (0xC9, "ret")
    opJzAbs   = (0xCA, "jz $")
    opIll7    = (0xCB, "ill")
    opCzAbs   = (0xCC, "cz $")
    opCallAbs = (0xCD, "call $")
    opAciImm  = (0xCE, "aci #")
    opRst1    = (0xCF, "rst 1")
    opRnc     = (0xD0, "rnc")
    opPopd    = (0xD1, "pop d")
    opJncAbs  = (0xD2, "jnc $")
    opOutp    = (0xD3, "out p")
    opCncAbs  = (0xD4, "cnc $")
    opPushd   = (0xD5, "push d")
    opSuiImm  = (0xD6, "sui #")
    opRst2    = (0xD7, "rst 2")
    opRc      = (0xD8, "rc")
    opIll8    = (0xD9, "ill")
    opJcAbs   = (0xDA, "jc $")
    opInp     = (0xDB, "in p")
    opCcAbs   = (0xDC, "cc $")
    opIll9    = (0xDD, "ill")
    opSbiImm  = (0xDE, "sbi #")
    opRst3    = (0xDF, "rst 3")
    opRpo     = (0xE0, "rpo")
    opPoph    = (0xE1, "pop h")
    opJpoAbs  = (0xE2, "jpo $")
    opXthl    = (0xE3, "xthl")
    opCpoAbs  = (0xE4, "cpo $")
    opPushh   = (0xE5, "push h")
    opAniImm  = (0xE6, "ani #")
    opRst4    = (0xE7, "rst 4")
    opRpe     = (0xE8, "rpe")
    opPchl    = (0xE9, "pchl")
    opJpeAbs  = (0xEA, "jpe $")
    opXchg    = (0xEB, "xchg")
    opCpeAbs  = (0xEC, "cpe $")
    opIll10   = (0xED, "ill")
    opXriImm  = (0xEE, "xri #")
    opRst5    = (0xEF, "rst 5")
    opRp      = (0xF0, "rp")
    opPoppsw  = (0xF1, "pop psw")
    opJpAbs   = (0xF2, "jp $")
    opDi      = (0xF3, "di")
    opCpAbs   = (0xF4, "cp $")
    opPushpsw = (0xF5, "push psw")
    opOriImm  = (0xF6, "ori #")
    opRst6    = (0xF7, "rst 6")
    opRm      = (0xF8, "rm")
    opSphl    = (0xF9, "sphl")
    opJmAbs   = (0xFA, "jm $")
    opEi      = (0xFB, "ei")
    opCmAbs   = (0xFC, "cm $")
    opIll11   = (0xFD, "ill")
    opCpiImm  = (0xFE, "cpi #")
    opRst7    = (0xFF, "rst 7")


type
  i8080 = object
    readByte: proc(memAddr: uint16): uint8
    writeByte: proc(memAddr: uint16, value: uint8)
    portIn: proc(port: uint8): uint8
    portOut: proc(port: uint8, value: uint8)

    hookGetB: proc(c: i8080)
    hookSetB: proc(c: i8080, value: uint8)
    hookStartTick: proc(c: i8080)
    procEndTick: proc(c: i8080)

    cyc: uint64

    tickIdx: uint8
    activeOpc: Opc
    detailedMode: bool

    aluRes: uint8
    aluIn1: uint8
    aluIn2: uint8
    addrBus: uint16
    dataBus: uint8

    pc, sp: uint16
    a, b, c, d, e, h, l: uint8
    sf {.bitsize:1.}, zf {.bitsize:1.}, hf {.bitsize:1.}, pf {.bitsize:1.}, cf {.bitsize:1.}, iff {.bitsize:1.}: bool
    halted {.bitsize:1.}: bool
    interrupt_pending {.bitsize:1.}: bool

    interrupt_vector: uint8
    interrupt_delay: uint8

proc i8080_rb*(c: var i8080; aAddr: uint16): uint8 =
  return c.read_byte(aAddr)

proc i8080_wb*(c: var i8080; aAddr: uint16; val: uint8) =
  c.write_byte(aAddr, val)

proc i8080_rw*(c: var i8080; aAddr: uint16): uint16 =
  return c.read_byte(aAddr + 1) shl 8 or
      c.read_byte(aAddr)

proc i8080_ww*(c: var i8080; aAddr: uint16; val: uint16) =
  c.write_byte(aAddr, uint8(val and 0xFF))
  c.write_byte(aAddr + 1, uint8(val shr 8))

proc i8080_next_byte*(c: var i8080): uint8 =
  result = i8080_rb(c, c.pc)
  inc c.pc

proc i8080_next_word*(c: var i8080): uint16 =
  result = i8080_rw(c, c.pc)
  c.pc += 2

proc i8080_set_bc*(c: var i8080; val: uint16) =
  c.b = uint8(val shr 8)
  c.c = uint8(val and 0xFF)

proc i8080_set_de*(c: var i8080; val: uint16) =
  c.d = uint8(val shr 8)
  c.e = uint8(val and 0xFF)

proc i8080_set_hl*(c: var i8080; val: uint16) =
  c.h = uint8(val shr 8)
  c.l = uint8(val and 0xFF)

proc i8080_get_bc*(c: var i8080): uint16 =
  return (c.b.uint16 shl 8) or c.c

proc i8080_get_de*(c: var i8080): uint16 =
  return (c.d.uint16 shl 8) or c.e

proc i8080_get_hl*(c: var i8080): uint16 =
  return (c.h.uint16 shl 8) or c.l

proc i8080_push_stack*(c: var i8080; val: uint16) =
  c.sp -= 2
  i8080_ww(c, c.sp, val)

proc i8080_pop_stack*(c: var i8080): uint16 =
  var val: uint16 = i8080_rw(c, c.sp)
  c.sp += 2
  return val

proc parity*(val: uint8): bool =
  var nb_one_bits: uint8 = 0
  block:
    var i: cint = 0
    while i < 8:
      nb_one_bits += ((val shr i) and 1)
      inc i
  return (nb_one_bits and 1) == 0

proc carry*(bit_no: cint; a: uint8; b: uint8; cy: bool): bool =
  var res: int16 = int16(a) + int16(b) + int8(cy)
  var carry: int16 = res xor int16(a) xor int16(b)
  return bool(carry and (1 shl bit_no))

template setZsp(c, val): untyped =
  c.zf = (val) == 0
  c.sf = bool((val) shr 7)
  c.pf = parity(val)


proc i8080_add*(c: var i8080; reg: ptr uint8; val: uint8; cy: bool) =
  var res: uint8 = reg[] + val + uint8(cy)
  c.cf = carry(8, reg[], val, cy)
  c.hf = carry(4, reg[], val, cy)
  setZsp(c, res)
  reg[] = res

proc i8080_sub*(c: var i8080; reg: ptr uint8; val: uint8; cy: bool) =
  i8080_add(c, reg, not(val), not(cy))
  c.cf = not(c.cf)

proc i8080_dad*(c: var i8080; val: uint16) =
  c.cf = bool(((i8080_get_hl(c) + val) shr 16) and 1)
  i8080_set_hl(c, i8080_get_hl(c) + val)

proc i8080_inr*(c: var i8080; val: uint8): uint8 =
  result = val + 1
  c.hf = ((result and 0xF) == 0)
  setZsp(c, result)

proc i8080_dcr*(c: var i8080; val: uint8): uint8 =
  result = val - 1
  c.hf = not(((result and 0xF) == 0xF))
  setZsp(c, result)

proc i8080_ana*(c: var i8080; val: uint8) =
  var result: uint8 = c.a and val
  c.cf = bool(0)
  c.hf = (((c.a or val) and 0x08) != 0)
  setZsp(c, result)
  c.a = result

proc i8080_xra*(c: var i8080; val: uint8) =
  c.a = val xor c.a
  c.cf = false
  c.hf = false
  setZsp(c, c.a)

proc i8080_ora*(c: var i8080; val: uint8) =
  c.a = val or c.a
  c.cf = false
  c.hf = false
  setZsp(c, c.a)

proc i8080_cmp*(c: var i8080; val: uint8) =
  var result: int16 = int16(c.a - val)
  c.cf = bool(result shr 8)
  c.hf = bool(not((c.a.int16 xor result xor val.int16)).uint8 and 0x10)
  setZsp(c, result.uint8 and 0xFF)

proc i8080_jmp*(c: var i8080; aAddr: uint16) =
  c.pc = aAddr

proc i8080_cond_jmp*(c: var i8080; condition: bool) =
  var aAddr: uint16 = i8080_next_word(c)
  if condition:
    c.pc = aAddr

proc i8080_call*(c: var i8080; aAddr: uint16) =
  i8080_push_stack(c, c.pc)
  i8080_jmp(c, aAddr)

proc i8080_cond_call*(c: var i8080; condition: bool) =
  var aAddr: uint16 = i8080_next_word(c)
  if condition:
    i8080_call(c, aAddr)
    c.cyc += 6

proc i8080_ret*(c: var i8080) =
  c.pc = i8080_pop_stack(c)

proc i8080_cond_ret*(c: var i8080; condition: bool) =
  if condition:
    i8080_ret(c)
    c.cyc += 6

proc i8080_push_psw*(c: var i8080) =
  var psw: uint8 = 0
  psw = c.sf.uint8 shl 7 or psw
  psw = c.zf.uint8 shl 6 or psw
  psw = c.hf.uint8 shl 4 or psw
  psw = c.pf.uint8 shl 2 or psw
  psw = 1 shl 1 or psw
  psw = c.cf.uint8 shl 0 or psw
  i8080_push_stack(c, c.a shl 8 or psw)

proc i8080_pop_psw*(c: var i8080) =
  var af: uint16 = i8080_pop_stack(c)
  c.a = uint8(af shr 8)
  var psw: uint8 = uint8(af and 0xFF)
  c.sf = bool((psw shr 7) and 1)
  c.zf = bool((psw shr 6) and 1)
  c.hf = bool((psw shr 4) and 1)
  c.pf = bool((psw shr 2) and 1)
  c.cf = bool((psw shr 0) and 1)

proc i8080_rlc*(c: var i8080) =
  c.cf = bool(c.a.uint8 shr 7)
  c.a = ((c.a.uint8 shl 1) or c.cf.uint8)

proc i8080_rrc*(c: var i8080) =
  c.cf = bool(c.a.uint8 and 1)
  c.a = ((c.a.uint8 shr 1) or uint8(c.cf.uint8 shl 7))

proc i8080_ral*(c: var i8080) =
  var cy: bool = c.cf
  c.cf = bool(c.a.uint8 shr 7)
  c.a = ((c.a.uint8 shl 1) or cy.uint8)

proc i8080_rar*(c: var i8080) =
  var cy: bool = c.cf
  c.cf = bool(c.a.uint8 and 1)
  c.a = ((c.a.uint8 shr 1) or (cy.uint8 shl 7))

proc i8080_daa*(c: var i8080) =
  var cy: bool = c.cf
  var correction: uint8 = 0
  var lsb: uint8 = c.a and 0x0F
  var msb: uint8 = c.a shr 4
  if c.hf or (lsb > 9):
    correction += 0x06
  if c.cf or (msb > 9) or ((msb >= 9) and (lsb > 9)):
    correction += 0x60
    cy = true
  i8080_add(c, addr c.a, correction, false)
  c.cf = cy

proc i8080_xchg*(c: var i8080) =
  var de: uint16 = i8080_get_de(c)
  i8080_set_de(c, i8080_get_hl(c))
  i8080_set_hl(c, de)

proc i8080_xthl*(c: var i8080) =
  var val: uint16 = i8080_rw(c, c.sp)
  i8080_ww(c, c.sp, i8080_get_hl(c))
  i8080_set_hl(c, val)

proc i8080_execute*(c: var i8080; opcode: Opc) =
  c.cyc += oPCODES_CYCLES[opcode.uint8]
  if c.interrupt_delay > 0:
    c.interrupt_delay -= 1
  case opcode:
    of opMova_a: c.a = c.a
    of opMova_b: c.a = c.b
    of opMova_c: c.a = c.c
    of opMova_d: c.a = c.d
    of opMova_e: c.a = c.e
    of opMova_h: c.a = c.h
    of opMova_l: c.a = c.l
    of opMova_M: c.a = i8080_rb(c, i8080_get_hl(c))
    of opLdaxb: c.a = i8080_rb(c, i8080_get_bc(c))
    of opLdaxd: c.a = i8080_rb(c, i8080_get_de(c))
    of opLdaAbs: c.a = i8080_rb(c, i8080_next_word(c))
    of opMovb_a: c.b = c.a
    of opMovb_b: c.b = c.b
    of opMovb_c: c.b = c.c
    of opMovb_d: c.b = c.d
    of opMovb_e: c.b = c.e
    of opMovb_h: c.b = c.h
    of opMovb_l: c.b = c.l
    of opMovb_M: c.b = i8080_rb(c, i8080_get_hl(c))
    of opMovc_a: c.c = c.a
    of opMovc_b: c.c = c.b
    of opMovc_c: c.c = c.c
    of opMovc_d: c.c = c.d
    of opMovc_e: c.c = c.e
    of opMovc_h: c.c = c.h
    of opMovc_l: c.c = c.l
    of opMovc_M: c.c = i8080_rb(c, i8080_get_hl(c))
    of opMovd_a: c.d = c.a
    of opMovd_b: c.d = c.b
    of opMovd_c: c.d = c.c
    of opMovd_d: c.d = c.d
    of opMovd_e: c.d = c.e
    of opMovd_h: c.d = c.h
    of opMovd_l: c.d = c.l
    of opMovd_M: c.d = i8080_rb(c, i8080_get_hl(c))
    of opMove_a: c.e = c.a
    of opMove_b: c.e = c.b
    of opMove_c: c.e = c.c
    of opMove_d: c.e = c.d
    of opMove_e: c.e = c.e
    of opMove_h: c.e = c.h
    of opMove_l: c.e = c.l
    of opMove_M: c.e = i8080_rb(c, i8080_get_hl(c))
    of opMovh_a: c.h = c.a
    of opMovh_b: c.h = c.b
    of opMovh_c: c.h = c.c
    of opMovh_d: c.h = c.d
    of opMovh_e: c.h = c.e
    of opMovh_h: c.h = c.h
    of opMovh_l: c.h = c.l
    of opMovh_M: c.h = i8080_rb(c, i8080_get_hl(c))
    of opMovl_a: c.l = c.a
    of opMovl_b: c.l = c.b
    of opMovl_c: c.l = c.c
    of opMovl_d: c.l = c.d
    of opMovl_e: c.l = c.e
    of opMovl_h: c.l = c.h
    of opMovl_l: c.l = c.l
    of opMovl_M: c.l = i8080_rb(c, i8080_get_hl(c))
    of opMovM_a: i8080_wb(c, i8080_get_hl(c), c.a)
    of opMovM_b: i8080_wb(c, i8080_get_hl(c), c.b)
    of opMovM_c: i8080_wb(c, i8080_get_hl(c), c.c)
    of opMovM_d: i8080_wb(c, i8080_get_hl(c), c.d)
    of opMovM_e: i8080_wb(c, i8080_get_hl(c), c.e)
    of opMovM_h: i8080_wb(c, i8080_get_hl(c), c.h)
    of opMovM_l: i8080_wb(c, i8080_get_hl(c), c.l)
    of opMvia: c.a = i8080_next_byte(c)
    of opMvib: c.b = i8080_next_byte(c)
    of opMvic: c.c = i8080_next_byte(c)
    of opMvid: c.d = i8080_next_byte(c)
    of opMvie: c.e = i8080_next_byte(c)
    of opMvih: c.h = i8080_next_byte(c)
    of opMvil: c.l = i8080_next_byte(c)
    of opMviM: i8080_wb(c, i8080_get_hl(c), i8080_next_byte(c))
    of opStaxb: i8080_wb(c, i8080_get_bc(c), c.a)
    of opStaxd: i8080_wb(c, i8080_get_de(c), c.a)
    of opStaAbs: i8080_wb(c, i8080_next_word(c), c.a)
    of opLxib: i8080_set_bc(c, i8080_next_word(c))
    of opLxid: i8080_set_de(c, i8080_next_word(c))
    of opLxih: i8080_set_hl(c, i8080_next_word(c))
    of opLxisp: c.sp = i8080_next_word(c)
    of opLhld: i8080_set_hl(c, i8080_rw(c, i8080_next_word(c)))
    of opShld: i8080_ww(c, i8080_next_word(c), i8080_get_hl(c))
    of opSphl: c.sp = i8080_get_hl(c)
    of opXchg: i8080_xchg(c)
    of opXthl: i8080_xthl(c)
    of opAdda: i8080_add(c, addr c.a, c.a, false)
    of opAddb: i8080_add(c, addr c.a, c.b, false)
    of opAddc: i8080_add(c, addr c.a, c.c, false)
    of opAddd: i8080_add(c, addr c.a, c.d, false)
    of opAdde: i8080_add(c, addr c.a, c.e, false)
    of opAddh: i8080_add(c, addr c.a, c.h, false)
    of opAddl: i8080_add(c, addr c.a, c.l, false)
    of opAddM: i8080_add(c, addr c.a, i8080_rb(c, i8080_get_hl(c)), false)
    of opAdiImm: i8080_add(c, addr c.a, i8080_next_byte(c), false)
    of opAdca: i8080_add(c, addr c.a, c.a, c.cf)
    of opAdcb: i8080_add(c, addr c.a, c.b, c.cf)
    of opAdcc: i8080_add(c, addr c.a, c.c, c.cf)
    of opAdcd: i8080_add(c, addr c.a, c.d, c.cf)
    of opAdce: i8080_add(c, addr c.a, c.e, c.cf)
    of opAdch: i8080_add(c, addr c.a, c.h, c.cf)
    of opAdcl: i8080_add(c, addr c.a, c.l, c.cf)
    of opAdcM: i8080_add(c, addr c.a, i8080_rb(c, i8080_get_hl(c)), c.cf)
    of opAciImm: i8080_add(c, addr c.a, i8080_next_byte(c), c.cf)
    of opSuba: i8080_sub(c, addr c.a, c.a, false)
    of opSubb: i8080_sub(c, addr c.a, c.b, false)
    of opSubc: i8080_sub(c, addr c.a, c.c, false)
    of opSubd: i8080_sub(c, addr c.a, c.d, false)
    of opSube: i8080_sub(c, addr c.a, c.e, false)
    of opSubh: i8080_sub(c, addr c.a, c.h, false)
    of opSubl: i8080_sub(c, addr c.a, c.l, false)
    of opSubM: i8080_sub(c, addr c.a, i8080_rb(c, i8080_get_hl(c)), false)
    of opSuiImm: i8080_sub(c, addr c.a, i8080_next_byte(c), false)
    of opSbba: i8080_sub(c, addr c.a, c.a, c.cf)
    of opSbbb: i8080_sub(c, addr c.a, c.b, c.cf)
    of opSbbc: i8080_sub(c, addr c.a, c.c, c.cf)
    of opSbbd: i8080_sub(c, addr c.a, c.d, c.cf)
    of opSbbe: i8080_sub(c, addr c.a, c.e, c.cf)
    of opSbbh: i8080_sub(c, addr c.a, c.h, c.cf)
    of opSbbl: i8080_sub(c, addr c.a, c.l, c.cf)
    of opSbbM: i8080_sub(c, addr c.a, i8080_rb(c, i8080_get_hl(c)), c.cf)
    of opSbiImm: i8080_sub(c, addr c.a, i8080_next_byte(c), c.cf)
    of opDadb: i8080_dad(c, i8080_get_bc(c))
    of opDadd: i8080_dad(c, i8080_get_de(c))
    of opDadh: i8080_dad(c, i8080_get_hl(c))
    of opDadsp: i8080_dad(c, c.sp)
    of opDi: c.iff = false
    of opEi: c.iff = true; c.interrupt_delay = 1
    of opNop: discard
    of opHlt: c.halted = true
    of opInra: c.a = i8080_inr(c, c.a)
    of opInrb: c.b = i8080_inr(c, c.b)
    of opInrc: c.c = i8080_inr(c, c.c)
    of opInrd: c.d = i8080_inr(c, c.d)
    of opInre: c.e = i8080_inr(c, c.e)
    of opInrh: c.h = i8080_inr(c, c.h)
    of opInrl: c.l = i8080_inr(c, c.l)
    of opInrM: i8080_wb(c, i8080_get_hl(c), i8080_inr(c, i8080_rb(c, i8080_get_hl(c))))
    of opDcra: c.a = i8080_dcr(c, c.a)
    of opDcrb: c.b = i8080_dcr(c, c.b)
    of opDcrc: c.c = i8080_dcr(c, c.c)
    of opDcrd: c.d = i8080_dcr(c, c.d)
    of opDcre: c.e = i8080_dcr(c, c.e)
    of opDcrh: c.h = i8080_dcr(c, c.h)
    of opDcrl: c.l = i8080_dcr(c, c.l)
    of opDcrM: i8080_wb(c, i8080_get_hl(c), i8080_dcr(c, i8080_rb(c, i8080_get_hl(c))))
    of opInxb: i8080_set_bc(c, i8080_get_bc(c) + 1)
    of opInxd: i8080_set_de(c, i8080_get_de(c) + 1)
    of opInxh: i8080_set_hl(c, i8080_get_hl(c) + 1)
    of opInxsp: c.sp += 1
    of opDcxb: i8080_set_bc(c, i8080_get_bc(c) - 1)
    of opDcxd: i8080_set_de(c, i8080_get_de(c) - 1)
    of opDcxh: i8080_set_hl(c, i8080_get_hl(c) - 1)
    of opDcxsp: c.sp -= 1
    of opDaa: i8080_daa(c)
    of opCma: c.a = not(c.a)
    of opStc: c.cf = true
    of opCmc: c.cf = not(c.cf)
    of opRlc: i8080_rlc(c)
    of opRrc: i8080_rrc(c)
    of opRal: i8080_ral(c)
    of opRar: i8080_rar(c)
    of opAnaa: i8080_ana(c, c.a)
    of opAnab: i8080_ana(c, c.b)
    of opAnac: i8080_ana(c, c.c)
    of opAnad: i8080_ana(c, c.d)
    of opAnae: i8080_ana(c, c.e)
    of opAnah: i8080_ana(c, c.h)
    of opAnal: i8080_ana(c, c.l)
    of opAnaM: i8080_ana(c, i8080_rb(c, i8080_get_hl(c)))
    of opAniImm: i8080_ana(c, i8080_next_byte(c))
    of opXraa: i8080_xra(c, c.a)
    of opXrab: i8080_xra(c, c.b)
    of opXrac: i8080_xra(c, c.c)
    of opXrad: i8080_xra(c, c.d)
    of opXrae: i8080_xra(c, c.e)
    of opXrah: i8080_xra(c, c.h)
    of opXral: i8080_xra(c, c.l)
    of opXraM: i8080_xra(c, i8080_rb(c, i8080_get_hl(c)))
    of opXriImm: i8080_xra(c, i8080_next_byte(c))
    of opOraa: i8080_ora(c, c.a)
    of opOrab: i8080_ora(c, c.b)
    of opOrac: i8080_ora(c, c.c)
    of opOrad: i8080_ora(c, c.d)
    of opOrae: i8080_ora(c, c.e)
    of opOrah: i8080_ora(c, c.h)
    of opOral: i8080_ora(c, c.l)
    of opOraM: i8080_ora(c, i8080_rb(c, i8080_get_hl(c)))
    of opOriImm: i8080_ora(c, i8080_next_byte(c))
    of opCmpa: i8080_cmp(c, c.a)
    of opCmpb: i8080_cmp(c, c.b)
    of opCmpc: i8080_cmp(c, c.c)
    of opCmpd: i8080_cmp(c, c.d)
    of opCmpe: i8080_cmp(c, c.e)
    of opCmph: i8080_cmp(c, c.h)
    of opCmpl: i8080_cmp(c, c.l)
    of opCmpM: i8080_cmp(c, i8080_rb(c, i8080_get_hl(c)))
    of opCpiImm: i8080_cmp(c, i8080_next_byte(c))
    of opJmpAbs: i8080_jmp(c, i8080_next_word(c))
    of opJnzAbs: i8080_cond_jmp(c, c.zf == false)
    of opJzAbs: i8080_cond_jmp(c, c.zf == true)
    of opJncAbs: i8080_cond_jmp(c, c.cf == false)
    of opJcAbs: i8080_cond_jmp(c, c.cf == true)
    of opJpoAbs: i8080_cond_jmp(c, c.pf == false)
    of opJpeAbs: i8080_cond_jmp(c, c.pf == true)
    of opJpAbs: i8080_cond_jmp(c, c.sf == false)
    of opJmAbs: i8080_cond_jmp(c, c.sf == true)
    of opPchl: c.pc = i8080_get_hl(c)
    of opCallAbs: i8080_call(c, i8080_next_word(c))
    of opCnzAbs: i8080_cond_call(c, c.zf == false)
    of opCzAbs: i8080_cond_call(c, c.zf == true)
    of opCncAbs: i8080_cond_call(c, c.cf == false)
    of opCcAbs: i8080_cond_call(c, c.cf == true)
    of opCpoAbs: i8080_cond_call(c, c.pf == false)
    of opCpeAbs: i8080_cond_call(c, c.pf == true)
    of opCpAbs: i8080_cond_call(c, c.sf == false)
    of opCmAbs: i8080_cond_call(c, c.sf == true)
    of opRet: i8080_ret(c)
    of opRnz: i8080_cond_ret(c, c.zf == false)
    of opRz: i8080_cond_ret(c, c.zf == true)
    of opRnc: i8080_cond_ret(c, c.cf == false)
    of opRc: i8080_cond_ret(c, c.cf == true)
    of opRpo: i8080_cond_ret(c, c.pf == false)
    of opRpe: i8080_cond_ret(c, c.pf == true)
    of opRp: i8080_cond_ret(c, c.sf == false)
    of opRm: i8080_cond_ret(c, c.sf == true)
    of opRst0: i8080_call(c, 0x00)
    of opRst1: i8080_call(c, 0x08)
    of opRst2: i8080_call(c, 0x10)
    of opRst3: i8080_call(c, 0x18)
    of opRst4: i8080_call(c, 0x20)
    of opRst5: i8080_call(c, 0x28)
    of opRst6: i8080_call(c, 0x30)
    of opRst7: i8080_call(c, 0x38)
    of opPushb: i8080_push_stack(c, i8080_get_bc(c))
    of opPushd: i8080_push_stack(c, i8080_get_de(c))
    of opPushh: i8080_push_stack(c, i8080_get_hl(c))
    of opPushpsw: i8080_push_psw(c)
    of opPopb: i8080_set_bc(c, i8080_pop_stack(c))
    of opPopd: i8080_set_de(c, i8080_pop_stack(c))
    of opPoph: i8080_set_hl(c, i8080_pop_stack(c))
    of opPoppsw: i8080_pop_psw(c)
    of opInp: c.a = c.port_in(i8080_next_byte(c))
    of opOutp: c.port_out(i8080_next_byte(c), c.a)
    of opIll, opIll1, opIll2, opIll3, opIll4, opIll5, opIll6: discard
    of opIll7: i8080_ret(c)
    of opIll8, opIll9, opIll10: i8080_call(c, i8080_next_word(c))
    of opIll11: i8080_jmp(c, i8080_next_word(c))

proc i8080_init*(c: var i8080) =
  c.read_byte = nil
  c.write_byte = nil
  c.port_in = nil
  c.port_out = nil
  c.cyc = 0
  c.pc = 0
  c.sp = 0
  c.a = 0
  c.b = 0
  c.c = 0
  c.d = 0
  c.e = 0
  c.h = 0
  c.l = 0
  c.sf = false
  c.zf = false
  c.hf = false
  c.pf = false
  c.cf = false
  c.iff = false
  c.halted = false
  c.interrupt_pending = false
  c.interrupt_vector = 0
  c.interrupt_delay = 0

proc i8080_step*(c: var i8080) =
  if c.interrupt_pending and c.iff and (c.interrupt_delay == 0):
    c.interrupt_pending = false
    c.iff = false
    c.halted = false
    i8080_execute(c, c.interrupt_vector.Opc)
  else:
    if not(c.halted):
      i8080_execute(c, i8080_next_byte(c).Opc)

proc i8080_interrupt*(c: var i8080; opcode: uint8) =
  c.interrupt_pending = true
  c.interrupt_vector = opcode


type
  TickedImpl = object
    args: seq[string]
    ticks: seq[NimNode]

var tickedImpls {.compiletime.}: Table[string, TickedImpl]

macro ticked(impl: untyped): untyped =
  var def: TickedImpl
  for arg in impl.params[1 .. ^1]:
    def.args.add arg[0].strVal()

  for tick in impl.body():
    def.ticks.add tick

  tickedImpls[impl.name().strVal()] = def

  result = newStmtList()

proc cpuDot(field: string): NimNode =
  nnkDotExpr.newTree(ident"c", ident(field))

proc convertStep(step: NimNode): seq[NimNode] =
  const hookReg = @["b"]
  proc aux(step: NimNode, inGet: bool): NimNode =
    case step.kind:
      of nnkIdent:
        if step.strVal() in hookReg and inGet:
          result = nnkStmtList.newTree(
            newCall(cpuDot("hookGet" & step.strVal())),
            cpuDot(step.strVal()))

        elif step.strVal() in @[
          "hl", "hf", "aluRes", "zf", "sf", "addrBus",
          "h", "l", "dataBus", "aluIn1", "aluIn2", "pf", "pc"
        ] & hookReg:
          result = cpuDot(step.strVal())

        else:
          result = step

      of nnkCall, nnkInfix, nnkCommand:
        result = newTree(step.kind, step[0])
        for arg in step[1 .. ^1]:
          result.add aux(arg, true)

      of AtomicNodes - nnkIdent:
        result = step

      of nnkAsgn:
        if step[0].strVal() in hookReg:
          let tmpName = ident"tmp"
          let tmp = newVarStmt(tmpName, aux(step[1], true))
          let asgn = aux(step[0], false)
          let hook =
            newCall(cpuDot("hookSet" & step[0].strVal()), ident"c", tmpName)

          result = quote do:
            `tmp`
            `hook`
            `asgn` = `tmpName`

        else:
          result = newTree(step.kind)
          for item in items(step):
            result.add aux(item, inGet)

      else:
        result = newTree(step.kind)
        for item in items(step):
          result.add aux(item, inGet)

  if step.kind == nnkCall and (step.len == 1 or step[1].kind != nnkStmtList):
    let name = step[0].strVal()
    for tick in tickedImpls[name].ticks:
      result.add convertStep(tick)

  else:
    result = @[aux(step[1], false)]

proc fetch(c: var i8080) =
  discard

macro doTick(body: untyped): untyped =
  var idx = 0
  var detailed = tern(
    body.len > 1 and body[1][0].eqIdent("detailed"),
    body[1][1], nil)

  var fast = body[0][1]



  if isNil(detailed):
    result = fast

  else:
    result = nnkCaseStmt.newTree(nnkDotExpr.newTree(ident"c", ident"tickIdx"))
    for stmt in detailed:
      for step in convertStep(stmt):
        result.add nnkOfBranch.newTree(newLit(idx), step)
        inc idx

    result[^1][^1].add newCall("fetch", ident"c")

    result.add nnkElse.newTree(
      newCall("assert", ident"false",
              newLit"Unreachable state, missing `fetch()` call"))

    result = quote do:
      if c.detailedMode:
        `result`
        inc c.tickIdx

      else:
        `fast`

  echo result.repr()

proc updateZsp() {.ticked.} =
  step: zf = (aluRes) == 0
  step: sf = bool((aluRes) shr 7)
  step: pf = parity(aluRes)

proc fetchHL() {.ticked.} =
  step: addrBus = uint16(h) shl 8 or l

proc getByte(c: var i8080): uint8 = c.readByte(c.addrBus)

proc readMem() {.ticked.} =
  step: dataBus = getByte()

proc writeMem() {.ticked.} =
  step: c.writeByte(addrBus, dataBus)

proc inr() {.ticked.} =
  step: aluRes = aluIn1 + 1
  step: hf = ((aluRes and 0xF) == 0)
  updateZsp()

proc nextByte() {.ticked.} =
  step: addrBus = pc
  step: dataBus = getByte(c)
  step: inc pc

proc readHL() {.ticked.} =
  fetchHL()
  readMem()

proc writeHL() {.ticked.} =
  fetchHL()
  writeMem()

proc tick(c: var i8080) =
  if c.tickIdx == 0:
    c.activeOpc = c.readByte(c.pc).Opc
    inc c.pc

  case c.activeOpc:
    # of opInrM:
    #   doTick:
    #     fast:

    #     detailed:
    #       readHL()
    #       inr()
    #       writeHL()

    of opMviB:
      doTick:
        fast:
          c.b = i8080_next_byte(c)

        detailed:
          nextByte()
          step: b = dataBus

    of opHlt:
      doTick:
        fast:
          c.halted = true

    else:
      raise newImplementKindError(c.activeOpc)


proc init*(c: var i8080; memory: ref seq[Opc]) =
  i8080_init(c)
  memory[].add opHlt
  c.read_byte = proc(aAddr: uint16): uint8 =
    memory[aAddr].uint8

  c.write_byte = proc(aAddr: uint16; val: uint8) =
    memory[aAddr] = val.Opc

  c.port_in = proc(port: uint8): uint8 = return 0x00
  c.port_out = proc(port: uint8; value: uint8) = discard

proc main*() =
  startHax()
  var cpu: i8080
  init(cpu, asRef @[opMviB, Opc 10])
  while not cpu.halted:
    tick(cpu)

  pprint cpu

main()
