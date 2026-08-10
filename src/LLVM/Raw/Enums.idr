module LLVM.Raw.Enums

%default total

public export LLVMTypeKind : Type
LLVMTypeKind = Int32

public export llvmVoidTypeKind, llvmHalfTypeKind, llvmFloatTypeKind : LLVMTypeKind
llvmVoidTypeKind = 0
llvmHalfTypeKind = 1
llvmFloatTypeKind = 2

public export llvmDoubleTypeKind, llvmLabelTypeKind, llvmIntegerTypeKind : LLVMTypeKind
llvmDoubleTypeKind = 3
llvmLabelTypeKind = 7
llvmIntegerTypeKind = 8

public export llvmFunctionTypeKind, llvmStructTypeKind, llvmArrayTypeKind : LLVMTypeKind
llvmFunctionTypeKind = 9
llvmStructTypeKind = 10
llvmArrayTypeKind = 11

public export llvmPointerTypeKind, llvmVectorTypeKind, llvmMetadataTypeKind : LLVMTypeKind
llvmPointerTypeKind = 12
llvmVectorTypeKind = 13
llvmMetadataTypeKind = 14

public export llvmTokenTypeKind, llvmScalableVectorTypeKind, llvmBFloatTypeKind : LLVMTypeKind
llvmTokenTypeKind = 16
llvmScalableVectorTypeKind = 17
llvmBFloatTypeKind = 18

public export LLVMLinkage : Type
LLVMLinkage = Int32

public export llvmExternalLinkage, llvmAvailableExternallyLinkage : LLVMLinkage
llvmExternalLinkage = 0
llvmAvailableExternallyLinkage = 1

public export llvmLinkOnceAnyLinkage, llvmLinkOnceODRLinkage : LLVMLinkage
llvmLinkOnceAnyLinkage = 2
llvmLinkOnceODRLinkage = 3

public export llvmWeakAnyLinkage, llvmWeakODRLinkage, llvmAppendingLinkage : LLVMLinkage
llvmWeakAnyLinkage = 5
llvmWeakODRLinkage = 6
llvmAppendingLinkage = 7

public export llvmInternalLinkage, llvmPrivateLinkage, llvmExternalWeakLinkage : LLVMLinkage
llvmInternalLinkage = 8
llvmPrivateLinkage = 9
llvmExternalWeakLinkage = 12

public export llvmCommonLinkage : LLVMLinkage
llvmCommonLinkage = 14

public export LLVMIntPredicate : Type
LLVMIntPredicate = Int32

public export llvmIntEQ, llvmIntNE, llvmIntUGT, llvmIntUGE, llvmIntULT : LLVMIntPredicate
llvmIntEQ = 32
llvmIntNE = 33
llvmIntUGT = 34
llvmIntUGE = 35
llvmIntULT = 36

public export llvmIntULE, llvmIntSGT, llvmIntSGE, llvmIntSLT, llvmIntSLE : LLVMIntPredicate
llvmIntULE = 37
llvmIntSGT = 38
llvmIntSGE = 39
llvmIntSLT = 40
llvmIntSLE = 41

public export LLVMRealPredicate : Type
LLVMRealPredicate = Int32

public export llvmRealFalse, llvmRealOEQ, llvmRealOGT, llvmRealOGE : LLVMRealPredicate
llvmRealFalse = 0
llvmRealOEQ = 1
llvmRealOGT = 2
llvmRealOGE = 3

public export llvmRealOLT, llvmRealOLE, llvmRealONE, llvmRealORD : LLVMRealPredicate
llvmRealOLT = 4
llvmRealOLE = 5
llvmRealONE = 6
llvmRealORD = 7

public export llvmRealUNO, llvmRealUEQ, llvmRealUGT, llvmRealUGE : LLVMRealPredicate
llvmRealUNO = 8
llvmRealUEQ = 9
llvmRealUGT = 10
llvmRealUGE = 11

public export llvmRealULT, llvmRealULE, llvmRealUNE, llvmRealTrue : LLVMRealPredicate
llvmRealULT = 12
llvmRealULE = 13
llvmRealUNE = 14
llvmRealTrue = 15

public export LLVMVerifierFailureAction : Type
LLVMVerifierFailureAction = Int32

public export llvmAbortProcessAction, llvmPrintMessageAction, llvmReturnStatusAction : LLVMVerifierFailureAction
llvmAbortProcessAction = 0
llvmPrintMessageAction = 1
llvmReturnStatusAction = 2

public export LLVMCodeGenOptLevel : Type
LLVMCodeGenOptLevel = Int32

public export llvmCodeGenLevelNone, llvmCodeGenLevelLess : LLVMCodeGenOptLevel
llvmCodeGenLevelNone = 0
llvmCodeGenLevelLess = 1

public export llvmCodeGenLevelDefault, llvmCodeGenLevelAggressive : LLVMCodeGenOptLevel
llvmCodeGenLevelDefault = 2
llvmCodeGenLevelAggressive = 3

public export LLVMRelocMode : Type
LLVMRelocMode = Int32

public export llvmRelocDefault, llvmRelocStatic, llvmRelocPIC : LLVMRelocMode
llvmRelocDefault = 0
llvmRelocStatic = 1
llvmRelocPIC = 2

public export llvmRelocDynamicNoPic, llvmRelocROPI, llvmRelocRWPI, llvmRelocROPI_RWPI : LLVMRelocMode
llvmRelocDynamicNoPic = 3
llvmRelocROPI = 4
llvmRelocRWPI = 5
llvmRelocROPI_RWPI = 6

public export LLVMCodeModel : Type
LLVMCodeModel = Int32

public export llvmCodeModelDefault, llvmCodeModelJITDefault, llvmCodeModelTiny : LLVMCodeModel
llvmCodeModelDefault = 0
llvmCodeModelJITDefault = 1
llvmCodeModelTiny = 2

public export llvmCodeModelSmall, llvmCodeModelKernel, llvmCodeModelMedium, llvmCodeModelLarge : LLVMCodeModel
llvmCodeModelSmall = 3
llvmCodeModelKernel = 4
llvmCodeModelMedium = 5
llvmCodeModelLarge = 6

public export LLVMCodeGenFileType : Type
LLVMCodeGenFileType = Int32

public export llvmAssemblyFile, llvmObjectFile : LLVMCodeGenFileType
llvmAssemblyFile = 0
llvmObjectFile = 1

public export LLVMAtomicOrdering : Type
LLVMAtomicOrdering = Int32

public export llvmAtomicNotAtomic, llvmAtomicUnordered, llvmAtomicMonotonic : LLVMAtomicOrdering
llvmAtomicNotAtomic = 0
llvmAtomicUnordered = 1
llvmAtomicMonotonic = 2

public export llvmAtomicAcquire, llvmAtomicRelease, llvmAtomicAcquireRelease : LLVMAtomicOrdering
llvmAtomicAcquire = 4
llvmAtomicRelease = 5
llvmAtomicAcquireRelease = 6

public export llvmAtomicSequentiallyConsistent : LLVMAtomicOrdering
llvmAtomicSequentiallyConsistent = 7

public export LLVMDIFlags : Type
LLVMDIFlags = Bits32

public export LLVMModuleFlagBehavior : Type
LLVMModuleFlagBehavior = Int32

public export
llvmModuleFlagError, llvmModuleFlagWarning, llvmModuleFlagRequire,
  llvmModuleFlagOverride, llvmModuleFlagAppend, llvmModuleFlagAppendUnique : LLVMModuleFlagBehavior
llvmModuleFlagError = 0
llvmModuleFlagWarning = 1
llvmModuleFlagRequire = 2
llvmModuleFlagOverride = 3
llvmModuleFlagAppend = 4
llvmModuleFlagAppendUnique = 5

public export llvmDIFlagZero, llvmDIFlagPrivate, llvmDIFlagProtected, llvmDIFlagPublic : LLVMDIFlags
llvmDIFlagZero = 0
llvmDIFlagPrivate = 1
llvmDIFlagProtected = 2
llvmDIFlagPublic = 3

public export llvmDIFlagFwdDecl, llvmDIFlagArtificial, llvmDIFlagPrototyped : LLVMDIFlags
llvmDIFlagFwdDecl = 4
llvmDIFlagArtificial = 64
llvmDIFlagPrototyped = 256

public export LLVMDWARFSourceLanguage : Type
LLVMDWARFSourceLanguage = Int32

public export llvmDWARFSourceLanguageC, llvmDWARFSourceLanguageC99 : LLVMDWARFSourceLanguage
llvmDWARFSourceLanguageC = 1
llvmDWARFSourceLanguageC99 = 11

public export llvmDWARFSourceLanguageHaskell, llvmDWARFSourceLanguageRust : LLVMDWARFSourceLanguage
llvmDWARFSourceLanguageHaskell = 23
llvmDWARFSourceLanguageRust = 27

public export LLVMDWARFEmissionKind : Type
LLVMDWARFEmissionKind = Int32

public export llvmDWARFEmissionNone, llvmDWARFEmissionFull, llvmDWARFEmissionLineTablesOnly : LLVMDWARFEmissionKind
llvmDWARFEmissionNone = 0
llvmDWARFEmissionFull = 1
llvmDWARFEmissionLineTablesOnly = 2

public export llvmDWARFEncodingAddress, llvmDWARFEncodingBoolean : Bits32
llvmDWARFEncodingAddress = 1
llvmDWARFEncodingBoolean = 2

public export llvmDWARFEncodingFloat, llvmDWARFEncodingSigned, llvmDWARFEncodingUnsigned : Bits32
llvmDWARFEncodingFloat = 4
llvmDWARFEncodingSigned = 5
llvmDWARFEncodingUnsigned = 7
