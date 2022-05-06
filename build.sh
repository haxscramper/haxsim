#!/usr/bin/env bash
# -*- coding: utf-8 -*-
set -o nounset
set -o errexit

wip="${1:-cpp}"

case $wip in
    "cpp")
        mkdir -p nimcache/genny
        nim \
            cpp \
            -d=gennyProcHeaderPragmas='{.raises: [], cdecl, exportc, codegenDecl: "$# $#$#".}' \
            --noMain \
            --gc=refc \
            --noLinking \
            --header=nimcache/genny/em_header.h \
            src/cpus/core.nim

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
    "webui")
        cd src/gui
        ./build.sh
        echo "done gui compilation"
        ;;
esac
