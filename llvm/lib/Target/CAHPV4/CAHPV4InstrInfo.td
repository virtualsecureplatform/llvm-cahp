// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

include "CAHPV4InstrFormats.td"

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

def uimm4 : Operand<i16> {
  let ParserMatchClass = UImmAsmOperand<4>;
}

def simm11 : Operand<i16> {
  let ParserMatchClass = SImmAsmOperand<11>;
}

def simm16 : Operand<i16> {
  let ParserMatchClass = SImmAsmOperand<16>;
}

// R-instructions
def ADD  : CAHPV4InstR<0b00000001000, (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2),
                       "add", "$rd, $rs1, $rs2">;
def SUB  : CAHPV4InstR<0b00000011000, (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2),
                       "sub", "$rd, $rs1, $rs2">;
def XOR  : CAHPV4InstR<0b00000101000, (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2),
                       "xor", "$rd, $rs1, $rs2">;
def OR   : CAHPV4InstR<0b00000111000, (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2),
                       "or",  "$rd, $rs1, $rs2">;
def AND  : CAHPV4InstR<0b00001001000, (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2),
                       "and", "$rd, $rs1, $rs2">;
def SLL  : CAHPV4InstR<0b00010011000, (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2),
                       "sll", "$rd, $rs1, $rs2">;
def SRL  : CAHPV4InstR<0b00010101000, (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2),
                       "srl", "$rd, $rs1, $rs2">;
def SRA  : CAHPV4InstR<0b00011001000, (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2),
                       "sra", "$rd, $rs1, $rs2">;
def SLT  : CAHPV4InstR<0b10100011000, (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2),
                      "slt", "$rd, $rs1, $rs2">;
def SLTU : CAHPV4InstR<0b00100001000, (outs GPR:$rd), (ins GPR:$rs1, GPR:$rs2),
                      "sltu", "$rd, $rs1, $rs2">;

// I-instructions
def ADDI : CAHPV4InstIS11<0b01000001000, (outs GPR:$rd), (ins GPR:$rs1, simm11:$imm),
                          "addi", "$rd, $rs1, $imm">;
def XORI : CAHPV4InstIS11<0b01000101000, (outs GPR:$rd), (ins GPR:$rs1, simm11:$imm),
                          "xori", "$rd, $rs1, $imm">;
def ORI  : CAHPV4InstIS11<0b01000111000, (outs GPR:$rd), (ins GPR:$rs1, simm11:$imm),
                          "ori", "$rd, $rs1, $imm">;
def ANDI : CAHPV4InstIS11<0b01001001000, (outs GPR:$rd), (ins GPR:$rs1, simm11:$imm),
                          "andi", "$rd, $rs1, $imm">;
def SLLI : CAHPV4InstIU4<0b01010011000, (outs GPR:$rd), (ins GPR:$rs1, uimm4:$imm),
                         "slli", "$rd, $rs1, $imm">;
def SRLI : CAHPV4InstIU4<0b01010101000, (outs GPR:$rd), (ins GPR:$rs1, uimm4:$imm),
                         "srli", "$rd, $rs1, $imm">;
def SRAI : CAHPV4InstIU4<0b01011001000, (outs GPR:$rd), (ins GPR:$rs1, uimm4:$imm),
                         "srai", "$rd, $rs1, $imm">;
def SLTI : CAHPV4InstIS11<0b11100011000, (outs GPR:$rd), (ins GPR:$rs1, simm11:$imm),
                          "slti", "$rd, $rs1, $imm">;
// FIXME: SLTIU
def LI   : CAHPV4InstI16<0b11001111000, (outs GPR:$rd), (ins simm16:$imm),
                         "li", "$rd, $imm">;
