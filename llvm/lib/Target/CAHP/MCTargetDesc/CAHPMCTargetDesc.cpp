// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

#include "CAHPMCTargetDesc.h"
#include "CAHPMCAsmInfo.h"
#include "InstPrinter/CAHPInstPrinter.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/TargetRegistry.h"

#define GET_INSTRINFO_MC_DESC
#include "CAHPGenInstrInfo.inc"

#define GET_REGINFO_MC_DESC
#include "CAHPGenRegisterInfo.inc"

#define GET_SUBTARGETINFO_MC_DESC
#include "CAHPGenSubtargetInfo.inc"

using namespace llvm;

static MCInstrInfo *createCAHPMCInstrInfo() {
  MCInstrInfo *X = new MCInstrInfo();
  InitCAHPMCInstrInfo(X);
  return X;
}

static MCRegisterInfo *createCAHPMCRegisterInfo(const Triple &TT) {
  MCRegisterInfo *X = new MCRegisterInfo();

  // X0 is the return address register.
  InitCAHPMCRegisterInfo(X, CAHP::X0);

  return X;
}

static MCAsmInfo *createCAHPMCAsmInfo(const MCRegisterInfo &MRI,
                                      const Triple &TT) {
  return new CAHPMCAsmInfo(TT);
}

static MCSubtargetInfo *createCAHPMCSubtargetInfo(const Triple &TT,
                                                  StringRef CPU, StringRef FS) {
  std::string CPUName = CPU;
  if (CPUName.empty())
    CPUName = "generic";
  return createCAHPMCSubtargetInfoImpl(TT, CPUName, FS);
}

static MCInstPrinter *createCAHPMCInstPrinter(const Triple &T,
                                              unsigned SyntaxVariant,
                                              const MCAsmInfo &MAI,
                                              const MCInstrInfo &MII,
                                              const MCRegisterInfo &MRI) {
  return new CAHPInstPrinter(MAI, MII, MRI);
}

extern "C" void LLVMInitializeCAHPTargetMC() {
  Target &T = getTheCAHPTarget();
  TargetRegistry::RegisterMCAsmInfo(T, createCAHPMCAsmInfo);
  TargetRegistry::RegisterMCInstrInfo(T, createCAHPMCInstrInfo);
  TargetRegistry::RegisterMCRegInfo(T, createCAHPMCRegisterInfo);
  TargetRegistry::RegisterMCAsmBackend(T, createCAHPAsmBackend);
  TargetRegistry::RegisterMCSubtargetInfo(T, createCAHPMCSubtargetInfo);
  TargetRegistry::RegisterMCCodeEmitter(T, createCAHPMCCodeEmitter);
  TargetRegistry::RegisterMCInstPrinter(T, createCAHPMCInstPrinter);
}
