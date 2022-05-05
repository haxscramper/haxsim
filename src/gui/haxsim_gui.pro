QT     += core gui widgets
TEMPLATE = app
CONFIG += c++17

SOURCES *= em_main.cpp
HEADERS *= build/nimcache/em_main.h \
    build/generated/haxsim.h
INCLUDEPATH *= $$system(./get_nim_dir.sh)
INCLUDEPATH *= $$PWD/build/nimcache $$PWD/build/generated
DEPENDPATH *= $$PWD/build/nimcache

ROOT = $$PWD/../..

include($$ROOT/nimcache/nimcache.pri)

#SOURCES *= $$files($$PWD/build/nimcache/*.c)
LIBS += -L$$PWD/build -lem_main

DISTFILES += \
    em_main.nim
