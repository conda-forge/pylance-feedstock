#!/usr/bin/env bash
set -ex
export OPENSSL_DIR=$PREFIX

# Limit cargo parallelism to avoid OOM during cross-compilation on CI
if [ "${target_platform}" != "${build_platform}" ]; then
    export CARGO_BUILD_JOBS=2
    # Keep the upstream setting on macOS arm64 to avoid linker range failures.
    if [ "${target_platform}" = "osx-arm64" ]; then
        export CARGO_PROFILE_RELEASE_CODEGEN_UNITS=1
    else
        export CARGO_PROFILE_RELEASE_CODEGEN_UNITS=16
    fi
fi

# Bundle all downstream library licenses
cd python
cargo-bundle-licenses \
  --format yaml \
  --output ${SRC_DIR}/THIRDPARTY.yml

# Install package
${PYTHON} -m pip install . -vv