{* 
** Another pattern example.
** Shows dithered effect used
** by some requesters.
**
** D Benn, December 1995
*}

Window 1,,(0,0)-(150,100),14

Dim areaPat%(2)

areaPat%(0) = &HCCCC	'1100110011001100
areaPat%(1) = &H3333	'0011001100110011

{** Try this instead...
areaPat%(0) = &HAAAA	'1010101010101010
areaPat%(1) = &H5555	'0101010101010101  **}


{** And this...
areaPat%(0) = &H9249	'1001001001001001
areaPat%(1) = &H4924	'0100100100100100 **}

Pattern ,areaPat%	'affects polygon-fills
			'of any kind
Paint (0,0)

Gadget Wait 0

Window Close 1
