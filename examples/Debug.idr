module Main

import LLVM

%default total

buildDebug : Context -> Module -> IO ()
buildDebug context mod = do
  addDebugInfoVersion context mod
  withDIBuilder mod $ \builder => do
    (file, compileUnit) <- createCompileUnit builder (defaultCompileUnit "debug.idr" "examples")
    i32Type <- i32 context
    debugInt <- createBasicType builder "int" 32 Signed
    subroutineType <- createSubroutineType builder file [debugInt, debugInt, debugInt]
    subprogram <- createFunction builder compileUnit "add" file 4 subroutineType False
    signature <- functionType i32Type [i32Type, i32Type] False
    function <- addFunction mod "add" signature
    attachSubprogram function subprogram
    first <- parameter function 0
    second <- parameter function 1
    case (first, second) of
      (Just left, Just right) => do
        entry <- appendBasicBlock context function "entry"
        location <- createLocation context 5 2 subprogram Nothing
        withBuilder context $ \builder => do
          positionAtEnd builder entry
          setCurrentLocation builder location
          result <- buildAdd builder left right "sum"
          setInstructionLocation result location
          _ <- buildRet builder result
          pure ()
      _ => pure ()

main : IO ()
main = withContext $ \context =>
  withModule context "debug-example" $ \mod => do
    buildDebug context mod
    verification <- verifyModule mod
    case verification of
      Left error => putStrLn $ "LLVM verification failed: " ++ show error
      Right () => moduleIR mod >>= putStrLn
