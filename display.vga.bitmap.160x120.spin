{
----------------------------------------------------------------------------------------------------
    Filename:       display.vga.bitmap.160x120.spin
    Description:    Bitmap VGA display engine (6bpp color, 160x120)
    Author:         Jesse Burt
    Started:        Nov 17, 2009
    Updated:        Feb 7, 2025
    Copyright (c) 2025 - See end of file for terms of use.
----------------------------------------------------------------------------------------------------

    NOTE: This is a modified version of VGA64_PIXEngine.spin,
        originally by Kwabena W. Agyeman.
        The original header is preserved below.
}
{{

 VGA64 6 Bits Per Pixel Engine

 Author: Kwabena W. Agyeman
 Updated: 11172010
 Designed For: P8X32A
 Version: 1.0

 Copyright (c) 2010 Kwabena W. Agyeman
 See end of file for terms of use.

 Update History:

 v1.0 - Original release - 11172009.

 For each included copy of this object only one spin interpreter should access it at a time.

 Nyamekye,

}}
#define MEMMV_NATIVE bytemove
#include "graphics.common.spinh"

CON

    { default I/O configuration - this can be overridden in the parent object }
    PIN_GRP     = 0                             ' 0..3 for each group of 8 consecutive pins
    WIDTH       = 160
    HEIGHT      = 120


    { driver limits }
    ' actually 6bpp, but each pixel needs a byte of RAM, so count it as 8bpp
    BPP         = 8                             ' bits per pixel/color depth of the display
    BYTESPERPX  = 1 #> (BPP/8)                  ' limit to minimum of 1
    BPPDIV      = BYTESPERPX #> (8 / BPP)       ' limit to range BYTESPERPX .. (8/BPP)
    BUFF_SZ     = (WIDTH * HEIGHT) / BPPDIV
    MAX_COLOR   = 63
    XMAX        = WIDTH-1
    YMAX        = HEIGHT-1
    CENTERX     = WIDTH/2
    CENTERY     = HEIGHT/2

    PIX_CLK     = 25_175_000


VAR

    byte _framebuffer[BUFF_SZ]
    byte _cog


PUB start(): status
' Start VGA engine using default I/O settings
    return startx(PIN_GRP, WIDTH, HEIGHT, @_framebuffer)


PUB startx(PINGRP, DISP_WIDTH, DISP_HEIGHT, ptr_dispbuff): status | frq
' Start VGA engine
'   PINGRP: 8-pin group number (0, 1, 2, 3 for start pin as 0, 8, 16, 24, resp)
'       pins must be connected contiguously in the following (ascending) order:
'           Vsync, Hsync, B0, B1, G0, G1, R0, R1
'   WIDTH, HEIGHT: ignored for compatibility with other drivers
'   ptr_dispbuff: pointer to 19,200 byte (160*120) display/frame buffer
'   Returns:
'       cogid + 1 of the VGA engine on success
'       0 on failure
    stop()

    _disp_width := WIDTH                        ' use builtin symbols; params
    _disp_height := HEIGHT                      '   are only for API compat
    _disp_xmax := _disp_width - 1               '   with other drivers
    _disp_ymax := _disp_height - 1
    _buff_sz := _disp_width * _disp_height
    _bytesperln := WIDTH * BYTESPERPX
    set_address(ptr_dispbuff)

    PINGRP := (0 #> PINGRP <# 3)
    _pindirs := ($FF << (8 * PINGRP))
    _vid_st := ($30_00_00_FF | (PINGRP << 9))

    frq := constant((PIX_CLK + 1_600) / 4)
    _frq_st := 1
    repeat 32
        frq <<= 1
        _frq_st <-= 1
        if ( frq => clkfreq )
            frq -= clkfreq
            _frq_st += 1

    _disp_ind_addr := @_disp_ind
    _sync_ind_addr := @_sync_ind
    status := _cog := cognew(@entry, _ptr_drawbuffer)+1


PUB stop()
' Stop the driver
    if ( _cog )
        cogstop(_cog-1)
        _cog := 0


PUB clear()
' Clear the display
    longfill(_ptr_drawbuffer, _bgcolor, constant((WIDTH * HEIGHT) / 4))


PUB disp_state(state)
' Enable video output
'   Valid values: TRUE (-1), FALSE (0)
    _disp_ind := state


PUB disp_rate(rate): b
' Returns true or false depending on the time elasped according to a specified rate.
'   Rate - A display rate to return at. 0=0.234375Hz, 1=0.46875Hz, 2=0.9375Hz, 3=1.875Hz, 4=3.75Hz, 5=7.5Hz, 6=15Hz, 7=30Hz.
    result or= (($80 >> ((rate <# 7) #> 0)) & _sync_ind)


PUB plot(x, y, color)
' Plot pixel at (x, y) in color
    if (x < 0 or x > _disp_xmax) or (y < 0 or y > _disp_ymax)
        return                                  ' coords out of bounds, ignore
#ifdef GFX_DIRECT
' direct to display
'   (not implemented)
#else
' buffered display
    byte[_ptr_drawbuffer][x + (y * _disp_width)] := (color << 2) | $3
#endif


#ifndef GFX_DIRECT
PUB point(x, y): pix_clr
' Get color of pixel at x, y
    x := 0 #> x <# _disp_xmax
    y := 0 #> y <# _disp_ymax

    return byte[_ptr_drawbuffer][x + (y * _disp_width)] >> 2
#endif


PUB show()
' dummy method for compatibility with other drivers


PUB vsync(): s
' Current vertical sync status
    return _sync_ind


PUB wait_vsync()
' Waits for the display vertical refresh.
    result := _sync_ind                         ' take a snapshot of the sync status
    repeat until ( _sync_ind <> result )        '   now wait for it to change


#ifndef GFX_DIRECT
PRI memfill(xs, ys, val, count)
' Fill region of display buffer memory
'   xs, ys: Start of region
'   val: Color
'   count: Number of consecutive memory locations to write
    bytefill(_ptr_drawbuffer + (xs + (ys * _bytesperln)), (val << 2) | $3, count)
#endif


#define _PASM_
#include "core.con.counters.spin"

DAT

            org     0

entry
' Initialization
            mov     vcfg, _vid_st               ' Setup video hardware.
            mov     frqa, _frq_st               '
            movi    ctra, #(VCO_DIV_4 | PLL_INTERNAL)

loop
' Active Video
            mov     disp_ctr, par               ' Set/Reset tiles fill counter.
            mov     tiles_ctr, #120             '
tiles_disp  mov     tile_ctr, #4                ' Set/Reset tile fill counter.
tile_disp   mov     vscl, vis_scl               ' Set/Reset the video scale.
            mov     counter, #40                '

vid_lp
' Visible Video
            rdlong  buffer, disp_ctr            ' Download new pixels.
            add     disp_ctr, #4                '
            or      buffer, hvs_colors          ' Update display scanline.
            waitvid buffer, #%%3210             '
            djnz    counter, #vid_lp            ' Repeat.

' Invisible Video
            mov     vscl, invis_scl             ' Set/Reset the video scale.
            waitvid hs_colors, sync_pxl         ' Horizontal Sync.

' Repeat
            sub     disp_ctr, #160              ' Repeat.
            djnz    tile_ctr, #tile_disp        '
            add     disp_ctr, #160              ' Repeat.
            djnz    tiles_ctr, #tiles_disp      '

' Inactive Video
            add     refr_ctr, #1                ' Update sync indicator.
            wrbyte  refr_ctr, _sync_ind_addr    '

' Front Porch
            mov     counter, #11                ' Set loop counter.
fporch      mov     vscl, bl_pxl                ' Invisible lines.
            waitvid hs_colors, #0               '
            mov     vscl, invis_scl             ' Horizontal Sync.
            waitvid hs_colors, sync_pxl         '
            djnz    counter, #fporch            ' Repeat # times.

' Vertical Sync
            mov     counter, #(2 + 2)           ' Set loop counter.
vert_sync   mov     vscl, bl_pxl                ' Invisible lines.
            waitvid vs_colors, #0               '
            mov     vscl, invis_scl             ' Vertical Sync.
            waitvid vs_colors, sync_pxl         '
            djnz    counter, #vert_sync         ' Repeat # times.

' Back Porch
            mov     counter, #31                ' Set loop counter.
bporch      mov     vscl, bl_pxl                ' Invisible lines.
            waitvid hs_colors, #0               '
            mov     vscl, invis_scl             ' Horizontal Sync.
            waitvid hs_colors, sync_pxl         '
            djnz    counter, #bporch            ' Repeat # times.

' Update Display Settings
            rdbyte  buffer, _disp_ind_addr wz   ' Update display settings.
            muxnz   dira, _pindirs              '

' Loop
            jmp     #loop                       ' Loop.

' Data
invis_scl           long    (16 << 12) + 160    ' Scaling for inactive video.
vis_scl             long    (4 << 12) + 16      ' Scaling for active video.
bl_pxl              long    640                 ' Blank scanline pixel length.
sync_pxl            long    $00_00_3F_FC        ' F-porch, h-sync, and b-porch.
hs_colors           long    $01_03_01_03        ' Horizontal sync color mask.
vs_colors           long    $00_02_00_02        ' Vertical sync color mask.
hvs_colors          long    $03_03_03_03        ' Horizontal and vertical sync colors.

' Configuration Settings
_pindirs            long    0
_vid_st             long    0
_frq_st             long    0

' Addresses
_disp_ind_addr      long    0
_sync_ind_addr      long    0

' Run Time Variables
counter             res     1
buffer              res     1

tile_ctr            res     1
tiles_ctr           res     1

refr_ctr            res     1
disp_ctr            res     1


                    fit     496


_disp_ind           byte    1                   ' Video output control
_sync_ind           byte    0                   ' Video update control


DAT
{
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}

