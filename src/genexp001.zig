const std = @import("std");
const math = std.math;
const gl = @import("opengl.zig");
usingnamespace @import("util.zig");

pub const window_name = "genexp001";
pub const window_width = 1920;
pub const window_height = 1080;

pub const GenerativeExperimentState = struct {
    prng: std.rand.DefaultPrng,
    position: Vec2,

    pub fn init() GenerativeExperimentState {
        return GenerativeExperimentState{
            .prng = std.rand.DefaultPrng.init(0),
            .position = Vec2{ .x = 0.0, .y = 0.0 },
        };
    }

    pub fn deinit(self: GenerativeExperimentState) void {}
};

pub fn setup(genexp: *GenerativeExperimentState) !void {
    gl.pointSize(7.0);
    gl.enable(gl.BLEND);
    gl.blendFunc(gl.ONE, gl.ONE);
}

pub fn update(genexp: *GenerativeExperimentState, time: f64, dt: f32) void {
    const r = genexp.prng.random.int(u3);
    const position = &genexp.position;
    switch (r) {
        0 => position.x += 10.0,
        1 => position.x -= 10.0,
        2 => position.y += 10.0,
        3 => position.y -= 10.0,
        4 => {
            position.x += 10.0;
            position.y += 10.0;
        },
        5 => {
            position.x += 10.0;
            position.y -= 10.0;
        },
        6 => {
            position.x -= 10.0;
            position.y -= 10.0;
        },
        7 => {
            position.x -= 10.0;
            position.y += 10.0;
        },
    }

    if (position.x < -window_width * 0.5 or
        position.x > window_width * 0.5 or
        position.y < -window_height * 0.5 or
        position.y > window_height * 0.5)
    {
        position.x = 0.0;
        position.y = 0.0;
    }

    const rc = genexp.prng.random.uintLessThan(u8, 3);
    switch (rc) {
        0 => gl.color4f(0.5, 0.0, 0.0, 1.0),
        1 => gl.color4f(0.0, 0.5, 0.0, 1.0),
        2 => gl.color4f(0.0, 0.0, 0.5, 1.0),
        else => unreachable,
    }
    gl.begin(gl.POINTS);
    gl.vertex2f(position.x, position.y);
    gl.end();
}
