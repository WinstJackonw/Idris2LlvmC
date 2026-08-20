module Main

import System
import LLVM

%default total

jitAdd : ModuleBuilder ()
jitAdd = do
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
    _ => builderError $ simpleError "jitAdd" "missing function parameters"

main : IO ()
main = do
  result <- withLLJIT $ \jit => do
    added <- addJITModule jit "jit-example" jitAdd
    case added of
      Left error => pure $ Left error
      Right () => do
        symbol <- lookupSymbol jit "jit_add"
        case symbol of
          Left error => pure $ Left error
          Right address => Right <$> callJITU64_2 address 20 22
  case result of
    Left error => die $ show error
    Right value => putStrLn $ "jit result: " ++ show value
