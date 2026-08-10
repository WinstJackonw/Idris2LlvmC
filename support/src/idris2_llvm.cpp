#include "idris2_llvm.h"

#include "llvm-c/Analysis.h"
#include "llvm-c/BitReader.h"
#include "llvm-c/BitWriter.h"
#include "llvm-c/Core.h"
#include "llvm-c/DebugInfo.h"
#include "llvm-c/Error.h"
#include "llvm-c/IRReader.h"
#include "llvm-c/Linker.h"
#include "llvm-c/Target.h"
#include "llvm-c/TargetMachine.h"
#include "llvm-c/Transforms/PassBuilder.h"

#include <cstddef>
#include <cstdint>
#include <cstdlib>
#include <cstring>

static_assert(sizeof(void *) == 8, "llvm-c requires a 64-bit process");
static_assert(sizeof(size_t) == 8, "llvm-c requires 64-bit size_t");
static_assert(LLVMIntEQ == 32 && LLVMIntSLE == 41,
              "LLVM integer predicate ABI changed");
static_assert(LLVMCodeGenLevelDefault == 2 && LLVMObjectFile == 1,
              "LLVM target enum ABI changed");

#define EXPORT IDRIS2_LLVM_EXPORT
#define CREF(p) reinterpret_cast<LLVMContextRef>(p)
#define MREF(p) reinterpret_cast<LLVMModuleRef>(p)
#define TREF(p) reinterpret_cast<LLVMTypeRef>(p)
#define VREF(p) reinterpret_cast<LLVMValueRef>(p)
#define BBREF(p) reinterpret_cast<LLVMBasicBlockRef>(p)
#define BREF(p) reinterpret_cast<LLVMBuilderRef>(p)
#define MBREF(p) reinterpret_cast<LLVMMemoryBufferRef>(p)
#define MDREF(p) reinterpret_cast<LLVMMetadataRef>(p)
#define AREF(p) reinterpret_cast<LLVMAttributeRef>(p)
#define TARGETREF(p) reinterpret_cast<LLVMTargetRef>(p)
#define TMREF(p) reinterpret_cast<LLVMTargetMachineRef>(p)
#define TMOREF(p) reinterpret_cast<LLVMTargetMachineOptionsRef>(p)
#define TDREF(p) reinterpret_cast<LLVMTargetDataRef>(p)
#define PBOREF(p) reinterpret_cast<LLVMPassBuilderOptionsRef>(p)
#define DIREF(p) reinterpret_cast<LLVMDIBuilderRef>(p)

extern "C" {

EXPORT uint32_t idris2_llvm_shim_abi_version(void) { return 1; }
EXPORT const char *idris2_llvm_string_from_ptr(const char *value) {
  return value == nullptr ? "" : value;
}
EXPORT uint64_t idris2_llvm_string_byte_length(const char *value) {
  return value == nullptr ? 0 : static_cast<uint64_t>(std::strlen(value));
}
EXPORT int32_t idris2_llvm_is_null(const void *value) {
  return value == nullptr ? 1 : 0;
}
EXPORT void **idris2_llvm_ptr_array_new(uint32_t count) {
  return static_cast<void **>(std::calloc(count == 0 ? 1 : count,
                                          sizeof(void *)));
}
EXPORT void idris2_llvm_ptr_array_set(void **array, uint32_t index,
                                      void *value) {
  array[index] = value;
}
EXPORT void *idris2_llvm_ptr_array_get(void **array, uint32_t index) {
  return array[index];
}
EXPORT void idris2_llvm_ptr_array_free(void **array) { std::free(array); }
EXPORT int64_t *idris2_llvm_i64_array_new(uint32_t count) {
  return static_cast<int64_t *>(std::calloc(count == 0 ? 1 : count,
                                            sizeof(int64_t)));
}
EXPORT void idris2_llvm_i64_array_set(int64_t *array, uint32_t index,
                                      int64_t value) {
  array[index] = value;
}
EXPORT void idris2_llvm_i64_array_free(int64_t *array) { std::free(array); }

EXPORT uint32_t idris2_llvm_version_major(void) {
  unsigned major = 0, minor = 0, patch = 0;
  LLVMGetVersion(&major, &minor, &patch);
  return major;
}
EXPORT uint32_t idris2_llvm_version_minor(void) {
  unsigned major = 0, minor = 0, patch = 0;
  LLVMGetVersion(&major, &minor, &patch);
  return minor;
}
EXPORT uint32_t idris2_llvm_version_patch(void) {
  unsigned major = 0, minor = 0, patch = 0;
  LLVMGetVersion(&major, &minor, &patch);
  return patch;
}

EXPORT void *idris2_llvm_context_create(void) { return LLVMContextCreate(); }
EXPORT void idris2_llvm_context_dispose(void *context) {
  LLVMContextDispose(CREF(context));
}

EXPORT void *idris2_llvm_module_create_with_name_in_context(
    const char *name, void *context) {
  return LLVMModuleCreateWithNameInContext(name, CREF(context));
}
EXPORT void *idris2_llvm_clone_module(void *module) {
  return LLVMCloneModule(MREF(module));
}
EXPORT void idris2_llvm_dispose_module(void *module) {
  LLVMDisposeModule(MREF(module));
}
EXPORT void *idris2_llvm_get_module_context(void *module) {
  return LLVMGetModuleContext(MREF(module));
}
EXPORT const char *idris2_llvm_get_module_identifier(void *module,
                                                      uint64_t *length) {
  size_t len = 0;
  const char *result = LLVMGetModuleIdentifier(MREF(module), &len);
  if (length != nullptr) *length = static_cast<uint64_t>(len);
  return result;
}
EXPORT void idris2_llvm_set_module_identifier(void *module, const char *name,
                                               uint64_t length) {
  LLVMSetModuleIdentifier(MREF(module), name, static_cast<size_t>(length));
}
EXPORT const char *idris2_llvm_get_module_target(void *module) {
  return LLVMGetTarget(MREF(module));
}
EXPORT void idris2_llvm_set_module_target(void *module, const char *triple) {
  LLVMSetTarget(MREF(module), triple);
}
EXPORT const char *idris2_llvm_get_module_data_layout(void *module) {
  return LLVMGetDataLayoutStr(MREF(module));
}
EXPORT void idris2_llvm_set_module_data_layout(void *module,
                                                const char *layout) {
  LLVMSetDataLayout(MREF(module), layout);
}
EXPORT void idris2_llvm_add_module_flag(void *module, int32_t behavior,
                                        const char *key, uint64_t key_length,
                                        void *value) {
  LLVMAddModuleFlag(MREF(module), static_cast<LLVMModuleFlagBehavior>(behavior),
                    key, static_cast<size_t>(key_length), MDREF(value));
}
EXPORT char *idris2_llvm_print_module_to_string(void *module) {
  return LLVMPrintModuleToString(MREF(module));
}
EXPORT int32_t idris2_llvm_print_module_to_file(void *module,
                                                const char *path,
                                                char **error) {
  return LLVMPrintModuleToFile(MREF(module), path, error);
}
EXPORT void idris2_llvm_dump_module(void *module) { LLVMDumpModule(MREF(module)); }
EXPORT void idris2_llvm_dispose_message(char *message) {
  LLVMDisposeMessage(message);
}

EXPORT int32_t idris2_llvm_get_type_kind(void *type) {
  return static_cast<int32_t>(LLVMGetTypeKind(TREF(type)));
}
EXPORT int32_t idris2_llvm_type_is_sized(void *type) {
  return LLVMTypeIsSized(TREF(type));
}
EXPORT void *idris2_llvm_int_type_in_context(void *context, uint32_t width) {
  return LLVMIntTypeInContext(CREF(context), width);
}
EXPORT void *idris2_llvm_int1_type_in_context(void *context) {
  return LLVMInt1TypeInContext(CREF(context));
}
EXPORT void *idris2_llvm_int8_type_in_context(void *context) {
  return LLVMInt8TypeInContext(CREF(context));
}
EXPORT void *idris2_llvm_int16_type_in_context(void *context) {
  return LLVMInt16TypeInContext(CREF(context));
}
EXPORT void *idris2_llvm_int32_type_in_context(void *context) {
  return LLVMInt32TypeInContext(CREF(context));
}
EXPORT void *idris2_llvm_int64_type_in_context(void *context) {
  return LLVMInt64TypeInContext(CREF(context));
}
EXPORT uint32_t idris2_llvm_get_int_type_width(void *type) {
  return LLVMGetIntTypeWidth(TREF(type));
}
EXPORT void *idris2_llvm_half_type_in_context(void *context) {
  return LLVMHalfTypeInContext(CREF(context));
}
EXPORT void *idris2_llvm_float_type_in_context(void *context) {
  return LLVMFloatTypeInContext(CREF(context));
}
EXPORT void *idris2_llvm_double_type_in_context(void *context) {
  return LLVMDoubleTypeInContext(CREF(context));
}
EXPORT void *idris2_llvm_void_type_in_context(void *context) {
  return LLVMVoidTypeInContext(CREF(context));
}
EXPORT void *idris2_llvm_pointer_type_in_context(void *context,
                                                 uint32_t address_space) {
  return LLVMPointerTypeInContext(CREF(context), address_space);
}
EXPORT void *idris2_llvm_array_type2(void *element, uint64_t count) {
  return LLVMArrayType2(TREF(element), count);
}
EXPORT void *idris2_llvm_vector_type(void *element, uint32_t count) {
  return LLVMVectorType(TREF(element), count);
}
EXPORT void *idris2_llvm_scalable_vector_type(void *element, uint32_t count) {
  return LLVMScalableVectorType(TREF(element), count);
}
EXPORT void *idris2_llvm_function_type(void *result, void **params,
                                       uint32_t count, int32_t vararg) {
  return LLVMFunctionType(TREF(result),
                          reinterpret_cast<LLVMTypeRef *>(params), count,
                          vararg);
}
EXPORT void *idris2_llvm_struct_type_in_context(void *context, void **elements,
                                                uint32_t count,
                                                int32_t packed) {
  return LLVMStructTypeInContext(CREF(context),
                                 reinterpret_cast<LLVMTypeRef *>(elements),
                                 count, packed);
}
EXPORT void *idris2_llvm_struct_create_named(void *context, const char *name) {
  return LLVMStructCreateNamed(CREF(context), name);
}
EXPORT void idris2_llvm_struct_set_body(void *type, void **elements,
                                        uint32_t count, int32_t packed) {
  LLVMStructSetBody(TREF(type), reinterpret_cast<LLVMTypeRef *>(elements), count,
                    packed);
}
EXPORT char *idris2_llvm_print_type_to_string(void *type) {
  return LLVMPrintTypeToString(TREF(type));
}

EXPORT void *idris2_llvm_const_null(void *type) { return LLVMConstNull(TREF(type)); }
EXPORT void *idris2_llvm_get_undef(void *type) { return LLVMGetUndef(TREF(type)); }
EXPORT void *idris2_llvm_get_poison(void *type) { return LLVMGetPoison(TREF(type)); }
EXPORT void *idris2_llvm_const_int(void *type, uint64_t value,
                                   int32_t sign_extend) {
  return LLVMConstInt(TREF(type), value, sign_extend);
}
EXPORT void *idris2_llvm_const_real(void *type, double value) {
  return LLVMConstReal(TREF(type), value);
}
EXPORT void *idris2_llvm_const_string_in_context2(void *context,
                                                  const char *value,
                                                  uint64_t length,
                                                  int32_t null_terminate) {
  return LLVMConstStringInContext2(CREF(context), value,
                                   static_cast<size_t>(length), null_terminate);
}
EXPORT void *idris2_llvm_const_array2(void *element_type, void **values,
                                      uint64_t count) {
  return LLVMConstArray2(TREF(element_type),
                         reinterpret_cast<LLVMValueRef *>(values), count);
}
EXPORT void *idris2_llvm_const_struct_in_context(void *context, void **values,
                                                 uint32_t count,
                                                 int32_t packed) {
  return LLVMConstStructInContext(CREF(context),
                                  reinterpret_cast<LLVMValueRef *>(values),
                                  count, packed);
}
EXPORT void *idris2_llvm_const_named_struct(void *type, void **values,
                                            uint32_t count) {
  return LLVMConstNamedStruct(TREF(type),
                              reinterpret_cast<LLVMValueRef *>(values), count);
}
EXPORT void *idris2_llvm_const_vector(void **values, uint32_t count) {
  return LLVMConstVector(reinterpret_cast<LLVMValueRef *>(values), count);
}

EXPORT void *idris2_llvm_type_of(void *value) { return LLVMTypeOf(VREF(value)); }
EXPORT int32_t idris2_llvm_get_value_kind(void *value) {
  return static_cast<int32_t>(LLVMGetValueKind(VREF(value)));
}
EXPORT const char *idris2_llvm_get_value_name2(void *value, uint64_t *length) {
  size_t len = 0;
  const char *result = LLVMGetValueName2(VREF(value), &len);
  if (length != nullptr) *length = static_cast<uint64_t>(len);
  return result;
}
EXPORT void idris2_llvm_set_value_name2(void *value, const char *name,
                                        uint64_t length) {
  LLVMSetValueName2(VREF(value), name, static_cast<size_t>(length));
}
EXPORT char *idris2_llvm_print_value_to_string(void *value) {
  return LLVMPrintValueToString(VREF(value));
}
EXPORT void idris2_llvm_replace_all_uses_with(void *old_value,
                                              void *new_value) {
  LLVMReplaceAllUsesWith(VREF(old_value), VREF(new_value));
}
EXPORT int32_t idris2_llvm_is_constant(void *value) {
  return LLVMIsConstant(VREF(value));
}
EXPORT int32_t idris2_llvm_is_null_value(void *value) {
  return LLVMIsNull(VREF(value));
}

EXPORT void *idris2_llvm_add_function(void *module, const char *name,
                                      void *function_type) {
  return LLVMAddFunction(MREF(module), name, TREF(function_type));
}
EXPORT void *idris2_llvm_get_named_function(void *module, const char *name) {
  return LLVMGetNamedFunction(MREF(module), name);
}
EXPORT uint32_t idris2_llvm_count_params(void *function) {
  return LLVMCountParams(VREF(function));
}
EXPORT void *idris2_llvm_get_param(void *function, uint32_t index) {
  return LLVMGetParam(VREF(function), index);
}
EXPORT void idris2_llvm_set_function_call_conv(void *function,
                                                uint32_t call_conv) {
  LLVMSetFunctionCallConv(VREF(function), call_conv);
}
EXPORT uint32_t idris2_llvm_get_function_call_conv(void *function) {
  return LLVMGetFunctionCallConv(VREF(function));
}
EXPORT void *idris2_llvm_add_global(void *module, void *type,
                                    const char *name) {
  return LLVMAddGlobal(MREF(module), TREF(type), name);
}
EXPORT void *idris2_llvm_get_named_global(void *module, const char *name) {
  return LLVMGetNamedGlobal(MREF(module), name);
}
EXPORT void idris2_llvm_set_initializer(void *global, void *value) {
  LLVMSetInitializer(VREF(global), VREF(value));
}
EXPORT void idris2_llvm_set_global_constant(void *global, int32_t constant) {
  LLVMSetGlobalConstant(VREF(global), constant);
}
EXPORT void idris2_llvm_set_linkage(void *global, int32_t linkage) {
  LLVMSetLinkage(VREF(global), static_cast<LLVMLinkage>(linkage));
}
EXPORT int32_t idris2_llvm_get_linkage(void *global) {
  return static_cast<int32_t>(LLVMGetLinkage(VREF(global)));
}
EXPORT void idris2_llvm_set_section(void *global, const char *section) {
  LLVMSetSection(VREF(global), section);
}
EXPORT void idris2_llvm_set_alignment(void *value, uint32_t alignment) {
  LLVMSetAlignment(VREF(value), alignment);
}
EXPORT uint32_t idris2_llvm_get_alignment(void *value) {
  return LLVMGetAlignment(VREF(value));
}

EXPORT void *idris2_llvm_append_basic_block_in_context(void *context,
                                                       void *function,
                                                       const char *name) {
  return LLVMAppendBasicBlockInContext(CREF(context), VREF(function), name);
}
EXPORT void *idris2_llvm_insert_basic_block_in_context(void *context,
                                                       void *before,
                                                       const char *name) {
  return LLVMInsertBasicBlockInContext(CREF(context), BBREF(before), name);
}
EXPORT void *idris2_llvm_get_first_basic_block(void *function) {
  return LLVMGetFirstBasicBlock(VREF(function));
}
EXPORT void *idris2_llvm_get_next_basic_block(void *block) {
  return LLVMGetNextBasicBlock(BBREF(block));
}
EXPORT void *idris2_llvm_get_basic_block_terminator(void *block) {
  return LLVMGetBasicBlockTerminator(BBREF(block));
}

EXPORT void *idris2_llvm_create_builder_in_context(void *context) {
  return LLVMCreateBuilderInContext(CREF(context));
}
EXPORT void idris2_llvm_dispose_builder(void *builder) {
  LLVMDisposeBuilder(BREF(builder));
}
EXPORT void idris2_llvm_position_builder_at_end(void *builder, void *block) {
  LLVMPositionBuilderAtEnd(BREF(builder), BBREF(block));
}
EXPORT void idris2_llvm_position_builder_before(void *builder,
                                                void *instruction) {
  LLVMPositionBuilderBefore(BREF(builder), VREF(instruction));
}
EXPORT void *idris2_llvm_get_insert_block(void *builder) {
  return LLVMGetInsertBlock(BREF(builder));
}
EXPORT void idris2_llvm_clear_insertion_position(void *builder) {
  LLVMClearInsertionPosition(BREF(builder));
}

EXPORT void *idris2_llvm_build_ret_void(void *builder) {
  return LLVMBuildRetVoid(BREF(builder));
}
EXPORT void *idris2_llvm_build_ret(void *builder, void *value) {
  return LLVMBuildRet(BREF(builder), VREF(value));
}
EXPORT void *idris2_llvm_build_br(void *builder, void *destination) {
  return LLVMBuildBr(BREF(builder), BBREF(destination));
}
EXPORT void *idris2_llvm_build_cond_br(void *builder, void *condition,
                                       void *then_block, void *else_block) {
  return LLVMBuildCondBr(BREF(builder), VREF(condition), BBREF(then_block),
                         BBREF(else_block));
}
EXPORT void *idris2_llvm_build_unreachable(void *builder) {
  return LLVMBuildUnreachable(BREF(builder));
}
EXPORT void *idris2_llvm_build_switch(void *builder, void *value,
                                      void *else_block, uint32_t cases) {
  return LLVMBuildSwitch(BREF(builder), VREF(value), BBREF(else_block), cases);
}
EXPORT void idris2_llvm_add_case(void *switch_inst, void *on_value,
                                 void *destination) {
  LLVMAddCase(VREF(switch_inst), VREF(on_value), BBREF(destination));
}

#define BINARY_WRAPPER(name, llvm_name)                                      \
  EXPORT void *idris2_llvm_build_##name(void *builder, void *lhs, void *rhs, \
                                         const char *value_name) {            \
    return llvm_name(BREF(builder), VREF(lhs), VREF(rhs), value_name);        \
  }
BINARY_WRAPPER(add, LLVMBuildAdd)
BINARY_WRAPPER(nsw_add, LLVMBuildNSWAdd)
BINARY_WRAPPER(nuw_add, LLVMBuildNUWAdd)
BINARY_WRAPPER(fadd, LLVMBuildFAdd)
BINARY_WRAPPER(sub, LLVMBuildSub)
BINARY_WRAPPER(nsw_sub, LLVMBuildNSWSub)
BINARY_WRAPPER(nuw_sub, LLVMBuildNUWSub)
BINARY_WRAPPER(fsub, LLVMBuildFSub)
BINARY_WRAPPER(mul, LLVMBuildMul)
BINARY_WRAPPER(nsw_mul, LLVMBuildNSWMul)
BINARY_WRAPPER(nuw_mul, LLVMBuildNUWMul)
BINARY_WRAPPER(fmul, LLVMBuildFMul)
BINARY_WRAPPER(udiv, LLVMBuildUDiv)
BINARY_WRAPPER(sdiv, LLVMBuildSDiv)
BINARY_WRAPPER(fdiv, LLVMBuildFDiv)
BINARY_WRAPPER(urem, LLVMBuildURem)
BINARY_WRAPPER(srem, LLVMBuildSRem)
BINARY_WRAPPER(frem, LLVMBuildFRem)
BINARY_WRAPPER(shl, LLVMBuildShl)
BINARY_WRAPPER(lshr, LLVMBuildLShr)
BINARY_WRAPPER(ashr, LLVMBuildAShr)
BINARY_WRAPPER(and, LLVMBuildAnd)
BINARY_WRAPPER(or, LLVMBuildOr)
BINARY_WRAPPER(xor, LLVMBuildXor)
#undef BINARY_WRAPPER

EXPORT void *idris2_llvm_build_neg(void *builder, void *value,
                                   const char *name) {
  return LLVMBuildNeg(BREF(builder), VREF(value), name);
}
EXPORT void *idris2_llvm_build_fneg(void *builder, void *value,
                                    const char *name) {
  return LLVMBuildFNeg(BREF(builder), VREF(value), name);
}
EXPORT void *idris2_llvm_build_not(void *builder, void *value,
                                   const char *name) {
  return LLVMBuildNot(BREF(builder), VREF(value), name);
}
EXPORT void *idris2_llvm_build_icmp(void *builder, int32_t predicate,
                                    void *lhs, void *rhs, const char *name) {
  return LLVMBuildICmp(BREF(builder), static_cast<LLVMIntPredicate>(predicate),
                       VREF(lhs), VREF(rhs), name);
}
EXPORT void *idris2_llvm_build_fcmp(void *builder, int32_t predicate,
                                    void *lhs, void *rhs, const char *name) {
  return LLVMBuildFCmp(BREF(builder),
                       static_cast<LLVMRealPredicate>(predicate), VREF(lhs),
                       VREF(rhs), name);
}
EXPORT void *idris2_llvm_build_phi(void *builder, void *type,
                                   const char *name) {
  return LLVMBuildPhi(BREF(builder), TREF(type), name);
}
EXPORT void idris2_llvm_add_incoming(void *phi, void **values, void **blocks,
                                     uint32_t count) {
  LLVMAddIncoming(VREF(phi), reinterpret_cast<LLVMValueRef *>(values),
                  reinterpret_cast<LLVMBasicBlockRef *>(blocks), count);
}
EXPORT void *idris2_llvm_build_alloca(void *builder, void *type,
                                      const char *name) {
  return LLVMBuildAlloca(BREF(builder), TREF(type), name);
}
EXPORT void *idris2_llvm_build_load2(void *builder, void *type, void *pointer,
                                     const char *name) {
  return LLVMBuildLoad2(BREF(builder), TREF(type), VREF(pointer), name);
}
EXPORT void *idris2_llvm_build_store(void *builder, void *value,
                                     void *pointer) {
  return LLVMBuildStore(BREF(builder), VREF(value), VREF(pointer));
}
EXPORT void *idris2_llvm_build_gep2(void *builder, void *type, void *pointer,
                                    void **indices, uint32_t count,
                                    const char *name) {
  return LLVMBuildGEP2(BREF(builder), TREF(type), VREF(pointer),
                       reinterpret_cast<LLVMValueRef *>(indices), count, name);
}
EXPORT void *idris2_llvm_build_in_bounds_gep2(
    void *builder, void *type, void *pointer, void **indices, uint32_t count,
    const char *name) {
  return LLVMBuildInBoundsGEP2(BREF(builder), TREF(type), VREF(pointer),
                               reinterpret_cast<LLVMValueRef *>(indices), count,
                               name);
}
EXPORT void *idris2_llvm_build_struct_gep2(void *builder, void *type,
                                           void *pointer, uint32_t index,
                                           const char *name) {
  return LLVMBuildStructGEP2(BREF(builder), TREF(type), VREF(pointer), index,
                             name);
}

#define CAST_WRAPPER(name, llvm_name)                                       \
  EXPORT void *idris2_llvm_build_##name(void *builder, void *value,          \
                                         void *type, const char *value_name) {\
    return llvm_name(BREF(builder), VREF(value), TREF(type), value_name);    \
  }
CAST_WRAPPER(trunc, LLVMBuildTrunc)
CAST_WRAPPER(zext, LLVMBuildZExt)
CAST_WRAPPER(sext, LLVMBuildSExt)
CAST_WRAPPER(fp_to_ui, LLVMBuildFPToUI)
CAST_WRAPPER(fp_to_si, LLVMBuildFPToSI)
CAST_WRAPPER(ui_to_fp, LLVMBuildUIToFP)
CAST_WRAPPER(si_to_fp, LLVMBuildSIToFP)
CAST_WRAPPER(fp_trunc, LLVMBuildFPTrunc)
CAST_WRAPPER(fp_ext, LLVMBuildFPExt)
CAST_WRAPPER(ptr_to_int, LLVMBuildPtrToInt)
CAST_WRAPPER(int_to_ptr, LLVMBuildIntToPtr)
CAST_WRAPPER(bit_cast, LLVMBuildBitCast)
CAST_WRAPPER(addr_space_cast, LLVMBuildAddrSpaceCast)
#undef CAST_WRAPPER

EXPORT void *idris2_llvm_build_call2(void *builder, void *function_type,
                                     void *function, void **args,
                                     uint32_t count, const char *name) {
  return LLVMBuildCall2(BREF(builder), TREF(function_type), VREF(function),
                        reinterpret_cast<LLVMValueRef *>(args), count, name);
}
EXPORT void *idris2_llvm_build_select(void *builder, void *condition,
                                      void *then_value, void *else_value,
                                      const char *name) {
  return LLVMBuildSelect(BREF(builder), VREF(condition), VREF(then_value),
                         VREF(else_value), name);
}
EXPORT void *idris2_llvm_build_extract_value(void *builder, void *aggregate,
                                             uint32_t index,
                                             const char *name) {
  return LLVMBuildExtractValue(BREF(builder), VREF(aggregate), index, name);
}
EXPORT void *idris2_llvm_build_insert_value(void *builder, void *aggregate,
                                            void *element, uint32_t index,
                                            const char *name) {
  return LLVMBuildInsertValue(BREF(builder), VREF(aggregate), VREF(element),
                              index, name);
}
EXPORT void *idris2_llvm_build_extract_element(void *builder, void *vector,
                                               void *index,
                                               const char *name) {
  return LLVMBuildExtractElement(BREF(builder), VREF(vector), VREF(index), name);
}
EXPORT void *idris2_llvm_build_insert_element(void *builder, void *vector,
                                              void *element, void *index,
                                              const char *name) {
  return LLVMBuildInsertElement(BREF(builder), VREF(vector), VREF(element),
                                VREF(index), name);
}
EXPORT void *idris2_llvm_build_shuffle_vector(void *builder, void *left,
                                              void *right, void *mask,
                                              const char *name) {
  return LLVMBuildShuffleVector(BREF(builder), VREF(left), VREF(right),
                                VREF(mask), name);
}
EXPORT void *idris2_llvm_build_freeze(void *builder, void *value,
                                      const char *name) {
  return LLVMBuildFreeze(BREF(builder), VREF(value), name);
}
EXPORT void idris2_llvm_set_volatile(void *memory_inst, int32_t value) {
  LLVMSetVolatile(VREF(memory_inst), value);
}
EXPORT void idris2_llvm_set_ordering(void *memory_inst, int32_t ordering) {
  LLVMSetOrdering(VREF(memory_inst),
                  static_cast<LLVMAtomicOrdering>(ordering));
}
EXPORT void *idris2_llvm_build_fence(void *builder, int32_t ordering,
                                     int32_t single_thread,
                                     const char *name) {
  return LLVMBuildFence(BREF(builder), static_cast<LLVMAtomicOrdering>(ordering),
                        single_thread, name);
}

EXPORT void *idris2_llvm_md_string_in_context2(void *context,
                                               const char *text,
                                               uint64_t length) {
  return LLVMMDStringInContext2(CREF(context), text,
                                static_cast<size_t>(length));
}
EXPORT void *idris2_llvm_md_node_in_context2(void *context, void **metadata,
                                             uint64_t count) {
  return LLVMMDNodeInContext2(CREF(context),
                              reinterpret_cast<LLVMMetadataRef *>(metadata),
                              static_cast<size_t>(count));
}
EXPORT void *idris2_llvm_value_as_metadata(void *value) {
  return LLVMValueAsMetadata(VREF(value));
}
EXPORT void *idris2_llvm_metadata_as_value(void *context, void *metadata) {
  return LLVMMetadataAsValue(CREF(context), MDREF(metadata));
}
EXPORT void idris2_llvm_set_metadata(void *instruction, uint32_t kind,
                                     void *metadata_value) {
  LLVMSetMetadata(VREF(instruction), kind, VREF(metadata_value));
}
EXPORT uint32_t idris2_llvm_get_md_kind_id_in_context(void *context,
                                                      const char *name,
                                                      uint32_t length) {
  return LLVMGetMDKindIDInContext(CREF(context), name, length);
}

EXPORT void *idris2_llvm_create_memory_buffer_with_memory_range_copy(
    const char *input, uint64_t length, const char *name) {
  return LLVMCreateMemoryBufferWithMemoryRangeCopy(
      input, static_cast<size_t>(length), name);
}
EXPORT int32_t idris2_llvm_create_memory_buffer_with_contents_of_file(
    const char *path, void **out_buffer, char **out_message) {
  return LLVMCreateMemoryBufferWithContentsOfFile(
      path, reinterpret_cast<LLVMMemoryBufferRef *>(out_buffer), out_message);
}
EXPORT const char *idris2_llvm_get_buffer_start(void *buffer) {
  return LLVMGetBufferStart(MBREF(buffer));
}
EXPORT uint64_t idris2_llvm_get_buffer_size(void *buffer) {
  return static_cast<uint64_t>(LLVMGetBufferSize(MBREF(buffer)));
}
EXPORT void idris2_llvm_dispose_memory_buffer(void *buffer) {
  LLVMDisposeMemoryBuffer(MBREF(buffer));
}

EXPORT int32_t idris2_llvm_verify_module(void *module, int32_t action,
                                         char **out_message) {
  return LLVMVerifyModule(MREF(module),
                          static_cast<LLVMVerifierFailureAction>(action),
                          out_message);
}
EXPORT int32_t idris2_llvm_verify_function(void *function, int32_t action) {
  return LLVMVerifyFunction(VREF(function),
                            static_cast<LLVMVerifierFailureAction>(action));
}
EXPORT int32_t idris2_llvm_parse_ir_in_context2(void *context, void *buffer,
                                                void **out_module,
                                                char **out_message) {
  return LLVMParseIRInContext2(CREF(context), MBREF(buffer),
                               reinterpret_cast<LLVMModuleRef *>(out_module),
                               out_message);
}
EXPORT int32_t idris2_llvm_parse_bitcode_in_context2(void *context,
                                                     void *buffer,
                                                     void **out_module) {
  return LLVMParseBitcodeInContext2(
      CREF(context), MBREF(buffer),
      reinterpret_cast<LLVMModuleRef *>(out_module));
}
EXPORT int32_t idris2_llvm_write_bitcode_to_file(void *module,
                                                 const char *path) {
  return LLVMWriteBitcodeToFile(MREF(module), path);
}
EXPORT void *idris2_llvm_write_bitcode_to_memory_buffer(void *module) {
  return LLVMWriteBitcodeToMemoryBuffer(MREF(module));
}
EXPORT int32_t idris2_llvm_link_modules2(void *destination, void *source) {
  return LLVMLinkModules2(MREF(destination), MREF(source));
}

EXPORT void *idris2_llvm_create_pass_builder_options(void) {
  return LLVMCreatePassBuilderOptions();
}
EXPORT void idris2_llvm_dispose_pass_builder_options(void *options) {
  LLVMDisposePassBuilderOptions(PBOREF(options));
}
EXPORT void idris2_llvm_pass_builder_options_set_verify_each(void *options,
                                                             int32_t value) {
  LLVMPassBuilderOptionsSetVerifyEach(PBOREF(options), value);
}
EXPORT void idris2_llvm_pass_builder_options_set_debug_logging(void *options,
                                                               int32_t value) {
  LLVMPassBuilderOptionsSetDebugLogging(PBOREF(options), value);
}
EXPORT void *idris2_llvm_run_passes(void *module, const char *passes,
                                    void *target_machine, void *options) {
  return LLVMRunPasses(MREF(module), passes, TMREF(target_machine),
                       PBOREF(options));
}
EXPORT int32_t idris2_llvm_error_is_success(void *error) {
  return error == LLVMErrorSuccess ? 1 : 0;
}
EXPORT char *idris2_llvm_get_error_message(void *error) {
  return LLVMGetErrorMessage(reinterpret_cast<LLVMErrorRef>(error));
}
EXPORT void idris2_llvm_dispose_error_message(char *message) {
  LLVMDisposeErrorMessage(message);
}

EXPORT void idris2_llvm_initialize_all_target_infos(void) {
  LLVMInitializeAllTargetInfos();
}
EXPORT void idris2_llvm_initialize_all_targets(void) { LLVMInitializeAllTargets(); }
EXPORT void idris2_llvm_initialize_all_target_mcs(void) {
  LLVMInitializeAllTargetMCs();
}
EXPORT void idris2_llvm_initialize_all_asm_parsers(void) {
  LLVMInitializeAllAsmParsers();
}
EXPORT void idris2_llvm_initialize_all_asm_printers(void) {
  LLVMInitializeAllAsmPrinters();
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
EXPORT char *idris2_llvm_get_default_target_triple(void) {
  return LLVMGetDefaultTargetTriple();
}
EXPORT char *idris2_llvm_get_host_cpu_name(void) { return LLVMGetHostCPUName(); }
EXPORT char *idris2_llvm_get_host_cpu_features(void) {
  return LLVMGetHostCPUFeatures();
}
EXPORT int32_t idris2_llvm_get_target_from_triple(const char *triple,
                                                  void **target,
                                                  char **error) {
  return LLVMGetTargetFromTriple(
      triple, reinterpret_cast<LLVMTargetRef *>(target), error);
}
EXPORT const char *idris2_llvm_get_target_name(void *target) {
  return LLVMGetTargetName(TARGETREF(target));
}
EXPORT const char *idris2_llvm_get_target_description(void *target) {
  return LLVMGetTargetDescription(TARGETREF(target));
}
EXPORT void *idris2_llvm_create_target_machine(
    void *target, const char *triple, const char *cpu, const char *features,
    int32_t level, int32_t reloc, int32_t code_model) {
  return LLVMCreateTargetMachine(
      TARGETREF(target), triple, cpu, features,
      static_cast<LLVMCodeGenOptLevel>(level),
      static_cast<LLVMRelocMode>(reloc),
      static_cast<LLVMCodeModel>(code_model));
}
EXPORT void idris2_llvm_dispose_target_machine(void *target_machine) {
  LLVMDisposeTargetMachine(TMREF(target_machine));
}
EXPORT char *idris2_llvm_get_target_machine_triple(void *target_machine) {
  return LLVMGetTargetMachineTriple(TMREF(target_machine));
}
EXPORT char *idris2_llvm_get_target_machine_cpu(void *target_machine) {
  return LLVMGetTargetMachineCPU(TMREF(target_machine));
}
EXPORT char *idris2_llvm_get_target_machine_feature_string(
    void *target_machine) {
  return LLVMGetTargetMachineFeatureString(TMREF(target_machine));
}
EXPORT void *idris2_llvm_create_target_data_layout(void *target_machine) {
  return LLVMCreateTargetDataLayout(TMREF(target_machine));
}
EXPORT void idris2_llvm_dispose_target_data(void *target_data) {
  LLVMDisposeTargetData(TDREF(target_data));
}
EXPORT char *idris2_llvm_copy_string_rep_of_target_data(void *target_data) {
  return LLVMCopyStringRepOfTargetData(TDREF(target_data));
}
EXPORT uint64_t idris2_llvm_abi_size_of_type(void *target_data, void *type) {
  return LLVMABISizeOfType(TDREF(target_data), TREF(type));
}
EXPORT uint32_t idris2_llvm_abi_alignment_of_type(void *target_data,
                                                  void *type) {
  return LLVMABIAlignmentOfType(TDREF(target_data), TREF(type));
}
EXPORT int32_t idris2_llvm_target_machine_emit_to_file(
    void *target_machine, void *module, char *path, int32_t file_type,
    char **error) {
  return LLVMTargetMachineEmitToFile(
      TMREF(target_machine), MREF(module), path,
      static_cast<LLVMCodeGenFileType>(file_type), error);
}
EXPORT int32_t idris2_llvm_target_machine_emit_to_memory_buffer(
    void *target_machine, void *module, int32_t file_type, char **error,
    void **out_buffer) {
  return LLVMTargetMachineEmitToMemoryBuffer(
      TMREF(target_machine), MREF(module),
      static_cast<LLVMCodeGenFileType>(file_type), error,
      reinterpret_cast<LLVMMemoryBufferRef *>(out_buffer));
}

EXPORT uint32_t idris2_llvm_debug_metadata_version(void) {
  return LLVMDebugMetadataVersion();
}
EXPORT void *idris2_llvm_create_di_builder(void *module) {
  return LLVMCreateDIBuilder(MREF(module));
}
EXPORT void idris2_llvm_di_builder_finalize(void *builder) {
  LLVMDIBuilderFinalize(DIREF(builder));
}
EXPORT void idris2_llvm_dispose_di_builder(void *builder) {
  LLVMDisposeDIBuilder(DIREF(builder));
}
EXPORT void *idris2_llvm_di_builder_create_file(
    void *builder, const char *filename, uint64_t filename_len,
    const char *directory, uint64_t directory_len) {
  return LLVMDIBuilderCreateFile(DIREF(builder), filename,
                                 static_cast<size_t>(filename_len), directory,
                                 static_cast<size_t>(directory_len));
}
EXPORT void *idris2_llvm_di_builder_create_compile_unit(
    void *builder, int32_t language, void *file, const char *producer,
    uint64_t producer_len, int32_t optimized, const char *flags,
    uint64_t flags_len, uint32_t runtime_version, const char *split_name,
    uint64_t split_name_len, int32_t emission_kind, uint32_t dwo_id,
    int32_t split_debug_inlining, int32_t debug_info_for_profiling,
    const char *sysroot, uint64_t sysroot_len, const char *sdk,
    uint64_t sdk_len) {
  return LLVMDIBuilderCreateCompileUnit(
      DIREF(builder), static_cast<LLVMDWARFSourceLanguage>(language),
      MDREF(file), producer, static_cast<size_t>(producer_len), optimized, flags,
      static_cast<size_t>(flags_len), runtime_version, split_name,
      static_cast<size_t>(split_name_len),
      static_cast<LLVMDWARFEmissionKind>(emission_kind), dwo_id,
      split_debug_inlining, debug_info_for_profiling, sysroot,
      static_cast<size_t>(sysroot_len), sdk, static_cast<size_t>(sdk_len));
}
EXPORT void *idris2_llvm_di_builder_create_basic_type(
    void *builder, const char *name, uint64_t name_len, uint64_t size_bits,
    uint32_t encoding, uint32_t flags) {
  return LLVMDIBuilderCreateBasicType(DIREF(builder), name,
                                      static_cast<size_t>(name_len), size_bits,
                                      encoding, static_cast<LLVMDIFlags>(flags));
}
EXPORT void *idris2_llvm_di_builder_create_pointer_type(
    void *builder, void *pointee, uint64_t size_bits, uint32_t align_bits,
    uint32_t address_space, const char *name, uint64_t name_len) {
  return LLVMDIBuilderCreatePointerType(
      DIREF(builder), MDREF(pointee), size_bits, align_bits, address_space, name,
      static_cast<size_t>(name_len));
}
EXPORT void *idris2_llvm_di_builder_create_subroutine_type(
    void *builder, void *file, void **parameter_types, uint32_t count,
    uint32_t flags) {
  return LLVMDIBuilderCreateSubroutineType(
      DIREF(builder), MDREF(file),
      reinterpret_cast<LLVMMetadataRef *>(parameter_types), count,
      static_cast<LLVMDIFlags>(flags));
}
EXPORT void *idris2_llvm_di_builder_create_function(
    void *builder, void *scope, const char *name, uint64_t name_len,
    const char *linkage_name, uint64_t linkage_name_len, void *file,
    uint32_t line, void *type, int32_t local_to_unit, int32_t definition,
    uint32_t scope_line, uint32_t flags, int32_t optimized) {
  return LLVMDIBuilderCreateFunction(
      DIREF(builder), MDREF(scope), name, static_cast<size_t>(name_len),
      linkage_name, static_cast<size_t>(linkage_name_len), MDREF(file), line,
      MDREF(type), local_to_unit, definition, scope_line,
      static_cast<LLVMDIFlags>(flags), optimized);
}
EXPORT void *idris2_llvm_di_builder_create_lexical_block(
    void *builder, void *scope, void *file, uint32_t line, uint32_t column) {
  return LLVMDIBuilderCreateLexicalBlock(DIREF(builder), MDREF(scope),
                                         MDREF(file), line, column);
}
EXPORT void *idris2_llvm_di_builder_create_debug_location(
    void *context, uint32_t line, uint32_t column, void *scope,
    void *inlined_at) {
  return LLVMDIBuilderCreateDebugLocation(CREF(context), line, column,
                                          MDREF(scope), MDREF(inlined_at));
}
EXPORT void *idris2_llvm_di_builder_create_expression(void *builder,
                                                      int64_t *addresses,
                                                      uint64_t count) {
  return LLVMDIBuilderCreateExpression(DIREF(builder),
                                       reinterpret_cast<uint64_t *>(addresses),
                                       static_cast<size_t>(count));
}
EXPORT void *idris2_llvm_di_builder_create_auto_variable(
    void *builder, void *scope, const char *name, uint64_t name_len, void *file,
    uint32_t line, void *type, int32_t always_preserve, uint32_t flags,
    uint32_t align_bits) {
  return LLVMDIBuilderCreateAutoVariable(
      DIREF(builder), MDREF(scope), name, static_cast<size_t>(name_len),
      MDREF(file), line, MDREF(type), always_preserve,
      static_cast<LLVMDIFlags>(flags), align_bits);
}
EXPORT void *idris2_llvm_di_builder_create_parameter_variable(
    void *builder, void *scope, const char *name, uint64_t name_len,
    uint32_t argument_number, void *file, uint32_t line, void *type,
    int32_t always_preserve, uint32_t flags) {
  return LLVMDIBuilderCreateParameterVariable(
      DIREF(builder), MDREF(scope), name, static_cast<size_t>(name_len),
      argument_number, MDREF(file), line, MDREF(type), always_preserve,
      static_cast<LLVMDIFlags>(flags));
}
EXPORT void *idris2_llvm_di_builder_insert_declare_record_at_end(
    void *builder, void *storage, void *variable, void *expression,
    void *location, void *block) {
  return LLVMDIBuilderInsertDeclareRecordAtEnd(
      DIREF(builder), VREF(storage), MDREF(variable), MDREF(expression),
      MDREF(location), BBREF(block));
}
EXPORT void *idris2_llvm_di_builder_insert_dbg_value_record_at_end(
    void *builder, void *value, void *variable, void *expression,
    void *location, void *block) {
  return LLVMDIBuilderInsertDbgValueRecordAtEnd(
      DIREF(builder), VREF(value), MDREF(variable), MDREF(expression),
      MDREF(location), BBREF(block));
}
EXPORT void idris2_llvm_set_subprogram(void *function, void *subprogram) {
  LLVMSetSubprogram(VREF(function), MDREF(subprogram));
}
EXPORT void idris2_llvm_instruction_set_debug_loc(void *instruction,
                                                  void *location) {
  LLVMInstructionSetDebugLoc(VREF(instruction), MDREF(location));
}
EXPORT void idris2_llvm_set_current_debug_location2(void *builder,
                                                    void *location) {
  LLVMSetCurrentDebugLocation2(BREF(builder), MDREF(location));
}

} // extern "C"
