const builtin = @import("builtin");
const std = @import("std");
const c = @import("c.zig");
const math = std.math;
usingnamespace @import("util.zig");

pub const window_name = "genexp002";
pub const window_width = 1920;
pub const window_height = 1080;

pub const GenerativeExperimentState = struct {
    prng: std.rand.DefaultPrng = undefined,
    data: std.ArrayList(Vec2) = undefined,
};

pub fn init(genexp: *GenerativeExperimentState) !void {
    genexp.prng = std.rand.DefaultPrng.init(0);

    c.glLineWidth(3.0);
    c.glPointSize(7.0);
    c.glEnable(c.GL_BLEND);
    c.glBlendFunc(c.GL_SRC_ALPHA, c.GL_ONE_MINUS_SRC_ALPHA);

    genexp.data = try @TypeOf(genexp.data).initCapacity(std.heap.page_allocator, 1024);
    try genexp.data.append(Vec2{ .x = 100.0, .y = 100.0 });
    try genexp.data.append(Vec2{ .x = 0.0, .y = 0.0 });
}

pub fn update(genexp: *GenerativeExperimentState, time: f64, dt: f32) void {
    c.glClearBufferfv(c.GL_COLOR, 0, &[4]f32{ 1.0, 1.0, 1.0, 1.0 });
    //c.glColor4f(0.0, 0.0, 0.0, 1.0);
    //c.glEnableClientState(c.GL_VERTEX_ARRAY);
    //c.glVertexPointer(2, c.GL_FLOAT, 0, demo.data.items.ptr);
    //c.glDrawArrays(c.GL_POINTS, 0, @intCast(c_int, demo.data.items.len));
    //c.glDisableClientState(c.GL_VERTEX_ARRAY);
}

pub fn deinit(genexp: *GenerativeExperimentState) void {}
