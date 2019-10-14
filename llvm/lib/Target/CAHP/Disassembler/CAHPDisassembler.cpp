// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

#include "MCTargetDesc/CAHPMCTargetDesc.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCDisassembler/MCDisassembler.h"
#include "llvm/MC/MCFixedLenDisassembler.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/Support/Endian.h"
#include "llvm/Support/FormatVariadic.h"
#include "llvm/Support/TargetRegistry.h"

using namespace llvm;

#define DEBUG_TYPE "cahp-disassembler"

typedef MCDisassembler::DecodeStatus DecodeStatus;

namespace {
class CAHPDisassembler : public MCDisassembler {

public:
  CAHPDisassembler(const MCSubtargetInfo &STI, MCContext &Ctx)
      : MCDisassembler(STI, Ctx) {}

  DecodeStatus getInstruction(MCInst &Instr, uint64_t &Size,
                              ArrayRef<uint8_t> Bytes, uint64_t Address,
                              raw_ostream &VStream,
                              raw_ostream &CStream) const override;
};
} // end anonymous namespace

static MCDisassembler *createCAHPDisassembler(const Target &T,
                                              const MCSubtargetInfo &STI,
                                              MCContext &Ctx) {
  return new CAHPDisassembler(STI, Ctx);
}

extern "C" void LLVMInitializeCAHPDisassembler() {
  TargetRegistry::RegisterMCDisassembler(getTheCAHPTarget(),
                                         createCAHPDisassembler);
}

static const unsigned GPRDecoderTable[] = {
    CAHP::X0,  CAHP::X1,  CAHP::X2,  CAHP::X3, CAHP::X4,  CAHP::X5,
    CAHP::X6,  CAHP::X7,  CAHP::X8,  CAHP::X9, CAHP::X10, CAHP::X11,
    CAHP::X12, CAHP::X13, CAHP::X14, CAHP::X15};

static DecodeStatus DecodeGPRRegisterClass(MCInst &Inst, uint64_t RegNo,
                                           uint64_t Address,
                                           const void *Decoder) {
  if (RegNo > sizeof(GPRDecoderTable))
    return MCDisassembler::Fail;

  unsigned Reg = GPRDecoderTable[RegNo];
  Inst.addOperand(MCOperand::createReg(Reg));
  return MCDisassembler::Success;
}

// Add implied SP operand for instructions lwsp/swsp. The SP operand isn't
// explicitly encoded in the instruction.
static void addImplySP(MCInst &Inst, int64_t Address, const void *Decoder) {
  if (Inst.getOpcode() == CAHP::LWSP || Inst.getOpcode() == CAHP::SWSP)
    DecodeGPRRegisterClass(Inst, /* SP */ 1, Address, Decoder);
}

template <unsigned N>
static DecodeStatus decodeUImmOperand(MCInst &Inst, uint64_t Imm,
                                      int64_t Address, const void *Decoder) {
  assert(isUInt<N>(Imm) && "Invalid immediate");
  addImplySP(Inst, Address, Decoder);
  Inst.addOperand(MCOperand::createImm(Imm));
  return MCDisassembler::Success;
}

template <unsigned N>
static DecodeStatus decodeSImmOperand(MCInst &Inst, uint64_t Imm,
                                      int64_t Address, const void *Decoder) {
  assert(isUInt<N>(Imm) && "Invalid immediate");
  // Sign-extend the number in the bottom N bits of Imm
  Inst.addOperand(MCOperand::createImm(SignExtend64<N>(Imm)));
  return MCDisassembler::Success;
}

#include "CAHPGenDisassemblerTables.inc"

DecodeStatus CAHPDisassembler::getInstruction(MCInst &MI, uint64_t &Size,
                                              ArrayRef<uint8_t> Bytes,
                                              uint64_t Address, raw_ostream &OS,
                                              raw_ostream &CS) const {
  if (Bytes.size() < 2) {
    Size = 0;
    return MCDisassembler::Fail;
  }

  uint32_t Inst;
  DecodeStatus Result;

  uint8_t is24bitInst = Bytes[0] & 1;

  if (is24bitInst) {
    if (Bytes.size() < 3) {
      Size = 0;
      return MCDisassembler::Fail;
    }

    Inst = Bytes[0] | (Bytes[1] << 8) | (Bytes[2] << 16);
    LLVM_DEBUG(dbgs() << "Trying CAHP 24bit table :\n");
    Result = decodeInstruction(DecoderTable24, MI, Inst, Address, this, STI);
    Size = 3;
  } else {
    if (Bytes.size() < 2) {
      Size = 0;
      return MCDisassembler::Fail;
    }
    Inst = support::endian::read16le(Bytes.data());
    LLVM_DEBUG(dbgs() << "Trying CAHP 16bit table :\n");
    Result = decodeInstruction(DecoderTable16, MI, Inst, Address, this, STI);
    Size = 2;
  }

  return Result;
}
