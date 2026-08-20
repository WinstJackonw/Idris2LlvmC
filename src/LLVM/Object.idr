module LLVM.Object

import LLVM.Core
import LLVM.Error
import LLVM.Internal.Array
import LLVM.Internal.String
import LLVM.Raw.Core as RawCore
import LLVM.Raw.Object as Raw
import LLVM.Raw.Types as RawTypes

%default total

public export
record RelocationInfo where
  constructor MkRelocationInfo
  offset : Bits64
  relocationType : Bits64
  typeName : String
  value : String

public export
record SectionInfo where
  constructor MkSectionInfo
  name : String
  address : Bits64
  size : Bits64
  relocations : List RelocationInfo

public export
record SymbolInfo where
  constructor MkSymbolInfo
  name : String
  address : Bits64
  size : Bits64

public export
record ObjectInfo where
  constructor MkObjectInfo
  binaryType : Int32
  sections : List SectionInfo
  symbols : List SymbolInfo

borrowedString : IO (Ptr String) -> IO String
borrowedString get = do
  pointer <- get
  if RawTypes.isNullRef pointer then pure "" else peekString pointer

collectRelocations : Nat -> RawTypes.SectionIteratorRef -> RawTypes.RelocationIteratorRef -> IO (List RelocationInfo)
collectRelocations Z section iterator = pure []
collectRelocations (S fuel) section iterator = do
  done <- primIO $ Raw.isRelocationIteratorAtEnd section iterator
  if done /= 0
    then pure []
    else do
      offset <- primIO $ Raw.getRelocationOffset iterator
      kind <- primIO $ Raw.getRelocationType iterator
      typeName <- borrowedString $ primIO $ Raw.getRelocationTypeName iterator
      value <- borrowedString $ primIO $ Raw.getRelocationValueString iterator
      primIO $ Raw.moveToNextRelocation iterator
      rest <- collectRelocations fuel section iterator
      pure $ MkRelocationInfo offset kind typeName value :: rest

collectSections : Nat -> RawTypes.BinaryRef -> RawTypes.SectionIteratorRef -> IO (List SectionInfo)
collectSections Z binary iterator = pure []
collectSections (S fuel) binary iterator = do
  done <- primIO $ Raw.isSectionIteratorAtEnd binary iterator
  if done /= 0
    then pure []
    else do
      name <- borrowedString $ primIO $ Raw.getSectionName iterator
      size <- primIO $ Raw.getSectionSize iterator
      address <- primIO $ Raw.getSectionAddress iterator
      relocIterator <- primIO $ Raw.getRelocations iterator
      relocations <- collectRelocations 100000 iterator relocIterator
      primIO $ Raw.disposeRelocationIterator relocIterator
      primIO $ Raw.moveToNextSection iterator
      rest <- collectSections fuel binary iterator
      pure $ MkSectionInfo name address size relocations :: rest

collectSymbols : Nat -> RawTypes.BinaryRef -> RawTypes.SymbolIteratorRef -> IO (List SymbolInfo)
collectSymbols Z binary iterator = pure []
collectSymbols (S fuel) binary iterator = do
  done <- primIO $ Raw.isSymbolIteratorAtEnd binary iterator
  if done /= 0
    then pure []
    else do
      name <- borrowedString $ primIO $ Raw.getSymbolName iterator
      address <- primIO $ Raw.getSymbolAddress iterator
      size <- primIO $ Raw.getSymbolSize iterator
      primIO $ Raw.moveToNextSymbol iterator
      rest <- collectSymbols fuel binary iterator
      pure $ MkSymbolInfo name address size :: rest

takeMessage : AnyPtr -> IO String
takeMessage pointer = do
  null <- isNull pointer
  if null then pure "input is not a supported object file" else do
    let stringPointer : Ptr String = prim__castPtr pointer
    message <- peekString stringPointer
    primIO $ RawCore.disposeMessage stringPointer
    pure message

export
inspectObjectFile : String -> IO (LLVMResult ObjectInfo)
inspectObjectFile path = withContextE $ \context =>
  withMemoryBufferFromFile path $ \buffer => do
    (binary, messagePointer) <- withOutPtr $ \outMessage =>
      primIO $ Raw.createBinary (toRawMemoryBuffer buffer) (toRawContext context) outMessage
    if RawTypes.isNullRef binary
      then Left . simpleError "inspectObjectFile" <$> takeMessage messagePointer
      else do
        kind <- primIO $ Raw.binaryGetType binary
        sectionIterator <- primIO $ Raw.copySectionIterator binary
        sections <- collectSections 100000 binary sectionIterator
        primIO $ Raw.disposeSectionIterator sectionIterator
        symbolIterator <- primIO $ Raw.copySymbolIterator binary
        symbols <- collectSymbols 100000 binary symbolIterator
        primIO $ Raw.disposeSymbolIterator symbolIterator
        primIO $ Raw.disposeBinary binary
        pure $ Right $ MkObjectInfo kind sections symbols
