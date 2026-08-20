module LLVM.Raw.LTO

import public LLVM.Raw.Types

%default total

lto : String -> String
lto name = "C:" ++ name ++ ",libLTO"

public export RawLTODebugModel, RawLTOCodegenModel : Type
RawLTODebugModel = Int32
RawLTOCodegenModel = Int32

export %foreign (lto "lto_get_version")
getVersion : PrimIO (Ptr String)

export %foreign (lto "lto_api_version")
apiVersion : PrimIO Bits32

export %foreign (lto "lto_get_error_message")
getErrorMessage : PrimIO (Ptr String)

export %foreign (lto "lto_module_create")
moduleCreate : String -> PrimIO LTOModuleRef

export %foreign (lto "lto_module_dispose")
moduleDispose : LTOModuleRef -> PrimIO ()

export %foreign (lto "lto_module_get_target_triple")
moduleGetTargetTriple : LTOModuleRef -> PrimIO (Ptr String)

export %foreign (lto "lto_module_set_target_triple")
moduleSetTargetTriple : LTOModuleRef -> String -> PrimIO ()

export %foreign (lto "lto_module_get_num_symbols")
moduleGetNumSymbols : LTOModuleRef -> PrimIO Bits32

export %foreign (lto "lto_module_get_symbol_name")
moduleGetSymbolName : LTOModuleRef -> Bits32 -> PrimIO (Ptr String)

export %foreign (lto "lto_module_get_symbol_attribute")
moduleGetSymbolAttribute : LTOModuleRef -> Bits32 -> PrimIO Bits32

export %foreign (lto "lto_module_is_thinlto")
moduleIsThinLTO : LTOModuleRef -> PrimIO Int32

export %foreign (lto "lto_codegen_create")
codegenCreate : PrimIO LTOCodeGeneratorRef

export %foreign (lto "lto_codegen_dispose")
codegenDispose : LTOCodeGeneratorRef -> PrimIO ()

export %foreign (lto "lto_codegen_add_module")
codegenAddModule : LTOCodeGeneratorRef -> LTOModuleRef -> PrimIO Int32

export %foreign (lto "lto_codegen_set_debug_model")
codegenSetDebugModel : LTOCodeGeneratorRef -> RawLTODebugModel -> PrimIO Int32

export %foreign (lto "lto_codegen_set_pic_model")
codegenSetPICModel : LTOCodeGeneratorRef -> RawLTOCodegenModel -> PrimIO Int32

export %foreign (lto "lto_codegen_set_cpu")
codegenSetCPU : LTOCodeGeneratorRef -> String -> PrimIO ()

export %foreign (lto "lto_codegen_add_must_preserve_symbol")
codegenAddMustPreserveSymbol : LTOCodeGeneratorRef -> String -> PrimIO ()

export %foreign (lto "lto_codegen_set_should_internalize")
codegenSetShouldInternalize : LTOCodeGeneratorRef -> Int32 -> PrimIO ()

export %foreign (lto "lto_codegen_set_should_embed_uselists")
codegenSetShouldEmbedUseLists : LTOCodeGeneratorRef -> Int32 -> PrimIO ()

export %foreign (lto "lto_codegen_compile_to_file")
codegenCompileToFile : LTOCodeGeneratorRef -> AnyPtr -> PrimIO Int32

export %foreign (lto "thinlto_create_codegen")
thinCreateCodegen : PrimIO ThinLTOCodeGeneratorRef

export %foreign (lto "thinlto_codegen_dispose")
thinDisposeCodegen : ThinLTOCodeGeneratorRef -> PrimIO ()

export %foreign (lto "thinlto_codegen_add_module")
thinAddModule : ThinLTOCodeGeneratorRef -> String -> AnyPtr -> Int32 -> PrimIO ()

export %foreign (lto "thinlto_codegen_process")
thinProcess : ThinLTOCodeGeneratorRef -> PrimIO ()

export %foreign (lto "thinlto_module_get_num_object_files")
thinGetNumObjectFiles : ThinLTOCodeGeneratorRef -> PrimIO Bits32

export %foreign (lto "thinlto_module_get_object_file")
thinGetObjectFile : ThinLTOCodeGeneratorRef -> Bits32 -> PrimIO (Ptr String)

export %foreign (lto "thinlto_codegen_set_pic_model")
thinSetPICModel : ThinLTOCodeGeneratorRef -> RawLTOCodegenModel -> PrimIO Int32

export %foreign (lto "thinlto_set_generated_objects_dir")
thinSetGeneratedObjectsDir : ThinLTOCodeGeneratorRef -> String -> PrimIO ()

export %foreign (lto "thinlto_codegen_set_cpu")
thinSetCPU : ThinLTOCodeGeneratorRef -> String -> PrimIO ()

export %foreign (lto "thinlto_codegen_disable_codegen")
thinDisableCodegen : ThinLTOCodeGeneratorRef -> Int32 -> PrimIO ()

export %foreign (lto "thinlto_codegen_set_codegen_only")
thinSetCodegenOnly : ThinLTOCodeGeneratorRef -> Int32 -> PrimIO ()

export %foreign (lto "thinlto_codegen_add_must_preserve_symbol")
thinAddMustPreserveSymbol : ThinLTOCodeGeneratorRef -> String -> Int32 -> PrimIO ()

export %foreign (lto "thinlto_codegen_add_cross_referenced_symbol")
thinAddCrossReferencedSymbol : ThinLTOCodeGeneratorRef -> String -> Int32 -> PrimIO ()

export %foreign (lto "thinlto_codegen_set_cache_dir")
thinSetCacheDir : ThinLTOCodeGeneratorRef -> String -> PrimIO ()

export %foreign (lto "thinlto_codegen_set_cache_pruning_interval")
thinSetCachePruningInterval : ThinLTOCodeGeneratorRef -> Int32 -> PrimIO ()

export %foreign (lto "thinlto_codegen_set_cache_entry_expiration")
thinSetCacheEntryExpiration : ThinLTOCodeGeneratorRef -> Bits32 -> PrimIO ()

export %foreign (lto "thinlto_codegen_set_cache_size_megabytes")
thinSetCacheSizeMegabytes : ThinLTOCodeGeneratorRef -> Bits32 -> PrimIO ()
