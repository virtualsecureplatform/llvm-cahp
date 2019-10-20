# RUN: not llvm-mc -triple cahp < %s 2>&1 | FileCheck %s

# Out of range immediates
lw a4, 512(a2) # CHECK: :[[@LINE]]:8: error: immediate must be an integer in the range [-512, 511]
lb a4, -513(a2) # CHECK: :[[@LINE]]:8: error: immediate must be an integer in the range [-512, 511]
lbu a4, -513(a2) # CHECK: :[[@LINE]]:9: error: immediate must be an integer in the range [-512, 511]
sw a4, -513(a2) # CHECK: :[[@LINE]]:8: error: immediate must be an integer in the range [-512, 511]
sb a4, 512(a2) # CHECK: :[[@LINE]]:8: error: immediate must be an integer in the range [-512, 511]
li t0, -513 # CHECK: :[[@LINE]]:8: error: immediate must be an integer in the range [-512, 511]
li s0, 512 # CHECK: :[[@LINE]]:8: error: immediate must be an integer in the range [-512, 511]
addi a0, a1, 512 # CHECK: :[[@LINE]]:14: error: immediate must be an integer in the range [-512, 511]
addi a0, a1, -513 # CHECK: :[[@LINE]]:14: error: immediate must be an integer in the range [-512, 511]
andi a0, a1, 1024 # CHECK: :[[@LINE]]:14: error: immediate must be an integer in the range [0, 1023]
xori a0, a1, -1 # CHECK: :[[@LINE]]:14: error: immediate must be an integer in the range [0, 1023]
lsli a0, a1, 16 # CHECK: :[[@LINE]]:14: error: immediate must be an integer in the range [0, 15]
asri a0, a1, -1 # CHECK: :[[@LINE]]:14: error: immediate must be an integer in the range [0, 15]
lwsp a4, 128(sp) # CHECK: :[[@LINE]]:10: error: immediate must be a multiple of 2 bytes in the range [0, 126]
swsp a3, -2(sp) # CHECK: :[[@LINE]]:10: error: immediate must be a multiple of 2 bytes in the range [0, 126]
lsi a5, 32 # CHECK: :[[@LINE]]:9: error: immediate must be an integer in the range [-32, 31]
lsi a5, -33 # CHECK: :[[@LINE]]:9: error: immediate must be an integer in the range [-32, 31]
lui a5, 65 # CHECK: :[[@LINE]]:9: error: immediate must be an integer in the range [0, 63]
lui a5, -1 # CHECK: :[[@LINE]]:9: error: immediate must be an integer in the range [0, 63]
js 1024 # CHECK: :[[@LINE]]:4: error: immediate must be an integer in the range [-1024, 1023]
js -1025 # CHECK: :[[@LINE]]:4: error: immediate must be an integer in the range [-1024, 1023]

# Invalid mnemonics
subs x1, x2 # CHECK: :[[@LINE]]:1: error: unrecognized instruction mnemonic
nandi x14, x13 # CHECK: :[[@LINE]]:1: error: unrecognized instruction mnemonic

# Invalid register names
add foo, x1, x3 # CHECK: :[[@LINE]]:5: error: invalid operand for instruction
sub x0, x16, x4 # CHECK: :[[@LINE]]:9: error: invalid operand for instruction
mov t2, x8 # CHECK: :[[@LINE]]:5: error: invalid operand for instruction

# Invalid operand types
add x15, x1, 1 # CHECK: :[[@LINE]]:14: error: invalid operand for instruction

# Too many operand
mov x8, x9, x10 # CHECK: :[[@LINE]]:13: error: invalid operand for instruction
li x11, x12, x13 # CHECK: :[[@LINE]]:9: error: invalid operand for instruction

# Too few operands
li x8 # CHECK: :[[@LINE]]:1: error: too few operands for instruction
mov x13 # CHECK: :[[@LINE]]:1: error: too few operands for instruction

# Illegal operand modifier
lsli a0, a0, %lo(1) # CHECK: :[[@LINE]]:14: error: immediate must be an integer in the range [0, 15]
ori a0, a1, %hi(foo) # CHECK: :[[@LINE]]:13: error: immediate must be an integer in the range [0, 1023]
lui a0, %lo(1) # CHECK: :[[@LINE]]:9: error: immediate must be an integer in the range [0, 63]
addi t0, sp, %modifer(255) # CHECK: :[[@LINE]]:15: error: unrecognized operand modifier
addi t1, %lo(t2), 1 # CHECK: :[[@LINE]]:10: error: invalid operand for instruction
