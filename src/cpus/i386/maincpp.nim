import "commonhpp"
import emulator/[emulatorhpp, interruptcpp]
import hardware/[processorhpp]
import instruction/[
  instructionhpp,
  basehpp,
  instr16cpp,
  instr32cpp,
  parsecpp,
  execcpp
]

template MEMORY_SIZE*(): untyped {.dirty.} =
  (4 * MB)

type
  Setting* {.bycopy.} = object
    mem_size*: csize_t
    image_name*: cstring
    load_addr*: uint32
    load_size*: csize_t
    ui_enable*: bool
    ui_full*: bool
    ui_vm*: bool
  
proc run_emulator*(set: Setting): void

proc help*(name: cstring): void = 
  discard 

proc init*(): void =
  when false:
    setbuf(stdout, nil)
    setbuf(stderr, nil)

proc main*(argc: cint, argv: ptr UncheckedArray[cstring]): cint = 
  var set = Setting(
    mem_size: MEMORY_SIZE,
    image_name: "sample/kernel.img",
    load_addr: 0x0,
    load_size: cast[csize_t](-1),
    ui_enable: true,
    ui_full: false,
    ui_vm: false)

  var opt: char
  run_emulator(set)

proc run_emulator*(set: Setting): void = 
  var emuset: EmuSetting
  emuset.mem_size = set.mem_size
  emuset.uiset.enable = set.ui_enable
  emuset.uiset.full = set.ui_full
  emuset.uiset.vm = set.ui_vm

  var emu: Emulator = initEmulator(emuset)
  var instr: InstrData
  var instr16: Instr16 = initInstr16(addr emu, addr instr)
  var instr32: Instr32 = initInstr32(addr emu, addr instr)

  if not(emu.insert_floppy(0, set.image_name, false)):
    WARN("cannot load image \'%s\'", set.image_name)
    return 
  
  emu.load_binary("bios/bios.bin", 0xf0000, 0, 0x2800)
  emu.load_binary("bios/crt0.bin", 0xffff0, 0, 0x10)
  if set.load_addr.toBool():
    emu.load_binary(set.image_name, set.load_addr, 0x200, set.load_size)
  
  
  
  while (emu.is_running()):
    var is_mode32: bool
    var prefix: uint8
    var chsz_ad, chsz_op: bool
    instr = InstrData()
    # memset(addr instr, 0, sizeof((InstrData)))
    try:
      if emu.intr.chk_irq():
        emu.accs.cpu.do_halt(false)
      
      if emu.accs.cpu.is_halt():
        {.warning: "[FIXME] 'std.this_thread.sleep_for(std.chrono.milliseconds(10))'".}
        continue
      
      emu.intr.hundle_interrupt()
      is_mode32 = emu.accs.cpu.is_mode32()
      if is_mode32:
        prefix = instr32.parse_prefix()

      else:
        prefix = instr16.parse_prefix()
      chsz_op = toBool(prefix and CHSZ_OP)
      chsz_ad = toBool(prefix and CHSZ_AD)
      if is_mode32 xor chsz_op:
        instr32.set_chsz_ad(not((is_mode32 xor chsz_ad)))
        parse(instr32)
        discard exec(instr32)
      
      else:
        instr16.set_chsz_ad(is_mode32 xor chsz_ad)
        parse(instr16)
        discard exec(instr16)
      
    except:
      # emu.queue_interrupt(n, true)
      assert false
      # ERROR("Exception %d", n)

    # except:
    #   emu.dump_regs()
    #   emu.stop()
