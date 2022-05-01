#!/usr/bin/env bash
# -*- coding: utf-8 -*-
set -o nounset
set -o errexit

nimdir=$HOME/.choosenim/toolchains/nim-$(
    nim --version | grep Version | cut -d' ' -f4 | tr -d '\n'
)

echo $nimdir/lib
