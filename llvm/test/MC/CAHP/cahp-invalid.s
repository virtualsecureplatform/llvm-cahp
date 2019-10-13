# RUN: not llvm-mc -triple cahp < %s 2>&1 | FileCheck %s

# Out of range immediates
lw a4, 1024(a2) # CHECK: :[[@LINE]]:8: error: immediate must be a multiple of 2 bytes in the range [-1024, 1022]
lb a4, -513(a2) # CHECK: :[[@LINE]]:8: error: immediate must be an integer in the range [-512, 511]
lbu a4, -513(a2) # CHECK: :[[@LINE]]:9: error: immediate must be an integer in the range [-512, 511]
sw a4, -1025(a2) # CHECK: :[[@LINE]]:8: error: immediate must be a multiple of 2 bytes in the range [-1024, 1022]
sb a4, 512(a2) # CHECK: :[[@LINE]]:8: error: immediate must be an integer in the range [-512, 511]
li t0, -513 # CHECK: :[[@LINE]]:8: error: immediate must be an integer in the range [-512, 511]
li s0, 512 # CHECK: :[[@LINE]]:8: error: immediate must be an integer in the range [-512, 511]
addi a0, a1, 128 # CHECK: :[[@LINE]]:14: error: immediate must be an integer in the range [-128, 127]
addi a0, a1, -129 # CHECK: :[[@LINE]]:14: error: immediate must be an integer in the range [-128, 127]
andi a0, a1, 256 # CHECK: :[[@LINE]]:14: error: immediate must be an integer in the range [0, 255]
andi a0, a1, -1 # CHECK: :[[@LINE]]:14: error: immediate must be an integer in the range [0, 255]
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
add foo, x1, x3 # CHECK: :[[@LINE]]:5: error: unknown operand
sub x0, x16, x4 # CHECK: :[[@LINE]]:9: error: unknown operand
mov t2, x8 # CHECK: :[[@LINE]]:5: error: unknown operand

# Invalid operand types
add x15, x1, 1 # CHECK: :[[@LINE]]:14: error: invalid operand for instruction

# Too many operand
mov x8, x9, x10 # CHECK: :[[@LINE]]:13: error: invalid operand for instruction
li x11, x12, x13 # CHECK: :[[@LINE]]:9: error: invalid operand for instruction

# Too few operands
li x8 # CHECK: :[[@LINE]]:1: error: too few operands for instruction
mov x13 # CHECK: :[[@LINE]]:1: error: too few operands for instruction
