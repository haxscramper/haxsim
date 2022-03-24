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
  Setting* = object
    mem_size*: csize_t
    image_name*: cstring
    load_addr*: uint32
    load_size*: csize_t
    ui_enable*: bool
    ui_full*: bool
    ui_vm*: bool

  FullImpl = object
    data: InstrData
    impl16: Instr16
    impl32: Instr32
    emu: Emulator
  
proc help*(name: cstring): void =
  discard 

proc init*(): void =
  when false:
    setbuf(stdout, nil)
    setbuf(stderr, nil)

proc loop*(full: var FullImpl) =
  while (full.emu.is_running()):
    var is_mode32: bool
    var prefix: uint8
    var chsz_ad, chsz_op: bool
    full.data = InstrData()
    # memset(addr instr, 0, sizeof((InstrData)))
    try:
      if full.emu.intr.chk_irq():
        full.emu.accs.cpu.do_halt(false)

      if full.emu.accs.cpu.is_halt():
        {.warning: "[FIXME] 'std.this_thread.sleep_for(std.chrono.milliseconds(10))'".}
        continue

      full.emu.intr.hundle_interrupt()
      is_mode32 = full.emu.accs.cpu.is_mode32()
      if is_mode32:
        prefix = full.impl32.parse_prefix()

      else:
        prefix = full.impl16.parse_prefix()
      chsz_op = toBool(prefix and CHSZ_OP)
      chsz_ad = toBool(prefix and CHSZ_AD)
      if is_mode32 xor chsz_op:
        full.impl32.set_chsz_ad(not((is_mode32 xor chsz_ad)))
        parse(full.impl32)
        discard exec(full.impl32)

      else:
        full.impl16.set_chsz_ad(is_mode32 xor chsz_ad)
        parse(full.impl16)
        discard exec(full.impl16)

    except:
      # emu.queue_interrupt(n, true)
      assert false
      # ERROR("Exception %d", n)

    # except:
    #   emu.dump_regs()
    #   emu.stop()
  
proc run_emulator*(eset: Setting): void =
  var emuset: EmuSetting
  emuset.mem_size = eset.mem_size
  emuset.uiset.enable = eset.ui_enable
  emuset.uiset.full = eset.ui_full
  emuset.uiset.vm = eset.ui_vm

  var full = FullImpl(emu: initEmulator(emuset))
  full.impl16 = initInstr16(addr full.emu, addr full.data)
  full.impl32 = initInstr32(addr full.emu, addr full.data)

  if not(full.emu.insert_floppy(0, eset.image_name, false)):
    WARN("cannot load image \'%s\'", eset.image_name)
    return 
  
  full.emu.load_binary("bios/bios.bin", 0xf0000, 0, 0x2800)
  full.emu.load_binary("bios/crt0.bin", 0xffff0, 0, 0x10)
  if eset.load_addr.toBool():
    full.emu.load_binary(eset.image_name, eset.load_addr, 0x200, eset.load_size)

  full.loop()

proc main*(): cint =
  var eset = Setting(
    mem_size: MEMORY_SIZE,
    image_name: "sample/kernel.img",
    load_addr: 0x0,
    load_size: cast[csize_t](-1),
    ui_enable: true,
    ui_full: false,
    ui_vm: false)

  var opt: char
  run_emulator(eset)
