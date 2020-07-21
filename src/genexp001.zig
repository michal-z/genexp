const builtin = @import("builtin");
const std = @import("std");
const c = @import("c.zig");
const math = std.math;
usingnamespace @import("util.zig");

pub const window_name = "genexp001";
pub const window_width = 1920;
pub const window_height = 1080;

pub const GenerativeExperimentState = struct {
    prng: std.rand.DefaultPrng = undefined,
    position: Vec2 = .{ .x = 0.0, .y = 0.0 },
};

pub fn init(genexp: *GenerativeExperimentState) !void {
    genexp.prng = std.rand.DefaultPrng.init(0);
    c.glPointSize(7.0);
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

    c.glColor4f(0.0, 0.5, 0.0, 1.0);
    c.glBegin(c.GL_POINTS);
    c.glVertex2f(position.x, position.y);
    c.glEnd();
}

pub fn deinit(genexp: *GenerativeExperimentState) void {}
