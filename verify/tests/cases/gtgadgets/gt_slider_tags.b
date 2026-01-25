' GadTools tag parsing test: SLIDER_KIND with GTSL_Min, GTSL_Max
' Verify: generated .s has TagItem array with correct constants.
WINDOW 1,"Test",(0,0)-(320,200),14
GADGET 1,1,"Vol:",(10,10)-(100,22),SLIDER_KIND,GTSL_Min=0,GTSL_Max=100
SLEEP FOR 1
WINDOW CLOSE 1
END
