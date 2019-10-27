// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

#include "CAHPInstrInfo.h"
#include "CAHP.h"
#include "CAHPSubtarget.h"
#include "CAHPTargetMachine.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/TargetRegistry.h"

#define GET_INSTRINFO_CTOR_DTOR
#include "CAHPGenInstrInfo.inc"

using namespace llvm;

CAHPInstrInfo::CAHPInstrInfo()
    : CAHPGenInstrInfo(CAHP::ADJCALLSTACKDOWN, CAHP::ADJCALLSTACKUP) {}

void CAHPInstrInfo::copyPhysReg(MachineBasicBlock &MBB,
                                MachineBasicBlock::iterator MBBI,
                                const DebugLoc &DL, unsigned DstReg,
                                unsigned SrcReg, bool KillSrc) const {
  assert(CAHP::GPRRegClass.contains(DstReg, SrcReg) &&
         "Impossible reg-to-reg copy");

  BuildMI(MBB, MBBI, DL, get(CAHP::MOV), DstReg).addReg(SrcReg);
}

void CAHPInstrInfo::storeRegToStackSlot(MachineBasicBlock &MBB,
                                        MachineBasicBlock::iterator I,
                                        unsigned SrcReg, bool IsKill, int FI,
                                        const TargetRegisterClass *RC,
                                        const TargetRegisterInfo *TRI) const {
  DebugLoc DL;
  if (I != MBB.end())
    DL = I->getDebugLoc();

  if (!CAHP::GPRRegClass.hasSubClassEq(RC))
    llvm_unreachable("Can't store this register to stack slot");

  BuildMI(MBB, I, DL, get(CAHP::SW)).addReg(SrcReg).addFrameIndex(FI).addImm(0);
}

void CAHPInstrInfo::loadRegFromStackSlot(MachineBasicBlock &MBB,
                                         MachineBasicBlock::iterator I,
                                         unsigned DstReg, int FI,
                                         const TargetRegisterClass *RC,
                                         const TargetRegisterInfo *TRI) const {
  DebugLoc DL;
  if (I != MBB.end())
    DL = I->getDebugLoc();

  if (!CAHP::GPRRegClass.hasSubClassEq(RC))
    llvm_unreachable("Can't load this register from stack slot");

  BuildMI(MBB, I, DL, get(CAHP::LW), DstReg).addFrameIndex(FI).addImm(0);
}
