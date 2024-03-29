#!/usr/bin/env bash
# -*- coding: utf-8 -*-
set -o nounset
set -o errexit

wip="${1:-imgui}"

case $wip in
    "cpp")
        mkdir -p nimcache/genny
        nim \
            cpp \
            -d=gennyProcHeaderPragmas='{.raises: [], cdecl, exportc, codegenDecl: "$# $#$#".}' \
            --noMain \
            -d=hmin \
            --gc=refc \
            --noLinking \
            --linetrace=off \
            --stacktrace=off \
            --header=nimcache/genny/em_header.h \
            src/cpus/core.nim

        # clang-format -i nimcache/*haxsim*.cpp

        prifile=nimcache/nimcache.pri
        echo "SOURCES *= \\" >$prifile
        cat nimcache/core.json |
            jq '.link | .[]' |
            sd '"(.*)\.o"' '    "$1" \\' |
            head --bytes -2 >>$prifile

        echo "done"
        ;;

    "single")
        nim cpp -r "tests/tEmuEndToEnd.nim"
        ;;

    "test")
        for file in tests/t*.nim; do
            nim c -o:"tests/temp.bin" -r $file
        done
        echo "done all tests"
        ;;

    "imgui")
        echo "starting compilation"
        nim cpp -r src/gui/em_imgui.nim
        # ./src/gui/em_imgui run
        echo "execution done"
        ;;

    "win")
        echo "Starting win"
        nim c -r \
            --passl=-lole32 \
            --passl=-oleaut32 \
            --passl=-lcomdlg32 \
            --out=src/gui/em_imgui.exe \
            -d=mingw src/gui/em_imgui.nim
        echo "done win"
        ;;

    "webui")
        cd src/gui
        ./build.sh
        echo "done gui compilation"
        ;;
esac
