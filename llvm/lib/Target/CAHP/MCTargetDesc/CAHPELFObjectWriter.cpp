// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

#include "MCTargetDesc/CAHPFixupKinds.h"
#include "MCTargetDesc/CAHPMCTargetDesc.h"
#include "llvm/MC/MCELFObjectWriter.h"
#include "llvm/MC/MCFixup.h"
#include "llvm/MC/MCObjectWriter.h"
#include "llvm/Support/ErrorHandling.h"

using namespace llvm;

namespace {
class CAHPELFObjectWriter : public MCELFObjectTargetWriter {
public:
  CAHPELFObjectWriter(uint8_t OSABI);

  ~CAHPELFObjectWriter() override;

protected:
  unsigned getRelocType(MCContext &Ctx, const MCValue &Target,
                        const MCFixup &Fixup, bool IsPCRel) const override;
};
} // namespace

CAHPELFObjectWriter::CAHPELFObjectWriter(uint8_t OSABI)
    : MCELFObjectTargetWriter(false, OSABI, ELF::EM_CAHP,
                              /*HasRelocationAddend*/ true) {}

CAHPELFObjectWriter::~CAHPELFObjectWriter() {}

unsigned CAHPELFObjectWriter::getRelocType(MCContext &Ctx,
                                           const MCValue &Target,
                                           const MCFixup &Fixup,
                                           bool IsPCRel) const {
  // Determine the type of the relocation
  switch ((unsigned)Fixup.getKind()) {
  default:
    llvm_unreachable("invalid fixup kind!");
  case FK_Data_2:
    return ELF::R_CAHP_16;
  case CAHP::fixup_cahp_hi6:
    return ELF::R_CAHP_HI6;
  case CAHP::fixup_cahp_lo10:
    return ELF::R_CAHP_LO10;
  case CAHP::fixup_cahp_pcrel_11:
    return ELF::R_CAHP_PCREL_11;
  }
}

std::unique_ptr<MCObjectTargetWriter>
llvm::createCAHPELFObjectWriter(uint8_t OSABI) {
  return llvm::make_unique<CAHPELFObjectWriter>(OSABI);
}
