module LLVM.Raw.Remarks

import public LLVM.Raw.Types

%default total

llvm : String -> String
llvm name = "C:" ++ name ++ ",libLLVM"

export %foreign (llvm "LLVMRemarkStringGetData")
stringGetData : RemarkStringRef -> PrimIO (Ptr String)

export %foreign (llvm "LLVMRemarkStringGetLen")
stringGetLength : RemarkStringRef -> PrimIO Bits32

export %foreign (llvm "LLVMRemarkDebugLocGetSourceFilePath")
debugLocGetSourceFilePath : RemarkDebugLocRef -> PrimIO RemarkStringRef

export %foreign (llvm "LLVMRemarkDebugLocGetSourceLine")
debugLocGetSourceLine : RemarkDebugLocRef -> PrimIO Bits32

export %foreign (llvm "LLVMRemarkDebugLocGetSourceColumn")
debugLocGetSourceColumn : RemarkDebugLocRef -> PrimIO Bits32

export %foreign (llvm "LLVMRemarkArgGetKey")
argGetKey : RemarkArgRef -> PrimIO RemarkStringRef

export %foreign (llvm "LLVMRemarkArgGetValue")
argGetValue : RemarkArgRef -> PrimIO RemarkStringRef

export %foreign (llvm "LLVMRemarkArgGetDebugLoc")
argGetDebugLoc : RemarkArgRef -> PrimIO RemarkDebugLocRef

export %foreign (llvm "LLVMRemarkEntryDispose")
entryDispose : RemarkEntryRef -> PrimIO ()

export %foreign (llvm "LLVMRemarkEntryGetType")
entryGetType : RemarkEntryRef -> PrimIO Int32

export %foreign (llvm "LLVMRemarkEntryGetPassName")
entryGetPassName : RemarkEntryRef -> PrimIO RemarkStringRef

export %foreign (llvm "LLVMRemarkEntryGetRemarkName")
entryGetRemarkName : RemarkEntryRef -> PrimIO RemarkStringRef

export %foreign (llvm "LLVMRemarkEntryGetFunctionName")
entryGetFunctionName : RemarkEntryRef -> PrimIO RemarkStringRef

export %foreign (llvm "LLVMRemarkEntryGetDebugLoc")
entryGetDebugLoc : RemarkEntryRef -> PrimIO RemarkDebugLocRef

export %foreign (llvm "LLVMRemarkEntryGetHotness")
entryGetHotness : RemarkEntryRef -> PrimIO Bits64

export %foreign (llvm "LLVMRemarkEntryGetNumArgs")
entryGetNumArgs : RemarkEntryRef -> PrimIO Bits32

export %foreign (llvm "LLVMRemarkEntryGetFirstArg")
entryGetFirstArg : RemarkEntryRef -> PrimIO RemarkArgRef

export %foreign (llvm "LLVMRemarkEntryGetNextArg")
entryGetNextArg : RemarkArgRef -> RemarkEntryRef -> PrimIO RemarkArgRef

export %foreign (llvm "LLVMRemarkParserCreateYAML")
parserCreateYAML : AnyPtr -> Bits64 -> PrimIO RemarkParserRef

export %foreign (llvm "LLVMRemarkParserCreateBitstream")
parserCreateBitstream : AnyPtr -> Bits64 -> PrimIO RemarkParserRef

export %foreign (llvm "LLVMRemarkParserGetNext")
parserGetNext : RemarkParserRef -> PrimIO RemarkEntryRef

export %foreign (llvm "LLVMRemarkParserHasError")
parserHasError : RemarkParserRef -> PrimIO Int32

export %foreign (llvm "LLVMRemarkParserGetErrorMessage")
parserGetErrorMessage : RemarkParserRef -> PrimIO (Ptr String)

export %foreign (llvm "LLVMRemarkParserDispose")
parserDispose : RemarkParserRef -> PrimIO ()
