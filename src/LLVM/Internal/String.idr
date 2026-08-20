module LLVM.Internal.String

%default total

shim : String -> String
shim name = "C:idris2_llvm_" ++ name ++ ",libidris2_llvm"

%foreign (shim "string_from_ptr")
prim__stringFromPtr : Ptr String -> PrimIO String

%foreign (shim "is_null")
prim__isNull : AnyPtr -> PrimIO Int32

%foreign (shim "string_byte_length")
prim__stringByteLength : String -> PrimIO Bits64

%foreign (shim "string_copy_len")
prim__stringCopyLen : Ptr String -> Bits64 -> PrimIO (Ptr String)

%foreign (shim "string_copy_free")
prim__stringCopyFree : Ptr String -> PrimIO ()

export
peekString : Ptr String -> IO String
peekString ptr = primIO $ prim__stringFromPtr ptr

export
isNull : AnyPtr -> IO Bool
isNull ptr = do
  value <- primIO $ prim__isNull ptr
  pure (value /= 0)

export
byteLength : String -> IO Bits64
byteLength value = primIO $ prim__stringByteLength value

export
peekStringLength : Ptr String -> Bits64 -> IO String
peekStringLength pointer length = do
  copy <- primIO $ prim__stringCopyLen pointer length
  value <- peekString copy
  primIO $ prim__stringCopyFree copy
  pure value
