' Phase 6 compile-time test: GADGET SETATTR and GADGET GETATTR
' Verify: generated .s has _SetGTGadgetAttrs, _GetGTGadgetAttr calls.
WINDOW 1,"Test",(0,0)-(320,200),14
GADGET 1,1,"Vol:",(10,10)-(200,22),SLIDER_KIND,GTSL_Min=0,GTSL_Max=100,GTSL_Level=50
GADGET SETATTR 1,GTSL_Level=75
x& = GADGET GETATTR(1,GTSL_Level)
WINDOW CLOSE 1
END
