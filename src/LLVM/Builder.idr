module LLVM.Builder

import LLVM.Core
import LLVM.Error

%default total

public export
record ModuleBuilder a where
  constructor MkModuleBuilder
  runBuilder : Context -> Module -> Builder -> IO (LLVMResult a)

public export
Functor ModuleBuilder where
  map transform (MkModuleBuilder action) = MkModuleBuilder $ \context, mod, builder => do
    result <- action context mod builder
    pure $ map transform result

public export
Applicative ModuleBuilder where
  pure value = MkModuleBuilder $ \_, _, _ => pure $ Right value
  (MkModuleBuilder function) <*> (MkModuleBuilder argument) =
    MkModuleBuilder $ \context, mod, builder => do
      functionResult <- function context mod builder
      case functionResult of
        Left error => pure $ Left error
        Right apply => do
          argumentResult <- argument context mod builder
          pure $ map apply argumentResult

public export
Monad ModuleBuilder where
  (MkModuleBuilder action) >>= next = MkModuleBuilder $ \context, mod, builder => do
    result <- action context mod builder
    case result of
      Left error => pure $ Left error
      Right value => runBuilder (next value) context mod builder

export
builderError : LLVMError -> ModuleBuilder a
builderError error = MkModuleBuilder $ \_, _, _ => pure $ Left error

export
liftBuilderIO : IO a -> ModuleBuilder a
liftBuilderIO action = MkModuleBuilder $ \_, _, _ => Right <$> action

export
liftBuilderResult : IO (LLVMResult a) -> ModuleBuilder a
liftBuilderResult action = MkModuleBuilder $ \_, _, _ => action

export
currentContext : ModuleBuilder Context
currentContext = MkModuleBuilder $ \context, _, _ => pure $ Right context

export
currentModule : ModuleBuilder Module
currentModule = MkModuleBuilder $ \_, mod, _ => pure $ Right mod

export
currentBuilder : ModuleBuilder Builder
currentBuilder = MkModuleBuilder $ \_, _, builder => pure $ Right builder

export
withModuleBuilder : Context -> String ->
                    (Module -> Builder -> IO (LLVMResult a)) -> IO (LLVMResult a)
withModuleBuilder context name action =
  withModuleE context name $ \mod =>
    withBuilderE context $ \builder => action mod builder

export
runModuleBuilderIn : Context -> String -> ModuleBuilder a -> IO (LLVMResult a)
runModuleBuilderIn context name program =
  withModuleBuilder context name $ \mod, builder =>
    runBuilder program context mod builder

export
runModuleBuilder : String -> ModuleBuilder a -> IO (LLVMResult a)
runModuleBuilder name program = withContextE $ \context =>
  runModuleBuilderIn context name program
