set OPENSSL_DIR=%LIBRARY_PREFIX%
REM Create temp folder
mkdir tmpbuild_%PY_VER%
set TEMP=%CD%\tmpbuild_%PY_VER%
REM Bundle all downstream library licenses
cd python
cargo-bundle-licenses ^
    --format yaml ^
    --output %SRC_DIR%\THIRDPARTY.yml ^
    || goto :error
REM Use PEP517 to install the package
maturin build ^
    --release ^
    --strip ^
    --manylinux off ^
    --interpreter=%PYTHON%
REM Install wheel
cd target/wheels
REM set UTF-8 mode by default
chcp 65001
set PYTHONUTF8=1
set PYTHONIOENCODING="UTF-8"
set TMPDIR=tmpbuild_%PY_VER%
FOR %%w in (*.whl) DO %PYTHON% -m pip install %%w --no-clean
