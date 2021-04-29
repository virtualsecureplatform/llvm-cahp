// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

#include "CAHPV4MCAsmInfo.h"
#include "llvm/ADT/Triple.h"
using namespace llvm;

void CAHPV4MCAsmInfo::anchor() {}

CAHPV4MCAsmInfo::CAHPV4MCAsmInfo(const Triple &TT) {
  CodePointerSize = 2;
  CalleeSaveStackSlotSize = 2;
  CommentString = "#";
  SupportsDebugInformation = true;
}
