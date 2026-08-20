module LLVM.Error

%default total

public export
record LLVMError where
  constructor MkLLVMError
  operation : String
  message : String

public export
LLVMResult : Type -> Type
LLVMResult a = Either LLVMError a

public export
Show LLVMError where
  show error = error.operation ++ ": " ++ error.message

public export
Eq LLVMError where
  left == right = left.operation == right.operation && left.message == right.message

export
simpleError : String -> String -> LLVMError
simpleError = MkLLVMError
