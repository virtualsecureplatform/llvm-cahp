#include "CAHP.h"
#include "CommonArgs.h"
#include "InputInfo.h"
#include "clang/Driver/Compilation.h"
#include "clang/Driver/Options.h"
#include "llvm/Option/ArgList.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/Path.h"
#include "llvm/Support/raw_ostream.h"

using namespace clang::driver;
using namespace clang::driver::toolchains;
using namespace clang::driver::tools;
using namespace clang;
using namespace llvm::opt;

CAHPToolChain::CAHPToolChain(const Driver &D, const llvm::Triple &Triple,
                             const llvm::opt::ArgList &Args)
    : Generic_ELF(D, Triple, Args) {
  if (!D.SysRoot.empty())
    getFilePaths().push_back(D.SysRoot);
}

Tool *CAHPToolChain::buildLinker() const {
  return new tools::CAHP::Linker(*this);
}

void CAHP::Linker::ConstructJob(Compilation &C, const JobAction &JA,
                                const InputInfo &Output,
                                const InputInfoList &Inputs,
                                const ArgList &Args,
                                const char *LinkingOutput) const {
  const ToolChain &ToolChain = getToolChain();
  const Driver &D = ToolChain.getDriver();
  ArgStringList CmdArgs;

  if (!D.SysRoot.empty())
    CmdArgs.push_back(Args.MakeArgString("--sysroot=" + D.SysRoot));
  std::string Linker = getToolChain().GetProgramPath(getShortName());

  bool WantCRTs =
      !Args.hasArg(options::OPT_nostdlib, options::OPT_nostartfiles);

  if (WantCRTs) {
    CmdArgs.push_back(Args.MakeArgString(ToolChain.GetFilePath("crt0.o")));
  }

  Args.AddAllArgs(CmdArgs, options::OPT_L);
  ToolChain.AddFilePathLibArgs(Args, CmdArgs);

  AddLinkerInputs(ToolChain, Inputs, Args, CmdArgs, JA);

  CmdArgs.push_back(
      Args.MakeArgString("--script=" + ToolChain.GetFilePath("cahp.lds")));

  CmdArgs.push_back("-o");
  CmdArgs.push_back(Output.getFilename());
  C.addCommand(llvm::make_unique<Command>(JA, *this, Args.MakeArgString(Linker),
                                          CmdArgs, Inputs));
}
