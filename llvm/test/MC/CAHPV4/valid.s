# RUN: llvm-mc %s -triple=cahpv4 -show-encoding \
# RUN:     | FileCheck -check-prefixes=CHECK,CHECK-INST %s

# CHECK-INST: add x1, x2, x3
# CHECK: encoding: [0x08,0x10,0x61,0x00]
add x1, x2, x3
# CHECK-INST: add x16, x17, x18
# CHECK: encoding: [0x08,0x88,0x50,0x02]
add x16, x17, x18
# CHECK-INST: sub x1, x2, x3
# CHECK: encoding: [0x18,0x10,0x61,0x00]
sub x1, x2, x3
# CHECK-INST: xor x1, x2, x3
# CHECK: encoding: [0x28,0x10,0x61,0x00]
xor x1, x2, x3
# CHECK-INST: or x1, x2, x3
# CHECK: encoding: [0x38,0x10,0x61,0x00]
or x1, x2, x3
# CHECK-INST: and x1, x2, x3
# CHECK: encoding: [0x48,0x10,0x61,0x00]
and x1, x2, x3
# CHECK-INST: sll x1, x2, x3
# CHECK: encoding: [0x98,0x10,0x61,0x00]
sll x1, x2, x3
# CHECK-INST: srl x1, x2, x3
# CHECK: encoding: [0xa8,0x10,0x61,0x00]
srl x1, x2, x3
# CHECK-INST: sra x1, x2, x3
# CHECK: encoding: [0xc8,0x10,0x61,0x00]
sra x1, x2, x3
# CHECK-INST: slt x1, x2, x3
# CHECK: encoding: [0x18,0x15,0x61,0x00]
slt x1, x2, x3
# CHECK-INST: sltu x1, x2, x3
# CHECK: encoding: [0x08,0x11,0x61,0x00]
sltu x1, x2, x3
