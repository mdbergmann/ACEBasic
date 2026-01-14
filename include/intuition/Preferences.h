#ifndef INTUITION_PREFERENCES_H
#define INTUITION_PREFERENCES_H TRUE
/*
** preferences.h for ACE Basic
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
** This are the StructPointer defines for preferences.h
*/
#ifndef PreferencesPtr
#define PreferencesPtr ADDRESS
#endif
/*
** End of StructPointer defines for preferences.h
*/


#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef DEVICES_TIMER_H
#include <devices/timer.h>
#endif

/* ======================================================================== */
/* === Preferences ======================================================== */
/* ======================================================================== */

/* these are the definitions for the printer configurations */
#define FILENAME_SIZE   30      /* Filename size */
#define DEVNAME_SIZE    16      /* Device-name size */

#define POINTERSIZE (1 + 16 + 1) * 2    /* Size of Pointer data buffer */

/* These defines are for the default font size.  These actually describe the
 * height of the defaults fonts.  The default font type is the topaz
 * font,  which is a fixed width font that can be used in either
 * eighty-column or sixty-column mode.  The Preferences structure reflects
 * which is currently selected by the value found in the variable FontSize, 
 * which may have either of the values defined below.  These values actually
 * are used to select the height of the default font.  By changing the
 * height,  the resolution of the font changes as well.
 */
#define TOPAZ_EIGHTY 8
#define TOPAZ_SIXTY 9

/* Note:  Starting with V36,  and continuing with each new version of
 * Intuition,  an increasing number of fields of STRUCT Preferences
 * are ignored by SetPrefs().  (Some fields are obeyed only at the
 * initial SetPrefs(),  which comes from the devs:system-configuration
 * file).  Elements are generally superseded as new hardware or software
 * features demand more information than fits in STRUCT Preferences.
 * Parts of STRUCT Preferences must be ignored so that applications
 * calling GetPrefs(),  modifying some other part of STRUCT Preferences, 
 * then calling SetPrefs(),  don't end up truncating the extended
 * data.
 *
 * Consult the autodocs for SetPrefs() for further information as
 * to which fields are not always respected.
 */

STRUCT Preferences
 
    /* the default font height */
    BYTE FontHeight                     /* height for system default font  */

    /* constant describing what's hooked up to the port */
    BYTE  PrinterPort                   /* printer port connection         */

    /* the baud rate of the port */
    SHORTINT BaudRate                      /* baud rate for the serial port   */

    /* various timing rates */
    timeval KeyRptSpeed          /* repeat speed for keyboard       */
    timeval KeyRptDelay          /* Delay before keys repeat        */
    timeval DoubleClick          /* Interval allowed between clicks */

    /* Intuition Pointer data */
    STRING PointerMatrix SIZE 72  /*  POINTERSIZE*SIZEOF(SHORTINT) */   /* Definition of pointer sprite    */
    BYTE XOffset                        /* X-Offset for active 'bit'       */
    BYTE YOffset                        /* Y-Offset for active 'bit'       */
    SHORTINT color17                       /***********************************/
    SHORTINT color18                       /* Colours for sprite pointer      */
    SHORTINT color19                       /***********************************/
    SHORTINT PointerTicks                  /* Sensitivity of the pointer      */

    /* Workbench Screen colors */
    SHORTINT color0                        /***********************************/
    SHORTINT color1                        /*  Standard default colours       */
    SHORTINT color2                        /*   Used in the Workbench         */
    SHORTINT color3                        /***********************************/

    /* positioning data for the Intuition View */
    BYTE ViewXOffset                    /* Offset for top lefthand corner  */
    BYTE ViewYOffset                    /* X and Y dimensions              */
    SHORTINT ViewInitX 
    SHORTINT   ViewInitY           /* View initial offset values      */

    SHORTINT EnableCLI                      /* CLI availability switch */

    /* printer configurations */
    SHORTINT PrinterType                   /* printer type            */
    STRING PrinterFilename SIZE 30  /*  FILENAME_SIZE */ /* file FOR printer       */

    /* print format and quality configurations */
    SHORTINT PrintPitch                    /* print pitch                     */
    SHORTINT PrintQuality                  /* print quality                   */
    SHORTINT PrintSpacing                  /* number of lines per inch        */
    SHORTINT PrintLeftMargin               /* left margin in characters       */
    SHORTINT PrintRightMargin              /* right margin in characters      */
    SHORTINT PrintImage                    /* positive or negative            */
    SHORTINT PrintAspect                   /* horizontal or vertical          */
    SHORTINT PrintShade                    /* b&w,  half-tone,  or color        */
    SHORTINT PrintThreshold                 /* darkness ctrl for b/w dumps     */

    /* print paper descriptors */
    SHORTINT PaperSize                     /* paper size                      */
    SHORTINT PaperLength                   /* paper length in number of lines */
    SHORTINT PaperType                     /* continuous or single sheet      */

    /* Serial device settings: These are six nibble-fields in three bytes */
    /* (these look a little strange so the defaults will map out to zero) */
    BYTE    SerRWBits    /* upper nibble = (8-number of read bits)      */
                         /* lower nibble = (8-number of write bits)     */
    BYTE    SerStopBuf   /* upper nibble = (number of stop bits - 1)    */
                         /* lower nibble = (table value for BufSize)    */
    BYTE    SerParShk    /* upper nibble = (value for Parity setting)   */
                         /* lower nibble = (value for Handshake mode)   */
    BYTE    LaceWB       /* if workbench is to be interlaced            */

    STRING Pad SIZE 12  
    STRING PrtDevName SIZE 16  /*  DEVNAME_SIZE  */   /* device used by printer.device
                                         * (omit the ".device")
                                         */
    BYTE    DefaultPrtUnit      /* default unit opened by printer.device */
    BYTE    DefaultSerUnit      /* default serial unit */

    BYTE    RowSizeChange       /* affect NormalDisplayRows/Columns     */
    BYTE    ColumnSizeChange 

    SHORTINT    PrintFlags         /* user preference flags */
    SHORTINT    PrintMaxWidth      /* max width of printed picture in 10ths/in */
    SHORTINT    PrintMaxHeight     /* max height of printed picture in 10ths/in */
    BYTE     PrintDensity       /* print density */
    BYTE     PrintXOffset       /* offset of printed picture in 10ths/inch */

    SHORTINT    wb_Width           /* override default workbench width  */
    SHORTINT    wb_Height          /* override default workbench height */
    BYTE     wb_Depth           /* override default workbench depth  */

    BYTE     ext_size           /* extension information -- do not touch! */
                            /* extension size in blocks of 64 bytes */
END STRUCT 


/* Workbench Interlace (use one bit) */
#define LACEWB                  (&H1)
#define LW_RESERVED     1               /* internal use only */

/* Enable_CLI   */
#define SCREEN_DRAG     (&H4000)
#define MOUSE_ACCEL     (&H8000&)

/* PrinterPort */
#define PARALLEL_PRINTER &H00
#define SERIAL_PRINTER  &H01

/* BaudRate */
#define BAUD_110        &H00
#define BAUD_300        &H01
#define BAUD_1200       &H02
#define BAUD_2400       &H03
#define BAUD_4800       &H04
#define BAUD_9600       &H05
#define BAUD_19200      &H06
#define BAUD_MIDI       &H07

/* PaperType */
#define FANFOLD &H00
#define SINGLE          &H80

/* PrintPitch */
#define PICA            &H000
#define ELITE           &H400
#define FINE            &H800

/* PrintQuality */
#define DRAFT           &H000
#define LETTER          &H100

/* PrintSpacing */
#define SIX_LPI         &H000
#define EIGHT_LPI       &H200

/* Print Image */
#define IMAGE_POSITIVE  &H00
#define IMAGE_NEGATIVE  &H01

/* PrintAspect */
#define ASPECT_HORIZ    &H00
#define ASPECT_VERT     &H01

/* PrintShade */
#define SHADE_BW        &H00
#define SHADE_GREYSCALE &H01
#define SHADE_COLOR     &H02

/* PaperSize (all paper sizes have a zero in the lowest nybble) */
#define US_LETTER       &H00
#define US_LEGAL        &H10
#define N_TRACTOR       &H20
#define W_TRACTOR       &H30
#define CUSTOM          &H40

/* New PaperSizes for V36: */
#define EURO_A0 &H50            /* European size A0: 841 x 1189 */
#define EURO_A1 &H60            /* European size A1: 594 x 841 */
#define EURO_A2 &H70            /* European size A2: 420 x 594 */
#define EURO_A3 &H80            /* European size A3: 297 x 420 */
#define EURO_A4 &H90            /* European size A4: 210 x 297 */
#define EURO_A5 &HA0            /* European size A5: 148 x 210 */
#define EURO_A6 &HB0            /* European size A6: 105 x 148 */
#define EURO_A7 &HC0            /* European size A7: 74 x 105 */
#define EURO_A8 &HD0            /* European size A8: 52 x 74 */


/* PrinterType */
#define CUSTOM_NAME             &H00
#define ALPHA_P_101             &H01
#define BROTHER_15XL            &H02
#define CBM_MPS1000             &H03
#define DIAB_630                &H04
#define DIAB_ADV_D25            &H05
#define DIAB_C_150              &H06
#define EPSON                   &H07
#define EPSON_JX_80             &H08
#define OKIMATE_20              &H09
#define QUME_LP_20              &H0A
/* new printer entries,  3 October 1985 */
#define HP_LASERJET             &H0B
#define HP_LASERJET_PLUS        &H0C

/* Serial Input Buffer Sizes */
#define SBUF_512        &H00
#define SBUF_1024       &H01
#define SBUF_2048       &H02
#define SBUF_4096       &H03
#define SBUF_8000       &H04
#define SBUF_16000      &H05

/* Serial Bit Masks */
#define SREAD_BITS      &HF0 /* for SerRWBits   */
#define SWRITE_BITS     &H0F

#define SSTOP_BITS      &HF0 /* for SerStopBuf  */
#define SBUFSIZE_BITS   &H0F

#define SPARITY_BITS    &HF0 /* for SerParShk   */
#define SHSHAKE_BITS    &H0F

/* Serial Parity (upper nibble,  after being shifted by
 * macro SPARNUM() )
 */
#define SPARITY_NONE     0
#define SPARITY_EVEN     1
#define SPARITY_ODD      2
/* New parity definitions for V36: */
#define SPARITY_MARK     3
#define SPARITY_SPACE    4

/* Serial Handshake Mode (lower nibble,  after masking using
 * macro SHANKNUM() )
 */
#define SHSHAKE_XON      0
#define SHSHAKE_RTS      1
#define SHSHAKE_NONE     2

/* new defines for PrintFlags */

#define CORRECT_RED         &H0001  /* color correct red shades */
#define CORRECT_GREEN       &H0002  /* color correct green shades */
#define CORRECT_BLUE        &H0004  /* color correct blue shades */

#define CENTER_IMAGE        &H0008  /* center image on paper */

#define IGNORE_DIMENSIONS   &H0000 /* ignore max width/height settings */
#define BOUNDED_DIMENSIONS  &H0010  /* use max width/height as boundaries */
#define ABSOLUTE_DIMENSIONS &H0020  /* use max width/height as absolutes */
#define PIXEL_DIMENSIONS    &H0040  /* use max width/height as prt pixels */
#define MULTIPLY_DIMENSIONS &H0080 /* use max width/height as multipliers */

#define INTEGER_SCALING     &H0100  /* force integer scaling */

#define ORDERED_DITHERING   &H0000 /* ordered dithering */
#define HALFTONE_DITHERING  &H0200  /* halftone dithering */
#define FLOYD_DITHERING     &H0400 /* Floyd-Steinberg dithering */

#define ANTI_ALIAS          &H0800 /* anti-alias image */
#define GREY_SCALE2         &H1000 /* for use with hi-res monitor */

/* masks used for checking bits */

#define CORRECT_RGB_MASK    (CORRECT_RED OR CORRECT_GREEN OR CORRECT_BLUE)
#define DIMENSIONS_MASK     (BOUNDED_DIMENSIONS OR ABSOLUTE_DIMENSIONS OR PIXEL_DIMENSIONS OR MULTIPLY_DIMENSIONS)
#define DITHERING_MASK      (HALFTONE_DITHERING OR FLOYD_DITHERING)

#endif
