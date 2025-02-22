XCB_LINKED :: false;

#if XCB_LINKED {
    #load "../generated/xcb.jai";
    #load "../generated/xcb_image.jai";
} else {
    #load "../generated/xcb_fp.jai";
    #load "../generated/xcb_image_fp.jai";

    using xcb_procs: XCB_Symbols;
    using xcb_image_procs: XCB_Image_Symbols;
}

WIDTH :: 640;
HEIGHT :: 480;

bitmap: []u8;

fill_color :: (r: u8, g: u8, b: u8) {
    for 0..WIDTH * HEIGHT - 1 {
        bitmap[it * 4 + 0] = b;
        bitmap[it * 4 + 1] = g;
        bitmap[it * 4 + 2] = r;
        bitmap[it * 4 + 3] = 128;
    }
}

load_procs :: (procs: *$T, libname: string) -> success := false {
    generic_c_call :: #type () #c_call;

    lib := dlopen(temp_c_string(libname), RTLD_NOW);
    if !lib {
        log_error("Failed to load %: %", libname, to_string(dlerror()));
        return false;
    }

    tis := cast(*Type_Info_Struct) type_info(T);
    for m : tis.members {
        pi := cast(*Type_Info_Procedure) m.type;
        dlerror();
        ppfn := cast(*generic_c_call)((cast(*u8) procs) + m.offset_in_bytes);
        ppfn.* = cast(generic_c_call) dlsym(lib, m.name.data);
        assert(!!(ppfn.*), "Failed to resolve function '%': %", m.name, to_string(dlerror()));
    }

    return true;
}

main :: () {
    #if !XCB_LINKED {
        load_procs(*xcb_procs, "libxcb.so");
        load_procs(*xcb_image_procs, "libxcb-image.so");
    }

    connection := xcb_connect(null, null);

    if !connection {
        exit(1);
    }

    screen := xcb_setup_roots_iterator(xcb_get_setup(connection)).data;
    window := xcb_generate_id(connection);
    xcb_create_window(
        c=connection,
        depth=XCB_COPY_FROM_PARENT,
        wid=window,
        parent=screen.root,
        x=0, y=0, width=WIDTH, height=HEIGHT, border_width=1,
        _class=.XCB_WINDOW_CLASS_INPUT_OUTPUT,
        visual=screen.root_visual,
        value_mask=.XCB_CW_BACK_PIXEL | .XCB_CW_EVENT_MASK,
        value_list=u32.[screen.white_pixel, xx (xcb_event_mask_t.XCB_EVENT_MASK_EXPOSURE | xcb_event_mask_t.XCB_EVENT_MASK_KEY_PRESS)].data,
    );

    pixmap := xcb_generate_id(connection);
    pixmap_format := xcb_setup_pixmap_formats(xcb_get_setup(connection));
    for 0..xcb_setup_pixmap_formats_length(xcb_get_setup(connection))-1 {
        if pixmap_format[it].depth == 24 && pixmap_format[it].bits_per_pixel == 32 {
            pixmap_format += it;
        }
    }

    xcb_create_pixmap(connection, screen.root_depth, pixmap, window, WIDTH, HEIGHT);
    graphics := xcb_generate_id(connection);
    xcb_create_gc(
        connection,
        graphics,
        pixmap,
        .XCB_GC_FOREGROUND | .XCB_GC_BACKGROUND,
        u32.[screen.black_pixel, screen.white_pixel].data,
    );

    bitmap, _ = NewArray(WIDTH * HEIGHT * 4, u8);
    fill_color(0x24, 0x26, 0x36);

    image := xcb_image_create(
        WIDTH, HEIGHT, .XCB_IMAGE_FORMAT_Z_PIXMAP,
        pixmap_format.scanline_pad,
        pixmap_format.depth,
        pixmap_format.bits_per_pixel,
        0,
        xcb_get_setup(connection).image_byte_order,
        .XCB_IMAGE_ORDER_LSB_FIRST,
        bitmap.data,
        // TODO: Maybe generate a wrapper that takes jai array?
        xx bitmap.count,
        bitmap.data,
    );

    xcb_image_put(connection, pixmap, graphics, image, 0, 0, 0);
    xcb_map_window(connection, window);
    xcb_flush(connection);

    should_quit := false;
    event: *xcb_generic_event_t;
    expose_event: *xcb_expose_event_t;
    key_press_event: *xcb_key_press_event_t;

    pulse: u8 = 0;
    while !should_quit {
        event = xcb_wait_for_event(connection);
        if event.response_type & ~0x80 == {
            case XCB_EXPOSE;
                expose_event = cast(*xcb_expose_event_t)event;
                xcb_copy_area(
                    connection,
                    pixmap,
                    window,
                    graphics,
                    xx expose_event.x, xx expose_event.y,
                    xx expose_event.x, xx expose_event.y,
                    expose_event.width, expose_event.height,
                );
                xcb_flush(connection);
            case XCB_KEY_PRESS;
                key_press_event = cast(*xcb_key_press_event_t)event;
                // This is ESC
                if key_press_event.detail == 9 should_quit = true;
        }
        pulse = (pulse + 1) % 255;
        fill_color(0x24 + pulse, 0x26 + pulse/2, 0x36 + pulse/4);
        xcb_image_put(connection, pixmap, graphics, image, 0, 0, 0);
        xcb_copy_area(connection, pixmap, window, graphics, 0, 0, 0, 0, WIDTH, HEIGHT);
        xcb_flush(connection);
    }
}

#import "Basic";
#import "POSIX";
#import "String";
