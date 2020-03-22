const std = @import("std");
const testing = std.testing;
const util = @import("util.zig");

pub const Waveform = struct {
    const Bits = 12;

    pub const Size = std.math.pow(usize, 2, Bits);
    pub const IndexMask = Size - 1;
    pub const Index = @Type(.{
        .Int = .{
            .is_signed = false,
            .bits = Bits,
        },
    });

    pub const Scanner = struct {
        pub const T = switch (std.Target.current.cpu.arch) {
            .wasm32 => f32,
            else => f64,
        };

        position: T = 0,
        step_size: T = 0,

        pub inline fn advance(self: *Scanner) void {
            self.position += self.step_size;

            // TODO Find out if the while loop is more expensive than a single if.
            //      If so, for whatever reason, we can use that. It's not so correct,
            //      but the index masking in the interpolate function should take care
            //      of that.
            while (self.position >= Waveform.Size) {
                self.position -= @intToFloat(T, Waveform.Size);
            }
        }

        pub inline fn calculateStepSize(self: *Scanner, format: util.Format, frequency: f32) void {
            const step_size = @intToFloat(T, Waveform.Size) * frequency / format.sample_rate;
            @atomicStore(T, &self.step_size, step_size, .SeqCst);
        }

        pub inline fn reset(self: *Scanner) void {
            @atomicStore(T, &self.position, 0, .SeqCst);
        }
    };

    data: [Size]f32,

    pub inline fn interpolate(self: Waveform, scanner: Scanner) f32 {
        const position = scanner.position;
        const index_a = @floatToInt(usize, @trunc(position));
        const index_b = @floatToInt(usize, @ceil(position)) & IndexMask;

        const value_a = self.data[index_a];
        const value_b = self.data[index_b];
        const lerp_t = position - @trunc(position);

        return value_a + (value_b - value_a) * @floatCast(f32, lerp_t);
    }

    pub fn squareWave(base_frequency: f64, harmonics: usize) Waveform {
        var result = Waveform{
            .data = undefined,
        };

        for (result.data) |_, i| {
            const progress = @intToFloat(f64, i) / @intToFloat(f64, result.data.len);

            var value: f64 = 0;
            var value_index: usize = 0;

            while (value_index < harmonics) : (value_index += 1) {
                const k = @intToFloat(f64, value_index);
                const two_k_one = 2 * k + 1;

                const value_f64 = (1 / two_k_one) * std.math.sin(progress * std.math.pi * 2 * base_frequency * two_k_one);
                value += value_f64;
            }

            result.data[i] = @floatCast(f32, value);
        }

        return result;
    }

    pub fn sineWave(base_frequency: f64) Waveform {
        var result = Waveform{
            .data = undefined,
        };

        for (result.data) |_, i| {
            const progress = @intToFloat(f64, i) / @intToFloat(f64, result.data.len);
            const value = std.math.sin(progress * std.math.pi * 2 * base_frequency);

            result.data[i] = @floatCast(f32, value);
        }

        return result;
    }

    pub fn sawtoothWave(base_frequency: f64, harmonics: usize) Waveform {
        var result = Waveform{
            .data = undefined,
        };

        const factor = @as(f64, 2) / std.math.pi;

        for (result.data) |_, i| {
            const progress = @intToFloat(f64, i) / @intToFloat(f64, result.data.len);

            var value: f64 = 0;
            var value_index: usize = 1;

            while (value_index < harmonics + 1) : (value_index += 1) {
                const k = @intToFloat(f64, value_index);
                const sign = std.math.pow(f64, -1, k - 1);

                value += sign * std.math.sin(progress * std.math.pi * 2 * base_frequency * k) / k;
            }

            result.data[i] = @floatCast(f32, factor * value);
        }

        return result;
    }

    pub fn triangleWave(base_frequency: f64, harmonics: usize) Waveform {
        var result = Waveform{
            .data = undefined,
        };

        return result;
    }

    pub fn noise(rand: *std.rand.Random) Waveform {
        var result = Waveform{
            .data = undefined,
        };

        for (result.data) |_, i| {
            result.data[i] = rand.float(f32) * 2 - 1;
        }

        return result;
    }
};

pub const WaveformTable = struct {
    waveforms: []Waveform,
};

pub const WavetableOscillator = struct {
    pub const Params = util.Parameters(struct {
        table: WaveformTable,
        format: util.Format,
        frequency: f32 = 0,
        detune: f32 = 0,
        position: f32 = 0,
    });

    params: Params,

    // Internal
    allocator: *std.mem.Allocator,

    // Can we add Unison by using multiple scanners with
    // slightly offset step sizes?
    scanner: Waveform.Scanner,
    index_a: usize,
    index_b: usize,
    mix: f32,

    pub fn init(allocator: *std.mem.Allocator, initial_params: Params.Child) !WavetableOscillator {
        var self = WavetableOscillator{
            .params = Params.init(initial_params),

            .allocator = allocator,

            .scanner = .{},
            .index_a = undefined,
            .index_b = undefined,
            .mix = undefined,
        };

        self.updateParams(initial_params);

        return self;
    }

    pub fn sample(self: *WavetableOscillator) f32 {
        defer self.scanner.advance();

        const table = self.params.read().table;
        const value_a = table.waveforms[self.index_a].interpolate(self.scanner);
        const value_b = table.waveforms[self.index_b].interpolate(self.scanner);

        return value_a * self.mix + value_b * (1 - self.mix);
    }

    pub fn reset(self: *WavetableOscillator) void {
        self.scanner.reset();
    }

    pub fn updateParams(self: *WavetableOscillator, params: Params.Child) void {
        const freq = params.frequency + params.detune;
        const adjusted_pos = params.position * @intToFloat(f32, params.table.waveforms.len - 1);

        self.params.write(params);
        self.index_a = @floatToInt(usize, @floor(adjusted_pos));
        self.index_b = @floatToInt(usize, @ceil(adjusted_pos));
        self.mix = @ceil(adjusted_pos) - adjusted_pos;
        self.scanner.calculateStepSize(params.format, freq);
    }
};

test "Waveform.squareWave" {
    const square = Waveform.squareWave(1, 1);
    const sine = Waveform.sineWave(1);

    testing.expect(std.mem.eql(f32, &square.data, &sine.data));

    const square2 = Waveform.squareWave(1, 4);

    var sine1 = Waveform.sineWave(1);
    var sine2 = Waveform.sineWave(3);
    var sine3 = Waveform.sineWave(5);
    var sine4 = Waveform.sineWave(7);
    var sine_final = Waveform{ .data = undefined };

    const bm = util.buffer_math;

    bm.multScalar(f32, &sine2.data, 1 / @as(f32, 3), &sine2.data);
    bm.multScalar(f32, &sine3.data, 1 / @as(f32, 5), &sine3.data);
    bm.multScalar(f32, &sine4.data, 1 / @as(f32, 7), &sine4.data);

    bm.add(f32, &sine1.data, &sine2.data, &sine_final.data);
    bm.add(f32, &sine_final.data, &sine3.data, &sine_final.data);
    bm.add(f32, &sine_final.data, &sine4.data, &sine_final.data);

    const eql = bm.approxEq(f32, &square2.data, &sine_final.data, 0.000001);

    testing.expect(eql);
}

test "Waveform.Scanner" {
    const T = Waveform.Scanner.T;
    var scanner = Waveform.Scanner{};

    scanner.calculateStepSize(.{
        .sample_rate = 44100,
        .channel_count = 1,
    }, 440);

    std.testing.expectEqual(@as(T, 0), scanner.position);
    std.testing.expect(std.math.approxEq(T, 40.8671201814, scanner.step_size, 0.0000001));

    scanner.position = 4080;
    scanner.advance();

    std.testing.expect(std.math.approxEq(T, scanner.step_size - 16, scanner.position, 0.0000001));
}

test "Waveform.interpolate" {
    var waveform = Waveform{
        .data = undefined,
    };

    waveform.data[0] = 0;
    waveform.data[1] = 1;
    waveform.data[2] = 11;

    var scanner: Waveform.Scanner = .{};

    scanner.position = 0.5;
    std.testing.expectEqual(@as(f32, 0.5), waveform.interpolate(scanner));

    scanner.position = 0.25;
    std.testing.expectEqual(@as(f32, 0.25), waveform.interpolate(scanner));

    scanner.position = 1.5;
    std.testing.expectEqual(@as(f32, 6), waveform.interpolate(scanner));
}
