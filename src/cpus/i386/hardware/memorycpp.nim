import
  stdinth
import
  stringh
import
  hardware/memoryhpp
proc initMemory*(size: csize_t): Memory_Memory = 
  mem_size = size
  memory = newuint8_t()
  a20gate = false

proc destroyMemory*(this: var Memory): void = 
  cxx_delete memory
  mem_size = 0

proc dump_mem*(this: var Memory, `addr`: uint32, size: csize_t): void = 
  `addr` = (`addr` and not((0x10 - 1)))
  for idx in 0 ..< size:
    MSG("0x%08x : ", `addr` + idx * 0x10)
    for i in 0 ..< 4:
      MSG("%08x ", (cast[ptr uint32](memory()[(`addr` + idx * 0x10) / 4 + i])
    MSG("\\n")

proc read_data*(this: var Memory, dst: pointer, src_addr: uint32, size: csize_t): csize_t = 
  ASSERT_RANGE(src_addr, size)
  memcpy(dst, addr memory[src_addr], size)
  return size

proc write_data*(this: var Memory, dst_addr: uint32, src: pointer, size: csize_t): csize_t = 
  ASSERT_RANGE(dst_addr, size)
  memcpy(addr memory[dst_addr], src, size)
  return size
