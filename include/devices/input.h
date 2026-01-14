#ifndef DEVICES_INPUT_H
#define DEVICES_INPUT_H 1
/*
** input.h for ACE Basic
**
** Note: Translated to ACE by ConvertC2ACE
**       @ MapMeadow Software, Nils Sjoholm
**
**
** Date: 09/03/95
**
**
*/


#ifndef     EXEC_IO_H
#include <exec/io.h>
#endif

#define  IND_ADDHANDLER    (CMD_NONSTD+0)
#define  IND_REMHANDLER    (CMD_NONSTD+1)
#define  IND_WRITEEVENT    (CMD_NONSTD+2)
#define  IND_SETTHRESH     (CMD_NONSTD+3)
#define  IND_SETPERIOD     (CMD_NONSTD+4)
#define  IND_SETMPORT      (CMD_NONSTD+5)
#define  IND_SETMTYPE      (CMD_NONSTD+6)
#define  IND_SETMTRIG      (CMD_NONSTD+7)

#endif  /* DEVICES_INPUT_H */
