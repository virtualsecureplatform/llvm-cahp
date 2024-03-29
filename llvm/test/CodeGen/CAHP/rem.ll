; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=cahp -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=CAHP

define i16 @urem(i16 %a, i16 %b) nounwind {
; CAHP-LABEL: urem:
; CAHP:       # %bb.0:
; CAHP-NEXT:	addi2	sp, -2
; CAHP-NEXT:	swsp	ra, 0(sp)
; CAHP-NEXT:	jsal	__umodhi3
; CAHP-NEXT:	lwsp	ra, 0(sp)
; CAHP-NEXT:	addi2	sp, 2
; CAHP-NEXT:	jr	ra
  %1 = urem i16 %a, %b
  ret i16 %1
}

define i16 @srem(i16 %a, i16 %b) nounwind {
; CAHP-LABEL: srem:
; CAHP:       # %bb.0:
; CAHP-NEXT:	addi2	sp, -2
; CAHP-NEXT:	swsp	ra, 0(sp)
; CAHP-NEXT:	jsal	__modhi3
; CAHP-NEXT:	lwsp	ra, 0(sp)
; CAHP-NEXT:	addi2	sp, 2
; CAHP-NEXT:	jr	ra
  %1 = srem i16 %a, %b
  ret i16 %1
}
