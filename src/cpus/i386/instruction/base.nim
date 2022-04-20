import instruction

template instr*(b: InstrImpl): untyped = b.exec.instr
