add_llvm_library(LLVMCAHPAsmParser
  CAHPAsmParser.cpp

  LINK_COMPONENTS
  MC
  MCParser
  CAHPDesc
  CAHPInfo
  Support
  )
