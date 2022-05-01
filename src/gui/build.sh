#!/usr/bin/env bash
set -o errexit
set -x

mkdir -p build
cd build
rm -rf nimcache

nim c \
    -d=asm \
    -d=emscripten \
    -d=useMalloc \
    --opt=size \
    --cpu=wasm32 \
    --cc=clang \
    --clang.exe=emcc \
    --clang.linkerexe=emcc \
    --nimcache=nimcache \
    --noMain \
    --compileOnly \
    --exceptions=goto \
    --header=em_main.h \
    --gc=orc \
    --out=em_main.o \
    ../em_main.nim

# find nimcache -iname "*.c" -or -iname "*.h" |
#     xargs -t -P0 -I{} \
#         clang-format -style='{ColumnLimit: 120}' \
#         -i {}

cm_verbose=OFF

emcmake cmake \
    -DCMAKE_VERBOSE_MAKEFILE:BOOL=$cm_verbose \
    ..

make -j12

clang-format -i em_result.js

echo "compiled"
