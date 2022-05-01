cmake_minimum_required(VERSION 3.0)
project(em_main)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 11)
# Linux -pthread shenanigans
if(CMAKE_SYSTEM_NAME STREQUAL Linux)
  set(THREADS_PREFER_PTHREAD_FLAG ON)
  find_package(Threads REQUIRED)
endif()

if(CIMGUI_DIR STREQUAL "some string")
  message(FATAL_ERROR "CIMGUI_DIR must not be empty")
else()
  message("Using cimgui dir -- ${CIMGUI_DIR}")
endif()

execute_process(COMMAND nim --version OUTPUT_VARIABLE nim_version_out)

string(REGEX MATCH "Version ([0-9]+\\.[0-9]+\\.[0-9]+)" _ ${nim_version_out})
set(nim_version ${CMAKE_MATCH_1})
set(NIM_INCLUDE_DIRS "$ENV{HOME}/.choosenim/toolchains/nim-${nim_version}/lib")

message(STATUS "Using nim version " ${nim_version})

message(DEBUG "Nim base include dirs" ${NIM_INCLUDE_DIRS})

# === LIBRARY: cimgui + Dear ImGui
add_library(
  cimgui STATIC
  ${CIMGUI_DIR}/cimgui.cpp
  ${CIMGUI_DIR}/cimgui.h
  ${CIMGUI_DIR}/imgui/imgui.cpp
  ${CIMGUI_DIR}/imgui/imgui.h
  ${CIMGUI_DIR}/imgui/imgui_widgets.cpp
  ${CIMGUI_DIR}/imgui/imgui_draw.cpp
  ${CIMGUI_DIR}/imgui/imgui_tables.cpp
  ${CIMGUI_DIR}/imgui/imgui_demo.cpp)

target_include_directories(cimgui INTERFACE cimgui)

# === LIBRARY: sokol add headers to the the file list because they are useful to
# have in IDEs
set(SOKOL_HEADERS sokol/sokol_gfx.h sokol/sokol_app.h sokol/sokol_imgui.h
                  sokol/sokol_glue.h)

add_library(sokol STATIC sokol/sokol.c ${SOKOL_HEADERS})
target_include_directories(sokol PUBLIC ${CIMGUI_DIR})

if(CMAKE_SYSTEM_NAME STREQUAL Linux)
  target_link_libraries(sokol INTERFACE X11 Xi Xcursor GL dl m)
  target_link_libraries(sokol PUBLIC Threads::Threads)
endif()

target_link_libraries(sokol PUBLIC cimgui)
target_include_directories(sokol INTERFACE sokol)

add_executable(em_main)
file(GLOB nim_sources nimcache/*.c)

target_link_libraries(em_main sokol)
target_sources(em_main PUBLIC ${nim_sources})
target_include_directories(em_main PUBLIC ${CMAKE_SOURCE_DIR}/sokol)
target_compile_definitions(em_main PUBLIC CIMGUI_DEFINE_ENUMS_AND_STRUCTS)
target_include_directories(em_main PUBLIC ${NIM_INCLUDE_DIRS})

set(CMAKE_EXECUTABLE_SUFFIX ".html")
# use our own minimal shell.html
target_link_options(em_main PRIVATE --shell-file
                    ${CMAKE_SOURCE_DIR}/sokol/shell.html)

# WASM+JS size optimizations
target_link_options(
  em_main
  PRIVATE
  -sNO_FILESYSTEM=1
  -sASSERTIONS=0
  -g1
  -sMALLOC=emmalloc
  -sUSE_GLFW=3
  --closure=1)

# this hack removes the xxx-CMakeForceLinker.cxx dummy file
set_target_properties(em_main PROPERTIES LINKER_LANGUAGE C)
