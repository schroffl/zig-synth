const std = @import("std");
const wave = @import("wavetable.zig");
const midi = @import("midi.zig");
const util = @import("util.zig");
const adsr = @import("adsr.zig");

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

pub const Synth = struct {
    allocator: *std.mem.Allocator,
    envelope: adsr.ADSR,
    oscillator: wave.WavetableOscillator,
    sub_oscillator: wave.WavetableOscillator,
    oscillator_mix: f32 = 0.5,

    pub fn init(allocator: *std.mem.Allocator, format: util.Format) !Synth {
        if (default_table == null) {
            try populateDefaultTable(allocator);
        }

        return Synth{
            .allocator = allocator,
            .envelope = adsr.ADSR.init(.{
                .format = format,
                .attack = 0.07,
                .decay = 0.03,
                .sustain = 0.0,
                .release = 0.2,
            }),
            .oscillator = try wave.WavetableOscillator.init(allocator, .{
                .format = format,
                .table = default_table.?,
            }),
            .sub_oscillator = try wave.WavetableOscillator.init(allocator, .{
                .format = format,
                .table = default_table.?,
            }),
        };
    }

    pub fn deinit(self: *Synth) void {
        const table = default_table;
        default_table = null;

        self.aclloator.free(table.waveforms);
    }

    pub fn handleMIDIMessage(self: *Synth, message: midi.Message) void {
        switch (message) {
            .NoteOn => |info| {
                const frequency = @floatCast(f32, midi.noteToFrequency(info.note));
                self.envelope.gate(true);

                self.oscillator.reset();
                self.sub_oscillator.reset();

                var params = self.oscillator.params.read();
                params.frequency = @floatCast(f32, frequency);
                self.oscillator.updateParams(params);

                var sub_params = self.sub_oscillator.params.read();
                sub_params.frequency = frequency;
                self.sub_oscillator.updateParams(sub_params);
            },
            .NoteOff => |info| {
                self.envelope.gate(false);
            },
            .PitchBend => |info| {
                const percentage = @intToFloat(f32, info.value) / std.math.maxInt(@TypeOf(info.value));
                const detune = (percentage * 2 - 1) * 30;

                var params = self.oscillator.params.read();
                params.detune = detune;
                self.oscillator.updateParams(params);
            },
            .ControlChange => |cc| {
                switch (cc.controller) {
                    1 => {
                        const value = @intToFloat(f32, cc.value) / std.math.maxInt(@TypeOf(cc.value));

                        switch (cc.channel) {
                            0 => {
                                var params = self.oscillator.params.read();
                                params.position = value;
                                self.oscillator.updateParams(params);
                            },
                            1 => {
                                var sub_params = self.sub_oscillator.params.read();
                                sub_params.position = value;
                                self.sub_oscillator.updateParams(sub_params);
                            },
                            2 => {
                                @atomicStore(f32, &self.oscillator_mix, value, .SeqCst);
                            },
                            3 => {
                                var sub_params = self.sub_oscillator.params.read();
                                sub_params.detune = value * 10;
                                self.sub_oscillator.updateParams(sub_params);
                            },
                            4 => {
                                // var filter_params = self.filter.params.read();
                                // filter_params.frequency = 100 + value * 2000;
                                // self.filter.params.write(filter_params);
                                // self.filter.updateInternals();
                            },
                            else => {},
                        }
                    },
                    else => {},
                }
            },
            else => {},
        }
    }

    pub fn sampleInto(self: *Synth, buffer: []f32) void {
        const mix = self.oscillator_mix;

        for (buffer) |_, i| {
            const a = self.oscillator.sample();
            const b = self.sub_oscillator.sample();

            buffer[i] = a * mix + b * (1 - mix);
            buffer[i] *= self.envelope.getMultiplier(1);
        }
    }
};

test "synth" {
    _ = @import("wavetable.zig");
}
