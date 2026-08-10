#!/usr/bin/env bash
set -euo pipefail

support_dir="$(cd "$(dirname "$0")" && pwd)"
project_dir="$(cd "${support_dir}/.." && pwd)"

if [[ ! -d "${support_dir}/build" ]]; then
  "${support_dir}/build.sh"
fi
cmake --install "${support_dir}/build" --prefix "${project_dir}"

if [[ -f "${project_dir}/lib/libidris2_llvm.dylib" ]]; then
  cp "${project_dir}/lib/libidris2_llvm.dylib" "${project_dir}/lib/libidris2_llvm"
elif [[ -f "${project_dir}/lib/libidris2_llvm.so" ]]; then
  cp "${project_dir}/lib/libidris2_llvm.so" "${project_dir}/lib/libidris2_llvm"
fi

