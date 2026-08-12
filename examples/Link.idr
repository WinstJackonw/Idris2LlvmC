module Main

import LLVM

%default total

buildAdd : Context -> Module -> IO ()
buildAdd context mod = do
  i32Type <- i32 context
  signature <- functionType i32Type [i32Type, i32Type] False
  function <- addFunction mod "add" signature
  first <- parameter function 0
  second <- parameter function 1
  case (first, second) of
    (Just left, Just right) => do
      entry <- appendBasicBlock context function "entry"
      withBuilder context $ \builder => do
        positionAtEnd builder entry
        result <- buildAdd builder left right "sum"
        _ <- buildRet builder result
        pure ()
    _ => pure ()

buildMultiply : Context -> Module -> IO ()
buildMultiply context mod = do
  i32Type <- i32 context
  signature <- functionType i32Type [i32Type, i32Type] False
  function <- addFunction mod "multiply" signature
  first <- parameter function 0
  second <- parameter function 1
  case (first, second) of
    (Just left, Just right) => do
      entry <- appendBasicBlock context function "entry"
      withBuilder context $ \builder => do
        positionAtEnd builder entry
        result <- buildMul builder left right "product"
        _ <- buildRet builder result
        pure ()
    _ => pure ()

main : IO ()
main = withContext $ \context =>
  withModule context "link-a" $ \modA => do
    buildAdd context modA
    withModule context "link-b" $ \modB => do
      buildMultiply context modB
      linked <- linkInto modA modB
      case linked of
        Left error => putStrLn $ "link failed: " ++ show error
        Right () => do
          verification <- verifyModule modA
          case verification of
            Left error => putStrLn $ "LLVM verification failed: " ++ show error
            Right () => moduleIR modA >>= putStrLn
