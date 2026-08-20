module LLVM.Raw.ErrorHandling

%default total

llvm : String -> String
llvm name = "C:" ++ name ++ ",libLLVM"

export %foreign (llvm "LLVMInstallFatalErrorHandler")
installFatalErrorHandler : (String -> ()) -> PrimIO ()

export %foreign (llvm "LLVMResetFatalErrorHandler")
resetFatalErrorHandler : PrimIO ()

export %foreign (llvm "LLVMEnablePrettyStackTrace")
enablePrettyStackTrace : PrimIO ()
