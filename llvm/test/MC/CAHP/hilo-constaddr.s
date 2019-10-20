# RUN: llvm-mc -filetype=obj -triple=cahp %s \
# RUN:  | llvm-objdump -d - | FileCheck %s -check-prefix=CHECK-INSTR

# RUN: llvm-mc -filetype=obj -triple=cahp %s \
# RUN:  | llvm-readobj -r | FileCheck %s -check-prefix=CHECK-REL

# Check the assembler can handle hi and lo expressions with a constant
# address, and constant expressions involving labels. Test case derived from
# test/MC/Mips/hilo-addressing.s

# Check that 1 is added to the high 6 bits if bit 9 of the low part is 1.
.equ addr, 0x1234
  lui t0, %hi(addr)
  lw ra, %lo(addr)(t0)
# CHECK-INSTR: lui t0, 5
# CHECK-INSTR: lw ra, -460(t0)

# Check that assembler can handle %hi(label1 - label2) and %lo(label1 - label2)
# expressions.

tmp1:
  # Emit zeros so that difference between tmp1 and tmp3 is 0x1234+5 bytes.
  .fill 0x1234
tmp2:
  lui t0, %hi(tmp3-tmp1)
  lw ra, %lo(tmp3-tmp1)(t0)
# CHECK-INSTR: lui t0, 5
# CHECK-INSTR: lw ra, -455(t0)

tmp3:
  lui t1, %hi(tmp2-tmp3)
  lw sp, %lo(tmp2-tmp3)(t1)
# CHECK-INSTR: lui t1, 0
# CHECK-INSTR: lw sp, -5(t1)

# Check that a relocation isn't emitted for %hi(label1 - label2) and
# %lo(label1 - label2) expressions.

# CHECK-REL-NOT: R_CAHP
