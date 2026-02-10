{*
** SAGA Chunky Screen Submodule for ACE BASIC
**
** Provides direct access to the Vampire Isabel video chip
** for chunky pixel modes, bypassing the OS (no Intuition,
** no P96 driver needed).
**
** Uses POKEW/POKEL for direct register access.
**
** Requires: Vampire FPGA accelerator with SAGA chipset
**
** Register map:
**   $DFF1EC  LONG  SAGA_POINTER    Chunky bitmap pointer
**   $DFF1F4  WORD  SAGA_GFXMODE    Resolution | color format
**   $DFF1E6  WORD  SAGA_MODULO     Row modulo
**   $DFE1EC  LONG  SAGA_POINTER_READ  Read-back pointer
**   $DFE1F4  WORD  SAGA_GFXMODE_READ  Read-back mode
**   $DFF380  LONG  SAGA_CHUNKY_COL    Palette: N<<24|R<<16|G<<8|B
**
** PiP registers:
**   $DFF3D0  WORD  PIP_X_START
**   $DFF3D2  WORD  PIP_Y_START
**   $DFF3D4  WORD  PIP_X_STOP
**   $DFF3D6  WORD  PIP_Y_STOP
**   $DFF3D8  LONG  PIP_POINTER
**   $DFF3DC  WORD  PIP_GFXMODE
**   $DFF3DE  WORD  PIP_MODULO
**   $DFF3E0  WORD  PIP_CLRKEY
**   $DFF3E2  WORD  PIP_DMAROWS
**
** Author: ACE Project
**   Date: February 2026
*}

{* Saved state for restore *}
SHORTINT _sagaOldMode%
LONGINT  _sagaOldPtr&


{* --- SagaOpen --- *}
{* Save current display state and activate SAGA chunky mode. *}

SUB SagaOpen(bufAddr&, resolution%, colorFmt%) EXTERNAL
  SHARED _sagaOldMode%, _sagaOldPtr&

  ' Save current state
  _sagaOldMode% = PEEKW(&HDFE1F4)
  _sagaOldPtr&  = PEEKL(&HDFE1EC)

  ' Activate new mode
  POKEW &HDFF1F4, resolution% OR colorFmt%
  POKEW &HDFF1E6, 0
  POKEL &HDFF1EC, bufAddr&

  ' Disable CIA-A keyboard interrupt so OS handler won't steal key events
  POKE &HBFED01, &H08
END SUB


{* --- SagaClose --- *}
{* Restore the display state saved by SagaOpen. *}

SUB SagaClose EXTERNAL
  SHARED _sagaOldMode%, _sagaOldPtr&

  ' Re-enable CIA-A keyboard interrupt for OS
  POKE &HBFED01, &H88

  POKEW &HDFF1F4, _sagaOldMode%
  POKEL &HDFF1EC, _sagaOldPtr&
END SUB


{* --- SagaSetBuffer --- *}
{* Switch the displayed framebuffer pointer. *}

SUB SagaSetBuffer(bufAddr&) EXTERNAL
  POKEL &HDFF1EC, bufAddr&
END SUB


{* --- SagaSetModulo --- *}
{* Set row modulo (bytes to skip after each row). *}

SUB SagaSetModulo(modulo%) EXTERNAL
  POKEW &HDFF1E6, modulo%
END SUB


{* --- SagaSetColor --- *}
{* Set a palette entry for 8-bit indexed mode. *}

SUB SagaSetColor(index%, r%, g%, b%) EXTERNAL
  LONGINT val&

  val& = (CLNG(index%) * &H1000000) ~
       + (CLNG(r%) * &H10000) ~
       + (CLNG(g%) * &H100) ~
       + CLNG(b%)
  POKEL &HDFF388, val&
END SUB


{* --- SagaWaitVBL --- *}
{* Wait for vertical blank (tear-free buffer swaps). *}

SUB SagaWaitVBL EXTERNAL
  ASSEM
    .sagawait:
      btst   #5,$dff01f
      beq.s  .sagawait
      move.w #$0020,$dff09c
  END ASSEM
END SUB


{* --- SagaPipOpen --- *}
{* Enable Picture-in-Picture overlay. *}

SUB SagaPipOpen(bufAddr&, x0%, y0%, x1%, y1%, colorFmt%) EXTERNAL
  SHORTINT width%

  POKEW &HDFF3D0, x0%
  POKEW &HDFF3D2, y0%
  POKEW &HDFF3D4, x1%
  POKEW &HDFF3D6, y1%
  POKEL &HDFF3D8, bufAddr&
  POKEW &HDFF3DC, colorFmt%
  POKEW &HDFF3DE, 0

  ' DMA fetch width = pixel width * bytes per pixel
  ' For simplicity, assume format code = bytes per pixel for 8/16-bit
  width% = (x1% - x0%) * colorFmt%
  POKEW &HDFF3E2, width%
END SUB


{* --- SagaPipClose --- *}
{* Disable PiP overlay. *}

SUB SagaPipClose EXTERNAL
  POKEW &HDFF3E2, 0
END SUB


{* --- SagaPipSetKey --- *}
{* Set PiP color key for transparency. *}
{* enable%: 0=off, nonzero=on. r%/g%/b%: 0-15 each (4 bits). *}

SUB SagaPipSetKey(enable%, r%, g%, b%) EXTERNAL
  SHORTINT val%

  val% = ((r% AND &HF) * &H100) ~
       + ((g% AND &HF) * &H10) ~
       + (b% AND &HF)
  IF enable% <> 0 THEN val% = val% OR &H8000
  POKEW &HDFF3E0, val%
END SUB


{* --- SagaRawKey --- *}
{* Poll CIA-A keyboard register for key events. *}
{* Returns: 0-127 = key pressed (scancode),  *}
{*          128-255 = key released (scancode + 128), *}
{*          -1 = no new event. *}
{* *}
{* CIA-A registers used: *}
{*   $BFEC01  SDR  Serial Data Register (keyboard data) *}
{*   $BFED01  ICR  Interrupt Control (bit 3 = SP flag) *}
{*   $BFEE01  CRA  Control Reg A (bit 6 = SP direction) *}

SUB SHORTINT SagaRawKey EXTERNAL
  SHORTINT raw%, inv%, scancode%, keyUp%

  ' Check if a keyboard interrupt is pending (bit 3 of ICR)
  IF (PEEK(&HBFED01) AND &H08) = 0 THEN
    SagaRawKey = -1
    EXIT SUB
  END IF

  ' Read and decode the keycode
  raw% = PEEK(&HBFEC01)
  inv% = raw% XOR &HFF
  keyUp% = inv% AND 1
  scancode% = (inv% / 2) AND &H7F

  ' Handshake: pulse bit 6 of CRA to acknowledge
  POKE &HBFEE01, PEEK(&HBFEE01) OR &H40
  ' Small delay (dummy read)
  raw% = PEEK(&HBFEF01)
  POKE &HBFEE01, PEEK(&HBFEE01) AND &HBF

  IF keyUp% THEN
    SagaRawKey = scancode% + 128
  ELSE
    SagaRawKey = scancode%
  END IF
END SUB
