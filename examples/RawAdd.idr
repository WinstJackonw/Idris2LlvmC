module Main

import LLVM.Internal.Array
import LLVM.Internal.String
import LLVM.Raw

%default total

buildRawAdd : ContextRef -> ModuleRef -> IO ()
buildRawAdd context mod = do
  integerType <- primIO $ int32TypeInContext context
  signature <- withAnyPtrArray [forgetRef integerType, forgetRef integerType] $ \params, count =>
    primIO $ functionType integerType params count 0
  function <- primIO $ addFunction mod "add" signature
  left <- primIO $ getParam function 0
  right <- primIO $ getParam function 1
  leftLength <- byteLength "left"
  rightLength <- byteLength "right"
  primIO $ setValueName left "left" leftLength
  primIO $ setValueName right "right" rightLength
  entry <- primIO $ appendBasicBlockInContext context function "entry"
  builder <- primIO $ createBuilderInContext context
  primIO $ positionBuilderAtEnd builder entry
  sum <- primIO $ buildAdd builder left right "sum"
  _ <- primIO $ buildRet builder sum
  primIO $ disposeBuilder builder

main : IO ()
main = do
  context <- primIO contextCreate
  mod <- primIO $ moduleCreateWithNameInContext "raw-add-example" context
  buildRawAdd context mod
  (status, _) <- withOutPtr $ \outMessage =>
    primIO $ verifyModule mod llvmReturnStatusAction outMessage
  if status /= 0
    then putStrLn "LLVM verification failed"
    else do
      irPointer <- primIO $ printModuleToString mod
      putStrLn !(peekString irPointer)
      primIO $ disposeMessage irPointer
  primIO $ disposeModule mod
  primIO $ contextDispose context
