module LLVM.Remarks

import LLVM.Core
import LLVM.Error
import LLVM.Internal.String
import LLVM.Raw.Core as RawCore
import LLVM.Raw.Remarks as Raw
import LLVM.Raw.Types as RawTypes

%default total

public export data RemarkFormat = YAML | Bitstream

public export
data RemarkType = Passed | Missed | Analysis | AnalysisFPCommute | AnalysisAliasing
                | Failure | UnknownRemarkType Int32

public export
record RemarkDebugLoc where
  constructor MkRemarkDebugLoc
  sourceFile : String
  line : Bits32
  column : Bits32

public export
record RemarkArg where
  constructor MkRemarkArg
  key : String
  value : String
  location : Maybe RemarkDebugLoc

public export
record Remark where
  constructor MkRemark
  remarkType : RemarkType
  passName : String
  remarkName : String
  functionName : String
  location : Maybe RemarkDebugLoc
  hotness : Bits64
  arguments : List RemarkArg

decodeType : Int32 -> RemarkType
decodeType 0 = Passed
decodeType 1 = Missed
decodeType 2 = Analysis
decodeType 3 = AnalysisFPCommute
decodeType 4 = AnalysisAliasing
decodeType 5 = Failure
decodeType value = UnknownRemarkType value

copyString : RawTypes.RemarkStringRef -> IO String
copyString reference = if RawTypes.isNullRef reference then pure "" else do
  pointer <- primIO $ Raw.stringGetData reference
  length <- primIO $ Raw.stringGetLength reference
  peekStringLength pointer (cast length)

copyLocation : RawTypes.RemarkDebugLocRef -> IO (Maybe RemarkDebugLoc)
copyLocation reference = if RawTypes.isNullRef reference then pure Nothing else do
  fileReference <- primIO $ Raw.debugLocGetSourceFilePath reference
  file <- copyString fileReference
  line <- primIO $ Raw.debugLocGetSourceLine reference
  column <- primIO $ Raw.debugLocGetSourceColumn reference
  pure $ Just $ MkRemarkDebugLoc file line column

collectArgs : Nat -> RawTypes.RemarkEntryRef -> RawTypes.RemarkArgRef -> IO (List RemarkArg)
collectArgs Z entry argument = pure []
collectArgs (S fuel) entry argument = if RawTypes.isNullRef argument then pure [] else do
  key <- primIO (Raw.argGetKey argument) >>= copyString
  value <- primIO (Raw.argGetValue argument) >>= copyString
  location <- primIO (Raw.argGetDebugLoc argument) >>= copyLocation
  next <- primIO $ Raw.entryGetNextArg argument entry
  rest <- collectArgs fuel entry next
  pure $ MkRemarkArg key value location :: rest

copyEntry : RawTypes.RemarkEntryRef -> IO Remark
copyEntry entry = do
  kind <- decodeType <$> (primIO $ Raw.entryGetType entry)
  pass <- primIO (Raw.entryGetPassName entry) >>= copyString
  name <- primIO (Raw.entryGetRemarkName entry) >>= copyString
  function <- primIO (Raw.entryGetFunctionName entry) >>= copyString
  location <- primIO (Raw.entryGetDebugLoc entry) >>= copyLocation
  hotness <- primIO $ Raw.entryGetHotness entry
  count <- primIO $ Raw.entryGetNumArgs entry
  first <- primIO $ Raw.entryGetFirstArg entry
  arguments <- collectArgs (cast count) entry first
  pure $ MkRemark kind pass name function location hotness arguments

collectEntries : Nat -> RawTypes.RemarkParserRef -> IO (List Remark)
collectEntries Z parser = pure []
collectEntries (S fuel) parser = do
  entry <- primIO $ Raw.parserGetNext parser
  if RawTypes.isNullRef entry
    then pure []
    else do
      value <- copyEntry entry
      primIO $ Raw.entryDispose entry
      rest <- collectEntries fuel parser
      pure $ value :: rest

createParser : RemarkFormat -> AnyPtr -> Bits64 -> PrimIO RawTypes.RemarkParserRef
createParser YAML = Raw.parserCreateYAML
createParser Bitstream = Raw.parserCreateBitstream

export
parseRemarksFile : RemarkFormat -> String -> IO (LLVMResult (List Remark))
parseRemarksFile format path = withMemoryBufferFromFile path $ \buffer => do
  let rawBuffer = toRawMemoryBuffer buffer
  start <- primIO $ RawCore.getBufferStart rawBuffer
  size <- primIO $ RawCore.getBufferSize rawBuffer
  parser <- primIO $ createParser format (RawTypes.forgetRef start) size
  if RawTypes.isNullRef parser
    then pure $ Left $ simpleError "parseRemarksFile" "could not create remarks parser"
    else do
      remarks <- collectEntries 1000000 parser
      failed <- primIO $ Raw.parserHasError parser
      if failed /= 0
        then do
          messagePointer <- primIO $ Raw.parserGetErrorMessage parser
          message <- if RawTypes.isNullRef messagePointer then pure "invalid remarks input" else peekString messagePointer
          primIO $ Raw.parserDispose parser
          pure $ Left $ simpleError "parseRemarksFile" message
        else do
          primIO $ Raw.parserDispose parser
          pure $ Right remarks
