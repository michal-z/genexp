const builtin = @import("builtin");
const std = @import("std");
const c = @import("c.zig");
const math = std.math;
const default_allocator = std.heap.c_allocator;
const ArrayList = std.ArrayList;
usingnamespace @import("util.zig");

pub const window_name = "genexp003";
pub const window_width = 1920;
pub const window_height = 1080;

pub const GenerativeExperimentState = struct {
    prng: std.rand.DefaultPrng,
    square: SandShape,
    triangle: SandShape,

    pub fn init() GenerativeExperimentState {
        return GenerativeExperimentState{
            .prng = std.rand.DefaultPrng.init(0),
            .square = SandShape.init(default_allocator),
            .triangle = SandShape.init(default_allocator),
        };
    }

    pub fn deinit(self: GenerativeExperimentState) void {
        self.square.deinit();
        self.triangle.deinit();
    }
};

const SandPoint = struct {
    p: [16]Vec2,

    fn init(x: f32, y: f32, rand: *std.rand.Random) SandPoint {
        var self = SandPoint{ .p = undefined };
        for (self.p) |*p| {
            p.*.x = x + (16.0 * rand.float(f32) - 8.0);
            p.*.y = y + (16.0 * rand.float(f32) - 8.0);
        }
        return self;
    }
};

const SandShape = struct {
    points: ArrayList(SandPoint),

    fn init(allocator: *std.mem.Allocator) SandShape {
        return SandShape{
            .points = ArrayList(SandPoint).init(allocator),
        };
    }

    fn deinit(self: SandShape) void {
        self.points.deinit();
    }

    fn draw(self: SandShape) void {
        c.glBegin(c.GL_LINES);
        for (self.points.items) |point, point_index| {
            for (point.p) |p0, i| {
                const p1 = &self.points.items[(point_index + 1) % self.points.items.len].p[i];
                c.glVertex2f(p0.x, p0.y);
                c.glVertex2f(p1.x, p1.y);
            }
        }
        c.glEnd();
    }
};

pub fn setup(genexp: *GenerativeExperimentState) !void {
    const rand = &genexp.prng.random;

    try genexp.square.points.append(SandPoint.init(-100.0, -100.0, rand));
    try genexp.square.points.append(SandPoint.init(100.0, -100.0, rand));
    try genexp.square.points.append(SandPoint.init(100.0, 100.0, rand));
    try genexp.square.points.append(SandPoint.init(-100.0, 100.0, rand));

    try genexp.triangle.points.append(SandPoint.init(0.0, 100.0, rand));
    try genexp.triangle.points.append(SandPoint.init(-100.0, -100.0, rand));
    try genexp.triangle.points.append(SandPoint.init(100.0, -100.0, rand));

    c.glEnable(c.GL_BLEND);
    c.glBlendFunc(c.GL_SRC_ALPHA, c.GL_ONE_MINUS_SRC_ALPHA);
}

pub fn update(genexp: *GenerativeExperimentState, time: f64, dt: f32) void {
    c.glClearBufferfv(c.GL_COLOR, 0, &[4]f32{ 1.0, 1.0, 1.0, 1.0 });
    c.glColor4f(0.0, 0.0, 0.0, 0.5);

    c.glPushMatrix();
    c.glTranslatef(-300.0, 0.0, 0.0);
    genexp.square.draw();
    c.glPopMatrix();

    c.glPushMatrix();
    c.glTranslatef(300.0, 0.0, 0.0);
    genexp.triangle.draw();
    c.glPopMatrix();
}
