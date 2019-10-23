; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=cahp -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=CAHP

; Check indexed and unindexed, sext, zext and anyext loads

define i16 @lb(i8 *%a) nounwind {
; CAHP-LABEL: lb:
; CAHP:       # %bb.0:
; CAHP-NEXT:    lb a1, 0(a0)
; CAHP-NEXT:    lb a0, 1(a0)
; CAHP-NEXT:    jr ra
  %1 = getelementptr i8, i8* %a, i16 1
  %2 = load i8, i8* %1
  %3 = sext i8 %2 to i16
  ; the unused load will produce an anyext for selection
  %4 = load volatile i8, i8* %a
  ret i16 %3
}

define i16 @lw(i16 *%a) nounwind {
; CAHP-LABEL: lw:
; CAHP:       # %bb.0:
; CAHP-NEXT:    lw a1, 0(a0)
; CAHP-NEXT:    lw a0, 6(a0)
; CAHP-NEXT:    jr ra
  %1 = getelementptr i16, i16* %a, i16 3
  %2 = load i16, i16* %1
  %3 = load volatile i16, i16* %a
  ret i16 %2
}

define i16 @lbu(i8 *%a) nounwind {
; CAHP-LABEL: lbu:
; CAHP:       # %bb.0:
; CAHP-NEXT:    lbu a1, 0(a0)
; CAHP-NEXT:    lbu a0, 4(a0)
; CAHP-NEXT:    add a0, a0, a1
; CAHP-NEXT:    jr ra
  %1 = getelementptr i8, i8* %a, i16 4
  %2 = load i8, i8* %1
  %3 = zext i8 %2 to i16
  %4 = load volatile i8, i8* %a
  %5 = zext i8 %4 to i16
  %6 = add i16 %3, %5
  ret i16 %6
}

; Check indexed and unindexed stores

define void @sb(i8 *%a, i8 %b) nounwind {
; CAHP-LABEL: sb:
; CAHP:       # %bb.0:
; CAHP-NEXT:    sb a1, 6(a0)
; CAHP-NEXT:    sb a1, 0(a0)
; CAHP-NEXT:    jr ra
  store i8 %b, i8* %a
  %1 = getelementptr i8, i8* %a, i16 6
  store i8 %b, i8* %1
  ret void
}

define void @sw(i16 *%a, i16 %b) nounwind {
; CAHP-LABEL: sw:
; CAHP:       # %bb.0:
; CAHP-NEXT:    sw a1, 16(a0)
; CAHP-NEXT:    sw a1, 0(a0)
; CAHP-NEXT:    jr ra
  store i16 %b, i16* %a
  %1 = getelementptr i16, i16* %a, i16 8
  store i16 %b, i16* %1
  ret void
}

; Check load and store to an i1 location
define i16 @load_sext_zext_anyext_i1(i1 *%a) nounwind {
; CAHP-LABEL: load_sext_zext_anyext_i1:
; CAHP:       # %bb.0:
; CAHP-NEXT:    lb a1, 0(a0)
; CAHP-NEXT:    lbu a1, 1(a0)
; CAHP-NEXT:    lbu a0, 2(a0)
; CAHP-NEXT:    sub a0, a0, a1
; CAHP-NEXT:    jr ra
  ; sextload i1
  %1 = getelementptr i1, i1* %a, i16 1
  %2 = load i1, i1* %1
  %3 = sext i1 %2 to i16
  ; zextload i1
  %4 = getelementptr i1, i1* %a, i16 2
  %5 = load i1, i1* %4
  %6 = zext i1 %5 to i16
  %7 = add i16 %3, %6
  ; extload i1 (anyext). Produced as the load is unused.
  %8 = load volatile i1, i1* %a
  ret i16 %7
}

; Ensure that 1 is added to the high 6 bits if bit 9 of the low part is 1
define i16 @lw_sw_constant(i16 %a) nounwind {
; TODO: the addi should be folded in to the lw/sw
; CAHP-LABEL: lw_sw_constant:
; CAHP:       # %bb.0:
; CAHP-NEXT:    lui a1, 11
; CAHP-NEXT:    addi a2, a1, -139
; CAHP-NEXT:    lw a1, 0(a2)
; CAHP-NEXT:    sw a0, 0(a2)
; CAHP-NEXT:    mov a0, a1
; CAHP-NEXT:    jr ra
  %1 = inttoptr i16 11125 to i16*
  %2 = load volatile i16, i16* %1
  store i16 %a, i16* %1
  ret i16 %2
}
