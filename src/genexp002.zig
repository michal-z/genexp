const builtin = @import("builtin");
const std = @import("std");
const c = @import("c.zig");
const math = std.math;
const allocator = std.heap.c_allocator;
usingnamespace @import("util.zig");

pub const window_name = "genexp002";
pub const window_width = 1920;
pub const window_height = 1080;

const num_objects = 128;

pub const GenerativeExperimentState = struct {
    prng: std.rand.DefaultPrng = undefined,
    positions: []Vec2 = &[_]Vec2{},
    velocities: []Vec2 = &[_]Vec2{},
    accelerations: []Vec2 = &[_]Vec2{},
};

pub fn init(genexp: *GenerativeExperimentState) !void {
    genexp.prng = std.rand.DefaultPrng.init(0);
    const rand = &genexp.prng.random;

    c.glPointSize(127.0);
    c.glEnable(c.GL_BLEND);
    c.glBlendFunc(c.GL_SRC_ALPHA, c.GL_ONE_MINUS_SRC_ALPHA);

    genexp.positions = try allocator.alloc(Vec2, num_objects);
    genexp.velocities = try allocator.alloc(Vec2, num_objects);
    genexp.accelerations = try allocator.alloc(Vec2, num_objects);

    for (genexp.positions) |*pos| {
        pos.*.x = 2.0 * rand.float(f32) - 1.0;
        pos.*.y = 2.0 * rand.float(f32) - 1.0;
        pos.*.x *= window_width * 0.5;
        pos.*.y *= window_height * 0.5;
    }

    for (genexp.velocities) |*vel| {
        vel.*.x = 2.0 * rand.float(f32) - 1.0;
        vel.*.y = 2.0 * rand.float(f32) - 1.0;
    }
}

pub fn update(genexp: *GenerativeExperimentState, time: f64, dt: f32) void {
    const rand = &genexp.prng.random;

    for (genexp.accelerations) |*accel| {
        accel.*.x = 2.0 * rand.float(f32) - 1.0;
        accel.*.y = 2.0 * rand.float(f32) - 1.0;
    }

    for (genexp.positions) |pos, i| {
        if (pos.x < -0.5 * @intToFloat(f32, window_width) or
            pos.x > 0.5 * @intToFloat(f32, window_width) or
            pos.y < -0.5 * @intToFloat(f32, window_height) or
            pos.y > 0.5 * @intToFloat(f32, window_height))
        {
            const f = -1.2;
            const npos = pos.normalize();
            genexp.accelerations[i].x += f * npos.x;
            genexp.accelerations[i].y += f * npos.y;
        }
    }

    for (genexp.velocities) |*vel, i| {
        vel.*.x += genexp.accelerations[i].x;
        vel.*.y += genexp.accelerations[i].y;
        vel.*.x = if (vel.*.x < -10.0) -10.0 else if (vel.*.x > 10.0) 10.0 else vel.*.x;
        vel.*.y = if (vel.*.y < -10.0) -10.0 else if (vel.*.y > 10.0) 10.0 else vel.*.y;
        genexp.positions[i].x += vel.*.x;
        genexp.positions[i].y += vel.*.y;
    }

    c.glClearBufferfv(c.GL_COLOR, 0, &[4]f32{ 0.2, 0.4, 0.8, 1.0 });
    c.glColor4f(1.0, 1.0, 1.0, 0.75);
    c.glEnableClientState(c.GL_VERTEX_ARRAY);
    c.glVertexPointer(2, c.GL_FLOAT, 0, genexp.positions.ptr);
    c.glDrawArrays(c.GL_POINTS, 0, @intCast(c_int, genexp.positions.len));
    c.glDisableClientState(c.GL_VERTEX_ARRAY);
}

pub fn deinit(genexp: *GenerativeExperimentState) void {
    allocator.free(genexp.positions);
    allocator.free(genexp.velocities);
    allocator.free(genexp.accelerations);
}
