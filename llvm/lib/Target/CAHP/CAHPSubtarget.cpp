// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

#include "CAHPSubtarget.h"
#include "CAHP.h"
#include "CAHPFrameLowering.h"
#include "llvm/MC/TargetRegistry.h"

using namespace llvm;

#define DEBUG_TYPE "cahp-subtarget"

#define GET_SUBTARGETINFO_TARGET_DESC
#define GET_SUBTARGETINFO_CTOR
#include "CAHPGenSubtargetInfo.inc"

void CAHPSubtarget::anchor() {}

CAHPSubtarget &CAHPSubtarget::initializeSubtargetDependencies(
    StringRef CPU, StringRef TuneCPU, StringRef FS) {
  // Determine default and user-specified characteristics
  std::string CPUName = CPU.str();
  std::string TuneCPUName = TuneCPU.str();
  if (CPUName.empty())
    CPUName = "generic";
  if (TuneCPUName.empty())
    TuneCPUName = CPUName;
  ParseSubtargetFeatures(CPUName, TuneCPUName, FS);
  return *this;
}

CAHPSubtarget::CAHPSubtarget(const Triple &TT, StringRef CPU, StringRef TuneCPU,
                             StringRef FS, const TargetMachine &TM)
    : CAHPGenSubtargetInfo(TT, CPU, TuneCPU, FS),
      FrameLowering(initializeSubtargetDependencies(CPU, TuneCPU, FS)),
      InstrInfo(), RegInfo(getHwMode()), TLInfo(TM, *this) {}
