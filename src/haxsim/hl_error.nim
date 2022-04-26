import hmisc/types/colorstring
import hmisc/[base_errors, hdebug_misc]
import std/lenientops


func linesAround*(baseStr: string, charRange: Slice[int]):
  tuple[text: string, startPos, endPos: int] =

  var slice = charRange

  while slice.a > 0 and baseStr[slice.a] != '\n':
    dec slice.a

  if baseStr[slice.a] == '\n':
    inc slice.a

  while slice.b < baseStr.len and baseStr[slice.b] != '\n':
    inc slice.b

  if slice.b >= baseStr.len or baseStr[slice.b] == '\n':
    dec slice.b

  result.text = baseStr[slice]
  result.startPos = charRange.a - slice.a
  result.endPos = result.startPos + (charRange.b - charRange.a)

func renderLine*(c0, r0, c1, r1: int, buf: var ColoredRuneGrid,
                rune: ColoredRune) =
  let
    dc = c1 - c0
    dr = r1 - r0
    steps = if abs(dc) > abs(dr): abs(dc) else: abs(dr)
    cInc = dc / float(steps)
    rInc = dr / float(steps)

  var
    c = c0
    r = r0

  for i in 0 .. steps:
    buf[r, c] = rune
    c += cInc.int
    r += rInc.int

func renderLine*(
  grid: var ColoredRuneGrid, p1, p2: (int, int), rune: ColoredRune) =

  renderLine(p1[0], p1[1], p2[0], p2[1], grid, rune)

proc errorAt*(
  baseStr: string, charRange: Slice[int], message: string) =

  let (slice, a, b) = baseStr.linesAround(charRange)
  var grid = slice.toColoredRuneGrid()

  grid.renderLine((a, 1), (a + 5, 1), toColored('~', initStyle(fgRed)))
  # grid[0, a] = toColored(grid[0, a], initStyle(fgRed))
  grid[1, a] = toColored('^', initStyle(fgRed))
  grid[2, a] = toColored('|', initStyle(fgRed))
  grid[3, a] = toColored('+', initStyle(fgRed))
  grid[3, a] = toColored(message, initStyle(fgRed))

  echo grid
