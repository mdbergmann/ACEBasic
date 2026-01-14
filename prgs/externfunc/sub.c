/* 
** Subtract two long integers passed
** by value and return the result in 
** a third parameter by reference.
*/

subtract(x,y,z)
long x,y;
long *z;
{
  *z = x-y;
}
