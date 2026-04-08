set OPENSSL_DIR=%LIBRARY_PREFIX%
REM Create temp folder
mkdir tmpbuild_%PY_VER%
set TEMP=%CD%\tmpbuild_%PY_VER%

REM Fix protos symlinks: tarball symlinks (rust/*/protos -> ../../protos) are
REM not resolved on Windows, causing protoc to fail with "File not found".
REM Replace them with real copies of the root protos/ directory.
REM See: https://dev.azure.com/conda-forge/feedstock-builds/_build/results?buildId=1492698&view=logs&jobId=535b614b-9e28-51ef-eb67-d0aa83d01d61
pushd rust
for /d %%d in (*) do (
    if exist "%%d\protos" (
        rmdir /s /q "%%d\protos" 2>nul
        del /q "%%d\protos" 2>nul
        xcopy /e /i /q "..\protos" "%%d\protos" >nul
    )
)
popd

REM Bundle all downstream library licenses
cd python
cargo-bundle-licenses ^
    --format yaml ^
    --output %SRC_DIR%\THIRDPARTY.yml ^
    || goto :error
REM install the package
%PYTHON% -m pip install . -vv