module LLVM.Coroutines

import LLVM.Core
import LLVM.Error

%default total

export
buildCoroutineIntrinsic : Module -> Builder -> String -> List LLVMType ->
                          List Value -> String -> IO (LLVMResult Value)
buildCoroutineIntrinsic mod builder name overloadTypes arguments resultName = do
  declaration <- intrinsicDeclaration mod name overloadTypes
  case declaration of
    Left error => pure $ Left error
    Right function => do
      signature <- globalValueType function
      Right <$> buildCall builder signature function arguments resultName

export
coroId, coroBegin, coroAlloc, coroSize, coroSave, coroSuspend, coroEnd,
  coroFree, coroPromise, coroDone, coroResume, coroDestroy, coroNoop :
  Module -> Builder -> List LLVMType -> List Value -> String -> IO (LLVMResult Value)
coroId mod builder = buildCoroutineIntrinsic mod builder "llvm.coro.id"
coroBegin mod builder = buildCoroutineIntrinsic mod builder "llvm.coro.begin"
coroAlloc mod builder = buildCoroutineIntrinsic mod builder "llvm.coro.alloc"
coroSize mod builder = buildCoroutineIntrinsic mod builder "llvm.coro.size"
coroSave mod builder = buildCoroutineIntrinsic mod builder "llvm.coro.save"
coroSuspend mod builder = buildCoroutineIntrinsic mod builder "llvm.coro.suspend"
coroEnd mod builder = buildCoroutineIntrinsic mod builder "llvm.coro.end"
coroFree mod builder = buildCoroutineIntrinsic mod builder "llvm.coro.free"
coroPromise mod builder = buildCoroutineIntrinsic mod builder "llvm.coro.promise"
coroDone mod builder = buildCoroutineIntrinsic mod builder "llvm.coro.done"
coroResume mod builder = buildCoroutineIntrinsic mod builder "llvm.coro.resume"
coroDestroy mod builder = buildCoroutineIntrinsic mod builder "llvm.coro.destroy"
coroNoop mod builder = buildCoroutineIntrinsic mod builder "llvm.coro.noop"
