const std = @import("std");
const objc = @import("objc.zig");
const midi = @import("midi.zig");
const helper = @import("helper.zig");
const ADSR = @import("adsr.zig").ADSR;
usingnamespace @import("includes.zig");

const kOutputBus: UInt32 = 0;

pub fn main() !void {
    var startup_timer = try std.time.Timer.start();

    const allocator = std.testing.allocator;

    const format = AudioStreamBasicDescription{
        .mSampleRate = 44100,
        .mFormatID = kAudioFormatLinearPCM,
        .mFormatFlags = kLinearPCMFormatFlagIsFloat,
        .mBitsPerChannel = 32,
        .mChannelsPerFrame = 1,
        .mFramesPerPacket = 1,
        .mBytesPerPacket = 4,
        .mBytesPerFrame = 4,
        .mReserved = 0,
    };

    var state = State{
        .format = format,
        .total_frames = 0,
        .last_filter_sample = 0,
        .oscillators = try allocator.alloc(Oscillator, 3),
        .envelope = ADSR.init(0.03, 0, 1.0, 0.02, format),
    };

    defer allocator.free(state.oscillators);

    state.oscillators[0] = Oscillator{
        .frequency = midi.noteToFrequency(60),
        .phase = 0,
    };

    state.oscillators[1] = Oscillator{
        .frequency = midi.noteToFrequency(64),
        .phase = 0,
    };

    state.oscillators[2] = Oscillator{
        .frequency = midi.noteToFrequency(67),
        .phase = 0,
    };

    const desc = AudioComponentDescription{
        .componentType = kAudioUnitType_Output,
        .componentSubType = kAudioUnitSubType_HALOutput,
        .componentManufacturer = kAudioUnitManufacturer_Apple,
        .componentFlags = 0,
        .componentFlagsMask = 0,
    };

    const output_device = (try helper.findAudioDevice(allocator, "2ch")) orelse {
        std.debug.warn("Could not find specified audio device\n", .{});
        exit(1);
    };

    const component = (try helper.findAudioComponent(allocator, desc, "")) orelse {
        std.debug.warn("Could not find specified audio component\n", .{});
        exit(1);
    };

    const midi_source = (try midi.findMIDISource(allocator, "KeyStep")) orelse {
        std.debug.warn("Could not find specified midi source\n", .{});
        exit(1);
    };

    midi.setup(midiCallback, &state);

    var audio_unit: AudioUnit = undefined;
    helper.checkStatus(
        "AudioComponentInstanceNew",
        AudioComponentInstanceNew(component, &audio_unit),
    );

    var trueFlag: UInt32 = 1;

    helper.checkStatus(
        "AudioUnitSetProperty CurrentDevice",
        AudioUnitSetProperty(
            audio_unit,
            kAudioOutputUnitProperty_CurrentDevice,
            kAudioUnitScope_Output,
            kOutputBus,
            &output_device,
            @sizeOf(@TypeOf(output_device)),
        ),
    );

    helper.checkStatus(
        "AudioUnitSetProperty StreamFormat",
        AudioUnitSetProperty(
            audio_unit,
            kAudioUnitProperty_StreamFormat,
            kAudioUnitScope_Input,
            kOutputBus,
            &format,
            @sizeOf(@TypeOf(format)),
        ),
    );

    const callbackStruct = AURenderCallbackStruct{
        .inputProc = renderCallback,
        .inputProcRefCon = &state,
    };

    helper.checkStatus(
        "AudioUnitSetProperty SetRenderCallback",
        AudioUnitSetProperty(
            audio_unit,
            kAudioUnitProperty_SetRenderCallback,
            kAudioUnitScope_Global,
            kOutputBus,
            &callbackStruct,
            @sizeOf(@TypeOf(callbackStruct)),
        ),
    );

    helper.checkStatus(
        "AudioUnitInitialize",
        AudioUnitInitialize(audio_unit),
    );

    helper.checkStatus(
        "AudioOutputUnitStart",
        AudioOutputUnitStart(audio_unit),
    );

    const NSRunLoop: objc.Class = objc.objc_getClass("NSRunLoop");
    const currentRunLoop: objc.id = objc.objc_msgSend(@ptrCast(objc.id, NSRunLoop), objc.sel_getUid("currentRunLoop"));

    const startup_took = startup_timer.read();
    const startup_took_ms = @intToFloat(f64, startup_took) / 1000000;
    std.debug.warn("Startup took {d:.3}ms\n", .{startup_took_ms});

    _ = objc.objc_msgSend(currentRunLoop, objc.sel_getUid("run"));
}

fn midiCallback(
    pktlist_c: [*c]const MIDIPacketList,
    input: ?*c_void,
    src: ?*c_void,
) callconv(.C) void {
    const pktlist = pktlist_c[0];
    var packet = pktlist.packet[0];
    var packet_i: @TypeOf(pktlist.numPackets) = 0;

    var state = @ptrCast(*State, @alignCast(@alignOf(State), input));

    while (packet_i < pktlist.numPackets) : ({
        packet_i += 1;
        packet = MIDIPacketNext(&packet)[0];
    }) {
        const data = packet.data[0..packet.length];
        const msg = midi.Message.parse(data);

        switch (msg) {
            .NoteOn => |info| {
                const freq = midi.noteToFrequency(info.note);

                state.oscillators[0].frequency = midi.noteToFrequency(info.note);
                state.oscillators[1].frequency = midi.noteToFrequency(info.note + 4);
                state.oscillators[2].frequency = midi.noteToFrequency(info.note + 7);
                state.envelope.gate(true);
            },
            .NoteOff => |info| {
                state.envelope.gate(false);
            },
            else => {},
        }
    }
}

const State = struct {
    format: AudioStreamBasicDescription,
    total_frames: u64,
    last_filter_sample: f32,
    oscillators: []Oscillator,
    envelope: ADSR,
};

const Oscillator = struct {
    frequency: f32,
    phase: f32,

    pub fn sample(self: Oscillator, t: f32) f32 {
        return std.math.sin(self.frequency * t + self.phase);
    }
};

fn renderCallback(
    input: ?*c_void,
    flags: [*c]AudioUnitRenderActionFlags,
    timestamp: [*c]const AudioTimeStamp,
    bus: UInt32,
    frames: UInt32,
    buffers: [*c]AudioBufferList,
) callconv(.C) OSStatus {
    var timer = std.time.Timer.start() catch unreachable;

    var bufs = @ptrCast(*AudioBufferList, buffers);
    var buffer = bufs.mBuffers[0];
    var bufferData = @ptrCast([*c]f32, @alignCast(4, buffer.mData));
    const state = @ptrCast(*State, @alignCast(@alignOf(State), input));

    var i: @TypeOf(frames) = 0;

    const t_base = @intToFloat(f32, state.total_frames) / @floatCast(f32, state.format.mSampleRate);
    const t_inc = 1 / @floatCast(f32, state.format.mSampleRate);

    while (i < frames) : (i += 1) {
        const t = t_base + t_inc * @intToFloat(f32, i);
        const t_cycle = t * std.math.pi * 2;
        const adsr_value = state.envelope.getMultiplier(1);

        var value: f32 = 0;

        for (state.oscillators) |osc| {
            value += osc.sample(t_cycle);
        }

        bufferData[i] = value / 3 * adsr_value;
    }

    state.last_filter_sample = bufferData[frames - 1];
    state.total_frames += frames;

    return noErr;
}
