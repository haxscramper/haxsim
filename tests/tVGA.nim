import hmisc/core/all
import std/[sequtils, strutils]
import common
import hmisc/preludes/unittest
import hmisc/algo/clformat

import compiler/[assembler]
import hardware/[processor, memory]
import emulator/[emulator, access]
import device/[vga]
import instruction/[syntaxes]
import maincpp

let op = hdisplay(flags += { dfSplitNumbers, dfUseHex })

setTestContextDisplayOpts op
startHax()

suite "Write character to VGA":
  test "Write single character":
    var emu = eval([
      "mov dx, 0x3C2", # Enable 'ER' register
      "mov al, 0b10",
      "out dx, al",

      # Enable planes zero and one for sequencer writes
      "mov dx, 0x3C4", # Select target register on the CRT
      "mov al, 0x02",
      "out dx, al",

      "mov dx, 0x3C5", # Write data to target register on CRT
      "mov al, 0b11",
      "out dx, al",

      # Set horizontal resolution of the VGA
      "mov dx, 0x03b4",
      "mov al, 0x1",
      "out dx, al",
      "mov dx, 0x03b5",
      "mov al, 0x28",
      "out dx, al",

      # Set vertical resolution of the VGA
      "mov dx, 0x03b4",
      "mov al, 0x12",
      "out dx, al",
      "mov dx, 0x03b5",
      "mov al, 0x19",
      "out dx, al",

      # Move data to video memory
      "mov ebx, 0xB8000",
      "mov byte [ebx], 65", # Codepoint 'A', code is `65`
      "mov byte [ebx+1], 0x7", # Character attribute `0b111`
      "hlt"
    ], protMode = true, log = true)

    let txt = emu.vga.txtBuffer()

    emu.logger.enabled = false
    for row in txt:
      echo "|", row.mapIt(tern(it[0] == '\x00', ' ', it[0])).join(""), "|"
