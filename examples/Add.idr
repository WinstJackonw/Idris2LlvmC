module Main

import LLVM

%default total

buildAdd : Context -> Module -> IO ()
buildAdd context mod = do
  integerType <- i32 context
  signature <- functionType integerType [integerType, integerType] False
  function <- addFunction mod "add" signature
  first <- parameter function 0
  second <- parameter function 1
  case (first, second) of
    (Just left, Just right) => do
      setValueName left "left"
      setValueName right "right"
      entry <- appendBasicBlock context function "entry"
      withBuilder context $ \builder => do
        positionAtEnd builder entry
        result <- buildAdd builder left right "sum"
        _ <- buildRet builder result
        pure ()
    _ => pure ()

main : IO ()
main = withContext $ \context =>
  withModule context "add-example" $ \mod => do
    buildAdd context mod
    verification <- verifyModule mod
    case verification of
      Left error => putStrLn $ "LLVM verification failed: " ++ show error
      Right () => moduleIR mod >>= putStrLn
