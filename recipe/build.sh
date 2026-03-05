#!/usr/bin/env bash
set -ex
export OPENSSL_DIR=$PREFIX

# Limit cargo parallelism to avoid OOM during cross-compilation on CI
if [ "${target_platform}" != "${build_platform}" ]; then
    export CARGO_BUILD_JOBS=2
    export CARGO_PROFILE_RELEASE_CODEGEN_UNITS=16
fi

# Bundle all downstream library licenses
cd python
cargo-bundle-licenses \
  --format yaml \
  --output ${SRC_DIR}/THIRDPARTY.yml

# Install package
${PYTHON} -m pip install . -vv