#!/usr/bin/env bash
set -o errexit
set -x

mkdir -p build
cd build
rm -rf nimcache
# rm -rf generated
mkdir -p generated

nim c -r \
    --nimcache=nimcache \
    --gc=refc \
    --define=directRun \
    ../em_main.nim

echo "Direct run completed"

nim c \
    -d=gennyProcHeaderPragmas='{.raises: [], cdecl, exportc, codegenDecl: "$# $#$#".}' \
    --nimcache=nimcache \
    --header=em_main.h \
    --noMain \
    --gc=refc \
    --out=$PWD/libem_main.a \
    --app=staticlib \
    ../em_main.nim

cm_verbose=OFF
