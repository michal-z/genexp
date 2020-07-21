const builtin = @import("builtin");
const std = @import("std");
const c = @import("c.zig");
const math = std.math;
usingnamespace @import("util.zig");

pub const window_name = "genexp001";
pub const window_width = 1920;
pub const window_height = 1080;

pub const DemoState = struct {
    prng: std.rand.DefaultPrng = undefined,
    data: std.ArrayList(Vec2) = undefined,
    position: Vec2 = .{ .x = 0.0, .y = 0.0 },
};

pub fn init(demo: *DemoState) !void {
    demo.prng = std.rand.DefaultPrng.init(0);

    c.glLineWidth(3.0);
    c.glPointSize(7.0);
    c.glEnable(c.GL_BLEND);
    c.glBlendFunc(c.GL_SRC_ALPHA, c.GL_ONE_MINUS_SRC_ALPHA);

    demo.data = try @TypeOf(demo.data).initCapacity(std.heap.page_allocator, 1024);
    try demo.data.append(Vec2{ .x = 100.0, .y = 100.0 });
    try demo.data.append(Vec2{ .x = 0.0, .y = 0.0 });
}

pub fn update(demo: *DemoState, time: f64, dt: f32) void {
    //c.glClearBufferfv(c.GL_COLOR, 0, &[4]f32{ 1.0, 1.0, 1.0, 1.0 });
    const r = demo.prng.random.int(u3);
    switch (r) {
        0 => demo.position.x += 10.0,
        1 => demo.position.x -= 10.0,
        2 => demo.position.y += 10.0,
        3 => demo.position.y -= 10.0,
        4 => {
            demo.position.x += 10.0;
            demo.position.y += 10.0;
        },
        5 => {
            demo.position.x += 10.0;
            demo.position.y -= 10.0;
        },
        6 => {
            demo.position.x -= 10.0;
            demo.position.y -= 10.0;
        },
        7 => {
            demo.position.x -= 10.0;
            demo.position.y += 10.0;
        },
    }

    if (demo.position.x < -window_width * 0.5 or
        demo.position.x > window_width * 0.5 or
        demo.position.y < -window_height * 0.5 or
        demo.position.y > window_height * 0.5)
    {
        demo.position.x = 0.0;
        demo.position.y = 0.0;
    }

    c.glColor4f(0.0, 0.5, 0.0, 1.0);
    c.glBegin(c.GL_POINTS);
    c.glVertex2f(demo.position.x, demo.position.y);
    c.glEnd();
    //c.glColor4f(0.0, 0.0, 0.0, 1.0);
    //c.glEnableClientState(c.GL_VERTEX_ARRAY);
    //c.glVertexPointer(2, c.GL_FLOAT, 0, demo.data.items.ptr);
    //c.glDrawArrays(c.GL_POINTS, 0, @intCast(c_int, demo.data.items.len));
    //c.glDisableClientState(c.GL_VERTEX_ARRAY);
}

pub fn deinit(demo: *DemoState) void {}
