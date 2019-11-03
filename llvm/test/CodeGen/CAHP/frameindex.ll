; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=cahp -verify-machineinstrs < %s \
; RUN:   | FileCheck -check-prefix=CAHP %s

declare i16 @bar(i16*)

define i16 @foo() {
; CAHP-LABEL: foo:
; CAHP: # %bb.0:
; CAHP-NEXT:	addi2	sp, -4
; CAHP-NEXT:	swsp	ra, 2(sp)
; CAHP-NEXT:	lui	a0, %hi(bar)
; CAHP-NEXT:	addi	a1, a0, %lo(bar)
; CAHP-NEXT:	addi	a0, sp, 0
; CAHP-NEXT:	jalr	a1
; CAHP-NEXT:	lwsp	a0, 0(sp)
; CAHP-NEXT:	lwsp	ra, 2(sp)
; CAHP-NEXT:	addi2	sp, 4
; CAHP-NEXT:	jr	ra
  %1 = alloca i16
  %2 = call i16 @bar(i16* %1)
  %3 = getelementptr inbounds i16, i16* %1, i16 0
  %4 = load i16, i16* %3
  ret i16 %4
}
