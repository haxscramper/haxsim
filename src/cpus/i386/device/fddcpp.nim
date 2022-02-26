import
  thread
import
  cmath
import
  device/fddhpp
proc initFDD*(): FDD_FDD = 
  fddfuncs[FDD_READ_TRACK] = addr FDD.fdd_read_track
  fddfuncs[FDD_WRITE_DATA] = addr FDD.fdd_write_data
  fddfuncs[FDD_READ_DATA] = addr FDD.fdd_read_data
  fddfuncs[FDD_CONFIGURE] = addr FDD.fdd_configure
  for i in 0 ..< MAX_FDD:
    drive[i] = `nil`
  conf.EIS = 0
  conf.EFIFO = 1
  conf.POLL = 0
  sra.raw = 0
  srb.raw = 0
  data_q.max = 0
  th = std.thread(addr FDD.worker, this)

proc destroyFDD*(this: var FDD): void = 
  for i in 0 ..< MAX_FDD:
    eject_disk(i)
  th.join()

proc insert_disk*(this: var FDD, slot: uint8, fname: cstring, write: bool): bool = 
  var d: ptr DRIVE
  if slot >= MAX_FDD or drive[slot]:
    return false
  
  d = newDRIVE()
  d.disk = fopen(fname, (if write:
           "rb+"
         
         else:
           "rb"
         ))
  if not(d.disk):
    cxx_delete d
    return false
  
  d.cylinder = 0
  d.head = 0
  d.sector = 1
  d.write = write
  drive[slot] = d
  return true

proc eject_disk*(this: var FDD, slot: uint8): bool = 
  if slot >= MAX_FDD or not(drive[slot]):
    return false
  
  fclose(drive[slot].disk)
  cxx_delete drive[slot]
  drive[slot] = `nil`
  return true

proc seek*(this: var FDD, slot: uint8, c: uint8, h: uint8, s: uint8): int32 = 
  var offset: int32
  if not(drive[slot]) or not(drive[slot].disk):
    ERROR("not ready disk%d", slot)
  
  if s < 1 or s > N_SpH:
    ERROR("")
  
  if h < 0 or h >= N_HpC:
    ERROR("")
  
  if c < 0:
    ERROR("")
  
  msr.DRV_BSY = (msr.DRV_BSY or 1 shl slot)
  ds = (s - drive[slot].sector) * SIZE_SECTOR
  dh = (h - drive[slot].head) * SIZE_SECTOR * N_SpH
  dc = (c - drive[slot].cylinder) * SIZE_SECTOR * N_SpH * N_HpC
  offset = dc + dh + ds
  INFO(3, "seek : %d, ds : %d(%d->%d), dh : %d(%d->%d), dc : %d(%d->%d)", offset, ds, drive[slot].sector, s, dh, drive[slot].head, h, dc, drive[slot].cylinder, c)
  drive[slot].cylinder = c
  drive[slot].head = h
  drive[slot].sector = s
  drive[slot].progress = 0
  fseek(drive[slot].disk, offset, SEEK_CUR)
  msr.DRV_BSY = (msr.DRV_BSY xor 1 shl slot)
  return offset

proc read*(this: var FDD, slot: uint8): uint8 = 
  var v: uint8
  if not(drive[slot]) or not(drive[slot].disk):
    ERROR("not ready disk%d", slot)
  
  if not(fread(addr v, 1, 1, drive[slot].disk)):
    v = 0
  
  sync_position(slot)
  return v

proc write*(this: var FDD, slot: uint8, v: uint8): void = 
  if not(drive[slot]) or not(drive[slot].disk):
    ERROR("not ready disk%d", slot)
  
  fwrite(addr v, 1, 1, drive[slot].disk)
  sync_position(slot)

proc sync_position*(this: var FDD, slot: uint8): void = 
  if preInc(drive[slot].progress) < 0x200:
    return 
  
  drive[slot].progress = 0
  postInc(drive[slot].sector)
  if drive[slot].sector > N_SpH:
    drive[slot].sector = 1
    if postInc(drive[slot].head):
      postInc(drive[slot].cylinder)
    
  

proc in8*(this: var FDD, `addr`: uint16): uint8 = 
  var v: uint8
  case `addr`:
    of 0x3f0:
      v = sra.raw
    of 0x3f1:
      v = srb.raw
    of 0x3f3:
      v = tdr.raw
    of 0x3f4:
      v = msr.raw
    of 0x3f5:
      v = read_datareg()
    of 0x3f7:
      v = ccr.raw
  return v

proc out8*(this: var FDD, `addr`: uint16, v: uint8): void = 
  case `addr`:
    of 0x3f2:
      dor.raw = v
    of 0x3f3:
      tdr.raw = v
    of 0x3f4:
      dsr.raw = v
    of 0x3f5:
      enqueue(addr data_q, v)
    of 0x3f7:
      dir.raw = v

proc worker*(this: var FDD): void = 
  var mode: uint8
  while (true):
    while (data_q.queue.empty()):
      std.this_thread.sleep_for(std.chrono.milliseconds(10))
    mode = dequeue(addr data_q)
    if not(fddfuncs.count(mode)):
      data = 0x80
      continue
    
    msr.CMD_BSY = 1
    (this.CXX_SYNTAX_ERROR("*")[mode])()
    msr.CMD_BSY = 0

proc fdd_read_track*(this: var FDD): void = 
  var cmd: array[8, uint8]
  var slot: uint8
  msr.RQM = 1
  msr.DIO = 0
  for i in 0 ..< 8:
    cmd[i] = dequeue(addr data_q)
  slot = cmd[0] and 3
  if conf.EIS:
    seek(slot, cmd[1], cmd[2], 1)
  
  for i in 0 ..< std.pow(2, cmd[4]) * 128 * N_SpH:
    write_datareg(read(slot))
    intr = true
  write_datareg(st0.raw)
  write_datareg(st1.raw)
  write_datareg(st2.raw)
  write_datareg(drive[slot].cylinder)
  write_datareg(drive[slot].head)
  write_datareg(drive[slot].sector)
  write_datareg(cmd[4])
  msr.RQM = 0

proc fdd_write_data*(this: var FDD): void = 
  var cmd: array[8, uint8]
  var slot: uint8
  msr.RQM = 1
  msr.DIO = 1
  for i in 0 ..< 8:
    cmd[i] = dequeue(addr data_q)
  slot = cmd[0] and 3
  if conf.EIS:
    seek(slot, cmd[1], cmd[2], cmd[3])
  
  for i in 0 ..< std.pow(2, cmd[4]) * 128:
    write(slot, dequeue(addr data_q))
    intr = true
  write_datareg(st0.raw)
  write_datareg(st1.raw)
  write_datareg(st2.raw)
  write_datareg(drive[slot].cylinder)
  write_datareg(drive[slot].head)
  write_datareg(drive[slot].sector)
  write_datareg(cmd[4])
  msr.RQM = 0

proc fdd_read_data*(this: var FDD): void = 
  var cmd: array[8, uint8]
  var slot: uint8
  msr.RQM = 1
  msr.DIO = 0
  for i in 0 ..< 8:
    cmd[i] = dequeue(addr data_q)
  slot = cmd[0] and 3
  if conf.EIS:
    seek(slot, cmd[1], cmd[2], cmd[3])
  
  for i in 0 ..< std.pow(2, cmd[4]) * 128:
    write_datareg(read(slot))
    intr = true
  write_datareg(st0.raw)
  write_datareg(st1.raw)
  write_datareg(st2.raw)
  write_datareg(drive[slot].cylinder)
  write_datareg(drive[slot].head)
  write_datareg(drive[slot].sector)
  write_datareg(cmd[4])
  msr.RQM = 0

proc fdd_configure*(this: var FDD): void = 
  var cmd: array[3, uint8]
  for i in 0 ..< 3:
    cmd[i] = dequeue(addr data_q)
  conf.raw = cmd[1]

proc read_datareg*(this: var FDD): uint8 = 
  var v: uint8
  while (not(sra.INT)):
    std.this_thread.sleep_for(std.chrono.microseconds(50))
  v = data
  sra.INT = 0
  return v

proc write_datareg*(this: var FDD, v: uint8): void = 
  while (sra.INT):
    std.this_thread.sleep_for(std.chrono.microseconds(50))
  data = v
  sra.INT = 1

proc enqueue*(this: var FDD, q: ptr QUEUE, v: uint8): void = 
  while (q.max and q.queue.size() >= q.max):
    std.this_thread.sleep_for(std.chrono.microseconds(50))
  q.mtx.lock()
  q.queue.push(v)
  q.mtx.unlock()

proc dequeue*(this: var FDD, q: ptr QUEUE): uint8 = 
  var v: uint8
  q.mtx.lock()
  while (q.queue.empty()):
    q.mtx.unlock()
    std.this_thread.sleep_for(std.chrono.microseconds(50))
    q.mtx.lock()
  v = q.queue.front()
  q.queue.pop()
  q.mtx.unlock()
  return v
