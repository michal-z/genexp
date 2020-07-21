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
};
