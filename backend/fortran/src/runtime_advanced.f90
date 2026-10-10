module babele_runtime_advanced
   implicit none
   private
   public :: fib, fact, is_prime, gcd

contains

   recursive function fib(n) result(r)
      integer, intent(in) :: n
      integer :: r
      if (n < 2) then
         r = n
      else
         r = fib(n - 1) + fib(n - 2)
      end if
   end function fib

   recursive function fact(n) result(r)
      integer, intent(in) :: n
      integer :: r
      if (n <= 1) then
         r = 1
      else
         r = n * fact(n - 1)
      end if
   end function fact

   function is_prime(n) result(r)
      integer, intent(in) :: n
      logical :: r
      integer :: i
      r = .true.
      if (n < 2) then
         r = .false.
         return
      end if
      do i = 2, int(sqrt(real(n)))
         if (mod(n, i) == 0) then
            r = .false.
            return
         end if
      end do
   end function is_prime

   recursive function gcd(a, b) result(r)
      integer, intent(in) :: a, b
      integer :: r
      if (b == 0) then
         r = a
      else
         r = gcd(b, mod(a, b))
      end if
   end function gcd

end module babele_runtime_advanced
