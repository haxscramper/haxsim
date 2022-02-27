import
  commonhpp
template DEFAULT_MEMORY_SIZE*(): untyped {.dirty.} =
  (1 * KB)

template ASSERT_RANGE*(`addr`: untyped, len: untyped): untyped {.dirty.} =
  ASSERT(`addr` + len - 1 < this.mem_size)

template IN_RANGE*(`addr`: untyped, len: untyped): untyped {.dirty.} =
  (`addr` + len - 1 < this.mem_size)

type
  Memory* {.bycopy, importcpp.} = object
    mem_size*: uint32
    memory*: ptr UncheckedArray[uint8]
    a20gate*: bool

proc set_a20gate*(this: var Memory, ena: bool): void =
  this.a20gate = ena

proc is_ena_a20gate*(this: Memory): bool =
  return this.a20gate

proc write_mem8*(this: var Memory, `addr`: uint32, v: uint8): void =
  if IN_RANGE(`addr`, 1):
    this.memory[`addr`] = v


proc write_mem16*(this: var Memory, `addr`: uint32, v: uint16): void =
  if IN_RANGE(`addr`, 2):
    (cast[ptr uint16](addr this.memory[`addr`]))[] = v


proc write_mem32*(this: var Memory, `addr`: uint32, v: uint32): void =
  if IN_RANGE(`addr`, 4):
    (cast[ptr uint32](addr this.memory[`addr`]))[] = v


proc read_mem32*(this: var Memory, `addr`: uint32): uint32 =
  if IN_RANGE(`addr`, 4):
    return (cast[ptr uint32](addr this.memory[`addr`]))[]

  else:
    return 0

proc read_mem16*(this: var Memory, `addr`: uint32): uint16 =
  if IN_RANGE(`addr`, 2):
    return (cast[ptr uint16](addr this.memory[`addr`]))[]

  else:
    return 0

proc read_mem8*(this: var Memory, `addr`: uint32): uint8 =
  if IN_RANGE(`addr`, 1):
    return this.memory[`addr`]

  else:
    return 0

proc initMemory*(size: uint32): Memory =
  result.mem_size = size
  # FIXME allocate memory array
  # result.memory = newSeq[uint8](size)
  result.a20gate = false

proc destroyMemory*(this: var Memory): void =
  # cxx_delete memory
  this.mem_size = 0

proc dump_mem*(this: var Memory, `addr`: uint32, size: csize_t): void =
  let `addr` = (`addr` and not((0x10 - 1)).uint32())
  for idx in 0 ..< size:
    MSG("0x%08x : ", `addr` + idx * 0x10)
    for i in 0 ..< 4:
      MSG("%08x ", (cast[ptr UncheckedArray[uint32]](this.memory))[
        (`addr` + idx * 0x10) div 4 + uint64(i)])

    MSG("\\n")

proc read_data*(this: var Memory, dst: pointer, src_addr: uint32, size: csize_t): csize_t =
  ASSERT_RANGE(src_addr, size)
  copymem(dest = dst, source = addr this.memory[src_addr], size = size)
  return size

proc write_data*(this: var Memory, dst_addr: uint32, src: pointer, size: csize_t): csize_t =
  ASSERT_RANGE(dst_addr, size)
  copymem(dest = addr this.memory[dst_addr], source = src, size = size)
  return size
