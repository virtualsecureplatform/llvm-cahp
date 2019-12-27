// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

include "CAHPInstrFormats.td"

def SDT_CAHPCall         : SDTypeProfile<0, -1, [SDTCisVT<0, i16>]>;
def SDT_CAHPCallSeqStart : SDCallSeqStart<[SDTCisVT<0, i16>, SDTCisVT<1, i16>]>;
def SDT_CAHPCallSeqEnd   : SDCallSeqEnd<[SDTCisVT<0, i16>, SDTCisVT<1, i16>]>;
def SDT_CAHPSelectCC     : SDTypeProfile<1, 5, [SDTCisSameAs<1, 2>,
                                                SDTCisSameAs<0, 4>,
                                                SDTCisSameAs<4, 5>]>;
def SDT_CAHPBrCC         : SDTypeProfile<0, 4, [SDTCisSameAs<0, 1>,
                                                SDTCisVT<3, OtherVT>]>;

def BrCC         : SDNode<"CAHPISD::BR_CC", SDT_CAHPBrCC,
                          [SDNPHasChain, SDNPOutGlue, SDNPInGlue]>;
def Call         : SDNode<"CAHPISD::CALL", SDT_CAHPCall,
                          [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue,
                           SDNPVariadic]>;
def CallSeqStart : SDNode<"ISD::CALLSEQ_START", SDT_CAHPCallSeqStart,
                          [SDNPHasChain, SDNPOutGlue]>;
def CallSeqEnd   : SDNode<"ISD::CALLSEQ_END", SDT_CAHPCallSeqEnd,
                          [SDNPHasChain, SDNPOptInGlue, SDNPOutGlue]>;
def RetFlag      : SDNode<"CAHPISD::RET_FLAG", SDTNone,
                          [SDNPHasChain, SDNPOptInGlue, SDNPVariadic]>;
def SelectCC     : SDNode<"CAHPISD::SELECT_CC", SDT_CAHPSelectCC,
                          [SDNPInGlue]>;

class ImmAsmOperand<string prefix, int width, string suffix> : AsmOperandClass {
  let Name = prefix # "Imm" # width # suffix;
  let RenderMethod = "addImmOperands";
  let DiagnosticType = "Invalid" # Name;
}

class SImmAsmOperand<int width, string suffix = "">
    : ImmAsmOperand<"S", width, suffix> {
}

class UImmAsmOperand<int width, string suffix = "">
    : ImmAsmOperand<"U", width, suffix> {
}

def uimm4 : Operand<i16>, ImmLeaf<i16, [{return isUInt<4>(Imm);}]> {
  let ParserMatchClass = UImmAsmOperand<4>;
  let DecoderMethod = "decodeUImmOperand<4>";
  let EncoderMethod = "getImmOpValue";
  let MCOperandPredicate = [{
    int64_t Imm;
    if (!MCOp.evaluateAsConstantImm(Imm))
      return false;
    return isUInt<4>(Imm);
  }];
}

def simm6 : Operand<i16>, ImmLeaf<i16, [{return isInt<6>(Imm);}]> {
  let ParserMatchClass = SImmAsmOperand<6>;
  let DecoderMethod = "decodeSImmOperand<6>";
  let EncoderMethod = "getImmOpValue";
  let MCOperandPredicate = [{
    int64_t Imm;
    if (!MCOp.evaluateAsConstantImm(Imm))
      return false;
    return isInt<6>(Imm);
  }];
}

def simm10 : Operand<i16>, ImmLeaf<i16, [{return isInt<10>(Imm);}]> {
  let ParserMatchClass = SImmAsmOperand<10>;
  let DecoderMethod = "decodeSImmOperand<10>";
  let EncoderMethod = "getImmOpValue";
  let MCOperandPredicate = [{
    int64_t Imm;
    if (!MCOp.evaluateAsConstantImm(Imm))
      return false;
    return isInt<10>(Imm);
  }];
}

def simm10_branch : Operand<OtherVT> {
  let ParserMatchClass = ImmAsmOperand<"BareS", 10, "">;
  let DecoderMethod = "decodeSImmOperand<10>";
  let EncoderMethod = "getImmOpValue";
}

def simm11 : Operand<i16>, ImmLeaf<i16, [{return isInt<11>(Imm);}]> {
  let ParserMatchClass = SImmAsmOperand<11>;
  let DecoderMethod = "decodeSImmOperand<11>";
  let EncoderMethod = "getImmOpValue";
}

def simm11_branch : Operand<OtherVT> {
  let ParserMatchClass = SImmAsmOperand<11>;
  let DecoderMethod = "decodeSImmOperand<11>";
  let EncoderMethod = "getImmOpValue";
}

def uimm7_lsb0 : Operand<i16> {
  let ParserMatchClass = UImmAsmOperand<7, "Lsb0">;
  let DecoderMethod = "decodeUImmOperand<7>";
  let EncoderMethod = "getImmOpValue";
  let MCOperandPredicate = [{
    int64_t Imm;
    if (!MCOp.evaluateAsConstantImm(Imm))
      return false;
    return isShiftedUInt<6, 1>(Imm);
  }];
}

// Standalone (codegen-only) immleaf patterns.
def simm16    : ImmLeaf<i16, [{return isInt<16>(Imm);}]>;
def simm16hi6 : ImmLeaf<i16, [{return isShiftedInt<6, 10>(Imm);}]>;

// Extract least significant 10 bits from an immediate value and sign extend
// them.
def LO10Sext : SDNodeXForm<imm, [{
  return CurDAG->getTargetConstant(SignExtend64<10>(N->getZExtValue()),
                                   SDLoc(N), N->getValueType(0));
}]>;

// Extract the most significant 6 bits from an immediate value. Add 1 if bit
// 9 is 1, to compensate for the low 10 bits in the matching immediate addi
// or ld/st being negative.
def HI6 : SDNodeXForm<imm, [{
  return CurDAG->getTargetConstant(((N->getZExtValue()+0x200) >> 10) & 0x3f,
                                   SDLoc(N), N->getValueType(0));
}]>;

// Addressing modes.
// Necessary because a frameindex can't be matched directly in a pattern.
def AddrFI : ComplexPattern<iPTR, 1, "SelectAddrFI", [frameindex], []>;

def IsOrAdd: PatFrag<(ops node:$A, node:$B), (or node:$A, node:$B), [{
  return isOrEquivalentToAdd(N);
}]>;

// Conditional code predicates - used for pattern matching for jump instructions
def CC_EQ  : PatLeaf<(i16 imm),
                     [{return (N->getZExtValue() == ISD::SETEQ);}]>;
def CC_NE  : PatLeaf<(i16 imm),
                     [{return (N->getZExtValue() == ISD::SETNE);}]>;
def CC_GE  : PatLeaf<(i16 imm),
                     [{return (N->getZExtValue() == ISD::SETGE);}]>;
def CC_GT  : PatLeaf<(i16 imm),
                     [{return (N->getZExtValue() == ISD::SETGT);}]>;
def CC_GTU : PatLeaf<(i16 imm),
                     [{return (N->getZExtValue() == ISD::SETUGT);}]>;
def CC_GEU : PatLeaf<(i16 imm),
                     [{return (N->getZExtValue() == ISD::SETUGE);}]>;
def CC_LE  : PatLeaf<(i16 imm),
                     [{return (N->getZExtValue() == ISD::SETLE);}]>;
def CC_LT  : PatLeaf<(i16 imm),
                     [{return (N->getZExtValue() == ISD::SETLT);}]>;
def CC_LTU : PatLeaf<(i16 imm),
                     [{return (N->getZExtValue() == ISD::SETULT);}]>;
def CC_LEU : PatLeaf<(i16 imm),
                         [{return (N->getZExtValue() == ISD::SETULE);}]>;

// 24-bit M-instructions.

let hasSideEffects = 0, mayLoad = 1, mayStore = 0 in {
  def LW  : CAHPInst24MLoad <0b010101, (outs GPR:$rd), (ins GPR:$rs, simm10:$imm),
                             "lw",  "$rd, ${imm}(${rs})">;
  def LB  : CAHPInst24MLoad <0b100101, (outs GPR:$rd), (ins GPR:$rs, simm10:$imm),
                             "lb",  "$rd, ${imm}(${rs})">;
  def LBU : CAHPInst24MLoad <0b000101, (outs GPR:$rd), (ins GPR:$rs, simm10:$imm),
                             "lbu", "$rd, ${imm}(${rs})">;
}

let hasSideEffects = 0, mayLoad = 0, mayStore = 1 in {
  def SW  : CAHPInst24MStore<0b011101, (outs), (ins GPR:$rs, GPR:$rd, simm10:$imm),
                            "sw",  "$rs, ${imm}(${rd})">;
  def SB  : CAHPInst24MStore<0b001101, (outs), (ins GPR:$rs, GPR:$rd, simm10:$imm),
                            "sb",  "$rs, ${imm}(${rd})">;
}

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isMoveImm = 1 in
def LI  : CAHPInst24MLoadI <0b110101, (outs GPR:$rd), (ins simm10:$imm),
                           "li", "$rd, $imm"> {
  let rs = 0;
}

// 24-bit R-instructions.

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {
  let isCommutable = 1 in {
    def ADD : CAHPInst24R<0b00000001, (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2),
                          "add", "$rd, $rs1, $rs2">;
    def AND : CAHPInst24R<0b00010001, (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2),
                          "and", "$rd, $rs1, $rs2">;
    def XOR : CAHPInst24R<0b00011001, (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2),
                          "xor", "$rd, $rs1, $rs2">;
    def OR  : CAHPInst24R<0b00100001, (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2),
                          "or",  "$rd, $rs1, $rs2">;
  }

  def SUB : CAHPInst24R<0b00001001, (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2),
                        "sub", "$rd, $rs1, $rs2">;
  def LSL : CAHPInst24R<0b00101001, (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2),
                        "lsl", "$rd, $rs1, $rs2">;
  def LSR : CAHPInst24R<0b00110001, (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2),
                        "lsr", "$rd, $rs1, $rs2">;
  def ASR : CAHPInst24R<0b00111001, (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2),
                        "asr", "$rd, $rs1, $rs2">;
}

// 24-bit I-instructions.

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {
  def ADDI : CAHPInst24I_10<0b000011, (outs GPR:$rd), (ins GPR:$rs1, simm10:$imm),
                         "addi", "$rd, $rs1, $imm">;
  def ANDI : CAHPInst24I_10<0b010011, (outs GPR:$rd), (ins GPR:$rs1, simm10:$imm),
                         "andi", "$rd, $rs1, $imm">;
  def XORI : CAHPInst24I_10<0b011011, (outs GPR:$rd), (ins GPR:$rs1, simm10:$imm),
                         "xori", "$rd, $rs1, $imm">;
  def ORI  : CAHPInst24I_10<0b100011, (outs GPR:$rd), (ins GPR:$rs1, simm10:$imm),
                         "ori",  "$rd, $rs1, $imm">;
  def LSLI : CAHPInst24I_4 <0b101011, (outs GPR:$rd), (ins GPR:$rs1, uimm4:$imm),
                         "lsli", "$rd, $rs1, $imm">;
  def LSRI : CAHPInst24I_4 <0b110011, (outs GPR:$rd), (ins GPR:$rs1, uimm4:$imm),
                         "lsri", "$rd, $rs1, $imm">;
  def ASRI : CAHPInst24I_4 <0b111011, (outs GPR:$rd), (ins GPR:$rs1, uimm4:$imm),
                         "asri", "$rd, $rs1, $imm">;
}

// 24-bit J-instructions.

let hasSideEffects = 0, mayLoad = 0, mayStore = 0,
    isBranch = 1, isTerminator = 1 in {
  def BEQ  : CAHPInst24J<0b001111, (ins GPR:$rs1, GPR:$rs2, simm10_branch:$imm),
                         "beq",  "$rs1, $rs2, $imm">;
  def BNE  : CAHPInst24J<0b101111, (ins GPR:$rs1, GPR:$rs2, simm10_branch:$imm),
                         "bne",  "$rs1, $rs2, $imm">;
  def BLT  : CAHPInst24J<0b110111, (ins GPR:$rs1, GPR:$rs2, simm10_branch:$imm),
                         "blt",  "$rs1, $rs2, $imm">;
  def BLTU : CAHPInst24J<0b010111, (ins GPR:$rs1, GPR:$rs2, simm10_branch:$imm),
                         "bltu", "$rs1, $rs2, $imm">;
  def BLE  : CAHPInst24J<0b111111, (ins GPR:$rs1, GPR:$rs2, simm10_branch:$imm),
                         "ble",  "$rs1, $rs2, $imm">;
  def BLEU : CAHPInst24J<0b011111, (ins GPR:$rs1, GPR:$rs2, simm10_branch:$imm),
                         "bleu", "$rs1, $rs2, $imm">;
}

// 16-bit M-instructions.

let hasSideEffects = 0, mayLoad = 1, mayStore = 0 in
def LWSP : CAHPInst16MLoad <0b010100, (outs GPR:$rd), (ins SP:$rs, uimm7_lsb0:$imm),
                           "lwsp", "$rd, ${imm}(${rs})"> {
  bits<7> imm;
  let Inst{15-12} = imm{4-1};
  let Inst{7-6} = imm{6-5};
}

let hasSideEffects = 0, mayLoad = 0, mayStore = 1 in
def SWSP : CAHPInst16MStore<0b011100, (outs), (ins GPR:$rs, SP:$rd, uimm7_lsb0:$imm),
                           "swsp", "$rs, ${imm}(${rd})"> {
  bits<7> imm;
  let Inst{15-12} = imm{4-1};
  let Inst{7-6} = imm{6-5};
}

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isMoveImm = 1 in
def LSI  : CAHPInst16MLoadI <0b110100, (outs GPR:$rd), (ins simm6:$imm),
                           "lsi",  "$rd, $imm"> {
  bits<6> imm;
  let Inst{15-12} = imm{3-0};
  let Inst{7-6} = imm{5-4};
}

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isMoveImm = 1 in
def LUI  : CAHPInst16MLoadI <0b000100, (outs GPR:$rd), (ins simm6:$imm),
                           "lui",  "$rd, $imm"> {
  bits<6> imm;
  let Inst{15-12} = imm{3-0};
  let Inst{7-6} = imm{5-4};
}

// 16-bit R-instructions.

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isMoveReg = 1 in
def MOV  : CAHPInst16R<0b11000000, (outs GPR:$rd), (ins GPR:$rs),
                      "mov",  "$rd, $rs">;

let hasSideEffects = 0, mayLoad = 0, mayStore = 0,
    Constraints = "$rd = $rd_w" in {
  let isCommutable = 1 in {
    def ADD2 : CAHPInst16R<0b10000000, (outs GPR:$rd_w), (ins GPR:$rd, GPR:$rs),
                          "add2", "$rd, $rs">;
    def AND2 : CAHPInst16R<0b10010000, (outs GPR:$rd_w), (ins GPR:$rd, GPR:$rs),
                          "and2", "$rd, $rs">;
    def XOR2 : CAHPInst16R<0b10011000, (outs GPR:$rd_w), (ins GPR:$rd, GPR:$rs),
                          "xor2", "$rd, $rs">;
    def OR2  : CAHPInst16R<0b10100000, (outs GPR:$rd_w), (ins GPR:$rd, GPR:$rs),
                          "or2",  "$rd, $rs">;
  }

  def SUB2 : CAHPInst16R<0b10001000, (outs GPR:$rd_w), (ins GPR:$rd, GPR:$rs),
                        "sub2", "$rd, $rs">;
  def LSL2 : CAHPInst16R<0b10101000, (outs GPR:$rd_w), (ins GPR:$rd, GPR:$rs),
                        "lsl2", "$rd, $rs">;
  def LSR2 : CAHPInst16R<0b10110000, (outs GPR:$rd_w), (ins GPR:$rd, GPR:$rs),
                        "lsr2", "$rd, $rs">;
  def ASR2 : CAHPInst16R<0b10111000, (outs GPR:$rd_w), (ins GPR:$rd, GPR:$rs),
                        "asr2", "$rd, $rs">;
}

// 16-bit I-instructions.

let hasSideEffects = 0, mayLoad = 0, mayStore = 0,
    Constraints = "$rd = $rd_w" in {
  def LSLI2 : CAHPInst16I_4<0b101010, (outs GPR:$rd_w), (ins GPR:$rd, uimm4:$imm),
                          "lsli2", "$rd, $imm">;
  def LSRI2 : CAHPInst16I_4<0b110010, (outs GPR:$rd_w), (ins GPR:$rd, uimm4:$imm),
                          "lsri2", "$rd, $imm">;
  def ASRI2 : CAHPInst16I_4<0b111010, (outs GPR:$rd_w), (ins GPR:$rd, uimm4:$imm),
                          "asri2", "$rd, $imm">;
  def ADDI2 : CAHPInst16I_6<0b000010, (outs GPR:$rd_w), (ins GPR:$rd, simm6:$imm),
                          "addi2", "$rd, $imm">;
  def ANDI2 : CAHPInst16I_6<0b010010, (outs GPR:$rd_w), (ins GPR:$rd, simm6:$imm),
                          "andi2", "$rd, $imm">;
}

// 16-bit J-instructions.

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {
  let isCall = 1, Defs = [/* RA */ X0] in
  def JALR : CAHPInst16JR<0b10110, (ins GPR:$rs),     "jalr", "$rs">;

  let isBranch = 1, isBarrier = 1, isTerminator = 1, isIndirectBranch = 1 in
  def JR   : CAHPInst16JR<0b00110, (ins GPR:$rs),     "jr",   "$rs">;

  let isBranch = 1, isTerminator = 1, isBarrier = 1 in
  def JS   : CAHPInst16JI<0b01110, (ins simm11_branch:$imm), "js", "$imm">;

  let isCall = 1, Defs = [/* RA */ X0] in
  def JSAL : CAHPInst16JI<0b11110, (ins simm11:$imm), "jsal", "$imm">;
}

// Others.

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def NOP : CAHPInst16<(outs), (ins), "nop", ""> {
  let Inst = 0;
}

let isBarrier = 1, isReturn = 1, isTerminator = 1 in
def PseudoRET : Pseudo<(outs), (ins), [(RetFlag)]>,
                PseudoInstExpansion<(JR X0)>;

// Pessimistically assume the stack pointer will be clobbered
let Defs = [/* SP */ X1], Uses = [/* SP */ X1] in {
def ADJCALLSTACKDOWN : Pseudo<(outs), (ins i16imm:$amt1, i16imm:$amt2),
                              [(CallSeqStart timm:$amt1, timm:$amt2)]>;
def ADJCALLSTACKUP   : Pseudo<(outs), (ins i16imm:$amt1, i16imm:$amt2),
                              [(CallSeqEnd timm:$amt1, timm:$amt2)]>;
} // Defs = [X1], Uses = [X1]

let usesCustomInserter = 1 in
def Select_GPR_Using_CC_GPR
    : Pseudo<(outs GPR:$dst),
             (ins GPR:$lhs, GPR:$rhs, i16imm:$imm, GPR:$src, GPR:$src2),
             [(set i16:$dst, (SelectCC GPR:$lhs, GPR:$rhs,
              (i16 imm:$imm), GPR:$src, GPR:$src2))]>;

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCodeGenOnly = 0 in
def PseudoHLT : Pseudo16<(outs), (ins), []> {
  let AsmString = "hlt";
}

// Codegen patterns.

/// FrameIndex calculations
def : Pat<(add     (i16 AddrFI:$Rs), simm10:$imm),
          (ADDI    (i16 AddrFI:$Rs), simm10:$imm)>;
def : Pat<(IsOrAdd (i16 AddrFI:$Rs), simm10:$imm),
          (ADDI    (i16 AddrFI:$Rs), simm10:$imm)>;

def : Pat<(simm6:$imm), (LSI simm6:$imm)>;
def : Pat<(simm10:$imm), (LI simm10:$imm)>;
def : Pat<(simm16hi6:$imm), (LUI (HI6 imm:$imm))>;
def : Pat<(simm16:$imm), (ADDI (LUI (HI6 imm:$imm)), (LO10Sext imm:$imm))>;

multiclass LdPat<PatFrag LoadOp, CAHPInst Inst> {
  def : Pat<(LoadOp GPR:$rs1), (Inst GPR:$rs1, 0)>;
  def : Pat<(LoadOp AddrFI:$rs1), (LW AddrFI:$rs1, 0)>;
  def : Pat<(LoadOp (add GPR:$rs1, simm10:$imm)),
            (Inst GPR:$rs1, simm10:$imm)>;
  def : Pat<(LoadOp (add AddrFI:$rs1, simm10:$imm)),
            (Inst AddrFI:$rs1, simm10:$imm)>;
  def : Pat<(LoadOp (IsOrAdd AddrFI:$rs1, simm10:$imm)),
            (Inst AddrFI:$rs1, simm10:$imm)>;
}
defm : LdPat<load, LW>;
defm : LdPat<extloadi8,  LB>;
defm : LdPat<sextloadi8, LB>;
defm : LdPat<zextloadi8, LBU>;

multiclass StPat<PatFrag StoreOp, CAHPInst Inst> {
  def : Pat<(StoreOp GPR:$rs, GPR:$rd), (Inst GPR:$rs, GPR:$rd, 0)>;
  def : Pat<(StoreOp GPR:$rs, AddrFI:$rd), (Inst GPR:$rs, AddrFI:$rd, 0)>;
  def : Pat<(StoreOp GPR:$rs, (add GPR:$rd, simm10:$imm)),
            (Inst    GPR:$rs, GPR:$rd, simm10:$imm)>;
  def : Pat<(StoreOp GPR:$rs, (add AddrFI:$rd, simm10:$imm)),
            (Inst    GPR:$rs, AddrFI:$rd, simm10:$imm)>;
  def : Pat<(StoreOp GPR:$rs, (IsOrAdd AddrFI:$rd, simm10:$imm)),
            (Inst    GPR:$rs, AddrFI:$rd, simm10:$imm)>;
}
defm : StPat<store, SW>;
defm : StPat<truncstorei8, SB>;

def : Pat<(add GPR:$rs1, GPR:$rs2), (ADD GPR:$rs1, GPR:$rs2)>;
def : Pat<(sub GPR:$rs1, GPR:$rs2), (SUB GPR:$rs1, GPR:$rs2)>;
def : Pat<(and GPR:$rs1, GPR:$rs2), (AND GPR:$rs1, GPR:$rs2)>;
def : Pat<(xor GPR:$rs1, GPR:$rs2), (XOR GPR:$rs1, GPR:$rs2)>;
def : Pat<(or  GPR:$rs1, GPR:$rs2), (OR  GPR:$rs1, GPR:$rs2)>;
def : Pat<(shl GPR:$rs1, GPR:$rs2), (LSL GPR:$rs1, GPR:$rs2)>;
def : Pat<(srl GPR:$rs1, GPR:$rs2), (LSR GPR:$rs1, GPR:$rs2)>;
def : Pat<(sra GPR:$rs1, GPR:$rs2), (ASR GPR:$rs1, GPR:$rs2)>;

def : Pat<(add GPR:$rs1, simm10:$imm), (ADDI GPR:$rs1, simm10:$imm)>;
def : Pat<(and GPR:$rs1, simm10:$imm), (ANDI GPR:$rs1, simm10:$imm)>;
def : Pat<(xor GPR:$rs1, simm10:$imm), (XORI GPR:$rs1, simm10:$imm)>;
def : Pat<(or  GPR:$rs1, simm10:$imm), (ORI  GPR:$rs1, simm10:$imm)>;
def : Pat<(shl GPR:$rs1, uimm4:$imm),  (LSLI GPR:$rs1, uimm4:$imm)>;
def : Pat<(srl GPR:$rs1, uimm4:$imm),  (LSRI GPR:$rs1, uimm4:$imm)>;
def : Pat<(sra GPR:$rs1, uimm4:$imm),  (ASRI GPR:$rs1, uimm4:$imm)>;

// Match `(brcond (CondOp ..), ..)` and lower to the appropriate CAHP branch
// instruction.
class BccPat<PatLeaf Cond, CAHPInst Inst>
    : Pat<(BrCC GPR:$rs1, GPR:$rs2, Cond, bb:$imm),
          (Inst GPR:$rs1, GPR:$rs2, simm10_branch:$imm)>;
def : BccPat<CC_EQ, BEQ>;
def : BccPat<CC_NE, BNE>;
def : BccPat<CC_LT, BLT>;
def : BccPat<CC_LE, BLE>;
def : BccPat<CC_LTU, BLTU>;
def : BccPat<CC_LEU, BLEU>;

class BccSwapPat<PatLeaf Cond, CAHPInst Inst>
    : Pat<(BrCC GPR:$rs1, GPR:$rs2, Cond, bb:$imm),
          (Inst GPR:$rs2, GPR:$rs1, bb:$imm)>;
// Condition codes that don't have matching CAHP branch instructions, but
// are trivially supported by swapping the two input operands
def : BccSwapPat<CC_GT, BLT>;
def : BccSwapPat<CC_GE, BLE>;
def : BccSwapPat<CC_GTU, BLTU>;
def : BccSwapPat<CC_GEU, BLEU>;

// An extra pattern is needed for a brcond without a setcc (i.e. where the
// condition was calculated elsewhere).
def : Pat<(brcond GPR:$cond, bb:$imm), (BNE GPR:$cond, (LSI 0), bb:$imm)>;

def : Pat<(br bb:$imm), (JS simm11_branch:$imm)>;
def : Pat<(Call GPR:$rs), (JALR GPR:$rs)>;
def : Pat<(Call tglobaladdr:$dst), (JSAL tglobaladdr:$dst)>;
def : Pat<(Call texternalsym:$dst), (JSAL texternalsym:$dst)>;

// Compress patterns

class CompressPat<dag input, dag output> {
  dag Input  = input;
  dag Output    = output;
  list<Predicate> Predicates = [];
}

multiclass CompPatRRRComm<CAHPInst24 Inst24, CAHPInst16 Inst16> {
  def : CompressPat<(Inst24 GPR:$rs1, GPR:$rs1, GPR:$rs2),
                    (Inst16 GPR:$rs1, GPR:$rs2)>;
  def : CompressPat<(Inst24 GPR:$rs1, GPR:$rs2, GPR:$rs1),
                    (Inst16 GPR:$rs1, GPR:$rs2)>;
}
defm : CompPatRRRComm<ADD, ADD2>;
defm : CompPatRRRComm<AND, AND2>;
defm : CompPatRRRComm<XOR, XOR2>;
defm : CompPatRRRComm<OR,  OR2>;

class CompPatRRRNonComm<CAHPInst24 Inst24, CAHPInst16 Inst16>
  : CompressPat<(Inst24 GPR:$rs1, GPR:$rs1, GPR:$rs2),
                (Inst16 GPR:$rs1, GPR:$rs2)> {
}
def : CompPatRRRNonComm<SUB, SUB2>;
def : CompPatRRRNonComm<LSL, LSL2>;
def : CompPatRRRNonComm<LSR, LSR2>;
def : CompPatRRRNonComm<ASR, ASR2>;

def : CompressPat<(LSLI GPR:$rs1, GPR:$rs1, uimm4:$imm), (LSLI2 GPR:$rs1, uimm4:$imm)>;
def : CompressPat<(LSRI GPR:$rs1, GPR:$rs1, uimm4:$imm), (LSRI2 GPR:$rs1, uimm4:$imm)>;
def : CompressPat<(ASRI GPR:$rs1, GPR:$rs1, uimm4:$imm), (ASRI2 GPR:$rs1, uimm4:$imm)>;
def : CompressPat<(ADDI GPR:$rs1, GPR:$rs1, simm6:$imm), (ADDI2 GPR:$rs1, simm6:$imm)>;
def : CompressPat<(ANDI GPR:$rs1, GPR:$rs1, simm6:$imm), (ANDI2 GPR:$rs1, simm6:$imm)>;

def : CompressPat<(LW   GPR:$rd, SP:$rs, uimm7_lsb0:$imm),
                  (LWSP GPR:$rd, SP:$rs, uimm7_lsb0:$imm)>;
def : CompressPat<(SW   GPR:$rd, SP:$rs, uimm7_lsb0:$imm),
                  (SWSP GPR:$rd, SP:$rs, uimm7_lsb0:$imm)>;
