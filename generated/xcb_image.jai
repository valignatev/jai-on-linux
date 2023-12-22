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

xcb_shm_id: xcb_extension_t #elsewhere libxcb_image;

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

xcb_shm_seg_next :: (i: *xcb_shm_seg_iterator_t) -> void #foreign libxcb_image;

xcb_shm_seg_end :: (i: xcb_shm_seg_iterator_t) -> xcb_generic_iterator_t #foreign libxcb_image;

xcb_shm_query_version :: (c: *xcb_connection_t) -> xcb_shm_query_version_cookie_t #foreign libxcb_image;

xcb_shm_query_version_unchecked :: (c: *xcb_connection_t) -> xcb_shm_query_version_cookie_t #foreign libxcb_image;

xcb_shm_query_version_reply :: (c: *xcb_connection_t, cookie: xcb_shm_query_version_cookie_t, e: **xcb_generic_error_t) -> *xcb_shm_query_version_reply_t #foreign libxcb_image;

xcb_shm_attach_checked :: (c: *xcb_connection_t, shmseg: xcb_shm_seg_t, shmid: u32, read_only: u8) -> xcb_void_cookie_t #foreign libxcb_image;

xcb_shm_attach :: (c: *xcb_connection_t, shmseg: xcb_shm_seg_t, shmid: u32, read_only: u8) -> xcb_void_cookie_t #foreign libxcb_image;

xcb_shm_detach_checked :: (c: *xcb_connection_t, shmseg: xcb_shm_seg_t) -> xcb_void_cookie_t #foreign libxcb_image;

xcb_shm_detach :: (c: *xcb_connection_t, shmseg: xcb_shm_seg_t) -> xcb_void_cookie_t #foreign libxcb_image;

xcb_shm_put_image_checked :: (c: *xcb_connection_t, drawable: xcb_drawable_t, gc: xcb_gcontext_t, total_width: u16, total_height: u16, src_x: u16, src_y: u16, src_width: u16, src_height: u16, dst_x: s16, dst_y: s16, depth: u8, format: u8, send_event: u8, shmseg: xcb_shm_seg_t, offset: u32) -> xcb_void_cookie_t #foreign libxcb_image;

xcb_shm_put_image :: (c: *xcb_connection_t, drawable: xcb_drawable_t, gc: xcb_gcontext_t, total_width: u16, total_height: u16, src_x: u16, src_y: u16, src_width: u16, src_height: u16, dst_x: s16, dst_y: s16, depth: u8, format: u8, send_event: u8, shmseg: xcb_shm_seg_t, offset: u32) -> xcb_void_cookie_t #foreign libxcb_image;

xcb_shm_get_image :: (c: *xcb_connection_t, drawable: xcb_drawable_t, x: s16, y: s16, width: u16, height: u16, plane_mask: u32, format: u8, shmseg: xcb_shm_seg_t, offset: u32) -> xcb_shm_get_image_cookie_t #foreign libxcb_image;

xcb_shm_get_image_unchecked :: (c: *xcb_connection_t, drawable: xcb_drawable_t, x: s16, y: s16, width: u16, height: u16, plane_mask: u32, format: u8, shmseg: xcb_shm_seg_t, offset: u32) -> xcb_shm_get_image_cookie_t #foreign libxcb_image;

xcb_shm_get_image_reply :: (c: *xcb_connection_t, cookie: xcb_shm_get_image_cookie_t, e: **xcb_generic_error_t) -> *xcb_shm_get_image_reply_t #foreign libxcb_image;

xcb_shm_create_pixmap_checked :: (c: *xcb_connection_t, pid: xcb_pixmap_t, drawable: xcb_drawable_t, width: u16, height: u16, depth: u8, shmseg: xcb_shm_seg_t, offset: u32) -> xcb_void_cookie_t #foreign libxcb_image;

xcb_shm_create_pixmap :: (c: *xcb_connection_t, pid: xcb_pixmap_t, drawable: xcb_drawable_t, width: u16, height: u16, depth: u8, shmseg: xcb_shm_seg_t, offset: u32) -> xcb_void_cookie_t #foreign libxcb_image;

xcb_shm_attach_fd_checked :: (c: *xcb_connection_t, shmseg: xcb_shm_seg_t, shm_fd: s32, read_only: u8) -> xcb_void_cookie_t #foreign libxcb_image;

xcb_shm_attach_fd :: (c: *xcb_connection_t, shmseg: xcb_shm_seg_t, shm_fd: s32, read_only: u8) -> xcb_void_cookie_t #foreign libxcb_image;

xcb_shm_create_segment :: (c: *xcb_connection_t, shmseg: xcb_shm_seg_t, size: u32, read_only: u8) -> xcb_shm_create_segment_cookie_t #foreign libxcb_image;

xcb_shm_create_segment_unchecked :: (c: *xcb_connection_t, shmseg: xcb_shm_seg_t, size: u32, read_only: u8) -> xcb_shm_create_segment_cookie_t #foreign libxcb_image;

xcb_shm_create_segment_reply :: (c: *xcb_connection_t, cookie: xcb_shm_create_segment_cookie_t, e: **xcb_generic_error_t) -> *xcb_shm_create_segment_reply_t #foreign libxcb_image;

xcb_shm_create_segment_reply_fds :: (c: *xcb_connection_t, reply: *xcb_shm_create_segment_reply_t) -> *s32 #foreign libxcb_image;

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

xcb_image_annotate :: (image: *xcb_image_t) -> void #foreign libxcb_image;

xcb_image_create :: (width: u16, height: u16, format: xcb_image_format_t, xpad: u8, depth: u8, bpp: u8, unit: u8, byte_order: xcb_image_order_t, bit_order: xcb_image_order_t, base: *void, bytes: u32, data: *u8) -> *xcb_image_t #foreign libxcb_image;

xcb_image_create_native :: (c: *xcb_connection_t, width: u16, height: u16, format: xcb_image_format_t, depth: u8, base: *void, bytes: u32, data: *u8) -> *xcb_image_t #foreign libxcb_image;

xcb_image_destroy :: (image: *xcb_image_t) -> void #foreign libxcb_image;

xcb_image_get :: (conn: *xcb_connection_t, draw: xcb_drawable_t, x: s16, y: s16, width: u16, height: u16, plane_mask: u32, format: xcb_image_format_t) -> *xcb_image_t #foreign libxcb_image;

xcb_image_put :: (conn: *xcb_connection_t, draw: xcb_drawable_t, gc: xcb_gcontext_t, image: *xcb_image_t, x: s16, y: s16, left_pad: u8) -> xcb_void_cookie_t #foreign libxcb_image;

xcb_image_native :: (c: *xcb_connection_t, image: *xcb_image_t, convert: s32) -> *xcb_image_t #foreign libxcb_image;

xcb_image_put_pixel :: (image: *xcb_image_t, x: u32, y: u32, pixel: u32) -> void #foreign libxcb_image;

xcb_image_get_pixel :: (image: *xcb_image_t, x: u32, y: u32) -> u32 #foreign libxcb_image;

xcb_image_convert :: (src: *xcb_image_t, dst: *xcb_image_t) -> *xcb_image_t #foreign libxcb_image;

xcb_image_subimage :: (image: *xcb_image_t, x: u32, y: u32, width: u32, height: u32, base: *void, bytes: u32, data: *u8) -> *xcb_image_t #foreign libxcb_image;

xcb_image_shm_put :: (conn: *xcb_connection_t, draw: xcb_drawable_t, gc: xcb_gcontext_t, image: *xcb_image_t, shminfo: xcb_shm_segment_info_t, src_x: s16, src_y: s16, dest_x: s16, dest_y: s16, src_width: u16, src_height: u16, send_event: u8) -> *xcb_image_t #foreign libxcb_image;

xcb_image_shm_get :: (conn: *xcb_connection_t, draw: xcb_drawable_t, image: *xcb_image_t, shminfo: xcb_shm_segment_info_t, x: s16, y: s16, plane_mask: u32) -> s32 #foreign libxcb_image;

xcb_image_create_from_bitmap_data :: (data: *u8, width: u32, height: u32) -> *xcb_image_t #foreign libxcb_image;

xcb_create_pixmap_from_bitmap_data :: (display: *xcb_connection_t, d: xcb_drawable_t, data: *u8, width: u32, height: u32, depth: u32, fg: u32, bg: u32, gcp: *xcb_gcontext_t) -> xcb_pixmap_t #foreign libxcb_image;

#scope_file

libxcb_image :: #system_library "libxcb-image";
