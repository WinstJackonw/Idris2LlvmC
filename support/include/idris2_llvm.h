#ifndef IDRIS2_LLVM_H
#define IDRIS2_LLVM_H

#include <stdint.h>

#if defined(_WIN32)
#  define IDRIS2_LLVM_EXPORT __declspec(dllexport)
#else
#  define IDRIS2_LLVM_EXPORT __attribute__((visibility("default")))
#endif

#ifdef __cplusplus
extern "C" {
#endif

IDRIS2_LLVM_EXPORT uint32_t idris2_llvm_shim_abi_version(void);
IDRIS2_LLVM_EXPORT const char *idris2_llvm_string_from_ptr(const char *value);
IDRIS2_LLVM_EXPORT uint64_t idris2_llvm_string_byte_length(const char *value);
IDRIS2_LLVM_EXPORT int32_t idris2_llvm_is_null(const void *value);

#ifdef __cplusplus
}
#endif

#endif
