    
#include <stdio.h>
#include <stdlib.h>
#include <startup.h>
#include <startup.c>
#include <inttypes.h>
#include "rz.h"
#include "mp1.h"
#include "gfx.h"

__attribute__((section(".data")))
rz_ctxt_t rz = { 
    .ready = 0, 
};

__attribute__((section(".data")))
s32 calls = 0;

ENTRY u8 rand8(void) {
    rnd_seed = rnd_seed * 0x41C64E6D + 0x3039;
    calls++;
    return (rnd_seed + 1) >> 16;
}

u8 red = 0;
u8 green = 0;
u8 blue = 0;
u8 alpha = 255;

//test printing some things
void rz_main(void){
    gfx_begin();

    //gfx_draw_rectangle(0, 0, 155, 25, GPACK_RGBA8888(0, 0, 0, 255));

    gfx_printf_color(11,4, GPACK_RGBA8888(0, 0, 0, 255), "Seed: 0x%08X", rnd_seed);
    gfx_printf_color(11,14, GPACK_RGBA8888(0, 0, 0, 255), "Calls: 0x%08X", calls);

    // gfx_printf_color(10,25,GPACK_RGBA8888(255, 255, 255, 255), "R: %d", red);
    // gfx_printf_color(10,35,GPACK_RGBA8888(255, 255, 255, 255), "G: %d", green);
    // gfx_printf_color(10,45,GPACK_RGBA8888(255, 255, 255, 255), "B: %d", blue);
    // gfx_printf_color(10,55,GPACK_RGBA8888(255, 255, 255, 255), "A: %d", alpha);

    gfx_printf_color(10,5,GPACK_RGBA8888(255, 255, 255, 255), "Seed: 0x%08X", rnd_seed);
    gfx_printf_color(10,15, GPACK_RGBA8888(255, 255, 255, 255), "Calls: 0x%08X", calls);

    gfx_finish();    /*output gfx display lists*/
    mp1_GameUpdate(mp1_gfx); /* displaced function call - advances 1 game frame*/
}

void init(){
    clear_bss();
    do_global_ctors();
    gfx_init();
    rz.ready = 1;
}

// Initilizes and uses new stack instead of using graph threads stack. 
static void init_stack(void (*func)(void)) {
    static _Alignas(8) __attribute__((section(".stack"))) 
    char stack[0x2000];
    __asm__ volatile(   "la     $t0, %1;"
                        "sw     $sp, -0x04($t0);"
                        "sw     $ra, -0x08($t0);"
                        "addiu  $sp, $t0, -0x08;"
                        "jalr   %0;"
                        "nop;"
                        "lw     $ra, 0($sp);"
                        "lw     $sp, 4($sp);"
                        ::
                        "r"(func),
                        "i"(&stack[sizeof(stack)]));
}

/* rz entry point - init stack and call main function */
ENTRY void _start(void){

    init_gp();
    if(!rz.ready){
        init_stack(init);
    }
    init_stack(rz_main);
}
