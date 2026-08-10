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

ownedString : IO (Ptr String) -> IO String
ownedString get = do
  ptr <- get
  value <- peekString ptr
  primIO $ Raw.disposeMessage ptr
  pure value

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
buildSelect : Builder -> Value -> Value -> Value -> String -> IO Value
buildSelect (MkBuilder builder) (MkValue condition) (MkValue thenValue) (MkValue elseValue) name =
  MkValue <$> (primIO $ Raw.buildSelect builder condition thenValue elseValue name)
