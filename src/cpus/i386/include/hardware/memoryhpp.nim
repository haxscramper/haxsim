import
  commonhpp
template DEFAULT_MEMORY_SIZE*() {.dirty.} = 
  (1 * KB)

template ASSERT_RANGE*(`addr`: untyped, len: untyped) {.dirty.} = 
  ASSERT(`addr` + len - 1 < mem_size)

template IN_RANGE*(`addr`: untyped, len: untyped) {.dirty.} = 
  (`addr` + len - 1 < mem_size)

type
  Memory* {.bycopy, importcpp.} = object
    mem_size*: uint32    
    memory*: ptr uint8
    a20gate*: bool    
  
proc set_a20gate*(this: var Memory, ena: bool): void = 
  a20gate = ena

proc is_ena_a20gate*(this: var Memory): bool = 
  return a20gate

proc write_mem8*(this: var Memory, `addr`: uint32, v: uint8): void = 
  if IN_RANGE(`addr`, 1):
    memory[`addr`] = v
  

proc write_mem16*(this: var Memory, `addr`: uint32, v: uint16): void = 
  if IN_RANGE(`addr`, 2):
    (cast[ptr uint16](addr memory[`addr`]))[] = v
  

proc write_mem32*(this: var Memory, `addr`: uint32, v: uint32): void = 
  if IN_RANGE(`addr`, 4):
    (cast[ptr uint32](addr memory[`addr`]))[] = v
  

proc read_mem32*(this: var Memory, `addr`: uint32): uint32 = 
  return (if IN_RANGE(`addr`, 4):
            (cast[ptr uint32](addr memory[`addr`]))[]
          
          else:
            0
          )

proc read_mem16*(this: var Memory, `addr`: uint32): uint16 = 
  return (if IN_RANGE(`addr`, 2):
            (cast[ptr uint16](addr memory[`addr`]))[]
          
          else:
            0
          )

proc read_mem8*(this: var Memory, `addr`: uint32): uint8 = 
  return (if IN_RANGE(`addr`, 1):
            memory[`addr`]
          
          else:
            0
          )
