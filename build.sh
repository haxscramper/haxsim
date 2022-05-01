#!/usr/bin/env bash
# -*- coding: utf-8 -*-
set -o nounset
set -o errexit

wip="${1:-webui}"

case $wip in
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
