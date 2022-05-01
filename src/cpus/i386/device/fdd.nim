# import thread
import std/tables
import std/deques
import std/math
# import std/threads
import std/locks
import common
import dev_io
import dev_irq

const
  MAX_FDD*                = 4
  SIZE_SECTOR*            = 0x200
  N_SpH*                  = 18
  N_HpC*                  = 2
  FDD_READ_TRACK*         = 0x02
  FDD_SENSE_DRIVE_STATUS* = 0x04
  FDD_WRITE_DATA*         = 0x05
  FDD_READ_DATA*          = 0x06
  FDD_RECALIBRATE*        = 0x07
  FDD_READ_ID*            = 0x0a
  FDD_FORMAT_TRACK*       = 0x0d
  FDD_SEEK*               = 0x0f
  FDD_CONFIGURE*          = 0x13

type
  DRIVE* = object
    disk*:               File
    cylinder* {.bitsize: 7.}: uint8
    head* {.bitsize:     1.}: uint8
    sector* {.bitsize:   5.}: uint8
    write*:              bool
    progress*:           uint16

  QUEUE* = object
    queue*: Deque[uint8]
    mtx*: Lock
    max*: uint16

  FDD* = ref object of IRQ
    portio*: PortIO
    fddfuncs*: Table[uint8, fddfunc_t]
    drive*: array[MAX_FDD, ref DRIVE]
    conf*: FDD_conf
    sra*: FDD_sra
    srb*: FDD_srb
    dor*: FDD_dor
    tdr*: FDD_tdr
    msr*: FDD_msr
    dsr*: FDD_dsr
    data*: uint8
    data_q*: QUEUE
    ccr*: FDD_ccr
    dir*: FDD_dir
    st0*: FDD_st0
    st1*: FDD_st1
    st2*: FDD_st2
    str3*: FDD_str3
    # th*: Thread[int]

  FDD_str3* {.union.} = object
    raw*: uint8
    field1*: FDD_str3_field1

  fddfunc_t* = proc(fdd: var FDD, arg0: void): void

  FDD_conf_field1* = object
    FIFOTHR* {.bitsize: 4.}: uint8
    POLL* {.bitsize: 1.}: uint8
    EFIFO* {.bitsize: 1.}: uint8
    EIS* {.bitsize: 1.}: uint8

  FDD_st2* {.union.} = object
    raw*: uint8
    field1*: FDD_st2_field1

  FDD_st1* {.union.} = object
    raw*: uint8
    field1*: FDD_st1_field1

  FDD_st2_field1* = object
    MD* {.bitsize: 1.}: uint8
    BC* {.bitsize: 1.}: uint8
    SN* {.bitsize: 1.}: uint8
    SH* {.bitsize: 1.}: uint8
    WC* {.bitsize: 1.}: uint8
    DD* {.bitsize: 1.}: uint8
    CM* {.bitsize: 1.}: uint8

  FDD_st0* {.union.} = object
    raw*: uint8
    field1*: FDD_st0_field1

  FDD_st1_field1* = object
    MA* {.bitsize: 1.}: uint8
    NW* {.bitsize: 1.}: uint8
    ND* {.bitsize: 1.}: uint8
    field3* {.bitsize: 1.}: uint8
    OR* {.bitsize: 1.}: uint8
    DE* {.bitsize: 1.}: uint8
    field6* {.bitsize: 1.}: uint8
    EN* {.bitsize: 1.}: uint8

  FDD_msr* {.union.} = object
    raw*: uint8
    field1*: FDD_msr_field1

  FDD_dsr* {.union.} = object
    raw*: uint8

  FDD_ccr* {.union.} = object
    raw*: uint8

  FDD_dir* {.union.} = object
    raw*: uint8

  FDD_st0_field1* = object
    DS0* {.bitsize: 1.}: uint8
    DS1* {.bitsize: 1.}: uint8
    H* {.bitsize: 1.}: uint8
    field3* {.bitsize: 1.}: uint8
    EC* {.bitsize: 1.}: uint8
    SE* {.bitsize: 1.}: uint8
    IC0* {.bitsize: 1.}: uint8
    IC1* {.bitsize: 1.}: uint8

  FDD_dor* {.union.} = object
    raw*: uint8
    field1*: FDD_dor_field1

  FDD_tdr* {.union.} = object
    raw*: uint8

  FDD_srb* {.union.} = object
    raw*: uint8
    field1*: FDD_srb_field1

  FDD_conf* {.union.} = object
    raw*: uint8
    field1*: FDD_conf_field1

  FDD_sra_field1* = object
    DIR* {.bitsize: 1.}: uint8
    nWP* {.bitsize: 1.}: uint8
    nINDX* {.bitsize: 1.}: uint8
    HDSEL* {.bitsize: 1.}: uint8
    nTRK0* {.bitsize: 1.}: uint8
    STEP* {.bitsize: 1.}: uint8
    nDRV2* {.bitsize: 1.}: uint8
    INT* {.bitsize: 1.}: uint8

  FDD_sra* {.union.} = object
    raw*: uint8
    field1*: FDD_sra_field1

  FDD_srb_field1* = object
    MOT0* {.bitsize: 1.}: uint8
    MOT1* {.bitsize: 1.}: uint8
    WE* {.bitsize: 1.}: uint8
    RD* {.bitsize: 1.}: uint8
    WR* {.bitsize: 1.}: uint8
    SEL0* {.bitsize: 1.}: uint8

  FDD_dor_field1* = object
    SEL0* {.bitsize: 1.}: uint8
    SEL1* {.bitsize: 1.}: uint8
    nRESET* {.bitsize: 1.}: uint8
    nDMA* {.bitsize: 1.}: uint8
    MOT* {.bitsize: 4.}: uint8

  FDD_msr_field1* = object
    DRV_BSY* {.bitsize: 4.}: uint8
    CMD_BSY* {.bitsize: 1.}: uint8
    NON_DMA* {.bitsize: 1.}: uint8
    DIO* {.bitsize: 1.}: uint8
    RQM* {.bitsize: 1.}: uint8

  FDD_str3_field1* = object
    DS0* {.bitsize: 1.}: uint8
    DS1* {.bitsize: 1.}: uint8
    HD* {.bitsize: 1.}: uint8
    field3* {.bitsize: 1.}: uint8
    T0* {.bitsize: 1.}: uint8
    field5* {.bitsize: 1.}: uint8
    WP* {.bitsize: 1.}: uint8

proc FIFOTHR*(this: FDD_conf): uint8 = this.field1.FIFOTHR
proc `FIFOTHR=`*(this: var FDD_conf, value: uint8) = this.field1.FIFOTHR = value
proc POLL*(this: FDD_conf): uint8 = this.field1.POLL
proc `POLL=`*(this: var FDD_conf, value: uint8) = this.field1.POLL = value
proc EFIFO*(this: FDD_conf): uint8 = this.field1.EFIFO
proc `EFIFO=`*(this: var FDD_conf, value: uint8) = this.field1.EFIFO = value
proc EIS*(this: FDD_conf): uint8 = this.field1.EIS
proc `EIS=`*(this: var FDD_conf, value: uint8) = this.field1.EIS = value
proc DIR*(this: FDD_sra): uint8 = this.field1.DIR
proc `DIR=`*(this: var FDD_sra, value: uint8) = this.field1.DIR = value
proc nWP*(this: FDD_sra): uint8 = this.field1.nWP
proc `nWP=`*(this: var FDD_sra, value: uint8) = this.field1.nWP = value
proc nINDX*(this: FDD_sra): uint8 = this.field1.nINDX
proc `nINDX=`*(this: var FDD_sra, value: uint8) = this.field1.nINDX = value
proc HDSEL*(this: FDD_sra): uint8 = this.field1.HDSEL
proc `HDSEL=`*(this: var FDD_sra, value: uint8) = this.field1.HDSEL = value
proc nTRK0*(this: FDD_sra): uint8 = this.field1.nTRK0
proc `nTRK0=`*(this: var FDD_sra, value: uint8) = this.field1.nTRK0 = value
proc STEP*(this: FDD_sra): uint8 = this.field1.STEP
proc `STEP=`*(this: var FDD_sra, value: uint8) = this.field1.STEP = value
proc nDRV2*(this: FDD_sra): uint8 = this.field1.nDRV2
proc `nDRV2=`*(this: var FDD_sra, value: uint8) = this.field1.nDRV2 = value
proc INT*(this: FDD_sra): uint8 = this.field1.INT
proc `INT=`*(this: var FDD_sra, value: uint8) = this.field1.INT = value
proc MOT0*(this: FDD_srb): uint8 = this.field1.MOT0
proc `MOT0=`*(this: var FDD_srb, value: uint8) = this.field1.MOT0 = value
proc MOT1*(this: FDD_srb): uint8 = this.field1.MOT1
proc `MOT1=`*(this: var FDD_srb, value: uint8) = this.field1.MOT1 = value
proc WE*(this: FDD_srb): uint8 = this.field1.WE
proc `WE=`*(this: var FDD_srb, value: uint8) = this.field1.WE = value
proc RD*(this: FDD_srb): uint8 = this.field1.RD
proc `RD=`*(this: var FDD_srb, value: uint8) = this.field1.RD = value
proc WR*(this: FDD_srb): uint8 = this.field1.WR
proc `WR=`*(this: var FDD_srb, value: uint8) = this.field1.WR = value
proc SEL0*(this: FDD_srb): uint8 = this.field1.SEL0
proc `SEL0=`*(this: var FDD_srb, value: uint8) = this.field1.SEL0 = value
proc SEL0*(this: FDD_dor): uint8 = this.field1.SEL0
proc `SEL0=`*(this: var FDD_dor, value: uint8) = this.field1.SEL0 = value
proc SEL1*(this: FDD_dor): uint8 = this.field1.SEL1
proc `SEL1=`*(this: var FDD_dor, value: uint8) = this.field1.SEL1 = value
proc nRESET*(this: FDD_dor): uint8 = this.field1.nRESET
proc `nRESET=`*(this: var FDD_dor, value: uint8) = this.field1.nRESET = value
proc nDMA*(this: FDD_dor): uint8 = this.field1.nDMA
proc `nDMA=`*(this: var FDD_dor, value: uint8) = this.field1.nDMA = value
proc MOT*(this: FDD_dor): uint8 = this.field1.MOT
proc `MOT=`*(this: var FDD_dor, value: uint8) = this.field1.MOT = value
proc DRV_BSY*(this: FDD_msr): uint8 = this.field1.DRV_BSY
proc `DRV_BSY=`*(this: var FDD_msr, value: uint8) = this.field1.DRV_BSY = value
proc CMD_BSY*(this: FDD_msr): uint8 = this.field1.CMD_BSY
proc `CMD_BSY=`*(this: var FDD_msr, value: uint8) = this.field1.CMD_BSY = value
proc NON_DMA*(this: FDD_msr): uint8 = this.field1.NON_DMA
proc `NON_DMA=`*(this: var FDD_msr, value: uint8) = this.field1.NON_DMA = value
proc DIO*(this: FDD_msr): uint8 = this.field1.DIO
proc `DIO=`*(this: var FDD_msr, value: uint8) = this.field1.DIO = value
proc RQM*(this: FDD_msr): uint8 = this.field1.RQM
proc `RQM=`*(this: var FDD_msr, value: uint8) = this.field1.RQM = value
proc DS0*(this: FDD_st0): uint8 = this.field1.DS0
proc `DS0=`*(this: var FDD_st0, value: uint8) = this.field1.DS0 = value
proc DS1*(this: FDD_st0): uint8 = this.field1.DS1
proc `DS1=`*(this: var FDD_st0, value: uint8) = this.field1.DS1 = value
proc H*(this: FDD_st0): uint8 = this.field1.H
proc `H=`*(this: var FDD_st0, value: uint8) = this.field1.H = value
proc EC*(this: FDD_st0): uint8 = this.field1.EC
proc `EC=`*(this: var FDD_st0, value: uint8) = this.field1.EC = value
proc SE*(this: FDD_st0): uint8 = this.field1.SE
proc `SE=`*(this: var FDD_st0, value: uint8) = this.field1.SE = value
proc IC0*(this: FDD_st0): uint8 = this.field1.IC0
proc `IC0=`*(this: var FDD_st0, value: uint8) = this.field1.IC0 = value
proc IC1*(this: FDD_st0): uint8 = this.field1.IC1
proc `IC1=`*(this: var FDD_st0, value: uint8) = this.field1.IC1 = value
proc MA*(this: FDD_st1): uint8 = this.field1.MA
proc `MA=`*(this: var FDD_st1, value: uint8) = this.field1.MA = value
proc NW*(this: FDD_st1): uint8 = this.field1.NW
proc `NW=`*(this: var FDD_st1, value: uint8) = this.field1.NW = value
proc ND*(this: FDD_st1): uint8 = this.field1.ND
proc `ND=`*(this: var FDD_st1, value: uint8) = this.field1.ND = value
proc OR*(this: FDD_st1): uint8 = this.field1.OR
proc `OR=`*(this: var FDD_st1, value: uint8) = this.field1.OR = value
proc DE*(this: FDD_st1): uint8 = this.field1.DE
proc `DE=`*(this: var FDD_st1, value: uint8) = this.field1.DE = value
proc EN*(this: FDD_st1): uint8 = this.field1.EN
proc `EN=`*(this: var FDD_st1, value: uint8) = this.field1.EN = value
proc MD*(this: FDD_st2): uint8 = this.field1.MD
proc `MD=`*(this: var FDD_st2, value: uint8) = this.field1.MD = value
proc BC*(this: FDD_st2): uint8 = this.field1.BC
proc `BC=`*(this: var FDD_st2, value: uint8) = this.field1.BC = value
proc SN*(this: FDD_st2): uint8 = this.field1.SN
proc `SN=`*(this: var FDD_st2, value: uint8) = this.field1.SN = value
proc SH*(this: FDD_st2): uint8 = this.field1.SH
proc `SH=`*(this: var FDD_st2, value: uint8) = this.field1.SH = value
proc WC*(this: FDD_st2): uint8 = this.field1.WC
proc `WC=`*(this: var FDD_st2, value: uint8) = this.field1.WC = value
proc DD*(this: FDD_st2): uint8 = this.field1.DD
proc `DD=`*(this: var FDD_st2, value: uint8) = this.field1.DD = value
proc CM*(this: FDD_st2): uint8 = this.field1.CM
proc `CM=`*(this: var FDD_st2, value: uint8) = this.field1.CM = value
proc DS0*(this: FDD_str3): uint8 = this.field1.DS0
proc `DS0=`*(this: var FDD_str3, value: uint8) = this.field1.DS0 = value
proc DS1*(this: FDD_str3): uint8 = this.field1.DS1
proc `DS1=`*(this: var FDD_str3, value: uint8) = this.field1.DS1 = value
proc HD*(this: FDD_str3): uint8 = this.field1.HD
proc `HD=`*(this: var FDD_str3, value: uint8) = this.field1.HD = value
proc T0*(this: FDD_str3): uint8 = this.field1.T0
proc `T0=`*(this: var FDD_str3, value: uint8) = this.field1.T0 = value
proc WP*(this: FDD_str3): uint8 = this.field1.WP
proc `WP=`*(this: var FDD_str3, value: uint8) = this.field1.WP = value

proc dequeue*(this: var FDD, q: ptr QUEUE): uint8 =
  var v: uint8
  q.mtx.acquire()
  while (q.queue.len() == 0):
    q.mtx.release()
    # std.this_thread.sleep_for(std.chrono.microseconds(50))
    q.mtx.acquire()
  v = q.queue.popFirst()
  discard q.queue.popFirst()
  q.mtx.release()
  return v

proc seek*(this: var FDD, slot: uint8, c: uint8, h: uint8, s: uint8): int32 =
  var offset, dc, dh, ds: int32
  if not(this.drive[slot].toBool()) or not(this.drive[slot].disk.toBool()):
    ERROR("not ready disk%d", slot)

  if s < 1 or s > N_SpH:
    ERROR("")

  if h < 0 or h >= N_HpC:
    ERROR("")

  if c < 0:
    ERROR("")

  this.msr.DRV_BSY = (this.msr.DRV_BSY or uint8(1 shl slot))
  ds = int32((s - this.drive[slot].sector) * SIZE_SECTOR)
  dh = int32((h - this.drive[slot].head) * SIZE_SECTOR * N_SpH)
  dc = int32((c - this.drive[slot].cylinder) * SIZE_SECTOR * N_SpH * N_HpC)
  offset = dc + dh + ds
  INFO(3, "seek : %d, ds : %d(%d->%d), dh : %d(%d->%d), dc : %d(%d->%d)",
       offset, ds, drive[slot].sector, s, dh, drive[slot].head, h, dc, drive[slot].cylinder, c)

  this.drive[slot].cylinder = c
  this.drive[slot].head = h
  this.drive[slot].sector = s
  this.drive[slot].progress = 0

  {.warning: "fseek(this.drive[slot].disk, offset, SEEK_CUR)".}
  this.msr.DRV_BSY = (this.msr.DRV_BSY xor uint8(1 shl slot))
  return offset


proc write_datareg*(this: var FDD, v: uint8): void =
  while this.sra.INT.toBool():
    {.warning: "FIXME: std.this_thread.sleep_for(std.chrono.microseconds(50))".}
  this.data = v
  this.sra.INT = 1

proc sync_position*(this: var FDD, slot: uint8): void =
  if preInc(this.drive[slot].progress) < 0x200:
    return

  this.drive[slot].progress = 0
  inc this.drive[slot].sector
  if this.drive[slot].sector > N_SpH:
    this.drive[slot].sector = 1
    var before = this.drive[slot].head
    inc this.drive[slot].head
    if before.toBool():
      inc this.drive[slot].cylinder

proc read*(this: var FDD, slot: uint8): uint8 =
  var v: uint8
  if not(this.drive[slot].toBool()) or not(this.drive[slot].disk.toBool()):
    ERROR("not ready disk%d", slot)

  {.warning: "FIXME".}
  # if not(fread(addr v, 1, 1, this.drive[slot].disk)):
  #   v = 0

  sync_position(this, slot)
  return v

proc fdd_read_track*(this: var FDD): void =
  var cmd: array[8, uint8]
  var slot: uint8
  this.msr.RQM = 1
  this.msr.DIO = 0
  for i in 0 ..< 8:
    cmd[i] = dequeue(this, addr this.data_q)
  slot = cmd[0] and 3
  if this.conf.EIS.toBool():
    discard seek(this, slot, cmd[1], cmd[2], 1)

  for i in 0 ..< pow(2.float, cmd[4].float).int * 128 * N_SpH:
    write_datareg(this, read(this, slot))
    this.intr = true
  this.write_datareg(this.st0.raw)
  this.write_datareg(this.st1.raw)
  this.write_datareg(this.st2.raw)
  this.write_datareg(this.drive[slot].cylinder)
  this.write_datareg(this.drive[slot].head)
  this.write_datareg(this.drive[slot].sector)
  this.write_datareg(cmd[4])
  this.msr.RQM = 0

proc fdd_write_data*(this: var FDD): void =
  var cmd: array[8, uint8]
  var slot: uint8
  this.msr.RQM = 1
  this.msr.DIO = 1
  for i in 0 ..< 8:
    cmd[i] = dequeue(this, addr this.data_q)
  slot = cmd[0] and 3
  if this.conf.EIS.toBool():
    discard seek(this, slot, cmd[1], cmd[2], cmd[3])

  for i in 0 ..< pow(2.float, cmd[4].float).int * 128:
    {.warning: "write(this, slot, dequeue(this, addr this.data_q))".}
    this.intr = true
  this.write_datareg(this.st0.raw)
  this.write_datareg(this.st1.raw)
  this.write_datareg(this.st2.raw)
  this.write_datareg(this.drive[slot].cylinder)
  this.write_datareg(this.drive[slot].head)
  this.write_datareg(this.drive[slot].sector)
  this.write_datareg(cmd[4])
  this.msr.RQM = 0


proc fdd_read_data*(this: var FDD): void =
  var cmd: array[8, uint8]
  var slot: uint8
  this.msr.RQM = 1
  this.msr.DIO = 0
  for i in 0 ..< 8:
    cmd[i] = dequeue(this, addr this.data_q)
  slot = cmd[0] and 3
  if this.conf.EIS.toBool():
    discard seek(this, slot, cmd[1], cmd[2], cmd[3])

  for i in 0 ..< pow(2.float, cmd[4].float).int * 128:
    write_datareg(this, read(this, slot))
    this.intr = true
  this.write_datareg(this.st0.raw)
  this.write_datareg(this.st1.raw)
  this.write_datareg(this.st2.raw)
  this.write_datareg(this.drive[slot].cylinder)
  this.write_datareg(this.drive[slot].head)
  this.write_datareg(this.drive[slot].sector)
  this.write_datareg(cmd[4])
  this.msr.RQM = 0

proc fdd_configure*(this: var FDD): void =
  var cmd: array[3, uint8]
  for i in 0 ..< 3:
    cmd[i] = dequeue(this, addr this.data_q)
  this.conf.raw = cmd[1]



proc insert_disk*(this: var FDD, slot: uint8, fname: cstring, write: bool): bool =
  var d: ref DRIVE
  if slot >= MAX_FDD or this.drive[slot].toBool():
    return false

  new(d)
  # d[] = initDrive()
  d.disk = open($fname, (if write: fmWrite else: fmRead))
  if not(d.disk.toBool()):
    # cxx_delete d
    return false

  d.cylinder = 0
  d.head = 0
  d.sector = 1
  d.write = write
  this.drive[slot] = d
  return true

proc eject_disk*(this: var FDD, slot: uint8): bool =
  if slot >= MAX_FDD or not(this.drive[slot].toBool()):
    return false

  close(this.drive[slot].disk)
  # cxx_delete drive[slot]
  this.drive[slot] = nil
  return true

proc destroyFDD*(this: var FDD): void =
  for i in 0 ..< MAX_FDD:
    discard this.eject_disk(i.uint8)
  # FIXME: this.th.join()

proc write*(this: var FDD, slot: uint8, v: uint8): void =
  if not(this.drive[slot].toBool()) or not(this.drive[slot].disk.toBool()):
    ERROR("not ready disk%d", slot)

  # FIXME: write(addr v, 1, 1, this.drive[slot].disk)
  sync_position(this, slot)


proc read_datareg*(this: var FDD): uint8 =
  var v: uint8
  while (not(this.sra.INT.toBool())):
    {.warning: "std.this_thread.sleep_for(std.chrono.microseconds(50))".}
  v = this.data
  this.sra.INT = 0
  return v


proc in8*(this: var FDD, memAddr: uint16): uint8 =
  var v: uint8
  case memAddr:
    of 0x3f0: v = this.sra.raw
    of 0x3f1: v = this.srb.raw
    of 0x3f3: v = this.tdr.raw
    of 0x3f4: v = this.msr.raw
    of 0x3f5: v = this.read_datareg()
    of 0x3f7: v = this.ccr.raw
    else: assert false
  return v

proc enqueue*(this: var FDD, q: ptr QUEUE, v: uint8): void =
  while (q.max.toBool() and q.queue.len() >= q.max.int):
    {.warning: "std.this_thread.sleep_for(std.chrono.microseconds(50))".}
  q.mtx.acquire()
  q.queue.addLast(v)
  q.mtx.release()

proc out8*(this: var FDD, memAddr: uint16, v: uint8): void =
  case memAddr:
    of 0x3f2: this.dor.raw = v
    of 0x3f3: this.tdr.raw = v
    of 0x3f4: this.dsr.raw = v
    of 0x3f5: this.enqueue(addr this.data_q, v)
    of 0x3f7: this.dir.raw = v
    else: assert false

proc worker*(this: var FDD): void =
  var mode: uint8
  while (true):
    while (this.data_q.queue.len() == 0):
      {.warning: "std.this_thread.sleep_for(std.chrono.milliseconds(10))".}

    mode = this.dequeue(addr this.data_q)
    if mode notin this.fddfuncs:
      this.data = 0x80
      continue

    this.msr.CMD_BSY = 1
    this.fddfuncs[mode](this)
    # this.CXX_SYNTAX_ERROR("*")[mode])()
    this.msr.CMD_BSY = 0

proc initFDD*(): FDD =
  var fdd = FDD()
  fdd.fddfuncs[FDD_READ_TRACK] = fddfunc_t(fdd_read_track)
  fdd.fddfuncs[FDD_WRITE_DATA] = fddfunc_t(fdd_write_data)
  fdd.fddfuncs[FDD_READ_DATA] = fddfunc_t(fdd_read_data)
  fdd.fddfuncs[FDD_CONFIGURE] = fddfunc_t(fdd_configure)
  for i in 0 ..< MAX_FDD:
    fdd.drive[i] = nil
  fdd.conf.EIS = 0
  fdd.conf.EFIFO = 1
  fdd.conf.POLL = 0
  fdd.sra.raw = 0
  fdd.srb.raw = 0
  fdd.data_q.max = 0
  # th = std.thread(addr FDD.worker, this)

  fdd.portio = wrapPortIO(fdd, in8, out8)

  return fdd
