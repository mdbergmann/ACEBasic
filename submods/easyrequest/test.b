{*
** A test of EasyRequest SUBmod.
** By Nils Sjoholm. Modified by David Benn, July 1995, September 1996
*}

#include <SUBmods/EasyRequest.h>

{* Variables *}
LONGINT retval
STRING bodystring SIZE 200
STRING gadtext SIZE 30

{* Main *}
retval = EasyRequest("This is my title","Requesterstring","Continue")

bodystring = "This is the first line" + CHR$(10) + ~
             "And this is the second line" + CHR$(10) + ~
             "Yet another line" + CHR$(10) + ~
             "And the final line"

gadtext = "Fine|So?|How Nice|Or?"

retval = EasyRequest("Simple test of EasyRequest",bodystring,gadtext)

CASE
    retval = 0 : retval = EasyRequest("Another test","You cancelled, or?","OK")

    retval = 1 : retval = EasyRequest("Thank you","Glad you liked it","OK")

    retval = 2 : retval = EasyRequest("So what","I don't care."+ CHR$(10) + ~
				      "You dont have to use it","OK")

    retval = 3 : retval = EasyRequest("Hmmmm How nice","Yes I like it too.", ~
				      "Continue")
END CASE
