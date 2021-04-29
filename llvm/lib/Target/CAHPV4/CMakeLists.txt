add_llvm_component_group(CAHPV4)

set(LLVM_TARGET_DEFINITIONS CAHPV4.td)

tablegen(LLVM CAHPV4GenRegisterInfo.inc -gen-register-info)
tablegen(LLVM CAHPV4GenInstrInfo.inc -gen-instr-info)
tablegen(LLVM CAHPV4GenMCCodeEmitter.inc -gen-emitter)
tablegen(LLVM CAHPV4GenSubtargetInfo.inc -gen-subtarget)
tablegen(LLVM CAHPV4GenAsmMatcher.inc -gen-asm-matcher)
tablegen(LLVM CAHPV4GenAsmWriter.inc -gen-asm-writer)

add_public_tablegen_target(CAHPV4CommonTableGen)

add_llvm_target(CAHPV4CodeGen
  CAHPV4TargetMachine.cpp

  LINK_COMPONENTS
  Core
  CodeGen
  CAHPV4Info
  CAHPV4Desc
  Support
  Target

  ADD_TO_COMPONENT
  CAHPV4
  )
add_subdirectory(AsmParser)
add_subdirectory(MCTargetDesc)
add_subdirectory(TargetInfo)
