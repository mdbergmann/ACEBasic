#ifndef GRAPHICS_MODEID_H
#define GRAPHICS_MODEID_H 1
/*
** modeid.h for ACE Basic
**
** Note: Translated to ACE by ConvertC2ACE
**       @ MapMeadow Software, Nils Sjoholm
**
**
** Date: 09/01/95
**
**
*/


#ifndef GRAPHICS_DISPLAYINFO_H
#include <graphics/displayinfo.h>
#endif

#define INVALID_ID          -1&

/* With all the new modes that are available under V38 and V39,  it is highly
 * recommended that you use either the asl.library screenmode requester, 
 * and/or the V39 graphics.library function BestModeIDA().
 *
 * DO NOT interpret the any of the bits in the ModeID for its meaning. For
 * example,  do not interpret bit 3 (&H4) as meaning the ModeID is interlaced.
 * Instead,  use GetDisplayInfoData() with DTAG_DISP,  and examine the DIPF_...
 * flags to determine a ModeID's characteristics. The only exception to
 * this rule is that bit 7 (&H80) will always mean the ModeID is
 * ExtraHalfBright,  and bit 11 (&H800) will always mean the ModeID is HAM.
 */

/* normal identifiers */

#define MONITOR_ID_MASK         &HFFFF1000

#define DEFAULT_MONITOR_ID      &H00000000
#define NTSC_MONITOR_ID         &H00011000
#define PAL_MONITOR_ID          &H00021000

/* the following 22 composite keys are for Modes on the default Monitor.
 * NTSC & PAL "flavors" of these particular keys may be made by or'ing
 * the NTSC or PAL MONITOR_ID with the desired MODE_KEY...
 *
 * For example,  to specifically open a PAL HAM interlaced ViewPort
 * (or intuition screen),  you would use the modeid of
 * (PAL_MONITOR_ID OR HAMLACE_KEY)
 */

#define LORES_KEY           &H00000000
#define HIRES_KEY           &H00008000
#define SUPER_KEY           &H00008020
#define HAM_KEY             &H00000800
#define LORESLACE_KEY           &H00000004
#define HIRESLACE_KEY           &H00008004
#define SUPERLACE_KEY           &H00008024
#define HAMLACE_KEY         &H00000804
#define LORESDPF_KEY            &H00000400
#define HIRESDPF_KEY            &H00008400
#define SUPERDPF_KEY            &H00008420
#define LORESLACEDPF_KEY        &H00000404
#define HIRESLACEDPF_KEY        &H00008404
#define SUPERLACEDPF_KEY        &H00008424
#define LORESDPF2_KEY           &H00000440
#define HIRESDPF2_KEY           &H00008440
#define SUPERDPF2_KEY           &H00008460
#define LORESLACEDPF2_KEY       &H00000444
#define HIRESLACEDPF2_KEY       &H00008444
#define SUPERLACEDPF2_KEY       &H00008464
#define EXTRAHALFBRITE_KEY      &H00000080
#define EXTRAHALFBRITELACE_KEY      &H00000084
/* New for AA ChipSet (V39) */
#define HIRESHAM_KEY            &H00008800
#define SUPERHAM_KEY            &H00008820
#define HIRESEHB_KEY            &H00008080
#define SUPEREHB_KEY            &H000080a0
#define HIRESHAMLACE_KEY        &H00008804
#define SUPERHAMLACE_KEY        &H00008824
#define HIRESEHBLACE_KEY        &H00008084
#define SUPEREHBLACE_KEY        &H000080a4
/* Added for V40 - may be useful modes for some games or animations. */
#define LORESSDBL_KEY           &H00000008
#define LORESHAMSDBL_KEY        &H00000808
#define LORESEHBSDBL_KEY        &H00000088
#define HIRESHAMSDBL_KEY        &H00008808


/* VGA identifiers */

#define VGA_MONITOR_ID          &H00031000

#define VGAEXTRALORES_KEY       &H00031004
#define VGALORES_KEY            &H00039004
#define VGAPRODUCT_KEY          &H00039024
#define VGAHAM_KEY          &H00031804
#define VGAEXTRALORESLACE_KEY       &H00031005
#define VGALORESLACE_KEY        &H00039005
#define VGAPRODUCTLACE_KEY      &H00039025
#define VGAHAMLACE_KEY          &H00031805
#define VGAEXTRALORESDPF_KEY        &H00031404
#define VGALORESDPF_KEY         &H00039404
#define VGAPRODUCTDPF_KEY       &H00039424
#define VGAEXTRALORESLACEDPF_KEY    &H00031405
#define VGALORESLACEDPF_KEY     &H00039405
#define VGAPRODUCTLACEDPF_KEY       &H00039425
#define VGAEXTRALORESDPF2_KEY       &H00031444
#define VGALORESDPF2_KEY        &H00039444
#define VGAPRODUCTDPF2_KEY      &H00039464
#define VGAEXTRALORESLACEDPF2_KEY   &H00031445
#define VGALORESLACEDPF2_KEY        &H00039445
#define VGAPRODUCTLACEDPF2_KEY      &H00039465
#define VGAEXTRAHALFBRITE_KEY       &H00031084
#define VGAEXTRAHALFBRITELACE_KEY   &H00031085
/* New for AA ChipSet (V39) */
#define VGAPRODUCTHAM_KEY       &H00039824
#define VGALORESHAM_KEY         &H00039804
#define VGAEXTRALORESHAM_KEY        VGAHAM_KEY
#define VGAPRODUCTHAMLACE_KEY       &H00039825
#define VGALORESHAMLACE_KEY     &H00039805
#define VGAEXTRALORESHAMLACE_KEY    VGAHAMLACE_KEY
#define VGAEXTRALORESEHB_KEY        VGAEXTRAHALFBRITE_KEY
#define VGAEXTRALORESEHBLACE_KEY    VGAEXTRAHALFBRITELACE_KEY
#define VGALORESEHB_KEY         &H00039084
#define VGALORESEHBLACE_KEY     &H00039085
#define VGAEHB_KEY          &H000390a4
#define VGAEHBLACE_KEY          &H000390a5
/* These ModeIDs are the scandoubled equivalents of the above,  with the
 * exception of the DualPlayfield modes,  as AA does not allow for scandoubling
 * dualplayfield.
 */
#define VGAEXTRALORESDBL_KEY        &H00031000
#define VGALORESDBL_KEY         &H00039000
#define VGAPRODUCTDBL_KEY       &H00039020
#define VGAEXTRALORESHAMDBL_KEY     &H00031800
#define VGALORESHAMDBL_KEY      &H00039800
#define VGAPRODUCTHAMDBL_KEY        &H00039820
#define VGAEXTRALORESEHBDBL_KEY     &H00031080
#define VGALORESEHBDBL_KEY      &H00039080
#define VGAPRODUCTEHBDBL_KEY        &H000390a0

/* a2024 identifiers */

#define A2024_MONITOR_ID        &H00041000

#define A2024TENHERTZ_KEY       &H00041000
#define A2024FIFTEENHERTZ_KEY       &H00049000

/* prototype identifiers (private) */

#define PROTO_MONITOR_ID        &H00051000


/* These monitors and modes were added for the V38 release. */

#define EURO72_MONITOR_ID       &H00061000

#define EURO72EXTRALORES_KEY        &H00061004
#define EURO72LORES_KEY         &H00069004
#define EURO72PRODUCT_KEY       &H00069024
#define EURO72HAM_KEY           &H00061804
#define EURO72EXTRALORESLACE_KEY    &H00061005
#define EURO72LORESLACE_KEY     &H00069005
#define EURO72PRODUCTLACE_KEY       &H00069025
#define EURO72HAMLACE_KEY       &H00061805
#define EURO72EXTRALORESDPF_KEY     &H00061404
#define EURO72LORESDPF_KEY      &H00069404
#define EURO72PRODUCTDPF_KEY        &H00069424
#define EURO72EXTRALORESLACEDPF_KEY &H00061405
#define EURO72LORESLACEDPF_KEY      &H00069405
#define EURO72PRODUCTLACEDPF_KEY    &H00069425
#define EURO72EXTRALORESDPF2_KEY    &H00061444
#define EURO72LORESDPF2_KEY     &H00069444
#define EURO72PRODUCTDPF2_KEY       &H00069464
#define EURO72EXTRALORESLACEDPF2_KEY    &H00061445
#define EURO72LORESLACEDPF2_KEY     &H00069445
#define EURO72PRODUCTLACEDPF2_KEY   &H00069465
#define EURO72EXTRAHALFBRITE_KEY    &H00061084
#define EURO72EXTRAHALFBRITELACE_KEY    &H00061085
/* New AA modes (V39) */
#define EURO72PRODUCTHAM_KEY        &H00069824
#define EURO72PRODUCTHAMLACE_KEY    &H00069825
#define EURO72LORESHAM_KEY      &H00069804
#define EURO72LORESHAMLACE_KEY      &H00069805
#define EURO72EXTRALORESHAM_KEY     EURO72HAM_KEY
#define EURO72EXTRALORESHAMLACE_KEY EURO72HAMLACE_KEY
#define EURO72EXTRALORESEHB_KEY     EURO72EXTRAHALFBRITE_KEY
#define EURO72EXTRALORESEHBLACE_KEY EURO72EXTRAHALFBRITELACE_KEY
#define EURO72LORESEHB_KEY      &H00069084
#define EURO72LORESEHBLACE_KEY      &H00069085
#define EURO72EHB_KEY           &H000690a4
#define EURO72EHBLACE_KEY       &H000690a5
/* These ModeIDs are the scandoubled equivalents of the above,  with the
 * exception of the DualPlayfield modes,  as AA does not allow for scandoubling
 * dualplayfield.
 */
#define EURO72EXTRALORESDBL_KEY     &H00061000
#define EURO72LORESDBL_KEY      &H00069000
#define EURO72PRODUCTDBL_KEY        &H00069020
#define EURO72EXTRALORESHAMDBL_KEY  &H00061800
#define EURO72LORESHAMDBL_KEY       &H00069800
#define EURO72PRODUCTHAMDBL_KEY     &H00069820
#define EURO72EXTRALORESEHBDBL_KEY  &H00061080
#define EURO72LORESEHBDBL_KEY       &H00069080
#define EURO72PRODUCTEHBDBL_KEY     &H000690a0


#define EURO36_MONITOR_ID       &H00071000

/* Euro36 modeids can be ORed with the default modeids a la NTSC and PAL.
 * For example,  Euro36 SuperHires is
 * (EURO36_MONITOR_ID OR SUPER_KEY)
 */

#define SUPER72_MONITOR_ID      &H00081000

/* Super72 modeids can be ORed with the default modeids a la NTSC and PAL.
 * For example,  Super72 SuperHiresLace (80&H600) is
 * (SUPER72_MONITOR_ID OR SUPERLACE_KEY).
 * The following scandoubled Modes are the exception:
 */
#define SUPER72LORESDBL_KEY     &H00081008
#define SUPER72HIRESDBL_KEY     &H00089008
#define SUPER72SUPERDBL_KEY     &H00089028
#define SUPER72LORESHAMDBL_KEY      &H00081808
#define SUPER72HIRESHAMDBL_KEY      &H00089808
#define SUPER72SUPERHAMDBL_KEY      &H00089828
#define SUPER72LORESEHBDBL_KEY      &H00081088
#define SUPER72HIRESEHBDBL_KEY      &H00089088
#define SUPER72SUPEREHBDBL_KEY      &H000890a8


/* These monitors and modes were added for the V39 release. */

#define DBLNTSC_MONITOR_ID      &H00091000

#define DBLNTSCLORES_KEY        &H00091000
#define DBLNTSCLORESFF_KEY      &H00091004
#define DBLNTSCLORESHAM_KEY     &H00091800
#define DBLNTSCLORESHAMFF_KEY       &H00091804
#define DBLNTSCLORESEHB_KEY     &H00091080
#define DBLNTSCLORESEHBFF_KEY       &H00091084
#define DBLNTSCLORESLACE_KEY        &H00091005
#define DBLNTSCLORESHAMLACE_KEY     &H00091805
#define DBLNTSCLORESEHBLACE_KEY     &H00091085
#define DBLNTSCLORESDPF_KEY     &H00091400
#define DBLNTSCLORESDPFFF_KEY       &H00091404
#define DBLNTSCLORESDPFLACE_KEY     &H00091405
#define DBLNTSCLORESDPF2_KEY        &H00091440
#define DBLNTSCLORESDPF2FF_KEY      &H00091444
#define DBLNTSCLORESDPF2LACE_KEY    &H00091445
#define DBLNTSCHIRES_KEY        &H00099000
#define DBLNTSCHIRESFF_KEY      &H00099004
#define DBLNTSCHIRESHAM_KEY     &H00099800
#define DBLNTSCHIRESHAMFF_KEY       &H00099804
#define DBLNTSCHIRESLACE_KEY        &H00099005
#define DBLNTSCHIRESHAMLACE_KEY     &H00099805
#define DBLNTSCHIRESEHB_KEY     &H00099080
#define DBLNTSCHIRESEHBFF_KEY       &H00099084
#define DBLNTSCHIRESEHBLACE_KEY     &H00099085
#define DBLNTSCHIRESDPF_KEY     &H00099400
#define DBLNTSCHIRESDPFFF_KEY       &H00099404
#define DBLNTSCHIRESDPFLACE_KEY     &H00099405
#define DBLNTSCHIRESDPF2_KEY        &H00099440
#define DBLNTSCHIRESDPF2FF_KEY      &H00099444
#define DBLNTSCHIRESDPF2LACE_KEY    &H00099445
#define DBLNTSCEXTRALORES_KEY       &H00091200
#define DBLNTSCEXTRALORESHAM_KEY    &H00091a00
#define DBLNTSCEXTRALORESEHB_KEY    &H00091280
#define DBLNTSCEXTRALORESDPF_KEY    &H00091600
#define DBLNTSCEXTRALORESDPF2_KEY   &H00091640
#define DBLNTSCEXTRALORESFF_KEY     &H00091204
#define DBLNTSCEXTRALORESHAMFF_KEY  &H00091a04
#define DBLNTSCEXTRALORESEHBFF_KEY  &H00091284
#define DBLNTSCEXTRALORESDPFFF_KEY  &H00091604
#define DBLNTSCEXTRALORESDPF2FF_KEY &H00091644
#define DBLNTSCEXTRALORESLACE_KEY   &H00091205
#define DBLNTSCEXTRALORESHAMLACE_KEY    &H00091a05
#define DBLNTSCEXTRALORESEHBLACE_KEY    &H00091285
#define DBLNTSCEXTRALORESDPFLACE_KEY    &H00091605
#define DBLNTSCEXTRALORESDPF2LACE_KEY   &H00091645

#define DBLPAL_MONITOR_ID       &H000a1000

#define DBLPALLORES_KEY         &H000a1000
#define DBLPALLORESFF_KEY       &H000a1004
#define DBLPALLORESHAM_KEY      &H000a1800
#define DBLPALLORESHAMFF_KEY        &H000a1804
#define DBLPALLORESEHB_KEY      &H000a1080
#define DBLPALLORESEHBFF_KEY        &H000a1084
#define DBLPALLORESLACE_KEY     &H000a1005
#define DBLPALLORESHAMLACE_KEY      &H000a1805
#define DBLPALLORESEHBLACE_KEY      &H000a1085
#define DBLPALLORESDPF_KEY      &H000a1400
#define DBLPALLORESDPFFF_KEY        &H000a1404
#define DBLPALLORESDPFLACE_KEY      &H000a1405
#define DBLPALLORESDPF2_KEY     &H000a1440
#define DBLPALLORESDPF2FF_KEY       &H000a1444
#define DBLPALLORESDPF2LACE_KEY     &H000a1445
#define DBLPALHIRES_KEY         &H000a9000
#define DBLPALHIRESFF_KEY       &H000a9004
#define DBLPALHIRESHAM_KEY      &H000a9800
#define DBLPALHIRESHAMFF_KEY        &H000a9804
#define DBLPALHIRESLACE_KEY     &H000a9005
#define DBLPALHIRESHAMLACE_KEY      &H000a9805
#define DBLPALHIRESEHB_KEY      &H000a9080
#define DBLPALHIRESEHBFF_KEY        &H000a9084
#define DBLPALHIRESEHBLACE_KEY          &H000a9085
#define DBLPALHIRESDPF_KEY      &H000a9400
#define DBLPALHIRESDPFFF_KEY        &H000a9404
#define DBLPALHIRESDPFLACE_KEY      &H000a9405
#define DBLPALHIRESDPF2_KEY     &H000a9440
#define DBLPALHIRESDPF2FF_KEY       &H000a9444
#define DBLPALHIRESDPF2LACE_KEY     &H000a9445
#define DBLPALEXTRALORES_KEY        &H000a1200
#define DBLPALEXTRALORESHAM_KEY     &H000a1a00
#define DBLPALEXTRALORESEHB_KEY     &H000a1280
#define DBLPALEXTRALORESDPF_KEY     &H000a1600
#define DBLPALEXTRALORESDPF2_KEY    &H000a1640
#define DBLPALEXTRALORESFF_KEY      &H000a1204
#define DBLPALEXTRALORESHAMFF_KEY   &H000a1a04
#define DBLPALEXTRALORESEHBFF_KEY   &H000a1284
#define DBLPALEXTRALORESDPFFF_KEY   &H000a1604
#define DBLPALEXTRALORESDPF2FF_KEY  &H000a1644
#define DBLPALEXTRALORESLACE_KEY    &H000a1205
#define DBLPALEXTRALORESHAMLACE_KEY &H000a1a05
#define DBLPALEXTRALORESEHBLACE_KEY &H000a1285
#define DBLPALEXTRALORESDPFLACE_KEY &H000a1605
#define DBLPALEXTRALORESDPF2LACE_KEY    &H000a1645


/* Use these tags for passing to BestModeID() (V39) */

#define SPECIAL_FLAGS (DIPF_IS_DUALPF OR DIPF_IS_PF2PRI OR DIPF_IS_HAM OR DIPF_IS_EXTRAHALFBRITE)

#define BIDTAG_DIPFMustHave &H80000001  /* mask of the DIPF_ flags the ModeID must have */
                /* Default - NULL */
#define BIDTAG_DIPFMustNotHave  &H80000002  /* mask of the DIPF_ flags the ModeID must not have */
                /* Default - SPECIAL_FLAGS */
#define BIDTAG_ViewPort     &H80000003  /* ViewPort for which a ModeID is sought. */
                /* Default - NULL */
#define BIDTAG_NominalWidth &H80000004  /* \ together make the aspect ratio and */
#define BIDTAG_NominalHeight    &H80000005  /* / override the vp->Width/Height. */
                /* Default - SourceID NominalDimensionInfo, 
                 * or vp->DWidth/Height,  or (640 * 200), 
                 * in that preferred order.
                 */
#define BIDTAG_DesiredWidth &H80000006  /* \ Nominal Width and Height of the */
#define BIDTAG_DesiredHeight    &H80000007  /* / returned ModeID. */
                /* Default - same as Nominal */
#define BIDTAG_Depth        &H80000008  /* ModeID must support this depth. */
                /* Default - vp->RasInfo->BitMap->Depth or 1 */
#define BIDTAG_MonitorID    &H80000009  /* ModeID must use this monitor. */
                /* Default - use best monitor available */
#define BIDTAG_SourceID     &H8000000a  /* instead of a ViewPort. */
                /* Default - VPModeID(vp) if BIDTAG_ViewPort is
                 * specified,  else leave the DIPFMustHave and
                 * DIPFMustNotHave values untouched.
                 */
#define BIDTAG_RedBits      &H8000000b  /* \                */
#define BIDTAG_BlueBits     &H8000000c  /* END STRUCT Match up from the database */
#define BIDTAG_GreenBits    &H8000000d  /* /                */
                /* Default - 4 */
#define BIDTAG_GfxPrivate   &H8000000e  /* Private */

#endif /* GRAPHICS_MODEID_H */
