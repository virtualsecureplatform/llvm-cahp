// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

#include "CAHPSubtarget.h"
#include "CAHP.h"
#include "CAHPFrameLowering.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;

#define DEBUG_TYPE "cahp-subtarget"

#define GET_SUBTARGETINFO_TARGET_DESC
#define GET_SUBTARGETINFO_CTOR
#include "CAHPGenSubtargetInfo.inc"

void CAHPSubtarget::anchor() {}

CAHPSubtarget &CAHPSubtarget::initializeSubtargetDependencies(StringRef CPU,
                                                              StringRef FS) {
  // Determine default and user-specified characteristics
  std::string CPUName = CPU;
  if (CPUName.empty())
    CPUName = "generic";
  ParseSubtargetFeatures(CPUName, FS);
  return *this;
}

CAHPSubtarget::CAHPSubtarget(const Triple &TT, const std::string &CPU,
                             const std::string &FS, const TargetMachine &TM)
    : CAHPGenSubtargetInfo(TT, CPU, FS),
      FrameLowering(initializeSubtargetDependencies(CPU, FS)), InstrInfo(),
      RegInfo(getHwMode()), TLInfo(TM, *this) {}
