// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

let Namespace = "CAHP" in {
  def ABIRegAltName : RegAltNameIndex;

  class CAHPReg<bits<4> Enc, string n, list<string> alt = []> : Register<n> {
    let HWEncoding{3-0} = Enc;
    let AltNames = alt;
    let RegAltNameIndices = [ABIRegAltName];
  }
} // Namespace = "CAHP"

// Integer registers
def X0  : CAHPReg<0, "x0", ["ra"]>, DwarfRegNum<[0]>;
def X1  : CAHPReg<1, "x1", ["sp"]>, DwarfRegNum<[1]>;
def X2  : CAHPReg<2, "x2", ["fp"]>, DwarfRegNum<[2]>;
def X3  : CAHPReg<3, "x3", ["s0"]>, DwarfRegNum<[3]>;
def X4  : CAHPReg<4, "x4", ["s1"]>, DwarfRegNum<[4]>;
def X5  : CAHPReg<5, "x5", ["s2"]>, DwarfRegNum<[5]>;
def X6  : CAHPReg<6, "x6", ["s3"]>, DwarfRegNum<[6]>;
def X7  : CAHPReg<7, "x7", ["s4"]>, DwarfRegNum<[7]>;
def X8  : CAHPReg<8, "x8", ["a0"]>, DwarfRegNum<[8]>;
def X9  : CAHPReg<9, "x9", ["a1"]>, DwarfRegNum<[9]>;
def X10 : CAHPReg<10,"x10", ["a2"]>, DwarfRegNum<[10]>;
def X11 : CAHPReg<11,"x11", ["a3"]>, DwarfRegNum<[11]>;
def X12 : CAHPReg<12,"x12", ["a4"]>, DwarfRegNum<[12]>;
def X13 : CAHPReg<13,"x13", ["a5"]>, DwarfRegNum<[13]>;
def X14 : CAHPReg<14,"x14", ["t0"]>, DwarfRegNum<[14]>;
def X15 : CAHPReg<15,"x15", ["t1"]>, DwarfRegNum<[15]>;

// General Purpose Registers.
// The order of registers represents the preferred allocation sequence.
// Registers are listed in the order caller-save, callee-save, specials.
def GPR : RegisterClass<"CAHP", [i16], 16, (add
  X8, X9, X10, X11, X12, X13, X14, X15, X3, X4, X5, X6, X7, X0, X1, X2
  )>;

// For instructions like lwsp and swsp, which accept only the stack pointer as operand.
def SP : RegisterClass<"CAHP", [i16], 16, (add X1)>;
