// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

#include "CAHP.h"
#include "MCTargetDesc/CAHPBaseInfo.h"
#include "MCTargetDesc/CAHPMCExpr.h"
#include "llvm/CodeGen/AsmPrinter.h"
#include "llvm/CodeGen/MachineBasicBlock.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInst.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

static MCOperand lowerSymbolOperand(const MachineOperand &MO, MCSymbol *Sym,
                                    const AsmPrinter &AP) {
  MCContext &Ctx = AP.OutContext;
  CAHPMCExpr::VariantKind Kind;

  switch (MO.getTargetFlags()) {
  default:
    llvm_unreachable("Unknown target flag on GV operand");
  case CAHPII::MO_None:
    Kind = CAHPMCExpr::VK_CAHP_None;
    break;
  case CAHPII::MO_LO:
    Kind = CAHPMCExpr::VK_CAHP_LO;
    break;
  case CAHPII::MO_HI:
    Kind = CAHPMCExpr::VK_CAHP_HI;
    break;
  }

  const MCExpr *ME =
      MCSymbolRefExpr::create(Sym, MCSymbolRefExpr::VK_None, Ctx);

  if (!MO.isJTI() && MO.getOffset())
    ME = MCBinaryExpr::createAdd(
        ME, MCConstantExpr::create(MO.getOffset(), Ctx), Ctx);

  ME = CAHPMCExpr::create(ME, Kind, Ctx);
  return MCOperand::createExpr(ME);
}

bool llvm::LowerCAHPMachineOperandToMCOperand(const MachineOperand &MO,
                                              MCOperand &MCOp,
                                              const AsmPrinter &AP) {
  switch (MO.getType()) {
  default:
    report_fatal_error("LowerCAHPMachineInstrToMCInst: unknown operand type");

  case MachineOperand::MO_Register:
    // Ignore all implicit register operands.
    if (MO.isImplicit())
      return false;
    MCOp = MCOperand::createReg(MO.getReg());
    break;

  case MachineOperand::MO_RegisterMask:
    // Regmasks are like implicit defs.
    return false;

  case MachineOperand::MO_Immediate:
    MCOp = MCOperand::createImm(MO.getImm());
    break;

  case MachineOperand::MO_MachineBasicBlock:
    MCOp = MCOperand::createExpr(
        MCSymbolRefExpr::create(MO.getMBB()->getSymbol(), AP.OutContext));
    break;

  case MachineOperand::MO_GlobalAddress:
    MCOp = lowerSymbolOperand(MO, AP.getSymbol(MO.getGlobal()), AP);
    break;

  case MachineOperand::MO_ExternalSymbol:
    MCOp = lowerSymbolOperand(
        MO, AP.GetExternalSymbolSymbol(MO.getSymbolName()), AP);
    break;
  }

  return true;
}

void llvm::LowerCAHPMachineInstrToMCInst(const MachineInstr *MI, MCInst &OutMI,
                                         const AsmPrinter &AP) {
  OutMI.setOpcode(MI->getOpcode());

  for (const MachineOperand &MO : MI->operands()) {
    MCOperand MCOp;
    LowerCAHPMachineOperandToMCOperand(MO, MCOp, AP);
    if (LowerCAHPMachineOperandToMCOperand(MO, MCOp, AP))
      OutMI.addOperand(MCOp);
  }
}
