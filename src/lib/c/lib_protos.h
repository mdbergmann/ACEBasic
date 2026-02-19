/* lib_protos.h -- K&R-style prototypes for runtime library.
** Avoids implicit-function-declaration warnings (vbcc 161/213)
** without pulling in heavy system headers.
**
** Copyright (C) 2026 Manfred Bergmann
** License: GPLv2+
*/

#ifndef LIB_PROTOS_H
#define LIB_PROTOS_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

/* exec.library */
extern APTR AllocMem();
extern void FreeMem();
extern struct Library *OpenLibrary();
extern void CloseLibrary();
extern struct Task *FindTask();
extern APTR GetMsg();
extern void ReplyMsg();
extern void WaitPort();
extern ULONG Wait();
extern ULONG AvailMem();
extern BYTE OpenDevice();
extern void CloseDevice();
extern BYTE DoIO();
extern void BeginIO();
extern BYTE WaitIO();
extern void AbortIO();

/* intuition.library */
extern APTR AllocRemember();
extern void FreeRemember();
extern struct Window *OpenWindow();
extern void CloseWindow();
extern void CloseScreen();
extern LONG AddGadget();
extern USHORT RemoveGadget();
extern void RefreshGList();
extern void ModifyIDCMP();
extern BOOL Request();
extern void EndRequest();
extern void InitRequester();
extern BOOL ActivateGadget();
extern void ClearMenuStrip();
extern BOOL SetMenuStrip();
extern LONG AutoRequest();
extern ULONG LockIBase();
extern void UnlockIBase();
extern void NewModifyProp();
extern USHORT AddGList();
extern USHORT RemoveGList();

/* dos.library */
extern LONG Open();
extern LONG Close();
extern LONG Read();
extern LONG Write();
extern LONG Seek();
extern void Execute();
extern void Delay();
extern LONG IoErr();
extern LONG Lock();
extern void UnLock();
extern BOOL Examine();
extern BOOL ExNext();
extern LONG WaitForChar();
extern LONG SetFileSize();
extern LONG CreateDir();
extern BOOL DeleteFile();

/* graphics.library */
extern void SetAPen();
extern void Move();
extern void Draw();
extern LONG Text();
extern void RectFill();
extern ULONG SetSoftStyle();
extern ULONG AskSoftStyle();
extern void SetFont();
extern void CloseFont();
extern void ClearScreen();
extern void ScrollRaster();
extern LONG TextLength();

/* diskfont.library */
extern struct TextFont *OpenDiskFont();

/* asl.library */
extern APTR AllocAslRequest();
extern BOOL AslRequest();
extern void FreeAslRequest();

/* amiga.lib helpers */
extern struct MsgPort *CreatePort();
extern void DeletePort();
extern struct IORequest *CreateExtIO();
extern void DeleteExtIO();

/* C library / amiga.lib (varargs need ANSI proto for warning 213) */
extern int sprintf(char *, const char *, ...);
extern int fprintf(void *, const char *, ...);
extern int printf(const char *, ...);
extern int putchar();
extern int fgetc();

/* internal runtime functions */
extern char *strsingle();
extern void printsLF();
extern void printsTAB();
extern SHORT system_version();
extern void Ustringinput();
extern void Ustringprint();

#endif
