module LLVM.Raw.Disassembler

import public LLVM.Raw.Types

%default total

llvm : String -> String
llvm name = "C:" ++ name ++ ",libLLVM"

shim : String -> String
shim name = "C:idris2_llvm_" ++ name ++ ",libidris2_llvm"

public export llvmDisassemblerOptionUseMarkup, llvmDisassemblerOptionPrintImmHex,
  llvmDisassemblerOptionAsmPrinterVariant, llvmDisassemblerOptionSetInstrComments,
  llvmDisassemblerOptionPrintLatency : Bits64
llvmDisassemblerOptionUseMarkup = 1
llvmDisassemblerOptionPrintImmHex = 2
llvmDisassemblerOptionAsmPrinterVariant = 4
llvmDisassemblerOptionSetInstrComments = 8
llvmDisassemblerOptionPrintLatency = 16

export %foreign (shim "create_disasm")
createDisasm : String -> String -> String -> PrimIO DisasmContextRef

export %foreign (llvm "LLVMSetDisasmOptions")
setDisasmOptions : DisasmContextRef -> Bits64 -> PrimIO Int32

export %foreign (llvm "LLVMDisasmDispose")
disposeDisasm : DisasmContextRef -> PrimIO ()

export %foreign (llvm "LLVMDisasmInstruction")
disasmInstruction : DisasmContextRef -> AnyPtr -> Bits64 -> Bits64 -> AnyPtr -> Bits64 -> PrimIO Bits64
