// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

#ifndef LLVM_LIB_TARGET_CAHP_CAHP_H
#define LLVM_LIB_TARGET_CAHP_CAHP_H

#include "MCTargetDesc/CAHPBaseInfo.h"

namespace llvm {
class AsmPrinter;
class CAHPTargetMachine;
class FunctionPass;
class MCInst;
class MCOperand;
class MachineInstr;
class MachineOperand;

void LowerCAHPMachineInstrToMCInst(const MachineInstr *MI, MCInst &OutMI,
                                   const AsmPrinter &AP);
bool LowerCAHPMachineOperandToMCOperand(const MachineOperand &MO,
                                        MCOperand &MCOp, const AsmPrinter &AP);

FunctionPass *createCAHPISelDag(CAHPTargetMachine &TM);
} // namespace llvm

#endif
