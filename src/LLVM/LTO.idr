module LLVM.LTO

import LLVM.Core
import LLVM.Bitcode
import LLVM.Error
import LLVM.Internal.Array
import LLVM.Internal.String
import LLVM.Raw.Core as RawCore
import LLVM.Raw.LTO as Raw
import LLVM.Raw.Types as RawTypes

%default total

public export data LTODebugModel = NoDebug | DWARF
public export data LTOPICModel = Static | Dynamic | DynamicNoPIC | DefaultPIC

public export
record LTOConfig where
  constructor MkLTOConfig
  debugModel : LTODebugModel
  picModel : LTOPICModel
  cpu : String
  preserveSymbols : List String
  internalize : Bool
  embedUseLists : Bool

public export
defaultLTOConfig : LTOConfig
defaultLTOConfig = MkLTOConfig NoDebug DefaultPIC "" [] True False

public export
record ThinLTOInput where
  constructor MkThinLTOInput
  identifier : String
  path : String

public export
record ThinLTOConfig where
  constructor MkThinLTOConfig
  outputDirectory : String
  picModel : LTOPICModel
  cpu : String
  preserveSymbols : List String
  crossReferencedSymbols : List String
  cacheDirectory : Maybe String
  cachePruningInterval : Int32
  cacheEntryExpiration : Bits32
  cacheSizeMegabytes : Bits32
  disableCodegen : Bool
  codegenOnly : Bool

public export
defaultThinLTOConfig : String -> ThinLTOConfig
defaultThinLTOConfig output =
  MkThinLTOConfig output DefaultPIC "" [] [] Nothing (-1) 0 0 False False

rawDebug : LTODebugModel -> Raw.RawLTODebugModel
rawDebug NoDebug = 0
rawDebug DWARF = 1

rawPIC : LTOPICModel -> Raw.RawLTOCodegenModel
rawPIC Static = 0
rawPIC Dynamic = 1
rawPIC DynamicNoPIC = 2
rawPIC DefaultPIC = 3

ltoError : String -> IO LLVMError
ltoError operation = do
  pointer <- primIO Raw.getErrorMessage
  message <- if RawTypes.isNullRef pointer then pure "unknown libLTO error" else peekString pointer
  pure $ simpleError operation message

disposeModules : List RawTypes.LTOModuleRef -> IO ()
disposeModules [] = pure ()
disposeModules (moduleRef :: rest) = do
  primIO $ Raw.moduleDispose moduleRef
  disposeModules rest

loadModules : List String -> IO (LLVMResult (List RawTypes.LTOModuleRef))
loadModules [] = pure $ Right []
loadModules (path :: rest) = do
  moduleRef <- primIO $ Raw.moduleCreate path
  if RawTypes.isNullRef moduleRef
    then Left <$> ltoError "lto_module_create"
    else do
      remaining <- loadModules rest
      case remaining of
        Left error => do
          primIO $ Raw.moduleDispose moduleRef
          pure $ Left error
        Right modules => pure $ Right (moduleRef :: modules)

addModules : RawTypes.LTOCodeGeneratorRef -> List RawTypes.LTOModuleRef -> IO (LLVMResult ())
addModules codegen [] = pure $ Right ()
addModules codegen (moduleRef :: rest) = do
  failed <- primIO $ Raw.codegenAddModule codegen moduleRef
  if failed /= 0 then Left <$> ltoError "lto_codegen_add_module" else addModules codegen rest

addPreserved : RawTypes.LTOCodeGeneratorRef -> List String -> IO ()
addPreserved codegen [] = pure ()
addPreserved codegen (symbol :: rest) = do
  primIO $ Raw.codegenAddMustPreserveSymbol codegen symbol
  addPreserved codegen rest

export
ltoVersion : IO String
ltoVersion = primIO Raw.getVersion >>= peekString

export
compileLTOToFile : LTOConfig -> List String -> IO (LLVMResult String)
compileLTOToFile config paths = if null paths
  then pure $ Left $ simpleError "compileLTOToFile" "at least one input module is required"
  else do
    modulesResult <- loadModules paths
    case modulesResult of
      Left error => pure $ Left error
      Right modules => do
        codegen <- primIO Raw.codegenCreate
        if RawTypes.isNullRef codegen
          then do
            disposeModules modules
            Left <$> ltoError "lto_codegen_create"
          else do
            added <- addModules codegen modules
            case added of
              Left error => do
                primIO $ Raw.codegenDispose codegen
                disposeModules modules
                pure $ Left error
              Right () => do
                debugFailed <- primIO $ Raw.codegenSetDebugModel codegen (rawDebug config.debugModel)
                picFailed <- primIO $ Raw.codegenSetPICModel codegen (rawPIC config.picModel)
                if config.cpu /= "" then primIO $ Raw.codegenSetCPU codegen config.cpu else pure ()
                addPreserved codegen config.preserveSymbols
                primIO $ Raw.codegenSetShouldInternalize codegen (if config.internalize then 1 else 0)
                primIO $ Raw.codegenSetShouldEmbedUseLists codegen (if config.embedUseLists then 1 else 0)
                if debugFailed /= 0 || picFailed /= 0
                  then do
                    error <- ltoError "compileLTOToFile"
                    primIO $ Raw.codegenDispose codegen
                    disposeModules modules
                    pure $ Left error
                  else do
                    (failed, pathPointer) <- withOutPtr $ \outPath =>
                      primIO $ Raw.codegenCompileToFile codegen outPath
                    if failed /= 0
                      then do
                        error <- ltoError "lto_codegen_compile_to_file"
                        primIO $ Raw.codegenDispose codegen
                        disposeModules modules
                        pure $ Left error
                      else do
                        let generatedPath : Ptr String = prim__castPtr pathPointer
                        path <- peekString generatedPath
                        primIO $ Raw.codegenDispose codegen
                        disposeModules modules
                        pure $ Right path

withThinInputs : List ThinLTOInput ->
                 (List (String, MemoryBuffer) -> IO (LLVMResult a)) -> IO (LLVMResult a)
withThinInputs [] action = action []
withThinInputs (input :: rest) action = withMemoryBufferFromFile input.path $ \buffer =>
  withThinInputs rest $ \buffers => action ((input.identifier, buffer) :: buffers)

addThinInputs : RawTypes.ThinLTOCodeGeneratorRef -> List (String, MemoryBuffer) -> IO ()
addThinInputs codegen [] = pure ()
addThinInputs codegen ((identifier, buffer) :: rest) = do
  let rawBuffer = toRawMemoryBuffer buffer
  start <- primIO $ RawCore.getBufferStart rawBuffer
  size <- primIO $ RawCore.getBufferSize rawBuffer
  primIO $ Raw.thinAddModule codegen identifier (RawTypes.forgetRef start) (cast size)
  addThinInputs codegen rest

addThinSymbols : (RawTypes.ThinLTOCodeGeneratorRef -> String -> Int32 -> PrimIO ()) ->
                 RawTypes.ThinLTOCodeGeneratorRef -> List String -> IO ()
addThinSymbols add codegen [] = pure ()
addThinSymbols add codegen (symbol :: rest) = do
  length <- byteLength symbol
  primIO $ add codegen symbol (cast length)
  addThinSymbols add codegen rest

collectObjectPaths : RawTypes.ThinLTOCodeGeneratorRef -> Bits32 -> Nat -> IO (List String)
collectObjectPaths codegen index Z = pure []
collectObjectPaths codegen index (S remaining) = do
  path <- primIO (Raw.thinGetObjectFile codegen index) >>= peekString
  rest <- collectObjectPaths codegen (index + 1) remaining
  pure $ path :: rest

validateThinInputIn : ThinLTOInput -> Context -> IO (LLVMResult (LLVMResult ()))
validateThinInputIn input context =
  withBitcodeModuleFromFile context input.path $ \mod => do
    layout <- moduleDataLayout mod
    target <- moduleTarget mod
    pure $ if layout == "" || target == ""
      then Left $ simpleError "runThinLTO"
             (input.path ++ " must contain a target triple and data layout")
      else Right ()

validateThinInput : ThinLTOInput -> IO (LLVMResult ())
validateThinInput input = do
  result <- withContext $ validateThinInputIn input
  case result of
    Left error => pure $ Left error
    Right validation => pure validation

validateThinInputs : List ThinLTOInput -> IO (LLVMResult ())
validateThinInputs [] = pure $ Right ()
validateThinInputs (input :: rest) = do
  validation <- validateThinInput input
  case validation of
    Left error => pure $ Left error
    Right () => validateThinInputs rest

export
runThinLTO : ThinLTOConfig -> List ThinLTOInput -> IO (LLVMResult (List String))
runThinLTO config [] = pure $ Left $ simpleError "runThinLTO" "at least one input module is required"
runThinLTO config inputs = do
  validation <- validateThinInputs inputs
  case validation of
    Left error => pure $ Left error
    Right () => withThinInputs inputs $ \buffers => do
    codegen <- primIO Raw.thinCreateCodegen
    if RawTypes.isNullRef codegen
      then Left <$> ltoError "thinlto_create_codegen"
      else do
        addThinInputs codegen buffers
        picFailed <- primIO $ Raw.thinSetPICModel codegen (rawPIC config.picModel)
        if config.cpu /= "" then primIO $ Raw.thinSetCPU codegen config.cpu else pure ()
        primIO $ Raw.thinSetGeneratedObjectsDir codegen config.outputDirectory
        primIO $ Raw.thinDisableCodegen codegen (if config.disableCodegen then 1 else 0)
        primIO $ Raw.thinSetCodegenOnly codegen (if config.codegenOnly then 1 else 0)
        addThinSymbols Raw.thinAddMustPreserveSymbol codegen config.preserveSymbols
        addThinSymbols Raw.thinAddCrossReferencedSymbol codegen config.crossReferencedSymbols
        case config.cacheDirectory of
          Nothing => pure ()
          Just directory => primIO $ Raw.thinSetCacheDir codegen directory
        primIO $ Raw.thinSetCachePruningInterval codegen config.cachePruningInterval
        if config.cacheEntryExpiration /= 0
          then primIO $ Raw.thinSetCacheEntryExpiration codegen config.cacheEntryExpiration
          else pure ()
        if config.cacheSizeMegabytes /= 0
          then primIO $ Raw.thinSetCacheSizeMegabytes codegen config.cacheSizeMegabytes
          else pure ()
        if picFailed /= 0
          then do
            error <- ltoError "runThinLTO"
            primIO $ Raw.thinDisposeCodegen codegen
            pure $ Left error
          else do
            primIO $ Raw.thinProcess codegen
            count <- primIO $ Raw.thinGetNumObjectFiles codegen
            paths <- collectObjectPaths codegen 0 (cast count)
            primIO $ Raw.thinDisposeCodegen codegen
            if count == 0
              then Left <$> ltoError "thinlto_codegen_process"
              else pure $ Right paths
