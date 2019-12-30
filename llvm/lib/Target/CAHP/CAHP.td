// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

include "llvm/Target/Target.td"

//===----------------------------------------------------------------------===//
// Register file, calling conventions, instruction descriptions.
//===----------------------------------------------------------------------===//

include "CAHPSchedule.td"
include "CAHPRegisterInfo.td"
include "CAHPCallingConv.td"
include "CAHPInstrInfo.td"

//===----------------------------------------------------------------------===//
// CAHP processors supported.
//===----------------------------------------------------------------------===//

def : ProcessorModel<"generic", NoSchedModel, []>;
def : ProcessorModel<"emerald", EmeraldModel, []>;

//===----------------------------------------------------------------------===//
// Define the CAHP target.
//===----------------------------------------------------------------------===//

def CAHPInstrInfo : InstrInfo {
  let guessInstructionProperties = 0;
}

def CAHPAsmParser : AsmParser {
  // Use alternative names of registers when emitting.
  let ShouldEmitMatchRegisterAltName = 1;
}

def CAHPAsmWriter : AsmWriter {
  int PassSubtarget = 1;
}

def CAHP : Target {
  let InstructionSet = CAHPInstrInfo;
  let AssemblyParsers = [CAHPAsmParser];
  let AssemblyWriters = [CAHPAsmWriter];
  let AllowRegisterRenaming = 1;
}
