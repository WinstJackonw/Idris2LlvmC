module LLVM.Raw.Analysis

import public LLVM.Raw.Enums
import public LLVM.Raw.Types

%default total

llvm : String -> String
llvm name = "C:idris2_llvm_" ++ name ++ ",libidris2_llvm"

export %foreign (llvm "verify_module")
verifyModule : ModuleRef -> LLVMVerifierFailureAction -> AnyPtr -> PrimIO Int32

export %foreign (llvm "verify_function")
verifyFunction : ValueRef -> LLVMVerifierFailureAction -> PrimIO Int32

