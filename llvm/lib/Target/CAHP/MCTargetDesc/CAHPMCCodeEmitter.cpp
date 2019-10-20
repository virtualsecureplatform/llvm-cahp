// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

#include "MCTargetDesc/CAHPFixupKinds.h"
#include "MCTargetDesc/CAHPMCExpr.h"
#include "MCTargetDesc/CAHPMCTargetDesc.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCCodeEmitter.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCInstrDesc.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/Support/Casting.h"
#include "llvm/Support/EndianStream.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

#define DEBUG_TYPE "mccodeemitter"

STATISTIC(MCNumEmitted, "Number of MC instructions emitted");
STATISTIC(MCNumFixups, "Number of MC fixups created");

namespace {
class CAHPMCCodeEmitter : public MCCodeEmitter {
  CAHPMCCodeEmitter(const CAHPMCCodeEmitter &) = delete;
  void operator=(const CAHPMCCodeEmitter &) = delete;
  MCContext &Ctx;
  MCInstrInfo const &MCII;

public:
  CAHPMCCodeEmitter(MCContext &ctx, const MCInstrInfo &MCII)
      : Ctx(ctx), MCII(MCII) {}

  ~CAHPMCCodeEmitter() override {}

  void encodeInstruction(const MCInst &MI, raw_ostream &OS,
                         SmallVectorImpl<MCFixup> &Fixups,
                         const MCSubtargetInfo &STI) const override;

  /// TableGen'erated function for getting the binary encoding for an
  /// instruction.
  uint64_t getBinaryCodeForInstr(const MCInst &MI,
                                 SmallVectorImpl<MCFixup> &Fixups,
                                 const MCSubtargetInfo &STI) const;

  /// Return binary encoding of operand. If the machine operand requires
  /// relocation, record the relocation and return zero.
  unsigned getMachineOpValue(const MCInst &MI, const MCOperand &MO,
                             SmallVectorImpl<MCFixup> &Fixups,
                             const MCSubtargetInfo &STI) const;

  unsigned getImmOpValue(const MCInst &MI, unsigned OpNo,
                         SmallVectorImpl<MCFixup> &Fixups,
                         const MCSubtargetInfo &STI) const;
};
} // end anonymous namespace

MCCodeEmitter *llvm::createCAHPMCCodeEmitter(const MCInstrInfo &MCII,
                                             const MCRegisterInfo &MRI,
                                             MCContext &Ctx) {
  return new CAHPMCCodeEmitter(Ctx, MCII);
}

void CAHPMCCodeEmitter::encodeInstruction(const MCInst &MI, raw_ostream &OS,
                                          SmallVectorImpl<MCFixup> &Fixups,
                                          const MCSubtargetInfo &STI) const {
  const MCInstrDesc &Desc = MCII.get(MI.getOpcode());
  // Get byte count of instruction.
  unsigned Size = Desc.getSize();

  switch (Size) {
  default:
    llvm_unreachable("Unhandled encodeInstruction length!");
  case 2: {
    uint16_t Bits = getBinaryCodeForInstr(MI, Fixups, STI);
    support::endian::write<uint16_t>(OS, Bits, support::little);
    break;
  }
  case 3: {
    uint32_t Bits = getBinaryCodeForInstr(MI, Fixups, STI);
    support::endian::write<uint16_t>(OS, Bits & 0xffff, support::little);
    OS.write((Bits >> 16) & 0xff);
    break;
  }
  }

  ++MCNumEmitted; // Keep track of the # of mi's emitted.
}

unsigned
CAHPMCCodeEmitter::getMachineOpValue(const MCInst &MI, const MCOperand &MO,
                                     SmallVectorImpl<MCFixup> &Fixups,
                                     const MCSubtargetInfo &STI) const {

  if (MO.isReg())
    return Ctx.getRegisterInfo()->getEncodingValue(MO.getReg());

  if (MO.isImm())
    return static_cast<unsigned>(MO.getImm());

  llvm_unreachable("Unhandled expression!");
  return 0;
}

unsigned CAHPMCCodeEmitter::getImmOpValue(const MCInst &MI, unsigned OpNo,
                                          SmallVectorImpl<MCFixup> &Fixups,
                                          const MCSubtargetInfo &STI) const {
  const MCOperand &MO = MI.getOperand(OpNo);

  if (MO.isImm())
    return MO.getImm();

  assert(MO.isExpr() && "getImmOpValue expects only expressions or immediates");

  const MCExpr *Expr = MO.getExpr();
  MCExpr::ExprKind Kind = Expr->getKind();
  CAHP::Fixups FixupKind = CAHP::fixup_cahp_invalid;
  unsigned Offset = 0;

  if (Kind == MCExpr::Target) {
    const CAHPMCExpr *CAHPExpr = cast<CAHPMCExpr>(Expr);

    switch (CAHPExpr->getKind()) {
    case CAHPMCExpr::VK_CAHP_None:
    case CAHPMCExpr::VK_CAHP_Invalid:
      llvm_unreachable("Unhandled fixup kind!");

    case CAHPMCExpr::VK_CAHP_LO:
      FixupKind = CAHP::fixup_cahp_lo10;
      break;

    case CAHPMCExpr::VK_CAHP_HI:
      FixupKind = CAHP::fixup_cahp_hi6;
      break;
    }
  } else if (Kind == MCExpr::SymbolRef &&
             cast<MCSymbolRefExpr>(Expr)->getKind() ==
                 MCSymbolRefExpr::VK_None) {
    switch (MI.getOpcode()) {
    case CAHP::JS:
    case CAHP::JSAL:
      FixupKind = CAHP::fixup_cahp_pcrel_11;
      break;

    case CAHP::BEQ:
    case CAHP::BNE:
    case CAHP::BLT:
    case CAHP::BLTU:
    case CAHP::BLE:
    case CAHP::BLEU:
      FixupKind = CAHP::fixup_cahp_pcrel_10;
      break;
    }
  }

  assert(FixupKind != CAHP::fixup_cahp_invalid && "Unhandled expression!");

  Fixups.push_back(MCFixup::create(
      Offset, Expr, static_cast<MCFixupKind>(FixupKind), MI.getLoc()));
  ++MCNumFixups;

  return 0;
}

#include "CAHPGenMCCodeEmitter.inc"
