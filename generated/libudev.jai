//
// This file was auto-generated using the following command:
//
// jai generate.jai
//



/*
* udev - library context
*
* reads the udev config and system environment
* allows custom logging
*/
udev :: struct {}
udev_ref :: (udev: *udev) -> *udev #foreign libudev;
udev_unref :: (udev: *udev) -> *udev #foreign libudev;
udev_new :: () -> *udev #foreign libudev;
udev_set_log_fn :: (udev: *udev, log_fn: *void /* function type contained C va_list argument */) -> void #foreign libudev;

udev_get_log_priority :: (udev: *udev) -> s32 #foreign libudev;
udev_set_log_priority :: (udev: *udev, priority: s32) -> void #foreign libudev;
udev_get_userdata :: (udev: *udev) -> *void #foreign libudev;
udev_set_userdata :: (udev: *udev, userdata: *void) -> void #foreign libudev;

/*
* udev_list
*
* access to libudev generated lists
*/
udev_list_entry :: struct {}
udev_list_entry_get_next :: (list_entry: *udev_list_entry) -> *udev_list_entry #foreign libudev;
udev_list_entry_get_by_name :: (list_entry: *udev_list_entry, name: *u8) -> *udev_list_entry #foreign libudev;
udev_list_entry_get_name :: (list_entry: *udev_list_entry) -> *u8 #foreign libudev;
udev_list_entry_get_value :: (list_entry: *udev_list_entry) -> *u8 #foreign libudev;

/*
* udev_device
*
* access to sysfs/kernel devices
*/
udev_device :: struct {}
udev_device_ref :: (udev_device: *udev_device) -> *udev_device #foreign libudev;
udev_device_unref :: (udev_device: *udev_device) -> *udev_device #foreign libudev;
udev_device_get_udev :: (udev_device: *udev_device) -> *udev #foreign libudev;
udev_device_new_from_syspath :: (udev: *udev, syspath: *u8) -> *udev_device #foreign libudev;
udev_device_new_from_devnum :: (udev: *udev, type: u8, devnum: dev_t) -> *udev_device #foreign libudev;
udev_device_new_from_subsystem_sysname :: (udev: *udev, subsystem: *u8, sysname: *u8) -> *udev_device #foreign libudev;
udev_device_new_from_device_id :: (udev: *udev, id: *u8) -> *udev_device #foreign libudev;
udev_device_new_from_environment :: (udev: *udev) -> *udev_device #foreign libudev;

/* udev_device_get_parent_*() does not take a reference on the returned device, it is automatically unref'd with the parent */
udev_device_get_parent :: (udev_device: *udev_device) -> *udev_device #foreign libudev;
udev_device_get_parent_with_subsystem_devtype :: (udev_device: *udev_device, subsystem: *u8, devtype: *u8) -> *udev_device #foreign libudev;

/* retrieve device properties */
udev_device_get_devpath :: (udev_device: *udev_device) -> *u8 #foreign libudev;
udev_device_get_subsystem :: (udev_device: *udev_device) -> *u8 #foreign libudev;
udev_device_get_devtype :: (udev_device: *udev_device) -> *u8 #foreign libudev;
udev_device_get_syspath :: (udev_device: *udev_device) -> *u8 #foreign libudev;
udev_device_get_sysname :: (udev_device: *udev_device) -> *u8 #foreign libudev;
udev_device_get_sysnum :: (udev_device: *udev_device) -> *u8 #foreign libudev;
udev_device_get_devnode :: (udev_device: *udev_device) -> *u8 #foreign libudev;
udev_device_get_is_initialized :: (udev_device: *udev_device) -> s32 #foreign libudev;
udev_device_get_devlinks_list_entry :: (udev_device: *udev_device) -> *udev_list_entry #foreign libudev;
udev_device_get_properties_list_entry :: (udev_device: *udev_device) -> *udev_list_entry #foreign libudev;
udev_device_get_tags_list_entry :: (udev_device: *udev_device) -> *udev_list_entry #foreign libudev;
udev_device_get_current_tags_list_entry :: (udev_device: *udev_device) -> *udev_list_entry #foreign libudev;
udev_device_get_sysattr_list_entry :: (udev_device: *udev_device) -> *udev_list_entry #foreign libudev;
udev_device_get_property_value :: (udev_device: *udev_device, key: *u8) -> *u8 #foreign libudev;
udev_device_get_driver :: (udev_device: *udev_device) -> *u8 #foreign libudev;
udev_device_get_devnum :: (udev_device: *udev_device) -> dev_t #foreign libudev;
udev_device_get_action :: (udev_device: *udev_device) -> *u8 #foreign libudev;
udev_device_get_seqnum :: (udev_device: *udev_device) -> u64 #foreign libudev;
udev_device_get_usec_since_initialized :: (udev_device: *udev_device) -> u64 #foreign libudev;
udev_device_get_sysattr_value :: (udev_device: *udev_device, sysattr: *u8) -> *u8 #foreign libudev;
udev_device_set_sysattr_value :: (udev_device: *udev_device, sysattr: *u8, value: *u8) -> s32 #foreign libudev;
udev_device_has_tag :: (udev_device: *udev_device, tag: *u8) -> s32 #foreign libudev;
udev_device_has_current_tag :: (udev_device: *udev_device, tag: *u8) -> s32 #foreign libudev;

/*
* udev_monitor
*
* access to kernel uevents and udev events
*/
udev_monitor :: struct {}
udev_monitor_ref :: (udev_monitor: *udev_monitor) -> *udev_monitor #foreign libudev;
udev_monitor_unref :: (udev_monitor: *udev_monitor) -> *udev_monitor #foreign libudev;
udev_monitor_get_udev :: (udev_monitor: *udev_monitor) -> *udev #foreign libudev;

/* kernel and udev generated events over netlink */
udev_monitor_new_from_netlink :: (udev: *udev, name: *u8) -> *udev_monitor #foreign libudev;

/* bind socket */
udev_monitor_enable_receiving :: (udev_monitor: *udev_monitor) -> s32 #foreign libudev;
udev_monitor_set_receive_buffer_size :: (udev_monitor: *udev_monitor, size: s32) -> s32 #foreign libudev;
udev_monitor_get_fd :: (udev_monitor: *udev_monitor) -> s32 #foreign libudev;
udev_monitor_receive_device :: (udev_monitor: *udev_monitor) -> *udev_device #foreign libudev;

/* in-kernel socket filters to select messages that get delivered to a listener */
udev_monitor_filter_add_match_subsystem_devtype :: (udev_monitor: *udev_monitor, subsystem: *u8, devtype: *u8) -> s32 #foreign libudev;

udev_monitor_filter_add_match_tag :: (udev_monitor: *udev_monitor, tag: *u8) -> s32 #foreign libudev;
udev_monitor_filter_update :: (udev_monitor: *udev_monitor) -> s32 #foreign libudev;
udev_monitor_filter_remove :: (udev_monitor: *udev_monitor) -> s32 #foreign libudev;

/*
* udev_enumerate
*
* search sysfs for specific devices and provide a sorted list
*/
udev_enumerate :: struct {}
udev_enumerate_ref :: (udev_enumerate: *udev_enumerate) -> *udev_enumerate #foreign libudev;
udev_enumerate_unref :: (udev_enumerate: *udev_enumerate) -> *udev_enumerate #foreign libudev;
udev_enumerate_get_udev :: (udev_enumerate: *udev_enumerate) -> *udev #foreign libudev;
udev_enumerate_new :: (udev: *udev) -> *udev_enumerate #foreign libudev;

/* device properties filter */
udev_enumerate_add_match_subsystem :: (udev_enumerate: *udev_enumerate, subsystem: *u8) -> s32 #foreign libudev;
udev_enumerate_add_nomatch_subsystem :: (udev_enumerate: *udev_enumerate, subsystem: *u8) -> s32 #foreign libudev;
udev_enumerate_add_match_sysattr :: (udev_enumerate: *udev_enumerate, sysattr: *u8, value: *u8) -> s32 #foreign libudev;
udev_enumerate_add_nomatch_sysattr :: (udev_enumerate: *udev_enumerate, sysattr: *u8, value: *u8) -> s32 #foreign libudev;
udev_enumerate_add_match_property :: (udev_enumerate: *udev_enumerate, property: *u8, value: *u8) -> s32 #foreign libudev;
udev_enumerate_add_match_sysname :: (udev_enumerate: *udev_enumerate, sysname: *u8) -> s32 #foreign libudev;
udev_enumerate_add_match_tag :: (udev_enumerate: *udev_enumerate, tag: *u8) -> s32 #foreign libudev;
udev_enumerate_add_match_parent :: (udev_enumerate: *udev_enumerate, parent: *udev_device) -> s32 #foreign libudev;
udev_enumerate_add_match_is_initialized :: (udev_enumerate: *udev_enumerate) -> s32 #foreign libudev;
udev_enumerate_add_syspath :: (udev_enumerate: *udev_enumerate, syspath: *u8) -> s32 #foreign libudev;

/* run enumeration with active filters */
udev_enumerate_scan_devices :: (udev_enumerate: *udev_enumerate) -> s32 #foreign libudev;
udev_enumerate_scan_subsystems :: (udev_enumerate: *udev_enumerate) -> s32 #foreign libudev;

/* return device list */
udev_enumerate_get_list_entry :: (udev_enumerate: *udev_enumerate) -> *udev_list_entry #foreign libudev;

/*
* udev_queue
*
* access to the currently running udev events
*/
udev_queue :: struct {}
udev_queue_ref :: (udev_queue: *udev_queue) -> *udev_queue #foreign libudev;
udev_queue_unref :: (udev_queue: *udev_queue) -> *udev_queue #foreign libudev;
udev_queue_get_udev :: (udev_queue: *udev_queue) -> *udev #foreign libudev;
udev_queue_new :: (udev: *udev) -> *udev_queue #foreign libudev;
udev_queue_get_kernel_seqnum :: (udev_queue: *udev_queue) -> u64 #foreign libudev;
udev_queue_get_udev_seqnum :: (udev_queue: *udev_queue) -> u64 #foreign libudev;
udev_queue_get_udev_is_active :: (udev_queue: *udev_queue) -> s32 #foreign libudev;
udev_queue_get_queue_is_empty :: (udev_queue: *udev_queue) -> s32 #foreign libudev;
udev_queue_get_seqnum_is_finished :: (udev_queue: *udev_queue, seqnum: u64) -> s32 #foreign libudev;
udev_queue_get_seqnum_sequence_is_finished :: (udev_queue: *udev_queue, start: u64, end: u64) -> s32 #foreign libudev;

udev_queue_get_fd :: (udev_queue: *udev_queue) -> s32 #foreign libudev;
udev_queue_flush :: (udev_queue: *udev_queue) -> s32 #foreign libudev;
udev_queue_get_queued_list_entry :: (udev_queue: *udev_queue) -> *udev_list_entry #foreign libudev;

/*
*  udev_hwdb
*
*  access to the static hardware properties database
*/
udev_hwdb :: struct {}
udev_hwdb_new :: (udev: *udev) -> *udev_hwdb #foreign libudev;
udev_hwdb_ref :: (hwdb: *udev_hwdb) -> *udev_hwdb #foreign libudev;
udev_hwdb_unref :: (hwdb: *udev_hwdb) -> *udev_hwdb #foreign libudev;
udev_hwdb_get_properties_list_entry :: (hwdb: *udev_hwdb, modalias: *u8, flags: u32) -> *udev_list_entry #foreign libudev;

/*
* udev_util
*
* udev specific utilities
*/
udev_util_encode_string :: (str: *u8, str_enc: *u8, len: u64) -> s32 #foreign libudev;

#scope_file

libudev :: #library,system "libudev";
