/*** FUNCTION DECLARATIONS FOR ptreplay.LIBRARY ***/

#ifndef FUNCS_ptreplay_FUNCS_H
#define FUNCS_ptreplay_FUNCS_H

#ifndef ptreplay_H
#include <libraries/ptreplay.h>
#endif

Declare Function ADDRESS PTLoadModule(STRPTR module) LIBRARY ptreplay
Declare Function PTUnloadModule(ADDRESS module) LIBRARY ptreplay
Declare Function LONGINT PTPlay(ADDRESS module) LIBRARY ptreplay
Declare Function LONGINT PTStop(ADDRESS module) LIBRARY ptreplay
Declare Function LONGINT PTPause(ADDRESS module) LIBRARY ptreplay
Declare Function LONGINT PTResume(ADDRESS module) LIBRARY ptreplay
/* New in V2 */
Declare Function PTFade(ADDRESS module, SHORTINT speed) LIBRARY ptreplay
/* New in V3 */
Declare Function PTSetVolume(ADDRESS module, SHORTINT volume) LIBRARY ptreplay
/* New in V4 */
Declare Function SHORTINT PTSongPos(ADDRESS module) LIBRARY ptreplay
Declare Function SHORTINT PTSongLen(ADDRESS module) LIBRARY ptreplay
Declare Function SHORTINT PTSongPattern(ADDRESS module, ~
					SHORTINT position) LIBRARY ptreplay
Declare Function SHORTINT PTPatternPos(ADDRESS module) LIBRARY ptreplay
Declare Function APTR PTPatternData(ADDRESS module, SHORTINT patternNum, ~
				    SHORTINT rowNum) LIBRARY ptreplay
Declare Function PTInstallBits(ADDRESS module, SHORTINT restart, SHORTINT position, ~
			       SHORTINT row, SHORTINT fade) LIBRARY ptreplay
Declare Function ADDRESS PTSetupMod(APTR loadedMod) LIBRARY ptreplay
Declare Function PTFreeMod(ADDRESS module) LIBRARY ptreplay
Declare Function PTStartFade(ADDRESS module, SHORTINT speed) LIBRARY ptreplay
/* New in V5 */
Declare Function PTOnChannel(ADDRESS module, SHORTINT channel) LIBRARY ptreplay
Declare Function PTOffChannel(ADDRESS module, SHORTINT channel) LIBRARY ptreplay
Declare Function PTSetPos(ADDRESS module, SHORTINT position) LIBRARY ptreplay
Declare Function PTSetPri(SHORTINT pri) LIBRARY ptreplay
Declare Function SHORTINT PTGetPri() LIBRARY ptreplay
/* New in V6 */
Declare Function SHORTINT PTGetChan() LIBRARY ptreplay
Declare Function ADDRESS PTGetSample(ADDRESS module, SHORTINT num) LIBRARY ptreplay

#endif /* FUNCS_ptreplay_FUNCS_H */
