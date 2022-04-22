import common
import memory
import device/dev_io
import std/tables

type
  IO* {.requiresinit.} = object
    memory*: Memory
    portIo*: Table[uint16, PortIO] ## Memory address to the specific IO
    ## port.
    portIoMap*: Table[uint16, csizeT] ## Memory address to the size of the
    ## associated IO port.
    memIo*: Table[uint32, MemoryIO]
    memIoMap*: Table[uint32, uint32]

template log*(io: IO, ev: EmuEvent): untyped =
  io.memory.logger.log(ev, -2)

proc initIO*(mem: Memory): IO =
  result.memory = mem

proc destroyIO*(this: var IO): void =
  this.portIo.clear()
  this.memIo.clear()
  this.memIoMap.clear()


proc setPortio*(this: var IO, memAddr: uint16, len: csizeT, dev: PortIO): void =
  let memAddr = (memAddr and not(1.uint16))
  this.portIo[memAddr] = dev
  this.portIoMap[memAddr] = len

proc getPortioBase*(this: var IO, memAddr: uint16): uint16 =
  for i in 0 ..< 5:
    var base: uint16 = (memAddr and (not(1.uint16))) - uint16(2 * i)
    echov memAddr, base
    if base in this.portIoMap:
      if memAddr < base + this.portIoMap[base]:
        return base

      else:
        return 0

  return 0

proc inIo8*(this: var IO, port: uint16): uint8 =
  this.log ev(eekInIO).withIt do:
    it.memAddr = port
    it.size = 8

  var v: uint8 = 0
  let base: uint16 = this.getPortioBase(port)
  if base != 0:
    v = this.portIo[base].in8(port)

  else:
    raise EmuIoError.withNewIt:
      it.msg = &"No device connected at port {port}"
      it.port = port

    # ERROR("no device connected at port : 0x%04x", port) #

  this.log evEnd()
  return v


proc inIo32*(this: var IO, port: uint16): uint32 =
  var v: uint32 = 0
  for i in 0 ..< 4:
    v = (v + this.inIo8(port + uint16(i)) shl (8 * i))
  return v



proc inIo16*(this: var IO, port: uint16): uint16 =
  var v: uint16 = 0
  for i in 0 ..< 2:
    v = (v + this.inIo8(port + uint16(i)) shl (8 * i))
  return v

proc outIo8*(this: var IO, port: uint16, value: uint8): void =
  var base: uint16 = this.getPortioBase(port)
  if base != 0:
    this.portIo[base].out8(port, value)

  else:
    ERROR("no device connected at port : 0x%04x", port)

  INFO(4, "out [0x%04x] (0x%04x)", port, value)

proc outIo32*(this: var IO, port: uint16, value: uint32): void =
  for i in 0 ..< 4:
    this.outIo8(port + uint16(i), uint8((value shr (8 * i)) and 0xff))

proc outIo16*(this: var IO, port: uint16, value: uint16): void =
  for i in 0 ..< 2:
    this.outIo8(port + uint16(i), uint8((value shr (8 * i)) and 0xff))

proc setMemio*(this: var IO, base: uint32, len: csizeT, dev: var MemoryIO): void =
  assertRef(this.memory)
  assertRef(dev)
  var memAddr: uint32
  dev.setMem(this.memory, base, len)
  this.memIo[base] = dev
  block:
    memAddr = base
    while memAddr < base + len:
      this.memIoMap[memAddr] = base
      memAddr = (memAddr + (1 shl 12))


proc getMemioBase*(this: var IO, memAddr: uint32): uint32 =
  let memAddr = (memAddr and (not(((1.uint32 shl 12) - 1))))
  if memAddr in this.memIoMap:
    return this.memIoMap[memAddr]

  else:
    return 0

proc readMemio32*(this: var IO, base: uint32, offset: uint32): uint32 =
  ASSERT(base in this.memIo)
  result = this.memIo[base].read32(offset)
  this.log ev(eekGetIo32, evalue(result), offset)

proc readMemio16*(this: var IO, base: uint32, offset: uint32): uint16 =
  ASSERT(base in this.memIo)
  result = this.memIo[base].read16(offset)
  this.log ev(eekGetIo16, evalue(result), offset)

proc readMemio8*(this: var IO, base: uint32, offset: uint32): uint8 =
  ASSERT(base in this.memIo)
  result = this.memIo[base].read8(offset)
  this.log ev(eekGetIo8, evalue(result), offset)

proc writeMemio32*(this: var IO, base: uint32, offset: uint32, value: uint32): void =
  ASSERT(base in this.memIo)
  this.log ev(eekSetIo32, evalue(value), offset)
  this.memIo[base].write32(offset, value)

proc writeMemio16*(this: var IO, base: uint32, offset: uint32, value: uint16): void =
  ASSERT(base in this.memIo)
  this.log ev(eekSetIo16, evalue(value), offset)
  this.memIo[base].write16(offset, value)

proc writeMemio8*(this: var IO, base: uint32, offset: uint32, value: uint8): void =
  ASSERT(base in this.memIo)
  this.log ev(eekSetIo8, evalue(value), offset)
  this.memIo[base].write8(offset, value)

proc chkMemio*(this: var IO, memAddr: uint32): uint32 =
  result = this.getMemioBase(memAddr)
