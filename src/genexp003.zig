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

    pub fn init() GenerativeExperimentState {
        return GenerativeExperimentState{
            .prng = std.rand.DefaultPrng.init(0),
            .square = SandShape.init(default_allocator),
        };
    }

    pub fn deinit(self: GenerativeExperimentState) void {
        self.square.deinit();
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

    c.glEnable(c.GL_BLEND);
    c.glBlendFunc(c.GL_SRC_ALPHA, c.GL_ONE_MINUS_SRC_ALPHA);
}

pub fn update(genexp: *GenerativeExperimentState, time: f64, dt: f32) void {
    c.glClearBufferfv(c.GL_COLOR, 0, &[4]f32{ 1.0, 1.0, 1.0, 1.0 });
    c.glColor4f(0.0, 0.0, 0.0, 0.5);

    var x: f32 = -window_width * 0.5 + 200.0;
    var y: f32 = -window_height * 0.5 + 250.0;
    var angle: f32 = 0.0;

    while (y < window_height * 0.5) {
        while (x < window_width * 0.5) {
            c.glPushMatrix();
            c.glTranslatef(x, y, 0.0);
            c.glRotated(angle, 0.0, 0.0, 1.0);
            genexp.square.draw();
            c.glPopMatrix();
            x += 300.0;
            angle += 30.0;
        }
        x = -window_width * 0.5 + 200.0;
        y += 300.0;
    }
}
