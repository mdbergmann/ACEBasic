
This SUBmod allows a program to be loaded and executed with control over stack 
size and retrieval of the AmigaDOS return code, making it superior to ACE's 
SYSTEM command.

Like the SYSTEM command, the input file is taken from the context of the 
calling process (normally the keyboard).

Version 36 or higher of the OS (Wb 2.x/3.x) is required since the dos.library 
RunCommand() function is used.

Note: if you run a program which calls RunProg from a shell, the shell will
generally close upon completion of the program. The reason for this is still 
unclear to me but I have some ideas. It is unrelated to the use of UnLoadSeg().
I suspect it's just that I'm misunderstanding the behaviour of RunCommand()
and I may need to have the parent create a child process.

See RunProg.b and RunProg.h for more details and test.b for an example of how
to use RunProg.o.

Regards,

David Benn, 6th March 1995
