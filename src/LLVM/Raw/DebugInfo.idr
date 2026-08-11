module LLVM.Raw.DebugInfo

import public LLVM.Raw.Enums
import public LLVM.Raw.Types

%default total

llvm : String -> String
llvm name = "C:" ++ name ++ ",libLLVM"

export %foreign (llvm "LLVMDebugMetadataVersion")
debugMetadataVersion : PrimIO Bits32

export %foreign (llvm "LLVMCreateDIBuilder")
createDIBuilder : ModuleRef -> PrimIO DIBuilderRef

export %foreign (llvm "LLVMDIBuilderFinalize")
finalizeDIBuilder : DIBuilderRef -> PrimIO ()

export %foreign (llvm "LLVMDisposeDIBuilder")
disposeDIBuilder : DIBuilderRef -> PrimIO ()

export %foreign (llvm "LLVMDIBuilderCreateFile")
createFile : DIBuilderRef -> String -> Bits64 -> String -> Bits64 -> PrimIO MetadataRef

export %foreign (llvm "LLVMDIBuilderCreateCompileUnit")
createCompileUnit : DIBuilderRef -> LLVMDWARFSourceLanguage -> MetadataRef -> String -> Bits64 -> Int32 -> String -> Bits64 -> Bits32 -> String -> Bits64 -> LLVMDWARFEmissionKind -> Bits32 -> Int32 -> Int32 -> String -> Bits64 -> String -> Bits64 -> PrimIO MetadataRef

export %foreign (llvm "LLVMDIBuilderCreateBasicType")
createBasicType : DIBuilderRef -> String -> Bits64 -> Bits64 -> Bits32 -> LLVMDIFlags -> PrimIO MetadataRef

export %foreign (llvm "LLVMDIBuilderCreatePointerType")
createPointerType : DIBuilderRef -> MetadataRef -> Bits64 -> Bits32 -> Bits32 -> String -> Bits64 -> PrimIO MetadataRef

export %foreign (llvm "LLVMDIBuilderCreateSubroutineType")
createSubroutineType : DIBuilderRef -> MetadataRef -> AnyPtr -> Bits32 -> LLVMDIFlags -> PrimIO MetadataRef

export %foreign (llvm "LLVMDIBuilderCreateFunction")
createFunction : DIBuilderRef -> MetadataRef -> String -> Bits64 -> String -> Bits64 -> MetadataRef -> Bits32 -> MetadataRef -> Int32 -> Int32 -> Bits32 -> LLVMDIFlags -> Int32 -> PrimIO MetadataRef

export %foreign (llvm "LLVMDIBuilderCreateLexicalBlock")
createLexicalBlock : DIBuilderRef -> MetadataRef -> MetadataRef -> Bits32 -> Bits32 -> PrimIO MetadataRef

export %foreign (llvm "LLVMDIBuilderCreateDebugLocation")
createDebugLocation : ContextRef -> Bits32 -> Bits32 -> MetadataRef -> MetadataRef -> PrimIO MetadataRef

export %foreign (llvm "LLVMDIBuilderCreateExpression")
createExpression : DIBuilderRef -> AnyPtr -> Bits64 -> PrimIO MetadataRef

export %foreign (llvm "LLVMDIBuilderCreateAutoVariable")
createAutoVariable : DIBuilderRef -> MetadataRef -> String -> Bits64 -> MetadataRef -> Bits32 -> MetadataRef -> Int32 -> LLVMDIFlags -> Bits32 -> PrimIO MetadataRef

export %foreign (llvm "LLVMDIBuilderCreateParameterVariable")
createParameterVariable : DIBuilderRef -> MetadataRef -> String -> Bits64 -> Bits32 -> MetadataRef -> Bits32 -> MetadataRef -> Int32 -> LLVMDIFlags -> PrimIO MetadataRef

export %foreign (llvm "LLVMDIBuilderInsertDeclareRecordAtEnd")
insertDeclareRecordAtEnd : DIBuilderRef -> ValueRef -> MetadataRef -> MetadataRef -> MetadataRef -> BasicBlockRef -> PrimIO DbgRecordRef

export %foreign (llvm "LLVMDIBuilderInsertDbgValueRecordAtEnd")
insertDbgValueRecordAtEnd : DIBuilderRef -> ValueRef -> MetadataRef -> MetadataRef -> MetadataRef -> BasicBlockRef -> PrimIO DbgRecordRef

export %foreign (llvm "LLVMSetSubprogram")
setSubprogram : ValueRef -> MetadataRef -> PrimIO ()

export %foreign (llvm "LLVMInstructionSetDebugLoc")
instructionSetDebugLoc : ValueRef -> MetadataRef -> PrimIO ()

export %foreign (llvm "LLVMSetCurrentDebugLocation2")
setCurrentDebugLocation : BuilderRef -> MetadataRef -> PrimIO ()
