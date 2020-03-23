const std = @import("std");
const wave = @import("wavetable.zig");
const midi = @import("midi.zig");
const util = @import("util.zig");
const adsr = @import("adsr.zig");
const Host = @import("root").Host;

var default_table: ?wave.WaveformTable = null;

fn populateDefaultTable(allocator: *std.mem.Allocator) !void {
    var table = wave.WaveformTable{
        .waveforms = try allocator.alloc(wave.Waveform, 3),
    };

    table.waveforms[0] = wave.Waveform.sineWave(1);
    table.waveforms[1] = wave.Waveform.sawtoothWave(1, 40);
    table.waveforms[2] = wave.Waveform.squareWave(1, 40);

    default_table = table;
}

const NoteOnMessage = std.meta.fieldInfo(midi.Message, "NoteOn").field_type;

pub const Synth = struct {
    const Voice = struct {
        envelope: adsr.ADSR,
        oscillator_one: wave.WavetableOscillator,
        oscillator_two: wave.WavetableOscillator,
        oscillator_mix: f32 = 0.5,
        volume: f32 = 1,

        pub inline fn sample(self: *Voice) f32 {
            const one = self.oscillator_one.sample() * (1 - self.oscillator_mix);
            const two = self.oscillator_two.sample() * self.oscillator_mix;
            const multiplier = self.envelope.getMultiplier(1);

            return (one + two) * multiplier * self.volume;
        }

        pub fn reset(self: *Voice) void {
            self.oscillator_one.reset();
            self.oscillator_two.reset();
        }

        pub fn start(self: *Voice, msg: NoteOnMessage) void {
            const frequency = @floatCast(f32, midi.noteToFrequency(msg.note));
            self.volume = midi.velocityToFloat(f32, msg.velocity);

            var params_one = self.oscillator_one.params.read();
            params_one.frequency = frequency;
            self.oscillator_one.updateParams(params_one);
            self.oscillator_one.reset();

            var params_two = self.oscillator_two.params.read();
            params_two.frequency = frequency;
            self.oscillator_two.updateParams(params_two);
            self.oscillator_two.reset();

            self.envelope.gate(true);
        }
    };

    const VoiceWrapper = struct {
        // The u8 is required for @atomicStore to work right now.
        const State = enum(u8) {
            Free,
            Scheduled,
            Playing,
        };

        state: State = .Free,
        note: u7,
        voice: Voice,

        pub fn setup(self: *VoiceWrapper, msg: NoteOnMessage) bool {
            const xchg = @cmpxchgStrong(State, &self.state, .Free, .Scheduled, .SeqCst, .SeqCst);

            // Failed to acquire the voice
            if (xchg != null) {
                return false;
            }

            self.note = msg.note;
            self.voice.start(msg);

            @atomicStore(State, &self.state, .Playing, .SeqCst);

            return true;
        }

        pub fn free(self: *VoiceWrapper) void {
            @atomicStore(State, &self.state, .Free, .SeqCst);
        }
    };

    const VoiceCount = 8;

    allocator: *std.mem.Allocator,
    voices: []VoiceWrapper,

    pub fn init(allocator: *std.mem.Allocator, format: util.Format) !Synth {
        if (default_table == null) {
            try populateDefaultTable(allocator);
        }

        var self = Synth{
            .allocator = allocator,
            .voices = try allocator.alloc(VoiceWrapper, VoiceCount),
        };

        for (self.voices) |*wrapper| {
            wrapper.state = .Free;
            wrapper.voice = .{
                .envelope = adsr.ADSR.init(.{
                    .format = format,
                    .attack = 0.1,
                    .decay = 0.03,
                    .sustain = 0.4,
                    .release = 0.7,
                }),
                .oscillator_one = try wave.WavetableOscillator.init(allocator, .{
                    .format = format,
                    .table = default_table.?,
                }),
                .oscillator_two = try wave.WavetableOscillator.init(allocator, .{
                    .format = format,
                    .table = default_table.?,
                }),
            };
        }

        return self;
    }

    pub fn deinit(self: *Synth) void {
        const table = default_table;
        default_table = null;

        self.allocator.free(table.waveforms);
        self.allocator.free(self.voices);
    }

    pub fn handleMIDIMessage(self: *Synth, message: midi.Message) void {
        switch (message) {
            .NoteOn => |info| {
                for (self.voices) |*wrapper, i| {
                    switch (wrapper.state) {
                        .Scheduled, .Playing => {},
                        .Free => {
                            if (wrapper.setup(info)) {
                                break;
                            }
                        },
                    }
                } else {
                    var quiet_voice: ?*VoiceWrapper = null;
                    var quiet_volume: ?f32 = null;

                    for (self.voices) |*wrapper| {
                        const volume = wrapper.voice.volume * wrapper.voice.envelope.getMultiplier(0);

                        if (quiet_volume == null or volume < quiet_volume.?) {
                            quiet_volume = volume;
                            quiet_voice = wrapper;
                        }
                    }

                    if (quiet_voice) |wrapper| {
                        // TODO Maybe we should give the stolen voice a few milliseconds to fade out
                        wrapper.free();

                        if (!wrapper.setup(info)) {
                            unreachable;
                        }
                    } else unreachable;
                }
            },
            .NoteOff => |info| {
                // Find the voice that is playing the released note and
                // stop its envelope.
                for (self.voices) |*wrapper| {
                    switch (wrapper.state) {
                        .Free, .Scheduled => {},
                        .Playing => {
                            if (wrapper.note == info.note) {
                                wrapper.voice.envelope.gate(false);
                            }
                        },
                    }
                }
            },

            // TODO Implement polyphonic parameter update
            .PitchBend => |info| {
                const percentage = @intToFloat(f32, info.value) / std.math.maxInt(@TypeOf(info.value));
                const detune = (percentage * 2 - 1) * 30;
            },
            .ControlChange => |cc| {},
            else => {},
        }
    }

    pub fn sampleInto(self: *Synth, buffer: []f32) void {
        // TODO Find it out if this is the way to go.  The idea is that all voices
        //      combined add up to one when they play at their loudest.
        const scale = 1 / @intToFloat(f32, self.voices.len);

        for (self.voices) |*wrapper, wrapper_i| {
            for (buffer) |_, i| {
                const value = switch (wrapper.state) {
                    .Free, .Scheduled => 0,
                    .Playing => result: {
                        const voice_value = wrapper.voice.sample();

                        if (wrapper.voice.envelope.stage == .Idle) {
                            wrapper.free();
                        }

                        break :result voice_value;
                    },
                } * scale;

                // On macOS the buffer is filled with garbage data in the beginning.
                // The first voice should write without consideration of that data.
                // Maybe the host should take care of zeroing the buffer before
                // passing it to the synthesizer?
                if (wrapper_i == 0) {
                    buffer[i] = value;
                } else {
                    buffer[i] += value;
                }
            }
        }
    }
};
