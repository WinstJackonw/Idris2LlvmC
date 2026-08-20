#!/usr/bin/env bash
set -euo pipefail

tests_dir="$(cd "$(dirname "$0")" && pwd)"
project_dir="$(cd "${tests_dir}/.." && pwd)"
output_dir="${tests_dir}/build"

if [[ -z "${LLVM_CONFIG:-}" ]]; then
  echo "llvm-c tests: set LLVM_CONFIG to LLVM 22.1 llvm-config" >&2
  exit 2
fi

"${project_dir}/support/build.sh"
ctest --test-dir "${project_dir}/support/build" --output-on-failure
"${project_dir}/support/check-bindings.sh"

if [[ -n "${IDRIS2:-}" ]]; then
  idris2_bin="${IDRIS2}"
  package_path="${IDRIS2_PACKAGE_PATH:-}"
  library_path="${IDRIS2_LIBS:-}"
elif command -v pack >/dev/null 2>&1; then
  idris2_bin="$(pack app-path idris2)"
  package_path="$(pack package-path)"
  library_path="$(pack libs-path)"
else
  idris2_bin="$(command -v idris2)"
  package_path="${IDRIS2_PACKAGE_PATH:-}"
  library_path="${IDRIS2_LIBS:-}"
fi

mkdir -p "${output_dir}"
cd "${project_dir}"

IDRIS2_PACKAGE_PATH="${package_path}" \
IDRIS2_LIBS="${project_dir}/lib${library_path:+:${library_path}}" \
  "${idris2_bin}" --source-dir src --build-dir tests/build/ttc \
  --check src/LLVM.idr

IDRIS2_PACKAGE_PATH="${package_path}" \
IDRIS2_LIBS="${project_dir}/lib${library_path:+:${library_path}}" \
  "${idris2_bin}" --source-dir tests --output-dir tests/build \
  --build-dir tests/build/ttc \
  -o llvm-c-tests tests/Main.idr

examples=(SafeAdd RawAdd Cond Globals Struct ParseIR Bitcode Link Optimize Emit Debug RawCall RawBitcode JIT)

for example in "${examples[@]}"; do
  IDRIS2_PACKAGE_PATH="${package_path}" \
  IDRIS2_LIBS="${project_dir}/lib${library_path:+:${library_path}}" \
    "${idris2_bin}" --source-dir examples --output-dir tests/build \
    --build-dir tests/build/ttc \
    -o "example-${example}" "examples/${example}.idr"
done

# Idris2 >= 0.8.0 no longer copies the Chez runtime support library
# (libidris2_support) next to the compiled binary (idris-lang/Idris2#3189) and
# instead expects it on the loader search path. That works on Linux via the
# launcher's LD_LIBRARY_PATH export, but on macOS the generated /bin/sh
# launchers strip incoming DYLD_*/LD_* env vars and dyld ignores
# LD_LIBRARY_PATH, so the only reliable place is inside each app dir.
find_support_lib_dir() {
  "$1" --paths \
  | sed -n 's/^+ CG Library Directories :: \[\(.*\)\]$/\1/p' \
  | tr ',' '\n' \
  | tr -d ' "' \
  | while read -r dir; do
      if [[ -f "${dir}/libidris2_support.dylib" ]] || [[ -f "${dir}/libidris2_support.so" ]]; then
        echo "${dir}"
        break
      fi
    done
  return 0
}

support_lib_dir="$(find_support_lib_dir "${idris2_bin}")"
if [[ -z "${support_lib_dir}" ]] && command -v idris2 >/dev/null 2>&1; then
  support_lib_dir="$(find_support_lib_dir "$(command -v idris2)")"
fi
if [[ -z "${support_lib_dir}" ]]; then
  echo "llvm-c tests: could not locate libidris2_support in idris2 CG library directories" >&2
  exit 2
fi

for app_dir in "${output_dir}"/*_app; do
  for lib in libidris2_support.dylib libidris2_support.so; do
    if [[ -f "${support_lib_dir}/${lib}" ]]; then
      install -m 0755 "${support_lib_dir}/${lib}" "${app_dir}/"
    fi
  done
done

run_with_llvm() {
  DYLD_LIBRARY_PATH="${project_dir}/lib${DYLD_LIBRARY_PATH:+:${DYLD_LIBRARY_PATH}}" \
  LD_LIBRARY_PATH="${project_dir}/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}" \
    "$@"
}

example_checks=(
  "SafeAdd|define i32 @add"
  "RawAdd|define i32 @add"
  "Cond|phi i32"
  "Globals|call i32 @tick"
  "Struct|%point = type"
  "ParseIR|@parse_add"
  "Bitcode|define i32 @add"
  "Link|@multiply"
  "Optimize|ret i32 %x"
  "Emit|ok: target data layout"
  "Debug|!llvm.dbg.cu"
  "RawCall|call i32 @tick"
  "RawBitcode|define i32 @add"
  "JIT|jit result: 42"
)

for check in "${example_checks[@]}"; do
  name="${check%%|*}"
  marker="${check#*|}"
  output="$(run_with_llvm "${output_dir}/example-${name}")"
  if ! grep -qF "${marker}" <<< "${output}"; then
    echo "llvm-c: ${name} example output is missing '${marker}'" >&2
    exit 1
  fi
done

run_with_llvm "${output_dir}/llvm-c-tests"
