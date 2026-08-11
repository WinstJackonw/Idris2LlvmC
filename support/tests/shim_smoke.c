#include "idris2_llvm.h"

#include <stddef.h>

int main(void) {
  return idris2_llvm_shim_abi_version() == IDRIS2_LLVM_SHIM_ABI_VERSION &&
                 idris2_llvm_is_null(NULL) == 1
             ? 0
             : 1;
}
