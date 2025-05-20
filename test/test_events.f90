! events.f90
!
! Example that shows the capture of events.
!
! Author:  Philipp Engel
! Licence: ISC


module MyLib
    use, intrinsic :: iso_c_binding
    implicit none

    integer(c_long), parameter :: None          = 0     
    integer(c_int), parameter :: GrabModeSync   = 0
    integer(c_int), parameter :: GrabModeAsync  = 1
    integer(c_int), parameter :: AnyModifier    = ishft(1, 15)
    integer(c_int), parameter :: AnyButton      = 0
    integer(c_int), parameter :: AnyKey         = 0

    interface
    function XGrabButton(display, button, modifiers, grab_window, owner_events, &
        event_mask, pointer_mode, keyboard_mode, confine_to, cursor) &
        bind(c, name="XGrabButton")
        import :: c_ptr, c_int, c_long, c_bool
        type(c_ptr), value :: display
        integer(c_int), value :: button
        integer(c_int), value :: modifiers
        integer(c_long), value :: grab_window
        logical(c_bool), value :: owner_events
        integer(c_int), value :: event_mask
        integer(c_int), value :: pointer_mode
        integer(c_int), value :: keyboard_mode
        integer(c_long), value :: confine_to
        integer(c_long), value :: cursor
        integer(c_int) :: XGrabButton
    end function XGrabButton

    function XGrabKey(display, keycode, modifiers, grab_window, owner_events, &
        pointer_mode, keyboard_mode) bind(C, name='XGrabKey')
        import :: c_int, c_ptr, c_long, c_bool
        type(c_ptr), value :: display
        integer(c_int), value :: keycode, modifiers
        integer(c_long), value :: grab_window
        logical(c_bool), value :: owner_events
        integer(c_int), value :: pointer_mode, keyboard_mode
        integer(c_int) :: XGrabKey
    end function
    end interface
end module MyLib

program main
    use, intrinsic :: iso_c_binding
    use :: xlib
    use :: MyLib
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
    logical(c_bool) :: owner_events = .true.
    integer(c_int) :: status

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
    mask = ior(mask, POINTER_MOTION_MASK) ! left button
    mask = ior(mask, EXPOSURE_MASK) ! left button

    status = XGrabButton(display, AnyButton, AnyModifier, window, owner_events, &
    int(mask, 4), GrabModeAsync, GrabModeAsync, None, None)

    status = XGrabKey(display, AnyKey, AnyModifier, window, owner_events, &
    GrabModeAsync, GrabModeAsync)


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
