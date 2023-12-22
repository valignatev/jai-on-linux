//
// This file was auto-generated using the following command:
//
// jai generate.jai
//



XCB_SHM_MAJOR_VERSION :: 1;
XCB_SHM_MINOR_VERSION :: 2;

XCB_SHM_COMPLETION :: 0;

XCB_SHM_BAD_SEG :: 0;

XCB_SHM_QUERY_VERSION :: 0;

XCB_SHM_ATTACH :: 1;

XCB_SHM_DETACH :: 2;

XCB_SHM_PUT_IMAGE :: 3;

XCB_SHM_GET_IMAGE :: 4;

XCB_SHM_CREATE_PIXMAP :: 5;

XCB_SHM_ATTACH_FD :: 6;

XCB_SHM_CREATE_SEGMENT :: 7;

xcb_shm_id: xcb_extension_t;

xcb_shm_seg_t :: u32;

xcb_shm_seg_iterator_t :: struct {
    data:  *xcb_shm_seg_t;
    rem:   s32;
    index: s32;
}

xcb_shm_completion_event_t :: struct {
    response_type: u8;
    pad0:          u8;
    sequence:      u16;
    drawable:      xcb_drawable_t;
    minor_event:   u16;
    major_event:   u8;
    pad1:          u8;
    shmseg:        xcb_shm_seg_t;
    offset:        u32;
}

xcb_shm_bad_seg_error_t :: xcb_value_error_t;

xcb_shm_query_version_cookie_t :: struct {
    sequence: u32;
}

xcb_shm_query_version_request_t :: struct {
    major_opcode: u8;
    minor_opcode: u8;
    length:       u16;
}

xcb_shm_query_version_reply_t :: struct {
    response_type:  u8;
    shared_pixmaps: u8;
    sequence:       u16;
    length:         u32;
    major_version:  u16;
    minor_version:  u16;
    uid:            u16;
    gid:            u16;
    pixmap_format:  u8;
    pad0:           [15] u8;
}

xcb_shm_attach_request_t :: struct {
    major_opcode: u8;
    minor_opcode: u8;
    length:       u16;
    shmseg:       xcb_shm_seg_t;
    shmid:        u32;
    read_only:    u8;
    pad0:         [3] u8;
}

xcb_shm_detach_request_t :: struct {
    major_opcode: u8;
    minor_opcode: u8;
    length:       u16;
    shmseg:       xcb_shm_seg_t;
}

xcb_shm_put_image_request_t :: struct {
    major_opcode: u8;
    minor_opcode: u8;
    length:       u16;
    drawable:     xcb_drawable_t;
    gc:           xcb_gcontext_t;
    total_width:  u16;
    total_height: u16;
    src_x:        u16;
    src_y:        u16;
    src_width:    u16;
    src_height:   u16;
    dst_x:        s16;
    dst_y:        s16;
    depth:        u8;
    format:       u8;
    send_event:   u8;
    pad0:         u8;
    shmseg:       xcb_shm_seg_t;
    offset:       u32;
}

xcb_shm_get_image_cookie_t :: struct {
    sequence: u32;
}

xcb_shm_get_image_request_t :: struct {
    major_opcode: u8;
    minor_opcode: u8;
    length:       u16;
    drawable:     xcb_drawable_t;
    x:            s16;
    y:            s16;
    width:        u16;
    height:       u16;
    plane_mask:   u32;
    format:       u8;
    pad0:         [3] u8;
    shmseg:       xcb_shm_seg_t;
    offset:       u32;
}

xcb_shm_get_image_reply_t :: struct {
    response_type: u8;
    depth:         u8;
    sequence:      u16;
    length:        u32;
    visual:        xcb_visualid_t;
    size:          u32;
}

xcb_shm_create_pixmap_request_t :: struct {
    major_opcode: u8;
    minor_opcode: u8;
    length:       u16;
    pid:          xcb_pixmap_t;
    drawable:     xcb_drawable_t;
    width:        u16;
    height:       u16;
    depth:        u8;
    pad0:         [3] u8;
    shmseg:       xcb_shm_seg_t;
    offset:       u32;
}

xcb_shm_attach_fd_request_t :: struct {
    major_opcode: u8;
    minor_opcode: u8;
    length:       u16;
    shmseg:       xcb_shm_seg_t;
    read_only:    u8;
    pad0:         [3] u8;
}

xcb_shm_create_segment_cookie_t :: struct {
    sequence: u32;
}

xcb_shm_create_segment_request_t :: struct {
    major_opcode: u8;
    minor_opcode: u8;
    length:       u16;
    shmseg:       xcb_shm_seg_t;
    size:         u32;
    read_only:    u8;
    pad0:         [3] u8;
}

xcb_shm_create_segment_reply_t :: struct {
    response_type: u8;
    nfd:           u8;
    sequence:      u16;
    length:        u32;
    pad0:          [24] u8;
}

xcb_image_t :: struct {
    width:        u16;
    height:       u16;
    format:       xcb_image_format_t;
    scanline_pad: u8;

    depth:        u8;

    bpp:          u8;

    unit:         u8;

    plane_mask:   u32;

    byte_order:   xcb_image_order_t;

    bit_order:    xcb_image_order_t;

    stride:       u32;

    size:         u32;

    base:         *void;

    data:         *u8;
}

xcb_shm_segment_info_t :: struct {
    shmseg:  xcb_shm_seg_t;
    shmid:   u32;
    shmaddr: *u8;
}

XCB_Image_Procs :: struct #type_info_procedures_are_void_pointers {
    xcb_shm_seg_next:                   #type (i: *xcb_shm_seg_iterator_t) -> void #c_call;
    xcb_shm_seg_end:                    #type (i: xcb_shm_seg_iterator_t) -> xcb_generic_iterator_t #c_call;
    xcb_shm_query_version:              #type (c: *xcb_connection_t) -> xcb_shm_query_version_cookie_t #c_call;
    xcb_shm_query_version_unchecked:    #type (c: *xcb_connection_t) -> xcb_shm_query_version_cookie_t #c_call;
    xcb_shm_query_version_reply:        #type (c: *xcb_connection_t, cookie: xcb_shm_query_version_cookie_t, e: **xcb_generic_error_t) -> *xcb_shm_query_version_reply_t #c_call;
    xcb_shm_attach_checked:             #type (c: *xcb_connection_t, shmseg: xcb_shm_seg_t, shmid: u32, read_only: u8) -> xcb_void_cookie_t #c_call;
    xcb_shm_attach:                     #type (c: *xcb_connection_t, shmseg: xcb_shm_seg_t, shmid: u32, read_only: u8) -> xcb_void_cookie_t #c_call;
    xcb_shm_detach_checked:             #type (c: *xcb_connection_t, shmseg: xcb_shm_seg_t) -> xcb_void_cookie_t #c_call;
    xcb_shm_detach:                     #type (c: *xcb_connection_t, shmseg: xcb_shm_seg_t) -> xcb_void_cookie_t #c_call;
    xcb_shm_put_image_checked:          #type (c: *xcb_connection_t, drawable: xcb_drawable_t, gc: xcb_gcontext_t, total_width: u16, total_height: u16, src_x: u16, src_y: u16, src_width: u16, src_height: u16, dst_x: s16, dst_y: s16, depth: u8, format: u8, send_event: u8, shmseg: xcb_shm_seg_t, offset: u32) -> xcb_void_cookie_t #c_call;
    xcb_shm_put_image:                  #type (c: *xcb_connection_t, drawable: xcb_drawable_t, gc: xcb_gcontext_t, total_width: u16, total_height: u16, src_x: u16, src_y: u16, src_width: u16, src_height: u16, dst_x: s16, dst_y: s16, depth: u8, format: u8, send_event: u8, shmseg: xcb_shm_seg_t, offset: u32) -> xcb_void_cookie_t #c_call;
    xcb_shm_get_image:                  #type (c: *xcb_connection_t, drawable: xcb_drawable_t, x: s16, y: s16, width: u16, height: u16, plane_mask: u32, format: u8, shmseg: xcb_shm_seg_t, offset: u32) -> xcb_shm_get_image_cookie_t #c_call;
    xcb_shm_get_image_unchecked:        #type (c: *xcb_connection_t, drawable: xcb_drawable_t, x: s16, y: s16, width: u16, height: u16, plane_mask: u32, format: u8, shmseg: xcb_shm_seg_t, offset: u32) -> xcb_shm_get_image_cookie_t #c_call;
    xcb_shm_get_image_reply:            #type (c: *xcb_connection_t, cookie: xcb_shm_get_image_cookie_t, e: **xcb_generic_error_t) -> *xcb_shm_get_image_reply_t #c_call;
    xcb_shm_create_pixmap_checked:      #type (c: *xcb_connection_t, pid: xcb_pixmap_t, drawable: xcb_drawable_t, width: u16, height: u16, depth: u8, shmseg: xcb_shm_seg_t, offset: u32) -> xcb_void_cookie_t #c_call;
    xcb_shm_create_pixmap:              #type (c: *xcb_connection_t, pid: xcb_pixmap_t, drawable: xcb_drawable_t, width: u16, height: u16, depth: u8, shmseg: xcb_shm_seg_t, offset: u32) -> xcb_void_cookie_t #c_call;
    xcb_shm_attach_fd_checked:          #type (c: *xcb_connection_t, shmseg: xcb_shm_seg_t, shm_fd: s32, read_only: u8) -> xcb_void_cookie_t #c_call;
    xcb_shm_attach_fd:                  #type (c: *xcb_connection_t, shmseg: xcb_shm_seg_t, shm_fd: s32, read_only: u8) -> xcb_void_cookie_t #c_call;
    xcb_shm_create_segment:             #type (c: *xcb_connection_t, shmseg: xcb_shm_seg_t, size: u32, read_only: u8) -> xcb_shm_create_segment_cookie_t #c_call;
    xcb_shm_create_segment_unchecked:   #type (c: *xcb_connection_t, shmseg: xcb_shm_seg_t, size: u32, read_only: u8) -> xcb_shm_create_segment_cookie_t #c_call;
    xcb_shm_create_segment_reply:       #type (c: *xcb_connection_t, cookie: xcb_shm_create_segment_cookie_t, e: **xcb_generic_error_t) -> *xcb_shm_create_segment_reply_t #c_call;
    xcb_shm_create_segment_reply_fds:   #type (c: *xcb_connection_t, reply: *xcb_shm_create_segment_reply_t) -> *s32 #c_call;
    xcb_image_annotate:                 #type (image: *xcb_image_t) -> void #c_call;
    xcb_image_create:                   #type (width: u16, height: u16, format: xcb_image_format_t, xpad: u8, depth: u8, bpp: u8, unit: u8, byte_order: xcb_image_order_t, bit_order: xcb_image_order_t, base: *void, bytes: u32, data: *u8) -> *xcb_image_t #c_call;
    xcb_image_create_native:            #type (c: *xcb_connection_t, width: u16, height: u16, format: xcb_image_format_t, depth: u8, base: *void, bytes: u32, data: *u8) -> *xcb_image_t #c_call;
    xcb_image_destroy:                  #type (image: *xcb_image_t) -> void #c_call;
    xcb_image_get:                      #type (conn: *xcb_connection_t, draw: xcb_drawable_t, x: s16, y: s16, width: u16, height: u16, plane_mask: u32, format: xcb_image_format_t) -> *xcb_image_t #c_call;
    xcb_image_put:                      #type (conn: *xcb_connection_t, draw: xcb_drawable_t, gc: xcb_gcontext_t, image: *xcb_image_t, x: s16, y: s16, left_pad: u8) -> xcb_void_cookie_t #c_call;
    xcb_image_native:                   #type (c: *xcb_connection_t, image: *xcb_image_t, convert: s32) -> *xcb_image_t #c_call;
    xcb_image_put_pixel:                #type (image: *xcb_image_t, x: u32, y: u32, pixel: u32) -> void #c_call;
    xcb_image_get_pixel:                #type (image: *xcb_image_t, x: u32, y: u32) -> u32 #c_call;
    xcb_image_convert:                  #type (src: *xcb_image_t, dst: *xcb_image_t) -> *xcb_image_t #c_call;
    xcb_image_subimage:                 #type (image: *xcb_image_t, x: u32, y: u32, width: u32, height: u32, base: *void, bytes: u32, data: *u8) -> *xcb_image_t #c_call;
    xcb_image_shm_put:                  #type (conn: *xcb_connection_t, draw: xcb_drawable_t, gc: xcb_gcontext_t, image: *xcb_image_t, shminfo: xcb_shm_segment_info_t, src_x: s16, src_y: s16, dest_x: s16, dest_y: s16, src_width: u16, src_height: u16, send_event: u8) -> *xcb_image_t #c_call;
    xcb_image_shm_get:                  #type (conn: *xcb_connection_t, draw: xcb_drawable_t, image: *xcb_image_t, shminfo: xcb_shm_segment_info_t, x: s16, y: s16, plane_mask: u32) -> s32 #c_call;
    xcb_image_create_from_bitmap_data:  #type (data: *u8, width: u32, height: u32) -> *xcb_image_t #c_call;
    xcb_create_pixmap_from_bitmap_data: #type (display: *xcb_connection_t, d: xcb_drawable_t, data: *u8, width: u32, height: u32, depth: u32, fg: u32, bg: u32, gcp: *xcb_gcontext_t) -> xcb_pixmap_t #c_call;
}

#scope_file

