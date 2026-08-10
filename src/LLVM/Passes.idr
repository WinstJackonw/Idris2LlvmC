module LLVM.Passes

import LLVM.Core
import LLVM.Error
import LLVM.Internal.String
import LLVM.Raw.Passes as Raw
import LLVM.Raw.Types
import LLVM.Target

%default total

public export
record PassOptions where
  constructor MkPassOptions
  verifyEach : Bool
  debugLogging : Bool

public export
defaultPassOptions : PassOptions
defaultPassOptions = MkPassOptions False False

nullTargetMachine : TargetMachineRef
nullTargetMachine = prim__castPtr prim__getNullAnyPtr

export
runPasses : Module -> Maybe TargetMachine -> String -> PassOptions -> IO (Either LLVMError ())
runPasses mod targetMachine pipeline options = do
  rawOptions <- primIO Raw.createPassBuilderOptions
  primIO $ Raw.setVerifyEach rawOptions (if options.verifyEach then 1 else 0)
  primIO $ Raw.setDebugLogging rawOptions (if options.debugLogging then 1 else 0)
  let machine = case targetMachine of
        Nothing => nullTargetMachine
        Just value => toRawTargetMachine value
  errorRef <- primIO $ Raw.runPasses (toRawModule mod) pipeline machine rawOptions
  primIO $ Raw.disposePassBuilderOptions rawOptions
  success <- primIO $ Raw.errorIsSuccess errorRef
  if success /= 0
    then pure $ Right ()
    else do
      messagePointer <- primIO $ Raw.getErrorMessage errorRef
      message <- peekString messagePointer
      primIO $ Raw.disposeErrorMessage messagePointer
      pure $ Left $ MkLLVMError "runPasses" message
