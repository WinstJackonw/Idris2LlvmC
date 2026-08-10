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

IDRIS2_PATH="${project_dir}/src${IDRIS2_PATH:+:${IDRIS2_PATH}}" \
IDRIS2_PACKAGE_PATH="${package_path}" \
IDRIS2_LIBS="${project_dir}/lib${library_path:+:${library_path}}" \
  "${idris2_bin}" --source-dir . --output-dir tests/build \
  -o llvm-c-tests tests/Main.idr

DYLD_LIBRARY_PATH="${project_dir}/lib${DYLD_LIBRARY_PATH:+:${DYLD_LIBRARY_PATH}}" \
LD_LIBRARY_PATH="${project_dir}/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}" \
  "${output_dir}/llvm-c-tests"
