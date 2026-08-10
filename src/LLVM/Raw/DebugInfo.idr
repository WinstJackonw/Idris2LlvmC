module LLVM.Raw.DebugInfo

import public LLVM.Raw.Enums
import public LLVM.Raw.Types

%default total

llvm : String -> String
llvm name = "C:idris2_llvm_" ++ name ++ ",libidris2_llvm"

export %foreign (llvm "debug_metadata_version")
debugMetadataVersion : PrimIO Bits32

export %foreign (llvm "create_di_builder")
createDIBuilder : ModuleRef -> PrimIO DIBuilderRef

export %foreign (llvm "di_builder_finalize")
finalizeDIBuilder : DIBuilderRef -> PrimIO ()

export %foreign (llvm "dispose_di_builder")
disposeDIBuilder : DIBuilderRef -> PrimIO ()

export %foreign (llvm "di_builder_create_file")
createFile : DIBuilderRef -> String -> Bits64 -> String -> Bits64 -> PrimIO MetadataRef

export %foreign (llvm "di_builder_create_compile_unit")
createCompileUnit : DIBuilderRef -> LLVMDWARFSourceLanguage -> MetadataRef -> String -> Bits64 -> Int32 -> String -> Bits64 -> Bits32 -> String -> Bits64 -> LLVMDWARFEmissionKind -> Bits32 -> Int32 -> Int32 -> String -> Bits64 -> String -> Bits64 -> PrimIO MetadataRef

export %foreign (llvm "di_builder_create_basic_type")
createBasicType : DIBuilderRef -> String -> Bits64 -> Bits64 -> Bits32 -> LLVMDIFlags -> PrimIO MetadataRef

export %foreign (llvm "di_builder_create_pointer_type")
createPointerType : DIBuilderRef -> MetadataRef -> Bits64 -> Bits32 -> Bits32 -> String -> Bits64 -> PrimIO MetadataRef

export %foreign (llvm "di_builder_create_subroutine_type")
createSubroutineType : DIBuilderRef -> MetadataRef -> AnyPtr -> Bits32 -> LLVMDIFlags -> PrimIO MetadataRef

export %foreign (llvm "di_builder_create_function")
createFunction : DIBuilderRef -> MetadataRef -> String -> Bits64 -> String -> Bits64 -> MetadataRef -> Bits32 -> MetadataRef -> Int32 -> Int32 -> Bits32 -> LLVMDIFlags -> Int32 -> PrimIO MetadataRef

export %foreign (llvm "di_builder_create_lexical_block")
createLexicalBlock : DIBuilderRef -> MetadataRef -> MetadataRef -> Bits32 -> Bits32 -> PrimIO MetadataRef

export %foreign (llvm "di_builder_create_debug_location")
createDebugLocation : ContextRef -> Bits32 -> Bits32 -> MetadataRef -> MetadataRef -> PrimIO MetadataRef

export %foreign (llvm "di_builder_create_expression")
createExpression : DIBuilderRef -> AnyPtr -> Bits64 -> PrimIO MetadataRef

export %foreign (llvm "di_builder_create_auto_variable")
createAutoVariable : DIBuilderRef -> MetadataRef -> String -> Bits64 -> MetadataRef -> Bits32 -> MetadataRef -> Int32 -> LLVMDIFlags -> Bits32 -> PrimIO MetadataRef

export %foreign (llvm "di_builder_create_parameter_variable")
createParameterVariable : DIBuilderRef -> MetadataRef -> String -> Bits64 -> Bits32 -> MetadataRef -> Bits32 -> MetadataRef -> Int32 -> LLVMDIFlags -> PrimIO MetadataRef

export %foreign (llvm "di_builder_insert_declare_record_at_end")
insertDeclareRecordAtEnd : DIBuilderRef -> ValueRef -> MetadataRef -> MetadataRef -> MetadataRef -> BasicBlockRef -> PrimIO DbgRecordRef

export %foreign (llvm "di_builder_insert_dbg_value_record_at_end")
insertDbgValueRecordAtEnd : DIBuilderRef -> ValueRef -> MetadataRef -> MetadataRef -> MetadataRef -> BasicBlockRef -> PrimIO DbgRecordRef

export %foreign (llvm "set_subprogram")
setSubprogram : ValueRef -> MetadataRef -> PrimIO ()

export %foreign (llvm "instruction_set_debug_loc")
instructionSetDebugLoc : ValueRef -> MetadataRef -> PrimIO ()

export %foreign (llvm "set_current_debug_location2")
setCurrentDebugLocation : BuilderRef -> MetadataRef -> PrimIO ()

