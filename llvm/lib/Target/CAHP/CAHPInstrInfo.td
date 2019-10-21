// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

include "CAHPInstrFormats.td"

def RetFlag : SDNode<"CAHPISD::RET_FLAG", SDTNone,
                     [SDNPHasChain, SDNPOptInGlue, SDNPVariadic]>;

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

def uimm4 : Operand<i16>, ImmLeaf<i16, [{return isUInt<16>(Imm);}]> {
  let ParserMatchClass = UImmAsmOperand<4>;
  let DecoderMethod = "decodeUImmOperand<4>";
  let EncoderMethod = "getImmOpValue";
}

def simm6 : Operand<i16> {
  let ParserMatchClass = SImmAsmOperand<6>;
  let DecoderMethod = "decodeSImmOperand<6>";
  let EncoderMethod = "getImmOpValue";
}

def simm10 : Operand<i16>, ImmLeaf<i16, [{return isInt<16>(Imm);}]> {
  let ParserMatchClass = SImmAsmOperand<10>;
  let DecoderMethod = "decodeSImmOperand<10>";
  let EncoderMethod = "getImmOpValue";
}

def simm11 : Operand<i16> {
  let ParserMatchClass = SImmAsmOperand<11>;
  let DecoderMethod = "decodeSImmOperand<11>";
  let EncoderMethod = "getImmOpValue";
}

def uimm7_lsb0 : Operand<i16> {
  let ParserMatchClass = UImmAsmOperand<7, "Lsb0">;
  let DecoderMethod = "decodeUImmOperand<7>";
  let EncoderMethod = "getImmOpValue";
}

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
  def SW  : CAHPInst24MStore<0b011101, (outs GPR:$rd), (ins GPR:$rs, simm10:$imm),
                            "sw",  "$rs, ${imm}(${rd})">;
  def SB  : CAHPInst24MStore<0b001101, (outs GPR:$rd), (ins GPR:$rs, simm10:$imm),
                            "sb",  "$rs, ${imm}(${rd})">;
}

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isMoveImm = 1 in
def LI  : CAHPInst24MLoad <0b110101, (outs GPR:$rd), (ins simm10:$imm),
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
  def ADDI : CAHPInst24I<0b000011, (outs GPR:$rd), (ins GPR:$rs1, simm10:$imm),
                         "addi", "$rd, $rs1, $imm">;
  def ANDI : CAHPInst24I<0b010011, (outs GPR:$rd), (ins GPR:$rs1, simm10:$imm),
                         "andi", "$rd, $rs1, $imm">;
  def XORI : CAHPInst24I<0b011011, (outs GPR:$rd), (ins GPR:$rs1, simm10:$imm),
                         "xori", "$rd, $rs1, $imm">;
  def ORI  : CAHPInst24I<0b100011, (outs GPR:$rd), (ins GPR:$rs1, simm10:$imm),
                         "ori",  "$rd, $rs1, $imm">;
  def LSLI : CAHPInst24I<0b101011, (outs GPR:$rd), (ins GPR:$rs1, uimm4:$imm),
                         "lsli", "$rd, $rs1, $imm">;
  def LSRI : CAHPInst24I<0b110011, (outs GPR:$rd), (ins GPR:$rs1, uimm4:$imm),
                         "lsri", "$rd, $rs1, $imm">;
  def ASRI : CAHPInst24I<0b111011, (outs GPR:$rd), (ins GPR:$rs1, uimm4:$imm),
                         "asri", "$rd, $rs1, $imm">;
}

// 24-bit J-instructions.

let hasSideEffects = 0, mayLoad = 0, mayStore = 0,
    isBranch = 1, isTerminator = 1 in {
  def BEQ  : CAHPInst24J<0b001111, (ins GPR:$rs1, GPR:$rs2, simm10:$imm),
                         "beq",  "$rs1, $rs2, $imm">;
  def BNE  : CAHPInst24J<0b101111, (ins GPR:$rs1, GPR:$rs2, simm10:$imm),
                         "bne",  "$rs1, $rs2, $imm">;
  def BLT  : CAHPInst24J<0b110111, (ins GPR:$rs1, GPR:$rs2, simm10:$imm),
                         "blt",  "$rs1, $rs2, $imm">;
  def BLTU : CAHPInst24J<0b010111, (ins GPR:$rs1, GPR:$rs2, simm10:$imm),
                         "bltu", "$rs1, $rs2, $imm">;
  def BLE  : CAHPInst24J<0b111111, (ins GPR:$rs1, GPR:$rs2, simm10:$imm),
                         "ble",  "$rs1, $rs2, $imm">;
  def BLEU : CAHPInst24J<0b011111, (ins GPR:$rs1, GPR:$rs2, simm10:$imm),
                         "bleu", "$rs1, $rs2, $imm">;
}

// 16-bit M-instructions.

let hasSideEffects = 0, mayLoad = 1, mayStore = 0 in
def LWSP : CAHPInst16Load <0b010100, (outs GPR:$rd), (ins SP:$rs, uimm7_lsb0:$imm),
                           "lwsp", "$rd, ${imm}(${rs})"> {
  bits<7> imm;
  let Inst{15-12} = imm{4-1};
  let Inst{7-6} = imm{6-5};
}

let hasSideEffects = 0, mayLoad = 0, mayStore = 1 in
def SWSP : CAHPInst16Store<0b011100, (outs), (ins GPR:$rs, SP:$rd, uimm7_lsb0:$imm),
                           "swsp", "$rs, ${imm}(${rd})"> {
  bits<7> imm;
  let Inst{15-12} = imm{4-1};
  let Inst{7-6} = imm{6-5};
}

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isMoveImm = 1 in
def LSI  : CAHPInst16Load <0b110100, (outs GPR:$rd), (ins simm6:$imm),
                           "lsi",  "$rd, $imm"> {
  bits<6> imm;
  let Inst{15-12} = imm{3-0};
  let Inst{7-6} = imm{5-4};
}

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isMoveImm = 1 in
def LUI  : CAHPInst16Load <0b000100, (outs GPR:$rd), (ins simm6:$imm),
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
  def LSLI2 : CAHPInst16I<0b101010, (outs GPR:$rd_w), (ins GPR:$rd, uimm4:$imm),
                          "lsli2", "$rd, $imm">;
  def LSRI2 : CAHPInst16I<0b110010, (outs GPR:$rd_w), (ins GPR:$rd, uimm4:$imm),
                          "lsri2", "$rd, $imm">;
  def ASRI2 : CAHPInst16I<0b111010, (outs GPR:$rd_w), (ins GPR:$rd, uimm4:$imm),
                          "asri2", "$rd, $imm">;
  def ADDI2 : CAHPInst16I<0b000010, (outs GPR:$rd_w), (ins GPR:$rd, simm6:$imm),
                          "addi2", "$rd, $imm">;
  def ANDI2 : CAHPInst16I<0b010010, (outs GPR:$rd_w), (ins GPR:$rd, simm6:$imm),
                          "andi2", "$rd, $imm">;
}

// 16-bit J-instructions.

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {
  let isCall = 1, Defs = [X0] in
  def JALR : CAHPInst16JR<0b10110, (ins GPR:$rs),     "jalr", "$rs">;

  let isBranch = 1, isBarrier = 1, isTerminator = 1, isIndirectBranch = 1 in
  def JR   : CAHPInst16JR<0b00110, (ins GPR:$rs),     "jr",   "$rs">;

  let isBranch = 1, isTerminator = 1, isBarrier = 1 in
  def JS   : CAHPInst16JI<0b01110, (ins simm11:$imm), "js",   "$imm">;

  let isCall = 1, Defs = [X0] in
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

// Codegen patterns.

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
