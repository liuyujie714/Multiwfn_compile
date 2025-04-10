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
    
    call wgini('hori', ip)
    call swgwth(-60)
    call wgbas(ip, 'vert', ip1)
    call swgwth(-15)
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

    call myplot(id_scl1) 
    call wgfin()

contains

    subroutine myplot(id)
        integer, intent(in) :: id

        if (id == id_scl1) then
            call gwgscl(id, xrot1)
        else if (id == id_scl2) then
            call gwgscl(id, xrot2)
        end if
        
        write(*,*) "**************call metafl()************"
        call metafl('cons')
        call setxid(id_draw, 'widget')
        call scrmod('revers')
        CALL PAGE(3000,3000)
        CALL IMGFMT("RGB")
        write(*,*) "**************call disini()************"

        CALL GETLEV(lev)
        write(*, "('Current level: ', I4)") lev
        call disini()
        call erase()
        call hwfont()

        call name('X-axis', 'x')
        call name('Y-axis', 'y')
        call name('Z-axis', 'z')
        call labdig(-1, 'xyz')

        call axspos(585, 1800)
        call axslen(1800, 1800)

        call view3d(xrot1, xrot2, 6.0D0, 'angle')
        call height(40)
        call graf3d(0.0D0, 360D0, 0D0, 90D0, 0D0, 360D0, 0D0, 90D0, -3D0, 3D0, -3D0, 1D0)
        call surshd(xray, N, yray, N, zmat)
        write(*,*) "**************call disfin()************"
        call disfin()
    end subroutine myplot

end program dislin_3d_plot
