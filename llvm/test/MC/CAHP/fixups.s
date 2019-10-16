# RUN: llvm-mc -triple cahp < %s -show-encoding \
# RUN:     | FileCheck -check-prefix=CHECK-FIXUP %s
# RUN: llvm-mc -filetype=obj -triple cahp < %s \
# RUN:     | llvm-objdump -d - | FileCheck -check-prefix=CHECK-INSTR %s

# Checks that fixups that can be resolved within the same object file are
# applied correctly

.LBB0:
.space 1024
js .LBB0
# CHECK-FIXUP: fixup A - offset: 0, value: .LBB0, kind: fixup_cahp_pcrel_11
# CHECK-INSTR: js -1024

.LBB1:
.space 1024
jsal .LBB1
# CHECK-FIXUP: fixup A - offset: 0, value: .LBB1, kind: fixup_cahp_pcrel_11
# CHECK-INSTR: jsal -1024

.LBB2:
.space 512
beq a0, a1, .LBB2
# CHECK-FIXUP: fixup A - offset: 0, value: .LBB2, kind: fixup_cahp_pcrel_10
# CHECK-INSTR: beq a0, a1, -512

.LBB3:
.space 512
bne a0, a1, .LBB3
# CHECK-FIXUP: fixup A - offset: 0, value: .LBB3, kind: fixup_cahp_pcrel_10
# CHECK-INSTR: bne a0, a1, -512

.LBB4:
.space 512
blt a0, a1, .LBB4
# CHECK-FIXUP: fixup A - offset: 0, value: .LBB4, kind: fixup_cahp_pcrel_10
# CHECK-INSTR: blt a0, a1, -512

.LBB5:
.space 512
bltu a0, a1, .LBB5
# CHECK-FIXUP: fixup A - offset: 0, value: .LBB5, kind: fixup_cahp_pcrel_10
# CHECK-INSTR: bltu a0, a1, -512

.LBB6:
.space 512
ble a0, a1, .LBB6
# CHECK-FIXUP: fixup A - offset: 0, value: .LBB6, kind: fixup_cahp_pcrel_10
# CHECK-INSTR: ble a0, a1, -512

.LBB7:
.space 512
bleu a0, a1, .LBB7
# CHECK-FIXUP: fixup A - offset: 0, value: .LBB7, kind: fixup_cahp_pcrel_10
# CHECK-INSTR: bleu a0, a1, -512
