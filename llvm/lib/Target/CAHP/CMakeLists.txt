set(LLVM_TARGET_DEFINITIONS CAHP.td)

tablegen(LLVM CAHPGenAsmMatcher.inc -gen-asm-matcher)
tablegen(LLVM CAHPGenAsmWriter.inc -gen-asm-writer)
tablegen(LLVM CAHPGenCompressInstEmitter.inc -gen-cahp-compress-inst-emitter)
tablegen(LLVM CAHPGenCallingConv.inc -gen-callingconv)
tablegen(LLVM CAHPGenDAGISel.inc -gen-dag-isel)
tablegen(LLVM CAHPGenDisassemblerTables.inc -gen-disassembler)
tablegen(LLVM CAHPGenInstrInfo.inc -gen-instr-info)
tablegen(LLVM CAHPGenMCCodeEmitter.inc -gen-emitter)
tablegen(LLVM CAHPGenMCPseudoLowering.inc -gen-pseudo-lowering)
tablegen(LLVM CAHPGenRegisterInfo.inc -gen-register-info)
tablegen(LLVM CAHPGenSubtargetInfo.inc -gen-subtarget)

add_public_tablegen_target(CAHPCommonTableGen)

add_llvm_target(CAHPCodeGen
  CAHPAsmPrinter.cpp
  CAHPFrameLowering.cpp
  CAHPISelDAGToDAG.cpp
  CAHPISelLowering.cpp
  CAHPInstrInfo.cpp
  CAHPMCInstLower.cpp
  CAHPRegisterInfo.cpp
  CAHPSubtarget.cpp
  CAHPTargetMachine.cpp
  )
add_subdirectory(AsmParser)
add_subdirectory(Disassembler)
add_subdirectory(InstPrinter)
add_subdirectory(MCTargetDesc)
add_subdirectory(TargetInfo)
