// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

#include "MCTargetDesc/CAHPV4MCTargetDesc.h"
#include "llvm/MC/MCAsmBackend.h"
#include "llvm/MC/MCAssembler.h"
#include "llvm/MC/MCDirectives.h"
#include "llvm/MC/MCELFObjectWriter.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCFixupKindInfo.h"
#include "llvm/MC/MCObjectWriter.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

namespace {
class CAHPV4AsmBackend : public MCAsmBackend {
  uint8_t OSABI;

public:
  CAHPV4AsmBackend(uint8_t OSABI)
      : MCAsmBackend(support::little), OSABI(OSABI) {}
  ~CAHPV4AsmBackend() override {}

  void applyFixup(const MCAssembler &Asm, const MCFixup &Fixup,
                  const MCValue &Target, MutableArrayRef<char> Data,
                  uint64_t Value, bool IsResolved,
                  const MCSubtargetInfo *STI) const override;

  std::unique_ptr<MCObjectTargetWriter>
  createObjectTargetWriter() const override;

  bool fixupNeedsRelaxation(const MCFixup &Fixup, uint64_t Value,
                            const MCRelaxableFragment *DF,
                            const MCAsmLayout &Layout) const override {
    return false;
  }

  unsigned getNumFixupKinds() const override { return 1; }

  bool mayNeedRelaxation(const MCInst &Inst,
                         const MCSubtargetInfo &STI) const override {
    return false;
  }

  void relaxInstruction(MCInst &Inst,
                        const MCSubtargetInfo &STI) const override {

    report_fatal_error("CAHPV4AsmBackend::relaxInstruction() unimplemented");
  }

  bool writeNopData(raw_ostream &OS, uint64_t Count) const override;
};

bool CAHPV4AsmBackend::writeNopData(raw_ostream &OS, uint64_t Count) const {
  if ((Count % 4) != 0)
    return false;

  Count /= 4;
  for (uint64_t i = 0; i < Count; ++i)
    OS.write("\x08\x02\0\0", 4);

  return true;
}

void CAHPV4AsmBackend::applyFixup(const MCAssembler &Asm, const MCFixup &Fixup,
                                  const MCValue &Target,
                                  MutableArrayRef<char> Data, uint64_t Value,
                                  bool IsResolved,
                                  const MCSubtargetInfo *STI) const {
  return;
}

std::unique_ptr<MCObjectTargetWriter>
CAHPV4AsmBackend::createObjectTargetWriter() const {
  return createCAHPV4ELFObjectWriter(OSABI);
}

} // end anonymous namespace

MCAsmBackend *llvm::createCAHPV4AsmBackend(const Target &T,
                                           const MCSubtargetInfo &STI,
                                           const MCRegisterInfo &MRI,
                                           const MCTargetOptions &Options) {
  const Triple &TT = STI.getTargetTriple();
  uint8_t OSABI = MCELFObjectTargetWriter::getOSABI(TT.getOS());
  return new CAHPV4AsmBackend(OSABI);
}
