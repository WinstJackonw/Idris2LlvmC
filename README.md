# llvm-c for Idris 2

An Idris 2 binding to the backend-oriented LLVM 22.1 C API. It contains a
close-to-C `LLVM.Raw.*` layer and an ownership-aware `LLVM.*` façade for IR
construction, verification, parsing, bitcode, linking, passes, native target
emission, and debug information.

The package was developed against Idris 2 0.8.0 and LLVM 22.1.x. Raw bindings
load LLVM's monolithic shared `libLLVM` directly. A small C shim is retained
only for Idris pointer/string helpers and LLVM APIs implemented as inline C
header functions; it does not embed LLVM's static component libraries.

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

For Nix consumers, the flake exports the installed Idris library, its minimal
native shim, and an exact link to the pinned shared libLLVM as both
`packages.<system>.default` and `packages.<system>.idris2-llvm-c`. A downstream
flake can pass `idris2-llvm-c.packages.${system}.default` in its
`idrisLibraries` list.

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

`examples/SafeAdd.idr` is a runnable version of that construction built with the
safe façade; it also verifies and prints its module. `examples/RawAdd.idr` builds
the same `add` function directly against the close-to-C `LLVM.Raw` layer, where
every resource (context, module, builder) and every owned string must be
disposed by hand. The safe façade uses `LLVMType` because `Type` is reserved by
Idris.

## Test

```sh
LLVM_CONFIG=path/to/llvm/bin/llvm-config ./tests/run.sh
```

The suite compiles and runs Idris code covering construction, DIBuilder,
verification, textual IR and bitcode round-trips, module linking, the new pass
manager, and native object emission. It also runs the C shim smoke test and
checks every direct libLLVM and shim FFI symbol. Generated outputs go under
`tests/build`.

See [support/BINDINGS.md](support/BINDINGS.md) for coverage, ownership rules,
ABI policy, and deliberately out-of-scope LLVM-C subsystems.
