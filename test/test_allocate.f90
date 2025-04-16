program test
    implicit none
    
    integer,allocatable :: a_tmp(:), a(:)
    allocate(a(3))
    allocate(a(3))
    allocate(a_tmp(3))
    a = [1, 2, 3]
    
    a_tmp = a
    
    deallocate(a_tmp)
    
    a_tmp(1) = 8

end program test

