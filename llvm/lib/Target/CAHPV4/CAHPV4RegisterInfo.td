// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

let Namespace = "CAHPV4" in {
  def ABIRegAltName : RegAltNameIndex;

  class CAHPV4Reg<bits<5> Enc, string n, list<string> alt = []> : Register<n> {
    let HWEncoding{4-0} = Enc;
    let AltNames = alt;
    let RegAltNameIndices = [ABIRegAltName];
  }
} // Namespace = "CAHPV4"

// Integer registers
def X0  : CAHPV4Reg<0, "x0", ["zero"]>, DwarfRegNum<[0]>;
def X1  : CAHPV4Reg<1, "x1", ["ra"]>, DwarfRegNum<[1]>;
def X2  : CAHPV4Reg<2, "x2", ["sp"]>, DwarfRegNum<[2]>;
def X3  : CAHPV4Reg<3, "x3", ["gp"]>, DwarfRegNum<[3]>;
def X4  : CAHPV4Reg<4, "x4", ["tp"]>, DwarfRegNum<[4]>;
def X5  : CAHPV4Reg<5, "x5", ["t0"]>, DwarfRegNum<[5]>;
def X6  : CAHPV4Reg<6, "x6", ["t1"]>, DwarfRegNum<[6]>;
def X7  : CAHPV4Reg<7, "x7", ["t2"]>, DwarfRegNum<[7]>;
def X8  : CAHPV4Reg<8, "x8", ["s0", "fp"]>, DwarfRegNum<[8]>;
def X9  : CAHPV4Reg<9, "x9", ["s1"]>, DwarfRegNum<[9]>;
def X10 : CAHPV4Reg<10,"x10", ["a0"]>, DwarfRegNum<[10]>;
def X11 : CAHPV4Reg<11,"x11", ["a1"]>, DwarfRegNum<[11]>;
def X12 : CAHPV4Reg<12,"x12", ["a2"]>, DwarfRegNum<[12]>;
def X13 : CAHPV4Reg<13,"x13", ["a3"]>, DwarfRegNum<[13]>;
def X14 : CAHPV4Reg<14,"x14", ["a4"]>, DwarfRegNum<[14]>;
def X15 : CAHPV4Reg<15,"x15", ["a5"]>, DwarfRegNum<[15]>;
def X16 : CAHPV4Reg<16,"x16", ["a6"]>, DwarfRegNum<[16]>;
def X17 : CAHPV4Reg<17,"x17", ["a7"]>, DwarfRegNum<[17]>;
def X18 : CAHPV4Reg<18,"x18", ["s2"]>, DwarfRegNum<[18]>;
def X19 : CAHPV4Reg<19,"x19", ["s3"]>, DwarfRegNum<[19]>;
def X20 : CAHPV4Reg<20,"x20", ["s4"]>, DwarfRegNum<[20]>;
def X21 : CAHPV4Reg<21,"x21", ["s5"]>, DwarfRegNum<[21]>;
def X22 : CAHPV4Reg<22,"x22", ["s6"]>, DwarfRegNum<[22]>;
def X23 : CAHPV4Reg<23,"x23", ["s7"]>, DwarfRegNum<[23]>;
def X24 : CAHPV4Reg<24,"x24", ["s8"]>, DwarfRegNum<[24]>;
def X25 : CAHPV4Reg<25,"x25", ["s9"]>, DwarfRegNum<[25]>;
def X26 : CAHPV4Reg<26,"x26", ["s10"]>, DwarfRegNum<[26]>;
def X27 : CAHPV4Reg<27,"x27", ["s11"]>, DwarfRegNum<[27]>;
def X28 : CAHPV4Reg<28,"x28", ["t3"]>, DwarfRegNum<[28]>;
def X29 : CAHPV4Reg<29,"x29", ["t4"]>, DwarfRegNum<[29]>;
def X30 : CAHPV4Reg<30,"x30", ["t5"]>, DwarfRegNum<[30]>;
def X31 : CAHPV4Reg<31,"x31", ["t6"]>, DwarfRegNum<[31]>;

// General Purpose Registers.
// The order of registers represents the preferred allocation sequence.
// Registers are listed in the order caller-save, callee-save, specials.
def GPR : RegisterClass<"CAHPV4", [i16], 16, (add
    (sequence "X%u", 10, 17),
    (sequence "X%u", 5, 7),
    (sequence "X%u", 28, 31),
    (sequence "X%u", 8, 9),
    (sequence "X%u", 18, 27),
    (sequence "X%u", 0, 4)
  )>;

def GPRX0 : RegisterClass<"CAHPV4", [i16], 16, (add X0)>;

// The order of registers represents the preferred allocation sequence.
// Registers are listed in the order caller-save, callee-save, specials.
def GPRNoX0 : RegisterClass<"CAHPV4", [i16], 16, (add
    (sequence "X%u", 10, 17),
    (sequence "X%u", 5, 7),
    (sequence "X%u", 28, 31),
    (sequence "X%u", 8, 9),
    (sequence "X%u", 18, 27),
    (sequence "X%u", 1, 4)
  )>;

def GPRNoX0X2 : RegisterClass<"CAHPV4", [i16], 16, (add
    (sequence "X%u", 10, 17),
    (sequence "X%u", 5, 7),
    (sequence "X%u", 28, 31),
    (sequence "X%u", 8, 9),
    (sequence "X%u", 18, 27),
    X1, X3, X4
  )>;
