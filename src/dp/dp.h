{*
** Header for double-precision math interface library.
**
** D Benn, 1996
*}

Library "mathtrans.library"

Const DOUBLESIZE = 8, NULL = 0&

Def Address dp_new = Alloc(DOUBLESIZE)

Declare Function Longint dp_open() External
Declare Function dp_close() External

Declare Function dp_longint_to_double(Address dr, Longint n) External
Declare Function dp_double_to_longint(Address nr, Address d) External

Declare Function dp_single_to_double(Address dr, Single s) External
Declare Function dp_double_to_single(Address sr, Address d) External

Declare Function dp_add(Address dr, Address d1, Address d2) External
Declare Function dp_sub(Address dr, Address d1, Address d2) External
Declare Function dp_mul(Address dr, Address d1, Address d2) External
Declare Function dp_div(Address dr, Address d1, Address d2) External
Declare Function dp_pow(Address dr, Address d1, Address d2) External

Declare Function dp_cmp(Address dr, Address d1, Address d2) External

Declare Function dp_abs(Address dr, Address d1, Address d2) External
Declare Function dp_neg(Address dr, Address d1, Address d2) External
Declare Function dp_ceil(Address dr, Address d1, Address d2) External
Declare Function dp_floor(Address dr, Address d1, Address d2) External

Declare Function dp_sin(Address dr, Address d) External
Declare Function dp_cos(Address dr, Address d) External
Declare Function dp_tan(Address dr, Address d) External
Declare Function dp_exp(Address dr, Address d) External
Declare Function dp_log(Address dr, Address d) External
Declare Function dp_sqrt(Address dr, Address d) External

Declare Function dp_val(Address dr, String s) External
