add_llvm_component_library(LLVMCAHPV4AsmParser
  CAHPV4AsmParser.cpp

  LINK_COMPONENTS
  MC
  MCParser
  CAHPV4Info
  CAHPV4Desc
  Support

  ADD_TO_COMPONENT
  CAHPV4
  )

