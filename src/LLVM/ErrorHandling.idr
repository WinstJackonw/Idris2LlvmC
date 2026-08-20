module LLVM.ErrorHandling

import LLVM.Raw.ErrorHandling as Raw

%default total

export
withFatalErrorHandler : (String -> ()) -> IO a -> IO a
withFatalErrorHandler handler action = do
  primIO $ Raw.installFatalErrorHandler handler
  result <- action
  primIO Raw.resetFatalErrorHandler
  pure result

export
resetFatalErrorHandler : IO ()
resetFatalErrorHandler = primIO Raw.resetFatalErrorHandler

export
enablePrettyStackTrace : IO ()
enablePrettyStackTrace = primIO Raw.enablePrettyStackTrace
