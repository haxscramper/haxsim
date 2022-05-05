#!/usr/bin/env bash
set -o errexit
set -x

mkdir -p build
cd build
rm -rf nimcache
# rm -rf generated
mkdir -p generated

nim c \
    -d=gennyProcHeaderPragmas='{.raises: [], cdecl, exportc, codegenDecl: "$# $#$#".}' \
    --nimcache=nimcache \
    --header=em_main.h \
    --warnings=off \
    --noMain \
    --gc=refc \
    --out=$PWD/libem_main.a \
    --app=staticlib \
    ../em_main.nim

echo "[SH] Library compilation completed"

# nim c -r \
#     --nimcache=nimcache \
#     --gc=refc \
#     --define=directRun \
#     ../em_main.nim

echo "[SH] Direct run completed"

cm_verbose=OFF
