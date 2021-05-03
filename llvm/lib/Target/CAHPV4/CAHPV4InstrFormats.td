// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

// Base format
class CAHPV4Inst<dag outs, dag ins, string opcodestr, string argstr, list<dag> pattern = []>
: Instruction {
  let Namespace = "CAHPV4";

  dag OutOperandList = outs;
  dag InOperandList = ins;

  let AsmString = opcodestr # "\t" # argstr;

  // Matching patterns used when converting SelectionDAG into MachineDAG.
  let Pattern = pattern;

  let Size = 4;
  bits<32> Inst;
}

// Pseudo instructions
class Pseudo<dag outs, dag ins, list<dag> pattern>
: CAHPV4Inst<outs, ins, "", "", pattern> {
  let isPseudo = 1;
  let isCodeGenOnly = 1;
}

// R-instruction format
class CAHPV4InstR<bits<11> opcode, dag outs, dag ins, string opcodestr, string argstr>
: CAHPV4Inst<outs, ins, opcodestr, argstr> {
  bits<5> rd;
  bits<5> rs1;
  bits<5> rs2;

  let Inst{31-26} = 0;
  let Inst{25-21} = rs2;
  let Inst{20-16} = rd;
  let Inst{15-11} = rs1;
  let Inst{10-0} = opcode;
}

// I-instruction format
class CAHPV4InstIS11<bits<11> opcode, dag outs, dag ins, string opcodestr, string argstr>
: CAHPV4Inst<outs, ins, opcodestr, argstr> {
  bits<5> rd;
  bits<5> rs1;
  bits<11> imm;

  let Inst{31-21} = imm;
  let Inst{20-16} = rd;
  let Inst{15-11} = rs1;
  let Inst{10-0} = opcode;
}
class CAHPV4InstIU4<bits<11> opcode, dag outs, dag ins, string opcodestr, string argstr>
: CAHPV4Inst<outs, ins, opcodestr, argstr> {
  bits<5> rd;
  bits<5> rs1;
  bits<4> imm;

  let Inst{31-25} = 0;
  let Inst{24-21} = imm;
  let Inst{20-16} = rd;
  let Inst{15-11} = rs1;
  let Inst{10-0} = opcode;
}
class CAHPV4InstI16<bits<11> opcode, dag outs, dag ins, string opcodestr, string argstr>
: CAHPV4Inst<outs, ins, opcodestr, argstr> {
  bits<5> rd;
  bits<16> imm;

  let Inst{31} = imm{15};
  let Inst{30-21} = imm{9-0};
  let Inst{20-16} = rd;
  let Inst{15-11} = imm{14-10};
  let Inst{10-0} = opcode;
}
