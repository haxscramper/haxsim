QT     += core gui widgets
TEMPLATE = app
CONFIG += c++20

SOURCES *= em_main.cpp \
    simcore.cpp
HEADERS *= \
    em_main.hpp \
    simcore.hpp
#    build/generated/haxsim.h
INCLUDEPATH *= $$system(./get_nim_dir.sh)
INCLUDEPATH *= $$PWD/build/nimcache
DEPENDPATH *= $$PWD/build/nimcache

ROOT = $$PWD/../..

INCLUDEPATH *= $$ROOT/nimcache/genny
include($$ROOT/nimcache/nimcache.pri)

HEADERS *= $$files($$ROOT/nimcache/genny/*.h)
#LIBS += -L$$PWD/build -lem_main

DISTFILES += \
    ../../nimcache/genny/haxsim.nim \
    ../../nimcache/genny/internal.nim \
    em_main.nim
