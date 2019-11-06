// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

#include "CAHP.h"
#include "CAHPTargetMachine.h"
#include "InstPrinter/CAHPInstPrinter.h"
#include "llvm/CodeGen/AsmPrinter.h"
#include "llvm/CodeGen/MachineConstantPool.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/MachineModuleInfo.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Support/raw_ostream.h"
using namespace llvm;

#define DEBUG_TYPE "asm-printer"

namespace {
class CAHPAsmPrinter : public AsmPrinter {
public:
  explicit CAHPAsmPrinter(TargetMachine &TM,
                          std::unique_ptr<MCStreamer> Streamer)
      : AsmPrinter(TM, std::move(Streamer)) {}

  StringRef getPassName() const override { return "CAHP Assembly Printer"; }

  void EmitInstruction(const MachineInstr *MI) override;

  bool PrintAsmOperand(const MachineInstr *MI, unsigned OpNo,
                       const char *ExtraCode, raw_ostream &OS) override;
  bool PrintAsmMemoryOperand(const MachineInstr *MI, unsigned OpNo,
                             const char *ExtraCode, raw_ostream &OS) override;

  // TableGen'erated function.
  bool emitPseudoExpansionLowering(MCStreamer &OutStreamer,
                                   const MachineInstr *MI);
};
} // namespace

// Simple pseudo-instructions have their lowering (with expansion to real
// instructions) auto-generated.
#include "CAHPGenMCPseudoLowering.inc"

#define GEN_COMPRESS_INSTR
#include "CAHPGenCompressInstEmitter.inc"

void CAHPAsmPrinter::EmitInstruction(const MachineInstr *MI) {
  // Do any auto-generated pseudo lowerings.
  if (emitPseudoExpansionLowering(*OutStreamer, MI))
    return;

  MCInst TmpInst, CInst;
  LowerCAHPMachineInstrToMCInst(MI, TmpInst, *this);
  bool Res = compressInst(CInst, TmpInst, *TM.getMCSubtargetInfo(),
                          OutStreamer->getContext());
  EmitToStreamer(*OutStreamer, Res ? CInst : TmpInst);
}

bool CAHPAsmPrinter::PrintAsmOperand(const MachineInstr *MI, unsigned OpNo,
                                     const char *ExtraCode, raw_ostream &OS) {
  // First try the generic code, which knows about modifiers like 'c' and 'n'.
  if (!AsmPrinter::PrintAsmOperand(MI, OpNo, ExtraCode, OS))
    return false;

  if (!ExtraCode) {
    const MachineOperand &MO = MI->getOperand(OpNo);
    switch (MO.getType()) {
    case MachineOperand::MO_Immediate:
      OS << MO.getImm();
      return false;
    case MachineOperand::MO_Register:
      OS << CAHPInstPrinter::getRegisterName(MO.getReg());
      return false;
    default:
      break;
    }
  }

  return true;
}

bool CAHPAsmPrinter::PrintAsmMemoryOperand(const MachineInstr *MI,
                                           unsigned OpNo, const char *ExtraCode,
                                           raw_ostream &OS) {
  if (!ExtraCode) {
    const MachineOperand &MO = MI->getOperand(OpNo);
    // For now, we only support register memory operands in registers and
    // assume there is no addend
    if (!MO.isReg())
      return true;

    OS << "0(" << CAHPInstPrinter::getRegisterName(MO.getReg()) << ")";
    return false;
  }

  return AsmPrinter::PrintAsmMemoryOperand(MI, OpNo, ExtraCode, OS);
}

// Force static initialization.
extern "C" void LLVMInitializeCAHPAsmPrinter() {
  RegisterAsmPrinter<CAHPAsmPrinter> X(getTheCAHPTarget());
}
