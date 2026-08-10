module LLVM.IRReader

import LLVM.Core
import LLVM.Error
import LLVM.Internal.Array
import LLVM.Internal.String
import LLVM.Raw.Core as RawCore
import LLVM.Raw.IRReader as Raw
import LLVM.Raw.Types as RawTypes

%default total

takeMessage : AnyPtr -> IO String
takeMessage pointer = do
  null <- isNull pointer
  if null
    then pure "LLVM reported a parse error without a diagnostic message"
    else do
      let stringPointer : Ptr String = prim__castPtr pointer
      message <- peekString stringPointer
      primIO $ RawCore.disposeMessage stringPointer
      pure message

export
withParsedIR : Context -> String -> (Module -> IO a) -> IO (Either LLVMError a)
withParsedIR context source action = do
  sourceLength <- byteLength source
  buffer <- primIO $ RawCore.createMemoryBufferWithMemoryRangeCopy source sourceLength "idris-input.ll"
  ((status, messagePointer), modulePointer) <- withOutPtr $ \outModule =>
    withOutPtr $ \outMessage =>
      primIO $ Raw.parseIRInContext (toRawContext context) buffer outModule outMessage
  primIO $ RawCore.disposeMemoryBuffer buffer
  if status /= 0
    then Left . MkLLVMError "parseIR" <$> takeMessage messagePointer
    else do
      let moduleRef : RawTypes.ModuleRef = prim__castPtr modulePointer
      result <- action (MkModule moduleRef)
      primIO $ RawCore.disposeModule moduleRef
      pure $ Right result
