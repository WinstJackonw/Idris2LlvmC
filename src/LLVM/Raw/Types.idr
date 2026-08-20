module LLVM.Raw.Types

%default total

public export data ContextTag : Type where
public export data ModuleTag : Type where
public export data TypeTag : Type where
public export data ValueTag : Type where
public export data BasicBlockTag : Type where
public export data BuilderTag : Type where
public export data MemoryBufferTag : Type where
public export data AttributeTag : Type where
public export data MetadataTag : Type where
public export data NamedMetadataTag : Type where
public export data UseTag : Type where
public export data ComdatTag : Type where
public export data ErrorTag : Type where
public export data TargetTag : Type where
public export data TargetMachineTag : Type where
public export data TargetMachineOptionsTag : Type where
public export data TargetDataTag : Type where
public export data PassBuilderOptionsTag : Type where
public export data DIBuilderTag : Type where
public export data DbgRecordTag : Type where
public export data DisasmContextTag : Type where
public export data BinaryTag : Type where
public export data SectionIteratorTag : Type where
public export data SymbolIteratorTag : Type where
public export data RelocationIteratorTag : Type where
public export data RemarkStringTag : Type where
public export data RemarkDebugLocTag : Type where
public export data RemarkArgTag : Type where
public export data RemarkEntryTag : Type where
public export data RemarkParserTag : Type where
public export data OrcThreadSafeContextTag : Type where
public export data OrcThreadSafeModuleTag : Type where
public export data OrcLLJITBuilderTag : Type where
public export data OrcLLJITTag : Type where
public export data OrcJITDylibTag : Type where
public export data OrcExecutorSessionTag : Type where
public export data OrcResourceTrackerTag : Type where
public export data LTOModuleTag : Type where
public export data LTOCodeGeneratorTag : Type where
public export data ThinLTOCodeGeneratorTag : Type where

public export ContextRef : Type
ContextRef = Ptr ContextTag

public export ModuleRef : Type
ModuleRef = Ptr ModuleTag

public export TypeRef : Type
TypeRef = Ptr TypeTag

public export ValueRef : Type
ValueRef = Ptr ValueTag

public export BasicBlockRef : Type
BasicBlockRef = Ptr BasicBlockTag

public export BuilderRef : Type
BuilderRef = Ptr BuilderTag

public export MemoryBufferRef : Type
MemoryBufferRef = Ptr MemoryBufferTag

public export AttributeRef : Type
AttributeRef = Ptr AttributeTag

public export MetadataRef : Type
MetadataRef = Ptr MetadataTag

public export NamedMetadataRef : Type
NamedMetadataRef = Ptr NamedMetadataTag

public export UseRef : Type
UseRef = Ptr UseTag

public export ComdatRef : Type
ComdatRef = Ptr ComdatTag

public export ErrorRef : Type
ErrorRef = Ptr ErrorTag

public export TargetRef : Type
TargetRef = Ptr TargetTag

public export TargetMachineRef : Type
TargetMachineRef = Ptr TargetMachineTag

public export TargetMachineOptionsRef : Type
TargetMachineOptionsRef = Ptr TargetMachineOptionsTag

public export TargetDataRef : Type
TargetDataRef = Ptr TargetDataTag

public export PassBuilderOptionsRef : Type
PassBuilderOptionsRef = Ptr PassBuilderOptionsTag

public export DIBuilderRef : Type
DIBuilderRef = Ptr DIBuilderTag

public export DbgRecordRef : Type
DbgRecordRef = Ptr DbgRecordTag

public export DisasmContextRef : Type
DisasmContextRef = Ptr DisasmContextTag

public export BinaryRef : Type
BinaryRef = Ptr BinaryTag

public export SectionIteratorRef : Type
SectionIteratorRef = Ptr SectionIteratorTag

public export SymbolIteratorRef : Type
SymbolIteratorRef = Ptr SymbolIteratorTag

public export RelocationIteratorRef : Type
RelocationIteratorRef = Ptr RelocationIteratorTag

public export RemarkStringRef : Type
RemarkStringRef = Ptr RemarkStringTag

public export RemarkDebugLocRef : Type
RemarkDebugLocRef = Ptr RemarkDebugLocTag

public export RemarkArgRef : Type
RemarkArgRef = Ptr RemarkArgTag

public export RemarkEntryRef : Type
RemarkEntryRef = Ptr RemarkEntryTag

public export RemarkParserRef : Type
RemarkParserRef = Ptr RemarkParserTag

public export OrcThreadSafeContextRef : Type
OrcThreadSafeContextRef = Ptr OrcThreadSafeContextTag

public export OrcThreadSafeModuleRef : Type
OrcThreadSafeModuleRef = Ptr OrcThreadSafeModuleTag

public export OrcLLJITBuilderRef : Type
OrcLLJITBuilderRef = Ptr OrcLLJITBuilderTag

public export OrcLLJITRef : Type
OrcLLJITRef = Ptr OrcLLJITTag

public export OrcJITDylibRef : Type
OrcJITDylibRef = Ptr OrcJITDylibTag

public export OrcExecutionSessionRef : Type
OrcExecutionSessionRef = Ptr OrcExecutorSessionTag

public export OrcResourceTrackerRef : Type
OrcResourceTrackerRef = Ptr OrcResourceTrackerTag

public export LTOModuleRef : Type
LTOModuleRef = Ptr LTOModuleTag

public export LTOCodeGeneratorRef : Type
LTOCodeGeneratorRef = Ptr LTOCodeGeneratorTag

public export ThinLTOCodeGeneratorRef : Type
ThinLTOCodeGeneratorRef = Ptr ThinLTOCodeGeneratorTag

public export forgetRef : Ptr tag -> AnyPtr
forgetRef = prim__forgetPtr

public export castRef : AnyPtr -> Ptr tag
castRef = prim__castPtr

public export isNullRef : Ptr tag -> Bool
isNullRef p = prim__nullPtr p /= 0
