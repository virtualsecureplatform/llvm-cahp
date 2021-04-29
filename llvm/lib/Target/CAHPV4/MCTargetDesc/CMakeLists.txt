add_llvm_component_library(LLVMCAHPV4Desc
  CAHPV4MCTargetDesc.cpp
  CAHPV4MCAsmInfo.cpp
  CAHPV4AsmBackend.cpp
  CAHPV4ELFObjectWriter.cpp
  CAHPV4MCCodeEmitter.cpp

  LINK_COMPONENTS
  MC
  CAHPV4Info
  CAHPV4Desc
  Support

  ADD_TO_COMPONENT
  CAHPV4
)
