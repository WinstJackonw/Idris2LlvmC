#include "idris2_llvm.h"

#include "llvm-c/Core.h"
#include "llvm-c/Disassembler.h"
#include "llvm-c/Error.h"
#include "llvm-c/Target.h"

#include <stdint.h>
#include <stdlib.h>
#include <string.h>

_Static_assert(sizeof(void *) == 8, "llvm-c requires a 64-bit process");
_Static_assert(sizeof(size_t) == 8, "llvm-c requires 64-bit size_t");

#define EXPORT IDRIS2_LLVM_EXPORT

EXPORT uint32_t idris2_llvm_shim_abi_version(void) {
  return IDRIS2_LLVM_SHIM_ABI_VERSION;
}

EXPORT const char *idris2_llvm_string_from_ptr(const char *value) {
  return value == NULL ? "" : value;
}

EXPORT uint64_t idris2_llvm_string_byte_length(const char *value) {
  return value == NULL ? 0 : (uint64_t)strlen(value);
}

EXPORT int32_t idris2_llvm_is_null(const void *value) {
  return value == NULL ? 1 : 0;
}

EXPORT void **idris2_llvm_ptr_array_new(uint32_t count) {
  return calloc(count == 0 ? 1 : count, sizeof(void *));
}

EXPORT void idris2_llvm_ptr_array_set(void **array, uint32_t index,
                                      void *value) {
  array[index] = value;
}

EXPORT void *idris2_llvm_ptr_array_get(void **array, uint32_t index) {
  return array[index];
}

EXPORT void idris2_llvm_ptr_array_free(void **array) { free(array); }

EXPORT int64_t *idris2_llvm_i64_array_new(uint32_t count) {
  return calloc(count == 0 ? 1 : count, sizeof(int64_t));
}

EXPORT void idris2_llvm_i64_array_set(int64_t *array, uint32_t index,
                                      int64_t value) {
  array[index] = value;
}

EXPORT void idris2_llvm_i64_array_free(int64_t *array) { free(array); }

EXPORT uint8_t *idris2_llvm_u8_array_new(uint32_t count) {
  return calloc(count == 0 ? 1 : count, sizeof(uint8_t));
}

EXPORT void idris2_llvm_u8_array_set(uint8_t *array, uint32_t index,
                                     uint8_t value) {
  array[index] = value;
}

EXPORT void idris2_llvm_u8_array_free(uint8_t *array) { free(array); }

EXPORT LLVMDisasmContextRef idris2_llvm_create_disasm(const char *triple,
                                                       const char *cpu,
                                                       const char *features) {
  return LLVMCreateDisasmCPUFeatures(triple, cpu, features, NULL, 0, NULL,
                                     NULL);
}

EXPORT char *idris2_llvm_string_copy_len(const char *value, uint64_t length) {
  char *copy = malloc((size_t)length + 1);
  if (copy == NULL)
    return NULL;
  if (value != NULL && length != 0)
    memcpy(copy, value, (size_t)length);
  copy[length] = '\0';
  return copy;
}

EXPORT void idris2_llvm_string_copy_free(char *value) { free(value); }

EXPORT uint64_t *idris2_llvm_u64_array_new(uint32_t count) {
  return calloc(count == 0 ? 1 : count, sizeof(uint64_t));
}

EXPORT uint64_t idris2_llvm_u64_array_get(uint64_t *array, uint32_t index) {
  return array[index];
}

EXPORT void idris2_llvm_u64_array_free(uint64_t *array) { free(array); }

EXPORT uint64_t idris2_llvm_call_jit_u64_0(uint64_t address) {
  return ((uint64_t (*)(void))(uintptr_t)address)();
}

EXPORT uint64_t idris2_llvm_call_jit_u64_1(uint64_t address, uint64_t first) {
  return ((uint64_t (*)(uint64_t))(uintptr_t)address)(first);
}

EXPORT uint64_t idris2_llvm_call_jit_u64_2(uint64_t address, uint64_t first,
                                           uint64_t second) {
  return ((uint64_t (*)(uint64_t, uint64_t))(uintptr_t)address)(first, second);
}

static void get_version(unsigned *major, unsigned *minor, unsigned *patch) {
  LLVMGetVersion(major, minor, patch);
}

EXPORT uint32_t idris2_llvm_version_major(void) {
  unsigned major = 0, minor = 0, patch = 0;
  get_version(&major, &minor, &patch);
  return major;
}

EXPORT uint32_t idris2_llvm_version_minor(void) {
  unsigned major = 0, minor = 0, patch = 0;
  get_version(&major, &minor, &patch);
  return minor;
}

EXPORT uint32_t idris2_llvm_version_patch(void) {
  unsigned major = 0, minor = 0, patch = 0;
  get_version(&major, &minor, &patch);
  return patch;
}

EXPORT int32_t idris2_llvm_error_is_success(LLVMErrorRef error) {
  return error == LLVMErrorSuccess ? 1 : 0;
}

EXPORT void idris2_llvm_initialize_all_target_infos(void) {
  LLVMInitializeAllTargetInfos();
}

EXPORT void idris2_llvm_initialize_all_targets(void) {
  LLVMInitializeAllTargets();
}

EXPORT void idris2_llvm_initialize_all_target_mcs(void) {
  LLVMInitializeAllTargetMCs();
}

EXPORT void idris2_llvm_initialize_all_asm_parsers(void) {
  LLVMInitializeAllAsmParsers();
}

EXPORT void idris2_llvm_initialize_all_asm_printers(void) {
  LLVMInitializeAllAsmPrinters();
}

EXPORT void idris2_llvm_initialize_all_disassemblers(void) {
  LLVMInitializeAllDisassemblers();
}

EXPORT int32_t idris2_llvm_initialize_native_target(void) {
  return LLVMInitializeNativeTarget();
}

EXPORT int32_t idris2_llvm_initialize_native_asm_parser(void) {
  return LLVMInitializeNativeAsmParser();
}

EXPORT int32_t idris2_llvm_initialize_native_asm_printer(void) {
  return LLVMInitializeNativeAsmPrinter();
}
