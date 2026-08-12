module Main

import LLVM

%default total

buildFold : Context -> Module -> IO ()
buildFold context mod = do
  i32Type <- i32 context
  signature <- functionType i32Type [i32Type] False
  function <- addFunction mod "fold" signature
  input <- parameter function 0
  case input of
    Just value => do
      setValueName value "x"
      entry <- appendBasicBlock context function "entry"
      withBuilder context $ \builder => do
        positionAtEnd builder entry
        one <- constInt i32Type 1
        product <- buildMul builder value one "product"
        _ <- buildRet builder product
        pure ()
    _ => pure ()

main : IO ()
main = withContext $ \context =>
  withModule context "optimize-example" $ \mod => do
    buildFold context mod
    before <- moduleIR mod
    putStrLn "before:"
    putStrLn before
    optimized <- runPasses mod Nothing "instcombine" defaultPassOptions
    case optimized of
      Left error => putStrLn $ "passes failed: " ++ show error
      Right () => do
        after <- moduleIR mod
        putStrLn "after:"
        putStrLn after
