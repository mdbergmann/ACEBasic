{*
** Arne Audio Submodule for ACE BASIC
**
** Provides access to the Vampire SAGA "Arne" 16-bit audio chip
** with 16 channels, 8/16-bit samples, stereo volume, and rates
** up to 56 kHz. Uses POKEW/POKEL for direct register access.
**
** Requires: Vampire FPGA accelerator with SAGA chipset
**
** Register map:
**   Channel N base = $DFF400 + (N * $10)
**   +$00 LONG  AUD_POINTER  (sample address, 32-byte aligned)
**   +$04 LONG  AUD_LENGTH   (length in 64-bit chunks)
**   +$08 WORD  AUD_VOLUME   (bits 15-8: left, bits 7-0: right)
**   +$0A WORD  AUD_MODE     (bit0: 16bit, bit1: oneshot, bit2: stereo)
**   +$0C WORD  AUD_PERIOD   (PAL_CLOCK / sample_rate)
**
** DMA control:
**   Ch 0-3:  $DFF096 (DMACON)
**   Ch 4-15: $DFF296 (DMACON2)
**
** Author: ACE Project
**   Date: February 2026
*}


{* --- ArnePlay --- *}
{* Play a sample on a specific Arne channel. *}

SUB ArnePlay(channel%, bufAddr&, byteSize&, ~
             period%, volLeft%, volRight%, mode%) EXTERNAL

  LONGINT base&

  base& = &HDFF400 + (CLNG(channel%) * &H10)

  POKEL base&,       bufAddr&
  POKEL base& + &H4, byteSize& / 8
  POKEW base& + &H8, (volLeft% * 256) + volRight%
  POKEW base& + &HA, mode%
  POKEW base& + &HC, period%

  IF channel% < 4 THEN
    POKEW &HDFF096, &H8000 + (SHL(1, channel%))
  ELSE
    POKEW &HDFF296, &H8000 + (SHL(1, channel% - 4))
  END IF

END SUB


{* --- ArneStop --- *}
{* Stop playback on a channel (disable DMA). *}

SUB ArneStop(channel%) EXTERNAL

  IF channel% < 4 THEN
    POKEW &HDFF096, (SHL(1, channel%))
  ELSE
    POKEW &HDFF296, (SHL(1, channel% - 4))
  END IF

END SUB


{* --- ArneStart --- *}
{* Resume playback on a channel (re-enable DMA). *}

SUB ArneStart(channel%) EXTERNAL

  IF channel% < 4 THEN
    POKEW &HDFF096, &H8000 + (SHL(1, channel%))
  ELSE
    POKEW &HDFF296, &H8000 + (SHL(1, channel% - 4))
  END IF

END SUB


{* --- ArneVolume --- *}
{* Change volume on a playing channel without restarting it. *}

SUB ArneVolume(channel%, volLeft%, volRight%) EXTERNAL

  LONGINT base&

  base& = &HDFF400 + (CLNG(channel%) * &H10)
  POKEW base& + &H8, (volLeft% * 256) + volRight%

END SUB


{* --- ArneIsFree --- *}
{* Returns -1 (true) if channel is free, 0 (false) if busy. *}

SUB SHORTINT ArneIsFree(channel%) EXTERNAL

  SHORTINT dmaStatus%

  IF channel% < 4 THEN
    dmaStatus% = PEEKW(&HDFF002)
    ArneIsFree = ((dmaStatus% AND (SHL(1, channel%))) = 0)
  ELSE
    dmaStatus% = PEEKW(&HDFF202)
    ArneIsFree = ((dmaStatus% AND (SHL(1, channel% - 4))) = 0)
  END IF

END SUB


{* --- ArneFindFree --- *}
{* Scan channels 0-15, return first free channel or -1 if none. *}

SUB SHORTINT ArneFindFree EXTERNAL

  SHORTINT i%

  FOR i% = 0 TO 15
    IF ArneIsFree(i%) THEN
      ArneFindFree = i%
      EXIT SUB
    END IF
  NEXT

  ArneFindFree = -1

END SUB


{* --- ArneStopAll --- *}
{* Stop all 16 channels. *}

SUB ArneStopAll EXTERNAL

  SHORTINT i%

  FOR i% = 0 TO 15
    ArneStop(i%)
  NEXT

END SUB


{* --- ArnePeriod --- *}
{* Convenience: returns PAL_CLOCK / sampleRate& as a SHORT. *}

SUB SHORTINT ArnePeriod(sampleRate&) EXTERNAL

  ArnePeriod = CINT(3546895& / sampleRate&)

END SUB
