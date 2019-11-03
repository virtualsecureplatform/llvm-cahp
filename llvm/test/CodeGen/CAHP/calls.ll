; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=cahp -verify-machineinstrs < %s \
; RUN:   | FileCheck -check-prefix=CAHP %s

declare i16 @external_function(i16)

define i16 @test_call_external(i16 %a) nounwind {
; CAHP-LABEL: test_call_external:
; CAHP:       # %bb.0:
; CAHP-NEXT:	addi2	sp, -2
; CAHP-NEXT:	swsp	ra, 0(sp)
; CAHP-NEXT:	lui	a1, %hi(external_function)
; CAHP-NEXT:	addi	a1, a1, %lo(external_function)
; CAHP-NEXT:	jalr	a1
; CAHP-NEXT:	lwsp	ra, 0(sp)
; CAHP-NEXT:	addi2	sp, 2
; CAHP-NEXT:	jr	ra
  %1 = call i16 @external_function(i16 %a)
  ret i16 %1
}

define i16 @defined_function(i16 %a) nounwind {
; CAHP-LABEL: defined_function:
; CAHP:       # %bb.0:
; CAHP-NEXT:	addi2	a0, 1
; CAHP-NEXT:	jr	ra
  %1 = add i16 %a, 1
  ret i16 %1
}

define i16 @test_call_defined(i16 %a) nounwind {
; CAHP-LABEL: test_call_defined:
; CAHP:       # %bb.0:
; CAHP-NEXT:	addi2	sp, -2
; CAHP-NEXT:	swsp	ra, 0(sp)
; CAHP-NEXT:	lui	a1, %hi(defined_function)
; CAHP-NEXT:	addi	a1, a1, %lo(defined_function)
; CAHP-NEXT:	jalr	a1
; CAHP-NEXT:	lwsp	ra, 0(sp)
; CAHP-NEXT:	addi2	sp, 2
; CAHP-NEXT:	jr	ra
  %1 = call i16 @defined_function(i16 %a) nounwind
  ret i16 %1
}

define i16 @test_call_indirect(i16 (i16)* %a, i16 %b) nounwind {
; CAHP-LABEL: test_call_indirect:
; CAHP:       # %bb.0:
; CAHP-NEXT:	addi2	sp, -2
; CAHP-NEXT:	swsp	ra, 0(sp)
; CAHP-NEXT:	mov	a2, a0
; CAHP-NEXT:	mov	a0, a1
; CAHP-NEXT:	jalr	a2
; CAHP-NEXT:	lwsp	ra, 0(sp)
; CAHP-NEXT:	addi2	sp, 2
; CAHP-NEXT:	jr	ra
  %1 = call i16 %a(i16 %b)
  ret i16 %1
}
