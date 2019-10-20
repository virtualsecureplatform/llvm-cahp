// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

#include "CAHPMCExpr.h"
#include "llvm/MC/MCAssembler.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCSymbolELF.h"
#include "llvm/MC/MCValue.h"
#include "llvm/Object/ELF.h"
#include "llvm/Support/ErrorHandling.h"

using namespace llvm;

#define DEBUG_TYPE "riscvmcexpr"

const CAHPMCExpr *CAHPMCExpr::create(const MCExpr *Expr, VariantKind Kind,
                                     MCContext &Ctx) {
  return new (Ctx) CAHPMCExpr(Expr, Kind);
}

void CAHPMCExpr::printImpl(raw_ostream &OS, const MCAsmInfo *MAI) const {
  bool HasVariant = getKind() != VK_CAHP_None;
  if (HasVariant)
    OS << '%' << getVariantKindName(getKind()) << '(';
  Expr->print(OS, MAI);
  if (HasVariant)
    OS << ')';
}

bool CAHPMCExpr::evaluateAsRelocatableImpl(MCValue &Res,
                                           const MCAsmLayout *Layout,
                                           const MCFixup *Fixup) const {
  return getSubExpr()->evaluateAsRelocatable(Res, Layout, Fixup);
}

void CAHPMCExpr::visitUsedExpr(MCStreamer &Streamer) const {
  Streamer.visitUsedExpr(*getSubExpr());
}

CAHPMCExpr::VariantKind CAHPMCExpr::getVariantKindForName(StringRef name) {
  return StringSwitch<CAHPMCExpr::VariantKind>(name)
      .Case("lo", VK_CAHP_LO)
      .Case("hi", VK_CAHP_HI)
      .Default(VK_CAHP_Invalid);
}

StringRef CAHPMCExpr::getVariantKindName(VariantKind Kind) {
  switch (Kind) {
  default:
    llvm_unreachable("Invalid ELF symbol kind");
  case VK_CAHP_LO:
    return "lo";
  case VK_CAHP_HI:
    return "hi";
  }
}

bool CAHPMCExpr::evaluateAsConstant(int64_t &Res) const {
  MCValue Value;

  if (!getSubExpr()->evaluateAsRelocatable(Value, nullptr, nullptr))
    return false;

  if (!Value.isAbsolute())
    return false;

  Res = evaluateAsInt64(Value.getConstant());
  return true;
}

int64_t CAHPMCExpr::evaluateAsInt64(int64_t Value) const {
  switch (Kind) {
  default:
    llvm_unreachable("Invalid kind");
  case VK_CAHP_LO:
    return SignExtend64<10>(Value);
  case VK_CAHP_HI:
    // Add 1 if bit 9 is 1, to compensate for low 10 bits being negative.
    return ((Value + 0x200) >> 10) & 0x3f;
  }
}
