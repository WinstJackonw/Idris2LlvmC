module Main

import LLVM

%default total

buildStruct : Context -> Module -> IO ()
buildStruct context mod = do
  i32Type <- i32 context
  voidType <- void context
  indexZero <- constInt i32Type 0
  point <- namedStructType context "point"
  setStructBody point [i32Type, i32Type] False
  origin <- addGlobal mod point "origin"
  zero <- constNull point
  setInitializer origin zero
  readType <- functionType i32Type [] False
  readX <- addFunction mod "readOriginX" readType
  entry <- appendBasicBlock context readX "entry"
  withBuilder context $ \builder => do
    positionAtEnd builder entry
    xPointer <- buildGEP builder point origin [indexZero, indexZero] "x_ptr"
    xValue <- buildLoad builder i32Type xPointer "x"
    _ <- buildRet builder xValue
    pure ()
  writeType <- functionType voidType [] False
  writeX <- addFunction mod "writeOriginX" writeType
  entry2 <- appendBasicBlock context writeX "entry"
  withBuilder context $ \builder => do
    positionAtEnd builder entry2
    xPointer <- buildGEP builder point origin [indexZero, indexZero] "x_ptr"
    value <- constInt i32Type 42
    _ <- buildStore builder value xPointer
    _ <- buildRetVoid builder
    pure ()

main : IO ()
main = withContext $ \context =>
  withModule context "struct-example" $ \mod => do
    buildStruct context mod
    verification <- verifyModule mod
    case verification of
      Left error => putStrLn $ "LLVM verification failed: " ++ show error
      Right () => moduleIR mod >>= putStrLn
