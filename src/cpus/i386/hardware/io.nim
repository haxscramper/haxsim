import common
import memory
import device/dev_io
import std/tables

type
  IO* = ref object
    ## Main implementation of the IO for emulator
    memory*: Memory ## Reference to the main memory
    portIo*: Table[U16, PortIO] ## Memory address to the specific IO
    ## port.
    portIoMap*: Table[U16, csizeT] ## Memory address to the size of the
    ## associated IO port.
    memIo*: Table[U32, MemoryIO]
    memIoMap*: Table[U32, U32]

template log*(io: IO, ev: EmuEvent): untyped =
  io.memory.logger.log(ev, -2)

proc initIO*(mem: Memory): IO =
  IO(memory: mem)

proc destroyIO*(this: var IO) =
  this.portIo.clear()
  this.memIo.clear()
  this.memIoMap.clear()


proc setPortio*(this: var IO, memAddr: U16, len: csizeT, dev: PortIO) =
  assertRefFields dev, "Missing I/O callback implementation"

  # NOTE - original code was `addr &= ~1;` (and identical transformation
  # was used in the `getPortioBase`). Maybe this is a correct emulation,
  # but right now I have no idea, and I cannot find any documentation that
  # backed it up, so I commented this piece out.
  #
  # let memAddr = (memAddr and not(1u16))
  this.portIo[memAddr] = dev
  this.portIoMap[memAddr] = len

proc getPortioBase*(this: var IO, memAddr: U16): U16 =
  ## Given port address, retunr it's base implementation index. For example
  ## - four-byte port is connected at address `0x10`, and then one-byte
  ## read is performed at `0x12`. We need to call implementation that was
  ## mapped to `0x10`, but supply it with `0x12` as an address.
  for i in 0 .. 4: # Starting search from the exact memory location and
                   # going backwards - `0x12`, `0x11`, `0x10` and so on.
    let base: U16 = memAddr - U16(i)
    # If base /is/ known check whether target is in range.
    if base in this.portIoMap:
      # If memory address is within `[base .. base + len]` range, return
      # it.
      let len = this.portIoMap[base]
      if memAddr < base + len:
        return base

      else:
        # Base is properly registered in port, but outside of the expected
        # range. IMO this is an implementation bug - port is either mapped
        # correctly or not.
        return 0

proc inIo8*(
    this: var IO,
    port: U16,
    direct: bool = true,
  ): U8 =
  if direct:
    this.log ev(eekInIOStart).withIt do:
      it.memAddr = port
      it.size = 8

  var v: U8 = 0
  let base: U16 = this.getPortioBase(port)

  try:
    if base != 0:
      v = this.portIo[base].in8(port)

    else:
      raise EmuIoError.withNewIt:
        it.msg = &"No device connected at port {port}"
        it.port = port

  finally:
    if direct:
      this.log ev(eekInIoDone, evalue(v)).withIt do:
        it.memAddr = port
        it.size = 8

      this.log evEnd()

  return v


proc inIo32*(this: var IO, port: U16): U32 =
  var v: U32 = 0
  for i in 0 ..< 4:
    v = (v + this.inIo8(port + U16(i)) shl (8 * i))

  this.log ev(eekInIoDone, evalue(v)).withIt do:
    it.memAddr = port
    it.size = 32

  return v

proc inIo16*(this: var IO, port: U16): U16 =
  var v: U16 = 0
  for i in 0 ..< 2:
    v = (v + this.inIo8(port + U16(i)) shl (8 * i))

  this.log ev(eekInIoDone, evalue(v)).withIt do:
    it.memAddr = port
    it.size = 16

  return v

proc outIo8*(
    this: var IO, port: U16, value: U8, direct: bool = true) =
  if direct:
    this.log ev(eekOutIo, evalue(value), port).withIt do:
      it.size = 8

  var base: U16 = this.getPortioBase(port)
  if base != 0:
    this.portIo[base].out8(port, value)

  else:
    ERROR("no device connected at port : 0x%04x", port)


proc outIo32*(this: var IO, port: U16, value: U32) =
  this.log ev(eekOutIo, evalue(value), port).withIt do:
    it.size = 32

  for i in 0 ..< 4:
    this.outIo8(port + U16(i), U8((value shr (8 * i)) and 0xff))

proc outIo16*(this: var IO, port: U16, value: U16) =
  this.log ev(eekOutIo, evalue(value), port).withIt do:
    it.size = 16

  for i in 0 ..< 2:
    this.outIo8(port + U16(i), U8((value shr (8 * i)) and 0xff))

proc setMemio*(this: var IO, base: U32, len: csizeT, dev: var MemoryIO) =
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
  # Cut lower bits of the memory address
  let memAddr = memAddr and 0xFFFF_0000u32

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

proc writeMemio32*(this: var IO, base: U32, offset: U32, value: U32) =
  ASSERT(base in this.memIo)
  this.log ev(eekSetIo32, evalue(value), offset)
  this.memIo[base].write32(offset, value)

proc writeMemio16*(this: var IO, base: U32, offset: U32, value: U16) =
  ASSERT(base in this.memIo)
  this.log ev(eekSetIo16, evalue(value), offset)
  this.memIo[base].write16(offset, value)

proc writeMemio8*(this: var IO, base: U32, offset: U32, value: U8) =
  ASSERT(base in this.memIo)
  this.log ev(eekSetIo8, evalue(value), offset)
  this.memIo[base].write8(offset, value)
