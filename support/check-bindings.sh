#!/usr/bin/env bash
set -euo pipefail

support_dir="$(cd "$(dirname "$0")" && pwd)"
project_dir="$(cd "${support_dir}/.." && pwd)"

case "$(uname -s)" in
  Darwin) library="${project_dir}/lib/libidris2_llvm.dylib" ;;
  *) library="${project_dir}/lib/libidris2_llvm.so" ;;
esac

if [[ ! -f "${library}" ]]; then
  echo "llvm-c: native shim is missing; run support/build.sh first" >&2
  exit 2
fi

temporary_dir="$(mktemp -d)"
trap 'rm -rf "${temporary_dir}"' EXIT

rg -o '\(llvm "[^"]+"\)' "${project_dir}/src/LLVM" -g '*.idr' \
  | sed 's/.*(llvm "//;s/").*//' \
  | sort -u > "${temporary_dir}/declared"

if [[ "$(uname -s)" == Darwin ]]; then
  nm -gU "${library}" \
    | sed -n 's/.* _idris2_llvm_\([A-Za-z0-9_]*\)$/\1/p' \
    | sort -u > "${temporary_dir}/exported"
else
  nm -D --defined-only "${library}" \
    | sed -n 's/.* idris2_llvm_\([A-Za-z0-9_]*\)$/\1/p' \
    | sort -u > "${temporary_dir}/exported"
fi

comm -23 "${temporary_dir}/declared" "${temporary_dir}/exported" \
  > "${temporary_dir}/missing"

if [[ -s "${temporary_dir}/missing" ]]; then
  echo "llvm-c: Idris declarations without a native export:" >&2
  sed 's/^/  /' "${temporary_dir}/missing" >&2
  exit 1
fi

declaration_count="$(wc -l < "${temporary_dir}/declared" | tr -d ' ')"
echo "llvm-c: checked ${declaration_count} FFI symbols"
