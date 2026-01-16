
{From: jackmott@ix.netcom.com (The Crow)
Newsgroups: comp.lang.basic.misc
Subject: Great BASIC program, visually stunning
Date: 18 Nov 1995 04:15:34 GMT
Organization: none
Lines: 192
Message-ID: <48jml6$gkn@ixnews4.ix.netcom.com>
NNTP-Posting-Host: ix-stm6-26.ix.netcom.com
Mime-Version: 1.0
Content-Type: Text/Plain; charset=US-ASCII
X-NETCOM-Date: Fri Nov 17  8:15:34 PM PST 1995
X-Newsreader: WinVN 0.99.6

I wrote the following with QuickBasic 4.5 (the commercial one) if you run this 
with Qbasic that comes with DOS it will go REAL slow, but there is a variable 
you can change that I will comment profusely that will speed it up with a lack 
of quality..also you can just change the screen resolution and stuff if it is 
too slow, I am on a p90 for reference.

	This program makes a random and very cool starfield, then makes graphs 
various things that resemble black holes and galaxies..makes good screen saver 
type thing, and show it to your math teacher for extra credit...

I have this written in pascal at the highschool if anyone wants it in that let 
me know, its an easy conversion.}

const true = -1&, false = 0&

SCREEN 1,640,200,4,2

'..Approximate IBM CGA colors.
palette 0,0,0,0		'..black
palette 1,0,0,1		'..blue
palette 2,0,1,0		'..green
palette 3,0,.93,.87	'..cyan (aqua)
palette 4,1,0,0		'..red
palette 5,1,.13,.93	'..magenta (violet)
palette 6,.8,.6,.53	'..brown
palette 7,.25,.25,.25	'..light gray
palette 8,.73,.73,.73	'..dark gray
palette 9,.47,.87,1	'..light (sky) blue
palette 10,.73,1,0	'..light (lime) green
palette 11,0,.47,.43	'..light cyan (aqua)
palette 12,.5,0,0	'..light red
palette 13,.5,.7,.46	'..light magenta (violet)
palette 14,1,1,.13	'..yellow
palette 15,1,1,1	'..white

SUB quit
  SCREEN CLOSE 1
  STOP
END SUB

ON MOUSE CALL quit : MOUSE ON

RANDOMIZE TIMER

radians = 1.57079632679#        'constant for 90 degrees in radians


REPEAT      'Main body
i = 0

        REPEAT                        'Big Stars

                x = INT(RND * 640 + 1)      'This part makes really really
                y = INT(RND * 200 + 1)	    'cool looking stars
                COLOR 15
                PSET (x, y)

                COLOR 7
                PSET (x - 1, y)
                PSET (x + 1, y)
                PSET (x, y - 1)
                PSET (x, y + 1)
                COLOR 8
                PSET (x - 2, y)
                PSET (x + 2, y)
                PSET (x, y - 2)
                PSET (x, y + 2)
                i = i + 1
        UNTIL i = 20     'Big stars - change the value here for more stars
       
'The parts below make normal single pixel stars       

COLOR 8
i = 0
        REPEAT                     'Dim little stars
                x = INT(RND * 640 + 1)
                y = INT(RND * 200 + 1)
                PSET (x, y)
                i = i + 1
        UNTIL i = 180     'Dim little stars

COLOR 15
i = 0
        REPEAT                     'Bright litte stars
                x = INT(RND * 640 + 1)
                y = INT(RND * 200 + 1)
                PSET (x, y)
                i = i + 1
        UNTIL i = 90      'Bright little stars

COLOR 7
i = 0
        REPEAT                      'medium little stars
                x = INT(RND * 640 + 1)
                y = INT(RND * 200 + 1)
                PSET (x, y)
                i = i + 1
        UNTIL i = 150       'medium little stars


theta = 1

c = INT(RND * 15 + 1)  'color scheme, picks a random NON-black color
if c = 0 then c = 4
color c

hole = INT(RND * 16 + 1)	'Random value to select type of graph
REPEAT              'Black hole main loop

        

                r = 1.01 ^ theta                    'black hole main formula

               
CASE      'Variations of the graph
        hole = 1 :
                y = (SIN(theta)) * r :~          'Convert polar to cartesian y
                x = (SIN(radians - theta)) * r :~ 'Convert polar to cartesian x
        x = x + theta :~
        y = y + 240 :~
        hole = 2 :
                y = (SIN(theta)) * r :~            'Convert polar to cartesian y
                x = (SIN(radians - theta)) * r:~  'Convert polar to cartesian x
        x = x - theta + 640 :~
        y = y + 240
       
        hole = 3 :
                y = (SIN(theta)) * r :~           'Convert polar to cartesian y
                x = (SIN(radians - theta)) * r :~ 'Convert polar to cartesian x
        x = x - theta + 640 :~
        y = y - theta + 200 

        hole = 4 :
                y = (SIN(theta)) * r :~           'Convert polar to cartesian y
                x = (SIN(radians - theta)) * r  'Convert polar to cartesian x
        x = x + theta :~
        y = y + theta

        hole = 5 OR hole = 14 :
      
                y = (COS(theta)) * r :~           'Convert polar to cartesian y
                x = (SIN(90 - theta)) * r :~       'Convert polar to cartesian x
        x = x + 320 :~
        y = y + 240
       
        hole = 15 OR hole = 16 :
                y = (SIN(theta)) * r :~           'Convert polar to cartesian y
                x = (SIN(radians - theta)) * r :~ 'Convert polar to cartesian x
        
        x = x + 320 :~
        y = y + 240
        
        hole = 6 :
                y = (SIN(theta)) * r  :~          'Convert polar to cartesian y
                x = (SIN(radians - theta)) * r :~ 'Convert polar to cartesian x
        x = x * theta / 85 + 320 :~
        y = y + theta

        hole = 7 :
                y = (SIN(theta)) * r  :~          'Convert polar to cartesian y
                x = (SIN(radians - theta)) * r :~ 'Convert polar to cartesian x
        x = x * theta / 85 + 320 :~
        y = y - theta + 200

        hole = 8 :
                y = (SIN(theta)) * r :~        'Convert polar to cartesian y
                x = (SIN(radians - theta)) * r :~ 'Convert polar to cartesian x
        x = x + theta :~
        y = y * theta / 100 + 240 

        hole = 9 :
                y = (SIN(theta)) * r  :~          'Convert polar to cartesian y
                x = (SIN(radians - theta)) * r  :~ 'Convert polar to cartesian x
        x = x - theta + 640 :~
        y = y * theta / 100 + 240

        hole = 10 :
                y = (SIN(theta)) * r :~           'Convert polar to cartesian y
                x = (SIN(radians - theta)) * r :~ 'Convert polar to cartesian x
        x = x + theta / r + 320 :~
        y = y + theta

        hole = 11 :
                y = (SIN(theta)) * r :~          'Convert polar to cartesian y
                x = (SIN(radians - theta)) * r :~ 'Convert polar to cartesian x
        x = x + theta / r + 320 :~
        y = y - theta + 200

        hole = 12 :
                y = (SIN(theta)) * r :~          'Convert polar to cartesian y
                x = (SIN(radians - theta)) * r :~ 'Convert polar to cartesian x
        x = x + theta :~
        y = y + theta / r + 240

        hole = 13 :
                y = (SIN(theta)) * r :~           'Convert polar to cartesian y
                x = (SIN(radians - theta)) * r :~ 'Convert polar to cartesian x
        x = x - theta + 640 :~
        y = y + theta / r + 240

END CASE


                PSET (x, y)                             'Place the dots
                theta = theta + .01  'Make this bigger for more speed!!!!!!!

                'breakout$ = INKEY$

        UNTIL theta > 750 OR breakout$ <> ""

	SLEEP FOR 1

        CLS

        'IF breakout$ <> "" THEN SCREEN CLOSE 1:STOP
UNTIL false                    'Main body
