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
# CHECK-INST: addi x1, x2, -5
# CHECK: [0x08,0x12,0x61,0xff]
addi x1, x2, -5
# CHECK-INST: xori x1, x2, 5
# CHECK: [0x28,0x12,0xa1,0x00]
xori x1, x2, 5
# CHECK-INST: ori x1, x2, 5
# CHECK: [0x38,0x12,0xa1,0x00]
ori x1, x2, 5
# CHECK-INST: andi x1, x2, 5
# CHECK: [0x48,0x12,0xa1,0x00]
andi x1, x2, 5
# CHECK-INST: slli x1, x2, 9
# CHECK: [0x98,0x12,0x21,0x01]
slli x1, x2, 9
# CHECK-INST: srli x1, x2, 9
# CHECK: [0xa8,0x12,0x21,0x01]
srli x1, x2, 9
# CHECK-INST: srai x1, x2, 9
# CHECK: [0xc8,0x12,0x21,0x01]
srai x1, x2, 9
# CHECK-INST: slti x1, x2, -2
# CHECK: [0x18,0x17,0xc1,0xff]
slti x1, x2, -2
# CHECK-INST: li x1, -500
# CHECK: [0x78,0xfe,0x81,0xc1]
li x1, -500
