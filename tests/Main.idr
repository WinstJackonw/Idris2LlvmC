module Main

import Data.String
import System
import LLVM
import LLVM.Internal.Array
import LLVM.Internal.String
import LLVM.Raw.Core as Raw
import LLVM.Raw.Types as RawTypes

%default total

failTest : String -> IO a
failTest message = die $ "llvm-c test failure: " ++ message

assert : String -> Bool -> IO ()
assert label True = putStrLn $ "ok: " ++ label
assert label False = failTest label

expectUnit : String -> Either LLVMError () -> IO ()
expectUnit label (Right ()) = putStrLn $ "ok: " ++ label
expectUnit label (Left error) = failTest $ label ++ ": " ++ show error

expectResult : String -> Either LLVMError a -> IO a
expectResult label (Right value) = do
  putStrLn $ "ok: " ++ label
  pure value
expectResult label (Left error) = failTest $ label ++ ": " ++ show error

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

buildRawAddFunction : Context -> Module -> IO (Value, Value)
buildRawAddFunction context mod = do
  let rawContext = toRawContext context
  let rawModule = toRawModule mod
  integerType <- primIO $ Raw.int32TypeInContext rawContext
  signature <- withAnyPtrArray [RawTypes.forgetRef integerType, RawTypes.forgetRef integerType] $ \params, count =>
    primIO $ Raw.functionType integerType params count 0
  function <- primIO $ Raw.addFunction rawModule "raw_add" signature
  left <- primIO $ Raw.getParam function 0
  right <- primIO $ Raw.getParam function 1
  leftLength <- byteLength "left"
  rightLength <- byteLength "right"
  primIO $ Raw.setValueName left "left" leftLength
  primIO $ Raw.setValueName right "right" rightLength
  entry <- primIO $ Raw.appendBasicBlockInContext rawContext function "entry"
  builder <- primIO $ Raw.createBuilderInContext rawContext
  primIO $ Raw.positionBuilderAtEnd builder entry
  sum <- primIO $ Raw.buildAdd builder left right "sum"
  _ <- primIO $ Raw.buildRet builder sum
  primIO $ Raw.disposeBuilder builder
  pure (MkValue function, MkValue sum)

checkRawInterface : IO ()
checkRawInterface = withContext $ \context =>
  withModule context "raw-binding-tests" $ \mod => do
    (function, instruction) <- buildRawAddFunction context mod
    expectUnit "raw module verification" !(verifyModule mod)
    expectUnit "raw function verification" !(verifyFunction function)
    ir <- moduleIR mod
    assert "raw add function appears in IR" ("define i32 @raw_add" `isInfixOf` ir)
    assert "raw add instruction appears in IR" ("add i32 %left, %right" `isInfixOf` ir)
    printed <- valueIR instruction
    assert "raw instruction prints as add" ("add i32 %left, %right" `isInfixOf` printed)

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

checkCoreExtensions : Context -> Module -> IO ()
checkCoreExtensions context mod = do
  integerType <- i32 context
  vecType <- vectorType integerType 2
  assert "vector size" (!(vectorSize vecType) == 2)
  element <- elementType vecType
  assert "vector element type" ("i32" == !(typeIR element))
  one <- constInt integerType 1
  two <- constInt integerType 2
  vector <- constVector [one, two]
  zero <- constInt integerType 0
  mask <- constVector [one, zero]
  signature <- functionType vecType [vecType, vecType] False
  function <- addFunction mod "vector_reverse" signature
  attribute <- expectResult "enum attribute creation" !(enumAttribute context "nounwind" 0)
  addAttribute function FunctionAttribute attribute
  setFunctionCallConv function CCall
  entry <- appendBasicBlock context function "entry"
  leftVector <- parameter function 0
  rightVector <- parameter function 1
  instruction <- withBuilder context $ \builder => do
    positionAtEnd builder entry
    case (leftVector, rightVector) of
      (Just left, Just right) => do
        shuffled <- buildShuffleVector builder left right mask "reversed"
        _ <- buildRet builder shuffled
        pure shuffled
      _ => failTest "vector parameters"
  case !(valueKind instruction) of
    InstructionValue => putStrLn "ok: value kind instruction"
    _ => failTest "value kind instruction"
  assert "isA instruction" !(isA IsInstruction instruction)
  first <- firstBasicBlock function
  case first of
    Nothing => failTest "first basic block"
    Just block => do
      firstInst <- firstInstruction block
      case firstInst of
        Nothing => failTest "first instruction"
        Just value => assert "instruction traversal" !(isA IsInstruction value)

  global <- addGlobal mod integerType "atomic_value"
  initializer <- constInt integerType 0
  setInitializer global initializer
  voidType <- void context
  atomicSig <- functionType voidType [] False
  atomicFn <- addFunction mod "atomic_ops" atomicSig
  atomicEntry <- appendBasicBlock context atomicFn "entry"
  withBuilder context $ \builder => do
    positionAtEnd builder atomicEntry
    _ <- buildAtomicRMW builder AtomicAdd global one SequentiallyConsistent False
    _ <- buildAtomicCmpXchg builder global one two SequentiallyConsistent Monotonic False
    _ <- buildRetVoid builder
    pure ()

checkExceptionHandling : Context -> Module -> IO ()
checkExceptionHandling context mod = do
  integerType <- i32 context
  voidType <- void context
  pointer <- pointerType context 0
  personalityType <- functionType integerType [] True
  personality <- addFunction mod "__gxx_personality_v0" personalityType
  calleeType <- functionType voidType [] False
  callee <- addFunction mod "may_throw" calleeType
  function <- addFunction mod "invoke_test" calleeType
  setPersonality function personality
  entry <- appendBasicBlock context function "entry"
  normal <- appendBasicBlock context function "normal"
  unwind <- appendBasicBlock context function "unwind"
  landingType <- literalStructType context [pointer, integerType] False
  withBuilder context $ \builder => do
    positionAtEnd builder entry
    invoke <- buildInvoke builder calleeType callee [] normal unwind ""
    setInstructionCallConv invoke CCall
    positionAtEnd builder normal
    _ <- buildRetVoid builder
    positionAtEnd builder unwind
    landing <- buildLandingPad builder landingType personality 1 "exception"
    catchAll <- constNull pointer
    addClause landing catchAll
    setCleanup landing True
    _ <- buildResume builder landing
    pure ()

checkCoroutines : IO ()
checkCoroutines = withContext $ \context =>
  withModule context "coroutine-test" $ \mod => do
    pointer <- pointerType context 0
    signature <- functionType pointer [] False
    function <- addFunction mod "coroutine_noop" signature
    entry <- appendBasicBlock context function "entry"
    result <- withBuilder context $ \builder => do
      positionAtEnd builder entry
      intrinsic <- coroNoop mod builder [] [] "noop"
      case intrinsic of
        Left error => pure $ Left error
        Right value => do
          _ <- buildRet builder value
          pure $ Right ()
    expectUnit "coroutine intrinsic wrapper" result
    expectUnit "coroutine module verification" !(verifyModule mod)

checkBuilderDSL : IO ()
checkBuilderDSL = do
  result <- runModuleBuilder "dsl-test" $ do
    context <- currentContext
    mod <- currentModule
    builder <- currentBuilder
    integerType <- liftBuilderIO $ i32 context
    signature <- liftBuilderIO $ functionType integerType [] False
    function <- liftBuilderIO $ addFunction mod "dsl_value" signature
    entry <- liftBuilderIO $ appendBasicBlock context function "entry"
    liftBuilderIO $ positionAtEnd builder entry
    value <- liftBuilderIO $ constInt integerType 9
    _ <- liftBuilderIO $ buildRet builder value
    pure ()
  expectUnit "module builder DSL" result

checkOrc : IO ()
checkOrc = do
  result <- withLLJIT $ \jit => do
    added <- addJITModule jit "jit-test" $ do
      context <- currentContext
      mod <- currentModule
      builder <- currentBuilder
      integerType <- liftBuilderIO $ i64 context
      signature <- liftBuilderIO $ functionType integerType [integerType, integerType] False
      function <- liftBuilderIO $ addFunction mod "jit_add" signature
      left <- liftBuilderIO $ parameter function 0
      right <- liftBuilderIO $ parameter function 1
      case (left, right) of
        (Just x, Just y) => do
          entry <- liftBuilderIO $ appendBasicBlock context function "entry"
          liftBuilderIO $ positionAtEnd builder entry
          sum <- liftBuilderIO $ buildAdd builder x y "sum"
          _ <- liftBuilderIO $ buildRet builder sum
          pure ()
        _ => builderError $ simpleError "checkOrc" "missing JIT function parameters"
    case added of
      Left error => pure $ Left error
      Right () => do
        address <- lookupSymbol jit "jit_add"
        case address of
          Left error => pure $ Left error
          Right pointer => Right <$> callJITU64_2 pointer 20 22
  value <- expectResult "ORC LLJIT execution" result
  assert "ORC LLJIT result" (value == 42)

checkDisassembler : IO ()
checkDisassembler = do
  let config = MkDisassemblerConfig "x86_64-unknown-linux-gnu" "generic" "" 0
  instructions <- expectResult "disassembler" !(disassembleBytes config 4096 [0x48, 0x89, 0xF8, 0xC3])
  assert "disassembler emitted instructions" (not $ null instructions)

checkObjectInspection : IO ()
checkObjectInspection = do
  info <- expectResult "object inspection" !(inspectObjectFile "tests/build/add.o")
  assert "object has sections" (not $ null info.sections)
  assert "object has symbols" (not $ null info.symbols)

checkRemarks : IO ()
checkRemarks = do
  remarks <- expectResult "remarks YAML parser" !(parseRemarksFile YAML "tests/remarks.yaml")
  case remarks of
    [remark] => do
      assert "remark pass name" (remark.passName == "inline")
      assert "remark hotness" (remark.hotness == 42)
    _ => failTest "remarks YAML entry count"

checkLTO : IO ()
checkLTO = do
  version <- ltoVersion
  assert "LTO version" ("LLVM version 22.1" `isInfixOf` version)
  generated <- expectResult "regular LTO" !(compileLTOToFile defaultLTOConfig ["tests/build/roundtrip.bc"])
  assert "regular LTO output path" (generated /= "")
  rejected <- runThinLTO (defaultThinLTOConfig "tests/build")
                [MkThinLTOInput "missing-layout" "tests/build/roundtrip.bc"]
  case rejected of
    Left _ => putStrLn "ok: ThinLTO precondition error"
    Right _ => failTest "ThinLTO accepted bitcode without target data layout"
  thin <- runThinLTO (defaultThinLTOConfig "tests/build")
            [MkThinLTOInput "thin" "tests/build/thin.bc"]
  case thin of
    Right paths => assert "ThinLTO object output" (not $ null paths)
    Left error => failTest $ "ThinLTO: " ++ show error

runTests : IO ()
runTests = do
  version <- llvmVersion
  assert "LLVM major version" (version.major == 22)
  assert "LLVM minor version" (version.minor == 1)
  assert "shim ABI version" (!(shimABIVersion) == 3)
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
      expectUnit "targeted bitcode write" !(writeBitcodeFile mod "tests/build/thin.bc")
      checkCoreExtensions context mod
      checkExceptionHandling context mod
      expectUnit "extended Core verification" !(verifyModule mod)
  checkRawInterface
  checkBuilderDSL
  checkCoroutines
  withFatalErrorHandler (\_ => ()) $ putStrLn "ok: fatal error handler install/reset"
  checkOrc
  checkDisassembler
  checkObjectInspection
  checkRemarks
  checkLTO

main : IO ()
main = do
  runTests
  putStrLn "all llvm-c tests passed"
