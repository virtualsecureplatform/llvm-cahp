# RUN: not llvm-mc -triple cahpv4 < %s 2>&1 | FileCheck %s

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
