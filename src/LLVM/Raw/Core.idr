module LLVM.Raw.Core

import public LLVM.Raw.Enums
import public LLVM.Raw.Types

%default total

llvm : String -> String
llvm name = "C:idris2_llvm_" ++ name ++ ",libidris2_llvm"

export %foreign (llvm "shim_abi_version")
shimABIVersion : PrimIO Bits32

export %foreign (llvm "version_major")
versionMajor : PrimIO Bits32

export %foreign (llvm "version_minor")
versionMinor : PrimIO Bits32

export %foreign (llvm "version_patch")
versionPatch : PrimIO Bits32

export %foreign (llvm "context_create")
contextCreate : PrimIO ContextRef

export %foreign (llvm "context_dispose")
contextDispose : ContextRef -> PrimIO ()

export %foreign (llvm "module_create_with_name_in_context")
moduleCreateWithNameInContext : String -> ContextRef -> PrimIO ModuleRef

export %foreign (llvm "clone_module")
cloneModule : ModuleRef -> PrimIO ModuleRef

export %foreign (llvm "dispose_module")
disposeModule : ModuleRef -> PrimIO ()

export %foreign (llvm "get_module_context")
getModuleContext : ModuleRef -> PrimIO ContextRef

export %foreign (llvm "get_module_identifier")
getModuleIdentifier : ModuleRef -> AnyPtr -> PrimIO (Ptr String)

export %foreign (llvm "set_module_identifier")
setModuleIdentifier : ModuleRef -> String -> Bits64 -> PrimIO ()

export %foreign (llvm "get_module_target")
getModuleTarget : ModuleRef -> PrimIO (Ptr String)

export %foreign (llvm "set_module_target")
setModuleTarget : ModuleRef -> String -> PrimIO ()

export %foreign (llvm "get_module_data_layout")
getModuleDataLayout : ModuleRef -> PrimIO (Ptr String)

export %foreign (llvm "set_module_data_layout")
setModuleDataLayout : ModuleRef -> String -> PrimIO ()

export %foreign (llvm "add_module_flag")
addModuleFlag : ModuleRef -> LLVMModuleFlagBehavior -> String -> Bits64 -> MetadataRef -> PrimIO ()

export %foreign (llvm "print_module_to_string")
printModuleToString : ModuleRef -> PrimIO (Ptr String)

export %foreign (llvm "print_module_to_file")
printModuleToFile : ModuleRef -> String -> AnyPtr -> PrimIO Int32

export %foreign (llvm "dump_module")
dumpModule : ModuleRef -> PrimIO ()

export %foreign (llvm "dispose_message")
disposeMessage : Ptr String -> PrimIO ()

export %foreign (llvm "get_type_kind")
getTypeKind : TypeRef -> PrimIO LLVMTypeKind

export %foreign (llvm "type_is_sized")
typeIsSized : TypeRef -> PrimIO Int32

export %foreign (llvm "int_type_in_context")
intTypeInContext : ContextRef -> Bits32 -> PrimIO TypeRef

export %foreign (llvm "int1_type_in_context")
int1TypeInContext : ContextRef -> PrimIO TypeRef

export %foreign (llvm "int8_type_in_context")
int8TypeInContext : ContextRef -> PrimIO TypeRef

export %foreign (llvm "int16_type_in_context")
int16TypeInContext : ContextRef -> PrimIO TypeRef

export %foreign (llvm "int32_type_in_context")
int32TypeInContext : ContextRef -> PrimIO TypeRef

export %foreign (llvm "int64_type_in_context")
int64TypeInContext : ContextRef -> PrimIO TypeRef

export %foreign (llvm "get_int_type_width")
getIntTypeWidth : TypeRef -> PrimIO Bits32

export %foreign (llvm "half_type_in_context")
halfTypeInContext : ContextRef -> PrimIO TypeRef

export %foreign (llvm "float_type_in_context")
floatTypeInContext : ContextRef -> PrimIO TypeRef

export %foreign (llvm "double_type_in_context")
doubleTypeInContext : ContextRef -> PrimIO TypeRef

export %foreign (llvm "void_type_in_context")
voidTypeInContext : ContextRef -> PrimIO TypeRef

export %foreign (llvm "pointer_type_in_context")
pointerTypeInContext : ContextRef -> Bits32 -> PrimIO TypeRef

export %foreign (llvm "array_type2")
arrayType : TypeRef -> Bits64 -> PrimIO TypeRef

export %foreign (llvm "vector_type")
vectorType : TypeRef -> Bits32 -> PrimIO TypeRef

export %foreign (llvm "scalable_vector_type")
scalableVectorType : TypeRef -> Bits32 -> PrimIO TypeRef

export %foreign (llvm "function_type")
functionType : TypeRef -> AnyPtr -> Bits32 -> Int32 -> PrimIO TypeRef

export %foreign (llvm "struct_type_in_context")
structTypeInContext : ContextRef -> AnyPtr -> Bits32 -> Int32 -> PrimIO TypeRef

export %foreign (llvm "struct_create_named")
structCreateNamed : ContextRef -> String -> PrimIO TypeRef

export %foreign (llvm "struct_set_body")
structSetBody : TypeRef -> AnyPtr -> Bits32 -> Int32 -> PrimIO ()

export %foreign (llvm "print_type_to_string")
printTypeToString : TypeRef -> PrimIO (Ptr String)

export %foreign (llvm "const_null")
constNull : TypeRef -> PrimIO ValueRef

export %foreign (llvm "get_undef")
getUndef : TypeRef -> PrimIO ValueRef

export %foreign (llvm "get_poison")
getPoison : TypeRef -> PrimIO ValueRef

export %foreign (llvm "const_int")
constInt : TypeRef -> Bits64 -> Int32 -> PrimIO ValueRef

export %foreign (llvm "const_real")
constReal : TypeRef -> Double -> PrimIO ValueRef

export %foreign (llvm "const_string_in_context2")
constStringInContext : ContextRef -> String -> Bits64 -> Int32 -> PrimIO ValueRef

export %foreign (llvm "const_array2")
constArray : TypeRef -> AnyPtr -> Bits64 -> PrimIO ValueRef

export %foreign (llvm "const_struct_in_context")
constStructInContext : ContextRef -> AnyPtr -> Bits32 -> Int32 -> PrimIO ValueRef

export %foreign (llvm "const_named_struct")
constNamedStruct : TypeRef -> AnyPtr -> Bits32 -> PrimIO ValueRef

export %foreign (llvm "const_vector")
constVector : AnyPtr -> Bits32 -> PrimIO ValueRef

export %foreign (llvm "type_of")
typeOf : ValueRef -> PrimIO TypeRef

export %foreign (llvm "get_value_kind")
getValueKind : ValueRef -> PrimIO Int32

export %foreign (llvm "get_value_name2")
getValueName : ValueRef -> AnyPtr -> PrimIO (Ptr String)

export %foreign (llvm "set_value_name2")
setValueName : ValueRef -> String -> Bits64 -> PrimIO ()

export %foreign (llvm "print_value_to_string")
printValueToString : ValueRef -> PrimIO (Ptr String)

export %foreign (llvm "replace_all_uses_with")
replaceAllUsesWith : ValueRef -> ValueRef -> PrimIO ()

export %foreign (llvm "is_constant")
isConstant : ValueRef -> PrimIO Int32

export %foreign (llvm "is_null_value")
isNullValue : ValueRef -> PrimIO Int32

export %foreign (llvm "add_function")
addFunction : ModuleRef -> String -> TypeRef -> PrimIO ValueRef

export %foreign (llvm "get_named_function")
getNamedFunction : ModuleRef -> String -> PrimIO ValueRef

export %foreign (llvm "count_params")
countParams : ValueRef -> PrimIO Bits32

export %foreign (llvm "get_param")
getParam : ValueRef -> Bits32 -> PrimIO ValueRef

export %foreign (llvm "set_function_call_conv")
setFunctionCallConv : ValueRef -> Bits32 -> PrimIO ()

export %foreign (llvm "get_function_call_conv")
getFunctionCallConv : ValueRef -> PrimIO Bits32

export %foreign (llvm "add_global")
addGlobal : ModuleRef -> TypeRef -> String -> PrimIO ValueRef

export %foreign (llvm "get_named_global")
getNamedGlobal : ModuleRef -> String -> PrimIO ValueRef

export %foreign (llvm "set_initializer")
setInitializer : ValueRef -> ValueRef -> PrimIO ()

export %foreign (llvm "set_global_constant")
setGlobalConstant : ValueRef -> Int32 -> PrimIO ()

export %foreign (llvm "set_linkage")
setLinkage : ValueRef -> LLVMLinkage -> PrimIO ()

export %foreign (llvm "get_linkage")
getLinkage : ValueRef -> PrimIO LLVMLinkage

export %foreign (llvm "set_section")
setSection : ValueRef -> String -> PrimIO ()

export %foreign (llvm "set_alignment")
setAlignment : ValueRef -> Bits32 -> PrimIO ()

export %foreign (llvm "get_alignment")
getAlignment : ValueRef -> PrimIO Bits32

export %foreign (llvm "append_basic_block_in_context")
appendBasicBlockInContext : ContextRef -> ValueRef -> String -> PrimIO BasicBlockRef

export %foreign (llvm "insert_basic_block_in_context")
insertBasicBlockInContext : ContextRef -> BasicBlockRef -> String -> PrimIO BasicBlockRef

export %foreign (llvm "get_first_basic_block")
getFirstBasicBlock : ValueRef -> PrimIO BasicBlockRef

export %foreign (llvm "get_next_basic_block")
getNextBasicBlock : BasicBlockRef -> PrimIO BasicBlockRef

export %foreign (llvm "get_basic_block_terminator")
getBasicBlockTerminator : BasicBlockRef -> PrimIO ValueRef

export %foreign (llvm "create_builder_in_context")
createBuilderInContext : ContextRef -> PrimIO BuilderRef

export %foreign (llvm "dispose_builder")
disposeBuilder : BuilderRef -> PrimIO ()

export %foreign (llvm "position_builder_at_end")
positionBuilderAtEnd : BuilderRef -> BasicBlockRef -> PrimIO ()

export %foreign (llvm "position_builder_before")
positionBuilderBefore : BuilderRef -> ValueRef -> PrimIO ()

export %foreign (llvm "get_insert_block")
getInsertBlock : BuilderRef -> PrimIO BasicBlockRef

export %foreign (llvm "clear_insertion_position")
clearInsertionPosition : BuilderRef -> PrimIO ()

export %foreign (llvm "build_ret_void")
buildRetVoid : BuilderRef -> PrimIO ValueRef

export %foreign (llvm "build_ret")
buildRet : BuilderRef -> ValueRef -> PrimIO ValueRef

export %foreign (llvm "build_br")
buildBr : BuilderRef -> BasicBlockRef -> PrimIO ValueRef

export %foreign (llvm "build_cond_br")
buildCondBr : BuilderRef -> ValueRef -> BasicBlockRef -> BasicBlockRef -> PrimIO ValueRef

export %foreign (llvm "build_unreachable")
buildUnreachable : BuilderRef -> PrimIO ValueRef

export %foreign (llvm "build_switch")
buildSwitch : BuilderRef -> ValueRef -> BasicBlockRef -> Bits32 -> PrimIO ValueRef

export %foreign (llvm "add_case")
addCase : ValueRef -> ValueRef -> BasicBlockRef -> PrimIO ()

export %foreign (llvm "build_add")
buildAdd : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_nsw_add")
buildNSWAdd : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_nuw_add")
buildNUWAdd : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_fadd")
buildFAdd : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_sub")
buildSub : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_nsw_sub")
buildNSWSub : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_nuw_sub")
buildNUWSub : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_fsub")
buildFSub : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_mul")
buildMul : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_nsw_mul")
buildNSWMul : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_nuw_mul")
buildNUWMul : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_fmul")
buildFMul : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_udiv")
buildUDiv : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_sdiv")
buildSDiv : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_fdiv")
buildFDiv : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_urem")
buildURem : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_srem")
buildSRem : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_frem")
buildFRem : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_shl")
buildShl : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_lshr")
buildLShr : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_ashr")
buildAShr : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_and")
buildAnd : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_or")
buildOr : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_xor")
buildXor : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_neg")
buildNeg : BuilderRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_fneg")
buildFNeg : BuilderRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_not")
buildNot : BuilderRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_icmp")
buildICmp : BuilderRef -> LLVMIntPredicate -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_fcmp")
buildFCmp : BuilderRef -> LLVMRealPredicate -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_phi")
buildPhi : BuilderRef -> TypeRef -> String -> PrimIO ValueRef

export %foreign (llvm "add_incoming")
addIncoming : ValueRef -> AnyPtr -> AnyPtr -> Bits32 -> PrimIO ()

export %foreign (llvm "build_alloca")
buildAlloca : BuilderRef -> TypeRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_load2")
buildLoad : BuilderRef -> TypeRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_store")
buildStore : BuilderRef -> ValueRef -> ValueRef -> PrimIO ValueRef

export %foreign (llvm "build_gep2")
buildGEP : BuilderRef -> TypeRef -> ValueRef -> AnyPtr -> Bits32 -> String -> PrimIO ValueRef

export %foreign (llvm "build_in_bounds_gep2")
buildInBoundsGEP : BuilderRef -> TypeRef -> ValueRef -> AnyPtr -> Bits32 -> String -> PrimIO ValueRef

export %foreign (llvm "build_struct_gep2")
buildStructGEP : BuilderRef -> TypeRef -> ValueRef -> Bits32 -> String -> PrimIO ValueRef

export %foreign (llvm "build_trunc")
buildTrunc : BuilderRef -> ValueRef -> TypeRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_zext")
buildZExt : BuilderRef -> ValueRef -> TypeRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_sext")
buildSExt : BuilderRef -> ValueRef -> TypeRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_fp_to_ui")
buildFPToUI : BuilderRef -> ValueRef -> TypeRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_fp_to_si")
buildFPToSI : BuilderRef -> ValueRef -> TypeRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_ui_to_fp")
buildUIToFP : BuilderRef -> ValueRef -> TypeRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_si_to_fp")
buildSIToFP : BuilderRef -> ValueRef -> TypeRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_fp_trunc")
buildFPTrunc : BuilderRef -> ValueRef -> TypeRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_fp_ext")
buildFPExt : BuilderRef -> ValueRef -> TypeRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_ptr_to_int")
buildPtrToInt : BuilderRef -> ValueRef -> TypeRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_int_to_ptr")
buildIntToPtr : BuilderRef -> ValueRef -> TypeRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_bit_cast")
buildBitCast : BuilderRef -> ValueRef -> TypeRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_addr_space_cast")
buildAddrSpaceCast : BuilderRef -> ValueRef -> TypeRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_call2")
buildCall : BuilderRef -> TypeRef -> ValueRef -> AnyPtr -> Bits32 -> String -> PrimIO ValueRef

export %foreign (llvm "build_select")
buildSelect : BuilderRef -> ValueRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_extract_value")
buildExtractValue : BuilderRef -> ValueRef -> Bits32 -> String -> PrimIO ValueRef

export %foreign (llvm "build_insert_value")
buildInsertValue : BuilderRef -> ValueRef -> ValueRef -> Bits32 -> String -> PrimIO ValueRef

export %foreign (llvm "build_extract_element")
buildExtractElement : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_insert_element")
buildInsertElement : BuilderRef -> ValueRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_shuffle_vector")
buildShuffleVector : BuilderRef -> ValueRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "build_freeze")
buildFreeze : BuilderRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "set_volatile")
setVolatile : ValueRef -> Int32 -> PrimIO ()

export %foreign (llvm "set_ordering")
setOrdering : ValueRef -> LLVMAtomicOrdering -> PrimIO ()

export %foreign (llvm "build_fence")
buildFence : BuilderRef -> LLVMAtomicOrdering -> Int32 -> String -> PrimIO ValueRef

export %foreign (llvm "md_string_in_context2")
mdStringInContext : ContextRef -> String -> Bits64 -> PrimIO MetadataRef

export %foreign (llvm "md_node_in_context2")
mdNodeInContext : ContextRef -> AnyPtr -> Bits64 -> PrimIO MetadataRef

export %foreign (llvm "value_as_metadata")
valueAsMetadata : ValueRef -> PrimIO MetadataRef

export %foreign (llvm "metadata_as_value")
metadataAsValue : ContextRef -> MetadataRef -> PrimIO ValueRef

export %foreign (llvm "set_metadata")
setMetadata : ValueRef -> Bits32 -> ValueRef -> PrimIO ()

export %foreign (llvm "get_md_kind_id_in_context")
getMDKindIDInContext : ContextRef -> String -> Bits32 -> PrimIO Bits32

export %foreign (llvm "create_memory_buffer_with_memory_range_copy")
createMemoryBufferWithMemoryRangeCopy : String -> Bits64 -> String -> PrimIO MemoryBufferRef

export %foreign (llvm "create_memory_buffer_with_contents_of_file")
createMemoryBufferWithContentsOfFile : String -> AnyPtr -> AnyPtr -> PrimIO Int32

export %foreign (llvm "get_buffer_start")
getBufferStart : MemoryBufferRef -> PrimIO (Ptr String)

export %foreign (llvm "get_buffer_size")
getBufferSize : MemoryBufferRef -> PrimIO Bits64

export %foreign (llvm "dispose_memory_buffer")
disposeMemoryBuffer : MemoryBufferRef -> PrimIO ()
