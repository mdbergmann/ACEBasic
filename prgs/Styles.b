/* 	
	By Magnus Lundin 
	Hippomus in Action! 
	Using Linklibs by Nisse!?
*/
	


#include <stdio.h>
#include <LinkLibs/nisse.h>

puts("")
CRTFrontPen(2)
CRTStyle(TS_BOLD)
puts("Bold testing")

CRTFrontPen(3)
CRTStyle(TS_ITALICS)
puts("Italic Magnus")

CRTFrontPen(2)
CRTStyle(TS_UNDERSCORE)
puts("Det skall vara understruket")

CRTFrontPen(1)
CRTStyle(TS_INVERSEVIDEO)
puts("Vad menas med Inverse?")

CRTStyle(TS_PLAIN)
CRTFrontPen(1)
puts("HEHE")
puts("")

