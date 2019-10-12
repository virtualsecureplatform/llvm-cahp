set(LLVM_TARGET_DEFINITIONS CAHP.td)

tablegen(LLVM CAHPGenRegisterInfo.inc -gen-register-info)
tablegen(LLVM CAHPGenInstrInfo.inc -gen-instr-info)
tablegen(LLVM CAHPGenMCCodeEmitter.inc -gen-emitter)
tablegen(LLVM CAHPGenSubtargetInfo.inc -gen-subtarget)
tablegen(LLVM CAHPGenAsmMatcher.inc -gen-asm-matcher)
tablegen(LLVM CAHPGenAsmWriter.inc -gen-asm-writer)

add_public_tablegen_target(CAHPCommonTableGen)

add_llvm_target(CAHPCodeGen
  CAHPTargetMachine.cpp
  )
add_subdirectory(AsmParser)
add_subdirectory(InstPrinter)
add_subdirectory(MCTargetDesc)
add_subdirectory(TargetInfo)
