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

main : IO ()
main = withContext $ \context =>
  withModule context "bitcode-example" $ \mod => do
    buildAdd context mod
    written <- writeBitcodeFile mod "/tmp/idris2-llvm-bitcode.bc"
    case written of
      Left error => putStrLn $ "bitcode write failed: " ++ show error
      Right () => do
        parsed <- withBitcodeModuleFromFile context "/tmp/idris2-llvm-bitcode.bc" moduleIR
        case parsed of
          Left error => putStrLn $ "bitcode read failed: " ++ show error
          Right ir => putStrLn ir
