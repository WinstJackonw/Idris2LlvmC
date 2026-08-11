module LLVM.Raw.Bitcode

import public LLVM.Raw.Types

%default total

llvm : String -> String
llvm name = "C:" ++ name ++ ",libLLVM"

export %foreign (llvm "LLVMParseBitcodeInContext2")
parseBitcodeInContext : ContextRef -> MemoryBufferRef -> AnyPtr -> PrimIO Int32

export %foreign (llvm "LLVMWriteBitcodeToFile")
writeBitcodeToFile : ModuleRef -> String -> PrimIO Int32

export %foreign (llvm "LLVMWriteBitcodeToMemoryBuffer")
writeBitcodeToMemoryBuffer : ModuleRef -> PrimIO MemoryBufferRef
