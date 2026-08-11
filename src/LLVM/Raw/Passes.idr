module LLVM.Raw.Passes

import public LLVM.Raw.Types

%default total

llvm : String -> String
llvm name = "C:" ++ name ++ ",libLLVM"

shim : String -> String
shim name = "C:idris2_llvm_" ++ name ++ ",libidris2_llvm"

export %foreign (llvm "LLVMCreatePassBuilderOptions")
createPassBuilderOptions : PrimIO PassBuilderOptionsRef

export %foreign (llvm "LLVMDisposePassBuilderOptions")
disposePassBuilderOptions : PassBuilderOptionsRef -> PrimIO ()

export %foreign (llvm "LLVMPassBuilderOptionsSetVerifyEach")
setVerifyEach : PassBuilderOptionsRef -> Int32 -> PrimIO ()

export %foreign (llvm "LLVMPassBuilderOptionsSetDebugLogging")
setDebugLogging : PassBuilderOptionsRef -> Int32 -> PrimIO ()

export %foreign (llvm "LLVMRunPasses")
runPasses : ModuleRef -> String -> TargetMachineRef -> PassBuilderOptionsRef -> PrimIO ErrorRef

export %foreign (shim "error_is_success")
errorIsSuccess : ErrorRef -> PrimIO Int32

export %foreign (llvm "LLVMGetErrorMessage")
getErrorMessage : ErrorRef -> PrimIO (Ptr String)

export %foreign (llvm "LLVMDisposeErrorMessage")
disposeErrorMessage : Ptr String -> PrimIO ()

