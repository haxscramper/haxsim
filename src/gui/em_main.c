#include "nimcache/em_main.h"
#include <emscripten.h>
#include <stdio.h>

EMSCRIPTEN_KEEPALIVE void myFunction() {
    printf("MyFunction Called\n");
}

int main(int argc, char** argv) {
    printf("[C] Called main");
    NimMain();
    printf("[C] Called nim main");
    EM_ASM(InitWrappers());
    printf("[C] Called init sources");
}
