// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

#include "MCTargetDesc/CAHPV4MCTargetDesc.h"
#include "llvm/MC/MCELFObjectWriter.h"
#include "llvm/MC/MCFixup.h"
#include "llvm/MC/MCObjectWriter.h"
#include "llvm/Support/ErrorHandling.h"

using namespace llvm;

namespace {
class CAHPV4ELFObjectWriter : public MCELFObjectTargetWriter {
public:
  CAHPV4ELFObjectWriter(uint8_t OSABI);

  ~CAHPV4ELFObjectWriter() override;

protected:
  unsigned getRelocType(MCContext &Ctx, const MCValue &Target,
                        const MCFixup &Fixup, bool IsPCRel) const override;
};
} // namespace

CAHPV4ELFObjectWriter::CAHPV4ELFObjectWriter(uint8_t OSABI)
    : MCELFObjectTargetWriter(false, OSABI, ELF::EM_CAHPV4,
                              /*HasRelocationAddend*/ true) {}

CAHPV4ELFObjectWriter::~CAHPV4ELFObjectWriter() {}

unsigned CAHPV4ELFObjectWriter::getRelocType(MCContext &Ctx,
                                             const MCValue &Target,
                                             const MCFixup &Fixup,
                                             bool IsPCRel) const {
  report_fatal_error("invalid fixup kind!");
}

std::unique_ptr<MCObjectTargetWriter>
llvm::createCAHPV4ELFObjectWriter(uint8_t OSABI) {
  return std::make_unique<CAHPV4ELFObjectWriter>(OSABI);
}
