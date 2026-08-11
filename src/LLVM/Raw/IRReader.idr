module LLVM.Raw.IRReader

import public LLVM.Raw.Types

%default total

llvm : String -> String
llvm name = "C:" ++ name ++ ",libLLVM"

export %foreign (llvm "LLVMParseIRInContext2")
parseIRInContext : ContextRef -> MemoryBufferRef -> AnyPtr -> AnyPtr -> PrimIO Int32
