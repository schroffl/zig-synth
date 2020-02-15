const AudioStreamBasicDescription = @import("includes.zig").AudioStreamBasicDescription;

pub const ADSR = struct {
    pub const Stage = enum {
        Idle,
        Attack,
        Decay,
        Sustain,
        Release,
    };

    attack: f32,
    decay: f32,
    sustain: f32,
    release: f32,

    stage: Stage,
    frames_passed: u32,
    release_from: f32,

    const Self = @This();

    pub fn init(
        a: f32,
        d: f32,
        s: f32,
        r: f32,
        format: AudioStreamBasicDescription,
    ) Self {
        return Self{
            .attack = a * @floatCast(f32, format.mSampleRate),
            .decay = d * @floatCast(f32, format.mSampleRate),
            .sustain = s,
            .release = r * @floatCast(f32, format.mSampleRate),
            .stage = .Idle,
            .frames_passed = 0,
            .release_from = 0,
        };
    }

    pub fn gate(self: *Self, state: bool) void {
        if (state) {
            self.stage = .Attack;
            self.frames_passed = 0;
        } else if (self.stage != .Idle) {
            self.stage = .Release;
            self.frames_passed = 0;
        }
    }

    pub fn getMultiplier(self: *Self, forFrames: u32) f32 {
        return switch (self.stage) {
            .Attack => {
                const value = @intToFloat(f32, self.frames_passed) / self.attack;

                self.frames_passed += forFrames;

                if (@intToFloat(f32, self.frames_passed) > self.attack) {
                    self.frames_passed = 0;
                    self.release_from = 1;
                    self.stage = .Decay;

                    return 1;
                } else {
                    self.release_from = value;
                    return value;
                }
            },
            .Decay => {
                const range = 1 - self.sustain;
                const value = @intToFloat(f32, self.frames_passed) / self.decay * range;

                self.frames_passed += forFrames;

                if (@intToFloat(f32, self.frames_passed) > self.decay) {
                    self.frames_passed = 0;
                    self.release_from = self.sustain;
                    self.stage = .Sustain;

                    return self.sustain;
                } else {
                    self.release_from = 1 - range;
                    return self.release_from;
                }
            },
            .Sustain => {
                return self.sustain;
            },
            .Release => {
                const value = @intToFloat(f32, self.frames_passed) / self.release * self.release_from;

                self.frames_passed += forFrames;

                if (@intToFloat(f32, self.frames_passed) > self.release) {
                    self.frames_passed = 0;
                    self.release_from = 0;
                    self.stage = .Idle;

                    return 0;
                } else {
                    return self.release_from - value;
                }
            },
            else => 0,
        };
    }
};
