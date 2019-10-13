# RUN: llvm-mc %s -triple=cahp -show-encoding \
# RUN:     | FileCheck -check-prefixes=CHECK,CHECK-INST %s

# CHECK-INST: lw ra, -1000(sp)
# CHECK: encoding: [0x95,0x10,0x0c]
lw ra, -1000(sp)
# CHECK-INST: lb ra, -500(sp)
# CHECK: encoding: [0xa5,0x10,0x0c]
lb ra, -500(sp)
# CHECK-INST: lbu ra, -500(sp)
# CHECK: encoding: [0x85,0x10,0x0c]
lbu ra, -500(sp)
# CHECK-INST: sw ra, -1000(sp)
# CHECK: encoding: [0x9d,0x10,0x0c]
sw ra, -1000(sp)
# CHECK-INST: sb ra, -500(sp)
# CHECK: encoding: [0x8d,0x10,0x0c]
sb ra, -500(sp)
# CHECK-INST: li ra, -500
# CHECK: encoding: [0xb5,0x00,0x0c]
li ra, -500
# CHECK-INST: add ra, sp, fp
# CHECK: encoding: [0x01,0x10,0x02]
add ra, sp, fp
# CHECK-INST: sub ra, sp, fp
# CHECK: encoding: [0x09,0x10,0x02]
sub ra, sp, fp
# CHECK-INST: and ra, sp, fp
# CHECK: encoding: [0x11,0x10,0x02]
and ra, sp, fp
# CHECK-INST: xor ra, sp, fp
# CHECK: encoding: [0x19,0x10,0x02]
xor ra, sp, fp
# CHECK-INST: or ra, sp, fp
# CHECK: encoding: [0x21,0x10,0x02]
or ra, sp, fp
# CHECK-INST: lsl ra, sp, fp
# CHECK: encoding: [0x29,0x10,0x02]
lsl ra, sp, fp
# CHECK-INST: lsr ra, sp, fp
# CHECK: encoding: [0x31,0x10,0x02]
lsr ra, sp, fp
# CHECK-INST: asr ra, sp, fp
# CHECK: encoding: [0x39,0x10,0x02]
asr ra, sp, fp
# CHECK-INST: addi ra, sp, -10
# CHECK: encoding: [0xc3,0x10,0xf6]
addi ra, sp, -10
# CHECK-INST: addi ra, sp, 10
# CHECK: encoding: [0xc3,0x10,0x0a]
addi ra, sp, 10
# CHECK-INST: andi ra, sp, 10
# CHECK: encoding: [0x53,0x10,0x0a]
andi ra, sp, 10
# CHECK-INST: xori ra, sp, 10
# CHECK: encoding: [0x5b,0x10,0x0a]
xori ra, sp, 10
# CHECK-INST: ori ra, sp, 10
# CHECK: encoding: [0x63,0x10,0x0a]
ori ra, sp, 10
# CHECK-INST: lsli ra, sp, 3
# CHECK: encoding: [0x2b,0x10,0x03]
lsli ra, sp, 3
# CHECK-INST: lsri ra, sp, 3
# CHECK: encoding: [0x33,0x10,0x03]
lsri ra, sp, 3
# CHECK-INST: asri ra, sp, 4
# CHECK: encoding: [0x3b,0x10,0x04]
asri ra, sp, 4
# CHECK-INST: beq ra, sp, 16
# CHECK: encoding: [0x0f,0x01,0x10]
beq ra, sp, 16
# CHECK-INST: beq ra, sp, 16
# CHECK: encoding: [0x0f,0x01,0x10]
beq ra, sp, 16
# CHECK-INST: bne ra, sp, 16
# CHECK: encoding: [0x2f,0x01,0x10]
bne ra, sp, 16
# CHECK-INST: bne ra, sp, 16
# CHECK: encoding: [0x2f,0x01,0x10]
bne ra, sp, 16
# CHECK-INST: blt ra, sp, 16
# CHECK: encoding: [0x37,0x01,0x10]
blt ra, sp, 16
# CHECK-INST: blt ra, sp, 16
# CHECK: encoding: [0x37,0x01,0x10]
blt ra, sp, 16
# CHECK-INST: blt ra, sp, 16
# CHECK: encoding: [0x37,0x01,0x10]
blt ra, sp, 16
# CHECK-INST: bltu ra, sp, 16
# CHECK: encoding: [0x17,0x01,0x10]
bltu ra, sp, 16
# CHECK-INST: bltu ra, sp, 16
# CHECK: encoding: [0x17,0x01,0x10]
bltu ra, sp, 16
# CHECK-INST: bltu ra, sp, 16
# CHECK: encoding: [0x17,0x01,0x10]
bltu ra, sp, 16
# CHECK-INST: ble ra, sp, 16
# CHECK: encoding: [0x3f,0x01,0x10]
ble ra, sp, 16
# CHECK-INST: ble ra, sp, 16
# CHECK: encoding: [0x3f,0x01,0x10]
ble ra, sp, 16
# CHECK-INST: ble ra, sp, 16
# CHECK: encoding: [0x3f,0x01,0x10]
ble ra, sp, 16
# CHECK-INST: bleu ra, sp, 16
# CHECK: encoding: [0x1f,0x01,0x10]
bleu ra, sp, 16
# CHECK-INST: bleu ra, sp, 16
# CHECK: encoding: [0x1f,0x01,0x10]
bleu ra, sp, 16
# CHECK-INST: bleu ra, sp, 16
# CHECK: encoding: [0x1f,0x01,0x10]
bleu ra, sp, 16
# CHECK-INST: lwsp ra, 32(sp)
# CHECK: encoding: [0x54,0x00]
lwsp ra, 32(sp)
# CHECK-INST: swsp ra, 64(sp)
# CHECK: encoding: [0x9c,0x00]
swsp ra, 64(sp)
# CHECK-INST: lsi ra, -32
# CHECK: encoding: [0xb4,0x00]
lsi ra, -32
# CHECK-INST: lui ra, 32
# CHECK: encoding: [0x84,0x00]
lui ra, 32
# CHECK-INST: mov ra, sp
# CHECK: encoding: [0xc0,0x10]
mov ra, sp
# CHECK-INST: add2 ra, sp
# CHECK: encoding: [0x80,0x10]
add2 ra, sp
# CHECK-INST: sub2 ra, sp
# CHECK: encoding: [0x88,0x10]
sub2 ra, sp
# CHECK-INST: and2 ra, sp
# CHECK: encoding: [0x90,0x10]
and2 ra, sp
# CHECK-INST: xor2 ra, sp
# CHECK: encoding: [0x98,0x10]
xor2 ra, sp
# CHECK-INST: or2 ra, sp
# CHECK: encoding: [0xa0,0x10]
or2 ra, sp
# CHECK-INST: or2 ra, sp
# CHECK: encoding: [0xa0,0x10]
or2 ra, sp
# CHECK-INST: lsl2 ra, sp
# CHECK: encoding: [0xa8,0x10]
lsl2 ra, sp
# CHECK-INST: lsr2 ra, sp
# CHECK: encoding: [0xb0,0x10]
lsr2 ra, sp
# CHECK-INST: asr2 ra, sp
# CHECK: encoding: [0xb8,0x10]
asr2 ra, sp
# CHECK-INST: lsli2 ra, 3
# CHECK: encoding: [0x2a,0x30]
lsli2 ra, 3
# CHECK-INST: lsri2 ra, 3
# CHECK: encoding: [0x32,0x30]
lsri2 ra, 3
# CHECK-INST: asri2 ra, 3
# CHECK: encoding: [0x3a,0x30]
asri2 ra, 3
# CHECK-INST: addi2 ra, -32
# CHECK: encoding: [0x82,0x00]
addi2 ra, -32
# CHECK-INST: andi2 ra, 26
# CHECK: encoding: [0x52,0xa0]
andi2 ra, 26
# CHECK-INST: jalr sp
# CHECK: encoding: [0x16,0x01]
jalr sp
# CHECK-INST: jr sp
# CHECK: encoding: [0x06,0x01]
jr sp
# CHECK-INST: js 8
# CHECK: encoding: [0x0e,0x01]
js 8
# CHECK-INST: jsal 8
# CHECK: encoding: [0x1e,0x01]
jsal 8
# CHECK-INST: nop
# CHECK: encoding: [0x00,0x00]
nop
