module Main

import LLVM

%default total

buildMax : Context -> Module -> IO ()
buildMax context mod = do
  i32Type <- i32 context
  signature <- functionType i32Type [i32Type, i32Type] False
  function <- addFunction mod "max" signature
  first <- parameter function 0
  second <- parameter function 1
  case (first, second) of
    (Just left, Just right) => do
      setValueName left "a"
      setValueName right "b"
      entry <- appendBasicBlock context function "entry"
      aIsLarger <- appendBasicBlock context function "aIsLarger"
      merge <- appendBasicBlock context function "merge"
      withBuilder context $ \builder => do
        positionAtEnd builder entry
        condition <- buildICmp builder IntSGT left right "a_gt_b"
        _ <- buildCondBr builder condition aIsLarger merge
        positionAtEnd builder aIsLarger
        _ <- buildBr builder merge
        positionAtEnd builder merge
        result <- buildPhi builder i32Type "result"
        addIncoming result [(left, entry), (left, aIsLarger)]
        _ <- buildRet builder result
        pure ()
    _ => pure ()

main : IO ()
main = withContext $ \context =>
  withModule context "cond-example" $ \mod => do
    buildMax context mod
    verification <- verifyModule mod
    case verification of
      Left error => putStrLn $ "LLVM verification failed: " ++ show error
      Right () => moduleIR mod >>= putStrLn
