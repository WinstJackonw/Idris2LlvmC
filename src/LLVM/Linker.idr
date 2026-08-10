module LLVM.Linker

import LLVM.Core
import LLVM.Error
import LLVM.Raw.Core as RawCore
import LLVM.Raw.Linker as Raw

%default total

||| Link a clone of source into destination. Source remains valid.
export
linkInto : Module -> Module -> IO (Either LLVMError ())
linkInto destination source = do
  clone <- primIO $ RawCore.cloneModule (toRawModule source)
  status <- primIO $ Raw.linkModules (toRawModule destination) clone
  pure $ if status == 0
    then Right ()
    else Left $ MkLLVMError "linkInto" "LLVM module linking failed"

