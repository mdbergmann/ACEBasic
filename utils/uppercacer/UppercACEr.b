'******************************************************
'*                    UppercACEr                      *
'*       by K.Veijalainen (veijalai@cc.lut.fi)        *
'*                                                    *
'*        This program is SLOW. But it works.         *
'*                                                    *
'* 6.7.'94 - Work started(gettin' familiar with ACE)  *
'*           An almost working but S.L.O.W version    *
'*           finished...                              *
'* 7.7     - Added check whether it's substring that  *
'*           is found or a real reserved word         *
'*           Optimized code a bit                     *
'*           Added check for CTRL-C                   *
'*           Removed bug with empty line check        *
'*           Added check for strings in "" and        *
'*           comments within {}-brackets.             *
'*           Added 'QUIET'-parameter                  *
'*           Added 'DEBUG'-parameter                  *
'* 8.7     - Partial rewrite :-)                      *
'*           Fixed & sped up string-checking          *
'*           -''-            {}-comment-checking      *
'* ?.7-11.7- Rewrite. Bugfixes by Ede                 *
'* 20.7    - _jumppi-table.                           *
'* 22.7    - Bugfixes                                 *
'* 23.7    - Bugfix   - removed DEBUG-option          *
'* 24.7    - Wrote sucky docs.                        *
'* 26.7    - Fixed a division-by-zero error which     *
'*           occurred during speed info' calculation  *
'*           for short ACE programs where btime!=0.   *
'*           (DB)                                     *
'* 27.7    - removal of leftmost char in _res$()      *
'* 18.8    - empty line bug in skip_block_comment fixd*
'* 15.10   - Reserved word file must now be in s:.    *
'******************************************************

'These are used for the _jumppi()-table
CONST _first=0,_last=1

'Get the parameters
IF ARGCOUNT<2 THEN
	PRINT "You must give at least 2 parameters."
	PRINT "Usage: "+ARG$(0)+" <inputfile>[.b] <outputfile>[.b] [QUIET]"
	PRINT "The .b-extension is optional. If it's missing, it will be added."
	STOP
ELSE
	_infile$=ARG$(1)
	_outfile$=ARG$(2)
	IF UCASE$(RIGHT$(_infile$,2))<>".B"  THEN _infile$=_infile$+".b"
	IF UCASE$(RIGHT$(_outfile$,2))<>".B" THEN _outfile$=_outfile$+".b"
	_quiet=0 :REM defaults
	'This loop is made for easy addition of parameters in future
	FOR z=3 TO 3
		IF UCASE$(ARG$(z))="QUIET" AND _quiet=0 THEN _quiet=1
	NEXT
END IF

ON BREAK GOTO lopetus
BREAK ON

'Globally declare all variables as short int
DEFINT a-z,_

DECLARE SUB msg(_message$,_lf)
DECLARE SUB match_n_replace(mm$)
DECLARE SUB skip_spaces
DECLARE SUB find_word
DECLARE SUB skip_block_comment
DECLARE SUB openfiles
DECLARE SUB _readline

msg("Reading the reserved word index..",0)
n=0
'Check the number of reserved words in the index file
OPEN "I",#1,"s:UppercACEr.Reserved"
'Check whether _infile exists
IF HANDLE(1) = 0& THEN
	PRINT "Could not open UppercACEr.Reserved!"
	PRINT "Check that this file exists in "+ARG$(0)+CHR$(39)+"s current directory."
	STOP
END IF
WHILE NOT EOF(1)
	LINE INPUT #1,t$
	'Only inc n if the 1st char of t$ is not '
	IF PEEK(@t$)<>39 THEN ++n
WEND
CLOSE #1
'Alloc mem and dim the _res$()-array
CONST StrSize=11 : REM the max reserved word length is 10! (ACE 2.0)
myStrArrayAddr& = ALLOC(n*StrSize)
'This memory is automatically freed by ACE when the program exits
IF myStrArrayAddr& = 0& THEN
	PRINT "..Could not allocate";n*StrSize;" bytes of memory!"
	STOP
END IF
DIM _res$(1) SIZE StrSize ADDRESS myStrArrayAddr&
'..read strings from file
'Dim the jump location table
DIM _jumppi(1,25)
'Clear the table's START-locations.
FOR x=0 TO 25
	_jumppi(_first,x)=-1
NEXT
oa=-1 :REM make sure that oa<>a the 1st TIME we enter the loop...
OPEN "I",#1,"s:UppercACEr.Reserved"
FOR x=0 TO n
	'The .Reserved-file can contain comment lines starting with a ' (chr$(39))
	REPEAT
		LINE INPUT #1,t$
		'a is the ascii code of the 1st letter of t$
		a=PEEK(@t$)
	UNTIL a<>39
	a=a-65
	IF a>-1 AND a<26 THEN
		'Cut the 1st character - we KNOW what the 1st letter is from
		'the location in the _jumppi-table, so string-match checking
		'later on will be a tiny bit faster.
		l=LEN(t$)-1
		_res$(x)=UCASE$(RIGHT$(t$,l))
		IF oa<>a THEN
			_jumppi(_first,a)=x :REM beginning of words starting with different char
		END IF
		_jumppi(_last,a)=x :REM This 'pointer' moves TO the last word...
	END IF
	oa=a
NEXT
CLOSE #1
msg(".."+STR$(n+1)+" words loaded.",1)

'Open the files
OPEN "I",#1,_infile$
IF HANDLE(1)=0& THEN
	PRINT "Could not open "+_infile$+"!"
	STOP
END IF
OPEN "O",#2,_outfile$

COLOR 2,1
msg(" UppercACEr v0.33 ",0)
COLOR 1,3
msg(" by K.Veijalainen (veijalai@cc.lut.fi) ",1)
COLOR 1,0
msg("Converting "+_infile$+" --> "+_outfile$,1)

'*******************************************************************************
'Main
'Read the lines and parse them.
_lines=0:_words=0
btime!=TIMER
WHILE NOT EOF(1)
	_readline
	'Skip if the line is empty
	IF LEN(t$)=0 THEN
		t$=""
	ELSE
		'Search the point where real stuff begins
		y=1 :REM reset the location "pointer"
		'Skip the initial indention
		WHILE ASC(MID$(t$,y,1))<33 AND y<LEN(t$)+1
			'as long as there are spaces/tabs
			++y
		WEND
		'Was the line just full of BS spaces/tabs?
		IF y>LEN(t$) THEN
			t$=""
		ELSE
			'Let's skip comment lines - Check for "'"-character in the beginning
			IF MID$(t$,y,1)<>CHR$(39) THEN
				'Whoah! We got this far!
				REPEAT
					'Skip spaces between words
					skip_spaces
					'Find the next word on line
					m$=""
					oy=y : REM oy points TO the beginning of m$ now!
					find_word
					'M$ now is the WORD we found above
					'Check if there is a match and do the dirty deed
					match_n_replace(m$)
				UNTIL y>LEN(t$)
			END IF
		END IF
	END IF
	'This prevents oddness...
	IF t$="" THEN
		PRINT #2,CHR$(10);
	ELSE
		PRINT #2,t$
	END IF
WEND
btime!=TIMER-btime!

BREAK OFF

'Close the files
CLOSE #1
CLOSE #2

'Display some info
msg("# of lines in source:"+STR$(_lines),1)
msg("# of reserved words :"+STR$(_words),1)
IF btime! <> 0 THEN
	msg("Took"+STR$(btime!)+" seconds. Speed:"+STR$(_lines/btime!)+" l/s.",1)
END IF
msg("All done.",1)
STOP

'*******************************************************************************
'Procedures here...

'This procedure prints line of text with optional linefeed. Takes the
'global variable '_quiet' into account - if _quiet is true, nothing is printed.
SUB msg(_message$,_lf)
	SHARED _quiet
	IF _quiet=0 THEN
		IF _lf=1 THEN
				PRINT _message$
		ELSE
				PRINT _message$;
		END IF
	END IF
END SUB

'Speed this thing up!
SUB match_n_replace(mm$)
	SHARED _res$,t$,y,_words,n,oy,_jumppi
	l=LEN(mm$)
	'This check eliminates one-letter variables etc...
	IF l>1 THEN
		mm$=UCASE$(mm$)
		'Location in _jumppi-table
		a=peek(@mm$)-65
		'Is the word we are looking for possibly a reserved word?
		'(They all seem to start with a-z, NEVER with a number or _ or such...)
		'Also check, whether the length is more than 1 (all reserved words are
		'at least 2 characters long.
		IF a>-1 AND a<26 THEN
			'Min and Max boundaries
			x1=_jumppi(_first,a)
			'if x1 is -1, then there are no words starting with chr$(a+65)
			IF x1>-1 THEN
				x2=_jumppi(_last,a)
				'Crop off the leftmost character, because the words in _res$()-
				'table also are cropped.
				mm$=RIGHT$(mm$,l-1)
				FOR x=x1 TO x2
					IF mm$=_res$(x) THEN
						'Uppercase the sucker.
						'oy points to the beginning of the word.
						'y points to the end of the word +1
						'l is the length of the original mm$
						u$=t$
						't$=left$(u$,oy-1)+ucase$(mid$(u$,oy,l))+right$(u$,len(u$)-y+1)
						t$=LEFT$(u$,oy-1)+UCASE$(MID$(u$,oy,l))+MID$(u$,y)
						++_words
						'Make sure the rest is skipped if a REM is found
						IF mm$="EM" THEN y=LEN(t$)+2
						EXIT FOR
					END IF
				NEXT
			END IF
		END IF
	END IF
END SUB

'This sub "collects" the next word into string m$ from previously
'found location y onwards and leaves y pointing to the 1st non-alphanumeric
'character or the end of the line.
SUB find_word
	SHARED y,t$,m$
	WHILE y<LEN(t$)+1
		a=PEEK(@t$+y-1)
		IF a<48 OR (a>57 AND a<65) OR (a>90 AND a<>95 AND a<97) OR a>122 THEN
				exit sub
		ELSE
				'as long as character IS alphanumeric, add it to string
				m$=m$+chr$(a)
				'Move pointer to next char
				++y
		END IF
	WEND
END SUB

'Skips the spaces and stuff between words, plus strings and block
'comments.
'This checks whether c$ is alphanumeric or not, AND skips
'strings and block comments. NOTE! It does not matter is t$
'is changed within this sub.
SUB skip_spaces
	SHARED y,t$
	WHILE y<LEN(t$)+1
		a=PEEK(@t$+y-1)
		'String skipping
		IF a=34 THEN
			'This should _ONLY_ be executed from skip_spaces!!
			++y
			WHILE PEEK(@t$+y-1)<>34 AND y<LEN(t$)+1
				++y
			WEND
			++y
		ELSE
			'Is there a {}-comment? Can be spread on many lines.
			'The comment ends at a matching } or at the end of the source.
			'{-123  }-125
			IF a=123 THEN
				skip_block_comment
			ELSE
				IF (a>47 AND a<58) OR (a>64 AND a<91) OR a=95 OR (a>96 AND a<123) THEN
					'Ok ok... so here we are: beginning of another word found....
					exit sub
				else
					++y
				END IF
			END IF
		END IF
	WEND
END SUB

SUB skip_block_comment
	SHARED y,t$,_lines
	++y
	loopz:
	WHILE ASC(MID$(t$,y,1))<>125 AND y<LEN(t$)+1
		++y
	WEND
	'Is there need to read a new line? ARGH!
	IF y>LEN(t$) THEN
		'store the old line...
		IF t$="" THEN
			PRINT #2,CHR$(10);
		ELSE
			PRINT #2,t$
		END IF
		IF NOT EOF(1) THEN
			_readline
			y=1 :REM reset the location pointer
			GOTO loopz:
		ELSE
			y=LEN(t$)+2 : REM make sure nothing else is done in Main
		END IF
	END IF
	++y
END SUB

'Reads a line of source and prints the number of lines processed.
'Also removes some crap.
SUB _readline
	SHARED t$,_lines,_quiet
	LINE INPUT #1,t$
	++_lines
	'MSG() is not used to speed things up
	IF _quiet=0 THEN
		IF _lines MOD 10=0 THEN PRINT _lines;:PRINT CHR$(13);
	END IF
	'Remove needless spaces/tabs after a line
	WHILE ASC(RIGHT$(t$,1))<33 AND LEN(t$)>0
		t$=LEFT$(t$,LEN(t$)-1)
	WEND
END SUB

lopetus:
	PRINT:PRINT "Aborted!"
	CLOSE #1
	CLOSE #2
	STOP
