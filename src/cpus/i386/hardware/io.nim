import common
import memory
import device/dev_io
import std/tables

type
  IO* {.requiresinit.} = object
    memory*: Memory
    portIo*: Table[U16, PortIO] ## Memory address to the specific IO
    ## port.
    portIoMap*: Table[U16, csizeT] ## Memory address to the size of the
    ## associated IO port.
    memIo*: Table[U32, MemoryIO]
    memIoMap*: Table[U32, U32]

template log*(io: IO, ev: EmuEvent): untyped =
  io.memory.logger.log(ev, -2)

proc initIO*(mem: Memory): IO =
  result.memory = mem

proc destroyIO*(this: var IO): void =
  this.portIo.clear()
  this.memIo.clear()
  this.memIoMap.clear()


proc setPortio*(this: var IO, memAddr: U16, len: csizeT, dev: PortIO): void =
  let memAddr = (memAddr and not(1.U16))
  this.portIo[memAddr] = dev
  this.portIoMap[memAddr] = len

proc getPortioBase*(this: var IO, memAddr: U16): U16 =
  for i in 0 ..< 5:
    let base: U16 = (memAddr and (not(1.U16))) - U16(2 * i)
    if base in this.portIoMap:
      if memAddr < base + this.portIoMap[base]:
        return base

      else:
        return 0

  return 0

proc inIo8*(this: var IO, port: U16): U8 =
  this.log ev(eekInIO).withIt do:
    it.memAddr = port
    it.size = 8

  var v: U8 = 0
  let base: U16 = this.getPortioBase(port)
  if base != 0:
    v = this.portIo[base].in8(port)

  else:
    raise EmuIoError.withNewIt:
      it.msg = &"No device connected at port {port}"
      it.port = port

    # ERROR("no device connected at port : 0x%04x", port) #

  this.log evEnd()
  return v


proc inIo32*(this: var IO, port: U16): U32 =
  var v: U32 = 0
  for i in 0 ..< 4:
    v = (v + this.inIo8(port + U16(i)) shl (8 * i))
  return v



proc inIo16*(this: var IO, port: U16): U16 =
  var v: U16 = 0
  for i in 0 ..< 2:
    v = (v + this.inIo8(port + U16(i)) shl (8 * i))
  return v

proc outIo8*(this: var IO, port: U16, value: U8): void =
  var base: U16 = this.getPortioBase(port)
  if base != 0:
    this.portIo[base].out8(port, value)

  else:
    ERROR("no device connected at port : 0x%04x", port)

  INFO(4, "out [0x%04x] (0x%04x)", port, value)

proc outIo32*(this: var IO, port: U16, value: U32): void =
  for i in 0 ..< 4:
    this.outIo8(port + U16(i), U8((value shr (8 * i)) and 0xff))

proc outIo16*(this: var IO, port: U16, value: U16): void =
  for i in 0 ..< 2:
    this.outIo8(port + U16(i), U8((value shr (8 * i)) and 0xff))

proc setMemio*(this: var IO, base: U32, len: csizeT, dev: var MemoryIO): void =
  assertRef(this.memory)
  assertRef(dev)
  var memAddr: U32
  dev.setMem(this.memory, base, len)
  this.memIo[base] = dev
  block:
    memAddr = base
    while memAddr < base + len:
      this.memIoMap[memAddr] = base
      memAddr = (memAddr + (1 shl 12))


proc getMemio*(this: var IO, memAddr: U32): Option[U32] =
  let memAddr = memAddr and 0x0FFFu32
  if memAddr in this.memIoMap:
    return some this.memIoMap[memAddr]

proc readMemio32*(this: var IO, base: U32, offset: U32): U32 =
  ASSERT(base in this.memIo)
  result = this.memIo[base].read32(offset)
  this.log ev(eekGetIo32, evalue(result), offset)

proc readMemio16*(this: var IO, base: U32, offset: U32): U16 =
  ASSERT(base in this.memIo)
  result = this.memIo[base].read16(offset)
  this.log ev(eekGetIo16, evalue(result), offset)

proc readMemio8*(this: var IO, base: U32, offset: U32): U8 =
  ASSERT(base in this.memIo)
  result = this.memIo[base].read8(offset)
  this.log ev(eekGetIo8, evalue(result), offset)

proc writeMemio32*(this: var IO, base: U32, offset: U32, value: U32): void =
  ASSERT(base in this.memIo)
  this.log ev(eekSetIo32, evalue(value), offset)
  this.memIo[base].write32(offset, value)

proc writeMemio16*(this: var IO, base: U32, offset: U32, value: U16): void =
  ASSERT(base in this.memIo)
  this.log ev(eekSetIo16, evalue(value), offset)
  this.memIo[base].write16(offset, value)

proc writeMemio8*(this: var IO, base: U32, offset: U32, value: U8): void =
  ASSERT(base in this.memIo)
  this.log ev(eekSetIo8, evalue(value), offset)
  this.memIo[base].write8(offset, value)
