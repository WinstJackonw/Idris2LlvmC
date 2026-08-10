module LLVM.Internal.String

%default total

llvm : String -> String
llvm name = "C:idris2_llvm_" ++ name ++ ",libidris2_llvm"

%foreign (llvm "string_from_ptr")
prim__stringFromPtr : Ptr String -> PrimIO String

%foreign (llvm "is_null")
prim__isNull : AnyPtr -> PrimIO Int32

%foreign (llvm "string_byte_length")
prim__stringByteLength : String -> PrimIO Bits64

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
