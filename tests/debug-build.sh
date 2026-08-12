#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "$0")/.." && pwd)"

if command -v pack >/dev/null 2>&1; then
  idris2_bin="$(pack app-path idris2)"
  package_path="$(pack package-path)"
  library_path="$(pack libs-path)"
else
  idris2_bin="$(command -v idris2)"
  package_path="${IDRIS2_PACKAGE_PATH:-}"
  library_path="${IDRIS2_LIBS:-}"
fi

cd "${project_dir}"
mkdir -p tests/build/ttc

export IDRIS2_PACKAGE_PATH="${package_path}"
export IDRIS2_LIBS="${project_dir}/lib${library_path:+:${library_path}}"

echo "=== step 1: check src/LLVM.idr ==="
"${idris2_bin}" --source-dir src --build-dir tests/build/ttc --check src/LLVM.idr
echo "step1 exit: $?"

echo "=== step 2: check src/LLVM/Raw.idr ==="
"${idris2_bin}" --source-dir src --build-dir tests/build/ttc --check src/LLVM/Raw.idr
echo "step2 exit: $?"

echo "=== step 3: build tests/Main.idr ==="
"${idris2_bin}" --source-dir tests --output-dir tests/build --build-dir tests/build/ttc -o llvm-c-tests tests/Main.idr
echo "step3 exit: $?"

echo "=== step 4: build examples/SafeAdd.idr ==="
"${idris2_bin}" --source-dir examples --output-dir tests/build --build-dir tests/build/ttc -o example-SafeAdd examples/SafeAdd.idr
echo "step4 exit: $?"

echo "=== step 5: build examples/RawAdd.idr ==="
"${idris2_bin}" --source-dir examples --output-dir tests/build --build-dir tests/build/ttc -o example-RawAdd examples/RawAdd.idr
echo "step5 exit: $?"
