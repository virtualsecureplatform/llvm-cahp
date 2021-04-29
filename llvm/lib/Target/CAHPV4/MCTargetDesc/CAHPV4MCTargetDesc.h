// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

#ifndef LLVM_LIB_TARGET_CAHPV4_MCTARGETDESC_CAHPV4MCTARGETDESC_H
#define LLVM_LIB_TARGET_CAHPV4_MCTARGETDESC_CAHPV4MCTARGETDESC_H

#include "llvm/Config/config.h"
#include "llvm/MC/MCTargetOptions.h"
#include "llvm/Support/DataTypes.h"
#include <memory>

namespace llvm {
class MCAsmBackend;
class MCCodeEmitter;
class MCContext;
class MCInstrInfo;
class MCObjectTargetWriter;
class MCRegisterInfo;
class MCSubtargetInfo;
class StringRef;
class Target;
class Triple;
class raw_ostream;
class raw_pwrite_stream;

Target &getTheCAHPV4Target();

MCCodeEmitter *createCAHPV4MCCodeEmitter(const MCInstrInfo &MCII,
                                         const MCRegisterInfo &MRI,
                                         MCContext &Ctx);

MCAsmBackend *createCAHPV4AsmBackend(const Target &T,
                                     const MCSubtargetInfo &STI,
                                     const MCRegisterInfo &MRI,
                                     const MCTargetOptions &Options);

std::unique_ptr<MCObjectTargetWriter>
createCAHPV4ELFObjectWriter(uint8_t OSABI);
} // namespace llvm

// Defines symbolic names for CAHPV4 registers.
#define GET_REGINFO_ENUM
#include "CAHPV4GenRegisterInfo.inc"

// Defines symbolic names for CAHPV4 instructions.
#define GET_INSTRINFO_ENUM
#include "CAHPV4GenInstrInfo.inc"

#endif
