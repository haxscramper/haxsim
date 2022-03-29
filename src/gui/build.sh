#!/usr/bin/env bash
set -o errexit
set -x

nim c em_drive.nim

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
    --noLinking \
    --header=em_main.h \
    --gc=orc \
    --out=em_main.o \
    em_main.nim

nimdir=$HOME/.choosenim/toolchains/nim-$(
    nim --version | grep Version | cut -d' ' -f4 | tr -d '\n'
)

emcc em_main.c \
    nimcache/*.c \
    -O2 \
    -Oz \
    -I$nimdir/lib \
    -DCIMGUI_DEFINE_ENUMS_AND_STRUCTS \
    -I../../../deps/pkgs/imgui-1.84.2/imgui/private/cimgui \
    -s USE_GLFW=3 \
    -s LLD_REPORT_UNDEFINED \
    -s EXTRA_EXPORTED_RUNTIME_METHODS="['cwrap']" \
    -s ALLOW_MEMORY_GROWTH=1 \
    -s SAFE_HEAP \
    -s DEMANGLE_SUPPORT=1 \
    --source-map-base '/' \
    -g4 \
    -s NO_EXIT_RUNTIME=1 \
    --shell-file base.html \
    -flto \
    -o em_main.js

clang-format -i em_main.js
nim c -r httpserve.nim
echo compiled done
