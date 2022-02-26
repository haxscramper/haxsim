import util/debughpp
export debughpp

const KB* = 1024
template MB*(): untyped {.dirty.} = (KB * 1024)
template GB*(): untyped {.dirty.} = (MB * 1024)
