#!/usr/bin/env bash
set -euo pipefail

support_dir="$(cd "$(dirname "$0")" && pwd)"
project_dir="$(cd "${support_dir}/.." && pwd)"

case "$(uname -s)" in
  Darwin) shim_library="${project_dir}/lib/libidris2_llvm.dylib" ;;
  *) shim_library="${project_dir}/lib/libidris2_llvm.so" ;;
esac
llvm_library="${project_dir}/lib/libLLVM"

if [[ ! -f "${shim_library}" || ! -e "${llvm_library}" ]]; then
  echo "llvm-c: native shim is missing; run support/build.sh first" >&2
  exit 2
fi

temporary_dir="$(mktemp -d)"
trap 'rm -rf "${temporary_dir}"' EXIT

rg -o '\(llvm "[^"]+"\)' "${project_dir}/src/LLVM" -g '*.idr' \
  | sed 's/.*(llvm "//;s/").*//' \
  | sort -u > "${temporary_dir}/llvm-declared"

rg -o '\(shim "[^"]+"\)' "${project_dir}/src/LLVM" -g '*.idr' \
  | sed 's/.*(shim "//;s/").*//' \
  | sed 's/^/idris2_llvm_/' \
  | sort -u > "${temporary_dir}/shim-declared"

if [[ "$(uname -s)" == Darwin ]]; then
  nm -gU "${llvm_library}" \
    | sed -n 's/.* _\(LLVM[A-Za-z0-9_]*\)$/\1/p' \
    | sort -u > "${temporary_dir}/llvm-exported"
  nm -gU "${shim_library}" \
    | sed -n 's/.* _\(idris2_llvm_[A-Za-z0-9_]*\)$/\1/p' \
    | sort -u > "${temporary_dir}/shim-exported"
else
  nm -D --defined-only "${llvm_library}" \
    | sed -n 's/.* \(LLVM[A-Za-z0-9_]*\)\(@[^ ]*\)\?$/\1/p' \
    | sort -u > "${temporary_dir}/llvm-exported"
  nm -D --defined-only "${shim_library}" \
    | sed -n 's/.* \(idris2_llvm_[A-Za-z0-9_]*\)\(@[^ ]*\)\?$/\1/p' \
    | sort -u > "${temporary_dir}/shim-exported"
fi

comm -23 "${temporary_dir}/llvm-declared" "${temporary_dir}/llvm-exported" \
  > "${temporary_dir}/llvm-missing"
comm -23 "${temporary_dir}/shim-declared" "${temporary_dir}/shim-exported" \
  > "${temporary_dir}/shim-missing"

if [[ -s "${temporary_dir}/llvm-missing" || -s "${temporary_dir}/shim-missing" ]]; then
  echo "llvm-c: Idris declarations without a native export:" >&2
  sed 's/^/  libLLVM: /' "${temporary_dir}/llvm-missing" >&2
  sed 's/^/  shim: /' "${temporary_dir}/shim-missing" >&2
  exit 1
fi

llvm_count="$(wc -l < "${temporary_dir}/llvm-declared" | tr -d ' ')"
shim_count="$(wc -l < "${temporary_dir}/shim-declared" | tr -d ' ')"
echo "llvm-c: checked ${llvm_count} libLLVM symbols and ${shim_count} shim symbols"
