{*
** Header file for programs using EasyRequester SUBmod.
** D Benn, July 1995
*}

LIBRARY "intuition.library"

DECLARE SUB LONGINT EasyRequest(STRING wintitle, ~
                        	STRING bodytext, ~
                        	STRING gadgettext) EXTERNAL
