{ ** show the number of days difference between two dates **

  (illustrates the use of julday and calday$ subprograms in julian.h)

  Author: David J Benn
    Date: 9th April 1993 }

#include <ace/Julian.h>

if argcount=2 then 
  dt1$=arg$(1) : if ucase$(dt1$)="TODAY" then dt1$=date$
  dt2$=arg$(2) : if ucase$(dt2$)="TODAY" then dt2$=date$
  jd1 = julday(dt1$)
  jd2 = julday(dt2$)
  print "There is a difference of";abs(jd2-jd1);"days between ";
  print calday$(jd1);" and ";calday$(jd2);"."
else
  print "usage: days <date1>|today <date2>|today"
  print "       where date1 & date2 are strings"
  print "       of the form mm-dd-yyyy."
end if
