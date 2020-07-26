const std = @import("std");
const math = std.math;

pub const Vec2 = packed struct {
    x: f32,
    y: f32,

    pub fn dot(a: Vec2, b: Vec2) f32 {
        return a.x * b.x + a.y * b.y;
    }

    pub fn length(a: Vec2) f32 {
        return math.sqrt(dot(a, a));
    }

    pub fn normalize(a: Vec2) Vec2 {
        const f = 1.0 / a.length();
        return Vec2{ .x = f * a.x, .y = f * a.y };
    }
};
