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

pub const Vec2d = packed struct {
    x: f64,
    y: f64,

    pub fn dot(a: Vec2d, b: Vec2d) f64 {
        return a.x * b.x + a.y * b.y;
    }

    pub fn length(a: Vec2d) f64 {
        return math.sqrt(dot(a, a));
    }

    pub fn normalize(a: Vec2d) Vec2d {
        const f = 1.0 / a.length();
        return Vec2d{ .x = f * a.x, .y = f * a.y };
    }
};

pub const Color = packed struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8,
};
