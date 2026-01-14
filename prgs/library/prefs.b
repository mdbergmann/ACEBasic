{*
** Get screen font height via preferences.
** D Benn, July 1995
*}

LIBRARY "intuition"

DECLARE FUNCTION ADDRESS GetPrefs(ADDRESS buf, ~
				  SHORTINT bufsize) LIBRARY intuition

STRUCT Preferences
  BYTE FontHeight
END STRUCT

DECLARE STRUCT Preferences prefs

IF GetPrefs(prefs,SIZEOF(prefs)) THEN 
  PRINT prefs->FontHeight 
ELSE
  PRINT "Error getting preferences."
END IF

LIBRARY CLOSE "intuition"
