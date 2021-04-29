// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

include "llvm/Target/Target.td"

//===----------------------------------------------------------------------===//
// Register file, instruction descriptions.
//===----------------------------------------------------------------------===//

include "CAHPV4RegisterInfo.td"
include "CAHPV4InstrInfo.td"

//===----------------------------------------------------------------------===//
// CAHPV4 processors supported.
//===----------------------------------------------------------------------===//

def : ProcessorModel<"generic-cahpv4", NoSchedModel, []>;

//===----------------------------------------------------------------------===//
// Define the CAHPV4 target.
//===----------------------------------------------------------------------===//

def CAHPV4InstrInfo : InstrInfo;

def CAHPV4AsmParser : AsmParser {
  // Use alternative names of registers when emitting.
  let ShouldEmitMatchRegisterAltName = 1;
}

def CAHPV4 : Target {
  let InstructionSet = CAHPV4InstrInfo;
  let AssemblyParsers = [CAHPV4AsmParser];
}
