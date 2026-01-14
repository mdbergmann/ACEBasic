/*
** A simple ListView requester Subprogram LIBRARY Module.
**
** Adapted from RKM: Libraries (1992), p 383-385
** AND NDK example gadget1.c, by David Benn,
** 18th March, 3rd April, 1st May, 3rd,6th-8th,
** 29th June, 1st July 1995
**
** Modified to use the new includes 14th September 1995,
** by Nils Sjoholm.
** The fontsensitiv changes was done before that.
** The date? can't remember. :)
**
** Changed the source to use the function declarations
** and my tagmacros.
** Date 14-Oct-95   Nils Sjoholm
**
** Created SUBmod from ListBox.b
** making minor changes to the source.
** 17th October 1995, David Benn
** 
**/

#include <libraries/gadtools.h>
#include <ace/acedef.h>
#include <funcs/intuition_funcs.h>
#include <funcs/gadtools_funcs.h>
#include <funcs/utility_funcs.h>
#include <funcs/exec_funcs.h>

/*  *
** Constant definitions.
**/
CONST LISTBOX_CANCELLED = 0
CONST LISTBOX_ITEM_STRINGSIZE = 80

#define OK_CLICKED -1
#define CANCEL_CLICKED -2
#define UNKNOWN_ACTION -3

#define GAD_LISTVIEW  1
#define GAD_BUTTON_OK  2
#define GAD_BUTTON_CANCEL  3

/*  *
** FORWARD SUB declarations.
**/
DECLARE SUB LONGINT gadtools_window(ADDRESS listItemArray, LONGINT items, \
                                    STRING wdwTitle, STRING prompt)
DECLARE SUB handle_gadget(ADDRESS msg, ADDRESS action)
DECLARE SUB do_window_refresh(ADDRESS wdw)

/* ami.lib           */
DECLARE FUNCTION NewList(ADDRESS theList) EXTERNAL

/*  *
** Subprogram definitions.
**/
SUB LONGINT gadtools_window(ADDRESS listItemArray, \
                            LONGINT items, STRING wdwTitle, STRING prompt)
/*  *
** Prepare FOR USING GadTools, set up gadgets,
** OPEN WINDOW AND process IDCMP events.
**/

DECLARE STRUCT _Screen *mysc
DECLARE STRUCT TextAttr *scrFont
DECLARE STRUCT _Window *mywin
DECLARE STRUCT _Gadget *glist, *gad
DECLARE STRUCT NewGadget ng
DECLARE STRUCT TagItem *gadTags, *tag, *wintags
DECLARE STRUCT _List myList
DECLARE STRUCT Node *theNode
DECLARE STRUCT TextAttr gadFont
DECLARE STRUCT IntuiMessage *imsg
DECLARE STRUCT IntuiText IText

LONGINT terminated, class, selected
DIM STRING theItems(1) SIZE LISTBOX_ITEM_STRINGSIZE ADDRESS listItemArray
SHORTINT action
ADDRESS vi
LONGINT YSize
LONGINT Win_Width,Win_Height
LONGINT templeft,temptop,tempwidth,tempheight
LONGINT GadgetWidth
LONGINT IDCMP
STRING longname SIZE LISTBOX_ITEM_STRINGSIZE
STRING dummy SIZE LISTBOX_ITEM_STRINGSIZE
  glist = NULL

  mysc = SCREEN(1)
  IF mysc <> NULL THEN

    vi = GetVisualInfoA(mysc, NULL)
    IF vi <> NULL THEN
      /* GadTools always requires this STEP TO be taken. */
      gad = CreateContext(@glist)

     /*  * Create Exec LIST of items TO be displayed in listview GADGET **/
     NewList(myList)
     FOR i=1 TO items
       theNode = ALLOC(SIZEOF(Node))
       theNode->ln_Name = @theItems(i)
       dummy = theItems(i)
       IF LEN(dummy) > LEN(longname) THEN
           longname = dummy
       END IF
       AddTail(myList,theNode)
     NEXT
      scrFont = mysc->_Font
      YSize = scrFont->ta_YSize+5
      IText->ITextFont = scrFont
      IText->IText = @longname
      Win_Width = IntuiTextLength(IText)+40
      IF Win_Width > mysc->_Width THEN
          gadFont->ta_Name  = SADD("topaz.font")
          gadFont->ta_YSize = 8
          gadFont->ta_Style = 0
          gadFont->ta_Flags = 0
          scrFont = gadfont
          IText->ITextFont = scrFont
          IText->IText = @longname
          Win_Width = IntuiTextLength(IText) + 40
      END IF

      IText->ITextFont = scrFont
      IText->IText = SADD("Cancel")
      GadgetWidth = IntuiTextLength(IText) + 10
      IF Win_Width < (2 * GadgetWidth) + 40 THEN
          Win_Width = (2 * GadgetWidth) + 40
      END IF

     /*  * Create the listview GADGET initialising with above LIST **/

     ng->ng_LeftEdge = 10
     ng->ng_TopEdge = YSize + 8
     ng->ng_Width = Win_Width - 20
     ng->ng_Height = YSize * 5
     ng->ng_GadgetText = @prompt
     ng->ng_TextAttr = scrFont
     ng->ng_VisualInfo = vi
     ng->ng_GadgetID = GAD_LISTVIEW
     ng->ng_Flags = NULL

     templeft = ng->ng_LeftEdge
     temptop = ng->ng_TopEdge
     tempwidth = ng->ng_Width
     tempheight = ng->ng_Height

     SetUpTags(gadtags,3)
     IF gadTags <> NULL THEN
        tag = gadTags
        SetTag(GTLV_Labels,mylist)
        SetTag(GTLV_ShowSelected,NULL)
        SetTagEnd
     END IF

     gad = CreateGadgetA(LISTVIEW_KIND, gad, ng, gadTags)
     FreeTagItems(gadTags)

     /*  * Create the Ok AND Cancel buttons **/
     ng->ng_LeftEdge    = 10
     ng->ng_TopEdge     = temptop + tempheight + 4
     ng->ng_Width       = GadgetWidth
     ng->ng_Height      = YSize + 2
     ng->ng_GadgetText  = SADD("Ok")
     ng->ng_GadgetID    = GAD_BUTTON_OK
     ng->ng_Flags       = NULL

     templeft = ng->ng_LeftEdge
     temptop = ng->ng_TopEdge
     tempwidth = ng->ng_Width
     tempheight = ng->ng_Height

     gad = CreateGadgetA(BUTTON_KIND,gad,ng,NULL)

     ng->ng_LeftEdge    = 10 + ((Win_Width - 20) - tempwidth)
     ng->ng_TopEdge     = temptop
     ng->ng_Width       = tempwidth
     ng->ng_Height      = tempheight
     ng->ng_GadgetText  = SADD("Cancel")
     ng->ng_GadgetID    = GAD_BUTTON_CANCEL
     ng->ng_Flags       = NULL

     temptop = ng->ng_TopEdge
     tempheight = ng->ng_Height
     gad = CreateGadgetA(BUTTON_KIND,gad,ng,NULL)

     Win_Height = temptop + tempheight + 5

      IDCMP = (IDCMP_CLOSEWINDOW OR IDCMP_GADGETUP OR LISTVIEWIDCMP)

     SetUpTags(wintags,13)
     IF wintags <> NULL THEN
        tag = wintags
        SetTag(WA_Left,mysc->MouseX-(Win_Width/2))
        SetTag(WA_Top,mysc->MouseY-(Win_Height/2))
        SetTag(WA_InnerWidth,Win_Width)
        SetTag(WA_InnerHeight,Win_Height)
        SetTag(WA_Title,@wdwTitle)
        SetTag(WA_CustomScreen,mysc)
        SetTag(WA_Gadgets,glist)
        SetTag(WA_IDCMP,IDCMP)
        SetTag(WA_DragBar,TRUE)
        SetTag(WA_CloseGadget,TRUE)
        SetTag(WA_GimmeZeroZero,TRUE)
        SetTag(WA_Activate,TRUE)
        SetTagEnd
     END IF

     /* OPEN WINDOW, render gadgets AND enter event-handling loop.  */
     IF gad <> NULL THEN

         mywin = OpenWindowTagList(NULL,wintags)
         FreeTagItems(wintags)
         IF mywin <> NULL THEN
          GT_RefreshWindow(mywin,NULL)

          /*  *
          ** Standard MESSAGE handling loop with GadTools MESSAGE
          ** handling functions used (GT_GetIMsg() AND GT_ReplyIMsg()).
          **/
          WHILE NOT terminated
            WaitPort(mywin->UserPort)

            /* Use GT_GetIMsg() AND GT_ReplyIMsg() FOR handling   */
            /* IntuiMessages with GadTools gadgets.               */
            REPEAT
              imsg = GT_GetIMsg(mywin->UserPort)
              class = imsg->Class
              CASE
                /* Buttons AND listviews report GADGETUP.                */
                class = IDCMP_GADGETUP : handle_gadget(imsg, @action)
                /* Has WINDOW CLOSE GADGET been clicked?                 */
                class = IDCMP_CLOSEWINDOW : terminated=true : result=LISTBOX_CANCELLED
                /* This handling is REQUIRED with GadTools.              */
                class = IDCMP_REFRESHWINDOW : do_window_refresh(mywin)
              END CASE

              GT_ReplyIMsg(imsg)

              /* Item selected?     */
              IF action > 0 THEN
                selected = action
              ELSE
                /* Ok BUTTON clicked?   */
                IF action = OK_CLICKED THEN
                  terminated = TRUE
                  result = selected
                ELSE
                  /* Cancel BUTTON clicked?   */
                  IF action = CANCEL_CLICKED THEN
                    terminated = TRUE
                    result = LISTBOX_CANCELLED
                  END IF
                END IF
              END IF
            UNTIL terminated OR imsg = NULL
          WEND

          /* WINDOW CLOSE 1    */
          CloseWindow(mywin)
        ELSE
          result = LISTBOX_CANCELLED
        END IF
     ELSE
       result = LISTBOX_CANCELLED
     END IF

     /* FreeGadgets() must be called after the context has been
        created. It does nothing IF glist is NULL.    */
     FreeGadgets(glist)
     FreeVisualInfo(vi)
    ELSE
      result = LISTBOX_CANCELLED
    END IF
  ELSE
    result = LISTBOX_CANCELLED
  END IF

  /*  RETURN the result.  */
  gadtools_window = result
END SUB

SUB handle_gadget(ADDRESS msg, ADDRESS action)
DECLARE STRUCT IntuiMessage *imsg
DECLARE STRUCT _Gadget *gad
  imsg = msg
  gad = imsg->IAddress
  CASE
    gad->GadgetID = GAD_LISTVIEW : *%action := imsg->Code+1
    gad->GadgetID = GAD_BUTTON_OK : *%action := OK_CLICKED
    gad->GadgetID = GAD_BUTTON_CANCEL : *%action := CANCEL_CLICKED
    default : *%action := UNKNOWN_ACTION
  END CASE
END SUB

SUB do_window_refresh(ADDRESS wdw)
  GT_BeginRefresh(mywin)
  GT_EndRefresh(mywin,TRUE)
END SUB

SUB LONGINT ListBox(ADDRESS listItemArray, \
                    LONGINT items, STRING wdwTitle, STRING prompt) EXTERNAL
/*  *
** Invoke the listbox.
**/
LONGINT result

  LIBRARY "exec.LIBRARY"
  LIBRARY "utility.LIBRARY"
  LIBRARY "intuition.LIBRARY"
  LIBRARY "gadtools.LIBRARY"
  result = gadtools_window(listItemArray, items, wdwTitle, prompt)
  LIBRARY CLOSE
  ListBox = result
END SUB
