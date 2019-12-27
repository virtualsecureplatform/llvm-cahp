// This file is copied and modified from The LLVM Compiler Infrastructure, which
// is distributed under the Apache License v2.0 with LLVM Exceptions (see
// LICENSE.TXT for details). This file is licensed under the same license.

#include "CAHP.h"
#include "clang/Basic/MacroBuilder.h"
#include "llvm/ADT/StringSwitch.h"

using namespace clang;
using namespace clang::targets;

ArrayRef<const char *> CAHPTargetInfo::getGCCRegNames() const {
  static const char *const GCCRegNames[] = {
      "x0", "x1", "x2",  "x3",  "x4",  "x5",  "x6",  "x7",
      "x8", "x9", "x10", "x11", "x12", "x13", "x14", "x15"};
  return llvm::makeArrayRef(GCCRegNames);
}

ArrayRef<TargetInfo::GCCRegAlias> CAHPTargetInfo::getGCCRegAliases() const {
  static const TargetInfo::GCCRegAlias GCCRegAliases[] = {
      {{"ra"}, "x0"},  {{"sp"}, "x1"},  {{"fp"}, "x2"},  {{"s0"}, "x3"},
      {{"s1"}, "x4"},  {{"s2"}, "x5"},  {{"s3"}, "x6"},  {{"s4"}, "x7"},
      {{"a0"}, "x8"},  {{"a1"}, "x9"},  {{"a2"}, "x10"}, {{"a3"}, "x11"},
      {{"a4"}, "x12"}, {{"a5"}, "x13"}, {{"t0"}, "x15"}, {{"t1"}, "x15"}};
  return llvm::makeArrayRef(GCCRegAliases);
}

void CAHPTargetInfo::getTargetDefines(const LangOptions &Opts,
                                      MacroBuilder &Builder) const {

  Builder.defineMacro("__cahp__");
  Builder.defineMacro("__cahpv3__");
}

bool CAHPTargetInfo::isValidCPUName(StringRef Name) const {
  if (Name == "generic")
    return true;

  CPUKind CPU = llvm::StringSwitch<CPUKind>(Name).Default(CK_NONE);
  return CPU != CK_NONE;
}

bool CAHPTargetInfo::setCPU(const std::string &Name) {
  return isValidCPUName(Name);
}
