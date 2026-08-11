module LLVM.Raw.Linker

import public LLVM.Raw.Types

%default total

llvm : String -> String
llvm name = "C:" ++ name ++ ",libLLVM"

||| Links source into destination and always destroys source.
export %foreign (llvm "LLVMLinkModules2")
linkModules : ModuleRef -> ModuleRef -> PrimIO Int32
