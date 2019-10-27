// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

#include "CAHPRegisterInfo.h"
#include "CAHP.h"
#include "CAHPSubtarget.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/RegisterScavenging.h"
#include "llvm/CodeGen/TargetFrameLowering.h"
#include "llvm/CodeGen/TargetInstrInfo.h"
#include "llvm/Support/ErrorHandling.h"

#define GET_REGINFO_TARGET_DESC
#include "CAHPGenRegisterInfo.inc"

using namespace llvm;

CAHPRegisterInfo::CAHPRegisterInfo(unsigned HwMode)
    : CAHPGenRegisterInfo(/* RA */ CAHP::X0, /*DwarfFlavour*/ 0,
                          /*EHFlavor*/ 0,
                          /*PC*/ 0, HwMode) {}

const MCPhysReg *
CAHPRegisterInfo::getCalleeSavedRegs(const MachineFunction *MF) const {
  return CSR_SaveList;
}

BitVector CAHPRegisterInfo::getReservedRegs(const MachineFunction &MF) const {
  BitVector Reserved(getNumRegs());

  // Use markSuperRegs to ensure any register aliases are also reserved
  markSuperRegs(Reserved, CAHP::X0); // ra
  markSuperRegs(Reserved, CAHP::X1); // sp
  markSuperRegs(Reserved, CAHP::X2); // fp
  assert(checkAllSuperRegsMarked(Reserved));
  return Reserved;
}

void CAHPRegisterInfo::eliminateFrameIndex(MachineBasicBlock::iterator II,
                                           int SPAdj, unsigned FIOperandNum,
                                           RegScavenger *RS) const {
  assert(SPAdj == 0 && "Unexpected non-zero SPAdj value");

  MachineInstr &MI = *II;
  MachineFunction &MF = *MI.getParent()->getParent();
  DebugLoc DL = MI.getDebugLoc();

  int FrameIndex = MI.getOperand(FIOperandNum).getIndex();
  unsigned FrameReg;
  int Offset =
      getFrameLowering(MF)->getFrameIndexReference(MF, FrameIndex, FrameReg) +
      MI.getOperand(FIOperandNum + 1).getImm();
  assert(MF.getSubtarget().getFrameLowering()->hasFP(MF) &&
         "eliminateFrameIndex currently requires hasFP");

  // Offsets must be directly encoded in a 10-bit immediate field
  if (!isInt<10>(Offset)) {
    report_fatal_error(
        "Frame offsets outside of the signed 10-bit range not supported");
  }

  MI.getOperand(FIOperandNum).ChangeToRegister(FrameReg, false);
  MI.getOperand(FIOperandNum + 1).ChangeToImmediate(Offset);
}

Register CAHPRegisterInfo::getFrameRegister(const MachineFunction &MF) const {
  return CAHP::X2;
}

const uint32_t *
CAHPRegisterInfo::getCallPreservedMask(const MachineFunction & /*MF*/,
                                       CallingConv::ID /*CC*/) const {
  return CSR_RegMask;
}
