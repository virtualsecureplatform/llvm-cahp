// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

#ifndef LLVM_LIB_TARGET_CAHP_MCTARGETDESC_CAHPFIXUPKINDS_H
#define LLVM_LIB_TARGET_CAHP_MCTARGETDESC_CAHPFIXUPKINDS_H

#include "llvm/MC/MCFixup.h"

#undef CAHP

namespace llvm {
namespace CAHP {
enum Fixups {
  // Fixups for hi/lo
  fixup_cahp_hi6 = FirstTargetFixupKind,
  fixup_cahp_lo10,

  // 10-bit pc relative. e.g. bcc
  fixup_cahp_pcrel_10,

  // 11-bit pc relative. e.g. js, jsal
  fixup_cahp_pcrel_11,

  // fixup_rv16k_invalid - used as a sentinel and a marker, must be last fixup
  fixup_cahp_invalid,
  NumTargetFixupKinds = fixup_cahp_invalid - FirstTargetFixupKind
};
} // end namespace CAHP
} // end namespace llvm

#endif
