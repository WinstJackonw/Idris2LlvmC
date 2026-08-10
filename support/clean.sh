#!/usr/bin/env bash
set -euo pipefail

support_dir="$(cd "$(dirname "$0")" && pwd)"
project_dir="$(cd "${support_dir}/.." && pwd)"
rm -rf "${support_dir}/build" "${project_dir}/lib" "${project_dir}/build" "${project_dir}/tests/build"

