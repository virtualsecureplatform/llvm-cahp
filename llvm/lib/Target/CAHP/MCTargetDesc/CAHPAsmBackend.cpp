// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

#include "MCTargetDesc/CAHPFixupKinds.h"
#include "MCTargetDesc/CAHPMCTargetDesc.h"
#include "llvm/MC/MCAsmBackend.h"
#include "llvm/MC/MCAssembler.h"
#include "llvm/MC/MCContext.h"
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
class CAHPAsmBackend : public MCAsmBackend {
  uint8_t OSABI;

public:
  CAHPAsmBackend(uint8_t OSABI) : MCAsmBackend(support::little), OSABI(OSABI) {}
  ~CAHPAsmBackend() override {}

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

  unsigned getNumFixupKinds() const override {
    return CAHP::NumTargetFixupKinds;
  }

  const MCFixupKindInfo &getFixupKindInfo(MCFixupKind Kind) const override {
    if (Kind < FirstTargetFixupKind)
      return MCAsmBackend::getFixupKindInfo(Kind);

    // MCFixupKindInfo{name, offset, bits, flag}
    switch ((unsigned)Kind) {
    case CAHP::fixup_cahp_hi6: {
      const static MCFixupKindInfo info{"fixup_cahp_hi6", 0, 16, 0};
      return info;
    }

    case CAHP::fixup_cahp_lo10: {
      const static MCFixupKindInfo info{"fixup_cahp_lo10", 0, 24, 0};
      return info;
    }

    case CAHP::fixup_cahp_pcrel_10: {
      const static MCFixupKindInfo info{"fixup_cahp_pcrel_10", 0, 24,
                                        MCFixupKindInfo::FKF_IsPCRel};
      return info;
    }

    case CAHP::fixup_cahp_pcrel_11: {
      const static MCFixupKindInfo info{"fixup_cahp_pcrel_11", 5, 11,
                                        MCFixupKindInfo::FKF_IsPCRel};
      return info;
    }

    default:
      llvm_unreachable("Invalid kind!");
    }
  }

  bool mayNeedRelaxation(const MCInst &Inst,
                         const MCSubtargetInfo &STI) const override {
    return false;
  }

  void relaxInstruction(const MCInst &Inst, const MCSubtargetInfo &STI,
                        MCInst &Res) const override {

    report_fatal_error("CAHPAsmBackend::relaxInstruction() unimplemented");
  }

  bool writeNopData(raw_ostream &OS, uint64_t Count) const override;
};

bool CAHPAsmBackend::writeNopData(raw_ostream &OS, uint64_t Count) const {
  if ((Count % 2) != 0)
    return false;

  Count /= 2;
  for (uint64_t i = 0; i < Count; ++i)
    OS.write("\0\0", 2);

  return true;
}

static uint64_t adjustFixupValue(const MCFixup &Fixup, uint64_t Value,
                                 MCContext &Ctx) {
  unsigned Kind = Fixup.getKind();
  switch (Kind) {
  default:
    llvm_unreachable("Unknown fixup kind!");

  case FK_Data_1:
  case FK_Data_2:
  case FK_Data_4:
  case FK_Data_8:
    return Value;

  case CAHP::fixup_cahp_hi6:
    // Add 1 if bit 9 is 1, to compensate for low 10 bits being negative.
    Value = ((Value + 0x200) >> 10) & 0x3f;
    // Need to produce (imm[3:0] << 12)|(imm[5:4] << 6) from the 6-bit Value.
    return ((Value & 0xf) << 12) | (((Value >> 4) & 3) << 6);

  case CAHP::fixup_cahp_lo10:
    Value = Value & 0x3ff;
    // Need to produce (imm[7:0] << 16)|(imm[9:8] << 6)
    return ((Value & 0xff) << 16) | (((Value >> 8) & 3) << 6);

  case CAHP::fixup_cahp_pcrel_10:
    if (!isInt<10>(Value))
      Ctx.reportError(Fixup.getLoc(),
                      "fixup value out of range (fixup_cahp_pcrel_10)");
    // Need to produce (imm[7:0] << 16)|(imm[9:8] << 6) from the 10-bit Value.
    return ((Value & 0xff) << 16) | (((Value >> 8) & 0x3) << 6);

  case CAHP::fixup_cahp_pcrel_11:
    if (!isInt<11>(Value))
      Ctx.reportError(Fixup.getLoc(),
                      "fixup value out of range (fixup_cahp_pcrel_11)");
    return Value;
  }
}

void CAHPAsmBackend::applyFixup(const MCAssembler &Asm, const MCFixup &Fixup,
                                const MCValue &Target,
                                MutableArrayRef<char> Data, uint64_t Value,
                                bool IsResolved,
                                const MCSubtargetInfo *STI) const {
  if (!Value)
    return; // Doesn't change encoding.

  MCContext &Ctx = Asm.getContext();
  MCFixupKindInfo Info = getFixupKindInfo(Fixup.getKind());
  // Apply any target-specific value adjustments.
  Value = adjustFixupValue(Fixup, Value, Ctx);

  // Shift the value into position.
  Value <<= Info.TargetOffset;

  unsigned Offset = Fixup.getOffset();
  unsigned NumBytes = alignTo(Info.TargetSize + Info.TargetOffset, 8) / 8;

  assert(Offset + NumBytes <= Data.size() && "Invalid fixup offset!");

  // For each byte of the fragment that the fixup touches, mask in the
  // bits from the fixup value.
  for (unsigned i = 0; i != NumBytes; ++i) {
    Data[Offset + i] |= static_cast<uint8_t>((Value >> (i * 8)) & 0xff);
  }

  return;
}

std::unique_ptr<MCObjectTargetWriter>
CAHPAsmBackend::createObjectTargetWriter() const {
  return createCAHPELFObjectWriter(OSABI);
}

} // end anonymous namespace

MCAsmBackend *llvm::createCAHPAsmBackend(const Target &T,
                                         const MCSubtargetInfo &STI,
                                         const MCRegisterInfo &MRI,
                                         const MCTargetOptions &Options) {
  const Triple &TT = STI.getTargetTriple();
  uint8_t OSABI = MCELFObjectTargetWriter::getOSABI(TT.getOS());
  return new CAHPAsmBackend(OSABI);
}
