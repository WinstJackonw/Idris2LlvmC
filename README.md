# llvm-c for Idris 2

An Idris 2 binding to the backend-oriented LLVM 22.1 C API. It contains a
close-to-C `LLVM.Raw.*` layer and an ownership-aware `LLVM.*` façade for IR
construction, verification, parsing, bitcode, linking, passes, native target
emission, and debug information.

The package was developed against Idris 2 0.8.0 and LLVM 22.1.x. LLVM may be a
static build: CMake links it into `libidris2_llvm`, the shared shim loaded by
Idris.

## Build

Enter the pinned development environment to get LLVM 22.1, CMake, Idris 2,
and `pack`:

```sh
nix develop
pack build llvm-c.ipkg
```

The shell sets `LLVM_CONFIG` and `LLVM_DIR` to the Nix-provided LLVM. To use
tools installed outside Nix instead, point the build at the matching
`llvm-config`:

```sh
LLVM_CONFIG=path/to/llvm/bin/llvm-config pack build llvm-c.ipkg
```

Alternatively, set `LLVM_DIR` to LLVM's CMake package directory. Nothing in the
package hard-codes the local source or build paths.

The package is self-contained apart from Idris `base`; no network-fetched Idris
FFI helper package is required.

## Use

Import `LLVM` for the safe API or `LLVM.Raw` for the direct C-shaped API. The
smallest complete construction looks like this:

```idris
withContext $ \context =>
  withModule context "example" $ \mod => do
    integerType <- i32 context
    signature <- functionType integerType [integerType] False
    function <- addFunction mod "identity" signature
    argument <- parameter function 0
    case argument of
      Nothing => pure ()
      Just value => do
        entry <- appendBasicBlock context function "entry"
        withBuilder context $ \builder => do
          positionAtEnd builder entry
          _ <- buildRet builder value
          pure ()
```

`examples/Add.idr` is a runnable version that also verifies and prints its
module. The safe façade uses `LLVMType` because `Type` is reserved by Idris.

## Test

```sh
LLVM_CONFIG=path/to/llvm/bin/llvm-config ./tests/run.sh
```

The suite compiles and runs Idris code covering construction, DIBuilder,
verification, textual IR and bitcode round-trips, module linking, the new pass
manager, and native object emission. It also runs the C++ shim smoke test and
checks all declared FFI symbols. Generated outputs go under `tests/build`.

See [support/BINDINGS.md](support/BINDINGS.md) for coverage, ownership rules,
ABI policy, and deliberately out-of-scope LLVM-C subsystems.
