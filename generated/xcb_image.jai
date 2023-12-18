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

/**
* @struct xcb_image_t
* A structure that describes an xcb_image_t.
*/
xcb_image_t :: struct {
    width:        u16; /**< Width in pixels, excluding pads etc. */
    height:       u16; /**< Height in pixels. */
    format:       xcb_image_format_t; /**< Format. */
    /**< Right pad in bits.  Valid pads
    *   are 8, 16, 32.
    */
    scanline_pad: u8;

    /**< Depth in bits. Valid depths
    *   are 1, 4, 8, 16, 24 for z format,
    *   1 for xy-bitmap-format, anything
    *   for xy-pixmap-format.
    */
    depth:        u8;

    /**< Storage per pixel in bits.
    *   Must be >= depth. Valid bpp
    *   are 1, 4, 8, 16, 24, 32 for z
    *   format, 1 for xy-bitmap format,
    *   anything for xy-pixmap-format.
    */
    bpp:          u8;

    /**< Scanline unit in bits for
    *   xy formats and for bpp == 1,
    *   in which case valid scanline
    *   units are 8, 16, 32.  Otherwise,
    *   will be max(8, bpp).  Must be >= bpp.
    */
    unit:         u8;

    /**< When format is
    *   xy-pixmap and depth >
    *   1, this says which
    *   planes are "valid" in
    *   some vague sense.
    *   Currently used only
    *   by xcb_image_get/put_pixel(),
    *   and set only by
    *   xcb_image_get().
    */
    plane_mask:   u32;

    /**< Component byte order
    *   for z-pixmap, byte
    *   order of scanline unit
    *   for xy-bitmap and
    *   xy-pixmap.  Nybble
    *   order for z-pixmap
    *   when bpp == 4.
    */
    byte_order:   xcb_image_order_t;

    /**< Bit order of
    *   scanline unit for
    *   xy-bitmap and
    *   xy-pixmap.
    */
    bit_order:    xcb_image_order_t;

    /**< Bytes per image row.
    *   Computable from other
    *   data, but cached for
    *   convenience/performance.
    */
    stride:       u32;

    /**< Size of image data in bytes.
    *   Computable from other
    *   data, but cached for
    *   convenience/performance.
    */
    size:         u32;

    /**< Malloced block of storage that
    *   will be freed by
    *   @ref xcb_image_destroy() if non-null.
    */
    base:         *void;

    data:         *u8; /**< The actual image. */
}

/**
* @struct xcb_shm_segment_info_t
* A structure that stores the informations needed by the MIT Shm
* Extension.
*/
xcb_shm_segment_info_t :: struct {
    shmseg:  xcb_shm_seg_t;
    shmid:   u32;
    shmaddr: *u8;
}

/**
* Update the cached data of an image.
* @param image The image.
*
* An image's size and stride, among other things, are
* cached in its structure.  This function recomputes those
* cached values for the given image.
* @ingroup xcb__image_t
*/
xcb_image_annotate :: (image: *xcb_image_t) -> void #foreign libxcb_image;

/**
* Create a new image.
* @param width The width of the image, in pixels.
* @param height The height of the image, in pixels.
* @param format The format of the image.
* @param xpad The scanline pad of the image.
* @param depth The depth of the image.
* @param bpp The depth of the image storage.
* @param unit The unit of image representation, in bits.
* @param byte_order The byte order of the image.
* @param bit_order The bit order of the image.
* @param base The base address of malloced image data.
* @param bytes The size in bytes of the storage pointed to by base.
*              If base == 0 and bytes == ~0 and data == 0 on
*              entry, no storage will be auto-allocated.
* @param data The image data.  If data is null and bytes != ~0, then
*             an attempt will be made to fill in data; from
*             base if it is non-null (and bytes is large enough), else
*             by mallocing sufficient storage and filling in base.
* @return The new image.
*
* This function allocates the memory needed for an @ref xcb_image_t structure
* with the given properties.  See the description of xcb_image_t for details.
* This function initializes and returns a pointer to the
* xcb_image_t structure.  It may try to allocate or reserve data for the
* structure, depending on how @p base, @p bytes and @p data are set.
*
* The image must be destroyed with xcb_image_destroy().
* @ingroup xcb__image_t
*/
xcb_image_create :: (width: u16, height: u16, format: xcb_image_format_t, xpad: u8, depth: u8, bpp: u8, unit: u8, byte_order: xcb_image_order_t, bit_order: xcb_image_order_t, base: *void, bytes: u32, data: *u8) -> *xcb_image_t #foreign libxcb_image;

/**
* Create a new image in connection-native format.
* @param c The connection.
* @param width The width of the image, in pixels.
* @param height The height of the image, in pixels.
* @param format The format of the image.
* @param depth The depth of the image.
* @param base The base address of malloced image data.
* @param bytes The size in bytes of the storage pointed to by base.
*              If base == 0 and bytes == ~0 and data == 0 on
*              entry, no storage will be auto-allocated.
* @param data The image data.  If data is null and bytes != ~0, then
*             an attempt will be made to fill in data; from
*             base if it is non-null (and bytes is large enough), else
*             by mallocing sufficient storage and filling in base.
* @return The new image.
*
* This function calls @ref xcb_image_create() with the given
* properties, and with the remaining properties chosen
* according to the "native format" with the given
* properties on the current connection.
*
* It is usual to use this rather
* than calling xcb_image_create() directly.
* @ingroup xcb__image_t
*/
xcb_image_create_native :: (c: *xcb_connection_t, width: u16, height: u16, format: xcb_image_format_t, depth: u8, base: *void, bytes: u32, data: *u8) -> *xcb_image_t #foreign libxcb_image;

/**
* Destroy an image.
* @param image The image to be destroyed.
*
* This function frees the memory associated with the @p image
* parameter.  If its base pointer is non-null, it frees
* that also.
* @ingroup xcb__image_t
*/
xcb_image_destroy :: (image: *xcb_image_t) -> void #foreign libxcb_image;

/**
* Get an image from the X server.
* @param conn The connection to the X server.
* @param draw The drawable to get the image from.
* @param x The x coordinate in pixels, relative to the origin of the
* drawable and defining the upper-left corner of the rectangle.
* @param y The y coordinate in pixels, relative to the origin of the
* drawable and defining the upper-left corner of the rectangle.
* @param width The width of the subimage in pixels.
* @param height The height of the subimage in pixels.
* @param plane_mask The plane mask.  See the protocol document for details.
* @param format The format of the image.
* @return The subimage of @p draw defined by @p x, @p y, @p w, @p h.
*

* This function returns a new image taken from the
* given drawable @p draw.
* The image will be in connection native format. If the @p format
* is xy-bitmap and the @p plane_mask masks bit planes out, those
* bit planes will be made part of the returned image anyway,
* by zero-filling them; this will require a fresh memory allocation
* and some copying.  Otherwise, the resulting image will use the
* xcb_get_image_reply() record as its backing store.
*
* If a problem occurs, the function returns null.
* @ingroup xcb__image_t
*/
xcb_image_get :: (conn: *xcb_connection_t, draw: xcb_drawable_t, x: s16, y: s16, width: u16, height: u16, plane_mask: u32, format: xcb_image_format_t) -> *xcb_image_t #foreign libxcb_image;

/**
* Put an image onto the X server.
* @param conn The connection to the X server.
* @param draw The draw you get the image from.
* @param gc The graphic context.
* @param image The image you want to combine with the rectangle.
* @param x The x coordinate, which is relative to the origin of the
* drawable and defines the x coordinate of the upper-left corner of the
* rectangle.
* @param y The y coordinate, which is relative to the origin of the
* drawable and defines the x coordinate of the upper-left corner of
* the rectangle.
* @param left_pad Notionally shift an xy-bitmap or xy-pixmap image
* to the right some small amount, for some reason.  XXX Not clear
* this is currently supported correctly.
* @return The cookie returned by xcb_put_image().
*
* This function combines an image with a rectangle of the
* specified drawable @p draw. The image must be in native
* format for the connection.  The image is drawn at the
* specified location in the drawable. For the xy-bitmap
* format, the foreground pixel in @p gc defines the source
* for the one bits in the image, and the background pixel
* defines the source for the zero bits. For xy-pixmap and
* z-pixmap formats, the depth of the image must match the
* depth of the drawable; the gc is ignored.
*
* @ingroup xcb__image_t
*/
xcb_image_put :: (conn: *xcb_connection_t, draw: xcb_drawable_t, gc: xcb_gcontext_t, image: *xcb_image_t, x: s16, y: s16, left_pad: u8) -> xcb_void_cookie_t #foreign libxcb_image;

/**
* Check image for or convert image to native format.
* @param c The connection to the X server.
* @param image The image.
* @param convert  If 0, just check the image for native format.
* Otherwise, actually convert it.
* @return Null if the image is not in native format and can or will not
* be converted.  Otherwise, the native format image.
*
* Each X display has its own "native format" for images of a given
* format and depth.  This function either checks whether the given
* @p image is in native format for the given connection @p c, or
* actually tries to convert the image to native format, depending
* on whether @p convert is true or false.
*
* When @p convert is true, and the image is not in native format
* but can be converted, it will be, and a pointer to the new image
* will be returned.  The image passed in will be unharmed in this
* case; it is the caller's responsibility to check that the returned
* pointer is different and to dispose of the old image if desired.
* @ingroup xcb__image_t
*/
xcb_image_native :: (c: *xcb_connection_t, image: *xcb_image_t, convert: s32) -> *xcb_image_t #foreign libxcb_image;

/**
* Put a pixel to an image.
* @param image The image.
* @param x The x coordinate of the pixel.
* @param y The y coordinate of the pixel.
* @param pixel The new pixel value.
*
* This function overwrites the pixel in the given @p image with the
* specified @p pixel value (in client format). The image must contain the @p x
* and @p y coordinates, as no clipping is done.  This function honors
* the plane-mask for xy-pixmap images.
* @ingroup xcb__image_t
*/
xcb_image_put_pixel :: (image: *xcb_image_t, x: u32, y: u32, pixel: u32) -> void #foreign libxcb_image;

/**
* Get a pixel from an image.
* @param image The image.
* @param x The x coordinate of the pixel.
* @param y The y coordinate of the pixel.
* @return The pixel value.
*
* This function retrieves a pixel from the given @p image.
* The image must contain the @p x
* and @p y coordinates, as no clipping is done.  This function honors
* the plane-mask for xy-pixmap images.
* @ingroup xcb__image_t
*/
xcb_image_get_pixel :: (image: *xcb_image_t, x: u32, y: u32) -> u32 #foreign libxcb_image;

/**
* Convert an image to a new format.
* @param src Source image.
* @param dst Destination image.
* @return The @p dst image, or null on error.
*
* This function tries to convert the image data of the @p
* src image to the format implied by the @p dst image,
* overwriting the current destination image data.
* The source and destination must have the same
* width, height, and depth.  When the source and destination
* are already the same format, a simple copy is done.  Otherwise,
* when the destination has the same bits-per-pixel/scanline-unit
* as the source, an optimized copy routine (thanks to Keith Packard)
* is used for the conversion.  Otherwise, the copy is done the
* slow, slow way with @ref xcb_image_get_pixel() and
* @ref xcb_image_put_pixel() calls.
* @ingroup xcb__image_t
*/
xcb_image_convert :: (src: *xcb_image_t, dst: *xcb_image_t) -> *xcb_image_t #foreign libxcb_image;

/**
* Extract a subimage of an image.
* @param image Source image.
* @param x X coordinate of subimage.
* @param y Y coordinate of subimage.
* @param width Width of subimage.
* @param height Height of subimage.
* @param base Base of memory allocation.
* @param bytes Size of base allocation.
* @param data Memory allocation.
* @return The subimage, or null on error.
*
* Given an image, this function extracts the subimage at the
* given coordinates.  The requested subimage must be entirely
* contained in the source @p image.  The resulting image will have the same
* general image parameters as the source image.  The @p base, @p bytes,
* and @p data arguments are passed to @ref xcb_create_image() unaltered
* to create the destination image---see its documentation for details.
*
* @ingroup xcb__image_t
*/
xcb_image_subimage :: (image: *xcb_image_t, x: u32, y: u32, width: u32, height: u32, base: *void, bytes: u32, data: *u8) -> *xcb_image_t #foreign libxcb_image;

/**
* Put the data of an xcb_image_t onto a drawable using the MIT Shm
* Extension.
* @param conn The connection to the X server.
* @param draw The draw you get the image from.
* @param gc The graphic context.
* @param image The image you want to combine with the rectangle.
* @param shminfo A @ref xcb_shm_segment_info_t structure.
* @param src_x The offset in x from the left edge of the image
* defined by the xcb_image_t structure.
* @param src_y The offset in y from the left edge of the image
* defined by the xcb_image_t structure.
* @param dest_x The x coordinate, which is relative to the origin of the
* drawable and defines the x coordinate of the upper-left corner of the
* rectangle.
* @param dest_y The y coordinate, which is relative to the origin of the
* drawable and defines the x coordinate of the upper-left corner of
* the rectangle.
* @param src_width The width of the subimage, in pixels.
* @param src_height The height of the subimage, in pixels.
* @param send_event Indicates whether or not a completion event
* should occur when the image write is complete.
* @return a pointer to the source image if no problem occurs, otherwise 0.
*
* This function combines an image in memory with a shape of the
* specified drawable. The section of the image defined by the @p x, @p y,
* @p width, and @p height arguments is drawn on the specified part of
* the drawable. If XYBitmap format is used, the depth must be
* one, or a``BadMatch'' error results. The foreground pixel in the
* Graphic Context @p gc defines the source for the one bits in the
* image, and the background pixel defines the source for the zero
* bits. For XYPixmap and ZPixmap, the depth must match the depth of
* the drawable, or a ``BadMatch'' error results.
*
* @ingroup xcb__image_t
*/
xcb_image_shm_put :: (conn: *xcb_connection_t, draw: xcb_drawable_t, gc: xcb_gcontext_t, image: *xcb_image_t, shminfo: xcb_shm_segment_info_t, src_x: s16, src_y: s16, dest_x: s16, dest_y: s16, src_width: u16, src_height: u16, send_event: u8) -> *xcb_image_t #foreign libxcb_image;

/**
* Read image data into a shared memory xcb_image_t.
* @param conn The connection to the X server.
* @param draw The draw you get the image from.
* @param image The image you want to combine with the rectangle.
* @param shminfo A @ref xcb_shm_segment_info_t structure.
* @param x The x coordinate, which are relative to the origin of the
* drawable and define the upper-left corner of the rectangle.
* @param y The y coordinate, which are relative to the origin of the
* drawable and define the upper-left corner of the rectangle.
* @param plane_mask The plane mask.
* @return The subimage of @p draw defined by @p x, @p y, @p w, @p h.
*
* This function reads image data into a shared memory xcb_image_t where
* @p conn is the connection to the X server, @p draw is the source
* drawable, @p image is the destination xcb_image_t, @p x and @p y are offsets
* within the drawable, and @p plane_mask defines which planes are to be
* read.
*
* If a problem occurs, the function returns @c 0. It returns 1
* otherwise.
* @ingroup xcb__image_t
*/
xcb_image_shm_get :: (conn: *xcb_connection_t, draw: xcb_drawable_t, image: *xcb_image_t, shminfo: xcb_shm_segment_info_t, x: s16, y: s16, plane_mask: u32) -> s32 #foreign libxcb_image;

/**
* Create an image from user-supplied bitmap data.
* @param data Image data in packed bitmap format.
* @param width Width in bits of image data.
* @param height Height in bits of image data.
* @return The image constructed from the image data, or 0 on error.
*
* This function creates an image from the user-supplied
* bitmap @p data.  The bitmap data is assumed to be in
* xbm format (i.e., 8-bit scanline unit, LSB-first, 8-bit pad).
* @ingroup xcb__image_t
*/
xcb_image_create_from_bitmap_data :: (data: *u8, width: u32, height: u32) -> *xcb_image_t #foreign libxcb_image;

/**
* Create a pixmap from user-supplied bitmap data.
* @param display The connection to the X server.
* @param d The parent drawable for the pixmap.
* @param data Image data in packed bitmap format.
* @param width Width in bits of image data.
* @param height Height in bits of image data.
* @param depth Depth of the desired pixmap.
* @param fg Pixel for one-bits of pixmaps with depth larger than one.
* @param bg Pixel for zero-bits of pixmaps with depth larger than one.
* @param gcp If this pointer is non-null, the GC created to
* fill in the pixmap is stored here; it will have its foreground
* and background set to the supplied value.  Otherwise, the GC
* will be freed.
* @return The pixmap constructed from the image data, or 0 on error.
*
* This function creates a pixmap from the user-supplied
* bitmap @p data.  The bitmap data is assumed to be in
* xbm format (i.e., 8-bit scanline unit, LSB-first, 8-bit pad).
* If @p depth is greater than 1, the
* bitmap will be expanded to a pixmap using the given
* foreground and background pixels @p fg and @p bg.
* @ingroup xcb__image_t
*/
xcb_create_pixmap_from_bitmap_data :: (display: *xcb_connection_t, d: xcb_drawable_t, data: *u8, width: u32, height: u32, depth: u32, fg: u32, bg: u32, gcp: *xcb_gcontext_t) -> xcb_pixmap_t #foreign libxcb_image;

#scope_file

libxcb_image :: #system_library "libxcb-image";
