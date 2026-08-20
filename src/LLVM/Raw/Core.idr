module LLVM.Raw.Core

import public LLVM.Raw.Enums
import public LLVM.Raw.Types

%default total

llvm : String -> String
llvm name = "C:" ++ name ++ ",libLLVM"

shim : String -> String
shim name = "C:idris2_llvm_" ++ name ++ ",libidris2_llvm"

export %foreign (shim "shim_abi_version")
shimABIVersion : PrimIO Bits32

export %foreign (shim "version_major")
versionMajor : PrimIO Bits32

export %foreign (shim "version_minor")
versionMinor : PrimIO Bits32

export %foreign (shim "version_patch")
versionPatch : PrimIO Bits32

export %foreign (llvm "LLVMContextCreate")
contextCreate : PrimIO ContextRef

export %foreign (llvm "LLVMContextDispose")
contextDispose : ContextRef -> PrimIO ()

export %foreign (llvm "LLVMModuleCreateWithNameInContext")
moduleCreateWithNameInContext : String -> ContextRef -> PrimIO ModuleRef

export %foreign (llvm "LLVMCloneModule")
cloneModule : ModuleRef -> PrimIO ModuleRef

export %foreign (llvm "LLVMDisposeModule")
disposeModule : ModuleRef -> PrimIO ()

export %foreign (llvm "LLVMGetModuleContext")
getModuleContext : ModuleRef -> PrimIO ContextRef

export %foreign (llvm "LLVMGetModuleIdentifier")
getModuleIdentifier : ModuleRef -> AnyPtr -> PrimIO (Ptr String)

export %foreign (llvm "LLVMSetModuleIdentifier")
setModuleIdentifier : ModuleRef -> String -> Bits64 -> PrimIO ()

export %foreign (llvm "LLVMGetTarget")
getModuleTarget : ModuleRef -> PrimIO (Ptr String)

export %foreign (llvm "LLVMSetTarget")
setModuleTarget : ModuleRef -> String -> PrimIO ()

export %foreign (llvm "LLVMGetDataLayoutStr")
getModuleDataLayout : ModuleRef -> PrimIO (Ptr String)

export %foreign (llvm "LLVMSetDataLayout")
setModuleDataLayout : ModuleRef -> String -> PrimIO ()

export %foreign (llvm "LLVMAddModuleFlag")
addModuleFlag : ModuleRef -> LLVMModuleFlagBehavior -> String -> Bits64 -> MetadataRef -> PrimIO ()

export %foreign (llvm "LLVMPrintModuleToString")
printModuleToString : ModuleRef -> PrimIO (Ptr String)

export %foreign (llvm "LLVMPrintModuleToFile")
printModuleToFile : ModuleRef -> String -> AnyPtr -> PrimIO Int32

export %foreign (llvm "LLVMDumpModule")
dumpModule : ModuleRef -> PrimIO ()

export %foreign (llvm "LLVMDisposeMessage")
disposeMessage : Ptr String -> PrimIO ()

export %foreign (llvm "LLVMGetTypeKind")
getTypeKind : TypeRef -> PrimIO LLVMTypeKind

export %foreign (llvm "LLVMTypeIsSized")
typeIsSized : TypeRef -> PrimIO Int32

export %foreign (llvm "LLVMIntTypeInContext")
intTypeInContext : ContextRef -> Bits32 -> PrimIO TypeRef

export %foreign (llvm "LLVMInt1TypeInContext")
int1TypeInContext : ContextRef -> PrimIO TypeRef

export %foreign (llvm "LLVMInt8TypeInContext")
int8TypeInContext : ContextRef -> PrimIO TypeRef

export %foreign (llvm "LLVMInt16TypeInContext")
int16TypeInContext : ContextRef -> PrimIO TypeRef

export %foreign (llvm "LLVMInt32TypeInContext")
int32TypeInContext : ContextRef -> PrimIO TypeRef

export %foreign (llvm "LLVMInt64TypeInContext")
int64TypeInContext : ContextRef -> PrimIO TypeRef

export %foreign (llvm "LLVMGetIntTypeWidth")
getIntTypeWidth : TypeRef -> PrimIO Bits32

export %foreign (llvm "LLVMHalfTypeInContext")
halfTypeInContext : ContextRef -> PrimIO TypeRef

export %foreign (llvm "LLVMFloatTypeInContext")
floatTypeInContext : ContextRef -> PrimIO TypeRef

export %foreign (llvm "LLVMDoubleTypeInContext")
doubleTypeInContext : ContextRef -> PrimIO TypeRef

export %foreign (llvm "LLVMVoidTypeInContext")
voidTypeInContext : ContextRef -> PrimIO TypeRef

export %foreign (llvm "LLVMPointerTypeInContext")
pointerTypeInContext : ContextRef -> Bits32 -> PrimIO TypeRef

export %foreign (llvm "LLVMArrayType2")
arrayType : TypeRef -> Bits64 -> PrimIO TypeRef

export %foreign (llvm "LLVMVectorType")
vectorType : TypeRef -> Bits32 -> PrimIO TypeRef

export %foreign (llvm "LLVMScalableVectorType")
scalableVectorType : TypeRef -> Bits32 -> PrimIO TypeRef

export %foreign (llvm "LLVMGetElementType")
getElementType : TypeRef -> PrimIO TypeRef

export %foreign (llvm "LLVMGetVectorSize")
getVectorSize : TypeRef -> PrimIO Bits32

export %foreign (llvm "LLVMFunctionType")
functionType : TypeRef -> AnyPtr -> Bits32 -> Int32 -> PrimIO TypeRef

export %foreign (llvm "LLVMStructTypeInContext")
structTypeInContext : ContextRef -> AnyPtr -> Bits32 -> Int32 -> PrimIO TypeRef

export %foreign (llvm "LLVMStructCreateNamed")
structCreateNamed : ContextRef -> String -> PrimIO TypeRef

export %foreign (llvm "LLVMStructSetBody")
structSetBody : TypeRef -> AnyPtr -> Bits32 -> Int32 -> PrimIO ()

export %foreign (llvm "LLVMPrintTypeToString")
printTypeToString : TypeRef -> PrimIO (Ptr String)

export %foreign (llvm "LLVMConstNull")
constNull : TypeRef -> PrimIO ValueRef

export %foreign (llvm "LLVMGetUndef")
getUndef : TypeRef -> PrimIO ValueRef

export %foreign (llvm "LLVMGetPoison")
getPoison : TypeRef -> PrimIO ValueRef

export %foreign (llvm "LLVMConstInt")
constInt : TypeRef -> Bits64 -> Int32 -> PrimIO ValueRef

export %foreign (llvm "LLVMConstReal")
constReal : TypeRef -> Double -> PrimIO ValueRef

export %foreign (llvm "LLVMConstStringInContext2")
constStringInContext : ContextRef -> String -> Bits64 -> Int32 -> PrimIO ValueRef

export %foreign (llvm "LLVMConstArray2")
constArray : TypeRef -> AnyPtr -> Bits64 -> PrimIO ValueRef

export %foreign (llvm "LLVMConstStructInContext")
constStructInContext : ContextRef -> AnyPtr -> Bits32 -> Int32 -> PrimIO ValueRef

export %foreign (llvm "LLVMConstNamedStruct")
constNamedStruct : TypeRef -> AnyPtr -> Bits32 -> PrimIO ValueRef

export %foreign (llvm "LLVMConstVector")
constVector : AnyPtr -> Bits32 -> PrimIO ValueRef

export %foreign (llvm "LLVMTypeOf")
typeOf : ValueRef -> PrimIO TypeRef

export %foreign (llvm "LLVMGlobalGetValueType")
globalValueType : ValueRef -> PrimIO TypeRef

export %foreign (llvm "LLVMGetValueKind")
getValueKind : ValueRef -> PrimIO Int32

export %foreign (llvm "LLVMGetEnumAttributeKindForName")
getEnumAttributeKindForName : String -> Bits64 -> PrimIO Bits32

export %foreign (llvm "LLVMCreateEnumAttribute")
createEnumAttribute : ContextRef -> Bits32 -> Bits64 -> PrimIO AttributeRef

export %foreign (llvm "LLVMCreateStringAttribute")
createStringAttribute : ContextRef -> String -> Bits32 -> String -> Bits32 -> PrimIO AttributeRef

export %foreign (llvm "LLVMAddAttributeAtIndex")
addAttributeAtIndex : ValueRef -> Bits32 -> AttributeRef -> PrimIO ()

export %foreign (llvm "LLVMRemoveEnumAttributeAtIndex")
removeEnumAttributeAtIndex : ValueRef -> Bits32 -> Bits32 -> PrimIO ()

export %foreign (llvm "LLVMRemoveStringAttributeAtIndex")
removeStringAttributeAtIndex : ValueRef -> Bits32 -> String -> Bits32 -> PrimIO ()

export %foreign (llvm "LLVMGetValueName2")
getValueName : ValueRef -> AnyPtr -> PrimIO (Ptr String)

export %foreign (llvm "LLVMSetValueName2")
setValueName : ValueRef -> String -> Bits64 -> PrimIO ()

export %foreign (llvm "LLVMPrintValueToString")
printValueToString : ValueRef -> PrimIO (Ptr String)

export %foreign (llvm "LLVMReplaceAllUsesWith")
replaceAllUsesWith : ValueRef -> ValueRef -> PrimIO ()

export %foreign (llvm "LLVMIsConstant")
isConstant : ValueRef -> PrimIO Int32

export %foreign (llvm "LLVMIsNull")
isNullValue : ValueRef -> PrimIO Int32

export %foreign (llvm "LLVMAddFunction")
addFunction : ModuleRef -> String -> TypeRef -> PrimIO ValueRef

export %foreign (llvm "LLVMGetNamedFunction")
getNamedFunction : ModuleRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMCountParams")
countParams : ValueRef -> PrimIO Bits32

export %foreign (llvm "LLVMGetParam")
getParam : ValueRef -> Bits32 -> PrimIO ValueRef

export %foreign (llvm "LLVMSetFunctionCallConv")
setFunctionCallConv : ValueRef -> Bits32 -> PrimIO ()

export %foreign (llvm "LLVMGetFunctionCallConv")
getFunctionCallConv : ValueRef -> PrimIO Bits32

export %foreign (llvm "LLVMSetPersonalityFn")
setPersonalityFn : ValueRef -> ValueRef -> PrimIO ()

export %foreign (llvm "LLVMAddGlobal")
addGlobal : ModuleRef -> TypeRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMGetNamedGlobal")
getNamedGlobal : ModuleRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMSetInitializer")
setInitializer : ValueRef -> ValueRef -> PrimIO ()

export %foreign (llvm "LLVMSetGlobalConstant")
setGlobalConstant : ValueRef -> Int32 -> PrimIO ()

export %foreign (llvm "LLVMSetLinkage")
setLinkage : ValueRef -> LLVMLinkage -> PrimIO ()

export %foreign (llvm "LLVMGetLinkage")
getLinkage : ValueRef -> PrimIO LLVMLinkage

export %foreign (llvm "LLVMSetSection")
setSection : ValueRef -> String -> PrimIO ()

export %foreign (llvm "LLVMSetAlignment")
setAlignment : ValueRef -> Bits32 -> PrimIO ()

export %foreign (llvm "LLVMGetAlignment")
getAlignment : ValueRef -> PrimIO Bits32

export %foreign (llvm "LLVMAppendBasicBlockInContext")
appendBasicBlockInContext : ContextRef -> ValueRef -> String -> PrimIO BasicBlockRef

export %foreign (llvm "LLVMInsertBasicBlockInContext")
insertBasicBlockInContext : ContextRef -> BasicBlockRef -> String -> PrimIO BasicBlockRef

export %foreign (llvm "LLVMGetFirstBasicBlock")
getFirstBasicBlock : ValueRef -> PrimIO BasicBlockRef

export %foreign (llvm "LLVMGetNextBasicBlock")
getNextBasicBlock : BasicBlockRef -> PrimIO BasicBlockRef

export %foreign (llvm "LLVMGetFirstInstruction")
getFirstInstruction : BasicBlockRef -> PrimIO ValueRef

export %foreign (llvm "LLVMGetNextInstruction")
getNextInstruction : ValueRef -> PrimIO ValueRef

export %foreign (llvm "LLVMGetBasicBlockTerminator")
getBasicBlockTerminator : BasicBlockRef -> PrimIO ValueRef

export %foreign (llvm "LLVMCreateBuilderInContext")
createBuilderInContext : ContextRef -> PrimIO BuilderRef

export %foreign (llvm "LLVMDisposeBuilder")
disposeBuilder : BuilderRef -> PrimIO ()

export %foreign (llvm "LLVMPositionBuilderAtEnd")
positionBuilderAtEnd : BuilderRef -> BasicBlockRef -> PrimIO ()

export %foreign (llvm "LLVMPositionBuilderBefore")
positionBuilderBefore : BuilderRef -> ValueRef -> PrimIO ()

export %foreign (llvm "LLVMGetInsertBlock")
getInsertBlock : BuilderRef -> PrimIO BasicBlockRef

export %foreign (llvm "LLVMClearInsertionPosition")
clearInsertionPosition : BuilderRef -> PrimIO ()

export %foreign (llvm "LLVMBuildRetVoid")
buildRetVoid : BuilderRef -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildRet")
buildRet : BuilderRef -> ValueRef -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildBr")
buildBr : BuilderRef -> BasicBlockRef -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildCondBr")
buildCondBr : BuilderRef -> ValueRef -> BasicBlockRef -> BasicBlockRef -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildUnreachable")
buildUnreachable : BuilderRef -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildInvoke2")
buildInvoke : BuilderRef -> TypeRef -> ValueRef -> AnyPtr -> Bits32 -> BasicBlockRef -> BasicBlockRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildLandingPad")
buildLandingPad : BuilderRef -> TypeRef -> ValueRef -> Bits32 -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMAddClause")
addClause : ValueRef -> ValueRef -> PrimIO ()

export %foreign (llvm "LLVMSetCleanup")
setCleanup : ValueRef -> Int32 -> PrimIO ()

export %foreign (llvm "LLVMBuildResume")
buildResume : BuilderRef -> ValueRef -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildSwitch")
buildSwitch : BuilderRef -> ValueRef -> BasicBlockRef -> Bits32 -> PrimIO ValueRef

export %foreign (llvm "LLVMAddCase")
addCase : ValueRef -> ValueRef -> BasicBlockRef -> PrimIO ()

export %foreign (llvm "LLVMBuildAdd")
buildAdd : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildNSWAdd")
buildNSWAdd : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildNUWAdd")
buildNUWAdd : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildFAdd")
buildFAdd : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildSub")
buildSub : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildNSWSub")
buildNSWSub : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildNUWSub")
buildNUWSub : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildFSub")
buildFSub : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildMul")
buildMul : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildNSWMul")
buildNSWMul : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildNUWMul")
buildNUWMul : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildFMul")
buildFMul : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildUDiv")
buildUDiv : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildSDiv")
buildSDiv : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildFDiv")
buildFDiv : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildURem")
buildURem : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildSRem")
buildSRem : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildFRem")
buildFRem : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildShl")
buildShl : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildLShr")
buildLShr : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildAShr")
buildAShr : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildAnd")
buildAnd : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildOr")
buildOr : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildXor")
buildXor : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildNeg")
buildNeg : BuilderRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildFNeg")
buildFNeg : BuilderRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildNot")
buildNot : BuilderRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildICmp")
buildICmp : BuilderRef -> LLVMIntPredicate -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildFCmp")
buildFCmp : BuilderRef -> LLVMRealPredicate -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildPhi")
buildPhi : BuilderRef -> TypeRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMAddIncoming")
addIncoming : ValueRef -> AnyPtr -> AnyPtr -> Bits32 -> PrimIO ()

export %foreign (llvm "LLVMBuildAlloca")
buildAlloca : BuilderRef -> TypeRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildLoad2")
buildLoad : BuilderRef -> TypeRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildStore")
buildStore : BuilderRef -> ValueRef -> ValueRef -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildGEP2")
buildGEP : BuilderRef -> TypeRef -> ValueRef -> AnyPtr -> Bits32 -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildInBoundsGEP2")
buildInBoundsGEP : BuilderRef -> TypeRef -> ValueRef -> AnyPtr -> Bits32 -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildStructGEP2")
buildStructGEP : BuilderRef -> TypeRef -> ValueRef -> Bits32 -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildTrunc")
buildTrunc : BuilderRef -> ValueRef -> TypeRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildZExt")
buildZExt : BuilderRef -> ValueRef -> TypeRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildSExt")
buildSExt : BuilderRef -> ValueRef -> TypeRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildFPToUI")
buildFPToUI : BuilderRef -> ValueRef -> TypeRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildFPToSI")
buildFPToSI : BuilderRef -> ValueRef -> TypeRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildUIToFP")
buildUIToFP : BuilderRef -> ValueRef -> TypeRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildSIToFP")
buildSIToFP : BuilderRef -> ValueRef -> TypeRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildFPTrunc")
buildFPTrunc : BuilderRef -> ValueRef -> TypeRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildFPExt")
buildFPExt : BuilderRef -> ValueRef -> TypeRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildPtrToInt")
buildPtrToInt : BuilderRef -> ValueRef -> TypeRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildIntToPtr")
buildIntToPtr : BuilderRef -> ValueRef -> TypeRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildBitCast")
buildBitCast : BuilderRef -> ValueRef -> TypeRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildAddrSpaceCast")
buildAddrSpaceCast : BuilderRef -> ValueRef -> TypeRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildCall2")
buildCall : BuilderRef -> TypeRef -> ValueRef -> AnyPtr -> Bits32 -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMSetInstructionCallConv")
setInstructionCallConv : ValueRef -> Bits32 -> PrimIO ()

export %foreign (llvm "LLVMGetInstructionCallConv")
getInstructionCallConv : ValueRef -> PrimIO Bits32

export %foreign (llvm "LLVMSetTailCall")
setTailCall : ValueRef -> Int32 -> PrimIO ()

export %foreign (llvm "LLVMGetTailCallKind")
getTailCallKind : ValueRef -> PrimIO LLVMTailCallKind

export %foreign (llvm "LLVMSetTailCallKind")
setTailCallKind : ValueRef -> LLVMTailCallKind -> PrimIO ()

export %foreign (llvm "LLVMBuildSelect")
buildSelect : BuilderRef -> ValueRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildExtractValue")
buildExtractValue : BuilderRef -> ValueRef -> Bits32 -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildInsertValue")
buildInsertValue : BuilderRef -> ValueRef -> ValueRef -> Bits32 -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildExtractElement")
buildExtractElement : BuilderRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildInsertElement")
buildInsertElement : BuilderRef -> ValueRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildShuffleVector")
buildShuffleVector : BuilderRef -> ValueRef -> ValueRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildFreeze")
buildFreeze : BuilderRef -> ValueRef -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMSetVolatile")
setVolatile : ValueRef -> Int32 -> PrimIO ()

export %foreign (llvm "LLVMSetOrdering")
setOrdering : ValueRef -> LLVMAtomicOrdering -> PrimIO ()

export %foreign (llvm "LLVMBuildFence")
buildFence : BuilderRef -> LLVMAtomicOrdering -> Int32 -> String -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildAtomicRMW")
buildAtomicRMW : BuilderRef -> LLVMAtomicRMWBinOp -> ValueRef -> ValueRef -> LLVMAtomicOrdering -> Int32 -> PrimIO ValueRef

export %foreign (llvm "LLVMBuildAtomicCmpXchg")
buildAtomicCmpXchg : BuilderRef -> ValueRef -> ValueRef -> ValueRef -> LLVMAtomicOrdering -> LLVMAtomicOrdering -> Int32 -> PrimIO ValueRef

export %foreign (llvm "LLVMIsAArgument")
isAArgument : ValueRef -> PrimIO ValueRef

export %foreign (llvm "LLVMIsAFunction")
isAFunction : ValueRef -> PrimIO ValueRef

export %foreign (llvm "LLVMIsAGlobalVariable")
isAGlobalVariable : ValueRef -> PrimIO ValueRef

export %foreign (llvm "LLVMIsAInstruction")
isAInstruction : ValueRef -> PrimIO ValueRef

export %foreign (llvm "LLVMIsACallInst")
isACallInst : ValueRef -> PrimIO ValueRef

export %foreign (llvm "LLVMIsAInvokeInst")
isAInvokeInst : ValueRef -> PrimIO ValueRef

export %foreign (llvm "LLVMIsALandingPadInst")
isALandingPadInst : ValueRef -> PrimIO ValueRef

export %foreign (llvm "LLVMIsAPHINode")
isAPHINode : ValueRef -> PrimIO ValueRef

export %foreign (llvm "LLVMIsALoadInst")
isALoadInst : ValueRef -> PrimIO ValueRef

export %foreign (llvm "LLVMIsAStoreInst")
isAStoreInst : ValueRef -> PrimIO ValueRef

export %foreign (llvm "LLVMIsABranchInst")
isABranchInst : ValueRef -> PrimIO ValueRef

export %foreign (llvm "LLVMIsAReturnInst")
isAReturnInst : ValueRef -> PrimIO ValueRef

export %foreign (llvm "LLVMIsAAllocaInst")
isAAllocaInst : ValueRef -> PrimIO ValueRef

export %foreign (llvm "LLVMIsAConstantInt")
isAConstantInt : ValueRef -> PrimIO ValueRef

export %foreign (llvm "LLVMIsAConstantFP")
isAConstantFP : ValueRef -> PrimIO ValueRef

export %foreign (llvm "LLVMIsAConstantExpr")
isAConstantExpr : ValueRef -> PrimIO ValueRef

export %foreign (llvm "LLVMLookupIntrinsicID")
lookupIntrinsicID : String -> Bits64 -> PrimIO Bits32

export %foreign (llvm "LLVMGetIntrinsicDeclaration")
getIntrinsicDeclaration : ModuleRef -> Bits32 -> AnyPtr -> Bits64 -> PrimIO ValueRef

export %foreign (llvm "LLVMMDStringInContext2")
mdStringInContext : ContextRef -> String -> Bits64 -> PrimIO MetadataRef

export %foreign (llvm "LLVMMDNodeInContext2")
mdNodeInContext : ContextRef -> AnyPtr -> Bits64 -> PrimIO MetadataRef

export %foreign (llvm "LLVMValueAsMetadata")
valueAsMetadata : ValueRef -> PrimIO MetadataRef

export %foreign (llvm "LLVMMetadataAsValue")
metadataAsValue : ContextRef -> MetadataRef -> PrimIO ValueRef

export %foreign (llvm "LLVMSetMetadata")
setMetadata : ValueRef -> Bits32 -> ValueRef -> PrimIO ()

export %foreign (llvm "LLVMGetMDKindIDInContext")
getMDKindIDInContext : ContextRef -> String -> Bits32 -> PrimIO Bits32

export %foreign (llvm "LLVMCreateMemoryBufferWithMemoryRangeCopy")
createMemoryBufferWithMemoryRangeCopy : String -> Bits64 -> String -> PrimIO MemoryBufferRef

export %foreign (llvm "LLVMCreateMemoryBufferWithContentsOfFile")
createMemoryBufferWithContentsOfFile : String -> AnyPtr -> AnyPtr -> PrimIO Int32

export %foreign (llvm "LLVMGetBufferStart")
getBufferStart : MemoryBufferRef -> PrimIO (Ptr String)

export %foreign (llvm "LLVMGetBufferSize")
getBufferSize : MemoryBufferRef -> PrimIO Bits64

export %foreign (llvm "LLVMDisposeMemoryBuffer")
disposeMemoryBuffer : MemoryBufferRef -> PrimIO ()
