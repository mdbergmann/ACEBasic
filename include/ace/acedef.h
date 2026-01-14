#ifndef ACEDEF_H
#define ACEDEF_H 1

/*
** Note: Fixed the tagmacros, they where totaly wrong
**       Sorry about that, I also added some text on
**       how to use the macros.
**       Date: 10/08/95   Nils Sjoholm
**
**
*/
/*   Some useful defines for ACE Basic  */

#ifndef EXEC_TYPES_H		/* These constants are also defined in exec/types.h. */
Const NULL = 0&
Const TRUE = -1&
Const FALSE = 0&
#endif

/*   For drawing boxes and lines    */
#define BOX(x1,y1,x2,y2)  LINE(x1,y1)-(x2,y2),,B
#define BOXF(x1,y1,x2,y2)  LINE(x1,y1)-(x2,y2),,BF
#define DRAWLINE(x1,y1,x2,y2) LINE(x1,y1)-(x2,y2)

/*   Some gadgets defines           */
#define TEXTGADGET(num,status,default,x1,y1,x2,y2)  GADGET num,status,default,(x1,y1)-(x1+x2,y1+y2),BUTTON
#define STRGADGET(num,status,default,x1,y1,x2,y2)   GADGET num,status,default,(x1,y1)-(x1+x2,y1+y2),STRING
#define INTGADGET(num,status,default,x1,y1,x2,y2)   GADGET num,status,default,(x1,y1)-(x1+x2,y1+y2),LONGINT
#define SLIDERXGADGET(num,status,default,x1,y1,x2,y2) GADGET num,status,default,(x1,y1)-(x1+x2,y1+y2),POTX
#define SLIDERYGADGET(num,status,default,x1,y1,x2,y2) GADGET num,status,default,(x1,y1)-(x1+x2,y1+y2),POTY

/*   Some misc defines for windows, printing and drawing  */
#define OPENW(num,titel,x1,y1,x2,y2) WINDOW num,titel,(x1,y1)-(x2,y2)
#define PRINTAT(x,y,text) PENUP : SETXY x,y : PRINT text
#define SETRGB(num,r,g,b) PALETTE num,r/15,g/15,b/15
#define RAYTO(x,y) a= XCOR : b= YCOR : PENDOWN : LINE(a,b)-(x,y): PENUP : SETXY a,b
#define MOVETO(x,y) PENUP : SETXY x,y

#define CHECKMARK SPACE$(CheckPlace)

/* To use this tagmacros do like this
   DECLARE STRUCT TagItem   *tag,  *gadtags
   You mast have tag here gadtags is just an example

   Then do like this

   SetUpTags(gadtags,9)
   IF gadtags <> NULL THEN
      tag = gadtags
      SetTag(SomeTag,sometagdata)
      SetTag(just keep ON going)
      ......
      SetTagEnd
   END IF

   Remember that macros are CASE-sensitive
   Don't forget to DECLARE AllocateTagItems and FreeTagItems
   and free the tags when you don't need them anymore.

   Good luck   Nils Sjoholm

*/

#define SetUpTags(tagname,num) tagname = AllocateTagItems(num)
#define SetTag(tagvalue,tagdata) tag->ti_Tag = tagvalue \
: tag->ti_Data = tagdata \
: tag = tag + SIZEOF(TagItem)

#define SetTagEnd tag->ti_Tag = TAG_DONE

#endif

