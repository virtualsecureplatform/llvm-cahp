// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

#include "CAHP.h"
#include "CAHPTargetMachine.h"
#include "MCTargetDesc/CAHPMCTargetDesc.h"
#include "llvm/CodeGen/SelectionDAGISel.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/MathExtras.h"
#include "llvm/Support/raw_ostream.h"
using namespace llvm;

#define DEBUG_TYPE "cahp-isel"

// CAHP-specific code to select CAHP machine instructions for
// SelectionDAG operations.
namespace {
class CAHPDAGToDAGISel final : public SelectionDAGISel {
public:
  explicit CAHPDAGToDAGISel(CAHPTargetMachine &TargetMachine)
      : SelectionDAGISel(TargetMachine) {}

  StringRef getPassName() const override {
    return "CAHP DAG->DAG Pattern Instruction Selection";
  }

  void Select(SDNode *Node) override;

  // Include the pieces autogenerated from the target description.
#include "CAHPGenDAGISel.inc"
};
} // namespace

void CAHPDAGToDAGISel::Select(SDNode *Node) {
  // If we have a custom node, we have already selected
  if (Node->isMachineOpcode()) {
    LLVM_DEBUG(dbgs() << "== "; Node->dump(CurDAG); dbgs() << "\n");
    Node->setNodeId(-1);
    return;
  }

  // Select the default instruction.
  SelectCode(Node);
}

// This pass converts a legalized DAG into a CAHP-specific DAG, ready
// for instruction scheduling.
FunctionPass *llvm::createCAHPISelDag(CAHPTargetMachine &TM) {
  return new CAHPDAGToDAGISel(TM);
}
