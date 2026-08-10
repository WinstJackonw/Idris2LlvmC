module LLVM.Raw.IRReader

import public LLVM.Raw.Types

%default total

llvm : String -> String
llvm name = "C:idris2_llvm_" ++ name ++ ",libidris2_llvm"

export %foreign (llvm "parse_ir_in_context2")
parseIRInContext : ContextRef -> MemoryBufferRef -> AnyPtr -> AnyPtr -> PrimIO Int32

