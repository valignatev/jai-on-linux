//
// This file was auto-generated using the following command:
//
// jai generate.jai
//



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

