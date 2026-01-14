{*
** Header for Complex Number Mathematics Subprogram Library.
** Author: Rich Allen [rico@wsnet.com, rico@larry.cdsar.af.mil]
*}

LIBRARY "mathffp"
LIBRARY "mathtrans"

STRUCT Complex
  SINGLE real
  SINGLE imag
END STRUCT

DECLARE SUB ADDRESS AddComp (ADDRESS xaddr, ADDRESS yaddr, ADDRESS zaddr) EXTERNAL
DECLARE SUB ADDRESS SubComp (ADDRESS xaddr, ADDRESS yaddr, ADDRESS zaddr) EXTERNAL
DECLARE SUB ADDRESS MulComp (ADDRESS xaddr, ADDRESS yaddr, ADDRESS zaddr) EXTERNAL
DECLARE SUB ADDRESS DivComp (ADDRESS xaddr, ADDRESS yaddr, ADDRESS zaddr) EXTERNAL
