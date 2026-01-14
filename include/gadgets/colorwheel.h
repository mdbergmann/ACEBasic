#ifndef GADGETS_COLORWHEEL_H
#define GADGETS_COLORWHEEL_H 1
/*
** colorwheel.h for ACE Basic
**
** Note: Translated to ACE by ConvertC2ACE
**       @ MapMeadow Software, Nils Sjoholm
**
**
** Date: 09/03/95
**
**
*/

/*
** This are the StructPointer defines for colorwheel.h
*/
#ifndef ColorWheelHSBPtr
#define ColorWheelHSBPtr ADDRESS
#endif
#ifndef ColorWheelRGBPtr
#define ColorWheelRGBPtr ADDRESS
#endif
/*
** End of StructPointer defines for colorwheel.h
*/
      
/*****************************************************************************/


#ifndef UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif



/*****************************************************************************/


/* For use with the WHEEL_HSB tag */
STRUCT ColorWheelHSB
 
    LONGINT cw_Hue 
    LONGINT cw_Saturation 
    LONGINT cw_Brightness 
END STRUCT 

/* For use with the WHEEL_RGB tag */
STRUCT ColorWheelRGB
 
    LONGINT cw_Red 
    LONGINT cw_Green 
    LONGINT cw_Blue 
END STRUCT 


/*****************************************************************************/


#define WHEEL_Dummy      (TAG_USER+&H04000000)
#define WHEEL_Hue        (WHEEL_Dummy+1)   /* set/get Hue          */
#define WHEEL_Saturation     (WHEEL_Dummy+2)   /* set/get Saturation        */
#define WHEEL_Brightness     (WHEEL_Dummy+3)   /* set/get Brightness        */
#define WHEEL_HSB        (WHEEL_Dummy+4)   /* set/get ColorWheelHSB     */
#define WHEEL_Red        (WHEEL_Dummy+5)   /* set/get Red           */
#define WHEEL_Green      (WHEEL_Dummy+6)   /* set/get Green     */
#define WHEEL_Blue       (WHEEL_Dummy+7)   /* set/get Blue          */
#define WHEEL_RGB        (WHEEL_Dummy+8)   /* set/get ColorWheelRGB     */
#define WHEEL_Screen         (WHEEL_Dummy+9)   /* init screen/enviroment    */
#define WHEEL_Abbrv      (WHEEL_Dummy+10)  /* "GCBMRY" if English       */
#define WHEEL_Donation       (WHEEL_Dummy+11)  /* colors donated by app     */
#define WHEEL_BevelBox       (WHEEL_Dummy+12)  /* inside a bevel box        */
#define WHEEL_GradientSlider (WHEEL_Dummy+13)  /* attached gradient slider  */
#define WHEEL_MaxPens        (WHEEL_Dummy+14)  /* max # of pens to allocate */


/*****************************************************************************/


#endif /* GADGETS_COLORWHEEL_H */
