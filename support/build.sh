#!/usr/bin/env bash
set -euo pipefail

support_dir="$(cd "$(dirname "$0")" && pwd)"
project_dir="$(cd "${support_dir}/.." && pwd)"
build_dir="${support_dir}/build"

if [[ -n "${LLVM_DIR:-}" ]]; then
  llvm_cmake_dir="${LLVM_DIR}"
else
  llvm_config_bin="${LLVM_CONFIG:-}"
  if [[ -z "${llvm_config_bin}" ]]; then
    llvm_config_bin="$(command -v llvm-config || true)"
  fi
  if [[ -z "${llvm_config_bin}" || ! -x "${llvm_config_bin}" ]]; then
    echo "llvm-c: set LLVM_CONFIG to an executable LLVM 22.1 llvm-config" >&2
    exit 2
  fi
  llvm_cmake_dir="$(${llvm_config_bin} --cmakedir)"
fi

cmake -S "${support_dir}" -B "${build_dir}" \
  -DLLVM_DIR="${llvm_cmake_dir}" \
  -DCMAKE_BUILD_TYPE="${CMAKE_BUILD_TYPE:-Release}" \
  -DBUILD_TESTING=ON
cmake --build "${build_dir}" --parallel
cmake --install "${build_dir}" --prefix "${project_dir}"

# Chez looks up the library by the exact extensionless name used in %foreign.
if [[ -f "${project_dir}/lib/libidris2_llvm.dylib" ]]; then
  cp "${project_dir}/lib/libidris2_llvm.dylib" "${project_dir}/lib/libidris2_llvm"
elif [[ -f "${project_dir}/lib/libidris2_llvm.so" ]]; then
  cp "${project_dir}/lib/libidris2_llvm.so" "${project_dir}/lib/libidris2_llvm"
fi

llvm_dylib_path="$(<"${build_dir}/llvm-dylib-path")"
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

lto_dylib_path="$(<"${build_dir}/lto-dylib-path")"
lto_link="${project_dir}/lib/libLTO"
case "$(uname -s)" in
  Darwin) lto_platform_link="${lto_link}.dylib" ;;
  *) lto_platform_link="${lto_link}.so" ;;
esac
for link in "${lto_link}" "${lto_platform_link}"; do
  if [[ -L "${link}" ]]; then
    ln -sfn "${lto_dylib_path}" "${link}"
  elif [[ ! -e "${link}" ]]; then
    ln -s "${lto_dylib_path}" "${link}"
  else
    echo "llvm-c: refusing to replace non-symlink ${link}" >&2
    exit 2
  fi
done
