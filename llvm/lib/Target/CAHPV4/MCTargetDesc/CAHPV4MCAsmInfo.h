// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

#ifndef LLVM_LIB_TARGET_CAHPV4_MCTARGETDESC_CAHPV4MCASMINFO_H
#define LLVM_LIB_TARGET_CAHPV4_MCTARGETDESC_CAHPV4MCASMINFO_H

#include "llvm/MC/MCAsmInfoELF.h"

namespace llvm {
class Triple;

class CAHPV4MCAsmInfo : public MCAsmInfoELF {
  // This function MUST BE placed here to reduce the size of object files.
  // See also:
  // https://stackoverflow.com/questions/16801222/out-of-line-virtual-method
  void anchor() override;

public:
  explicit CAHPV4MCAsmInfo(const Triple &TargetTriple);
};

} // namespace llvm

#endif
