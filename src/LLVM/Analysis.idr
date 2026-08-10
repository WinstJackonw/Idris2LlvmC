module LLVM.Analysis

import LLVM.Core
import LLVM.Error
import LLVM.Internal.Array
import LLVM.Internal.String
import LLVM.Raw.Analysis as Raw
import LLVM.Raw.Core as RawCore
import LLVM.Raw.Enums as RawEnums

%default total

takeMessage : AnyPtr -> IO String
takeMessage pointer = do
  null <- isNull pointer
  if null
    then pure "LLVM reported an error without a diagnostic message"
    else do
      let stringPointer : Ptr String = prim__castPtr pointer
      message <- peekString stringPointer
      primIO $ RawCore.disposeMessage stringPointer
      pure message

export
verifyModule : Module -> IO (Either LLVMError ())
verifyModule mod = do
  (status, messagePointer) <- withOutPtr $ \outMessage =>
    primIO $ Raw.verifyModule (toRawModule mod) RawEnums.llvmReturnStatusAction outMessage
  if status == 0
    then pure $ Right ()
    else Left . MkLLVMError "verifyModule" <$> takeMessage messagePointer

export
verifyFunction : Value -> IO (Either LLVMError ())
verifyFunction function = do
  status <- primIO $ Raw.verifyFunction (toRawValue function) RawEnums.llvmReturnStatusAction
  pure $ if status == 0
    then Right ()
    else Left $ MkLLVMError "verifyFunction" "function verification failed"
