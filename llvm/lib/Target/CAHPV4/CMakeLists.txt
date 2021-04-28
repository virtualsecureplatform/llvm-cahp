add_llvm_component_group(CAHPV4)

add_llvm_target(CAHPV4CodeGen
  CAHPV4TargetMachine.cpp

  LINK_COMPONENTS
  Core
  CodeGen
  CAHPV4Info
  Support
  Target

  ADD_TO_COMPONENT
  CAHPV4
  )
add_subdirectory(TargetInfo)
