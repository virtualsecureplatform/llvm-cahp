// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

include "CAHPV4InstrFormats.td"

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
