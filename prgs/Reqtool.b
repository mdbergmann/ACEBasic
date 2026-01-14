/* 
	Magnus is using reqtools library
	All rights reserved by Hippomus
*/


#include <funcs/reqtools_funcs.h>

Library "reqtools.library"

a=rtEZRequestA("Hello Amigauser!","Okey|NO",0,0,0)

if a=1 then 
rtezrequestA("Yes Amiga is cool!","OKEY",0,0,0)

end if

if a=0 then 
rtezrequestA("So what are you?","SUCK",0,0,0)
end if
