module LLVM.Bitcode

import LLVM.Core
import LLVM.Error
import LLVM.Internal.Array
import LLVM.Internal.String
import LLVM.Raw.Bitcode as Raw
import LLVM.Raw.Core as RawCore
import LLVM.Raw.Types as RawTypes

%default total

takeMessage : AnyPtr -> IO String
takeMessage pointer = do
  null <- isNull pointer
  if null
    then pure "LLVM reported a file error without a diagnostic message"
    else do
      let stringPointer : Ptr String = prim__castPtr pointer
      message <- peekString stringPointer
      primIO $ RawCore.disposeMessage stringPointer
      pure message

export
writeBitcodeFile : Module -> String -> IO (Either LLVMError ())
writeBitcodeFile mod path = do
  status <- primIO $ Raw.writeBitcodeToFile (toRawModule mod) path
  pure $ if status == 0
    then Right ()
    else Left $ MkLLVMError "writeBitcodeFile" ("could not write " ++ path)

export
withBitcodeModuleFromFile : Context -> String -> (Module -> IO a) -> IO (Either LLVMError a)
withBitcodeModuleFromFile context path action = do
  ((fileStatus, fileMessage), bufferPointer) <- withOutPtr $ \outBuffer =>
    withOutPtr $ \outMessage =>
      primIO $ RawCore.createMemoryBufferWithContentsOfFile path outBuffer outMessage
  if fileStatus /= 0
    then Left . MkLLVMError "readBitcodeFile" <$> takeMessage fileMessage
    else do
      let buffer : RawTypes.MemoryBufferRef = prim__castPtr bufferPointer
      (parseStatus, modulePointer) <- withOutPtr $ \outModule =>
        primIO $ Raw.parseBitcodeInContext (toRawContext context) buffer outModule
      primIO $ RawCore.disposeMemoryBuffer buffer
      if parseStatus /= 0
        then pure $ Left $ MkLLVMError "parseBitcode" "invalid LLVM bitcode"
        else do
          let moduleRef : RawTypes.ModuleRef = prim__castPtr modulePointer
          result <- action (MkModule moduleRef)
          primIO $ RawCore.disposeModule moduleRef
          pure $ Right result
