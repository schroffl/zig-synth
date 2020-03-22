const std = @import("std");
const Synth = @import("../synth.zig").Synth;
const util = @import("../util.zig");
const midi = @import("../midi.zig");

const objc = @import("macos_objc.zig");
usingnamespace @import("macos_core_audio.zig");

pub const Host = struct {
    pub const warn = std.debug.warn;
};

/// Replace this with the name of your desired MIDI input.
/// It doesn't have to be the _exact_ name, but just something that
/// uniquely identifies it.
/// In my case, it's an Arturia KeyStep
const midi_hint = "KeyStep";

pub fn main() !void {
    var arena_allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = &arena_allocator.allocator;
    defer arena_allocator.deinit();

    const format = util.Format{
        .sample_rate = 44100,
        .channel_count = 1,
    };

    var instance = Instance{
        .ref = .{
            .synth = try Synth.init(allocator, format),
            .timer = try std.time.Timer.start(),
        },
        .audio_unit = undefined,
        .midi_client_ref = undefined,
        .midi_port_ref = undefined,
    };

    // Core Audio Setup
    {
        const stream_description = formatToAudioStreamBasicDescription(f32, format);
        const component_description = AudioComponentDescription{
            .componentType = kAudioUnitType_Output,
            .componentSubType = kAudioUnitSubType_HALOutput,
            .componentManufacturer = 0,
            .componentFlags = 0,
            .componentFlagsMask = 0,
        };

        const output_device = (try findAudioDevice(allocator, "Out", true)) orelse return error.AudioDeviceNotFound;
        const component = (try findAudioComponent(allocator, component_description, "Output")) orelse return error.AudioComponentNotFound;

        checkStatus(
            "AudioComponentInstanceNew",
            AudioComponentInstanceNew(component, &instance.audio_unit),
        );

        const kOutputBus: UInt32 = 0;
        var trueFlag: UInt32 = 1;

        checkStatus(
            "AudioUnitSetProperty CurrentDevice",
            AudioUnitSetProperty(
                instance.audio_unit,
                kAudioOutputUnitProperty_CurrentDevice,
                kAudioUnitScope_Output,
                kOutputBus,
                &output_device,
                @sizeOf(@TypeOf(output_device)),
            ),
        );

        checkStatus(
            "AudioUnitSetProperty StreamFormat",
            AudioUnitSetProperty(
                instance.audio_unit,
                kAudioUnitProperty_StreamFormat,
                kAudioUnitScope_Input,
                kOutputBus,
                &stream_description,
                @sizeOf(@TypeOf(stream_description)),
            ),
        );

        var callback_struct = AURenderCallbackStruct{
            .inputProc = renderCallback,
            .inputProcRefCon = &instance.ref,
        };

        checkStatus(
            "AudioUnitSetProperty SetRenderCallback",
            AudioUnitSetProperty(
                instance.audio_unit,
                kAudioUnitProperty_SetRenderCallback,
                kAudioUnitScope_Global,
                kOutputBus,
                &callback_struct,
                @sizeOf(AURenderCallbackStruct),
            ),
        );

        checkStatus(
            "AudioUnitInitialize",
            AudioUnitInitialize(instance.audio_unit),
        );

        checkStatus(
            "AudioOutputUnitStart",
            AudioOutputUnitStart(instance.audio_unit),
        );
    }

    const maybe_midi_source = try findMIDISource(allocator, midi_hint);

    // Core MIDI Setup
    if (maybe_midi_source) |midi_source| {
        const client_name = createCFString("test");

        checkStatus(
            "MIDIClientCreate",
            MIDIClientCreate(
                client_name,
                null,
                null,
                &instance.midi_client_ref,
            ),
        );

        const port_name = createCFString("test-port");

        checkStatus(
            "MIDIInputPortCreate",
            MIDIInputPortCreate(
                instance.midi_client_ref,
                port_name,
                midiCallback,
                &instance.ref.synth,
                &instance.midi_port_ref,
            ),
        );

        checkStatus(
            "MIDIPortConnectSource",
            MIDIPortConnectSource(
                instance.midi_port_ref,
                midi_source,
                null,
            ),
        );
    }

    startRunLoop();
}

const Instance = struct {
    ref: struct {
        synth: Synth,
        timer: std.time.Timer,
    },

    // Audio
    audio_unit: AudioUnit,

    // MIDI
    midi_client_ref: MIDIClientRef,
    midi_port_ref: MIDIPortRef,
};

fn renderCallback(
    input: ?*c_void,
    flags: [*c]AudioUnitRenderActionFlags,
    timestamp: [*c]const AudioTimeStamp,
    bus: UInt32,
    frames: UInt32,
    raw_buffers: [*c]AudioBufferList,
) callconv(.C) OSStatus {
    const RefT = comptime std.meta.fieldInfo(Instance, "ref").field_type;
    const aligned_ptr = @alignCast(@alignOf(RefT), input);
    var ref = @ptrCast(*RefT, aligned_ptr);

    var audio_buffer_list = @ptrCast(*AudioBufferList, raw_buffers);
    var audio_buffer = audio_buffer_list.mBuffers[0];
    var buffer_data = @ptrCast([*c]f32, @alignCast(@alignOf(f32), audio_buffer.mData));
    var buffer_slice = buffer_data[0..frames];

    ref.timer.reset();
    ref.synth.sampleInto(buffer_slice);
    const took = ref.timer.read();

    std.debug.warn("{} frames took {}ns\n", .{ frames, took });

    return noErr;
}
fn midiCallback(
    pktlist_c: [*c]const MIDIPacketList,
    input: ?*c_void,
    src: ?*c_void,
) callconv(.C) void {
    const aligned_ptr = @alignCast(@alignOf(Synth), input);
    var synth = @ptrCast(*Synth, aligned_ptr);

    const pktlist = pktlist_c[0];
    var packet = pktlist.packet[0];
    var packet_i: @TypeOf(pktlist.numPackets) = 0;

    while (packet_i < pktlist.numPackets) : ({
        packet_i += 1;
        packet = MIDIPacketNext(&packet)[0];
    }) {
        const data = packet.data[0..packet.length];
        const msg = midi.Message.parse(data);

        synth.handleMIDIMessage(msg);
    }
}

fn startRunLoop() void {
    const NSRunLoop = objc.objc_getClass("NSRunLoop");
    const current = objc.objc_msgSend(@ptrCast(objc.id, NSRunLoop), objc.sel_getUid("currentRunLoop"));
    _ = objc.objc_msgSend(current, objc.sel_getUid("run"));
}

fn formatToAudioStreamBasicDescription(comptime ValueT: type, format: util.Format) AudioStreamBasicDescription {
    return .{
        .mSampleRate = format.sample_rate,
        .mFormatID = kAudioFormatLinearPCM,
        .mFormatFlags = switch (ValueT) {
            f32, f64 => kLinearPCMFormatFlagIsFloat,
            else => @compileError("Unsupported format type"),
        },
        .mBitsPerChannel = @sizeOf(ValueT) * 8,
        .mChannelsPerFrame = format.channel_count,
        .mFramesPerPacket = 1,
        .mBytesPerPacket = @sizeOf(ValueT) * format.channel_count,
        .mBytesPerFrame = @sizeOf(ValueT) * format.channel_count,
        .mReserved = 0,
    };
}

test "formatToAudioStreamBasicDescription" {
    const mono_44100 = util.Format{
        .sample_rate = 44100,
        .channel_count = 1,
    };

    const absd = formatToAudioStreamBasicDescription(f32, mono_44100);

    std.testing.expectEqual(absd.mSampleRate, mono_44100.sample_rate);
    std.testing.expect(@intCast(c_int, absd.mFormatFlags) & kLinearPCMFormatFlagIsFloat != 0);
    std.testing.expectEqual(@as(c_uint, 32), absd.mBitsPerChannel);
    std.testing.expectEqual(@as(c_uint, 1), absd.mChannelsPerFrame);
    std.testing.expectEqual(@as(c_uint, 4), absd.mBytesPerPacket);
    std.testing.expectEqual(@as(c_uint, 4), absd.mBytesPerFrame);

    std.testing.expectEqual(absd.mFormatID, kAudioFormatLinearPCM);
    std.testing.expectEqual(@as(c_uint, 1), absd.mFramesPerPacket);
}

fn convertCFString(allocator: *std.mem.Allocator, str: CFStringRef) ![]const u8 {
    const len = @intCast(usize, CFStringGetLength(str)) + 1;
    var buffer = try allocator.alloc(u8, len);
    errdefer allocator.free(buffer);

    const result = CFStringGetCString(str, &buffer[0], @intCast(CFIndex, buffer.len), kCFStringEncodingUTF8);

    if (result != @"true") {
        return error.CFStringConversionFailed;
    }

    return buffer[0 .. buffer.len - 1];
}

fn createCFString(str: []const u8) CFStringRef {
    return CFStringCreateWithCString(
        kCFAllocatorDefault,
        &str[0],
        kCFStringEncodingUTF8,
    );
}

fn checkStatus(hint: []const u8, status: OSStatus) void {
    if (status != noErr) {
        std.debug.warn("checkStatus(\"{}\") failed with error: {}\n", .{ hint, status });
        exit(1);
    }
}
fn findAudioDevice(
    allocator: *std.mem.Allocator,
    hint: []const u8,
    ignore_input_devices: bool,
) !?AudioDeviceID {
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
        var input_count: ?UInt32 = null;

        if (!ignore_input_devices) {
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

            input_count = 0;

            // The size of an empty AudioBufferList is smaller than that of an AudioBuffer.
            if (device_stream_config_size >= @sizeOf(AudioBuffer)) {
                var stream_config_bytes = try allocator.alignedAlloc(u8, @alignOf(AudioBufferList), device_stream_config_size);
                var audio_buffer_list = @ptrCast(*AudioBufferList, &stream_config_bytes[0]);
                defer allocator.free(stream_config_bytes);

                checkStatus(
                    "AudioObjectGetPropertyData StreamConfiguration",
                    AudioObjectGetPropertyData(
                        device_id,
                        &device_stream_config_property_address,
                        0,
                        null,
                        &device_stream_config_size,
                        audio_buffer_list,
                    ),
                );

                input_count = audio_buffer_list.mNumberBuffers;
            }

            if (input_count.? > 0) {
                continue;
            }
        }

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
            std.debug.warn("Found Audio Device: \"{}\" ({} inputs)\n", .{ zig_name, input_count });
            return device_id;
        }
    }

    return null;
}

fn findAudioComponent(
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
            std.debug.warn("Selected Audio Component: \"{}\"\n", .{zig_name});
            return found;
        }

        current = found;
    }

    return null;
}

fn findMIDISource(allocator: *std.mem.Allocator, hint: []const u8) !?MIDIEndpointRef {
    const sources = MIDIGetNumberOfSources();
    var source_i: @TypeOf(sources) = 0;

    while (source_i < sources) : (source_i += 1) {
        const source = MIDIGetSource(source_i);
        var source_name: CFStringRef = undefined;

        checkStatus(
            "MIDIObjectGetStringProperty name",
            MIDIObjectGetStringProperty(
                source,
                kMIDIPropertyName,
                &source_name,
            ),
        );

        const zig_name = try convertCFString(allocator, source_name);
        defer allocator.free(zig_name);

        if (std.mem.indexOf(u8, zig_name, hint) != null) {
            std.debug.warn("Selected MIDI Source: {}\n", .{zig_name});
            return source;
        }
    }

    return null;
}
