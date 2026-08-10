module LLVM.DebugInfo

import LLVM.Core
import LLVM.Internal.Array
import LLVM.Internal.String
import LLVM.Raw.DebugInfo as Raw
import LLVM.Raw.Enums as RawEnums
import LLVM.Raw.Types as RawTypes

%default total

public export data DIBuilder = MkDIBuilder RawTypes.DIBuilderRef

export toRawDIBuilder : DIBuilder -> RawTypes.DIBuilderRef
toRawDIBuilder (MkDIBuilder builder) = builder

public export
data SourceLanguage = C | C99 | Haskell | Rust

toRawLanguage : SourceLanguage -> RawEnums.LLVMDWARFSourceLanguage
toRawLanguage C = RawEnums.llvmDWARFSourceLanguageC
toRawLanguage C99 = RawEnums.llvmDWARFSourceLanguageC99
toRawLanguage Haskell = RawEnums.llvmDWARFSourceLanguageHaskell
toRawLanguage Rust = RawEnums.llvmDWARFSourceLanguageRust

public export
data DebugEmission = NoDebug | FullDebug | LineTablesOnly

toRawEmission : DebugEmission -> RawEnums.LLVMDWARFEmissionKind
toRawEmission NoDebug = RawEnums.llvmDWARFEmissionNone
toRawEmission FullDebug = RawEnums.llvmDWARFEmissionFull
toRawEmission LineTablesOnly = RawEnums.llvmDWARFEmissionLineTablesOnly

public export
data TypeEncoding = Address | Boolean | Float | Signed | Unsigned

toRawEncoding : TypeEncoding -> Bits32
toRawEncoding Address = RawEnums.llvmDWARFEncodingAddress
toRawEncoding Boolean = RawEnums.llvmDWARFEncodingBoolean
toRawEncoding Float = RawEnums.llvmDWARFEncodingFloat
toRawEncoding Signed = RawEnums.llvmDWARFEncodingSigned
toRawEncoding Unsigned = RawEnums.llvmDWARFEncodingUnsigned

public export
record CompileUnitConfig where
  constructor MkCompileUnitConfig
  language : SourceLanguage
  fileName : String
  directory : String
  producer : String
  optimized : Bool
  emission : DebugEmission

public export
defaultCompileUnit : String -> String -> CompileUnitConfig
defaultCompileUnit file directory =
  MkCompileUnitConfig Haskell file directory "Idris 2 LLVM backend" False FullDebug

||| Add the LLVM module flag required for modern debug metadata.
export
addDebugInfoVersion : Context -> Module -> IO ()
addDebugInfoVersion context mod = do
  integerType <- i32 context
  version <- primIO Raw.debugMetadataVersion
  constant <- constInt integerType (cast version)
  metadata <- valueAsMetadata constant
  addModuleFlag mod FlagWarning "Debug Info Version" metadata

nullMetadata : RawTypes.MetadataRef
nullMetadata = prim__castPtr prim__getNullAnyPtr

export
withDIBuilder : Module -> (DIBuilder -> IO a) -> IO a
withDIBuilder mod action = do
  builder <- primIO $ Raw.createDIBuilder (toRawModule mod)
  result <- action (MkDIBuilder builder)
  primIO $ Raw.finalizeDIBuilder builder
  primIO $ Raw.disposeDIBuilder builder
  pure result

export
createFile : DIBuilder -> String -> String -> IO Metadata
createFile (MkDIBuilder builder) file directory = do
  fileLength <- byteLength file
  directoryLength <- byteLength directory
  MkMetadata <$> (primIO $ Raw.createFile builder file fileLength directory directoryLength)

export
createCompileUnit : DIBuilder -> CompileUnitConfig -> IO (Metadata, Metadata)
createCompileUnit builder@(MkDIBuilder rawBuilder) config = do
  file@(MkMetadata fileRef) <- createFile builder config.fileName config.directory
  producerLength <- byteLength config.producer
  compileUnit <- primIO $ Raw.createCompileUnit rawBuilder (toRawLanguage config.language)
    fileRef config.producer producerLength (if config.optimized then 1 else 0)
    "" 0 0 "" 0 (toRawEmission config.emission) 0 0 0 "" 0 "" 0
  pure (file, MkMetadata compileUnit)

export
createBasicType : DIBuilder -> String -> Bits64 -> TypeEncoding -> IO Metadata
createBasicType (MkDIBuilder builder) name sizeBits encoding = do
  nameLength <- byteLength name
  MkMetadata <$> (primIO $ Raw.createBasicType builder name nameLength sizeBits
                    (toRawEncoding encoding) RawEnums.llvmDIFlagZero)

export
createPointerType : DIBuilder -> Metadata -> Bits64 -> Bits32 -> String -> IO Metadata
createPointerType (MkDIBuilder builder) (MkMetadata pointee) sizeBits alignBits name = do
  nameLength <- byteLength name
  MkMetadata <$> (primIO $ Raw.createPointerType builder pointee sizeBits alignBits 0 name nameLength)

export
createSubroutineType : DIBuilder -> Metadata -> List Metadata -> IO Metadata
createSubroutineType (MkDIBuilder builder) (MkMetadata file) parameterTypes =
  withRefArray (map toRawMetadata parameterTypes) $ \array, count =>
    MkMetadata <$> (primIO $ Raw.createSubroutineType builder file array count RawEnums.llvmDIFlagZero)

export
createFunction : DIBuilder -> Metadata -> String -> Metadata -> Bits32 -> Metadata -> Bool -> IO Metadata
createFunction (MkDIBuilder builder) (MkMetadata scope) name (MkMetadata file) line
               (MkMetadata debugType) optimized = do
  nameLength <- byteLength name
  MkMetadata <$> (primIO $ Raw.createFunction builder scope name nameLength name nameLength
                    file line debugType 0 1 line RawEnums.llvmDIFlagPrototyped
                    (if optimized then 1 else 0))

export
createLexicalBlock : DIBuilder -> Metadata -> Metadata -> Bits32 -> Bits32 -> IO Metadata
createLexicalBlock (MkDIBuilder builder) (MkMetadata scope) (MkMetadata file) line column =
  MkMetadata <$> (primIO $ Raw.createLexicalBlock builder scope file line column)

export
createLocation : Context -> Bits32 -> Bits32 -> Metadata -> Maybe Metadata -> IO Metadata
createLocation context line column (MkMetadata scope) inlinedAt = do
  let rawInlined = case inlinedAt of
        Nothing => nullMetadata
        Just (MkMetadata value) => value
  MkMetadata <$> (primIO $ Raw.createDebugLocation (toRawContext context) line column scope rawInlined)

export
setCurrentLocation : Builder -> Metadata -> IO ()
setCurrentLocation builder (MkMetadata location) =
  primIO $ Raw.setCurrentDebugLocation (toRawBuilder builder) location

export
setInstructionLocation : Value -> Metadata -> IO ()
setInstructionLocation instruction (MkMetadata location) =
  primIO $ Raw.instructionSetDebugLoc (toRawValue instruction) location

export
attachSubprogram : Value -> Metadata -> IO ()
attachSubprogram function (MkMetadata subprogram) =
  primIO $ Raw.setSubprogram (toRawValue function) subprogram

export
createExpression : DIBuilder -> List Int64 -> IO Metadata
createExpression (MkDIBuilder builder) operations =
  withI64Array operations $ \array, count =>
    MkMetadata <$> (primIO $ Raw.createExpression builder array count)

export
createAutoVariable : DIBuilder -> Metadata -> String -> Metadata -> Bits32 -> Metadata -> Bits32 -> IO Metadata
createAutoVariable (MkDIBuilder builder) (MkMetadata scope) name (MkMetadata file) line
                   (MkMetadata debugType) alignBits = do
  nameLength <- byteLength name
  MkMetadata <$> (primIO $ Raw.createAutoVariable builder scope name nameLength file line debugType
                    1 RawEnums.llvmDIFlagZero alignBits)

export
createParameterVariable : DIBuilder -> Metadata -> String -> Bits32 -> Metadata -> Bits32 -> Metadata -> IO Metadata
createParameterVariable (MkDIBuilder builder) (MkMetadata scope) name argumentNumber
                        (MkMetadata file) line (MkMetadata debugType) = do
  nameLength <- byteLength name
  MkMetadata <$> (primIO $ Raw.createParameterVariable builder scope name nameLength
                    argumentNumber file line debugType 1 RawEnums.llvmDIFlagZero)

export
insertDeclareAtEnd : DIBuilder -> Value -> Metadata -> Metadata -> Metadata -> BasicBlock -> IO ()
insertDeclareAtEnd (MkDIBuilder builder) storage (MkMetadata variable)
                   (MkMetadata expression) (MkMetadata location) block = do
  _ <- primIO $ Raw.insertDeclareRecordAtEnd builder (toRawValue storage) variable
         expression location (toRawBasicBlock block)
  pure ()

export
insertValueAtEnd : DIBuilder -> Value -> Metadata -> Metadata -> Metadata -> BasicBlock -> IO ()
insertValueAtEnd (MkDIBuilder builder) value (MkMetadata variable)
                 (MkMetadata expression) (MkMetadata location) block = do
  _ <- primIO $ Raw.insertDbgValueRecordAtEnd builder (toRawValue value) variable
         expression location (toRawBasicBlock block)
  pure ()
