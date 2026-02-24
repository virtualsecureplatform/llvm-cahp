add_llvm_library(LLVMCAHPAsmPrinter
  CAHPInstPrinter.cpp

  LINK_COMPONENTS
  MC
  Support
  )
