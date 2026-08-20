module LLVM.Disassembler

import Data.List
import LLVM.Error
import LLVM.Internal.Array
import LLVM.Internal.String
import LLVM.Raw.Disassembler as Raw
import LLVM.Raw.Types as RawTypes
import LLVM.Target

%default total

public export
record DisassemblerConfig where
  constructor MkDisassemblerConfig
  triple : String
  cpu : String
  features : String
  options : Bits64

public export
record DisassembledInstruction where
  constructor MkDisassembledInstruction
  address : Bits64
  size : Bits64
  text : String

export
withDisassembler : DisassemblerConfig ->
                   (RawTypes.DisasmContextRef -> IO (LLVMResult a)) -> IO (LLVMResult a)
withDisassembler config action = do
  initializeAll
  context <- primIO $ Raw.createDisasm config.triple config.cpu config.features
  if RawTypes.isNullRef context
    then pure $ Left $ simpleError "withDisassembler" ("unsupported target: " ++ config.triple)
    else do
      status <- primIO $ Raw.setDisasmOptions context config.options
      if status == 0 && config.options /= 0
        then do
          primIO $ Raw.disposeDisasm context
          pure $ Left $ simpleError "withDisassembler" "requested disassembler options are unsupported"
        else do
          result <- action context
          primIO $ Raw.disposeDisasm context
          pure result

disassembleAll : Nat -> RawTypes.DisasmContextRef -> Bits64 -> List Bits8 ->
                 IO (LLVMResult (List DisassembledInstruction))
disassembleAll Z context address bytes =
  if null bytes
    then pure $ Right []
    else pure $ Left $ simpleError "disassembleBytes" "disassembler made no progress"
disassembleAll (S fuel) context address [] = pure $ Right []
disassembleAll (S fuel) context address bytes =
  withU8Array bytes $ \input, inputLength =>
    withU8Array (replicate 256 0) $ \output, outputLength => do
      consumed <- primIO $ Raw.disasmInstruction context input inputLength address output outputLength
      if consumed == 0
        then pure $ Left $ simpleError "disassembleBytes" ("invalid instruction at address " ++ show address)
        else do
          instruction <- peekString (RawTypes.castRef output)
          rest <- disassembleAll fuel context (address + consumed) (drop (cast consumed) bytes)
          pure $ map (MkDisassembledInstruction address consumed instruction ::) rest

export
disassembleBytes : DisassemblerConfig -> Bits64 -> List Bits8 ->
                   IO (LLVMResult (List DisassembledInstruction))
disassembleBytes config address bytes = withDisassembler config $ \context =>
  disassembleAll (length bytes) context address bytes
