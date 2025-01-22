#ifndef _MP1_H
#define _MP1_H

#include <n64.h>
#include <stdint.h>
#include "types.h"

#define MP1_SCREEN_WIDTH    320
#define MP1_SCREEN_HEIGHT   240

typedef struct {
    char            unk_0x00[0x230];            /* 0x00000 */
    Gfx             buf[0x2000];                /* 0x00230 */
    Gfx             buf_work[0x200];            /* 0x10230 */
    Mtx             unk_mtx[0x200];             /* 0x11230 */
                                                /* size: 0x19230 */
}disp_buf_t;

typedef struct{
    Gfx             *p;                         /* 0x00000 */
    uint32_t        unk;                        /* 0x00004 */
    disp_buf_t      *disp_buf;                  /* 0x00008 */
                                                /* size: 0x0000C */
}gfx_ctxt_t;

/* Addresses */
#define mp1_gfx_addr            0x800F37DC
#define mp1_GameUpdate_addr     0x8006257C

/* Data */
#define mp1_gfx                (*(gfx_ctxt_t*)      mp1_gfx_addr)

/*Function Prototypes*/
typedef void (*mp1_GameUpdate_t) (gfx_ctxt_t);

/*Functions*/
#define mp1_GameUpdate         ((mp1_GameUpdate_t)  mp1_GameUpdate_addr)

#endif