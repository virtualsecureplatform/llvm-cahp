# RUN: llvm-mc %s -triple=cahp -show-encoding \
# RUN:     | FileCheck -check-prefixes=CHECK,CHECK-INST %s
# RUN: llvm-mc -filetype=obj -triple=cahp < %s \
# RUN:     | llvm-objdump -d - | FileCheck -check-prefix=CHECK-INSTDUMP %s

# CHECK-INST: hlt
# CHECK-INSTDUMP: js 0
# CHECK: encoding: [0x0e,0x00]
hlt
