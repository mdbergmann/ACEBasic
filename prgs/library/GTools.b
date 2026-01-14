/*
** An example of GadTools library usage.
**
** Adapted from RKM: Libraries (1992), p 383-385 
** and NDK example gadget1.c, by David Benn, 
** 18th March, 3rd April, 7th,8th June, 7th October 1995.
**
** Changed the IDCMP flags, they where the old ones
** Also changed to use the functions headers.
** Finaly I changed the tags to use my tagmacros.
** Date 15-Oct-95      Nils Sjoholm
**
*/

#include <libraries/gadtools.h>
#include <ace/acedef.h>

/* Now we need some functions */
#include <funcs/intuition_funcs.h>
#include <funcs/gadtools_funcs.h>
#include <funcs/utility_funcs.h>
#include <funcs/exec_funcs.h>

/*
** Constant definitions.
*/
CONST GAD_SLIDER = 1
CONST GAD_STRING = 2
CONST GAD_BUTTON = 3

/* Range for the slider */

CONST SLIDER_MIN = 1
CONST SLIDER_MAX = 20

/*
** Forward SUB declarations.
*/
DECLARE SUB process_window_events(ADDRESS wdw)
DECLARE SUB gadtools_window
DECLARE SUB handle_gadget(ADDRESS msg)
DECLARE SUB do_window_refresh(ADDRESS wdw)

/*
** Shared library function declarations.
*/
LIBRARY "exec.library"
LIBRARY "utility.library"
LIBRARY "intuition.library"
LIBRARY "gadtools.library"

/*
** Global variables.
*/
DECLARE STRUCT TextAttr gadFont
gadFont->ta_Name  = SADD("topaz.font")
gadFont->ta_YSize = 8
gadFont->ta_Style = 0
gadFont->ta_Flags = 0

SHORTINT slider_level : slider_level = 5

/*
** Subprogram definitions.
*/
SUB gadtools_window
/*
** Prepare for using GadTools, set up gadgets
** and open window.
*/
SHARED slider_level, gadFont

DECLARE STRUCT _Screen *mysc
DECLARE STRUCT TextAttr *scrFont
DECLARE STRUCT _Window *mywin
DECLARE STRUCT _Gadget *glist, *gad
DECLARE STRUCT NewGadget ng
DECLARE STRUCT TagItem *gadTags, *tag
DIM ADDRESS radioButtonStrings(3)
ADDRESS vi

  glist = NULL
  
  mysc = SCREEN(1)
  IF mysc <> NULL THEN
    vi = GetVisualInfoA(mysc, NULL)
    IF vi <> NULL THEN
      /*  GadTools always requires this step to be taken. */
      gad = CreateContext(@glist)

    /* All the gadget creation calls accept a pointer to the previous
     * gadget, and link the new gadget to that gadget's NextGadget field.
     * Also, they exit gracefully, returning NULL, if any previous gadget
     * was NULL.  This limits the amount of checking for failure that
     * is needed.  You only need to check before you tweak any gadget
     * structure or use any of its fields, and finally once at the end,
     * before you add the gadgets. */

    ng->ng_LeftEdge = 100
    ng->ng_TopEdge = 20
    ng->ng_Width = 200
    ng->ng_Height = 12
    ng->ng_GadgetText = SADD("Speed:   ")
    ng->ng_TextAttr = gadFont
    ng->ng_VisualInfo = vi
    ng->ng_GadgetID = GAD_SLIDER

    SetUpTags(gadTags,6)
    IF gadTags <> NULL THEN
        tag = gadTags
        SetTag(GTSL_Min,SLIDER_MIN)
        SetTag(GTSL_Max,SLIDER_MAX)
        SetTag(GTSL_Level,slider_level)
        SetTag(GTSL_LevelFormat,SADD("%2ld"))
        SetTag(GTSL_MaxLevelLen,2)
        SetTagEnd
      END IF
      gad = CreateGadgetA(SLIDER_KIND, gad, ng, gadTags)
      slidergad = gad
      FreeTagItems(gadTags) 

    ng->ng_TopEdge = 40+topborder
    ng->ng_Height = 14
    ng->ng_GadgetText = SADD("Type Here:")
    ng->ng_GadgetID = GAD_STRING

    SetUpTags(GadTags,3)
    IF gadTags <> NULL THEN
       tag = gadTags
       SetTag(GTST_String,SADD("Hello World!"))
       SetTag(GTST_MaxChars,50)
       SetTagEnd
    END IF
    gad = CreateGadgetA(STRING_KIND, gad, ng, gadTags)
    FreeTagItems(gadTags)

    ng->ng_LeftEdge = ng->ng_LeftEdge + 50
    ng->ng_TopEdge = 60+topborder
    ng->ng_Width = 100
    ng->ng_Height = 12
    ng->ng_GadgetText = SADD("Click Here")
    ng->ng_GadgetID = GAD_BUTTON
    ng->ng_Flags = NULL
    gad = CreateGadgetA(BUTTON_KIND, gad, ng, NULL)
      
      /*  Open window, render gadgets and enter event-handling loop. */ 
      IF gad <> NULL THEN
    WINDOW 1,"GadTools Gadget Demo",(0,0)-(400,100),30
    IF ERR = 0 THEN
      mywin = WINDOW(7)

      ModifyIDCMP(mywin, mywin->IDCMPFlags OR SLIDERIDCMP)

      AddGList(mywin,glist,0,-1,NULL)
      RefreshGadgets(glist,mywin,NULL)
      GT_RefreshWindow(mywin,NULL)
      process_window_events(mywin)
      WINDOW CLOSE 1
        END IF
      END IF
    
      /*  FreeGadgets() must be called after the context has been
          created. It does nothing if glist is NULL. */
      FreeGadgets(glist)
      FreeVisualInfo(vi)
    END IF        
  END IF
END SUB

SUB process_window_events(ADDRESS mywinaddr)
/*
** Standard message handling loop with GadTools message
** handling functions used (GT_GetIMsg() and GT_ReplyIMsg()).
*/
DECLARE STRUCT _Window *mywin : mywin = mywinaddr
DECLARE STRUCT IntuiMessage *imsg
DECLARE STRUCT _Gadget *gad
LONGINT terminated, class

  WHILE NOT terminated
    WaitPort(mywin->UserPort)

    /*  Use GT_GetIMsg() and GT_ReplyIMsg() for handling
        IntuiMessages with GadTools gadgets. */
    REPEAT
      imsg = GT_GetIMsg(mywin->UserPort)
      class = imsg->Class
      CASE
    /*  BUTTON, STRING GADGET, slider? (IDCMP_MOUSEMOVE used FOR slider here;
        results in more messages; could use IDCMP_GADGETUP/DOWN but need
        GA_RelVerify/GA_Immediate - see scroller.b example program). */
    class = IDCMP_GADGETUP OR class = IDCMP_GADGETDOWN OR ~
    class = IDCMP_MOUSEMOVE : handle_gadget(imsg)
        /*  Has window close gadget been clicked? */
    class = IDCMP_CLOSEWINDOW : terminated = TRUE
        /*  This handling is REQUIRED with GadTools. */
    class = IDCMP_REFRESHWINDOW : do_window_refresh(mywin)
      END CASE
      GT_ReplyIMsg(imsg)          
    UNTIL terminated OR imsg = NULL
  WEND
END SUB

SUB handle_gadget(ADDRESS msg)
DECLARE STRUCT IntuiMessage *imsg
DECLARE STRUCT _Gadget *gad
DECLARE STRUCT StringInfo *info
  imsg = msg
  gad = imsg->IAddress
  info = gad->SpecialInfo
  CASE 
    gad->GadgetID = GAD_SLIDER : MsgBox "Speed: "+STR$(imsg->Code),"OK"
    gad->GadgetID = GAD_STRING : MsgBox CSTR(info->Buffer),"OK"
    gad->GadgetID = GAD_BUTTON : BEEP
  END CASE
END SUB

SUB do_window_refresh(ADDRESS wdw)
  GT_BeginRefresh(mywin)
  GT_EndRefresh(mywin,true)
END SUB

/*
** Main program.
*/
gadtools_window
LIBRARY CLOSE
END
