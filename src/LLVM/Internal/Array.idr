module LLVM.Internal.Array

import LLVM.Raw.Types

%default total

llvm : String -> String
llvm name = "C:idris2_llvm_" ++ name ++ ",libidris2_llvm"

%foreign (llvm "ptr_array_new")
prim__ptrArrayNew : Bits32 -> PrimIO AnyPtr

%foreign (llvm "ptr_array_set")
prim__ptrArraySet : AnyPtr -> Bits32 -> AnyPtr -> PrimIO ()

%foreign (llvm "ptr_array_get")
prim__ptrArrayGet : AnyPtr -> Bits32 -> PrimIO AnyPtr

%foreign (llvm "ptr_array_free")
prim__ptrArrayFree : AnyPtr -> PrimIO ()

%foreign (llvm "i64_array_new")
prim__i64ArrayNew : Bits32 -> PrimIO AnyPtr

%foreign (llvm "i64_array_set")
prim__i64ArraySet : AnyPtr -> Bits32 -> Int64 -> PrimIO ()

%foreign (llvm "i64_array_free")
prim__i64ArrayFree : AnyPtr -> PrimIO ()

fillPtrs : AnyPtr -> Bits32 -> List AnyPtr -> IO ()
fillPtrs array index [] = pure ()
fillPtrs array index (value :: rest) = do
  primIO $ prim__ptrArraySet array index value
  fillPtrs array (index + 1) rest

export
withAnyPtrArray : List AnyPtr -> (AnyPtr -> Bits32 -> IO a) -> IO a
withAnyPtrArray values action = do
  let count : Bits32 = cast (length values)
  array <- primIO $ prim__ptrArrayNew count
  fillPtrs array 0 values
  result <- action array count
  primIO $ prim__ptrArrayFree array
  pure result

export
withRefArray : List (Ptr tag) -> (AnyPtr -> Bits32 -> IO a) -> IO a
withRefArray values = withAnyPtrArray (map prim__forgetPtr values)

export
withOutPtr : (AnyPtr -> IO a) -> IO (a, AnyPtr)
withOutPtr action = do
  array <- primIO $ prim__ptrArrayNew 1
  result <- action array
  value <- primIO $ prim__ptrArrayGet array 0
  primIO $ prim__ptrArrayFree array
  pure (result, value)

fillI64s : AnyPtr -> Bits32 -> List Int64 -> IO ()
fillI64s array index [] = pure ()
fillI64s array index (value :: rest) = do
  primIO $ prim__i64ArraySet array index value
  fillI64s array (index + 1) rest

export
withI64Array : List Int64 -> (AnyPtr -> Bits64 -> IO a) -> IO a
withI64Array values action = do
  let count32 : Bits32 = cast (length values)
  array <- primIO $ prim__i64ArrayNew count32
  fillI64s array 0 values
  result <- action array (cast count32)
  primIO $ prim__i64ArrayFree array
  pure result

