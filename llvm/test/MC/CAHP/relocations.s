# RUN: llvm-mc -triple cahp < %s -show-encoding \
# RUN:     | FileCheck -check-prefix=INSTR -check-prefix=FIXUP %s
# RUN: llvm-mc -filetype=obj -triple cahp < %s \
# RUN:     | llvm-readobj -r | FileCheck -check-prefix=RELOC %s

# Check prefixes:
# RELOC - Check the relocation in the object.
# FIXUP - Check the fixup on the instruction.
# INSTR - Check the instruction is handled properly by the ASMPrinter

.2byte foo
# RELOC: R_CAHP_16 foo

lui t1, %hi(foo)
# RELOC: R_CAHP_HI6 foo 0x0
# INSTR: lui t1, %hi(foo)
# FIXUP: fixup A - offset: 0, value: %hi(foo), kind: fixup_cahp_hi6

lui t1, %hi(foo+4)
# RELOC: R_CAHP_HI6 foo 0x4
# INSTR: lui t1, %hi(foo+4)
# FIXUP: fixup A - offset: 0, value: %hi(foo+4), kind: fixup_cahp_hi6

addi t1, t1, %lo(foo)
# RELOC: R_CAHP_LO10 foo 0x0
# INSTR: addi t1, t1, %lo(foo)
# FIXUP: fixup A - offset: 0, value: %lo(foo), kind: fixup_cahp_lo10

addi t1, t1, %lo(foo+4)
# RELOC: R_CAHP_LO10 foo 0x4
# INSTR: addi t1, t1, %lo(foo+4)
# FIXUP: fixup A - offset: 0, value: %lo(foo+4), kind: fixup_cahp_lo10

jsal foo
# RELOC: R_CAHP_PCREL_11
# INSTR: jsal foo
# FIXUP: fixup A - offset: 0, value: foo, kind: fixup_cahp_pcrel_11
