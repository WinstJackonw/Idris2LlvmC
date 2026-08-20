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

#define IDRIS2_LLVM_SHIM_ABI_VERSION 3

IDRIS2_LLVM_EXPORT uint32_t idris2_llvm_shim_abi_version(void);
IDRIS2_LLVM_EXPORT const char *idris2_llvm_string_from_ptr(const char *value);
IDRIS2_LLVM_EXPORT uint64_t idris2_llvm_string_byte_length(const char *value);
IDRIS2_LLVM_EXPORT int32_t idris2_llvm_is_null(const void *value);
IDRIS2_LLVM_EXPORT uint8_t *idris2_llvm_u8_array_new(uint32_t count);
IDRIS2_LLVM_EXPORT void idris2_llvm_u8_array_set(uint8_t *array,
                                                uint32_t index,
                                                uint8_t value);
IDRIS2_LLVM_EXPORT void idris2_llvm_u8_array_free(uint8_t *array);
IDRIS2_LLVM_EXPORT void *idris2_llvm_create_disasm(const char *triple,
                                                   const char *cpu,
                                                   const char *features);
IDRIS2_LLVM_EXPORT char *idris2_llvm_string_copy_len(const char *value,
                                                     uint64_t length);
IDRIS2_LLVM_EXPORT void idris2_llvm_string_copy_free(char *value);
IDRIS2_LLVM_EXPORT uint64_t *idris2_llvm_u64_array_new(uint32_t count);
IDRIS2_LLVM_EXPORT uint64_t idris2_llvm_u64_array_get(uint64_t *array,
                                                      uint32_t index);
IDRIS2_LLVM_EXPORT void idris2_llvm_u64_array_free(uint64_t *array);
IDRIS2_LLVM_EXPORT uint64_t idris2_llvm_call_jit_u64_0(uint64_t address);
IDRIS2_LLVM_EXPORT uint64_t idris2_llvm_call_jit_u64_1(uint64_t address,
                                                       uint64_t first);
IDRIS2_LLVM_EXPORT uint64_t idris2_llvm_call_jit_u64_2(uint64_t address,
                                                       uint64_t first,
                                                       uint64_t second);
IDRIS2_LLVM_EXPORT void idris2_llvm_initialize_all_disassemblers(void);

#ifdef __cplusplus
}
#endif

#endif
