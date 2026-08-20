module LLVM.Orc

import LLVM.Builder
import LLVM.Core
import LLVM.Error
import LLVM.Internal.Array
import LLVM.Internal.String
import LLVM.Raw.Core as RawCore
import LLVM.Raw.Orc as Raw
import LLVM.Raw.Passes as RawError
import LLVM.Raw.Types as RawTypes
import LLVM.Target

%default total

public export data LLJIT = MkLLJIT RawTypes.OrcLLJITRef

export
toRawLLJIT : LLJIT -> RawTypes.OrcLLJITRef
toRawLLJIT (MkLLJIT reference) = reference

consumeError : String -> RawTypes.ErrorRef -> IO (LLVMResult ())
consumeError operation errorRef = do
  success <- primIO $ RawError.errorIsSuccess errorRef
  if success /= 0
    then pure $ Right ()
    else do
      messagePointer <- primIO $ RawError.getErrorMessage errorRef
      message <- peekString messagePointer
      primIO $ RawError.disposeErrorMessage messagePointer
      pure $ Left $ simpleError operation message

export
withLLJIT : (LLJIT -> IO (LLVMResult a)) -> IO (LLVMResult a)
withLLJIT action = do
  initialized <- initializeNative
  case initialized of
    Left error => pure $ Left error
    Right () => do
      builder <- primIO Raw.createLLJITBuilder
      (createError, jitPointer) <- withOutPtr $ \outJIT =>
        primIO $ Raw.createLLJIT outJIT builder
      created <- consumeError "withLLJIT" createError
      case created of
        Left error => pure $ Left error
        Right () => do
          let jitRef : RawTypes.OrcLLJITRef = prim__castPtr jitPointer
          result <- action (MkLLJIT jitRef)
          disposeResult <- primIO (Raw.disposeLLJIT jitRef) >>= consumeError "disposeLLJIT"
          case result of
            Left error => pure $ Left error
            Right value => pure $ map (const value) disposeResult

export
jitTriple : LLJIT -> IO String
jitTriple (MkLLJIT jit) = primIO (Raw.getTripleString jit) >>= peekString

export
jitDataLayout : LLJIT -> IO String
jitDataLayout (MkLLJIT jit) = primIO (Raw.getDataLayoutString jit) >>= peekString

export
addJITModule : LLJIT -> String -> ModuleBuilder () -> IO (LLVMResult ())
addJITModule (MkLLJIT jit) name program = do
  contextRef <- primIO RawCore.contextCreate
  moduleRef <- primIO $ RawCore.moduleCreateWithNameInContext name contextRef
  builderRef <- primIO $ RawCore.createBuilderInContext contextRef
  result <- runBuilder program (MkContext contextRef) (MkModule moduleRef) (MkBuilder builderRef)
  primIO $ RawCore.disposeBuilder builderRef
  case result of
    Left error => do
      primIO $ RawCore.disposeModule moduleRef
      primIO $ RawCore.contextDispose contextRef
      pure $ Left error
    Right () => do
      triplePointer <- primIO $ Raw.getTripleString jit
      triple <- peekString triplePointer
      layoutPointer <- primIO $ Raw.getDataLayoutString jit
      layout <- peekString layoutPointer
      primIO $ RawCore.setModuleTarget moduleRef triple
      primIO $ RawCore.setModuleDataLayout moduleRef layout
      threadContext <- primIO $ Raw.createThreadSafeContextFromContext contextRef
      threadModule <- primIO $ Raw.createThreadSafeModule moduleRef threadContext
      primIO $ Raw.disposeThreadSafeContext threadContext
      dylib <- primIO $ Raw.getMainJITDylib jit
      errorRef <- primIO $ Raw.addIRModule jit dylib threadModule
      consumeError "addJITModule" errorRef

takeMessage : AnyPtr -> IO String
takeMessage pointer = do
  null <- isNull pointer
  if null then pure "could not read object file" else do
    let messagePointer : Ptr String = prim__castPtr pointer
    message <- peekString messagePointer
    primIO $ RawCore.disposeMessage messagePointer
    pure message

export
addObjectFile : LLJIT -> String -> IO (LLVMResult ())
addObjectFile (MkLLJIT jit) path = do
  ((status, messagePointer), bufferPointer) <- withOutPtr $ \outBuffer =>
    withOutPtr $ \outMessage =>
      primIO $ RawCore.createMemoryBufferWithContentsOfFile path outBuffer outMessage
  if status /= 0
    then Left . simpleError "addObjectFile" <$> takeMessage messagePointer
    else do
      let buffer : RawTypes.MemoryBufferRef = prim__castPtr bufferPointer
      dylib <- primIO $ Raw.getMainJITDylib jit
      errorRef <- primIO $ Raw.addObjectFile jit dylib buffer
      consumeError "addObjectFile" errorRef

export
lookupSymbol : LLJIT -> String -> IO (LLVMResult Bits64)
lookupSymbol (MkLLJIT jit) name = do
  (errorRef, address) <- withOutU64 $ \outAddress =>
    primIO $ Raw.lookup jit outAddress name
  result <- consumeError "lookupSymbol" errorRef
  pure $ map (const address) result

export
callJITU64_0 : Bits64 -> IO Bits64
callJITU64_0 address = primIO $ Raw.callJITU64_0 address

export
callJITU64_1 : Bits64 -> Bits64 -> IO Bits64
callJITU64_1 address first = primIO $ Raw.callJITU64_1 address first

export
callJITU64_2 : Bits64 -> Bits64 -> Bits64 -> IO Bits64
callJITU64_2 address first second = primIO $ Raw.callJITU64_2 address first second
