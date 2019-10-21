// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

#include "CAHPTargetMachine.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/CodeGen/TargetLoweringObjectFileImpl.h"
#include "llvm/CodeGen/TargetPassConfig.h"
#include "llvm/IR/LegacyPassManager.h"
#include "llvm/Support/FormattedStream.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Target/TargetOptions.h"
using namespace llvm;

extern "C" void LLVMInitializeCAHPTarget() {
  RegisterTargetMachine<CAHPTargetMachine> X(getTheCAHPTarget());
}

static std::string computeDataLayout(const Triple &TT) {
  return "e"        // Little endian
         "-m:e"     // ELF name manging
         "-p:16:16" // 16-bit pointers, 16 bit aligned
         "-i16:16"  // 16 bit integers, 16 bit aligned
         "-n16"     // 16 bit native integer width
         "-S16";    // 16 bit natural stack alignment
}

static Reloc::Model getEffectiveRelocModel(const Triple &TT,
                                           Optional<Reloc::Model> RM) {
  if (!RM.hasValue())
    return Reloc::Static;
  return *RM;
}

CAHPTargetMachine::CAHPTargetMachine(const Target &T, const Triple &TT,
                                     StringRef CPU, StringRef FS,
                                     const TargetOptions &Options,
                                     Optional<Reloc::Model> RM,
                                     Optional<CodeModel::Model> CM,
                                     CodeGenOpt::Level OL, bool JIT)
    : LLVMTargetMachine(T, computeDataLayout(TT), TT, CPU, FS, Options,
                        getEffectiveRelocModel(TT, RM),
                        getEffectiveCodeModel(CM, CodeModel::Small), OL),
      TLOF(make_unique<TargetLoweringObjectFileELF>()),
      Subtarget(TT, CPU, FS, *this) {
  initAsmInfo();
}

namespace {
class CAHPPassConfig : public TargetPassConfig {
public:
  CAHPPassConfig(CAHPTargetMachine &TM, PassManagerBase &PM)
      : TargetPassConfig(TM, PM) {}

  CAHPTargetMachine &getCAHPTargetMachine() const {
    return getTM<CAHPTargetMachine>();
  }

  bool addInstSelector() override;
};
} // namespace

TargetPassConfig *CAHPTargetMachine::createPassConfig(PassManagerBase &PM) {
  return new CAHPPassConfig(*this, PM);
}

bool CAHPPassConfig::addInstSelector() {
  addPass(createCAHPISelDag(getCAHPTargetMachine()));

  return false;
}
