# Binding coverage and ownership

This package targets the stable LLVM 22.1 C API needed by an Idris compiler
backend. `support/bindings.manifest` is the module-to-header manifest, while
`support/check-bindings.sh` verifies that every Idris `%foreign` declaration
has a symbol in either shared libLLVM or the minimal shim.

The raw layer covers contexts, modules, types, constants, values, functions,
globals, basic blocks, IR builders, metadata, memory buffers, verification,
text and bitcode parsing, bitcode writing, module linking, the new pass manager,
target discovery and emission, target data, DIBuilder debug metadata, LLJIT,
regular and ThinLTO, disassembly, object-file inspection, optimization remarks,
and LLVM fatal-error handler installation.

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
| LLJIT | `LLVMOrcCreateLLJIT` | `LLVMOrcDisposeLLJIT`; use safe `withLLJIT` |
| Thread-safe context/module | ORC creation APIs | context is shared; module is consumed by LLJIT on add |
| LTO module/code generator | `lto_*_create` | matching dispose; ThinLTO input buffers live through `process` |
| Disassembler | `LLVMCreateDisasmCPUFeatures` | `LLVMDisasmDispose`; use safe `withDisassembler` |
| Binary and iterators | `LLVMCreateBinary` / copy iterator | dispose binary and every copied iterator |
| Remark parser/entry | parser/get-next | dispose every entry and parser; Safe copies borrowed strings |

The safe layer retains the original explicit brackets for compatibility and
adds `LLVMResult`, result-specialized brackets, `withModuleBuilder`, and the
`ModuleBuilder` reader/result DSL. Cleanup is guaranteed on ordinary IO/Either
returns. Idris `IO` has no exception-safe `finally` primitive in `base`, so
callers that introduce a non-local exception mechanism must keep cleanup at the
same abstraction boundary.

## ABI policy

The raw layer calls the stable LLVM C ABI in monolithic shared libLLVM directly.
The legacy `lto.h` API is the one exception: LLVM ships those symbols in the
separate shared libLTO, which is included in the package closure. The small shim
(ABI version 3) contains Idris pointer/string/array helpers, fixed `uint64_t`
JIT-call bridges, version/error helpers, a callback-free disassembler
constructor, and target initialization routines that LLVM exposes as inline C
header functions. It checks for a 64-bit process, links dynamically to libLLVM,
and never links LLVM component archives.
The package pins LLVM major/minor to 22.1 and supports patch releases in that
series.

The LLJIT workflow is covered; advanced ORC materialization units, asynchronous
lookup callbacks, and custom transform/object layers remain out of scope. LLVM
22.1 has no `llvm-c/Coroutines.h`, so `LLVM.Coroutines` uses intrinsic
lookup/declaration instead of a C++ shim. Fatal handlers observe a fatal error
but cannot convert LLVM's subsequent process exit into `Either`.
