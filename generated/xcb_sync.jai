//
// This file was auto-generated using the following command:
//
// jai generate_bindings.jai
//



XCB_SYNC_MAJOR_VERSION :: 3;
XCB_SYNC_MINOR_VERSION :: 1;

XCB_SYNC_COUNTER :: 0;

XCB_SYNC_ALARM :: 1;

XCB_SYNC_INITIALIZE :: 0;

XCB_SYNC_LIST_SYSTEM_COUNTERS :: 1;

XCB_SYNC_CREATE_COUNTER :: 2;

XCB_SYNC_DESTROY_COUNTER :: 6;

XCB_SYNC_QUERY_COUNTER :: 5;

XCB_SYNC_AWAIT :: 7;

XCB_SYNC_CHANGE_COUNTER :: 4;

XCB_SYNC_SET_COUNTER :: 3;

XCB_SYNC_CREATE_ALARM :: 8;

XCB_SYNC_CHANGE_ALARM :: 9;

XCB_SYNC_DESTROY_ALARM :: 11;

XCB_SYNC_QUERY_ALARM :: 10;

XCB_SYNC_SET_PRIORITY :: 12;

XCB_SYNC_GET_PRIORITY :: 13;

XCB_SYNC_CREATE_FENCE :: 14;

XCB_SYNC_TRIGGER_FENCE :: 15;

XCB_SYNC_RESET_FENCE :: 16;

XCB_SYNC_DESTROY_FENCE :: 17;

XCB_SYNC_QUERY_FENCE :: 18;

XCB_SYNC_AWAIT_FENCE :: 19;

XCB_SYNC_COUNTER_NOTIFY :: 0;

XCB_SYNC_ALARM_NOTIFY :: 1;

xcb_sync_id: xcb_extension_t #elsewhere libxcb_sync;

xcb_sync_alarm_t :: u32;

xcb_sync_alarm_iterator_t :: struct {
    data:  *xcb_sync_alarm_t;
    rem:   s32;
    index: s32;
}

xcb_sync_alarmstate_t :: enum u32 {
    ACTIVE    :: 0;
    INACTIVE  :: 1;
    DESTROYED :: 2;

    XCB_SYNC_ALARMSTATE_ACTIVE    :: ACTIVE;
    XCB_SYNC_ALARMSTATE_INACTIVE  :: INACTIVE;
    XCB_SYNC_ALARMSTATE_DESTROYED :: DESTROYED;
}

xcb_sync_counter_t :: u32;

xcb_sync_counter_iterator_t :: struct {
    data:  *xcb_sync_counter_t;
    rem:   s32;
    index: s32;
}

xcb_sync_fence_t :: u32;

xcb_sync_fence_iterator_t :: struct {
    data:  *xcb_sync_fence_t;
    rem:   s32;
    index: s32;
}

xcb_sync_testtype_t :: enum u32 {
    POSITIVE_TRANSITION :: 0;
    NEGATIVE_TRANSITION :: 1;
    POSITIVE_COMPARISON :: 2;
    NEGATIVE_COMPARISON :: 3;

    XCB_SYNC_TESTTYPE_POSITIVE_TRANSITION :: POSITIVE_TRANSITION;
    XCB_SYNC_TESTTYPE_NEGATIVE_TRANSITION :: NEGATIVE_TRANSITION;
    XCB_SYNC_TESTTYPE_POSITIVE_COMPARISON :: POSITIVE_COMPARISON;
    XCB_SYNC_TESTTYPE_NEGATIVE_COMPARISON :: NEGATIVE_COMPARISON;
}

xcb_sync_valuetype_t :: enum u32 {
    ABSOLUTE :: 0;
    RELATIVE :: 1;

    XCB_SYNC_VALUETYPE_ABSOLUTE :: ABSOLUTE;
    XCB_SYNC_VALUETYPE_RELATIVE :: RELATIVE;
}

xcb_sync_ca_t :: enum u32 {
    COUNTER    :: 1;
    VALUE_TYPE :: 2;
    VALUE      :: 4;
    TEST_TYPE  :: 8;
    DELTA      :: 16;
    EVENTS     :: 32;

    XCB_SYNC_CA_COUNTER    :: COUNTER;
    XCB_SYNC_CA_VALUE_TYPE :: VALUE_TYPE;
    XCB_SYNC_CA_VALUE      :: VALUE;
    XCB_SYNC_CA_TEST_TYPE  :: TEST_TYPE;
    XCB_SYNC_CA_DELTA      :: DELTA;
    XCB_SYNC_CA_EVENTS     :: EVENTS;
}

xcb_sync_int64_t :: struct {
    hi: s32;
    lo: u32;
}

xcb_sync_int64_iterator_t :: struct {
    data:  *xcb_sync_int64_t;
    rem:   s32;
    index: s32;
}

xcb_sync_systemcounter_t :: struct {
    counter:    xcb_sync_counter_t;
    resolution: xcb_sync_int64_t;
    name_len:   u16;
}

xcb_sync_systemcounter_iterator_t :: struct {
    data:  *xcb_sync_systemcounter_t;
    rem:   s32;
    index: s32;
}

xcb_sync_trigger_t :: struct {
    counter:    xcb_sync_counter_t;
    wait_type:  u32;
    wait_value: xcb_sync_int64_t;
    test_type:  u32;
}

xcb_sync_trigger_iterator_t :: struct {
    data:  *xcb_sync_trigger_t;
    rem:   s32;
    index: s32;
}

xcb_sync_waitcondition_t :: struct {
    trigger:         xcb_sync_trigger_t;
    event_threshold: xcb_sync_int64_t;
}

xcb_sync_waitcondition_iterator_t :: struct {
    data:  *xcb_sync_waitcondition_t;
    rem:   s32;
    index: s32;
}

xcb_sync_counter_error_t :: struct {
    response_type: u8;
    error_code:    u8;
    sequence:      u16;
    bad_counter:   u32;
    minor_opcode:  u16;
    major_opcode:  u8;
}

xcb_sync_alarm_error_t :: struct {
    response_type: u8;
    error_code:    u8;
    sequence:      u16;
    bad_alarm:     u32;
    minor_opcode:  u16;
    major_opcode:  u8;
}

xcb_sync_initialize_cookie_t :: struct {
    sequence: u32;
}

xcb_sync_initialize_request_t :: struct {
    major_opcode:          u8;
    minor_opcode:          u8;
    length:                u16;
    desired_major_version: u8;
    desired_minor_version: u8;
}

xcb_sync_initialize_reply_t :: struct {
    response_type: u8;
    pad0:          u8;
    sequence:      u16;
    length:        u32;
    major_version: u8;
    minor_version: u8;
    pad1:          [22] u8;
}

xcb_sync_list_system_counters_cookie_t :: struct {
    sequence: u32;
}

xcb_sync_list_system_counters_request_t :: struct {
    major_opcode: u8;
    minor_opcode: u8;
    length:       u16;
}

xcb_sync_list_system_counters_reply_t :: struct {
    response_type: u8;
    pad0:          u8;
    sequence:      u16;
    length:        u32;
    counters_len:  u32;
    pad1:          [20] u8;
}

xcb_sync_create_counter_request_t :: struct {
    major_opcode:  u8;
    minor_opcode:  u8;
    length:        u16;
    id:            xcb_sync_counter_t;
    initial_value: xcb_sync_int64_t;
}

xcb_sync_destroy_counter_request_t :: struct {
    major_opcode: u8;
    minor_opcode: u8;
    length:       u16;
    counter:      xcb_sync_counter_t;
}

xcb_sync_query_counter_cookie_t :: struct {
    sequence: u32;
}

xcb_sync_query_counter_request_t :: struct {
    major_opcode: u8;
    minor_opcode: u8;
    length:       u16;
    counter:      xcb_sync_counter_t;
}

xcb_sync_query_counter_reply_t :: struct {
    response_type: u8;
    pad0:          u8;
    sequence:      u16;
    length:        u32;
    counter_value: xcb_sync_int64_t;
}

xcb_sync_await_request_t :: struct {
    major_opcode: u8;
    minor_opcode: u8;
    length:       u16;
}

xcb_sync_change_counter_request_t :: struct {
    major_opcode: u8;
    minor_opcode: u8;
    length:       u16;
    counter:      xcb_sync_counter_t;
    amount:       xcb_sync_int64_t;
}

xcb_sync_set_counter_request_t :: struct {
    major_opcode: u8;
    minor_opcode: u8;
    length:       u16;
    counter:      xcb_sync_counter_t;
    value:        xcb_sync_int64_t;
}

xcb_sync_create_alarm_value_list_t :: struct {
    counter:   xcb_sync_counter_t;
    valueType: u32;
    value:     xcb_sync_int64_t;
    testType:  u32;
    delta:     xcb_sync_int64_t;
    events:    u32;
}

xcb_sync_create_alarm_request_t :: struct {
    major_opcode: u8;
    minor_opcode: u8;
    length:       u16;
    id:           xcb_sync_alarm_t;
    value_mask:   u32;
}

xcb_sync_change_alarm_value_list_t :: struct {
    counter:   xcb_sync_counter_t;
    valueType: u32;
    value:     xcb_sync_int64_t;
    testType:  u32;
    delta:     xcb_sync_int64_t;
    events:    u32;
}

xcb_sync_change_alarm_request_t :: struct {
    major_opcode: u8;
    minor_opcode: u8;
    length:       u16;
    id:           xcb_sync_alarm_t;
    value_mask:   u32;
}

xcb_sync_destroy_alarm_request_t :: struct {
    major_opcode: u8;
    minor_opcode: u8;
    length:       u16;
    alarm:        xcb_sync_alarm_t;
}

xcb_sync_query_alarm_cookie_t :: struct {
    sequence: u32;
}

xcb_sync_query_alarm_request_t :: struct {
    major_opcode: u8;
    minor_opcode: u8;
    length:       u16;
    alarm:        xcb_sync_alarm_t;
}

xcb_sync_query_alarm_reply_t :: struct {
    response_type: u8;
    pad0:          u8;
    sequence:      u16;
    length:        u32;
    trigger:       xcb_sync_trigger_t;
    delta:         xcb_sync_int64_t;
    events:        u8;
    state:         u8;
    pad1:          [2] u8;
}

xcb_sync_set_priority_request_t :: struct {
    major_opcode: u8;
    minor_opcode: u8;
    length:       u16;
    id:           u32;
    priority:     s32;
}

xcb_sync_get_priority_cookie_t :: struct {
    sequence: u32;
}

xcb_sync_get_priority_request_t :: struct {
    major_opcode: u8;
    minor_opcode: u8;
    length:       u16;
    id:           u32;
}

xcb_sync_get_priority_reply_t :: struct {
    response_type: u8;
    pad0:          u8;
    sequence:      u16;
    length:        u32;
    priority:      s32;
}

xcb_sync_create_fence_request_t :: struct {
    major_opcode:        u8;
    minor_opcode:        u8;
    length:              u16;
    drawable:            xcb_drawable_t;
    fence:               xcb_sync_fence_t;
    initially_triggered: u8;
}

xcb_sync_trigger_fence_request_t :: struct {
    major_opcode: u8;
    minor_opcode: u8;
    length:       u16;
    fence:        xcb_sync_fence_t;
}

xcb_sync_reset_fence_request_t :: struct {
    major_opcode: u8;
    minor_opcode: u8;
    length:       u16;
    fence:        xcb_sync_fence_t;
}

xcb_sync_destroy_fence_request_t :: struct {
    major_opcode: u8;
    minor_opcode: u8;
    length:       u16;
    fence:        xcb_sync_fence_t;
}

xcb_sync_query_fence_cookie_t :: struct {
    sequence: u32;
}

xcb_sync_query_fence_request_t :: struct {
    major_opcode: u8;
    minor_opcode: u8;
    length:       u16;
    fence:        xcb_sync_fence_t;
}

xcb_sync_query_fence_reply_t :: struct {
    response_type: u8;
    pad0:          u8;
    sequence:      u16;
    length:        u32;
    triggered:     u8;
    pad1:          [23] u8;
}

xcb_sync_await_fence_request_t :: struct {
    major_opcode: u8;
    minor_opcode: u8;
    length:       u16;
}

xcb_sync_counter_notify_event_t :: struct {
    response_type: u8;
    kind:          u8;
    sequence:      u16;
    counter:       xcb_sync_counter_t;
    wait_value:    xcb_sync_int64_t;
    counter_value: xcb_sync_int64_t;
    timestamp:     xcb_timestamp_t;
    count:         u16;
    destroyed:     u8;
    pad0:          u8;
}

xcb_sync_alarm_notify_event_t :: struct {
    response_type: u8;
    kind:          u8;
    sequence:      u16;
    alarm:         xcb_sync_alarm_t;
    counter_value: xcb_sync_int64_t;
    alarm_value:   xcb_sync_int64_t;
    timestamp:     xcb_timestamp_t;
    state:         u8;
    pad0:          [3] u8;
}

xcb_sync_alarm_next :: (i: *xcb_sync_alarm_iterator_t) -> void #foreign libxcb_sync;

xcb_sync_alarm_end :: (i: xcb_sync_alarm_iterator_t) -> xcb_generic_iterator_t #foreign libxcb_sync;

xcb_sync_counter_next :: (i: *xcb_sync_counter_iterator_t) -> void #foreign libxcb_sync;

xcb_sync_counter_end :: (i: xcb_sync_counter_iterator_t) -> xcb_generic_iterator_t #foreign libxcb_sync;

xcb_sync_fence_next :: (i: *xcb_sync_fence_iterator_t) -> void #foreign libxcb_sync;

xcb_sync_fence_end :: (i: xcb_sync_fence_iterator_t) -> xcb_generic_iterator_t #foreign libxcb_sync;

xcb_sync_int64_next :: (i: *xcb_sync_int64_iterator_t) -> void #foreign libxcb_sync;

xcb_sync_int64_end :: (i: xcb_sync_int64_iterator_t) -> xcb_generic_iterator_t #foreign libxcb_sync;

xcb_sync_systemcounter_sizeof :: (_buffer: *void) -> s32 #foreign libxcb_sync;

xcb_sync_systemcounter_name :: (R: *xcb_sync_systemcounter_t) -> *u8 #foreign libxcb_sync;

xcb_sync_systemcounter_name_length :: (R: *xcb_sync_systemcounter_t) -> s32 #foreign libxcb_sync;

xcb_sync_systemcounter_name_end :: (R: *xcb_sync_systemcounter_t) -> xcb_generic_iterator_t #foreign libxcb_sync;

xcb_sync_systemcounter_next :: (i: *xcb_sync_systemcounter_iterator_t) -> void #foreign libxcb_sync;

xcb_sync_systemcounter_end :: (i: xcb_sync_systemcounter_iterator_t) -> xcb_generic_iterator_t #foreign libxcb_sync;

xcb_sync_trigger_next :: (i: *xcb_sync_trigger_iterator_t) -> void #foreign libxcb_sync;

xcb_sync_trigger_end :: (i: xcb_sync_trigger_iterator_t) -> xcb_generic_iterator_t #foreign libxcb_sync;

xcb_sync_waitcondition_next :: (i: *xcb_sync_waitcondition_iterator_t) -> void #foreign libxcb_sync;

xcb_sync_waitcondition_end :: (i: xcb_sync_waitcondition_iterator_t) -> xcb_generic_iterator_t #foreign libxcb_sync;

xcb_sync_initialize :: (c: *xcb_connection_t, desired_major_version: u8, desired_minor_version: u8) -> xcb_sync_initialize_cookie_t #foreign libxcb_sync;

xcb_sync_initialize_unchecked :: (c: *xcb_connection_t, desired_major_version: u8, desired_minor_version: u8) -> xcb_sync_initialize_cookie_t #foreign libxcb_sync;

xcb_sync_initialize_reply :: (c: *xcb_connection_t, cookie: xcb_sync_initialize_cookie_t, e: **xcb_generic_error_t) -> *xcb_sync_initialize_reply_t #foreign libxcb_sync;

xcb_sync_list_system_counters_sizeof :: (_buffer: *void) -> s32 #foreign libxcb_sync;

xcb_sync_list_system_counters :: (c: *xcb_connection_t) -> xcb_sync_list_system_counters_cookie_t #foreign libxcb_sync;

xcb_sync_list_system_counters_unchecked :: (c: *xcb_connection_t) -> xcb_sync_list_system_counters_cookie_t #foreign libxcb_sync;

xcb_sync_list_system_counters_counters_length :: (R: *xcb_sync_list_system_counters_reply_t) -> s32 #foreign libxcb_sync;

xcb_sync_list_system_counters_counters_iterator :: (R: *xcb_sync_list_system_counters_reply_t) -> xcb_sync_systemcounter_iterator_t #foreign libxcb_sync;

xcb_sync_list_system_counters_reply :: (c: *xcb_connection_t, cookie: xcb_sync_list_system_counters_cookie_t, e: **xcb_generic_error_t) -> *xcb_sync_list_system_counters_reply_t #foreign libxcb_sync;

xcb_sync_create_counter_checked :: (c: *xcb_connection_t, id: xcb_sync_counter_t, initial_value: xcb_sync_int64_t) -> xcb_void_cookie_t #foreign libxcb_sync;

xcb_sync_create_counter :: (c: *xcb_connection_t, id: xcb_sync_counter_t, initial_value: xcb_sync_int64_t) -> xcb_void_cookie_t #foreign libxcb_sync;

xcb_sync_destroy_counter_checked :: (c: *xcb_connection_t, counter: xcb_sync_counter_t) -> xcb_void_cookie_t #foreign libxcb_sync;

xcb_sync_destroy_counter :: (c: *xcb_connection_t, counter: xcb_sync_counter_t) -> xcb_void_cookie_t #foreign libxcb_sync;

xcb_sync_query_counter :: (c: *xcb_connection_t, counter: xcb_sync_counter_t) -> xcb_sync_query_counter_cookie_t #foreign libxcb_sync;

xcb_sync_query_counter_unchecked :: (c: *xcb_connection_t, counter: xcb_sync_counter_t) -> xcb_sync_query_counter_cookie_t #foreign libxcb_sync;

xcb_sync_query_counter_reply :: (c: *xcb_connection_t, cookie: xcb_sync_query_counter_cookie_t, e: **xcb_generic_error_t) -> *xcb_sync_query_counter_reply_t #foreign libxcb_sync;

xcb_sync_await_sizeof :: (_buffer: *void, wait_list_len: u32) -> s32 #foreign libxcb_sync;

xcb_sync_await_checked :: (c: *xcb_connection_t, wait_list_len: u32, wait_list: *xcb_sync_waitcondition_t) -> xcb_void_cookie_t #foreign libxcb_sync;

xcb_sync_await :: (c: *xcb_connection_t, wait_list_len: u32, wait_list: *xcb_sync_waitcondition_t) -> xcb_void_cookie_t #foreign libxcb_sync;

xcb_sync_await_wait_list :: (R: *xcb_sync_await_request_t) -> *xcb_sync_waitcondition_t #foreign libxcb_sync;

xcb_sync_await_wait_list_length :: (R: *xcb_sync_await_request_t) -> s32 #foreign libxcb_sync;

xcb_sync_await_wait_list_iterator :: (R: *xcb_sync_await_request_t) -> xcb_sync_waitcondition_iterator_t #foreign libxcb_sync;

xcb_sync_change_counter_checked :: (c: *xcb_connection_t, counter: xcb_sync_counter_t, amount: xcb_sync_int64_t) -> xcb_void_cookie_t #foreign libxcb_sync;

xcb_sync_change_counter :: (c: *xcb_connection_t, counter: xcb_sync_counter_t, amount: xcb_sync_int64_t) -> xcb_void_cookie_t #foreign libxcb_sync;

xcb_sync_set_counter_checked :: (c: *xcb_connection_t, counter: xcb_sync_counter_t, value: xcb_sync_int64_t) -> xcb_void_cookie_t #foreign libxcb_sync;

xcb_sync_set_counter :: (c: *xcb_connection_t, counter: xcb_sync_counter_t, value: xcb_sync_int64_t) -> xcb_void_cookie_t #foreign libxcb_sync;

xcb_sync_create_alarm_value_list_serialize :: (_buffer: **void, value_mask: u32, _aux: *xcb_sync_create_alarm_value_list_t) -> s32 #foreign libxcb_sync;

xcb_sync_create_alarm_value_list_unpack :: (_buffer: *void, value_mask: u32, _aux: *xcb_sync_create_alarm_value_list_t) -> s32 #foreign libxcb_sync;

xcb_sync_create_alarm_value_list_sizeof :: (_buffer: *void, value_mask: u32) -> s32 #foreign libxcb_sync;

xcb_sync_create_alarm_sizeof :: (_buffer: *void) -> s32 #foreign libxcb_sync;

xcb_sync_create_alarm_checked :: (c: *xcb_connection_t, id: xcb_sync_alarm_t, value_mask: u32, value_list: *void) -> xcb_void_cookie_t #foreign libxcb_sync;

xcb_sync_create_alarm :: (c: *xcb_connection_t, id: xcb_sync_alarm_t, value_mask: u32, value_list: *void) -> xcb_void_cookie_t #foreign libxcb_sync;

xcb_sync_create_alarm_aux_checked :: (c: *xcb_connection_t, id: xcb_sync_alarm_t, value_mask: u32, value_list: *xcb_sync_create_alarm_value_list_t) -> xcb_void_cookie_t #foreign libxcb_sync;

xcb_sync_create_alarm_aux :: (c: *xcb_connection_t, id: xcb_sync_alarm_t, value_mask: u32, value_list: *xcb_sync_create_alarm_value_list_t) -> xcb_void_cookie_t #foreign libxcb_sync;

xcb_sync_create_alarm_value_list :: (R: *xcb_sync_create_alarm_request_t) -> *void #foreign libxcb_sync;

xcb_sync_change_alarm_value_list_serialize :: (_buffer: **void, value_mask: u32, _aux: *xcb_sync_change_alarm_value_list_t) -> s32 #foreign libxcb_sync;

xcb_sync_change_alarm_value_list_unpack :: (_buffer: *void, value_mask: u32, _aux: *xcb_sync_change_alarm_value_list_t) -> s32 #foreign libxcb_sync;

xcb_sync_change_alarm_value_list_sizeof :: (_buffer: *void, value_mask: u32) -> s32 #foreign libxcb_sync;

xcb_sync_change_alarm_sizeof :: (_buffer: *void) -> s32 #foreign libxcb_sync;

xcb_sync_change_alarm_checked :: (c: *xcb_connection_t, id: xcb_sync_alarm_t, value_mask: u32, value_list: *void) -> xcb_void_cookie_t #foreign libxcb_sync;

xcb_sync_change_alarm :: (c: *xcb_connection_t, id: xcb_sync_alarm_t, value_mask: u32, value_list: *void) -> xcb_void_cookie_t #foreign libxcb_sync;

xcb_sync_change_alarm_aux_checked :: (c: *xcb_connection_t, id: xcb_sync_alarm_t, value_mask: u32, value_list: *xcb_sync_change_alarm_value_list_t) -> xcb_void_cookie_t #foreign libxcb_sync;

xcb_sync_change_alarm_aux :: (c: *xcb_connection_t, id: xcb_sync_alarm_t, value_mask: u32, value_list: *xcb_sync_change_alarm_value_list_t) -> xcb_void_cookie_t #foreign libxcb_sync;

xcb_sync_change_alarm_value_list :: (R: *xcb_sync_change_alarm_request_t) -> *void #foreign libxcb_sync;

xcb_sync_destroy_alarm_checked :: (c: *xcb_connection_t, alarm: xcb_sync_alarm_t) -> xcb_void_cookie_t #foreign libxcb_sync;

xcb_sync_destroy_alarm :: (c: *xcb_connection_t, alarm: xcb_sync_alarm_t) -> xcb_void_cookie_t #foreign libxcb_sync;

xcb_sync_query_alarm :: (c: *xcb_connection_t, alarm: xcb_sync_alarm_t) -> xcb_sync_query_alarm_cookie_t #foreign libxcb_sync;

xcb_sync_query_alarm_unchecked :: (c: *xcb_connection_t, alarm: xcb_sync_alarm_t) -> xcb_sync_query_alarm_cookie_t #foreign libxcb_sync;

xcb_sync_query_alarm_reply :: (c: *xcb_connection_t, cookie: xcb_sync_query_alarm_cookie_t, e: **xcb_generic_error_t) -> *xcb_sync_query_alarm_reply_t #foreign libxcb_sync;

xcb_sync_set_priority_checked :: (c: *xcb_connection_t, id: u32, priority: s32) -> xcb_void_cookie_t #foreign libxcb_sync;

xcb_sync_set_priority :: (c: *xcb_connection_t, id: u32, priority: s32) -> xcb_void_cookie_t #foreign libxcb_sync;

xcb_sync_get_priority :: (c: *xcb_connection_t, id: u32) -> xcb_sync_get_priority_cookie_t #foreign libxcb_sync;

xcb_sync_get_priority_unchecked :: (c: *xcb_connection_t, id: u32) -> xcb_sync_get_priority_cookie_t #foreign libxcb_sync;

xcb_sync_get_priority_reply :: (c: *xcb_connection_t, cookie: xcb_sync_get_priority_cookie_t, e: **xcb_generic_error_t) -> *xcb_sync_get_priority_reply_t #foreign libxcb_sync;

xcb_sync_create_fence_checked :: (c: *xcb_connection_t, drawable: xcb_drawable_t, fence: xcb_sync_fence_t, initially_triggered: u8) -> xcb_void_cookie_t #foreign libxcb_sync;

xcb_sync_create_fence :: (c: *xcb_connection_t, drawable: xcb_drawable_t, fence: xcb_sync_fence_t, initially_triggered: u8) -> xcb_void_cookie_t #foreign libxcb_sync;

xcb_sync_trigger_fence_checked :: (c: *xcb_connection_t, fence: xcb_sync_fence_t) -> xcb_void_cookie_t #foreign libxcb_sync;

xcb_sync_trigger_fence :: (c: *xcb_connection_t, fence: xcb_sync_fence_t) -> xcb_void_cookie_t #foreign libxcb_sync;

xcb_sync_reset_fence_checked :: (c: *xcb_connection_t, fence: xcb_sync_fence_t) -> xcb_void_cookie_t #foreign libxcb_sync;

xcb_sync_reset_fence :: (c: *xcb_connection_t, fence: xcb_sync_fence_t) -> xcb_void_cookie_t #foreign libxcb_sync;

xcb_sync_destroy_fence_checked :: (c: *xcb_connection_t, fence: xcb_sync_fence_t) -> xcb_void_cookie_t #foreign libxcb_sync;

xcb_sync_destroy_fence :: (c: *xcb_connection_t, fence: xcb_sync_fence_t) -> xcb_void_cookie_t #foreign libxcb_sync;

xcb_sync_query_fence :: (c: *xcb_connection_t, fence: xcb_sync_fence_t) -> xcb_sync_query_fence_cookie_t #foreign libxcb_sync;

xcb_sync_query_fence_unchecked :: (c: *xcb_connection_t, fence: xcb_sync_fence_t) -> xcb_sync_query_fence_cookie_t #foreign libxcb_sync;

xcb_sync_query_fence_reply :: (c: *xcb_connection_t, cookie: xcb_sync_query_fence_cookie_t, e: **xcb_generic_error_t) -> *xcb_sync_query_fence_reply_t #foreign libxcb_sync;

xcb_sync_await_fence_sizeof :: (_buffer: *void, fence_list_len: u32) -> s32 #foreign libxcb_sync;

xcb_sync_await_fence_checked :: (c: *xcb_connection_t, fence_list_len: u32, fence_list: *xcb_sync_fence_t) -> xcb_void_cookie_t #foreign libxcb_sync;

xcb_sync_await_fence :: (c: *xcb_connection_t, fence_list_len: u32, fence_list: *xcb_sync_fence_t) -> xcb_void_cookie_t #foreign libxcb_sync;

xcb_sync_await_fence_fence_list :: (R: *xcb_sync_await_fence_request_t) -> *xcb_sync_fence_t #foreign libxcb_sync;

xcb_sync_await_fence_fence_list_length :: (R: *xcb_sync_await_fence_request_t) -> s32 #foreign libxcb_sync;

xcb_sync_await_fence_fence_list_end :: (R: *xcb_sync_await_fence_request_t) -> xcb_generic_iterator_t #foreign libxcb_sync;

#scope_file

libxcb_sync :: #library,system "libxcb-sync";
