#include "idris2_llvm.h"

int main() {
  return idris2_llvm_shim_abi_version() == 1 &&
                 idris2_llvm_is_null(nullptr) == 1
             ? 0
             : 1;
}

