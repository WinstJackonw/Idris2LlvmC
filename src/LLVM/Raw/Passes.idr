module LLVM.Raw.Passes

import public LLVM.Raw.Types

%default total

llvm : String -> String
llvm name = "C:idris2_llvm_" ++ name ++ ",libidris2_llvm"

export %foreign (llvm "create_pass_builder_options")
createPassBuilderOptions : PrimIO PassBuilderOptionsRef

export %foreign (llvm "dispose_pass_builder_options")
disposePassBuilderOptions : PassBuilderOptionsRef -> PrimIO ()

export %foreign (llvm "pass_builder_options_set_verify_each")
setVerifyEach : PassBuilderOptionsRef -> Int32 -> PrimIO ()

export %foreign (llvm "pass_builder_options_set_debug_logging")
setDebugLogging : PassBuilderOptionsRef -> Int32 -> PrimIO ()

export %foreign (llvm "run_passes")
runPasses : ModuleRef -> String -> TargetMachineRef -> PassBuilderOptionsRef -> PrimIO ErrorRef

export %foreign (llvm "error_is_success")
errorIsSuccess : ErrorRef -> PrimIO Int32

export %foreign (llvm "get_error_message")
getErrorMessage : ErrorRef -> PrimIO (Ptr String)

export %foreign (llvm "dispose_error_message")
disposeErrorMessage : Ptr String -> PrimIO ()

