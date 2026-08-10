module LLVM.Target

import LLVM.Core
import LLVM.Error
import LLVM.Internal.Array
import LLVM.Internal.String
import LLVM.Raw.Core as RawCore
import LLVM.Raw.Enums as RawEnums
import LLVM.Raw.Target as Raw
import LLVM.Raw.Types as RawTypes

%default total

public export data Target = MkTarget RawTypes.TargetRef
public export data TargetMachine = MkTargetMachine RawTypes.TargetMachineRef
public export data TargetData = MkTargetData RawTypes.TargetDataRef

export toRawTarget : Target -> RawTypes.TargetRef
toRawTarget (MkTarget target) = target

export toRawTargetMachine : TargetMachine -> RawTypes.TargetMachineRef
toRawTargetMachine (MkTargetMachine machine) = machine

export toRawTargetData : TargetData -> RawTypes.TargetDataRef
toRawTargetData (MkTargetData dataLayout) = dataLayout

public export
data OptimizationLevel = None | Less | Default | Aggressive

toRawOpt : OptimizationLevel -> RawEnums.LLVMCodeGenOptLevel
toRawOpt None = RawEnums.llvmCodeGenLevelNone
toRawOpt Less = RawEnums.llvmCodeGenLevelLess
toRawOpt Default = RawEnums.llvmCodeGenLevelDefault
toRawOpt Aggressive = RawEnums.llvmCodeGenLevelAggressive

public export
data Relocation = RelocDefault | Static | PIC | DynamicNoPIC | ROPI | RWPI | ROPI_RWPI

toRawReloc : Relocation -> RawEnums.LLVMRelocMode
toRawReloc RelocDefault = RawEnums.llvmRelocDefault
toRawReloc Static = RawEnums.llvmRelocStatic
toRawReloc PIC = RawEnums.llvmRelocPIC
toRawReloc DynamicNoPIC = RawEnums.llvmRelocDynamicNoPic
toRawReloc ROPI = RawEnums.llvmRelocROPI
toRawReloc RWPI = RawEnums.llvmRelocRWPI
toRawReloc ROPI_RWPI = RawEnums.llvmRelocROPI_RWPI

public export
data CodeModel = ModelDefault | JITDefault | Tiny | Small | Kernel | Medium | Large

toRawCodeModel : CodeModel -> RawEnums.LLVMCodeModel
toRawCodeModel ModelDefault = RawEnums.llvmCodeModelDefault
toRawCodeModel JITDefault = RawEnums.llvmCodeModelJITDefault
toRawCodeModel Tiny = RawEnums.llvmCodeModelTiny
toRawCodeModel Small = RawEnums.llvmCodeModelSmall
toRawCodeModel Kernel = RawEnums.llvmCodeModelKernel
toRawCodeModel Medium = RawEnums.llvmCodeModelMedium
toRawCodeModel Large = RawEnums.llvmCodeModelLarge

public export
data OutputKind = Assembly | Object

toRawOutput : OutputKind -> RawEnums.LLVMCodeGenFileType
toRawOutput Assembly = RawEnums.llvmAssemblyFile
toRawOutput Object = RawEnums.llvmObjectFile

public export
record TargetMachineConfig where
  constructor MkTargetMachineConfig
  triple : String
  cpu : String
  features : String
  optimization : OptimizationLevel
  relocation : Relocation
  codeModel : CodeModel

ownedMessage : IO (Ptr String) -> IO String
ownedMessage get = do
  pointer <- get
  value <- peekString pointer
  primIO $ RawCore.disposeMessage pointer
  pure value

takeMessage : AnyPtr -> String -> IO String
takeMessage pointer fallback = do
  null <- isNull pointer
  if null
    then pure fallback
    else do
      let stringPointer : Ptr String = prim__castPtr pointer
      message <- peekString stringPointer
      primIO $ RawCore.disposeMessage stringPointer
      pure message

export
initializeNative : IO (Either LLVMError ())
initializeNative = do
  targetStatus <- primIO Raw.initializeNativeTarget
  printerStatus <- primIO Raw.initializeNativeAsmPrinter
  parserStatus <- primIO Raw.initializeNativeAsmParser
  pure $ if targetStatus == 0 && printerStatus == 0 && parserStatus == 0
    then Right ()
    else Left $ MkLLVMError "initializeNative" "native target support is unavailable"

export
initializeAll : IO ()
initializeAll = do
  primIO Raw.initializeAllTargetInfos
  primIO Raw.initializeAllTargets
  primIO Raw.initializeAllTargetMCs
  primIO Raw.initializeAllAsmParsers
  primIO Raw.initializeAllAsmPrinters

export
hostTargetMachineConfig : IO TargetMachineConfig
hostTargetMachineConfig = do
  triple <- ownedMessage $ primIO Raw.getDefaultTargetTriple
  cpu <- ownedMessage $ primIO Raw.getHostCPUName
  features <- ownedMessage $ primIO Raw.getHostCPUFeatures
  pure $ MkTargetMachineConfig triple cpu features Default PIC ModelDefault

export
lookupTarget : String -> IO (Either LLVMError Target)
lookupTarget triple = do
  ((status, messagePointer), targetPointer) <- withOutPtr $ \outTarget =>
    withOutPtr $ \outMessage =>
      primIO $ Raw.getTargetFromTriple triple outTarget outMessage
  if status /= 0
    then Left . MkLLVMError "lookupTarget" <$> takeMessage messagePointer ("unknown target: " ++ triple)
    else pure $ Right $ MkTarget (prim__castPtr targetPointer)

export
withTargetMachine : TargetMachineConfig -> (TargetMachine -> IO a) -> IO (Either LLVMError a)
withTargetMachine config action = do
  initialized <- initializeNative
  case initialized of
    Left error => pure $ Left error
    Right () => do
      found <- lookupTarget config.triple
      case found of
        Left error => pure $ Left error
        Right (MkTarget target) => do
          machine <- primIO $ Raw.createTargetMachine target config.triple config.cpu config.features
                    (toRawOpt config.optimization) (toRawReloc config.relocation)
                    (toRawCodeModel config.codeModel)
          null <- isNull (prim__forgetPtr machine)
          if null
            then pure $ Left $ MkLLVMError "createTargetMachine" "LLVM returned a null target machine"
            else do
              result <- action (MkTargetMachine machine)
              primIO $ Raw.disposeTargetMachine machine
              pure $ Right result

export
withTargetData : TargetMachine -> (TargetData -> IO a) -> IO a
withTargetData (MkTargetMachine machine) action = do
  targetData <- primIO $ Raw.createTargetDataLayout machine
  result <- action (MkTargetData targetData)
  primIO $ Raw.disposeTargetData targetData
  pure result

export
targetDataLayout : TargetMachine -> IO String
targetDataLayout machine = withTargetData machine $ \(MkTargetData targetData) =>
  ownedMessage $ primIO $ Raw.copyStringRepOfTargetData targetData

export
configureModuleForTarget : Module -> TargetMachineConfig -> TargetMachine -> IO ()
configureModuleForTarget mod config machine = do
  setModuleTarget mod config.triple
  layout <- targetDataLayout machine
  setModuleDataLayout mod layout

export
emitToFile : TargetMachine -> Module -> OutputKind -> String -> IO (Either LLVMError ())
emitToFile (MkTargetMachine machine) mod kind path = do
  (status, messagePointer) <- withOutPtr $ \outMessage =>
    primIO $ Raw.targetMachineEmitToFile machine (toRawModule mod) path (toRawOutput kind) outMessage
  if status == 0
    then pure $ Right ()
    else Left . MkLLVMError "emitToFile" <$> takeMessage messagePointer ("could not emit " ++ path)
