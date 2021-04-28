// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

#include "llvm/Support/TargetRegistry.h"
using namespace llvm;

namespace llvm {
Target &getTheCAHPV4Target() {
  static Target TheCAHPV4Target;
  return TheCAHPV4Target;
}
} // namespace llvm

extern "C" void LLVMInitializeCAHPV4TargetInfo() {
  RegisterTarget<Triple::cahpv4> X(getTheCAHPV4Target(), "cahpv4", "CAHPV4",
                                   "CAHPV4");
}

// FIXME: Temporary stub - this function must be defined for linking
// to succeed and will be called unconditionally by llc, so must be a no-op.
// Remove once this function is properly implemented.
extern "C" void LLVMInitializeCAHPV4TargetMC() {}
