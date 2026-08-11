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

llvm_dylib_path="$(<"${support_dir}/build/llvm-dylib-path")"
llvm_link="${project_dir}/lib/libLLVM"
case "$(uname -s)" in
  Darwin) llvm_platform_link="${llvm_link}.dylib" ;;
  *) llvm_platform_link="${llvm_link}.so" ;;
esac
for link in "${llvm_link}" "${llvm_platform_link}"; do
  if [[ -L "${link}" ]]; then
    ln -sfn "${llvm_dylib_path}" "${link}"
  elif [[ ! -e "${link}" ]]; then
    ln -s "${llvm_dylib_path}" "${link}"
  else
    echo "llvm-c: refusing to replace non-symlink ${link}" >&2
    exit 2
  fi
done
