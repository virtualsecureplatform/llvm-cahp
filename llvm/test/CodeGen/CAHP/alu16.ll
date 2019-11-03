; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=cahp -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=CAHP

; Register-immediate instructions

define i16 @addi(i16 %a, i16 %b) nounwind {
; CAHP-LABEL: addi:
; CAHP:       # %bb.0:
; CAHP-NEXT:    addi a0, a1, 1
; CAHP-NEXT:    jr ra
  %1 = add i16 %b, 1
  ret i16 %1
}

define i16 @addi2(i16 %a) nounwind {
; CAHP-LABEL: addi2:
; CAHP:       # %bb.0:
; CAHP-NEXT:    addi2 a0, 1
; CAHP-NEXT:    jr ra
  %1 = add i16 %a, 1
  ret i16 %1
}

define i16 @xori(i16 %a) nounwind {
; CAHP-LABEL: xori:
; CAHP:       # %bb.0:
; CAHP-NEXT:    xori a0, a0, 4
; CAHP-NEXT:    jr ra
  %1 = xor i16 %a, 4
  ret i16 %1
}

define i16 @ori(i16 %a) nounwind {
; CAHP-LABEL: ori:
; CAHP:       # %bb.0:
; CAHP-NEXT:    ori a0, a0, 5
; CAHP-NEXT:    jr ra
  %1 = or i16 %a, 5
  ret i16 %1
}

define i16 @andi(i16 %a, i16 %b) nounwind {
; CAHP-LABEL: andi:
; CAHP:       # %bb.0:
; CAHP-NEXT:    andi a0, a1, 6
; CAHP-NEXT:    jr ra
  %1 = and i16 %b, 6
  ret i16 %1
}

define i16 @andi2(i16 %a) nounwind {
; CAHP-LABEL: andi2:
; CAHP:       # %bb.0:
; CAHP-NEXT:    andi2 a0, 6
; CAHP-NEXT:    jr ra
  %1 = and i16 %a, 6
  ret i16 %1
}

define i16 @lsli(i16 %a, i16 %b) nounwind {
; CAHP-LABEL: lsli:
; CAHP:       # %bb.0:
; CAHP-NEXT:    lsli a0, a1, 7
; CAHP-NEXT:    jr ra
  %1 = shl i16 %b, 7
  ret i16 %1
}

define i16 @lsli2(i16 %a) nounwind {
; CAHP-LABEL: lsli2:
; CAHP:       # %bb.0:
; CAHP-NEXT:    lsli2 a0, 7
; CAHP-NEXT:    jr ra
  %1 = shl i16 %a, 7
  ret i16 %1
}

define i16 @lsri(i16 %a, i16 %b) nounwind {
; CAHP-LABEL: lsri:
; CAHP:       # %bb.0:
; CAHP-NEXT:    lsri a0, a1, 8
; CAHP-NEXT:    jr ra
  %1 = lshr i16 %b, 8
  ret i16 %1
}

define i16 @lsri2(i16 %a) nounwind {
; CAHP-LABEL: lsri2:
; CAHP:       # %bb.0:
; CAHP-NEXT:    lsri2 a0, 8
; CAHP-NEXT:    jr ra
  %1 = lshr i16 %a, 8
  ret i16 %1
}

define i16 @asri(i16 %a, i16 %b) nounwind {
; CAHP-LABEL: asri:
; CAHP:       # %bb.0:
; CAHP-NEXT:    asri a0, a1, 9
; CAHP-NEXT:    jr ra
  %1 = ashr i16 %b, 9
  ret i16 %1
}

define i16 @asri2(i16 %a) nounwind {
; CAHP-LABEL: asri2:
; CAHP:       # %bb.0:
; CAHP-NEXT:    asri2 a0, 9
; CAHP-NEXT:    jr ra
  %1 = ashr i16 %a, 9
  ret i16 %1
}

; Register-register instructions

define i16 @add(i16 %a, i16 %b, i16 %c) nounwind {
; CAHP-LABEL: add:
; CAHP:       # %bb.0:
; CAHP-NEXT:    add a0, a1, a2
; CAHP-NEXT:    jr ra
  %1 = add i16 %b, %c
  ret i16 %1
}

define i16 @add2(i16 %a, i16 %b) nounwind {
; CAHP-LABEL: add2:
; CAHP:       # %bb.0:
; CAHP-NEXT:    add2 a0, a1
; CAHP-NEXT:    jr ra
  %1 = add i16 %a, %b
  ret i16 %1
}

define i16 @sub(i16 %a, i16 %b, i16 %c) nounwind {
; CAHP-LABEL: sub:
; CAHP:       # %bb.0:
; CAHP-NEXT:    sub a0, a1, a2
; CAHP-NEXT:    jr ra
  %1 = sub i16 %b, %c
  ret i16 %1
}

define i16 @sub2(i16 %a, i16 %b) nounwind {
; CAHP-LABEL: sub2:
; CAHP:       # %bb.0:
; CAHP-NEXT:    sub2 a0, a1
; CAHP-NEXT:    jr ra
  %1 = sub i16 %a, %b
  ret i16 %1
}

define i16 @lsl(i16 %a, i16 %b, i16 %c) nounwind {
; CAHP-LABEL: lsl:
; CAHP:       # %bb.0:
; CAHP-NEXT:    lsl a0, a1, a2
; CAHP-NEXT:    jr ra
  %1 = shl i16 %b, %c
  ret i16 %1
}

define i16 @lsl2(i16 %a, i16 %b) nounwind {
; CAHP-LABEL: lsl2:
; CAHP:       # %bb.0:
; CAHP-NEXT:    lsl2 a0, a1
; CAHP-NEXT:    jr ra
  %1 = shl i16 %a, %b
  ret i16 %1
}

define i16 @xor(i16 %a, i16 %b, i16 %c) nounwind {
; CAHP-LABEL: xor:
; CAHP:       # %bb.0:
; CAHP-NEXT:    xor a0, a1, a2
; CAHP-NEXT:    jr ra
  %1 = xor i16 %b, %c
  ret i16 %1
}

define i16 @xor2(i16 %a, i16 %b) nounwind {
; CAHP-LABEL: xor2:
; CAHP:       # %bb.0:
; CAHP-NEXT:    xor2 a0, a1
; CAHP-NEXT:    jr ra
  %1 = xor i16 %a, %b
  ret i16 %1
}

define i16 @lsr(i16 %a, i16 %b, i16 %c) nounwind {
; CAHP-LABEL: lsr:
; CAHP:       # %bb.0:
; CAHP-NEXT:    lsr a0, a1, a2
; CAHP-NEXT:    jr ra
  %1 = lshr i16 %b, %c
  ret i16 %1
}

define i16 @lsr2(i16 %a, i16 %b) nounwind {
; CAHP-LABEL: lsr2:
; CAHP:       # %bb.0:
; CAHP-NEXT:    lsr2 a0, a1
; CAHP-NEXT:    jr ra
  %1 = lshr i16 %a, %b
  ret i16 %1
}

define i16 @asr(i16 %a, i16 %b, i16 %c) nounwind {
; CAHP-LABEL: asr:
; CAHP:       # %bb.0:
; CAHP-NEXT:    asr a0, a1, a2
; CAHP-NEXT:    jr ra
  %1 = ashr i16 %b, %c
  ret i16 %1
}

define i16 @asr2(i16 %a, i16 %b) nounwind {
; CAHP-LABEL: asr2:
; CAHP:       # %bb.0:
; CAHP-NEXT:    asr2 a0, a1
; CAHP-NEXT:    jr ra
  %1 = ashr i16 %a, %b
  ret i16 %1
}

define i16 @or(i16 %a, i16 %b, i16 %c) nounwind {
; CAHP-LABEL: or:
; CAHP:       # %bb.0:
; CAHP-NEXT:    or a0, a1, a2
; CAHP-NEXT:    jr ra
  %1 = or i16 %b, %c
  ret i16 %1
}

define i16 @or2(i16 %a, i16 %b) nounwind {
; CAHP-LABEL: or2:
; CAHP:       # %bb.0:
; CAHP-NEXT:    or2 a0, a1
; CAHP-NEXT:    jr ra
  %1 = or i16 %a, %b
  ret i16 %1
}

define i16 @and(i16 %a, i16 %b, i16 %c) nounwind {
; CAHP-LABEL: and:
; CAHP:       # %bb.0:
; CAHP-NEXT:    and a0, a1, a2
; CAHP-NEXT:    jr ra
  %1 = and i16 %b, %c
  ret i16 %1
}

define i16 @and2(i16 %a, i16 %b) nounwind {
; CAHP-LABEL: and2:
; CAHP:       # %bb.0:
; CAHP-NEXT:    and2 a0, a1
; CAHP-NEXT:    jr ra
  %1 = and i16 %a, %b
  ret i16 %1
}
