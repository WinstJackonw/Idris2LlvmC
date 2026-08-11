module LLVM.Raw.Analysis

import public LLVM.Raw.Enums
import public LLVM.Raw.Types

%default total

llvm : String -> String
llvm name = "C:" ++ name ++ ",libLLVM"

export %foreign (llvm "LLVMVerifyModule")
verifyModule : ModuleRef -> LLVMVerifierFailureAction -> AnyPtr -> PrimIO Int32

export %foreign (llvm "LLVMVerifyFunction")
verifyFunction : ValueRef -> LLVMVerifierFailureAction -> PrimIO Int32
