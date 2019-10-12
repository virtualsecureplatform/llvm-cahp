// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

#ifndef LLVM_LIB_TARGET_CAHP_MCTARGETDESC_CAHPMCTARGETDESC_H
#define LLVM_LIB_TARGET_CAHP_MCTARGETDESC_CAHPMCTARGETDESC_H

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

Target &getTheCAHPTarget();

MCCodeEmitter *createCAHPMCCodeEmitter(const MCInstrInfo &MCII,
                                       const MCRegisterInfo &MRI,
                                       MCContext &Ctx);

MCAsmBackend *createCAHPAsmBackend(const Target &T, const MCSubtargetInfo &STI,
                                   const MCRegisterInfo &MRI,
                                   const MCTargetOptions &Options);

std::unique_ptr<MCObjectTargetWriter> createCAHPELFObjectWriter(uint8_t OSABI);
} // namespace llvm

// Defines symbolic names for CAHP registers.
#define GET_REGINFO_ENUM
#include "CAHPGenRegisterInfo.inc"

// Defines symbolic names for CAHP instructions.
#define GET_INSTRINFO_ENUM
#include "CAHPGenInstrInfo.inc"

#endif
