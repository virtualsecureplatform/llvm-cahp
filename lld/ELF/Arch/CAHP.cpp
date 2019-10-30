// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

#include "InputFiles.h"
#include "SyntheticSections.h"
#include "Target.h"

using namespace llvm;
using namespace llvm::object;
using namespace llvm::support::endian;
using namespace llvm::ELF;
using namespace lld;
using namespace lld::elf;

namespace {

class CAHP final : public TargetInfo {
public:
  CAHP();
  RelExpr getRelExpr(RelType type, const Symbol &s,
                     const uint8_t *loc) const override;
  void relocateOne(uint8_t *loc, RelType type, uint64_t val) const override;
};

} // end anonymous namespace

CAHP::CAHP() { noneRel = R_CAHP_NONE; }

RelExpr CAHP::getRelExpr(const RelType type, const Symbol &s,
                         const uint8_t *loc) const {
  switch (type) {
  case R_CAHP_PCREL_11:
    return R_PC;

  default:
    return R_ABS;
  }
}

void CAHP::relocateOne(uint8_t *loc, const RelType type,
                       const uint64_t val) const {
  switch (type) {
  case R_CAHP_NONE:
    break;

  case R_CAHP_16:
    write16le(loc, val);
    break;

  case R_CAHP_PCREL_11: {
    checkInt(loc, static_cast<int64_t>(val), 11, type);
    uint32_t insn = read16le(loc) & 0x001F;
    insn |= (val << 5);
    write16le(loc, insn);
    break;
  }

  case R_CAHP_HI6: {
    uint64_t hi = (val + 0x200) >> 10;

    uint32_t insn = read16le(loc) & 0x0F3F;
    uint16_t imm3_0 = (hi & 0xF) << 12;
    uint16_t imm5_4 = ((hi >> 4) & 3) << 6;
    insn |= imm3_0 | imm5_4;
    write16le(loc, insn);
    break;
  }

  case R_CAHP_LO10: {
    uint64_t hi = (val + 0x200) >> 10;
    uint64_t lo = val - (hi << 10);

    uint32_t insn = read32le(loc) & 0xFF00FF3F;
    uint32_t imm7_0 = (lo & 0xFF) << 16;
    uint32_t imm9_8 = ((lo >> 8) & 3) << 6;
    insn |= imm7_0 | imm9_8;
    write32le(loc, insn);
    break;
  }

  default:
    error(getErrorLocation(loc) +
          "unimplemented relocation: " + toString(type));
    return;
  }
}

TargetInfo *elf::getCAHPTargetInfo() {
  static CAHP target;
  return &target;
}
