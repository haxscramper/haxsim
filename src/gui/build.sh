#!/usr/bin/env bash
set -o errexit
set -x

# nim c em_drive.nim

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
    --gc=refc \
    --define=cimguiStaticLinking \
    --out=em_main.o \
    em_main.nim # --gc=orc \
# --gc=orc \
# --hints=on \
# --hint=all:off \
# --hint=Processing:on \
# --processing=filenames \

nimdir=$HOME/.choosenim/toolchains/nim-$(
    nim --version | grep Version | cut -d' ' -f4 | tr -d '\n'
)

IMDIR=../../../deps/pkgs/imgui-1.84.2/

# rm -rf build
mkdir -p build
cd build
# rm -rf CMakeFiles

# export EMCC_DEBUG=2
emcmake cmake \
    -DCMAKE_BUILD_TYPE=MinSizeRel \
    -DCIMGUI_DIR=$IMDIR/imgui/private/cimgui \
    ..

make -j10
# clang-format -i em_main.js

# cmake --build .

# emcc em_main.c \
#     nimcache/*.c \
#     -O2 \
#     -Oz \
#     -I$nimdir/lib \
#     -DCIMGUI_DEFINE_ENUMS_AND_STRUCTS \
#     -I$IMDIR/imgui/private/cimgui \
#     -s USE_GLFW=3 \
#     --shell-file base.html \
#     -o em_main.js

# nim c -r httpserve.nim
# echo compiled done
