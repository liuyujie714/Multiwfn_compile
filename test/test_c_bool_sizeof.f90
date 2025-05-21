program CC
  use, intrinsic :: iso_c_binding
  
  implicit none
  logical(c_bool) :: log = .true.
  logical :: log2 = .true.
  
  
  print *, 'log = ', log
  print *, 'log = ', log2
  
  print *, 'c_bool bytes', storage_size(log)/8  ! 转换为字节
  print *, 'native bool bytes:', storage_size(log2)/8  ! 转换为字节
  
end program CC




