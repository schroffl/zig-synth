const std = @import("std");
const objc = @import("objc.zig");
usingnamespace @import("core_audio.zig");

const kOutputBus: UInt32 = 0;
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

pub fn main() anyerror!void {
    const NSRunLoop: objc.Class = objc.objc_getClass("NSRunLoop");
    const currentRunLoop: objc.id = objc.objc_msgSend(@ptrCast(objc.id, NSRunLoop), objc.sel_getUid("currentRunLoop"));
    defer _ = objc.objc_msgSend(currentRunLoop, objc.sel_getUid("run"));

    const desc = AudioComponentDescription{
        .componentType = kAudioUnitType_Output,
        .componentSubType = kAudioUnitSubType_DefaultOutput,
        .componentManufacturer = kAudioUnitManufacturer_Apple,
        .componentFlags = 0,
        .componentFlagsMask = 0,
    };

    std.debug.warn("{}\n", .{desc});

    const component = AudioComponentFindNext(null, &desc) orelse {
        std.debug.warn("AudioComponentFindNext failed\n", .{});
        exit(1);
    };

    var audio_unit: AudioUnit = undefined;
    checkStatus(
        "AudioComponentInstanceNew",
        AudioComponentInstanceNew(component, &audio_unit),
    );

    var trueFlag: UInt32 = 1;

    checkStatus(
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
        .inputProcRefCon = null,
    };

    checkStatus(
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

    checkStatus(
        "AudioUnitInitialize",
        AudioUnitInitialize(audio_unit),
    );

    checkStatus(
        "AudioOutputUnitStart",
        AudioOutputUnitStart(audio_unit),
    );
}

fn checkStatus(hint: []const u8, status: OSStatus) void {
    if (status != noErr) {
        std.debug.warn("{} failed with error: {}\n", .{ hint, status });
        exit(1);
    }
}

var totalFrames: u64 = 0;

fn renderCallback(input: ?*c_void, flags: [*c]AudioUnitRenderActionFlags, timestamp: [*c]const AudioTimeStamp, bus: UInt32, frames: UInt32, buffers: [*c]AudioBufferList) callconv(.C) OSStatus {
    var bufs = @ptrCast(*AudioBufferList, buffers);
    var buffer = bufs.mBuffers[0];
    var bufferData = @ptrCast([*c]f32, @alignCast(4, buffer.mData));

    var i: @TypeOf(frames) = 0;

    while (i < frames) : (i += 1) {
        var sample = totalFrames + i;
        var t = @intToFloat(f32, sample) / @floatCast(f32, format.mSampleRate) * std.math.pi * 2;

        bufferData[i] = std.math.sin(t * 440);
        bufferData[i] = (bufferData[i] + std.math.sin(t * 880)) / 2;
    }

    totalFrames += frames;

    return noErr;
}
