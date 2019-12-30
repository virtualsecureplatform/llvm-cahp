// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

#include "CAHPFrameLowering.h"
#include "CAHPSubtarget.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/RegisterScavenging.h"

using namespace llvm;

// hasFP - Return true if the specified function should have a dedicated frame
// pointer register.  This is true if the function has variable sized allocas or
// if frame pointer elimination is disabled.
bool CAHPFrameLowering::hasFP(const MachineFunction &MF) const {
  const TargetRegisterInfo *RegInfo = MF.getSubtarget().getRegisterInfo();
  const MachineFrameInfo &MFI = MF.getFrameInfo();

  return MF.getTarget().Options.DisableFramePointerElim(MF) ||
         RegInfo->needsStackRealignment(MF) || MFI.hasVarSizedObjects() ||
         MFI.isFrameAddressTaken();
}

// Determines the size of the frame and maximum call frame size.
void CAHPFrameLowering::determineFrameLayout(MachineFunction &MF) const {
  MachineFrameInfo &MFI = MF.getFrameInfo();
  const CAHPRegisterInfo *RI = STI.getRegisterInfo();

  // Get the number of bytes to allocate from the FrameInfo.
  uint64_t FrameSize = MFI.getStackSize();

  // Get the alignment.
  uint64_t StackAlign = RI->needsStackRealignment(MF) ? MFI.getMaxAlignment()
                                                      : getStackAlignment();

  // Make sure the frame is aligned.
  FrameSize = alignTo(FrameSize, StackAlign);

  // Update frame info.
  MFI.setStackSize(FrameSize);
}

// Build a MI to compute "DestReg = SrcReg + Val"
void CAHPFrameLowering::adjustReg(MachineBasicBlock &MBB,
                                  MachineBasicBlock::iterator MBBI,
                                  const DebugLoc &DL, unsigned DestReg,
                                  unsigned SrcReg, int64_t Val,
                                  MachineInstr::MIFlag Flag) const {
  if (DestReg == SrcReg && Val == 0)
    return;

  MachineRegisterInfo &MRI = MBB.getParent()->getRegInfo();
  const CAHPInstrInfo *TII = STI.getInstrInfo();

  if (isInt<10>(Val)) {
    BuildMI(MBB, MBBI, DL, TII->get(CAHP::ADDI), DestReg)
        .addReg(SrcReg)
        .addImm(Val)
        .setMIFlag(Flag);
  } else if (isInt<16>(Val)) {
    unsigned Opc = CAHP::ADD;
    bool isSub = Val < 0;
    if (isSub) {
      Val = -Val;
      Opc = CAHP::SUB;
    }

    unsigned ScratchReg = MRI.createVirtualRegister(&CAHP::GPRRegClass);
    TII->movImm16(MBB, MBBI, DL, ScratchReg, Val, Flag);
    BuildMI(MBB, MBBI, DL, TII->get(Opc), DestReg)
        .addReg(SrcReg)
        .addReg(ScratchReg)
        .setMIFlag(Flag);
  } else {
    report_fatal_error("adjustReg cannot yet handle adjustments >16 bits");
  }
}

// Returns the register used to hold the frame pointer.
static unsigned getFPReg() { return CAHP::X2; }

// Returns the register used to hold the stack pointer.
static unsigned getSPReg() { return CAHP::X1; }

void CAHPFrameLowering::emitPrologue(MachineFunction &MF,
                                     MachineBasicBlock &MBB) const {
  assert(&MF.front() == &MBB && "Shrink-wrapping not yet supported");

  MachineFrameInfo &MFI = MF.getFrameInfo();
  MachineBasicBlock::iterator MBBI = MBB.begin();

  unsigned FPReg = getFPReg();
  unsigned SPReg = getSPReg();

  // Debug location must be unknown since the first debug location is used
  // to determine the end of the prologue.
  DebugLoc DL;

  // Determine the correct frame layout
  determineFrameLayout(MF);

  // FIXME (note copied from Lanai/RISCV): This appears to be overallocating.
  // Needs investigation. Get the number of bytes to allocate from the
  // FrameInfo.
  uint64_t StackSize = MFI.getStackSize();

  // Early exit if there is no need to allocate on the stack
  if (StackSize == 0 && !MFI.adjustsStack())
    return;

  // Allocate space on the stack if necessary.
  adjustReg(MBB, MBBI, DL, SPReg, SPReg, -StackSize, MachineInstr::FrameSetup);

  // The frame pointer is callee-saved, and code has been generated for us to
  // save it to the stack. We need to skip over the storing of callee-saved
  // registers as the frame pointer must be modified after it has been saved
  // to the stack, not before.
  // FIXME: assumes exactly one instruction is used to save each callee-saved
  // register.
  const std::vector<CalleeSavedInfo> &CSI = MFI.getCalleeSavedInfo();
  std::advance(MBBI, CSI.size());

  // Generate new FP.
  if (hasFP(MF))
    adjustReg(MBB, MBBI, DL, FPReg, SPReg, StackSize, MachineInstr::FrameSetup);
}

void CAHPFrameLowering::emitEpilogue(MachineFunction &MF,
                                     MachineBasicBlock &MBB) const {
  MachineBasicBlock::iterator MBBI = MBB.getLastNonDebugInstr();
  const CAHPRegisterInfo *RI = STI.getRegisterInfo();
  MachineFrameInfo &MFI = MF.getFrameInfo();
  DebugLoc DL = MBBI->getDebugLoc();
  unsigned FPReg = getFPReg();
  unsigned SPReg = getSPReg();

  // Skip to before the restores of callee-saved registers
  // FIXME: assumes exactly one instruction is used to restore each
  // callee-saved register.
  MachineBasicBlock::iterator LastFrameDestroy = MBBI;
  std::advance(LastFrameDestroy, -MFI.getCalleeSavedInfo().size());

  uint64_t StackSize = MFI.getStackSize();

  // Restore the stack pointer using the value of the frame pointer. Only
  // necessary if the stack pointer was modified, meaning the stack size is
  // unknown.
  if (RI->needsStackRealignment(MF) || MFI.hasVarSizedObjects()) {
    assert(hasFP(MF) && "frame pointer should not have been eliminated");
    adjustReg(MBB, LastFrameDestroy, DL, SPReg, FPReg, -StackSize,
              MachineInstr::FrameDestroy);
  }

  // Deallocate stack
  adjustReg(MBB, MBBI, DL, SPReg, SPReg, StackSize, MachineInstr::FrameDestroy);
}

int CAHPFrameLowering::getFrameIndexReference(const MachineFunction &MF, int FI,
                                              unsigned &FrameReg) const {
  const MachineFrameInfo &MFI = MF.getFrameInfo();
  const TargetRegisterInfo *RI = MF.getSubtarget().getRegisterInfo();

  // Callee-saved registers should be referenced relative to the stack
  // pointer (positive offset), otherwise use the frame pointer (negative
  // offset).
  const std::vector<CalleeSavedInfo> &CSI = MFI.getCalleeSavedInfo();
  int MinCSFI = 0;
  int MaxCSFI = -1;

  int Offset = MFI.getObjectOffset(FI) - getOffsetOfLocalArea() +
               MFI.getOffsetAdjustment();

  if (CSI.size()) {
    MinCSFI = CSI[0].getFrameIdx();
    MaxCSFI = CSI[CSI.size() - 1].getFrameIdx();
  }

  FrameReg = RI->getFrameRegister(MF);

  // If the frame index points to a callee-saved register or no frame pointer is
  // used in the MachineFunction, then make the Offset relative to the stack
  // pointer.
  if ((FI >= MinCSFI && FI <= MaxCSFI) || !hasFP(MF)) {
    FrameReg = CAHP::X1; // X1 is SP.
    Offset += MF.getFrameInfo().getStackSize();
  }
  return Offset;
}

void CAHPFrameLowering::determineCalleeSaves(MachineFunction &MF,
                                             BitVector &SavedRegs,
                                             RegScavenger *RS) const {
  TargetFrameLowering::determineCalleeSaves(MF, SavedRegs, RS);
  // Unconditionally spill RA and FP only if the function uses a frame
  // pointer.
  if (hasFP(MF)) {
    SavedRegs.set(CAHP::X0);
    SavedRegs.set(CAHP::X2);
  }
}

void CAHPFrameLowering::processFunctionBeforeFrameFinalized(
    MachineFunction &MF, RegScavenger *RS) const {
  const TargetRegisterInfo *RegInfo = MF.getSubtarget().getRegisterInfo();
  MachineFrameInfo &MFI = MF.getFrameInfo();
  const TargetRegisterClass *RC = &CAHP::GPRRegClass;
  if (!isInt<9>(MFI.estimateStackSize(MF))) {
    int RegScavFI = MFI.CreateStackObject(
        RegInfo->getSpillSize(*RC), RegInfo->getSpillAlignment(*RC), false);
    RS->addScavengingFrameIndex(RegScavFI);
  }
}
