module LLVM.Raw.Bitcode

import public LLVM.Raw.Types

%default total

llvm : String -> String
llvm name = "C:idris2_llvm_" ++ name ++ ",libidris2_llvm"

export %foreign (llvm "parse_bitcode_in_context2")
parseBitcodeInContext : ContextRef -> MemoryBufferRef -> AnyPtr -> PrimIO Int32

export %foreign (llvm "write_bitcode_to_file")
writeBitcodeToFile : ModuleRef -> String -> PrimIO Int32

export %foreign (llvm "write_bitcode_to_memory_buffer")
writeBitcodeToMemoryBuffer : ModuleRef -> PrimIO MemoryBufferRef

