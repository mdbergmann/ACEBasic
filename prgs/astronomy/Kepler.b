10 REM  This program 'KEP3LAW' written August 1994 
20 REM  by Leland Dolan of Houston Texas (USA) 
25 WINDOW 1,"Kepler's 3 Laws of Planetary Motion",(0,0)-(640,200)
30 CLS 
40 AY = 365.2596: REM  Anomalistic Year 
60 PRINT "This program calculates Planet's Orbital Period, or" 
70 PRINT "Mean Solar Distance, whichever value is unknown." 
90 PRINT 
100 INPUT "Quantity known: Distance (D), or Period (P)"; AN$ 
110 IF AN$ = "D" OR AN$ = "d" THEN GOSUB 1200 
120 IF AN$ = "P" OR AN$ = "p" THEN GOSUB 1400 
140 PRINT 
150 IF PA < 2 THEN GOSUB 1500 
160 IF PA >= 2 THEN GOSUB 1600 
200 GOSUB 1700 
210 PRINT 
300 INPUT "Is Orbital Eccentricity known"; QS$ 
320 IF QS$ = "Y" OR QS$ = "y" THEN GOSUB 2000 
330 IF QS$ = "N" OR QS$ = "n" THEN GOTO 900 
900 WINDOW CLOSE 1 : END 
1200 REM  Calculating orbital period 
1210 INPUT "Planet's Mean Solar Distance in A.U."; DS 
1220 PA = SQR(DS ^ 3) 
1230 RETURN 
1400 REM  Calculating Mean Solar Distance 
1410 INPUT "Planet's Orbital Period (years)"; PA 
1420 DS = (PA ^ 2) ^ (1 / 3) 
1430 RETURN 
1500 PG = PA * AY: REM  Converting years to days 
1510 PRINT "Orbital Period = "; 
1520 PRINT {USING "###.#";} PG; 
1530 PRINT " days" 
1540 RETURN 
1600 PRINT "Orbital Period ="; 
1610 PRINT {USING "###.##";} PA; 
1620 PRINT " years" 
1630 RETURN 
1700 PRINT "Mean Solar Distance ="; 
1710 PRINT {USING "###.##";} DS; 
1720 PRINT " A.U." 
1730 RETURN 
2000 REM  Calculating Perihelion & Aphelion Dist. 
2010 INPUT "What is Eccentricity of Orbit"; E 
2020 C = E * DS: REM  C is distance of foci from center 
2030 Q = DS - C: REM  Perihelion dist. 
2040 QA = DS + C: REM  Aphelion dist. 
2045 PRINT : CLS ': SCREEN 9 
2050 COLOR 5, 0: PRINT "Eccentricity ="; E 
2060 COLOR 12, 0: PRINT "Perihelion ="; 
2065 PRINT {USING "##.##";} Q 
2070 COLOR 3, 0: PRINT "Aphelion ="; 
2075 PRINT {USING "###.##";} QA 
2080 COLOR 7, 0: PRINT 
2100 REM  Drawing orbital ellipse 
2160 A = 195: B = A * (1 - E) ^ (1 / 2) 
2170 B1 = INT(B + .5): C1 = E * A 
2180 Q1 = A - C1: REM periehlion length 
2190 Q2 = Q1 + 115 
2200 LINE (115, 160)-(Q2, 160), 12 
2210 LINE (Q2, 160)-(505, 160), 3 
2230 PSET (310, 160) 
2250 PSET (Q2, 160) 
2260 ASP = 265: REM  Aspect Ratio number 
2270 CIRCLE (310, 160), 195, , , , 1 / ASP * B1 
2280 WHILE INKEY$="":SLEEP:WEND
2290 WINDOW CLOSE 1 
