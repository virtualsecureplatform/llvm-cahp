#ifndef LLVM_LIB_TARGET_CAHP_MCTARGETDESC_CAHPBASEINFO_H
#define LLVM_LIB_TARGET_CAHP_MCTARGETDESC_CAHPBASEINFO_H

#include "CAHPMCTargetDesc.h"

namespace llvm {

// CAHPII - This namespace holds all of the target specific flags that
// instruction info tracks. All definitions must match CAHPInstrFormats.td.
namespace CAHPII {
enum {
  MO_None,
  MO_LO,
  MO_HI,
};
} // namespace CAHPII

} // namespace llvm

#endif
