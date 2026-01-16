
{* 
** A "hello world" program which uses only
** dos.library functions. Note that FPuts and
** FPutC are only found under Wb 2.x and up
** (_Write could be used for 1.3 systems).
**
** Must be run from a shell/CLI.
*}

DECLARE FUNCTION _Output&() LIBRARY dos
DECLARE FUNCTION FPuts(handle&,buf$) LIBRARY dos
DECLARE FUNCTION FPutC(handle&,ch&) LIBRARY dos

fh& = _Output

FPuts(fh&,"hello world!")
FPutC(fh&,10&)
