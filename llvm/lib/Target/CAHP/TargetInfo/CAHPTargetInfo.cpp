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
