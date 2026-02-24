add_llvm_library(LLVMCAHPDisassembler
  CAHPDisassembler.cpp

  LINK_COMPONENTS
  MC
  MCDisassembler
  CAHPDesc
  CAHPInfo
  Support
  )
