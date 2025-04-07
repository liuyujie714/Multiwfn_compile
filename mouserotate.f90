! Mouse rotate module, written by Yujie Liu, 2025-04-08

! Usage example:
! 1. add global variables to define.f90
!   integer :: startX = 0, startY = 0 ! mouse position
!   logical :: isDragging = .false.   ! mouse dragging status
!   
! 2. add it to gui function in GUI.f90, such as drawmolgui, ...
!   use defvar
!   use mouse_rotate_mod
!   call swgcbk(idisgraph, mouse_rotate)    ! register mouse callback

module mouse_rotate_mod
    use, intrinsic :: iso_c_binding
    implicit none
    
    type, bind(c) :: POINT
        integer(c_long) :: x, y
    end type
    
    type, bind(c) :: MSG
        integer(c_intptr_t) :: hwnd
        integer(c_int) :: message
        integer(c_intptr_t) :: wParam
        integer(c_intptr_t) :: lParam
        integer(c_int) :: time
        type(POINT) :: pt
    end type
    
    interface
        function SetCapture(hWnd) bind(c, name='SetCapture')
            use iso_c_binding
            integer(c_intptr_t) :: SetCapture
            integer(c_intptr_t), value :: hWnd
        end function
        
        function ReleaseCapture() bind(c, name='ReleaseCapture')
            use iso_c_binding
            logical(c_bool) :: ReleaseCapture
        end function
        
        function  GetActiveWindow() bind(c, name='GetActiveWindow')
            use iso_c_binding
            integer(c_intptr_t) :: GetActiveWindow
        end function
        
        function PeekMessage(lpMsg, hWnd, wMsgFilterMin, wMsgFilterMax, wRemoveMsg) bind(c, name='PeekMessageA')
            use iso_c_binding
            import :: MSG
            logical(c_bool) :: PeekMessage
            type(MSG) :: lpMsg
            integer(c_intptr_t), value :: hWnd
            integer(c_int), value :: wMsgFilterMin, wMsgFilterMax, wRemoveMsg
        end function
        
        function TranslateMessage(lpMsg) bind(c, name='TranslateMessage')
            use iso_c_binding
            import :: MSG
            logical(c_bool) :: TranslateMessage
            type(MSG) :: lpMsg
        end function
        
        function DispatchMessage(lpMsg) bind(c, name='DispatchMessageA')
            use iso_c_binding
            import :: MSG
            integer(c_intptr_t) :: DispatchMessage
            type(MSG) :: lpMsg
        end function
        
        subroutine Sleep(dwMilliseconds) bind(c, name='Sleep')
            use iso_c_binding
            integer(c_int), value :: dwMilliseconds
        end subroutine
    end interface
    
    ! message codes
    integer, parameter :: WM_LBUTTONDOWN = 513  !0x0201
    integer, parameter :: WM_LBUTTONUP = 514    !0x0202
    integer, parameter :: WM_MOUSEMOVE = 512    !0x0200
    integer, parameter :: WM_KILLFOCUS = 8      !0x0008
    integer, parameter :: PM_REMOVE = 1         !0x0001
    
contains
    
    subroutine mouse_rotate(id)
        use defvar
        use plot
        integer, intent(in) :: id
        type(MSG) :: current_msg 
        integer :: currentX, currentY, delx, dely
        integer(c_intptr_t) :: active_window
        logical(c_bool) :: dummy1
        integer(c_intptr_t) :: dummy2
        character tmpstr*20
        
        active_window = GetActiveWindow()
        if (active_window == 0) return
        dummy2 = SetCapture(active_window)
        
        do
            if (PeekMessage(current_msg, active_window, 0, 0, PM_REMOVE)) then
                dummy1 = TranslateMessage(current_msg)
                dummy2 = DispatchMessage(current_msg)
                
                select case (current_msg%message)
                case (WM_LBUTTONDOWN)
                    startX = iand(int(current_msg%lParam, kind=4), 65535_4)
                    startY = ishft(int(current_msg%lParam, kind=4), -16)
                    isDragging = .true.
                
                case (WM_MOUSEMOVE)
                    if (isDragging) then
                        currentX = iand(int(current_msg%lParam, kind=4), 65535_4)
                        currentY = ishft(int(current_msg%lParam, kind=4), -16)
                        delx = currentX - startX
                        dely = currentY - startY
                        
                        if (abs(delx) > 5 .or. abs(dely) > 5) then
                            XVU = XVU + delx * 0.5
                            YVU = YVU + dely * 0.5
                            
                            startX = currentX
                            startY = currentY
                            ! plot actions
                            if (GUI_mode/=2) then
                                call drawmol
                            else if (GUI_mode==2) then
                                call drawplane(dp_init1,dp_end1,dp_init2,dp_end2,dp_init3,dp_end3,idrawtype)
                                write(tmpstr,"(f8.2)") XVU
                                call SWGTXT(idissetplaneXVU,tmpstr)
                                write(tmpstr,"(f8.2)") YVU
                                call SWGTXT(idissetplaneYVU,tmpstr)
                            end if
                        end if
                    end if
                
                case (WM_LBUTTONUP)
                    if (ReleaseCapture()) then
                        isDragging = .false.
                    end if
                    return

                end select
            else
                call Sleep(1)
            end if
        end do
    end subroutine mouse_rotate
    
end module mouse_rotate_mod

