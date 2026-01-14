#ifndef LIBRARIES_LOWLEVEL_H
#define LIBRARIES_LOWLEVEL_H
/*
** lowlevel.h for ACE Basic
**
** Note: Translated to ACE by ConvertC2ACE
**       @ MapMeadow Software, Nils Sjoholm
**
**
** Date: 09/01/95
**
**
*/

/*
** This are the StructPointer defines for lowlevel.h
*/
#ifndef KeyQueryPtr
#define KeyQueryPtr ADDRESS
#endif
/*
** End of StructPointer defines for lowlevel.h
*/



/*****************************************************************************/


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif


/*****************************************************************************/


/* structure for use with QueryKeys() */
STRUCT KeyQuery
 
    SHORTINT kq_KeyCode 
    SHORTINT  kq_Pressed 
END STRUCT 


/*****************************************************************************/


/* bits in the return value of GetKey() */
#define LLKB_LSHIFT 16
#define LLKB_RSHIFT 17
#define LLKB_CAPSLOCK   18
#define LLKB_CONTROL    19
#define LLKB_LALT   20
#define LLKB_RALT   21
#define LLKB_LAMIGA 22
#define LLKB_RAMIGA 23

#define LLKF_LSHIFT (65536)
#define LLKF_RSHIFT (131072)
#define LLKF_CAPSLOCK   (262144)
#define LLKF_CONTROL    (524288)
#define LLKF_LALT   (1048576)
#define LLKF_RALT   (2097152)
#define LLKF_LAMIGA (4194304)
#define LLKF_RAMIGA (8388608)


/*****************************************************************************/


/* Tags for SetJoyPortAttrs() */
#define SJA_Dummy    (TAG_USER+&Hc00100)
#define SJA_Type     (SJA_Dummy+1) /* force type to mouse,  joy,  game cntrlr */
#define SJA_Reinitialize (SJA_Dummy+2) /* free potgo bits,  reset to autosense   */

/* Controller types for SJA_Type tag */
#define SJA_TYPE_AUTOSENSE 0
#define SJA_TYPE_GAMECTLR  1
#define SJA_TYPE_MOUSE     2
#define SJA_TYPE_JOYSTK    3


/*****************************************************************************/


/* ReadJoyPort() return value definitions */

/* Port types */
#define JP_TYPE_NOTAVAIL  (0)    /* port DATA unavailable    */
#define JP_TYPE_GAMECTLR  (268435456)    /* port has game controller */
#define JP_TYPE_MOUSE     (536870912)    /* port has mouse       */
#define JP_TYPE_JOYSTK    (805306368)    /* port has joystick        */
#define JP_TYPE_UNKNOWN   (1073741824)    /* port has unknown device  */
#define JP_TYPE_MASK      (-268435456)    /* controller type          */

/* Button types,  valid for all types except JP_TYPE_NOTAVAIL */
#define JPB_BUTTON_BLUE    23     /* Blue - Stop  Right Mouse            */
#define JPB_BUTTON_RED     22     /* Red - Select  Left Mouse  Joystick Fire */
#define JPB_BUTTON_YELLOW  21     /* Yellow - Repeat                 */
#define JPB_BUTTON_GREEN   20     /* Green - Shuffle                 */
#define JPB_BUTTON_FORWARD 19     /* Charcoal - Forward          */
#define JPB_BUTTON_REVERSE 18     /* Charcoal - Reverse          */
#define JPB_BUTTON_PLAY    17     /* Grey - Play/Pause  Middle Mouse         */
#define JPF_BUTTON_BLUE    (8388608)
#define JPF_BUTTON_RED     (4194304)
#define JPF_BUTTON_YELLOW  (2097152)
#define JPF_BUTTON_GREEN   (1048576)
#define JPF_BUTTON_FORWARD (524288)
#define JPF_BUTTON_REVERSE (262144)
#define JPF_BUTTON_PLAY    (131072)
#define JP_BUTTON_MASK     (JPF_BUTTON_BLUE OR JPF_BUTTON_RED OR JPF_BUTTON_YELLOW OR \
 JPF_BUTTON_GREEN OR JPF_BUTTON_FORWARD OR JPF_BUTTON_REVERSE OR JPF_BUTTON_PLAY)

/* Direction types,  valid for JP_TYPE_GAMECTLR and JP_TYPE_JOYSTK */
#define JPB_JOY_UP    3
#define JPB_JOY_DOWN      2
#define JPB_JOY_LEFT      1
#define JPB_JOY_RIGHT     0
#define JPF_JOY_UP    (8)
#define JPF_JOY_DOWN      (4)
#define JPF_JOY_LEFT      (2)
#define JPF_JOY_RIGHT     (1)
#define JP_DIRECTION_MASK (JPF_JOY_UP OR JPF_JOY_DOWN OR JPF_JOY_LEFT OR JPF_JOY_RIGHT)

/* Mouse position reports,  valid for JP_TYPE_MOUSE */
#define JP_MHORZ_MASK   (255)    /* horzizontal position */
#define JP_MVERT_MASK   (65280)    /* vertical position    */
#define JP_MOUSE_MASK   (JP_MHORZ_MASK OR JP_MVERT_MASK)

/* Obsolete ReadJoyPort() definitions,  here for source code compatibility only.
 * Please do NOT use in new code.
 */
#define JPB_BTN1  JPB_BUTTON_BLUE
#define JPF_BTN1  JPF_BUTTON_BLUE
#define JPB_BTN2  JPB_BUTTON_RED
#define JPF_BTN2  JPF_BUTTON_RED
#define JPB_BTN3  JPB_BUTTON_YELLOW
#define JPF_BTN3  JPF_BUTTON_YELLOW
#define JPB_BTN4  JPB_BUTTON_GREEN
#define JPF_BTN4  JPF_BUTTON_GREEN
#define JPB_BTN5  JPB_BUTTON_FORWARD
#define JPF_BTN5  JPF_BUTTON_FORWARD
#define JPB_BTN6  JPB_BUTTON_REVERSE
#define JPF_BTN6  JPF_BUTTON_REVERSE
#define JPB_BTN7  JPB_BUTTON_PLAY
#define JPF_BTN7  JPF_BUTTON_PLAY
#define JPB_UP    JPB_JOY_UP
#define JPF_UP    JPF_JOY_UP
#define JPB_DOWN  JPB_JOY_DOWN
#define JPF_DOWN  JPF_JOY_DOWN
#define JPB_LEFT  JPB_JOY_LEFT
#define JPF_LEFT  JPF_JOY_LEFT
#define JPB_RIGHT JPB_JOY_RIGHT
#define JPF_RIGHT JPF_JOY_RIGHT


/*****************************************************************************/


/* Tags for SystemControl() */
#define SCON_Dummy     (TAG_USER+&H00C00000)
#define SCON_TakeOverSys   (SCON_Dummy+0)
#define SCON_KillReq       (SCON_Dummy+1)
#define SCON_CDReboot      (SCON_Dummy+2)
#define SCON_StopInput     (SCON_Dummy+3)
#define SCON_AddCreateKeys (SCON_Dummy+4)
#define SCON_RemCreateKeys (SCON_Dummy+5)

/* Reboot control values for use with SCON_CDReboot tag */
#define CDReboot_On     1
#define CDReboot_Off        0
#define CDReboot_Default    2


/*****************************************************************************/


/* Rawkey codes returned when using SCON_AddCreateKeys with SystemControl() */

#define RAWKEY_PORT0_BUTTON_BLUE    &H72
#define RAWKEY_PORT0_BUTTON_RED &H78
#define RAWKEY_PORT0_BUTTON_YELLOW  &H77
#define RAWKEY_PORT0_BUTTON_GREEN   &H76
#define RAWKEY_PORT0_BUTTON_FORWARD &H75
#define RAWKEY_PORT0_BUTTON_REVERSE &H74
#define RAWKEY_PORT0_BUTTON_PLAY    &H73
#define RAWKEY_PORT0_JOY_UP     &H79
#define RAWKEY_PORT0_JOY_DOWN       &H7A
#define RAWKEY_PORT0_JOY_LEFT       &H7C
#define RAWKEY_PORT0_JOY_RIGHT      &H7B

#define RAWKEY_PORT1_BUTTON_BLUE    &H172
#define RAWKEY_PORT1_BUTTON_RED &H178
#define RAWKEY_PORT1_BUTTON_YELLOW  &H177
#define RAWKEY_PORT1_BUTTON_GREEN   &H176
#define RAWKEY_PORT1_BUTTON_FORWARD &H175
#define RAWKEY_PORT1_BUTTON_REVERSE &H174
#define RAWKEY_PORT1_BUTTON_PLAY    &H173
#define RAWKEY_PORT1_JOY_UP     &H179
#define RAWKEY_PORT1_JOY_DOWN       &H17A
#define RAWKEY_PORT1_JOY_LEFT       &H17C
#define RAWKEY_PORT1_JOY_RIGHT      &H17B

#define RAWKEY_PORT2_BUTTON_BLUE    &H272
#define RAWKEY_PORT2_BUTTON_RED &H278
#define RAWKEY_PORT2_BUTTON_YELLOW  &H277
#define RAWKEY_PORT2_BUTTON_GREEN   &H276
#define RAWKEY_PORT2_BUTTON_FORWARD &H275
#define RAWKEY_PORT2_BUTTON_REVERSE &H274
#define RAWKEY_PORT2_BUTTON_PLAY    &H273
#define RAWKEY_PORT2_JOY_UP     &H279
#define RAWKEY_PORT2_JOY_DOWN       &H27A
#define RAWKEY_PORT2_JOY_LEFT       &H27C
#define RAWKEY_PORT2_JOY_RIGHT      &H27B

#define RAWKEY_PORT3_BUTTON_BLUE    &H372
#define RAWKEY_PORT3_BUTTON_RED &H378
#define RAWKEY_PORT3_BUTTON_YELLOW  &H377
#define RAWKEY_PORT3_BUTTON_GREEN   &H376
#define RAWKEY_PORT3_BUTTON_FORWARD &H375
#define RAWKEY_PORT3_BUTTON_REVERSE &H374
#define RAWKEY_PORT3_BUTTON_PLAY    &H373
#define RAWKEY_PORT3_JOY_UP     &H379
#define RAWKEY_PORT3_JOY_DOWN       &H37A
#define RAWKEY_PORT3_JOY_LEFT       &H37C
#define RAWKEY_PORT3_JOY_RIGHT      &H37B


/*****************************************************************************/


/* Return values for GetLanguageSelection() */
#define LANG_UNKNOWN    0
#define LANG_AMERICAN   1   /* American English */
#define LANG_ENGLISH    2   /* British English  */
#define LANG_GERMAN 3
#define LANG_FRENCH 4
#define LANG_SPANISH    5
#define LANG_ITALIAN    6
#define LANG_PORTUGUESE 7
#define LANG_DANISH 8
#define LANG_DUTCH  9
#define LANG_NORWEGIAN  10
#define LANG_FINNISH    11
#define LANG_SWEDISH    12
#define LANG_JAPANESE   13
#define LANG_CHINESE    14
#define LANG_ARABIC 15
#define LANG_GREEK  16
#define LANG_HEBREW 17
#define LANG_KOREAN 18


/*****************************************************************************/


#endif /* LIBRARIES_LOWLEVEL_H */
