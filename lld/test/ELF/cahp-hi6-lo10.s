# REQUIRES: cahp

# RUN: llvm-mc -filetype=obj -triple=cahp %s -o %t.o

# RUN: ld.lld %t.o --defsym foo=0 --defsym bar=42 -o %t
# RUN: llvm-objdump -d %t | FileCheck %s
# CHECK:      04 08           lui	a0, 0
# CHECK-NEXT: 03 88 00        addi	a0, a0, 0
# CHECK-NEXT: 1d 88 00        sw	a0, 0(a0)
# CHECK-NEXT: 04 09           lui	a1, 0
# CHECK-NEXT: 03 99 2a        addi	a1, a1, 42
# CHECK-NEXT: 1d 99 2a        sw	a1, 42(a1)

# RUN: ld.lld %t.o --defsym foo=0x7fff --defsym bar=0x7dff -o %t.limits
# RUN: llvm-objdump -d %t.limits | FileCheck --check-prefix=LIMITS %s
# LIMITS:      84 08                        	lui	a0, -32
# LIMITS-NEXT: c3 88 ff                     	addi	a0, a0, -1
# LIMITS-NEXT: dd 88 ff                     	sw	a0, -1(a0)
# LIMITS-NEXT: 44 f9                        	lui	a1, 31
# LIMITS-NEXT: 43 99 ff                     	addi	a1, a1, 511
# LIMITS-NEXT: 5d 99 ff                     	sw	a1, 511(a1)

.global _start

_start:
    lui     a0, %hi(foo)
    addi    a0, a0, %lo(foo)
    sw      a0, %lo(foo)(a0)
    lui     a1, %hi(bar)
    addi    a1, a1, %lo(bar)
    sw      a1, %lo(bar)(a1)

