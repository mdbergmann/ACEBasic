#ifndef GRAPHICS_RPATTR_H
#define GRAPHICS_RPATTR_H 1
/*
** rpattr.h for ACE Basic
**
** Note: Translated to ACE by ConvertC2ACE
**       @ MapMeadow Software, Nils Sjoholm
**
**
** Date: 09/01/95
**
**
*/


#define RPTAG_Font      &H80000000      /* get/set font */
#define RPTAG_APen      &H80000002      /* get/set apen */
#define RPTAG_BPen      &H80000003      /* get/set bpen */
#define RPTAG_DrMd      &H80000004      /* get/set draw mode */
#define RPTAG_OutLinePen    &H80000005  /* get/set outline pen */
#define RPTAG_OutlinePen    &H80000005  /* get/set outline pen. corrected case. */
#define RPTAG_WriteMask &H80000006  /* get/set WriteMask */
#define RPTAG_MaxPen        &H80000007  /* get/set maxpen */

#define RPTAG_DrawBounds    &H80000008  /* get only rastport draw bounds. pass &rect */

#endif  /* GRAPHICS_RPATTR_H */
