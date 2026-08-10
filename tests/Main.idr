module Main

import Data.String
import System
import LLVM

%default total

failTest : String -> IO a
failTest message = die $ "llvm-c test failure: " ++ message

assert : String -> Bool -> IO ()
assert label True = putStrLn $ "ok: " ++ label
assert label False = failTest label

expectUnit : String -> Either LLVMError () -> IO ()
expectUnit label (Right ()) = putStrLn $ "ok: " ++ label
expectUnit label (Left error) = failTest $ label ++ ": " ++ show error

buildAddFunction : Context -> Module -> IO (Value, Value)
buildAddFunction context mod = do
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
      result <- withBuilder context $ \builder => do
        positionAtEnd builder entry
        sum <- buildAdd builder left right "sum"
        _ <- buildRet builder sum
        pure sum
      pure (function, result)
    _ => failTest "LLVM function parameters were unavailable"

addDebugInfo : Context -> Module -> Value -> Value -> IO ()
addDebugInfo context mod function instruction = do
  addDebugInfoVersion context mod
  withDIBuilder mod $ \builder => do
    (file, compileUnit) <- createCompileUnit builder (defaultCompileUnit "tests.idr" ".")
    intDebugType <- createBasicType builder "Int32" 32 Signed
    signature <- createSubroutineType builder file
                   [intDebugType, intDebugType, intDebugType]
    subprogram <- createFunction builder compileUnit "add" file 1 signature False
    attachSubprogram function subprogram
    location <- createLocation context 1 1 subprogram Nothing
    setInstructionLocation instruction location

checkTextRoundTrip : Context -> String -> IO ()
checkTextRoundTrip context ir = do
  parsed <- withParsedIR context ir verifyModule
  case parsed of
    Right (Right ()) => putStrLn "ok: textual IR round-trip"
    Right (Left error) => failTest $ "parsed IR verification: " ++ show error
    Left error => failTest $ "textual IR parsing: " ++ show error

checkBitcodeRoundTrip : Context -> Module -> IO ()
checkBitcodeRoundTrip context mod = do
  expectUnit "bitcode write" !(writeBitcodeFile mod "tests/build/roundtrip.bc")
  parsed <- withBitcodeModuleFromFile context "tests/build/roundtrip.bc" verifyModule
  case parsed of
    Right (Right ()) => putStrLn "ok: bitcode round-trip"
    Right (Left error) => failTest $ "bitcode verification: " ++ show error
    Left error => failTest $ "bitcode parsing: " ++ show error

checkPasses : Module -> IO ()
checkPasses mod = do
  expectUnit "new pass manager" !(runPasses mod Nothing "default<O1>" defaultPassOptions)
  expectUnit "post-pass verification" !(verifyModule mod)

checkTargetEmission : Module -> IO ()
checkTargetEmission mod = do
  config <- hostTargetMachineConfig
  emitted <- withTargetMachine config $ \machine => do
    configureModuleForTarget mod config machine
    emitToFile machine mod Object "tests/build/add.o"
  case emitted of
    Right (Right ()) => putStrLn "ok: native object emission"
    Right (Left error) => failTest $ "object emission: " ++ show error
    Left error => failTest $ "target machine: " ++ show error

checkLinker : Context -> Module -> IO ()
checkLinker context destination =
  withModule context "link-source" $ \source => do
    integerType <- i32 context
    signature <- functionType integerType [] False
    function <- addFunction source "linked_function" signature
    entry <- appendBasicBlock context function "entry"
    withBuilder context $ \builder => do
      positionAtEnd builder entry
      zero <- constInt integerType 0
      _ <- buildRet builder zero
      pure ()
    expectUnit "module linker" !(linkInto destination source)
    linked <- findFunction destination "linked_function"
    case linked of
      Just _ => putStrLn "ok: linked symbol lookup"
      Nothing => failTest "linked symbol lookup"

runTests : IO ()
runTests = do
  version <- llvmVersion
  assert "LLVM major version" (version.major == 22)
  assert "LLVM minor version" (version.minor == 1)
  assert "shim ABI version" (!(shimABIVersion) == 1)
  withContext $ \context =>
    withModule context "binding-tests" $ \mod => do
      (function, instruction) <- buildAddFunction context mod
      addDebugInfo context mod function instruction
      expectUnit "constructed module verification" !(verifyModule mod)
      ir <- moduleIR mod
      assert "generated function appears in IR" ("define i32 @add" `isInfixOf` ir)
      assert "debug compile unit appears in IR" ("!DICompileUnit" `isInfixOf` ir)
      checkTextRoundTrip context ir
      checkBitcodeRoundTrip context mod
      checkLinker context mod
      checkPasses mod
      checkTargetEmission mod

main : IO ()
main = do
  runTests
  putStrLn "all llvm-c tests passed"
