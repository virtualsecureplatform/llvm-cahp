// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

#ifndef LLVM_LIB_TARGET_CAHP_CAHPINSTRINFO_H
#define LLVM_LIB_TARGET_CAHP_CAHPINSTRINFO_H

#include "CAHPRegisterInfo.h"
#include "llvm/CodeGen/TargetInstrInfo.h"

#define GET_INSTRINFO_HEADER
#include "CAHPGenInstrInfo.inc"

namespace llvm {

class CAHPInstrInfo : public CAHPGenInstrInfo {

public:
  CAHPInstrInfo();
};
} // namespace llvm

#endif
