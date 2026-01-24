/*
** ACE linked-library module: GadTools gadgets.
** Copyright (C) 1998 David Benn
**
** This program is free software; you can redistribute it and/or
** modify it under the terms of the GNU General Public License
** as published by the Free Software Foundation; either version 2
** of the License, or (at your option) any later version.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software
** Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
**
** GadTools gadget creation and lifecycle management.
** Provides _CreateGTGadget, _CleanupGadTools for the ACE runtime.
**
** Author: David J Benn
**   Date: January 2026
*/

#include <exec/types.h>
#include <intuition/intuition.h>
#include <utility/tagitem.h>

/* NewGadget struct for CreateGadgetA */
struct NewGadget {
    WORD ng_LeftEdge, ng_TopEdge;
    WORD ng_Width, ng_Height;
    UBYTE *ng_GadgetText;
    struct TextAttr *ng_TextAttr;
    UWORD ng_GadgetID;
    ULONG ng_Flags;
    APTR ng_VisualInfo;
    APTR ng_UserData;
};

/* GadTools inline function stubs (vbcc) */
#define CLIB_GADTOOLS_PROTOS_H 1
#include <proto/gadtools.h>

#define MAXGADGET 255
#define CLOSEGAD  256L
#define MAX_LABEL_ARRAYS 16

/* module state */
static BOOL gt_initialized = FALSE;
static BOOL gadgets_in_window = FALSE;
static APTR vi = NULL;
static struct Gadget *glist = NULL;
static struct Gadget *prevgad = NULL;
static struct Gadget *gt_gadgets[MAXGADGET+1];
static ULONG gt_gadnum = 0;
static ULONG gt_lastcode = 0;

/* Label array tracking for cleanup */
static struct {
    APTR ptr;
    ULONG size;
} gt_label_arrays[MAX_LABEL_ARRAYS];
static int gt_num_label_arrays = 0;

/* external variables */
extern struct Screen *Scrn;
extern struct Window *Wdw;

/* external functions */
extern void set_wdw_close_num();

/* internal functions */
static void InitGadTools()
{
    if (gt_initialized) return;
    if (Scrn == NULL) return;

    vi = GetVisualInfoA(Scrn, NULL);
    if (vi == NULL) return;

    prevgad = CreateContext(&glist);
    if (prevgad == NULL)
    {
	FreeVisualInfo(vi);
	vi = NULL;
	return;
    }

    gt_initialized = TRUE;
}

/* public functions */

APTR BuildGTLabels(element_size, num_elements, array_addr)
LONG element_size;
LONG num_elements;
char *array_addr;
{
/*
** Build a NULL-terminated STRPTR array from an ACE fixed-size
** string array.  GadTools GTCY_Labels/GTMX_Labels need this
** format: an array of char* pointers, NULL-terminated.
**
** ACE string arrays store strings as contiguous fixed-size blocks:
**   [elem_size bytes][elem_size bytes]...
**
** We allocate a pointer array: (num_elements+1) * 4 bytes
** and fill each entry with a pointer into the string data.
*/
LONG alloc_size;
char **ptrs;
LONG i;

    if (num_elements <= 0 || element_size <= 0 || array_addr == NULL)
	return NULL;

    alloc_size = (num_elements + 1) * 4;
    ptrs = (char **)AllocMem(alloc_size, 0L);
    if (ptrs == NULL) return NULL;

    for (i = 0; i < num_elements; i++)
	ptrs[i] = array_addr + (i * element_size);
    ptrs[num_elements] = NULL;

    /* Track for cleanup */
    if (gt_num_label_arrays < MAX_LABEL_ARRAYS)
    {
	gt_label_arrays[gt_num_label_arrays].ptr = (APTR)ptrs;
	gt_label_arrays[gt_num_label_arrays].size = alloc_size;
	gt_num_label_arrays++;
    }

    return (APTR)ptrs;
}

void CreateGTGadget(tagarray, kind, y2, x2, y1, x1, label, status, id)
ULONG *tagarray;
LONG kind;
LONG y2, x2, y1, x1;
UBYTE *label;
LONG status, id;
{
struct NewGadget ng;
struct Gadget *gad;

    if (id < 1 || id > MAXGADGET) return;

    if (!gt_initialized) InitGadTools();
    if (!gt_initialized) return;

    /* Remove existing gadgets from window before modifying list */
    if (gadgets_in_window && Wdw)
    {
	RemoveGList(Wdw, glist, -1);
	gadgets_in_window = FALSE;
    }

    /* Fill NewGadget struct */
    ng.ng_LeftEdge = (WORD)x1;
    ng.ng_TopEdge = (WORD)y1;
    ng.ng_Width = (WORD)(x2 - x1);
    ng.ng_Height = (WORD)(y2 - y1);
    ng.ng_GadgetText = label;
    ng.ng_TextAttr = NULL;
    ng.ng_GadgetID = (UWORD)id;
    ng.ng_Flags = 0;
    ng.ng_VisualInfo = vi;
    ng.ng_UserData = NULL;

    /* Create the gadget */
    gad = CreateGadgetA((ULONG)kind, prevgad, &ng,
			(struct TagItem *)tagarray);
    if (gad == NULL) return;

    prevgad = gad;
    gt_gadgets[id] = gad;

    /* Disable if status == 0 */
    if (status == 0)
	gad->Flags |= GADGDISABLED;

    /* Add gadgets to window if open */
    if (Wdw)
    {
	AddGList(Wdw, glist, -1, -1, NULL);
	RefreshGList(glist, Wdw, NULL, -1);
	GT_RefreshWindow(Wdw, NULL);
	/* Ensure REFRESHWINDOW is in IDCMP for GadTools refresh handling */
	ModifyIDCMP(Wdw, Wdw->IDCMPFlags | REFRESHWINDOW);
	gadgets_in_window = TRUE;
    }
}

void CleanupGadTools()
{
int i;

    if (!gt_initialized) return;

    if (gadgets_in_window && Wdw)
    {
	RemoveGList(Wdw, glist, -1);
	gadgets_in_window = FALSE;
    }

    if (glist)
    {
	FreeGadgets(glist);
	glist = NULL;
    }

    if (vi)
    {
	FreeVisualInfo(vi);
	vi = NULL;
    }

    /* Free label arrays built by BuildGTLabels */
    for (i = 0; i < gt_num_label_arrays; i++)
    {
	if (gt_label_arrays[i].ptr)
	    FreeMem(gt_label_arrays[i].ptr,
		    gt_label_arrays[i].size);
	gt_label_arrays[i].ptr = NULL;
    }
    gt_num_label_arrays = 0;

    prevgad = NULL;
    gt_initialized = FALSE;
}

/* ---- Close individual gadget ---- */

void CloseGTGadget(id)
LONG id;
{
struct Gadget *gad;

    if (id < 1 || id > MAXGADGET) return;
    gad = gt_gadgets[id];
    if (gad == NULL) return;

    if (gadgets_in_window && Wdw)
    {
	RemoveGList(Wdw, glist, -1);
	gadgets_in_window = FALSE;
    }

    gt_gadgets[id] = NULL;

    /* Re-add remaining gadgets if window is open */
    if (Wdw)
    {
	AddGList(Wdw, glist, -1, -1, NULL);
	RefreshGList(glist, Wdw, NULL, -1);
	GT_RefreshWindow(Wdw, NULL);
	gadgets_in_window = TRUE;
    }
}

/* ---- Attribute access ---- */

void SetGTGadgetAttrs(tagarray, id)
ULONG *tagarray;
LONG id;
{
struct Gadget *gad;

    if (id < 1 || id > MAXGADGET) return;
    gad = gt_gadgets[id];
    if (gad == NULL || Wdw == NULL) return;

    GT_SetGadgetAttrsA(gad, Wdw, NULL, (struct TagItem *)tagarray);
}

ULONG GetGTGadgetAttr(tag, id)
ULONG tag;
LONG id;
{
struct Gadget *gad;
struct TagItem tags[2];
ULONG result;

    if (id < 1 || id > MAXGADGET) return 0L;
    gad = gt_gadgets[id];
    if (gad == NULL || Wdw == NULL) return 0L;

    result = 0L;
    tags[0].ti_Tag = tag;
    tags[0].ti_Data = (ULONG)&result;
    tags[1].ti_Tag = 0L;  /* TAG_DONE */
    tags[1].ti_Data = 0L;
    GT_GetGadgetAttrsA(gad, Wdw, NULL, tags);
    return result;
}

/* ---- Event handling ---- */

ULONG gt_gadget_event_test()
{
/* Non-blocking test for a GadTools gadget event.
** Uses GT_GetIMsg/GT_ReplyIMsg.
** Handles REFRESHWINDOW automatically.
** Returns 1 if a gadget event occurred, 0 otherwise.
*/
struct IntuiMessage *msg;
struct Gadget *GadPtr;
USHORT GadNum;
ULONG MsgClass;

    if (Wdw == NULL) return 0L;

    msg = GT_GetIMsg(Wdw->UserPort);
    if (msg == NULL) return 0L;

    MsgClass = msg->Class;

    /* Handle REFRESHWINDOW internally */
    if (MsgClass & REFRESHWINDOW)
    {
	GT_BeginRefresh(Wdw);
	GT_EndRefresh(Wdw, TRUE);
	GT_ReplyIMsg(msg);
	return 0L;
    }

    if (MsgClass & GADGETUP)
    {
	GadPtr = (struct Gadget *)msg->IAddress;
	GadNum = GadPtr->GadgetID;
	gt_lastcode = (ULONG)msg->Code;
    }
    else
	GadNum = 0;

    GT_ReplyIMsg(msg);

    if ((MsgClass & GADGETUP) && GadNum >= 1 && GadNum <= MAXGADGET)
    {
	gt_gadnum = (ULONG)GadNum;
	return 1L;
    }

    return 0L;
}

void WaitGTGadget(id)
ULONG id;
{
/* Wait on a specific gadget (id), or any gadget if id=0.
** Uses GT_GetIMsg/GT_ReplyIMsg.
** Handles REFRESHWINDOW automatically.
*/
struct IntuiMessage *msg;
struct Gadget *GadPtr;
USHORT GadNum;
ULONG MsgClass;

    if (Wdw == NULL) return;
    if (id > MAXGADGET) return;
    if (id > 0 && gt_gadgets[id] == NULL) return;

    do
    {
	msg = GT_GetIMsg(Wdw->UserPort);
	if (msg == NULL)
	{
	    Wait(1L << Wdw->UserPort->mp_SigBit);
	    continue;
	}

	MsgClass = msg->Class;

	/* Handle REFRESHWINDOW internally */
	if (MsgClass & REFRESHWINDOW)
	{
	    GT_BeginRefresh(Wdw);
	    GT_EndRefresh(Wdw, TRUE);
	    GT_ReplyIMsg(msg);
	    continue;
	}

	if (MsgClass & GADGETUP)
	{
	    GadPtr = (struct Gadget *)msg->IAddress;
	    GadNum = GadPtr->GadgetID;
	    gt_lastcode = (ULONG)msg->Code;
	}
	else
	    GadNum = 0;

	GT_ReplyIMsg(msg);

	/* Handle CLOSEWINDOW */
	if (MsgClass & CLOSEWINDOW)
	{
	    set_wdw_close_num();
	    gt_gadnum = CLOSEGAD;
	    return;
	}

	/* Any gadget will do? */
	if (id == 0 && (MsgClass & GADGETUP)) break;
    }
    while (!(MsgClass & GADGETUP) || GadNum != id);

    gt_gadnum = (ULONG)GadNum;
}

ULONG GadFuncGT(n)
ULONG n;
{
/* Return information about the currently selected GadTools gadget.
** n=0: test for event (non-blocking), returns -1 if event, 0 if none
** n=1: return gadget ID of last selected gadget
** n=2: return string buffer or longint value (STRING_KIND/INTEGER_KIND)
** n=3: return slider/scroller level (from IDCMP Code field)
** n=4: return address of Gadget struct
*/
struct Gadget *gad;
struct StringInfo *si;

    switch(n)
    {
	case 0:
	    if (gt_gadget_event_test())
		return -1L;
	    else
		return 0L;

	case 1:
	    return gt_gadnum;

	case 2:
	    if (gt_gadnum < 1 || gt_gadnum > MAXGADGET) return 0L;
	    gad = gt_gadgets[gt_gadnum];
	    if (gad == NULL) return 0L;
	    si = (struct StringInfo *)gad->SpecialInfo;
	    if (si == NULL) return 0L;
	    /* STRING_KIND: return buffer address */
	    /* INTEGER_KIND: return LongInt value */
	    if (si->LongInt != 0 && si->Buffer != NULL
		&& si->Buffer[0] >= '0' && si->Buffer[0] <= '9')
		return (ULONG)si->LongInt;
	    return (ULONG)si->Buffer;

	case 3:
	    /* For SLIDER_KIND/SCROLLER_KIND, the level is in the
	    ** Code field of the IDCMP message, stored in gt_lastcode.
	    */
	    return gt_lastcode;

	case 4:
	    if (gt_gadnum < 1 || gt_gadnum > MAXGADGET) return 0L;
	    return (ULONG)gt_gadgets[gt_gadnum];

	default:
	    return 0L;
    }
}
