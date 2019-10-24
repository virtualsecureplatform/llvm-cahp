// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

#include "CAHPISelLowering.h"
#include "CAHP.h"
#include "CAHPRegisterInfo.h"
#include "CAHPSubtarget.h"
#include "CAHPTargetMachine.h"
#include "MCTargetDesc/CAHPBaseInfo.h"
#include "llvm/CodeGen/CallingConvLower.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/SelectionDAGISel.h"
#include "llvm/CodeGen/TargetLoweringObjectFileImpl.h"
#include "llvm/CodeGen/ValueTypes.h"
#include "llvm/IR/DiagnosticInfo.h"
#include "llvm/IR/DiagnosticPrinter.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

#define DEBUG_TYPE "cahp-lower"

CAHPTargetLowering::CAHPTargetLowering(const TargetMachine &TM,
                                       const CAHPSubtarget &STI)
    : TargetLowering(TM) {

  // Set up the register classes.
  addRegisterClass(MVT::i16, &CAHP::GPRRegClass);

  // Compute derived properties from the register classes.
  computeRegisterProperties(STI.getRegisterInfo());

  setStackPointerRegisterToSaveRestore(CAHP::X1);

  for (auto N : {ISD::EXTLOAD, ISD::SEXTLOAD, ISD::ZEXTLOAD})
    setLoadExtAction(N, MVT::i16, MVT::i1, Promote);

  // TODO: add all necessary setOperationAction calls.
  setOperationAction(ISD::GlobalAddress, MVT::i16, Custom);
  setOperationAction(ISD::BR_CC, MVT::i16, Expand);

  setBooleanContents(ZeroOrOneBooleanContent);

  // Function alignments (log2).
  setMinFunctionAlignment(1);
  setPrefFunctionAlignment(1);
}

SDValue CAHPTargetLowering::LowerOperation(SDValue Op,
                                           SelectionDAG &DAG) const {
  switch (Op.getOpcode()) {
  default:
    report_fatal_error("unimplemented operand");

  case ISD::GlobalAddress:
    return lowerGlobalAddress(Op, DAG);
  }
}

SDValue CAHPTargetLowering::lowerGlobalAddress(SDValue Op,
                                               SelectionDAG &DAG) const {
  SDLoc DL(Op);
  EVT Ty = Op.getValueType();
  GlobalAddressSDNode *N = cast<GlobalAddressSDNode>(Op);
  const GlobalValue *GV = N->getGlobal();
  int64_t Offset = N->getOffset();

  if (!isPositionIndependent()) {
    SDValue GAHi =
        DAG.getTargetGlobalAddress(GV, DL, Ty, Offset, CAHPII::MO_HI);
    SDValue GALo =
        DAG.getTargetGlobalAddress(GV, DL, Ty, Offset, CAHPII::MO_LO);
    SDValue MNHi = SDValue(DAG.getMachineNode(CAHP::LUI, DL, Ty, GAHi), 0);
    SDValue MNLo =
        SDValue(DAG.getMachineNode(CAHP::ADDI, DL, Ty, MNHi, GALo), 0);
    return MNLo;
  } else {
    report_fatal_error("Unable to lowerGlobalAddress");
  }
}

// Calling Convention Implementation.
#include "CAHPGenCallingConv.inc"

// Transform physical registers into virtual registers.
SDValue CAHPTargetLowering::LowerFormalArguments(
    SDValue Chain, CallingConv::ID CallConv, bool IsVarArg,
    const SmallVectorImpl<ISD::InputArg> &Ins, const SDLoc &DL,
    SelectionDAG &DAG, SmallVectorImpl<SDValue> &InVals) const {

  switch (CallConv) {
  default:
    report_fatal_error("Unsupported calling convention");
  case CallingConv::C:
    break;
  }

  MachineFunction &MF = DAG.getMachineFunction();
  MachineRegisterInfo &RegInfo = MF.getRegInfo();

  if (IsVarArg)
    report_fatal_error("VarArg not supported");

  // Assign locations to all of the incoming arguments.
  SmallVector<CCValAssign, 16> ArgLocs;
  CCState CCInfo(CallConv, IsVarArg, MF, ArgLocs, *DAG.getContext());
  CCInfo.AnalyzeFormalArguments(Ins, CC_CAHP);

  for (auto &VA : ArgLocs) {
    if (!VA.isRegLoc())
      report_fatal_error("Defined with too many args");

    // Arguments passed in registers.
    EVT RegVT = VA.getLocVT();
    if (RegVT != MVT::i16) {
      LLVM_DEBUG(dbgs() << "LowerFormalArguments Unhandled argument type: "
                        << RegVT.getEVTString() << "\n");
      report_fatal_error("unhandled argument type");
    }
    const unsigned VReg = RegInfo.createVirtualRegister(&CAHP::GPRRegClass);
    RegInfo.addLiveIn(VA.getLocReg(), VReg);
    SDValue ArgIn = DAG.getCopyFromReg(Chain, DL, VReg, RegVT);

    InVals.push_back(ArgIn);
  }
  return Chain;
}

SDValue
CAHPTargetLowering::LowerReturn(SDValue Chain, CallingConv::ID CallConv,
                                bool IsVarArg,
                                const SmallVectorImpl<ISD::OutputArg> &Outs,
                                const SmallVectorImpl<SDValue> &OutVals,
                                const SDLoc &DL, SelectionDAG &DAG) const {
  if (IsVarArg) {
    report_fatal_error("VarArg not supported");
  }

  // Stores the assignment of the return value to a location.
  SmallVector<CCValAssign, 16> RVLocs;

  // Info about the registers and stack slot.
  CCState CCInfo(CallConv, IsVarArg, DAG.getMachineFunction(), RVLocs,
                 *DAG.getContext());

  CCInfo.AnalyzeReturn(Outs, RetCC_CAHP);

  SDValue Flag;
  SmallVector<SDValue, 4> RetOps(1, Chain);

  // Copy the result values into the output registers.
  for (unsigned i = 0, e = RVLocs.size(); i < e; ++i) {
    CCValAssign &VA = RVLocs[i];
    assert(VA.isRegLoc() && "Can only return in registers!");

    Chain = DAG.getCopyToReg(Chain, DL, VA.getLocReg(), OutVals[i], Flag);

    // Guarantee that all emitted copies are stuck together.
    Flag = Chain.getValue(1);
    RetOps.push_back(DAG.getRegister(VA.getLocReg(), VA.getLocVT()));
  }

  RetOps[0] = Chain; // Update chain.

  // Add the flag if we have it.
  if (Flag.getNode()) {
    RetOps.push_back(Flag);
  }

  return DAG.getNode(CAHPISD::RET_FLAG, DL, MVT::Other, RetOps);
}

const char *CAHPTargetLowering::getTargetNodeName(unsigned Opcode) const {
  switch ((CAHPISD::NodeType)Opcode) {
  case CAHPISD::FIRST_NUMBER:
    break;
  case CAHPISD::RET_FLAG:
    return "CAHPISD::RET_FLAG";
  }
  return nullptr;
}
