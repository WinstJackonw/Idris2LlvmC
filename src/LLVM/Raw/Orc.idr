module LLVM.Raw.Orc

import public LLVM.Raw.Types

%default total

llvm : String -> String
llvm name = "C:" ++ name ++ ",libLLVM"

shim : String -> String
shim name = "C:idris2_llvm_" ++ name ++ ",libidris2_llvm"

export %foreign (llvm "LLVMOrcCreateNewThreadSafeContext")
createThreadSafeContext : PrimIO OrcThreadSafeContextRef

export %foreign (llvm "LLVMOrcCreateNewThreadSafeContextFromLLVMContext")
createThreadSafeContextFromContext : ContextRef -> PrimIO OrcThreadSafeContextRef

export %foreign (llvm "LLVMOrcDisposeThreadSafeContext")
disposeThreadSafeContext : OrcThreadSafeContextRef -> PrimIO ()

export %foreign (llvm "LLVMOrcCreateNewThreadSafeModule")
createThreadSafeModule : ModuleRef -> OrcThreadSafeContextRef -> PrimIO OrcThreadSafeModuleRef

export %foreign (llvm "LLVMOrcDisposeThreadSafeModule")
disposeThreadSafeModule : OrcThreadSafeModuleRef -> PrimIO ()

export %foreign (llvm "LLVMOrcCreateLLJITBuilder")
createLLJITBuilder : PrimIO OrcLLJITBuilderRef

export %foreign (llvm "LLVMOrcDisposeLLJITBuilder")
disposeLLJITBuilder : OrcLLJITBuilderRef -> PrimIO ()

export %foreign (llvm "LLVMOrcCreateLLJIT")
createLLJIT : AnyPtr -> OrcLLJITBuilderRef -> PrimIO ErrorRef

export %foreign (llvm "LLVMOrcDisposeLLJIT")
disposeLLJIT : OrcLLJITRef -> PrimIO ErrorRef

export %foreign (llvm "LLVMOrcLLJITGetExecutionSession")
getExecutionSession : OrcLLJITRef -> PrimIO OrcExecutionSessionRef

export %foreign (llvm "LLVMOrcLLJITGetMainJITDylib")
getMainJITDylib : OrcLLJITRef -> PrimIO OrcJITDylibRef

export %foreign (llvm "LLVMOrcLLJITGetTripleString")
getTripleString : OrcLLJITRef -> PrimIO (Ptr String)

export %foreign (llvm "LLVMOrcLLJITGetDataLayoutStr")
getDataLayoutString : OrcLLJITRef -> PrimIO (Ptr String)

export %foreign (llvm "LLVMOrcLLJITAddObjectFile")
addObjectFile : OrcLLJITRef -> OrcJITDylibRef -> MemoryBufferRef -> PrimIO ErrorRef

export %foreign (llvm "LLVMOrcLLJITAddLLVMIRModule")
addIRModule : OrcLLJITRef -> OrcJITDylibRef -> OrcThreadSafeModuleRef -> PrimIO ErrorRef

export %foreign (llvm "LLVMOrcLLJITLookup")
lookup : OrcLLJITRef -> AnyPtr -> String -> PrimIO ErrorRef

export %foreign (shim "call_jit_u64_0")
callJITU64_0 : Bits64 -> PrimIO Bits64

export %foreign (shim "call_jit_u64_1")
callJITU64_1 : Bits64 -> Bits64 -> PrimIO Bits64

export %foreign (shim "call_jit_u64_2")
callJITU64_2 : Bits64 -> Bits64 -> Bits64 -> PrimIO Bits64
