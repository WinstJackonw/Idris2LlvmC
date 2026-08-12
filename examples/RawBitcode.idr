module Main

import LLVM.Internal.Array
import LLVM.Internal.String
import LLVM.Raw

%default total

buildRawAdd : ContextRef -> ModuleRef -> IO ()
buildRawAdd context mod = do
  i32Type <- primIO $ int32TypeInContext context
  signature <- withAnyPtrArray [forgetRef i32Type, forgetRef i32Type] $ \params, count =>
    primIO $ functionType i32Type params count 0
  function <- primIO $ addFunction mod "add" signature
  left <- primIO $ getParam function 0
  right <- primIO $ getParam function 1
  leftLength <- byteLength "left"
  rightLength <- byteLength "right"
  primIO $ setValueName left "left" leftLength
  primIO $ setValueName right "right" rightLength
  entry <- primIO $ appendBasicBlockInContext context function "entry"
  builder <- primIO $ createBuilderInContext context
  primIO $ positionBuilderAtEnd builder entry
  sum <- primIO $ buildAdd builder left right "sum"
  _ <- primIO $ buildRet builder sum
  primIO $ disposeBuilder builder

printModuleIR : ModuleRef -> IO ()
printModuleIR mod = do
  irPointer <- primIO $ printModuleToString mod
  putStrLn !(peekString irPointer)
  primIO $ disposeMessage irPointer

main : IO ()
main = do
  context <- primIO contextCreate
  mod <- primIO $ moduleCreateWithNameInContext "raw-bitcode-example" context
  buildRawAdd context mod
  status <- primIO $ writeBitcodeToFile mod "/tmp/idris2-llvm-raw-bitcode.bc"
  if status /= 0
    then putStrLn "bitcode write failed"
    else do
      ((fileStatus, _), bufferPointer) <- withOutPtr $ \outBuffer =>
        withOutPtr $ \outMessage =>
          primIO $ createMemoryBufferWithContentsOfFile "/tmp/idris2-llvm-raw-bitcode.bc" outBuffer outMessage
      if fileStatus /= 0
        then putStrLn "bitcode read failed"
        else do
          let buffer : MemoryBufferRef = prim__castPtr bufferPointer
          (parseStatus, modulePointer) <- withOutPtr $ \outModule =>
            primIO $ parseBitcodeInContext context buffer outModule
          primIO $ disposeMemoryBuffer buffer
          if parseStatus /= 0
            then putStrLn "bitcode parse failed"
            else do
              let parsed : ModuleRef = prim__castPtr modulePointer
              printModuleIR parsed
              primIO $ disposeModule parsed
  primIO $ disposeModule mod
  primIO $ contextDispose context
