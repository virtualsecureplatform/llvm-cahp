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

void CAHPInstrInfo::movImm16(MachineBasicBlock &MBB,
                             MachineBasicBlock::iterator MBBI,
                             const DebugLoc &DL, unsigned DstReg, uint64_t Val,
                             MachineInstr::MIFlag Flag) const {
  assert(isInt<16>(Val) && "Can only materialize 16-bit constants");

  // TODO: If the value can be materialized using only one instruction, only
  // insert a single instruction.

  uint64_t Hi6 = ((Val + 0x200) >> 10) & 0x3f;
  uint64_t Lo10 = SignExtend64<10>(Val);
  BuildMI(MBB, MBBI, DL, get(CAHP::LUI), DstReg).addImm(Hi6).setMIFlag(Flag);
  BuildMI(MBB, MBBI, DL, get(CAHP::ADDI), DstReg)
      .addReg(DstReg)
      .addImm(Lo10)
      .setMIFlag(Flag);
}

// The contents of values added to Cond are not examined outside of
// CAHPInstrInfo, giving us flexibility in what to push to it. For CAHP, we
// push BranchOpcode, Reg1, Reg2.
static void parseCondBranch(MachineInstr &LastInst, MachineBasicBlock *&Target,
                            SmallVectorImpl<MachineOperand> &Cond) {
  // Block ends with fall-through condbranch.
  assert(LastInst.getDesc().isConditionalBranch() &&
         "Unknown conditional branch");
  Target = LastInst.getOperand(2).getMBB();
  Cond.push_back(MachineOperand::CreateImm(LastInst.getOpcode()));
  Cond.push_back(LastInst.getOperand(0));
  Cond.push_back(LastInst.getOperand(1));
}

bool CAHPInstrInfo::analyzeBranch(MachineBasicBlock &MBB,
                                  MachineBasicBlock *&TBB,
                                  MachineBasicBlock *&FBB,
                                  SmallVectorImpl<MachineOperand> &Cond,
                                  bool AllowModify) const {
  TBB = FBB = nullptr;
  Cond.clear();

  // If the block has no terminators, it just falls into the block after it.
  MachineBasicBlock::iterator I = MBB.getLastNonDebugInstr();
  if (I == MBB.end() || !isUnpredicatedTerminator(*I))
    return false;

  // Count the number of terminators and find the first unconditional or
  // indirect branch.
  MachineBasicBlock::iterator FirstUncondOrIndirectBr = MBB.end();
  int NumTerminators = 0;
  for (auto J = I.getReverse(); J != MBB.rend() && isUnpredicatedTerminator(*J);
       J++) {
    NumTerminators++;
    if (J->getDesc().isUnconditionalBranch() ||
        J->getDesc().isIndirectBranch()) {
      FirstUncondOrIndirectBr = J.getReverse();
    }
  }

  // If AllowModify is true, we can erase any terminators after
  // FirstUncondOrIndirectBR.
  if (AllowModify && FirstUncondOrIndirectBr != MBB.end()) {
    while (std::next(FirstUncondOrIndirectBr) != MBB.end()) {
      std::next(FirstUncondOrIndirectBr)->eraseFromParent();
      NumTerminators--;
    }
    I = FirstUncondOrIndirectBr;
  }

  // We can't handle blocks that end in an indirect branch.
  if (I->getDesc().isIndirectBranch())
    return true;

  // We can't handle blocks with more than 2 terminators.
  if (NumTerminators > 2)
    return true;

  // Handle a single unconditional branch.
  if (NumTerminators == 1 && I->getDesc().isUnconditionalBranch()) {
    TBB = I->getOperand(0).getMBB();
    return false;
  }

  // Handle a single conditional branch.
  if (NumTerminators == 1 && I->getDesc().isConditionalBranch()) {
    parseCondBranch(*I, TBB, Cond);
    return false;
  }

  // Handle a conditional branch followed by an unconditional branch.
  if (NumTerminators == 2 && std::prev(I)->getDesc().isConditionalBranch() &&
      I->getDesc().isUnconditionalBranch()) {
    parseCondBranch(*std::prev(I), TBB, Cond);
    FBB = I->getOperand(0).getMBB();
    return false;
  }

  // Otherwise, we can't handle this.
  return true;
}

unsigned CAHPInstrInfo::removeBranch(MachineBasicBlock &MBB,
                                     int *BytesRemoved) const {
  if (BytesRemoved)
    *BytesRemoved = 0;

  MachineBasicBlock::iterator I = MBB.getLastNonDebugInstr();
  if (I == MBB.end())
    return 0;

  if (!I->getDesc().isUnconditionalBranch() &&
      !I->getDesc().isConditionalBranch())
    return 0;

  // Remove the branch.
  I->eraseFromParent();
  if (BytesRemoved)
    *BytesRemoved += getInstSizeInBytes(*I);

  I = MBB.end();

  if (I == MBB.begin())
    return 1;
  --I;
  if (!I->getDesc().isConditionalBranch())
    return 1;

  // Remove the branch.
  I->eraseFromParent();
  if (BytesRemoved)
    *BytesRemoved += getInstSizeInBytes(*I);
  return 2;
}

// Inserts a branch into the end of the specific MachineBasicBlock, returning
// the number of instructions inserted.
unsigned CAHPInstrInfo::insertBranch(
    MachineBasicBlock &MBB, MachineBasicBlock *TBB, MachineBasicBlock *FBB,
    ArrayRef<MachineOperand> Cond, const DebugLoc &DL, int *BytesAdded) const {
  if (BytesAdded)
    *BytesAdded = 0;

  // Shouldn't be a fall through.
  assert(TBB && "InsertBranch must not be told to insert a fallthrough");
  assert((Cond.size() == 3 || Cond.size() == 0) &&
         "CAHP branch conditions have two components!");

  // Unconditional branch.
  if (Cond.empty()) {
    MachineInstr &MI = *BuildMI(&MBB, DL, get(CAHP::JS)).addMBB(TBB);
    if (BytesAdded)
      *BytesAdded = getInstSizeInBytes(MI);
    return 1;
  }

  // Either a one or two-way conditional branch.
  unsigned Opc = Cond[0].getImm();
  MachineInstr &CondMI =
      *BuildMI(&MBB, DL, get(Opc)).add(Cond[1]).add(Cond[2]).addMBB(TBB);
  if (BytesAdded)
    *BytesAdded += getInstSizeInBytes(CondMI);

  // One-way conditional branch.
  if (!FBB)
    return 1;

  // Two-way conditional branch.
  MachineInstr &MI = *BuildMI(&MBB, DL, get(CAHP::JS)).addMBB(FBB);
  if (BytesAdded)
    *BytesAdded += getInstSizeInBytes(MI);
  return 2;
}

bool CAHPInstrInfo::reverseBranchCondition(
    SmallVectorImpl<MachineOperand> &Cond) const {
  assert((Cond.size() == 3) && "Invalid branch condition!");

  bool ShouldSwap = false;
  switch (Cond[0].getImm()) {
  case CAHP::BEQ:
    Cond[0].setImm(CAHP::BNE);
    break;
  case CAHP::BNE:
    Cond[0].setImm(CAHP::BEQ);
    break;
  case CAHP::BLT:
    Cond[0].setImm(CAHP::BLE);
    ShouldSwap = true;
    break;
  case CAHP::BLE:
    Cond[0].setImm(CAHP::BLT);
    ShouldSwap = true;
    break;
  case CAHP::BLTU:
    Cond[0].setImm(CAHP::BLEU);
    ShouldSwap = true;
    break;
  case CAHP::BLEU:
    Cond[0].setImm(CAHP::BLTU);
    ShouldSwap = true;
    break;
  }

  if (ShouldSwap) {
    using std::swap;
    swap(Cond[1], Cond[2]);
  }

  return false;
}

MachineBasicBlock *
CAHPInstrInfo::getBranchDestBlock(const MachineInstr &MI) const {
  assert(MI.getDesc().isBranch() && "Unexpected opcode!");
  // The branch target is always the last operand.
  int NumOp = MI.getNumExplicitOperands();
  return MI.getOperand(NumOp - 1).getMBB();
}

bool CAHPInstrInfo::isBranchOffsetInRange(unsigned BranchOp,
                                          int64_t BrOffset) const {
  switch (BranchOp) {
  default:
    llvm_unreachable("Unexpected opcode!");

  case CAHP::BEQ:
  case CAHP::BNE:
  case CAHP::BLT:
  case CAHP::BLE:
  case CAHP::BLTU:
  case CAHP::BLEU:
    return isInt<10>(BrOffset);

  case CAHP::JSAL:
  case CAHP::JS:
    return isInt<11>(BrOffset);
  }
}

unsigned CAHPInstrInfo::getInstSizeInBytes(const MachineInstr &MI) const {
  unsigned Opcode = MI.getOpcode();

  switch (Opcode) {
  default:
    return get(Opcode).getSize();

  case TargetOpcode::EH_LABEL:
  case TargetOpcode::IMPLICIT_DEF:
  case TargetOpcode::KILL:
  case TargetOpcode::DBG_VALUE:
    return 0;

  case TargetOpcode::INLINEASM: {
    const MachineFunction &MF = *MI.getParent()->getParent();
    const auto &TM = static_cast<const CAHPTargetMachine &>(MF.getTarget());
    return getInlineAsmLength(MI.getOperand(0).getSymbolName(),
                              *TM.getMCAsmInfo());
  }
  }
}
