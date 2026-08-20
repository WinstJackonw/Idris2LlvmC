module LLVM.Internal.Array

import LLVM.Raw.Types

%default total

shim : String -> String
shim name = "C:idris2_llvm_" ++ name ++ ",libidris2_llvm"

%foreign (shim "ptr_array_new")
prim__ptrArrayNew : Bits32 -> PrimIO AnyPtr

%foreign (shim "ptr_array_set")
prim__ptrArraySet : AnyPtr -> Bits32 -> AnyPtr -> PrimIO ()

%foreign (shim "ptr_array_get")
prim__ptrArrayGet : AnyPtr -> Bits32 -> PrimIO AnyPtr

%foreign (shim "ptr_array_free")
prim__ptrArrayFree : AnyPtr -> PrimIO ()

%foreign (shim "i64_array_new")
prim__i64ArrayNew : Bits32 -> PrimIO AnyPtr

%foreign (shim "i64_array_set")
prim__i64ArraySet : AnyPtr -> Bits32 -> Int64 -> PrimIO ()

%foreign (shim "i64_array_free")
prim__i64ArrayFree : AnyPtr -> PrimIO ()

%foreign (shim "u8_array_new")
prim__u8ArrayNew : Bits32 -> PrimIO AnyPtr

%foreign (shim "u8_array_set")
prim__u8ArraySet : AnyPtr -> Bits32 -> Bits8 -> PrimIO ()

%foreign (shim "u8_array_free")
prim__u8ArrayFree : AnyPtr -> PrimIO ()

%foreign (shim "u64_array_new")
prim__u64ArrayNew : Bits32 -> PrimIO AnyPtr

%foreign (shim "u64_array_get")
prim__u64ArrayGet : AnyPtr -> Bits32 -> PrimIO Bits64

%foreign (shim "u64_array_free")
prim__u64ArrayFree : AnyPtr -> PrimIO ()

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

fillU8s : AnyPtr -> Bits32 -> List Bits8 -> IO ()
fillU8s array index [] = pure ()
fillU8s array index (value :: rest) = do
  primIO $ prim__u8ArraySet array index value
  fillU8s array (index + 1) rest

export
withU8Array : List Bits8 -> (AnyPtr -> Bits64 -> IO a) -> IO a
withU8Array values action = do
  let count : Bits32 = cast (length values)
  array <- primIO $ prim__u8ArrayNew count
  fillU8s array 0 values
  result <- action array (cast count)
  primIO $ prim__u8ArrayFree array
  pure result

export
withOutU64 : (AnyPtr -> IO a) -> IO (a, Bits64)
withOutU64 action = do
  array <- primIO $ prim__u64ArrayNew 1
  result <- action array
  value <- primIO $ prim__u64ArrayGet array 0
  primIO $ prim__u64ArrayFree array
  pure (result, value)
