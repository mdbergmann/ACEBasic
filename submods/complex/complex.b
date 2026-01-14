{*
** Complex Number Mathematics Subprogram Library.
** Author: Rich Allen [rico@wsnet.com, rico@larry.cdsar.af.mil]
*}

STRUCT Complex
  SINGLE real
  SINGLE imag
END STRUCT

SUB ADDRESS AddComp (ADDRESS xaddr, ADDRESS yaddr, ADDRESS zaddr) EXTERNAL
DECLARE STRUCT Complex *x, *y, *z

  x = xaddr : y = yaddr : z = zaddr

  z->real = x->real + y->real
  z->imag = x->imag + y->imag

  AddComp = z
END SUB

SUB ADDRESS SubComp (ADDRESS xaddr, ADDRESS yaddr, ADDRESS zaddr) EXTERNAL
DECLARE STRUCT Complex *x, *y, *z

  x = xaddr : y = yaddr : z = zaddr

  z->real = x->real - y->real
  z->imag = x->imag - y->imag

  SubComp = z
END SUB

SUB ADDRESS MulComp (ADDRESS xaddr, ADDRESS yaddr, ADDRESS zaddr) EXTERNAL
DECLARE STRUCT Complex *x, *y, *z

  x = xaddr : y = yaddr : z = zaddr

  z->real = (x->real*y->real) - (x->imag*y->imag)
  z->imag = (x->real*y->imag) + (x->imag*y->real)

  MulComp = z
END SUB

SUB ADDRESS DivComp (ADDRESS xaddr, ADDRESS yaddr, ADDRESS zaddr) EXTERNAL
DECLARE STRUCT Complex *x, *y, *z

  x = xaddr : y = yaddr : z = zaddr

  z->real = (x->real*y->real) + (x->imag*y->imag)
  z->imag = (x->imag*y->real) - (x->real*y->imag)

  denom!  = (y->real*y->real) + (y->imag*y->imag)

  if denom! = 0 then
    z->real = 0
    z->imag = 0
  else
    z->real = z->real / denom!
    z->imag = z->imag / denom!
  end if

  DivComp = z
END SUB
