// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

#ifndef LLVM_LIB_TARGET_CAHP_MCTARGETDESC_CAHPMCEXPR_H
#define LLVM_LIB_TARGET_CAHP_MCTARGETDESC_CAHPMCEXPR_H

#include "llvm/MC/MCExpr.h"

namespace llvm {

class StringRef;
class CAHPMCExpr : public MCTargetExpr {
public:
  enum VariantKind { VK_CAHP_None, VK_CAHP_LO, VK_CAHP_HI, VK_CAHP_Invalid };

private:
  const MCExpr *Expr;
  const VariantKind Kind;

  int64_t evaluateAsInt64(int64_t Value) const;

  explicit CAHPMCExpr(const MCExpr *Expr, VariantKind Kind)
      : Expr(Expr), Kind(Kind) {}

public:
  static const CAHPMCExpr *create(const MCExpr *Expr, VariantKind Kind,
                                  MCContext &Ctx);

  VariantKind getKind() const { return Kind; }

  const MCExpr *getSubExpr() const { return Expr; }

  void printImpl(raw_ostream &OS, const MCAsmInfo *MAI) const override;
  bool evaluateAsRelocatableImpl(MCValue &Res, const MCAsmLayout *Layout,
                                 const MCFixup *Fixup) const override;
  void visitUsedExpr(MCStreamer &Streamer) const override;
  MCFragment *findAssociatedFragment() const override {
    return getSubExpr()->findAssociatedFragment();
  }

  // There are no TLS CAHPMCExprs at the moment.
  void fixELFSymbolsInTLSFixups(MCAssembler &Asm) const override {}

  bool evaluateAsConstant(int64_t &Res) const;

  static bool classof(const MCExpr *E) {
    return E->getKind() == MCExpr::Target;
  }

  static bool classof(const CAHPMCExpr *) { return true; }

  static VariantKind getVariantKindForName(StringRef name);
  static StringRef getVariantKindName(VariantKind Kind);
};

} // end namespace llvm.

#endif
