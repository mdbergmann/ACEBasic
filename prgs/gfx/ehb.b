
'..A test of Extra-Halfbrite screen mode in ACE.
'..Based upon a C program in "Inside Amiga Graphics", p 263-266.
'..David J Benn, August 1994.

DEFINT a-z

const nibble = 4

screen 1,320,200,6,6

for i=0 to 31
  read RGB

  R = SHR(RGB AND &H0F00,2*nibble)
  G = SHR(RGB AND &H00F0,nibble)
  B = RGB AND &H000F
  
  palette i,R/15,G/15,B/15
next

'..color-table
DATA &H888,&HF00,&H0F0,&H00F
DATA &HFF0,&H0FF,&HF0F,&HFFF
DATA &HA04,&H0A4,&HA40,&H40A
DATA &H4A0,&H04A,&HAA0,&HA0A
DATA &H953,&H369,&H84A,&HC3B
DATA &H8E4,&H5CB,&H678,&H983
DATA &H77A,&H9B4,&HD4D,&HCF7
DATA &H3B9,&H95E,&HDD5,&H4F7

window 1,,(0,0)-(320,200),32,1

'..demo
for c=0 to 15
  {* color bars for colors 0..15 *}
  color c
  line (18*c,20)-(18*c+17,40),,bf

  {* ...and the halfbrite versions *} 
  color c+32
  line (18*c,50)-(18*c+17,70),,bf

  {* color bars for colors 16..31 *}
  color c+16
  line (18*c,110)-(18*c+17,130),,bf

  {* ...and the halfbrite versions *} 
  color c+48
  line (18*c,140)-(18*c+17,160),,bf
next

while inkey$="":sleep:wend

window close 1
screen close 1
