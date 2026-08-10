# Binding coverage and ownership

This package targets the stable LLVM 22.1 C API needed by an Idris compiler
backend. `support/bindings.manifest` is the module-to-header manifest, while
`support/check-bindings.sh` verifies that every Idris `%foreign` declaration
has a symbol in the built shim.

The raw layer covers contexts, modules, types, constants, values, functions,
globals, basic blocks, IR builders, metadata, memory buffers, verification,
text and bitcode parsing, bitcode writing, module linking, the new pass manager,
target discovery and emission, target data, and DIBuilder debug metadata.

## Ownership

| Resource | Acquired by | Released by / rule |
|---|---|---|
| Context | `contextCreate` | `contextDispose`; use safe `withContext` |
| Module | module creation or parser | `disposeModule`; link consumes its source, safe `linkInto` clones it |
| Builder | `createBuilderInContext` | `disposeBuilder`; use safe `withBuilder` |
| DIBuilder | `createDIBuilder` | finalize, then dispose; safe `withDIBuilder` does both |
| Memory buffer | file/range and bitcode APIs | `disposeMemoryBuffer`; parsers consume or borrow as documented by LLVM |
| Target machine | `createTargetMachine` | `disposeTargetMachine`; use safe `withTargetMachine` |
| Target data | `createTargetDataLayout` | `disposeTargetData`; use safe `withTargetData` |
| LLVM message | APIs returning an owned `char *` | `disposeMessage` |
| LLVM error message | `getErrorMessage` | `disposeErrorMessage` |
| Type, value, block, metadata, target | borrowed/arena-owned | never dispose independently |

The safe layer is deliberately explicit-bracket based. Idris `IO` has no
exception-safe `finally` primitive in `base`, so callers that introduce their
own non-local exception mechanism should keep cleanup at the same abstraction
boundary.

## ABI policy

The shim is a shared C ABI boundary over the LLVM static libraries. It checks
for a 64-bit process, pins LLVM major/minor to 22.1, and uses fixed-width Idris
FFI values so C `size_t` and enum representation do not leak into Idris code.
The package supports patch releases in the 22.1 series.

APIs outside the current backend-oriented scope include ORC/JIT, LTO,
disassembly, object-file inspection, remarks, and LLVM fatal-error handlers.
Those can be added as separate raw modules without changing the existing safe
API or shim ABI.
