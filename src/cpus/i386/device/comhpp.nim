import commonhpp
import dev_iohpp
type
  COM* {.bycopy.} = object
    portio*: PortIO
