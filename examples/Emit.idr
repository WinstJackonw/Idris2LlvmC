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
main = do
  initialized <- initializeNative
  case initialized of
    Left error => putStrLn $ "native target unavailable: " ++ show error
    Right () => do
      config <- hostTargetMachineConfig
      withContext $ \context =>
        withModule context "emit-example" $ \mod => do
          buildAdd context mod
          emitted <- withTargetMachine config $ \machine => do
            configureModuleForTarget mod config machine
            layout <- targetDataLayout machine
            putStrLn $ "ok: target data layout " ++ layout
            written <- emitToFile machine mod Assembly "/tmp/idris2-llvm-emit.s"
            case written of
              Left error => putStrLn $ "emit failed: " ++ show error
              Right () => putStrLn "ok: assembly written to /tmp/idris2-llvm-emit.s"
          case emitted of
            Left error => putStrLn $ "target machine failed: " ++ show error
            Right () => pure ()
