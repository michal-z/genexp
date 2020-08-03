const builtin = @import("builtin");
const std = @import("std");
const c = @import("c.zig");
const math = std.math;
const default_allocator = std.heap.c_allocator;
usingnamespace @import("util.zig");

pub const window_name = "genexp002";
pub const window_width = 1920;
pub const window_height = 1080;

const num_objects = 256;
const max_vel = 5.0;

pub const GenerativeExperimentState = struct {
    prng: std.rand.DefaultPrng,
    positions: []Vec2,
    colors: []Color,
    velocities: []Vec2,
    accelerations: []Vec2,

    pub fn init() GenerativeExperimentState {
        return GenerativeExperimentState{
            .prng = std.rand.DefaultPrng.init(0),
            .positions = &[_]Vec2{},
            .colors = &[_]Color{},
            .velocities = &[_]Vec2{},
            .accelerations = &[_]Vec2{},
        };
    }

    pub fn deinit(self: GenerativeExperimentState) void {
        default_allocator.free(self.positions);
        default_allocator.free(self.colors);
        default_allocator.free(self.velocities);
        default_allocator.free(self.accelerations);
    }
};

pub fn setup(genexp: *GenerativeExperimentState) !void {
    const rand = &genexp.prng.random;

    c.glLineWidth(5.0);
    c.glEnable(c.GL_BLEND);
    c.glBlendFunc(c.GL_SRC_ALPHA, c.GL_ONE_MINUS_SRC_ALPHA);

    genexp.positions = try default_allocator.alloc(Vec2, num_objects);
    genexp.colors = try default_allocator.alloc(Color, num_objects);
    genexp.velocities = try default_allocator.alloc(Vec2, num_objects);
    genexp.accelerations = try default_allocator.alloc(Vec2, num_objects);

    for (genexp.positions) |*pos| {
        pos.*.x = 2.0 * rand.float(f32) - 1.0;
        pos.*.y = 2.0 * rand.float(f32) - 1.0;
        pos.*.x *= window_width * 0.5;
        pos.*.y *= window_height * 0.5;
    }

    for (genexp.colors) |*color| {
        color.*.r = rand.int(u8);
        color.*.g = rand.int(u8);
        color.*.b = rand.int(u8);
        color.*.a = 128;
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

    c.glColor4f(0.0, 0.0, 0.0, 0.1);
    c.glBegin(c.GL_QUADS);
    c.glVertex2i(-window_width / 2, -window_height / 2);
    c.glVertex2i(window_width / 2, -window_height / 2);
    c.glVertex2i(window_width / 2, window_height / 2);
    c.glVertex2i(-window_width / 2, window_height / 2);
    c.glEnd();

    c.glBegin(c.GL_LINES);
    for (genexp.velocities) |*vel, i| {
        vel.*.x += genexp.accelerations[i].x;
        vel.*.y += genexp.accelerations[i].y;
        vel.*.x = if (vel.*.x < -max_vel) -max_vel else if (vel.*.x > max_vel) max_vel else vel.*.x;
        vel.*.y = if (vel.*.y < -max_vel) -max_vel else if (vel.*.y > max_vel) max_vel else vel.*.y;

        c.glColor4ub(genexp.colors[i].r, genexp.colors[i].g, genexp.colors[i].b, 200);
        c.glVertex2f(genexp.positions[i].x, genexp.positions[i].y);

        genexp.positions[i].x += vel.*.x;
        genexp.positions[i].y += vel.*.y;

        c.glVertex2f(genexp.positions[i].x, genexp.positions[i].y);
    }
    c.glEnd();
}
