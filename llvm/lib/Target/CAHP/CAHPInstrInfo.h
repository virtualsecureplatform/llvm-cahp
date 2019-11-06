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

  void copyPhysReg(MachineBasicBlock &MBB, MachineBasicBlock::iterator MBBI,
                   const DebugLoc &DL, unsigned DstReg, unsigned SrcReg,
                   bool KillSrc) const override;
  void storeRegToStackSlot(MachineBasicBlock &MBB,
                           MachineBasicBlock::iterator I, unsigned SrcReg,
                           bool IsKill, int FI, const TargetRegisterClass *RC,
                           const TargetRegisterInfo *TRI) const override;
  void loadRegFromStackSlot(MachineBasicBlock &MBB,
                            MachineBasicBlock::iterator I, unsigned DstReg,
                            int FI, const TargetRegisterClass *RC,
                            const TargetRegisterInfo *TRI) const override;

  // Materializes the given int16 Val into DstReg.
  void movImm16(MachineBasicBlock &MBB, MachineBasicBlock::iterator MBBI,
                const DebugLoc &DL, unsigned DstReg, uint64_t Val,
                MachineInstr::MIFlag Flag = MachineInstr::NoFlags) const;

  bool analyzeBranch(MachineBasicBlock &MBB, MachineBasicBlock *&TBB,
                     MachineBasicBlock *&FBB,
                     SmallVectorImpl<MachineOperand> &Cond,
                     bool AllowModify) const override;

  unsigned insertBranch(MachineBasicBlock &MBB, MachineBasicBlock *TBB,
                        MachineBasicBlock *FBB, ArrayRef<MachineOperand> Cond,
                        const DebugLoc &dl,
                        int *BytesAdded = nullptr) const override;

  unsigned removeBranch(MachineBasicBlock &MBB,
                        int *BytesRemoved = nullptr) const override;

  bool
  reverseBranchCondition(SmallVectorImpl<MachineOperand> &Cond) const override;
};
} // namespace llvm

#endif
