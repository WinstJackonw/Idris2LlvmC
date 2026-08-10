module LLVM.Raw.Target

import public LLVM.Raw.Enums
import public LLVM.Raw.Types

%default total

llvm : String -> String
llvm name = "C:idris2_llvm_" ++ name ++ ",libidris2_llvm"

export %foreign (llvm "initialize_all_target_infos")
initializeAllTargetInfos : PrimIO ()

export %foreign (llvm "initialize_all_targets")
initializeAllTargets : PrimIO ()

export %foreign (llvm "initialize_all_target_mcs")
initializeAllTargetMCs : PrimIO ()

export %foreign (llvm "initialize_all_asm_parsers")
initializeAllAsmParsers : PrimIO ()

export %foreign (llvm "initialize_all_asm_printers")
initializeAllAsmPrinters : PrimIO ()

export %foreign (llvm "initialize_native_target")
initializeNativeTarget : PrimIO Int32

export %foreign (llvm "initialize_native_asm_parser")
initializeNativeAsmParser : PrimIO Int32

export %foreign (llvm "initialize_native_asm_printer")
initializeNativeAsmPrinter : PrimIO Int32

export %foreign (llvm "get_default_target_triple")
getDefaultTargetTriple : PrimIO (Ptr String)

export %foreign (llvm "get_host_cpu_name")
getHostCPUName : PrimIO (Ptr String)

export %foreign (llvm "get_host_cpu_features")
getHostCPUFeatures : PrimIO (Ptr String)

export %foreign (llvm "get_target_from_triple")
getTargetFromTriple : String -> AnyPtr -> AnyPtr -> PrimIO Int32

export %foreign (llvm "get_target_name")
getTargetName : TargetRef -> PrimIO (Ptr String)

export %foreign (llvm "get_target_description")
getTargetDescription : TargetRef -> PrimIO (Ptr String)

export %foreign (llvm "create_target_machine")
createTargetMachine : TargetRef -> String -> String -> String -> LLVMCodeGenOptLevel -> LLVMRelocMode -> LLVMCodeModel -> PrimIO TargetMachineRef

export %foreign (llvm "dispose_target_machine")
disposeTargetMachine : TargetMachineRef -> PrimIO ()

export %foreign (llvm "get_target_machine_triple")
getTargetMachineTriple : TargetMachineRef -> PrimIO (Ptr String)

export %foreign (llvm "get_target_machine_cpu")
getTargetMachineCPU : TargetMachineRef -> PrimIO (Ptr String)

export %foreign (llvm "get_target_machine_feature_string")
getTargetMachineFeatureString : TargetMachineRef -> PrimIO (Ptr String)

export %foreign (llvm "create_target_data_layout")
createTargetDataLayout : TargetMachineRef -> PrimIO TargetDataRef

export %foreign (llvm "dispose_target_data")
disposeTargetData : TargetDataRef -> PrimIO ()

export %foreign (llvm "copy_string_rep_of_target_data")
copyStringRepOfTargetData : TargetDataRef -> PrimIO (Ptr String)

export %foreign (llvm "abi_size_of_type")
abiSizeOfType : TargetDataRef -> TypeRef -> PrimIO Bits64

export %foreign (llvm "abi_alignment_of_type")
abiAlignmentOfType : TargetDataRef -> TypeRef -> PrimIO Bits32

export %foreign (llvm "target_machine_emit_to_file")
targetMachineEmitToFile : TargetMachineRef -> ModuleRef -> String -> LLVMCodeGenFileType -> AnyPtr -> PrimIO Int32

export %foreign (llvm "target_machine_emit_to_memory_buffer")
targetMachineEmitToMemoryBuffer : TargetMachineRef -> ModuleRef -> LLVMCodeGenFileType -> AnyPtr -> AnyPtr -> PrimIO Int32

