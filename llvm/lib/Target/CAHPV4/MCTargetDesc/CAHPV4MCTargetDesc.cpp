// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

#include "CAHPV4MCTargetDesc.h"
#include "CAHPV4MCAsmInfo.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/TargetRegistry.h"

#define GET_INSTRINFO_MC_DESC
#include "CAHPV4GenInstrInfo.inc"

#define GET_REGINFO_MC_DESC
#include "CAHPV4GenRegisterInfo.inc"

#define GET_SUBTARGETINFO_MC_DESC
#include "CAHPV4GenSubtargetInfo.inc"

using namespace llvm;

static MCInstrInfo *createCAHPV4MCInstrInfo() {
  MCInstrInfo *X = new MCInstrInfo();
  InitCAHPV4MCInstrInfo(X);
  return X;
}

static MCRegisterInfo *createCAHPV4MCRegisterInfo(const Triple &TT) {
  MCRegisterInfo *X = new MCRegisterInfo();

  // X1 is the return address register.
  InitCAHPV4MCRegisterInfo(X, CAHPV4::X1);

  return X;
}

static MCAsmInfo *createCAHPV4MCAsmInfo(const MCRegisterInfo &MRI,
                                        const Triple &TT,
                                        const MCTargetOptions &Options) {
  return new CAHPV4MCAsmInfo(TT);
}

static MCSubtargetInfo *
createCAHPV4MCSubtargetInfo(const Triple &TT, StringRef CPU, StringRef FS) {
  std::string CPUName = std::string(CPU);
  if (CPUName.empty())
    CPUName = "generic-cahpv4";
  return createCAHPV4MCSubtargetInfoImpl(TT, CPUName, CPUName, FS);
}

extern "C" void LLVMInitializeCAHPV4TargetMC() {
  Target &T = getTheCAHPV4Target();
  TargetRegistry::RegisterMCAsmInfo(T, createCAHPV4MCAsmInfo);
  TargetRegistry::RegisterMCInstrInfo(T, createCAHPV4MCInstrInfo);
  TargetRegistry::RegisterMCRegInfo(T, createCAHPV4MCRegisterInfo);
  TargetRegistry::RegisterMCAsmBackend(T, createCAHPV4AsmBackend);
  TargetRegistry::RegisterMCSubtargetInfo(T, createCAHPV4MCSubtargetInfo);
  TargetRegistry::RegisterMCCodeEmitter(T, createCAHPV4MCCodeEmitter);
}
