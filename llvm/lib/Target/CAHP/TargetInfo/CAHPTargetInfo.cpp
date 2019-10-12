// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

#include "llvm/Support/TargetRegistry.h"
using namespace llvm;

namespace llvm {
Target &getTheCAHPTarget() {
  static Target TheCAHPTarget;
  return TheCAHPTarget;
}
} // namespace llvm

extern "C" void LLVMInitializeCAHPTargetInfo() {
  RegisterTarget<Triple::cahp> X(getTheCAHPTarget(), "cahp", "CAHP", "CAHP");
}

// FIXME: Temporary stub - this function must be defined for linking
// to succeed and will be called unconditionally by llc, so must be a no-op.
// Remove once this function is properly implemented.
extern "C" void LLVMInitializeCAHPTargetMC() {}
