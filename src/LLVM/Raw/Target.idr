module LLVM.Raw.Target

import public LLVM.Raw.Enums
import public LLVM.Raw.Types

%default total

llvm : String -> String
llvm name = "C:" ++ name ++ ",libLLVM"

shim : String -> String
shim name = "C:idris2_llvm_" ++ name ++ ",libidris2_llvm"

export %foreign (shim "initialize_all_target_infos")
initializeAllTargetInfos : PrimIO ()

export %foreign (shim "initialize_all_targets")
initializeAllTargets : PrimIO ()

export %foreign (shim "initialize_all_target_mcs")
initializeAllTargetMCs : PrimIO ()

export %foreign (shim "initialize_all_asm_parsers")
initializeAllAsmParsers : PrimIO ()

export %foreign (shim "initialize_all_asm_printers")
initializeAllAsmPrinters : PrimIO ()

export %foreign (shim "initialize_all_disassemblers")
initializeAllDisassemblers : PrimIO ()

export %foreign (shim "initialize_native_target")
initializeNativeTarget : PrimIO Int32

export %foreign (shim "initialize_native_asm_parser")
initializeNativeAsmParser : PrimIO Int32

export %foreign (shim "initialize_native_asm_printer")
initializeNativeAsmPrinter : PrimIO Int32

export %foreign (llvm "LLVMGetDefaultTargetTriple")
getDefaultTargetTriple : PrimIO (Ptr String)

export %foreign (llvm "LLVMGetHostCPUName")
getHostCPUName : PrimIO (Ptr String)

export %foreign (llvm "LLVMGetHostCPUFeatures")
getHostCPUFeatures : PrimIO (Ptr String)

export %foreign (llvm "LLVMGetTargetFromTriple")
getTargetFromTriple : String -> AnyPtr -> AnyPtr -> PrimIO Int32

export %foreign (llvm "LLVMGetTargetName")
getTargetName : TargetRef -> PrimIO (Ptr String)

export %foreign (llvm "LLVMGetTargetDescription")
getTargetDescription : TargetRef -> PrimIO (Ptr String)

export %foreign (llvm "LLVMCreateTargetMachine")
createTargetMachine : TargetRef -> String -> String -> String -> LLVMCodeGenOptLevel -> LLVMRelocMode -> LLVMCodeModel -> PrimIO TargetMachineRef

export %foreign (llvm "LLVMDisposeTargetMachine")
disposeTargetMachine : TargetMachineRef -> PrimIO ()

export %foreign (llvm "LLVMGetTargetMachineTriple")
getTargetMachineTriple : TargetMachineRef -> PrimIO (Ptr String)

export %foreign (llvm "LLVMGetTargetMachineCPU")
getTargetMachineCPU : TargetMachineRef -> PrimIO (Ptr String)

export %foreign (llvm "LLVMGetTargetMachineFeatureString")
getTargetMachineFeatureString : TargetMachineRef -> PrimIO (Ptr String)

export %foreign (llvm "LLVMCreateTargetDataLayout")
createTargetDataLayout : TargetMachineRef -> PrimIO TargetDataRef

export %foreign (llvm "LLVMDisposeTargetData")
disposeTargetData : TargetDataRef -> PrimIO ()

export %foreign (llvm "LLVMCopyStringRepOfTargetData")
copyStringRepOfTargetData : TargetDataRef -> PrimIO (Ptr String)

export %foreign (llvm "LLVMABISizeOfType")
abiSizeOfType : TargetDataRef -> TypeRef -> PrimIO Bits64

export %foreign (llvm "LLVMABIAlignmentOfType")
abiAlignmentOfType : TargetDataRef -> TypeRef -> PrimIO Bits32

export %foreign (llvm "LLVMTargetMachineEmitToFile")
targetMachineEmitToFile : TargetMachineRef -> ModuleRef -> String -> LLVMCodeGenFileType -> AnyPtr -> PrimIO Int32

export %foreign (llvm "LLVMTargetMachineEmitToMemoryBuffer")
targetMachineEmitToMemoryBuffer : TargetMachineRef -> ModuleRef -> LLVMCodeGenFileType -> AnyPtr -> AnyPtr -> PrimIO Int32
