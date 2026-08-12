module Main

import LLVM

%default total

buildGlobals : Context -> Module -> IO ()
buildGlobals context mod = do
  i32Type <- i32 context
  counter <- addGlobal mod i32Type "count"
  setLinkage counter Internal
  zero <- constInt i32Type 0
  setInitializer counter zero
  one <- constInt i32Type 1
  tickType <- functionType i32Type [] False
  tick <- addFunction mod "tick" tickType
  entry <- appendBasicBlock context tick "entry"
  withBuilder context $ \builder => do
    positionAtEnd builder entry
    current <- buildLoad builder i32Type counter "current"
    incremented <- buildAdd builder current one "incremented"
    _ <- buildStore builder incremented counter
    _ <- buildRet builder incremented
    pure ()
  run <- addFunction mod "run" tickType
  entry2 <- appendBasicBlock context run "entry"
  withBuilder context $ \builder => do
    positionAtEnd builder entry2
    firstCall <- buildCall builder tickType tick [] "first"
    secondCall <- buildCall builder tickType tick [] "second"
    sum <- buildAdd builder firstCall secondCall "sum"
    _ <- buildRet builder sum
    pure ()

main : IO ()
main = withContext $ \context =>
  withModule context "globals-example" $ \mod => do
    buildGlobals context mod
    verification <- verifyModule mod
    case verification of
      Left error => putStrLn $ "LLVM verification failed: " ++ show error
      Right () => moduleIR mod >>= putStrLn
