! events.f90
!
! Example that shows the capture of events.
!
! Author:  Philipp Engel
! Licence: ISC
program main
    use, intrinsic :: iso_c_binding
    use :: xlib
    implicit none
    integer              :: rc, screen
    integer(kind=c_long) :: black, white
    integer(kind=c_long) :: long(5)
    integer(kind=c_long) :: root, window
    integer(kind=c_long) :: wm_delete_window
    type(c_ptr)          :: display, gc
    type(x_event)        :: event
    type(x_gc_values)    :: values
    integer(c_long)      :: mask = 0

    ! Create window.
    display = x_open_display(c_null_char)
    screen  = x_default_screen(display)
    root    = x_default_root_window(display)

    black = x_black_pixel(display, screen)
    white = x_white_pixel(display, screen)

    window = x_create_simple_window(display, root, 0, 0, 300, 200, 0, black, white)

    ! Show window.
    mask = ior(BUTTON_PRESS_MASK, BUTTON_RELEASE_MASK)
    mask = ior(mask, BUTTON1_MOTION_MASK) ! left button
    mask = ior(mask, EXPOSURE_MASK) ! left button
    mask = ior(mask, STRUCTURE_NOTIFY_MASK) ! left button
    call x_select_input(display, window, mask)
    call x_map_window(display, window)

    ! Event loop.
    do
        print '(a)', 'waiting for event ...'
        call x_next_event(display, event)

        select case (event%type)
            case (BUTTON_PRESS)
                print *, 'BUTTON_PRESS'
            case (BUTTON_RELEASE)
                print *, 'BUTTON_RELEASE'
            case (MOTION_NOTIFY)
                print *, 'move....'
            case (expose)
                print *, 'Expose'
            case (configure_notify)
                print *, 'ConfigureNotify'
                print *, 'width:  ', event%x_configure%width
                print *, 'height: ', event%x_configure%height
            case (client_message)
                print *, 'ClientMessage'
                long = transfer(event%x_client_message%data, long)
                if (long(1) == wm_delete_window) exit
            case (key_press)
                print *, 'KeyPress'
			case (KEY_RELEASE)
				print *, 'KeyRelease'
        end select
    end do

    call x_destroy_window(display, window)
    call x_close_display(display)
end program main
