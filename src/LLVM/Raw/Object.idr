module LLVM.Raw.Object

import public LLVM.Raw.Types

%default total

llvm : String -> String
llvm name = "C:" ++ name ++ ",libLLVM"

public export LLVMBinaryType : Type
LLVMBinaryType = Int32

export %foreign (llvm "LLVMCreateBinary")
createBinary : MemoryBufferRef -> ContextRef -> AnyPtr -> PrimIO BinaryRef

export %foreign (llvm "LLVMDisposeBinary")
disposeBinary : BinaryRef -> PrimIO ()

export %foreign (llvm "LLVMBinaryGetType")
binaryGetType : BinaryRef -> PrimIO LLVMBinaryType

export %foreign (llvm "LLVMObjectFileCopySectionIterator")
copySectionIterator : BinaryRef -> PrimIO SectionIteratorRef

export %foreign (llvm "LLVMObjectFileIsSectionIteratorAtEnd")
isSectionIteratorAtEnd : BinaryRef -> SectionIteratorRef -> PrimIO Int32

export %foreign (llvm "LLVMDisposeSectionIterator")
disposeSectionIterator : SectionIteratorRef -> PrimIO ()

export %foreign (llvm "LLVMMoveToNextSection")
moveToNextSection : SectionIteratorRef -> PrimIO ()

export %foreign (llvm "LLVMGetSectionName")
getSectionName : SectionIteratorRef -> PrimIO (Ptr String)

export %foreign (llvm "LLVMGetSectionSize")
getSectionSize : SectionIteratorRef -> PrimIO Bits64

export %foreign (llvm "LLVMGetSectionAddress")
getSectionAddress : SectionIteratorRef -> PrimIO Bits64

export %foreign (llvm "LLVMGetRelocations")
getRelocations : SectionIteratorRef -> PrimIO RelocationIteratorRef

export %foreign (llvm "LLVMDisposeRelocationIterator")
disposeRelocationIterator : RelocationIteratorRef -> PrimIO ()

export %foreign (llvm "LLVMIsRelocationIteratorAtEnd")
isRelocationIteratorAtEnd : SectionIteratorRef -> RelocationIteratorRef -> PrimIO Int32

export %foreign (llvm "LLVMMoveToNextRelocation")
moveToNextRelocation : RelocationIteratorRef -> PrimIO ()

export %foreign (llvm "LLVMGetRelocationOffset")
getRelocationOffset : RelocationIteratorRef -> PrimIO Bits64

export %foreign (llvm "LLVMGetRelocationType")
getRelocationType : RelocationIteratorRef -> PrimIO Bits64

export %foreign (llvm "LLVMGetRelocationTypeName")
getRelocationTypeName : RelocationIteratorRef -> PrimIO (Ptr String)

export %foreign (llvm "LLVMGetRelocationValueString")
getRelocationValueString : RelocationIteratorRef -> PrimIO (Ptr String)

export %foreign (llvm "LLVMObjectFileCopySymbolIterator")
copySymbolIterator : BinaryRef -> PrimIO SymbolIteratorRef

export %foreign (llvm "LLVMObjectFileIsSymbolIteratorAtEnd")
isSymbolIteratorAtEnd : BinaryRef -> SymbolIteratorRef -> PrimIO Int32

export %foreign (llvm "LLVMDisposeSymbolIterator")
disposeSymbolIterator : SymbolIteratorRef -> PrimIO ()

export %foreign (llvm "LLVMMoveToNextSymbol")
moveToNextSymbol : SymbolIteratorRef -> PrimIO ()

export %foreign (llvm "LLVMGetSymbolName")
getSymbolName : SymbolIteratorRef -> PrimIO (Ptr String)

export %foreign (llvm "LLVMGetSymbolAddress")
getSymbolAddress : SymbolIteratorRef -> PrimIO Bits64

export %foreign (llvm "LLVMGetSymbolSize")
getSymbolSize : SymbolIteratorRef -> PrimIO Bits64
