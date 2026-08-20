module LLVM.Core

import Data.List
import LLVM.Error
import LLVM.Internal.Array
import LLVM.Internal.String
import LLVM.Raw.Core as Raw
import LLVM.Raw.Enums as RawEnums
import LLVM.Raw.Types as RawTypes

%default total

public export
record LLVMVersion where
  constructor MkLLVMVersion
  major : Bits32
  minor : Bits32
  patch : Bits32

public export
Show LLVMVersion where
  show version = show version.major ++ "." ++ show version.minor ++ "." ++ show version.patch

public export data Context = MkContext RawTypes.ContextRef
public export data Module = MkModule RawTypes.ModuleRef
public export data LLVMType = MkLLVMType RawTypes.TypeRef
public export data Value = MkValue RawTypes.ValueRef
public export data BasicBlock = MkBasicBlock RawTypes.BasicBlockRef
public export data Builder = MkBuilder RawTypes.BuilderRef
public export data Metadata = MkMetadata RawTypes.MetadataRef
public export data MemoryBuffer = MkMemoryBuffer RawTypes.MemoryBufferRef
public export data Attribute = MkAttribute RawTypes.AttributeRef

export toRawContext : Context -> RawTypes.ContextRef
toRawContext (MkContext ref) = ref

export toRawModule : Module -> RawTypes.ModuleRef
toRawModule (MkModule ref) = ref

export toRawType : LLVMType -> RawTypes.TypeRef
toRawType (MkLLVMType ref) = ref

export toRawValue : Value -> RawTypes.ValueRef
toRawValue (MkValue ref) = ref

export toRawBasicBlock : BasicBlock -> RawTypes.BasicBlockRef
toRawBasicBlock (MkBasicBlock ref) = ref

export toRawBuilder : Builder -> RawTypes.BuilderRef
toRawBuilder (MkBuilder ref) = ref

export toRawMetadata : Metadata -> RawTypes.MetadataRef
toRawMetadata (MkMetadata ref) = ref

export toRawMemoryBuffer : MemoryBuffer -> RawTypes.MemoryBufferRef
toRawMemoryBuffer (MkMemoryBuffer ref) = ref

export toRawAttribute : Attribute -> RawTypes.AttributeRef
toRawAttribute (MkAttribute ref) = ref

export
llvmVersion : IO LLVMVersion
llvmVersion = do
  major <- primIO Raw.versionMajor
  minor <- primIO Raw.versionMinor
  patch <- primIO Raw.versionPatch
  pure $ MkLLVMVersion major minor patch

export
shimABIVersion : IO Bits32
shimABIVersion = primIO Raw.shimABIVersion

export
withContext : (Context -> IO a) -> IO a
withContext action = do
  context <- primIO Raw.contextCreate
  result <- action (MkContext context)
  primIO $ Raw.contextDispose context
  pure result

export
withModule : Context -> String -> (Module -> IO a) -> IO a
withModule (MkContext context) name action = do
  moduleRef <- primIO $ Raw.moduleCreateWithNameInContext name context
  result <- action (MkModule moduleRef)
  primIO $ Raw.disposeModule moduleRef
  pure result

export
withBuilder : Context -> (Builder -> IO a) -> IO a
withBuilder (MkContext context) action = do
  builder <- primIO $ Raw.createBuilderInContext context
  result <- action (MkBuilder builder)
  primIO $ Raw.disposeBuilder builder
  pure result

export
withContextE : (Context -> IO (LLVMResult a)) -> IO (LLVMResult a)
withContextE = withContext

export
withModuleE : Context -> String -> (Module -> IO (LLVMResult a)) -> IO (LLVMResult a)
withModuleE = withModule

export
withBuilderE : Context -> (Builder -> IO (LLVMResult a)) -> IO (LLVMResult a)
withBuilderE = withBuilder

ownedString : IO (Ptr String) -> IO String
ownedString get = do
  ptr <- get
  value <- peekString ptr
  primIO $ Raw.disposeMessage ptr
  pure value

takeOwnedMessage : AnyPtr -> String -> IO String
takeOwnedMessage pointer fallback = do
  null <- isNull pointer
  if null
    then pure fallback
    else do
      let stringPointer : Ptr String = prim__castPtr pointer
      message <- peekString stringPointer
      primIO $ Raw.disposeMessage stringPointer
      pure message

export
withMemoryBufferFromFile : String -> (MemoryBuffer -> IO (LLVMResult a)) -> IO (LLVMResult a)
withMemoryBufferFromFile path action = do
  ((status, messagePointer), bufferPointer) <- withOutPtr $ \outBuffer =>
    withOutPtr $ \outMessage =>
      primIO $ Raw.createMemoryBufferWithContentsOfFile path outBuffer outMessage
  if status /= 0
    then Left . simpleError "withMemoryBufferFromFile" <$>
           takeOwnedMessage messagePointer ("could not read " ++ path)
    else do
      let bufferRef : RawTypes.MemoryBufferRef = prim__castPtr bufferPointer
      result <- action (MkMemoryBuffer bufferRef)
      primIO $ Raw.disposeMemoryBuffer bufferRef
      pure result

export
moduleIR : Module -> IO String
moduleIR (MkModule moduleRef) = ownedString $ primIO $ Raw.printModuleToString moduleRef

export
valueIR : Value -> IO String
valueIR (MkValue value) = ownedString $ primIO $ Raw.printValueToString value

export
typeIR : LLVMType -> IO String
typeIR (MkLLVMType typeRef) = ownedString $ primIO $ Raw.printTypeToString typeRef

export
setModuleTarget : Module -> String -> IO ()
setModuleTarget (MkModule moduleRef) triple = primIO $ Raw.setModuleTarget moduleRef triple

export
moduleTarget : Module -> IO String
moduleTarget (MkModule moduleRef) = do
  ptr <- primIO $ Raw.getModuleTarget moduleRef
  peekString ptr

export
setModuleDataLayout : Module -> String -> IO ()
setModuleDataLayout (MkModule moduleRef) layout = primIO $ Raw.setModuleDataLayout moduleRef layout

export
moduleDataLayout : Module -> IO String
moduleDataLayout (MkModule moduleRef) = do
  ptr <- primIO $ Raw.getModuleDataLayout moduleRef
  peekString ptr

public export
data ModuleFlagBehavior = FlagError | FlagWarning | FlagRequire
                        | FlagOverride | FlagAppend | FlagAppendUnique

toRawModuleFlagBehavior : ModuleFlagBehavior -> RawEnums.LLVMModuleFlagBehavior
toRawModuleFlagBehavior FlagError = RawEnums.llvmModuleFlagError
toRawModuleFlagBehavior FlagWarning = RawEnums.llvmModuleFlagWarning
toRawModuleFlagBehavior FlagRequire = RawEnums.llvmModuleFlagRequire
toRawModuleFlagBehavior FlagOverride = RawEnums.llvmModuleFlagOverride
toRawModuleFlagBehavior FlagAppend = RawEnums.llvmModuleFlagAppend
toRawModuleFlagBehavior FlagAppendUnique = RawEnums.llvmModuleFlagAppendUnique

export
addModuleFlag : Module -> ModuleFlagBehavior -> String -> Metadata -> IO ()
addModuleFlag (MkModule moduleRef) behavior key (MkMetadata value) = do
  keyLength <- byteLength key
  primIO $ Raw.addModuleFlag moduleRef (toRawModuleFlagBehavior behavior) key keyLength value

export
valueAsMetadata : Value -> IO Metadata
valueAsMetadata (MkValue value) = MkMetadata <$> (primIO $ Raw.valueAsMetadata value)

export
intType : Context -> Bits32 -> IO LLVMType
intType (MkContext context) width = MkLLVMType <$> (primIO $ Raw.intTypeInContext context width)

export i1, i8, i16, i32, i64 : Context -> IO LLVMType
i1 (MkContext context) = MkLLVMType <$> (primIO $ Raw.int1TypeInContext context)
i8 (MkContext context) = MkLLVMType <$> (primIO $ Raw.int8TypeInContext context)
i16 (MkContext context) = MkLLVMType <$> (primIO $ Raw.int16TypeInContext context)
i32 (MkContext context) = MkLLVMType <$> (primIO $ Raw.int32TypeInContext context)
i64 (MkContext context) = MkLLVMType <$> (primIO $ Raw.int64TypeInContext context)

export half, float, double, void : Context -> IO LLVMType
half (MkContext context) = MkLLVMType <$> (primIO $ Raw.halfTypeInContext context)
float (MkContext context) = MkLLVMType <$> (primIO $ Raw.floatTypeInContext context)
double (MkContext context) = MkLLVMType <$> (primIO $ Raw.doubleTypeInContext context)
void (MkContext context) = MkLLVMType <$> (primIO $ Raw.voidTypeInContext context)

export
pointerType : Context -> Bits32 -> IO LLVMType
pointerType (MkContext context) addressSpace =
  MkLLVMType <$> (primIO $ Raw.pointerTypeInContext context addressSpace)

export
arrayType : LLVMType -> Bits64 -> IO LLVMType
arrayType (MkLLVMType element) count = MkLLVMType <$> (primIO $ Raw.arrayType element count)

export
vectorType : LLVMType -> Bits32 -> IO LLVMType
vectorType (MkLLVMType element) count = MkLLVMType <$> (primIO $ Raw.vectorType element count)

export
scalableVectorType : LLVMType -> Bits32 -> IO LLVMType
scalableVectorType (MkLLVMType element) count =
  MkLLVMType <$> (primIO $ Raw.scalableVectorType element count)

export
elementType : LLVMType -> IO LLVMType
elementType (MkLLVMType typeRef) = MkLLVMType <$> (primIO $ Raw.getElementType typeRef)

export
vectorSize : LLVMType -> IO Bits32
vectorSize (MkLLVMType typeRef) = primIO $ Raw.getVectorSize typeRef

export
functionType : LLVMType -> List LLVMType -> Bool -> IO LLVMType
functionType (MkLLVMType result) params vararg =
  withRefArray (map toRawType params) $ \array, count =>
    MkLLVMType <$> (primIO $ Raw.functionType result array count (if vararg then 1 else 0))

export
literalStructType : Context -> List LLVMType -> Bool -> IO LLVMType
literalStructType (MkContext context) elements packed =
  withRefArray (map toRawType elements) $ \array, count =>
    MkLLVMType <$> (primIO $ Raw.structTypeInContext context array count (if packed then 1 else 0))

export
namedStructType : Context -> String -> IO LLVMType
namedStructType (MkContext context) name = MkLLVMType <$> (primIO $ Raw.structCreateNamed context name)

export
setStructBody : LLVMType -> List LLVMType -> Bool -> IO ()
setStructBody (MkLLVMType typeRef) elements packed =
  withRefArray (map toRawType elements) $ \array, count =>
    primIO $ Raw.structSetBody typeRef array count (if packed then 1 else 0)

export
constInt : LLVMType -> Bits64 -> IO Value
constInt (MkLLVMType typeRef) value = MkValue <$> (primIO $ Raw.constInt typeRef value 0)

export
constSignedInt : LLVMType -> Int64 -> IO Value
constSignedInt (MkLLVMType typeRef) value =
  MkValue <$> (primIO $ Raw.constInt typeRef (cast value) 1)

export
constReal : LLVMType -> Double -> IO Value
constReal (MkLLVMType typeRef) value = MkValue <$> (primIO $ Raw.constReal typeRef value)

export
constNull : LLVMType -> IO Value
constNull (MkLLVMType typeRef) = MkValue <$> (primIO $ Raw.constNull typeRef)

export
undef : LLVMType -> IO Value
undef (MkLLVMType typeRef) = MkValue <$> (primIO $ Raw.getUndef typeRef)

export
poison : LLVMType -> IO Value
poison (MkLLVMType typeRef) = MkValue <$> (primIO $ Raw.getPoison typeRef)

export
constVector : List Value -> IO Value
constVector values = withRefArray (map toRawValue values) $ \array, count =>
  MkValue <$> (primIO $ Raw.constVector array count)

public export
data AttributeIndex = FunctionAttribute | ReturnAttribute | ParameterAttribute Bits32

attributeIndex : AttributeIndex -> Bits32
attributeIndex FunctionAttribute = 4294967295
attributeIndex ReturnAttribute = 0
attributeIndex (ParameterAttribute index) = index + 1

export
enumAttribute : Context -> String -> Bits64 -> IO (LLVMResult Attribute)
enumAttribute (MkContext context) name value = do
  length <- byteLength name
  kind <- primIO $ Raw.getEnumAttributeKindForName name length
  if kind == 0
    then pure $ Left $ simpleError "enumAttribute" ("unknown LLVM attribute: " ++ name)
    else Right . MkAttribute <$> (primIO $ Raw.createEnumAttribute context kind value)

export
stringAttribute : Context -> String -> String -> IO Attribute
stringAttribute (MkContext context) key value = do
  keyLength <- byteLength key
  valueLength <- byteLength value
  MkAttribute <$> (primIO $ Raw.createStringAttribute context key (cast keyLength) value (cast valueLength))

export
addAttribute : Value -> AttributeIndex -> Attribute -> IO ()
addAttribute (MkValue function) index (MkAttribute attribute) =
  primIO $ Raw.addAttributeAtIndex function (attributeIndex index) attribute

export
removeEnumAttribute : Value -> AttributeIndex -> String -> IO (LLVMResult ())
removeEnumAttribute (MkValue function) index name = do
  length <- byteLength name
  kind <- primIO $ Raw.getEnumAttributeKindForName name length
  if kind == 0
    then pure $ Left $ simpleError "removeEnumAttribute" ("unknown LLVM attribute: " ++ name)
    else do
      primIO $ Raw.removeEnumAttributeAtIndex function (attributeIndex index) kind
      pure $ Right ()

export
removeStringAttribute : Value -> AttributeIndex -> String -> IO ()
removeStringAttribute (MkValue function) index name = do
  length <- byteLength name
  primIO $ Raw.removeStringAttributeAtIndex function (attributeIndex index) name (cast length)

export
addFunction : Module -> String -> LLVMType -> IO Value
addFunction (MkModule moduleRef) name (MkLLVMType typeRef) =
  MkValue <$> (primIO $ Raw.addFunction moduleRef name typeRef)

export
findFunction : Module -> String -> IO (Maybe Value)
findFunction (MkModule moduleRef) name = do
  ref <- primIO $ Raw.getNamedFunction moduleRef name
  pure $ if RawTypes.isNullRef ref then Nothing else Just (MkValue ref)

export
parameter : Value -> Bits32 -> IO (Maybe Value)
parameter (MkValue function) index = do
  count <- primIO $ Raw.countParams function
  if index >= count
    then pure Nothing
    else Just . MkValue <$> (primIO $ Raw.getParam function index)

public export
data CallingConvention = CCall | FastCall | ColdCall | GHCCall | HiPECall
                       | AnyRegCall | PreserveMostCall | PreserveAllCall
                       | SwiftCall | CXXFastTLSCall | CustomCall Bits32

callingConvention : CallingConvention -> Bits32
callingConvention CCall = 0
callingConvention FastCall = 8
callingConvention ColdCall = 9
callingConvention GHCCall = 10
callingConvention HiPECall = 11
callingConvention AnyRegCall = 13
callingConvention PreserveMostCall = 14
callingConvention PreserveAllCall = 15
callingConvention SwiftCall = 16
callingConvention CXXFastTLSCall = 17
callingConvention (CustomCall value) = value

export
setFunctionCallConv : Value -> CallingConvention -> IO ()
setFunctionCallConv (MkValue function) convention =
  primIO $ Raw.setFunctionCallConv function (callingConvention convention)

export
functionCallConv : Value -> IO Bits32
functionCallConv (MkValue function) = primIO $ Raw.getFunctionCallConv function

export
setPersonality : Value -> Value -> IO ()
setPersonality (MkValue function) (MkValue personality) =
  primIO $ Raw.setPersonalityFn function personality

export
setValueName : Value -> String -> IO ()
setValueName (MkValue value) name = do
  length <- byteLength name
  primIO $ Raw.setValueName value name length

export
addGlobal : Module -> LLVMType -> String -> IO Value
addGlobal (MkModule moduleRef) (MkLLVMType typeRef) name =
  MkValue <$> (primIO $ Raw.addGlobal moduleRef typeRef name)

export
setInitializer : Value -> Value -> IO ()
setInitializer (MkValue global) (MkValue value) = primIO $ Raw.setInitializer global value

public export
data Linkage = External | AvailableExternally | LinkOnceAny | LinkOnceODR
             | WeakAny | WeakODR | Appending | Internal | Private
             | ExternalWeak | Common

toRawLinkage : Linkage -> RawEnums.LLVMLinkage
toRawLinkage External = RawEnums.llvmExternalLinkage
toRawLinkage AvailableExternally = RawEnums.llvmAvailableExternallyLinkage
toRawLinkage LinkOnceAny = RawEnums.llvmLinkOnceAnyLinkage
toRawLinkage LinkOnceODR = RawEnums.llvmLinkOnceODRLinkage
toRawLinkage WeakAny = RawEnums.llvmWeakAnyLinkage
toRawLinkage WeakODR = RawEnums.llvmWeakODRLinkage
toRawLinkage Appending = RawEnums.llvmAppendingLinkage
toRawLinkage Internal = RawEnums.llvmInternalLinkage
toRawLinkage Private = RawEnums.llvmPrivateLinkage
toRawLinkage ExternalWeak = RawEnums.llvmExternalWeakLinkage
toRawLinkage Common = RawEnums.llvmCommonLinkage

export
setLinkage : Value -> Linkage -> IO ()
setLinkage (MkValue value) linkage = primIO $ Raw.setLinkage value (toRawLinkage linkage)

export
appendBasicBlock : Context -> Value -> String -> IO BasicBlock
appendBasicBlock (MkContext context) (MkValue function) name =
  MkBasicBlock <$> (primIO $ Raw.appendBasicBlockInContext context function name)

nullableValue : RawTypes.ValueRef -> Maybe Value
nullableValue ref = if RawTypes.isNullRef ref then Nothing else Just (MkValue ref)

nullableBlock : RawTypes.BasicBlockRef -> Maybe BasicBlock
nullableBlock ref = if RawTypes.isNullRef ref then Nothing else Just (MkBasicBlock ref)

export
firstBasicBlock : Value -> IO (Maybe BasicBlock)
firstBasicBlock (MkValue function) = nullableBlock <$> (primIO $ Raw.getFirstBasicBlock function)

export
nextBasicBlock : BasicBlock -> IO (Maybe BasicBlock)
nextBasicBlock (MkBasicBlock block) = nullableBlock <$> (primIO $ Raw.getNextBasicBlock block)

export
firstInstruction : BasicBlock -> IO (Maybe Value)
firstInstruction (MkBasicBlock block) = nullableValue <$> (primIO $ Raw.getFirstInstruction block)

export
nextInstruction : Value -> IO (Maybe Value)
nextInstruction (MkValue instruction) = nullableValue <$> (primIO $ Raw.getNextInstruction instruction)

export
typeOf : Value -> IO LLVMType
typeOf (MkValue value) = MkLLVMType <$> (primIO $ Raw.typeOf value)

export
globalValueType : Value -> IO LLVMType
globalValueType (MkValue value) = MkLLVMType <$> (primIO $ Raw.globalValueType value)

public export
data ValueKind = ArgumentValue | BasicBlockValue | MemoryUseValue | MemoryDefValue
               | MemoryPhiValue | FunctionValue | GlobalAliasValue | GlobalIFuncValue
               | GlobalVariableValue | BlockAddressValue | ConstantExprValue
               | ConstantArrayValue | ConstantStructValue | ConstantVectorValue
               | UndefValue | ConstantAggregateZeroValue | ConstantDataArrayValue
               | ConstantDataVectorValue | ConstantIntValue | ConstantFPValue
               | ConstantPointerNullValue | ConstantTokenNoneValue | MetadataAsValue
               | InlineAsmValue | InstructionValue | PoisonValue | ConstantTargetNoneValue
               | ConstantPtrAuthValue | UnknownValueKind Int32

decodeValueKind : Int32 -> ValueKind
decodeValueKind 0 = ArgumentValue
decodeValueKind 1 = BasicBlockValue
decodeValueKind 2 = MemoryUseValue
decodeValueKind 3 = MemoryDefValue
decodeValueKind 4 = MemoryPhiValue
decodeValueKind 5 = FunctionValue
decodeValueKind 6 = GlobalAliasValue
decodeValueKind 7 = GlobalIFuncValue
decodeValueKind 8 = GlobalVariableValue
decodeValueKind 9 = BlockAddressValue
decodeValueKind 10 = ConstantExprValue
decodeValueKind 11 = ConstantArrayValue
decodeValueKind 12 = ConstantStructValue
decodeValueKind 13 = ConstantVectorValue
decodeValueKind 14 = UndefValue
decodeValueKind 15 = ConstantAggregateZeroValue
decodeValueKind 16 = ConstantDataArrayValue
decodeValueKind 17 = ConstantDataVectorValue
decodeValueKind 18 = ConstantIntValue
decodeValueKind 19 = ConstantFPValue
decodeValueKind 20 = ConstantPointerNullValue
decodeValueKind 21 = ConstantTokenNoneValue
decodeValueKind 22 = MetadataAsValue
decodeValueKind 23 = InlineAsmValue
decodeValueKind 24 = InstructionValue
decodeValueKind 25 = PoisonValue
decodeValueKind 26 = ConstantTargetNoneValue
decodeValueKind 27 = ConstantPtrAuthValue
decodeValueKind value = UnknownValueKind value

export
valueKind : Value -> IO ValueKind
valueKind (MkValue value) = decodeValueKind <$> (primIO $ Raw.getValueKind value)

public export
data ValueClass = IsArgument | IsFunction | IsGlobalVariable | IsInstruction
                | IsCall | IsInvoke | IsLandingPad | IsPhi | IsLoad | IsStore
                | IsBranch | IsReturn | IsAlloca | IsConstantInt | IsConstantFP
                | IsConstantExpr

rawClass : ValueClass -> RawTypes.ValueRef -> PrimIO RawTypes.ValueRef
rawClass IsArgument = Raw.isAArgument
rawClass IsFunction = Raw.isAFunction
rawClass IsGlobalVariable = Raw.isAGlobalVariable
rawClass IsInstruction = Raw.isAInstruction
rawClass IsCall = Raw.isACallInst
rawClass IsInvoke = Raw.isAInvokeInst
rawClass IsLandingPad = Raw.isALandingPadInst
rawClass IsPhi = Raw.isAPHINode
rawClass IsLoad = Raw.isALoadInst
rawClass IsStore = Raw.isAStoreInst
rawClass IsBranch = Raw.isABranchInst
rawClass IsReturn = Raw.isAReturnInst
rawClass IsAlloca = Raw.isAAllocaInst
rawClass IsConstantInt = Raw.isAConstantInt
rawClass IsConstantFP = Raw.isAConstantFP
rawClass IsConstantExpr = Raw.isAConstantExpr

export
isA : ValueClass -> Value -> IO Bool
isA cls (MkValue value) = do
  result <- primIO $ rawClass cls value
  pure $ not (RawTypes.isNullRef result)

export
positionAtEnd : Builder -> BasicBlock -> IO ()
positionAtEnd (MkBuilder builder) (MkBasicBlock block) =
  primIO $ Raw.positionBuilderAtEnd builder block

export
buildRetVoid : Builder -> IO Value
buildRetVoid (MkBuilder builder) = MkValue <$> (primIO $ Raw.buildRetVoid builder)

export
buildRet : Builder -> Value -> IO Value
buildRet (MkBuilder builder) (MkValue value) = MkValue <$> (primIO $ Raw.buildRet builder value)

export
buildBr : Builder -> BasicBlock -> IO Value
buildBr (MkBuilder builder) (MkBasicBlock block) = MkValue <$> (primIO $ Raw.buildBr builder block)

export
buildCondBr : Builder -> Value -> BasicBlock -> BasicBlock -> IO Value
buildCondBr (MkBuilder builder) (MkValue condition) (MkBasicBlock thenBlock) (MkBasicBlock elseBlock) =
  MkValue <$> (primIO $ Raw.buildCondBr builder condition thenBlock elseBlock)

export
buildInvoke : Builder -> LLVMType -> Value -> List Value -> BasicBlock -> BasicBlock -> String -> IO Value
buildInvoke (MkBuilder builder) (MkLLVMType signature) (MkValue function) args
            (MkBasicBlock normal) (MkBasicBlock unwind) name =
  withRefArray (map toRawValue args) $ \array, count =>
    MkValue <$> (primIO $ Raw.buildInvoke builder signature function array count normal unwind name)

export
buildLandingPad : Builder -> LLVMType -> Value -> Bits32 -> String -> IO Value
buildLandingPad (MkBuilder builder) (MkLLVMType resultType) (MkValue personality) clauses name =
  MkValue <$> (primIO $ Raw.buildLandingPad builder resultType personality clauses name)

export
addClause : Value -> Value -> IO ()
addClause (MkValue landingPad) (MkValue clause) = primIO $ Raw.addClause landingPad clause

export
setCleanup : Value -> Bool -> IO ()
setCleanup (MkValue landingPad) enabled = primIO $ Raw.setCleanup landingPad (if enabled then 1 else 0)

export
buildResume : Builder -> Value -> IO Value
buildResume (MkBuilder builder) (MkValue exception) = MkValue <$> (primIO $ Raw.buildResume builder exception)

export
buildAdd : Builder -> Value -> Value -> String -> IO Value
buildAdd (MkBuilder builder) (MkValue left) (MkValue right) name =
  MkValue <$> (primIO $ Raw.buildAdd builder left right name)

export
buildSub : Builder -> Value -> Value -> String -> IO Value
buildSub (MkBuilder builder) (MkValue left) (MkValue right) name =
  MkValue <$> (primIO $ Raw.buildSub builder left right name)

export
buildMul : Builder -> Value -> Value -> String -> IO Value
buildMul (MkBuilder builder) (MkValue left) (MkValue right) name =
  MkValue <$> (primIO $ Raw.buildMul builder left right name)

public export
data IntPredicate = IntEQ | IntNE | IntUGT | IntUGE | IntULT | IntULE
                  | IntSGT | IntSGE | IntSLT | IntSLE

toRawPredicate : IntPredicate -> RawEnums.LLVMIntPredicate
toRawPredicate IntEQ = RawEnums.llvmIntEQ
toRawPredicate IntNE = RawEnums.llvmIntNE
toRawPredicate IntUGT = RawEnums.llvmIntUGT
toRawPredicate IntUGE = RawEnums.llvmIntUGE
toRawPredicate IntULT = RawEnums.llvmIntULT
toRawPredicate IntULE = RawEnums.llvmIntULE
toRawPredicate IntSGT = RawEnums.llvmIntSGT
toRawPredicate IntSGE = RawEnums.llvmIntSGE
toRawPredicate IntSLT = RawEnums.llvmIntSLT
toRawPredicate IntSLE = RawEnums.llvmIntSLE

export
buildICmp : Builder -> IntPredicate -> Value -> Value -> String -> IO Value
buildICmp (MkBuilder builder) predicate (MkValue left) (MkValue right) name =
  MkValue <$> (primIO $ Raw.buildICmp builder (toRawPredicate predicate) left right name)

export
buildPhi : Builder -> LLVMType -> String -> IO Value
buildPhi (MkBuilder builder) (MkLLVMType typeRef) name =
  MkValue <$> (primIO $ Raw.buildPhi builder typeRef name)

export
addIncoming : Value -> List (Value, BasicBlock) -> IO ()
addIncoming (MkValue phi) incoming =
  withRefArray (map (toRawValue . fst) incoming) $ \values, count =>
    withRefArray (map (toRawBasicBlock . snd) incoming) $ \blocks, _ =>
      primIO $ Raw.addIncoming phi values blocks count

export
buildAlloca : Builder -> LLVMType -> String -> IO Value
buildAlloca (MkBuilder builder) (MkLLVMType typeRef) name =
  MkValue <$> (primIO $ Raw.buildAlloca builder typeRef name)

export
buildLoad : Builder -> LLVMType -> Value -> String -> IO Value
buildLoad (MkBuilder builder) (MkLLVMType typeRef) (MkValue pointer) name =
  MkValue <$> (primIO $ Raw.buildLoad builder typeRef pointer name)

export
buildStore : Builder -> Value -> Value -> IO Value
buildStore (MkBuilder builder) (MkValue value) (MkValue pointer) =
  MkValue <$> (primIO $ Raw.buildStore builder value pointer)

export
buildGEP : Builder -> LLVMType -> Value -> List Value -> String -> IO Value
buildGEP (MkBuilder builder) (MkLLVMType typeRef) (MkValue pointer) indices name =
  withRefArray (map toRawValue indices) $ \array, count =>
    MkValue <$> (primIO $ Raw.buildGEP builder typeRef pointer array count name)

export
buildCall : Builder -> LLVMType -> Value -> List Value -> String -> IO Value
buildCall (MkBuilder builder) (MkLLVMType functionType) (MkValue function) args name =
  withRefArray (map toRawValue args) $ \array, count =>
    MkValue <$> (primIO $ Raw.buildCall builder functionType function array count name)

export
setInstructionCallConv : Value -> CallingConvention -> IO ()
setInstructionCallConv (MkValue instruction) convention =
  primIO $ Raw.setInstructionCallConv instruction (callingConvention convention)

export
instructionCallConv : Value -> IO Bits32
instructionCallConv (MkValue instruction) = primIO $ Raw.getInstructionCallConv instruction

public export
data TailCallKind = NotTail | Tail | MustTail | NoTail

rawTailCallKind : TailCallKind -> RawEnums.LLVMTailCallKind
rawTailCallKind NotTail = RawEnums.llvmTailCallNone
rawTailCallKind Tail = RawEnums.llvmTailCall
rawTailCallKind MustTail = RawEnums.llvmMustTailCall
rawTailCallKind NoTail = RawEnums.llvmNoTailCall

export
setTailCall : Value -> Bool -> IO ()
setTailCall (MkValue call) enabled = primIO $ Raw.setTailCall call (if enabled then 1 else 0)

export
setTailCallKind : Value -> TailCallKind -> IO ()
setTailCallKind (MkValue call) kind = primIO $ Raw.setTailCallKind call (rawTailCallKind kind)

export
buildExtractElement : Builder -> Value -> Value -> String -> IO Value
buildExtractElement (MkBuilder builder) (MkValue vector) (MkValue index) name =
  MkValue <$> (primIO $ Raw.buildExtractElement builder vector index name)

export
buildInsertElement : Builder -> Value -> Value -> Value -> String -> IO Value
buildInsertElement (MkBuilder builder) (MkValue vector) (MkValue element) (MkValue index) name =
  MkValue <$> (primIO $ Raw.buildInsertElement builder vector element index name)

export
buildShuffleVector : Builder -> Value -> Value -> Value -> String -> IO Value
buildShuffleVector (MkBuilder builder) (MkValue left) (MkValue right) (MkValue mask) name =
  MkValue <$> (primIO $ Raw.buildShuffleVector builder left right mask name)

public export
data AtomicOrdering = NotAtomic | Unordered | Monotonic | Acquire | Release
                    | AcquireRelease | SequentiallyConsistent

rawOrdering : AtomicOrdering -> RawEnums.LLVMAtomicOrdering
rawOrdering NotAtomic = RawEnums.llvmAtomicNotAtomic
rawOrdering Unordered = RawEnums.llvmAtomicUnordered
rawOrdering Monotonic = RawEnums.llvmAtomicMonotonic
rawOrdering Acquire = RawEnums.llvmAtomicAcquire
rawOrdering Release = RawEnums.llvmAtomicRelease
rawOrdering AcquireRelease = RawEnums.llvmAtomicAcquireRelease
rawOrdering SequentiallyConsistent = RawEnums.llvmAtomicSequentiallyConsistent

public export
data AtomicRMWOp = AtomicXchg | AtomicAdd | AtomicSub | AtomicAnd | AtomicNand
                 | AtomicOr | AtomicXor | AtomicMax | AtomicMin | AtomicUMax
                 | AtomicUMin | AtomicFAdd | AtomicFSub | AtomicFMax | AtomicFMin
                 | AtomicUIncWrap | AtomicUDecWrap | AtomicUSubCond | AtomicUSubSat
                 | AtomicFMaximum | AtomicFMinimum

rawRMWOp : AtomicRMWOp -> RawEnums.LLVMAtomicRMWBinOp
rawRMWOp AtomicXchg = RawEnums.llvmAtomicRMWXchg
rawRMWOp AtomicAdd = RawEnums.llvmAtomicRMWAdd
rawRMWOp AtomicSub = RawEnums.llvmAtomicRMWSub
rawRMWOp AtomicAnd = RawEnums.llvmAtomicRMWAnd
rawRMWOp AtomicNand = RawEnums.llvmAtomicRMWNand
rawRMWOp AtomicOr = RawEnums.llvmAtomicRMWOr
rawRMWOp AtomicXor = RawEnums.llvmAtomicRMWXor
rawRMWOp AtomicMax = RawEnums.llvmAtomicRMWMax
rawRMWOp AtomicMin = RawEnums.llvmAtomicRMWMin
rawRMWOp AtomicUMax = RawEnums.llvmAtomicRMWUMax
rawRMWOp AtomicUMin = RawEnums.llvmAtomicRMWUMin
rawRMWOp AtomicFAdd = RawEnums.llvmAtomicRMWFAdd
rawRMWOp AtomicFSub = RawEnums.llvmAtomicRMWFSub
rawRMWOp AtomicFMax = RawEnums.llvmAtomicRMWFMax
rawRMWOp AtomicFMin = RawEnums.llvmAtomicRMWFMin
rawRMWOp AtomicUIncWrap = RawEnums.llvmAtomicRMWUIncWrap
rawRMWOp AtomicUDecWrap = RawEnums.llvmAtomicRMWUDecWrap
rawRMWOp AtomicUSubCond = RawEnums.llvmAtomicRMWUSubCond
rawRMWOp AtomicUSubSat = RawEnums.llvmAtomicRMWUSubSat
rawRMWOp AtomicFMaximum = RawEnums.llvmAtomicRMWFMaximum
rawRMWOp AtomicFMinimum = RawEnums.llvmAtomicRMWFMinimum

export
setVolatile : Value -> Bool -> IO ()
setVolatile (MkValue instruction) enabled = primIO $ Raw.setVolatile instruction (if enabled then 1 else 0)

export
setAtomicOrdering : Value -> AtomicOrdering -> IO ()
setAtomicOrdering (MkValue instruction) ordering = primIO $ Raw.setOrdering instruction (rawOrdering ordering)

export
buildFence : Builder -> AtomicOrdering -> Bool -> String -> IO Value
buildFence (MkBuilder builder) ordering singleThread name =
  MkValue <$> (primIO $ Raw.buildFence builder (rawOrdering ordering) (if singleThread then 1 else 0) name)

export
buildAtomicRMW : Builder -> AtomicRMWOp -> Value -> Value -> AtomicOrdering -> Bool -> IO Value
buildAtomicRMW (MkBuilder builder) op (MkValue pointer) (MkValue value) ordering singleThread =
  MkValue <$> (primIO $ Raw.buildAtomicRMW builder (rawRMWOp op) pointer value
                 (rawOrdering ordering) (if singleThread then 1 else 0))

export
buildAtomicCmpXchg : Builder -> Value -> Value -> Value -> AtomicOrdering -> AtomicOrdering -> Bool -> IO Value
buildAtomicCmpXchg (MkBuilder builder) (MkValue pointer) (MkValue compared) (MkValue replacement)
                   success failure singleThread =
  MkValue <$> (primIO $ Raw.buildAtomicCmpXchg builder pointer compared replacement
                 (rawOrdering success) (rawOrdering failure) (if singleThread then 1 else 0))

export
intrinsicDeclaration : Module -> String -> List LLVMType -> IO (LLVMResult Value)
intrinsicDeclaration (MkModule mod) name overloadTypes = do
  length <- byteLength name
  intrinsic <- primIO $ Raw.lookupIntrinsicID name length
  if intrinsic == 0
    then pure $ Left $ simpleError "intrinsicDeclaration" ("unknown LLVM intrinsic: " ++ name)
    else withRefArray (map toRawType overloadTypes) $ \types, count => do
      value <- primIO $ Raw.getIntrinsicDeclaration mod intrinsic types (cast count)
      pure $ if RawTypes.isNullRef value
        then Left $ simpleError "intrinsicDeclaration" ("could not declare LLVM intrinsic: " ++ name)
        else Right (MkValue value)

export
buildSelect : Builder -> Value -> Value -> Value -> String -> IO Value
buildSelect (MkBuilder builder) (MkValue condition) (MkValue thenValue) (MkValue elseValue) name =
  MkValue <$> (primIO $ Raw.buildSelect builder condition thenValue elseValue name)
