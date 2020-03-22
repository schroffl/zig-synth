const util = @import("util.zig");

pub const ADSR = struct {
    pub const Stage = enum {
        Idle,
        Attack,
        Decay,
        Sustain,
        Release,
    };

    pub const Params = util.Parameters(struct {
        format: util.Format,

        /// The multiplier for when a tone is held after its decay,
        /// but before being released.
        sustain: f32,

        /// Time to attack in seconds
        attack: f64,

        /// Time to decay in seconds
        decay: f64,

        /// Time to release in seconds
        release: f64,
    });

    params: Params,

    samples_attack: f32,
    samples_decay: f32,
    samples_release: f32,

    stage: Stage,
    frames_passed: f32,
    release_from: f32,

    const Self = @This();

    pub fn init(initial_params: Params.Child) Self {
        var self = Self{
            .params = Params.init(initial_params),
            .samples_attack = 0,
            .samples_decay = 0,
            .samples_release = 0,
            .stage = .Idle,
            .frames_passed = 0,
            .release_from = 0,
        };

        self.updateParams(initial_params);

        return self;
    }

    pub fn updateParams(self: *Self, params: Params.Child) void {
        const rate = params.format.sample_rate;

        self.params.write(params);

        self.samples_attack = @floatCast(f32, params.attack * rate);
        self.samples_decay = @floatCast(f32, params.decay * rate);
        self.samples_release = @floatCast(f32, params.release * rate);
    }

    pub fn gate(self: *Self, state: bool) void {
        if (state) {
            switch (self.stage) {
                .Attack => {},
                .Decay => {},
                .Sustain => {},
                .Idle => {
                    self.stage = .Attack;
                    self.frames_passed = 0;
                },
                .Release => {
                    // TODO Is this the correct thing to do? How do other implementations
                    //      handle the case "Release -> Attack".
                    self.frames_passed = self.getMultiplier(0) * self.samples_attack;
                    self.stage = .Attack;
                },
            }
        } else if (self.stage != .Idle and self.stage != .Release) {
            self.stage = .Release;
            self.frames_passed = 0;
        }
    }

    pub fn getMultiplier(self: *Self, forFrames: u32) f32 {
        return switch (self.stage) {
            .Attack => {
                const value = self.frames_passed / self.samples_attack;

                self.frames_passed += @intToFloat(f32, forFrames);

                if (self.frames_passed > self.samples_attack) {
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
                const params = self.params.read();
                const progress = self.frames_passed / self.samples_decay;
                const value_range = 1 - params.sustain;
                const value = 1 - value_range * progress;

                self.frames_passed += @intToFloat(f32, forFrames);

                if (self.frames_passed > self.samples_decay) {
                    self.frames_passed = 0;
                    self.release_from = params.sustain;
                    self.stage = .Sustain;

                    return params.sustain;
                } else {
                    self.release_from = value;
                    return value;
                }
            },
            .Sustain => {
                const params = self.params.read();
                return params.sustain;
            },
            .Release => {
                const value = self.frames_passed / self.samples_release * self.release_from;

                self.frames_passed += @intToFloat(f32, forFrames);

                if (self.frames_passed > self.samples_release) {
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
