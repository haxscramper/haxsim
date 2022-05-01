cmake_minimum_required(VERSION 3.0)
project(em_result)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 11)

execute_process(COMMAND nim --version OUTPUT_VARIABLE nim_version_out)

string(REGEX MATCH "Version ([0-9]+\\.[0-9]+\\.[0-9]+)" _ ${nim_version_out})
set(nim_version ${CMAKE_MATCH_1})
set(NIM_INCLUDE_DIRS "$ENV{HOME}/.choosenim/toolchains/nim-${nim_version}/lib")

message(STATUS "Using nim version " ${nim_version})
message(DEBUG "Nim base include dirs" ${NIM_INCLUDE_DIRS})

add_executable(em_result)
file(GLOB nim_sources build/nimcache/*.c)

target_sources(em_result PUBLIC ${CMAKE_SOURCE_DIR}/em_main.c)
target_sources(em_result PUBLIC ${nim_sources})
target_include_directories(em_result PUBLIC ${NIM_INCLUDE_DIRS})

set(CMAKE_EXECUTABLE_SUFFIX ".html")

target_compile_options(
  em_result PRIVATE -O0 -Oz -g --source-map-base=http://localhost:8080/
                    -gsource-map)

target_link_options(
  em_result
  PRIVATE
  -sMALLOC=emmalloc
  -O0
  -Oz
  -g
  --source-map-base=http://localhost:8080/
  -gsource-map
  "-sEXPORTED_FUNCTIONS=['_printTest','_main']"
  "-sEXPORTED_RUNTIME_METHODS=['cwrap']"
  -sALLOW_MEMORY_GROWTH=1
  -sMAXIMUM_MEMORY=4GB
  -sWASM=1
  -sASSERTIONS=2
  -sSAFE_HEAP=1
  -sNO_EXIT_RUNTIME=1
  --shell-file
  ${CMAKE_SOURCE_DIR}/em_main.html)

# this hack removes the xxx-CMakeForceLinker.cxx dummy file
set_target_properties(em_result PROPERTIES LINKER_LANGUAGE C)
