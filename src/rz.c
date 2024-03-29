    
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

void rz_main(void){

    
    gfx_begin();


    gfx_printf(10,10,"hello, printing is working",10,10);
    

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
    __asm__ volatile("lui $v0, 0x800F;"
                     "lw  $v0, 0x37DC($v0);");

}
