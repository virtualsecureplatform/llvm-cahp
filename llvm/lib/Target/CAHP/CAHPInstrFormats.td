// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

class CAHPInst<dag outs, dag ins, string opcodestr, string argstr, list<dag> pattern = []>
: Instruction {
  // SoftFail is a field the disassembler can use to provide a way for
  // instructions to not match without killing the whole decode process. It is
  // mainly used for ARM, but Tablegen expects this field to exist or it fails
  // to build the decode table.
  bits<32> SoftFail = 0;

  let Namespace = "CAHP";

  dag OutOperandList = outs;
  dag InOperandList = ins;

  let AsmString = opcodestr # "\t" # argstr;

  // Matching patterns used when converting SelectionDAG into MachineDAG.
  let Pattern = pattern;
}

// 16-bit instruction format.
class CAHPInst16<dag outs, dag ins, string opcodestr, string argstr, list<dag> pattern = []>
: CAHPInst<outs, ins, opcodestr, argstr, pattern> {
  let Size = 2;
  bits<16> Inst;
}

// 24-bit instruction format.
class CAHPInst24<dag outs, dag ins, string opcodestr, string argstr, list<dag> pattern = []>
: CAHPInst<outs, ins, opcodestr, argstr, pattern> {
  let Size = 3;
  bits<24> Inst;
}

// Pseudo instructions
class Pseudo<dag outs, dag ins, list<dag> pattern>
: CAHPInst<outs, ins, "", "", pattern> {
  let isPseudo = 1;
  let isCodeGenOnly = 1;
}

class Pseudo16<dag outs, dag ins, list<dag> pattern>
: Pseudo<outs, ins, pattern> {
  let Size = 2;
}

class Pseudo24<dag outs, dag ins, list<dag> pattern>
: Pseudo<outs, ins, pattern> {
  let Size = 3;
}

// 24-bit M-instruction format.
class CAHPInst24MLoad<bits<6> opcode, dag outs, dag ins, string opcodestr, string argstr>
: CAHPInst24<outs, ins, opcodestr, argstr>, Sched<[WriteLDST]> {
  bits<4> rd;
  bits<4> rs;
  bits<10> imm;

  let Inst{23-16} = imm{7-0};
  let Inst{15-12} = rs;
  let Inst{11-8} = rd;
  let Inst{7-6} = imm{9-8};
  let Inst{5-0} = opcode;
}

class CAHPInst24MLoadI<bits<6> opcode, dag outs, dag ins, string opcodestr, string argstr>
: CAHPInst24<outs, ins, opcodestr, argstr>, Sched<[WriteALU]> {
  bits<4> rd;
  bits<4> rs;
  bits<10> imm;

  let Inst{23-16} = imm{7-0};
  let Inst{15-12} = rs;
  let Inst{11-8} = rd;
  let Inst{7-6} = imm{9-8};
  let Inst{5-0} = opcode;
}

class CAHPInst24MStore<bits<6> opcode, dag outs, dag ins, string opcodestr, string argstr>
: CAHPInst24<outs, ins, opcodestr, argstr>, Sched<[WriteLDST]> {
  bits<4> rs;
  bits<4> rd;
  bits<10> imm;

  let Inst{23-16} = imm{7-0};
  let Inst{15-12} = rd;
  let Inst{11-8} = rs;
  let Inst{7-6} = imm{9-8};
  let Inst{5-0} = opcode;
}

// 24-bit R-instruction format.
class CAHPInst24R<bits<8> opcode, dag outs, dag ins, string opcodestr, string argstr>
: CAHPInst24<outs, ins, opcodestr, argstr>, Sched<[WriteALU]> {
  bits<4> rd;
  bits<4> rs1;
  bits<4> rs2;

  let Inst{23-20} = 0;
  let Inst{19-16} = rs2;
  let Inst{15-12} = rs1;
  let Inst{11-8} = rd;
  let Inst{7-0} = opcode;
}

// 24-bit I-instruction format for 10bit immediate.
class CAHPInst24I_10<bits<6> opcode, dag outs, dag ins, string opcodestr, string argstr>
: CAHPInst24<outs, ins, opcodestr, argstr>, Sched<[WriteALU]> {
  bits<4> rd;
  bits<4> rs1;
  bits<10> imm;

  let Inst{23-16} = imm{7-0};
  let Inst{15-12} = rs1;
  let Inst{11-8} = rd;
  let Inst{7-6} = imm{9-8};
  let Inst{5-0} = opcode;
}

// 24-bit I-instruction format for 4bit immediate.
class CAHPInst24I_4<bits<6> opcode, dag outs, dag ins, string opcodestr, string argstr>
: CAHPInst24<outs, ins, opcodestr, argstr>, Sched<[WriteALU]> {
  bits<4> rd;
  bits<4> rs1;
  bits<4> imm;

  let Inst{23-20} = 0;
  let Inst{19-16} = imm{3-0};
  let Inst{15-12} = rs1;
  let Inst{11-8} = rd;
  let Inst{7-6} = 0;
  let Inst{5-0} = opcode;
}

// 24-bit J-instruction format.
class CAHPInst24J<bits<6> opcode, dag ins, string opcodestr, string argstr>
: CAHPInst24<(outs), ins, opcodestr, argstr> {
  bits<4> rs1;
  bits<4> rs2;
  bits<10> imm;

  let Inst{23-16} = imm{7-0};
  let Inst{15-12} = rs1;
  let Inst{11-8} = rs2;
  let Inst{7-6} = imm{9-8};
  let Inst{5-0} = opcode;
}

// 16-bit M-instruction format.
class CAHPInst16MLoad<bits<6> opcode, dag outs, dag ins, string opcodestr, string argstr>
: CAHPInst16<outs, ins, opcodestr, argstr>, Sched<[WriteLDST]> {
  bits<4> rd;

  let Inst{11-8} = rd;
  let Inst{5-0} = opcode;
}

class CAHPInst16MLoadI<bits<6> opcode, dag outs, dag ins, string opcodestr, string argstr>
: CAHPInst16<outs, ins, opcodestr, argstr>, Sched<[WriteALU]> {
  bits<4> rd;

  let Inst{11-8} = rd;
  let Inst{5-0} = opcode;
}

class CAHPInst16MStore<bits<6> opcode, dag outs, dag ins, string opcodestr, string argstr>
: CAHPInst16<outs, ins, opcodestr, argstr>, Sched<[WriteLDST]> {
  bits<4> rs;

  let Inst{11-8} = rs;
  let Inst{5-0} = opcode;
}

// 16-bit R-instruction format.
class CAHPInst16R<bits<8> opcode, dag outs, dag ins, string opcodestr, string argstr>
: CAHPInst16<outs, ins, opcodestr, argstr>, Sched<[WriteALU]> {
  bits<4> rd;
  bits<4> rs;

  let Inst{15-12} = rs;
  let Inst{11-8} = rd;
  let Inst{7-0} = opcode;
}

// 16-bit I-instruction format for 6bit immediate.
class CAHPInst16I_6<bits<6> opcode, dag outs, dag ins, string opcodestr, string argstr>
: CAHPInst16<outs, ins, opcodestr, argstr>, Sched<[WriteALU]> {
  bits<4> rd;
  bits<6> imm;

  let Inst{15-12} = imm{3-0};
  let Inst{11-8} = rd;
  let Inst{7-6} = imm{5-4};
  let Inst{5-0} = opcode;
}

// 16-bit I-instruction format for 4bit immediate.
class CAHPInst16I_4<bits<6> opcode, dag outs, dag ins, string opcodestr, string argstr>
: CAHPInst16<outs, ins, opcodestr, argstr>, Sched<[WriteALU]> {
  bits<4> rd;
  bits<4> imm;

  let Inst{15-12} = imm{3-0};
  let Inst{11-8} = rd;
  let Inst{7-6} = 0;
  let Inst{5-0} = opcode;
}

// 16-bit J-instruction format.
class CAHPInst16JR<bits<5> opcode, dag ins, string opcodestr, string argstr>
: CAHPInst16<(outs), ins, opcodestr, argstr> {
  bits<4> rs;

  let Inst{15-12} = 0;
  let Inst{11-8} = rs;
  let Inst{7-5} = 0;
  let Inst{4-0} = opcode;
}

class CAHPInst16JI<bits<5> opcode, dag ins, string opcodestr, string argstr>
: CAHPInst16<(outs), ins, opcodestr, argstr> {
  bits<11> imm;

  let Inst{15-5} = imm;
  let Inst{4-0} = opcode;
}
