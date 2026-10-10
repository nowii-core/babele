! Runtime di Babele in Fortran
module babele_runtime
   implicit none
   private
   public :: babele_print

contains

   subroutine babele_print(s)
      character(len=*), intent(in) :: s
      print '(A)', trim(s)
   end subroutine babele_print

end module babele_runtime
