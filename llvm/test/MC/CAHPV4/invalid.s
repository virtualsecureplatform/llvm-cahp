# RUN: not llvm-mc -triple cahpv4 < %s 2>&1 | FileCheck %s

# Out of range immediates
addi x1, x2, 1024 # CHECK: :[[@LINE]]:14: error: immediate must be an integer in the range [-1024, 1023]
xori x1, x2, -1025 # CHECK: :[[@LINE]]:14: error: immediate must be an integer in the range [-1024, 1023]
slli x9, x8, 16 # CHECK: :[[@LINE]]:14: error: immediate must be an integer in the range [0, 15]
srli x9, x8, -1 # CHECK: :[[@LINE]]:14: error: immediate must be an integer in the range [0, 15]
li x10, 32768 # CHECK: :[[@LINE]]:9: error: immediate must be an integer in the range [-32768, 32767]
lb x3, -1025(x31) # CHECK: :[[@LINE]]:8: error: immediate must be an integer in the range [-1024, 1023]
sb x3, 1024(x31) # CHECK: :[[@LINE]]:8: error: immediate must be an integer in the range [-1024, 1023]

# Invalid mnemonics
subs x1, x2, x3 # CHECK: :[[@LINE]]:1: error: unrecognized instruction mnemonic
nandi x14, x13, x15 # CHECK: :[[@LINE]]:1: error: unrecognized instruction mnemonic

# Invalid register names
add x32, x30, x31 # CHECK: :[[@LINE]]:5: error: unknown operand

# Invalid operand types
add x15, x1, 1 # CHECK: :[[@LINE]]:14: error: invalid operand for instruction

# Too many operand
add x9, x6, x10, x1 # CHECK: :[[@LINE]]:18: error: invalid operand for instruction

# Too few operands
add x15, x30 # CHECK: :[[@LINE]]:1: error: too few operands for instruction
