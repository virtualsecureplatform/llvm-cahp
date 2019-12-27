// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

#ifndef LLVM_CLANG_LIB_DRIVER_TOOLCHAINS_ARCH_CAHP_H
#define LLVM_CLANG_LIB_DRIVER_TOOLCHAINS_ARCH_CAHP_H

#include "llvm/Option/Option.h"

namespace clang {
namespace driver {
namespace tools {
namespace cahp {

std::string getCAHPTargetCPU(const llvm::opt::ArgList &Args);

} // namespace cahp
} // namespace tools
} // namespace driver
} // namespace clang

#endif // LLVM_CLANG_LIB_DRIVER_TOOLCHAINS_ARCH_CAHP_H
