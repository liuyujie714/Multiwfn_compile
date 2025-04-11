program dislin_3d_plot
    use dislin
    implicit none

    integer, parameter :: N = 50
    integer :: id_draw, id_but, id_lab1, id_lab2, id_scl1, id_scl2
    double precision :: xrot1 = 50.0d0, xrot2 = 40.0d0
    double precision :: xray(N), yray(N), zmat(N,N)
    integer :: ip, ip1, ip2, i, j
    double precision :: step, x, y
    double precision, parameter :: fpi = 3.14159265358979323846d0 / 180.0d0

    ! Initialize data arrays
    step = 360.0d0 / dble(N-1)
    do i = 1, N
        x = dble(i-1)*step
        xray(i) = x
        do j = 1, N
            y = dble(j-1)*step
            yray(j) = y
            zmat(i,j) = 2.0d0 * sin(x*fpi) * sin(y*fpi)
        end do
    end do

    ! Create GUI widgets
    call swgtit('DISLIN 3D Plot')
    call swgopt('track', 'scroll')
    call swgopt('center', 'position')
    CALL SWGOPT("TRACK","SCROLL")
    
    call swgwth(70)
    call wgini('hori', ip)
    call wgbas(ip, 'vert', ip1)
    call swgwth(20)
    call wgbas(ip, 'vert', ip2)

    call swgdrw(2100D0/2970D0)
    call wglab(ip1, 'DISLIN 3D Plot:', id_lab2)
    call wgdraw(ip1, id_draw)

    call wglab(ip2, 'Azimuthal Rotation Angle:', id_lab1)
    call wgscl(ip2, ' ', 0.0d0, 360.0d0, 50.0d0, -1, id_scl1)
    call wglab(ip2, 'Polar Rotation Angle:', id_lab1)
    call wgscl(ip2, ' ', -90.0d0, 90.0d0, 40.0d0, -1, id_scl2)
    call swgcbk(id_scl1, myplot) 
    call swgcbk(id_scl2, myplot) 
    call REAWGT

    do i = 1, N
        step = dble(i)*10
        if (step <= 360D0) then
            call swgscl(id_scl1, step)
            call myplot(id_scl1) 
!             call doevnt
        end if 
    end do
    
    call wgfin()

contains
    subroutine myplot(id)
        integer, intent(in) :: id
        integer :: lev

        if (id == id_scl1) then
            call gwgscl(id, xrot1)
        else if (id == id_scl2) then
            call gwgscl(id, xrot2)
        end if
        
        
        CALL GETLEV(lev)
        write(*, "('Current level: ', I4)") lev
        if (lev /= 0) then
            write(*, *) "*******************Level ERROR*******************"
        end if
        
        call metafl('cons')
        call setxid(id_draw, 'widget')
        call scrmod('revers')
        CALL PAGE(3000,3000)
        CALL IMGFMT("RGB")
        
        write(*,*) "**************call disini()************"
        call disini()
        call erase()
        call hwfont()

        call name('X-axis', 'x')
        call name('Y-axis', 'y')
        call name('Z-axis', 'z')
        call labdig(-1, 'xyz')

        call axspos(700, 2800)
        call axslen(2100, 2100)

        call view3d(xrot1, xrot2, 6.0D0, 'angle')
        call height(40)
        call graf3d(0.0D0, 360D0, 0D0, 90D0, 0D0, 360D0, 0D0, 90D0, -3D0, 3D0, -3D0, 1D0)
        call surshd(xray, N, yray, N, zmat)
        call disfin()
        write(*,*) "**************call disfin()************"
        
    end subroutine myplot

end program dislin_3d_plot



! PROGRAM pgbar
!     use dislin
!     INTEGER ip,idbut,idpause,ival,idquit,idpr,isstop
!     isstop = 0
!     CALL SWGWTH(50)
!     CALL SWGTIT("PGBAR TEST")
!     CALL WGINI('VERT', ip)  
!     call swgopt("smooth", "pbar");
!     call swgopt("label", "pbar");  
!     call swgclr(0D0, 1D0, 0D0, "pbar");
!     CALL WGPBAR(ip,0D0,100D0,1D0,idscal)
!     CALL wgbut(ip, 'Start', 0, idbut)
!     CALL wgbut(ip, 'STOP', isstop, idpause)
!     CALL swgcbk(idbut, runprog)
!     CALL swgcbk(idpause, runprog)
!     CALL wgquit(ip, idquit)
!     CALL WGFIN

!     CONTAINS

!     SUBROUTINE runprog(id)
!     integer,intent (in) :: id
!     INTEGER*4 I,NIT
!     REAL*8 ipr
!     NIT = 1000000
!     DO I=1,NIT
!         IF (modulo(I,CEILING(REAL(NIT)/100.0)) == 0) THEN 
!             ipr = 100.0*i/NIT
!             write(*,*) ipr
!             CALL swgval(idscal,ipr)
!             call doevnt
!             call sleep(1)
!         END IF       
!     END DO
!     END SUBROUTINE runprog
! END PROGRAM PGBAR

