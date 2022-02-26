template MEMORY_SIZE*() {.dirty.} =
  (4 * MB)

type
  Setting* {.bycopy, importcpp.} = object
    mem_size*: csize_t
    image_name*: cstring
    load_addr*: uint32
    load_size*: csize_t
    ui_enable*: bool
    ui_full*: bool
    ui_vm*: bool
  
proc run_emulator*(set: Setting): void = 
  discard 

proc help*(name: cstring): void = 
  discard 

proc init*(): void = 
  setbuf(stdout, `nil`)
  setbuf(stderr, `nil`)

proc main*(argc: cint, argv: ptr UncheckedArray[cstring]): cint = 
  var set: Setting = (mem_size: MEMORY_SIZE, image_name: "sample/kernel.img", load_addr: 0x0, load_size: cast[csize_t](-1), ui_enable: true, ui_full: false, ui_vm: false)
  var opt: char
  var long_options: ptr UncheckedArray[option] = @([
                    ("memory", required_argument, `nil`, 1), 
                    ("load_addr", required_argument, `nil`, 3), 
                    ("load_size", required_argument, `nil`, 4), 
                    ("full", no_argument, `nil`, 5), 
                    ("VM", no_argument, `nil`, 6), 
                    ("no_graphic", no_argument, `nil`, 7), 
                    ("help", no_argument, `nil`, 104), 
                    (0, 0, 0, 0)
                  ])
  while ((opt = getopt_long(argc, argv, DEBUG_OPT, "m:z:a:s:h", long_options, `nil`)) != -1):
    var v: uint32
    
    case opt:
      of 109, 1:
        v = atoi(optarg)
        if v:
          set.mem_size = v * MB
        
        else:
          WARN("memory size is zero")
        
      of 97, 3:
        set.load_addr = strtol(optarg, `nil`, 0)
      of 115, 4:
        set.load_size = strtol(optarg, `nil`, 0)
      of 5:
        set.ui_full = true
      of 6:
        set.ui_vm = true
      of 7:
        set.ui_enable = false
      of 104, 63:
        help(argv[0])
  if argc > optind:
    set.image_name = argv[optind]
  
  
  run_emulator(set)

proc run_emulator*(set: Setting): void = 
  var emuset: EmuSetting = (mem_size: set.mem_size, uiset: (enable: set.ui_enable, full: set.ui_full, vm: set.ui_vm))
  var emu: Emulator = Emulator(emuset)
  var instr: InstrData
  var instr16: Instr16 = initInstr16(addr emu, addr instr)
  var instr32: Instr32 = initInstr32(addr emu, addr instr)
  if not(emu.insert_floppy(0, set.image_name, false)):
    WARN("cannot load image \'%s\'", set.image_name)
    return 
  
  emu.load_binary("bios/bios.bin", 0xf0000, 0, 0x2800)
  emu.load_binary("bios/crt0.bin", 0xffff0, 0, 0x10)
  if set.load_addr:
    emu.load_binary(set.image_name, set.load_addr, 0x200, set.load_size)
  
  
  
  while (emu.is_running()):
    var is_mode32: bool
    var prefix: uint8
    var chsz_ad: bool
    memset(addr instr, 0, sizeof((InstrData)))
    try:
      if emu.chk_irq():
        emu.do_halt(false)
      
      if emu.is_halt():
        std.this_thread.sleep_for(std.chrono.milliseconds(10))
        continue
      
      emu.hundle_interrupt()
      is_mode32 = emu.is_mode32()
      prefix = ((if is_mode32:
            instr32.parse_prefix()
          
          else:
            instr16.parse_prefix()
          ))
      chsz_op = prefix and CHSZ_OP
      chsz_ad = prefix and CHSZ_AD
      if is_mode32 xor chsz_op:
        instr32.set_chsz_ad(not((is_mode32 xor chsz_ad)))
        instr32.parse()
        instr32.exec()
      
      else:
        instr16.set_chsz_ad(is_mode32 xor chsz_ad)
        instr16.parse()
        instr16.exec()
      
    exceptexception_t as n
      emu.queue_interrupt(n, true)
      
      ERROR("Exception %d", n)
    except
      emu.dump_regs()
      emu.stop()

proc help*(name: cstring): void = 
  MSG("", name)
  MSG("")
  _exit(0)
