#!/usr/bin/env bash
set -o errexit
set -x

rm -rf nimcache

nim c \
    -d=asm \
    -d=emscripten \
    -d=danger \
    --verbosity=1 \
    -d=release \
    --stacktrace=off \
    --opt=size \
    --cpu=i386 \
    --cc=clang \
    --clang.exe=emcc \
    --clang.linkerexe=emcc \
    --nimcache=nimcache \
    --noMain \
    --compileOnly \
    --header=em_main.h \
    --gc=orc \
    --define=cimguiStaticLinking \
    --out=em_main.o \
    em_main.nim

nimdir=$HOME/.choosenim/toolchains/nim-$(
    nim --version | grep Version | cut -d' ' -f4 | tr -d '\n'
)

emcc em_main.c \
    nimcache/*.c \
    -O2 -Oz \
    -I$nimdir/lib \
    -s EXPORTED_FUNCTIONS="['_printTest', '_main']" \
    -s EXTRA_EXPORTED_RUNTIME_METHODS="['cwrap']" \
    -s ALLOW_MEMORY_GROWTH=1 \
    -s WASM=1 \
    -s NO_EXIT_RUNTIME=1 \
    --shell-file em_main.html \
    -flto \
    -o em_result.html

echo "compiled"
