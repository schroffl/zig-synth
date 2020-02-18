const std = @import("std");
usingnamespace @import("includes.zig");

pub fn convertCFString(allocator: *std.mem.Allocator, str: CFStringRef) ![]const u8 {
    const len = @intCast(usize, CFStringGetLength(str)) + 1;
    var buffer = try allocator.alloc(u8, len);

    const result = CFStringGetCString(str, &buffer[0], @intCast(CFIndex, buffer.len), kCFStringEncodingUTF8);

    if (result != @"true") {
        return error.CFStringConversionFailed;
    }

    return buffer[0 .. buffer.len - 1];
}

pub fn createCFString(str: []const u8) CFStringRef {
    return CFStringCreateWithCString(
        kCFAllocatorDefault,
        &str[0],
        kCFStringEncodingUTF8,
    );
}

pub fn checkStatus(hint: []const u8, status: OSStatus) void {
    if (status != noErr) {
        std.debug.warn("{} failed with error: {}\n", .{ hint, status });
        exit(1);
    }
}

pub fn findAudioDevice(allocator: *std.mem.Allocator, hint: []const u8) !?AudioDeviceID {
    var property_size: c_uint = undefined;
    var device_property_address = AudioObjectPropertyAddress{
        .mSelector = kAudioHardwarePropertyDevices,
        .mScope = kAudioObjectPropertyScopeGlobal,
        .mElement = kAudioObjectPropertyElementMaster,
    };

    checkStatus(
        "AudioObjectGetPropertyDataSize",
        AudioObjectGetPropertyDataSize(
            kAudioObjectSystemObject,
            &device_property_address,
            0,
            null,
            &property_size,
        ),
    );

    const device_count = @intCast(usize, property_size) / @sizeOf(AudioDeviceID);
    var devices = try allocator.alloc(AudioDeviceID, device_count);
    defer allocator.free(devices);

    checkStatus(
        "AudioObjectGetPropertyData",
        AudioObjectGetPropertyData(
            kAudioObjectSystemObject,
            &device_property_address,
            0,
            null,
            &property_size,
            &devices[0],
        ),
    );

    var device_name: CFStringRef = undefined;
    var device_name_size: c_uint = @sizeOf(CFStringRef);
    var device_name_property_address = AudioObjectPropertyAddress{
        .mSelector = kAudioDevicePropertyDeviceNameCFString,
        .mScope = kAudioObjectPropertyScopeGlobal,
        .mElement = kAudioObjectPropertyElementMaster,
    };

    var device_stream_config_size: c_uint = undefined;
    var device_stream_config_property_address = AudioObjectPropertyAddress{
        .mSelector = kAudioDevicePropertyStreamConfiguration,
        .mScope = kAudioDevicePropertyScopeInput,
        .mElement = 0,
    };

    for (devices) |device_id| {
        checkStatus(
            "AudioObjectGetPropertyDataSize StreamConfiguration",
            AudioObjectGetPropertyDataSize(
                device_id,
                &device_stream_config_property_address,
                0,
                null,
                &device_stream_config_size,
            ),
        );

        // FIXME Technically, this is not correct, because, afaik, the device_stream_config_size
        //       contains the size of the AudioBufferList and not just the AudioBuffers
        // const input_count = device_stream_config_size / @sizeOf(AudioBuffer);
        //
        // If the device has any inputs we can ignore it, because we only
        // want output devices.
        // if (input_count > 0) {
        //     continue;
        // }

        checkStatus(
            "AudioObjectGetPropertyData DeviceNameCFString",
            AudioObjectGetPropertyData(
                device_id,
                &device_name_property_address,
                0,
                null,
                &device_name_size,
                &device_name,
            ),
        );

        const zig_name = try convertCFString(allocator, device_name);
        defer allocator.free(zig_name);

        if (std.mem.indexOf(u8, zig_name, hint) != null) {
            std.debug.warn("Selected Audio Device: {}\n", .{zig_name});
            return device_id;
        }
    }

    return null;
}

pub fn findAudioComponent(
    allocator: *std.mem.Allocator,
    desc: AudioComponentDescription,
    hint: []const u8,
) !?AudioComponent {
    var current: AudioComponent = null;

    while (AudioComponentFindNext(current, &desc)) |found| {
        var name: CFStringRef = undefined;

        checkStatus(
            "AudioComponentCopyName",
            AudioComponentCopyName(found, &name),
        );

        const zig_name = try convertCFString(allocator, name);
        defer allocator.free(zig_name);

        if (std.mem.indexOf(u8, zig_name, hint) != null) {
            std.debug.warn("Selected Audio Component: {}\n", .{zig_name});
            return found;
        }

        current = found;
    }

    return null;
}
