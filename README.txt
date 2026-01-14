
ACE Basic compiler
==================

I've changed the compiler to gcc (as included in ADE available on Aminet).
With a few tweaks it was possible to compile the compiler.
But single precision floating point didn't work.
The project uses mathffp library,
but the variables that hold the float value were of type float rather than LONG.

Changing the variable definition 'singleval' from float to LONG fixed the floating point issue.

Further changes add support for vlink instead of blink.
And vasmm68k_mot instead of a68k assembler.
See ACE:bin/bas.vb if you want to use it.
