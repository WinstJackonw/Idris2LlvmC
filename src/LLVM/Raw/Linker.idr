module LLVM.Raw.Linker

import public LLVM.Raw.Types

%default total

llvm : String -> String
llvm name = "C:idris2_llvm_" ++ name ++ ",libidris2_llvm"

||| Links source into destination and always destroys source.
export %foreign (llvm "link_modules2")
linkModules : ModuleRef -> ModuleRef -> PrimIO Int32

