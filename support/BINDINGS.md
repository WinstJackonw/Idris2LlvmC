# Binding coverage and ownership

This package targets the stable LLVM 22.1 C API needed by an Idris compiler
backend. `support/bindings.manifest` is the module-to-header manifest, while
`support/check-bindings.sh` verifies that every Idris `%foreign` declaration
has a symbol in either shared libLLVM or the minimal shim.

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

The raw layer calls the stable LLVM C ABI in monolithic shared libLLVM directly.
The small shim (ABI version 2) contains only Idris pointer/string/array helpers,
version convenience calls, error-success testing, and the target initialization
routines that LLVM exposes as inline C header functions. It checks for a 64-bit
process and links dynamically to libLLVM; it never links LLVM component archives.
The package pins LLVM major/minor to 22.1 and supports patch releases in that
series.

APIs outside the current backend-oriented scope include ORC/JIT, LTO,
disassembly, object-file inspection, remarks, and LLVM fatal-error handlers.
Those can be added as separate raw modules without changing the existing safe
API or shim ABI.
