// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

#ifndef LLVM_LIB_TARGET_CAHP_CAHP_H
#define LLVM_LIB_TARGET_CAHP_CAHP_H

#include "MCTargetDesc/CAHPMCTargetDesc.h"
#include "llvm/Target/TargetMachine.h"

namespace llvm {
class CAHPTargetMachine;
class MCInst;
class MachineInstr;

void LowerCAHPMachineInstrToMCInst(const MachineInstr *MI, MCInst &OutMI);

FunctionPass *createCAHPISelDag(CAHPTargetMachine &TM);
} // namespace llvm

#endif
