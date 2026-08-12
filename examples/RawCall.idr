module Main

import LLVM.Internal.Array
import LLVM.Internal.String
import LLVM.Raw

%default total

buildRawCall : ContextRef -> ModuleRef -> IO ()
buildRawCall context mod = do
  i32Type <- primIO $ int32TypeInContext context
  zero <- primIO $ constInt i32Type 0 0
  one <- primIO $ constInt i32Type 1 0
  counter <- primIO $ addGlobal mod i32Type "counter"
  primIO $ setInitializer counter zero
  primIO $ setLinkage counter llvmInternalLinkage
  tickType <- primIO $ functionType i32Type prim__getNullAnyPtr 0 0
  tick <- primIO $ addFunction mod "tick" tickType
  tickEntry <- primIO $ appendBasicBlockInContext context tick "entry"
  builder <- primIO $ createBuilderInContext context
  primIO $ positionBuilderAtEnd builder tickEntry
  current <- primIO $ buildLoad builder i32Type counter "current"
  incremented <- primIO $ buildAdd builder current one "incremented"
  _ <- primIO $ buildStore builder incremented counter
  _ <- primIO $ buildRet builder incremented
  run <- primIO $ addFunction mod "run" tickType
  runEntry <- primIO $ appendBasicBlockInContext context run "entry"
  primIO $ positionBuilderAtEnd builder runEntry
  firstCall <- primIO $ buildCall builder tickType tick prim__getNullAnyPtr 0 "first"
  secondCall <- primIO $ buildCall builder tickType tick prim__getNullAnyPtr 0 "second"
  sum <- primIO $ buildAdd builder firstCall secondCall "sum"
  _ <- primIO $ buildRet builder sum
  primIO $ disposeBuilder builder

main : IO ()
main = do
  context <- primIO contextCreate
  mod <- primIO $ moduleCreateWithNameInContext "raw-call-example" context
  buildRawCall context mod
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
