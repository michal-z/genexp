const std = @import("std");
const math = std.math;
const gl = @import("opengl.zig");
usingnamespace @import("util.zig");

pub const window_name = "genexp004";
pub const window_width = 1024;
pub const window_height = 1024;

pub const GenerativeExperimentState = struct {
    prng: std.rand.DefaultPrng,
    y: f32,

    pub fn init() GenerativeExperimentState {
        return GenerativeExperimentState{
            .prng = std.rand.DefaultPrng.init(123),
            .y = -3.0,
        };
    }

    pub fn deinit(self: GenerativeExperimentState) void {}
};

pub fn setup(genexp: *GenerativeExperimentState) !void {
    gl.clearBufferfv(gl.COLOR, 0, &[4]f32{ 1.0, 1.0, 1.0, 1.0 });
    gl.pointSize(1.0);
    gl.enable(gl.BLEND);
    gl.blendFunc(gl.ONE, gl.ONE);
    gl.blendEquation(gl.FUNC_REVERSE_SUBTRACT);
    gl.matrixLoadIdentityEXT(gl.PROJECTION);
    gl.matrixOrthoEXT(gl.PROJECTION, -3.0, 3.0, -3.0, 3.0, -1.0, 1.0);
}

pub fn update(genexp: *GenerativeExperimentState, time: f64, dt: f32) void {
    if (genexp.y <= 3.0) {
        gl.color4f(0.01, 0.01, 0.01, 1.0);
        gl.begin(gl.POINTS);
        const step = 1.5 / @intToFloat(f32, window_width);
        var i: u32 = 0;
        while (i < 4) : (i += 1) {
            var x: f32 = -3.0;
            while (x <= 3.0) : (x += step) {
                const xoff = genexp.prng.random.floatNorm(f32) * 0.005;
                const yoff = genexp.prng.random.floatNorm(f32) * 0.005;
                const v0 = hyperbolic(Vec2{ .x = x, .y = genexp.y }, 1.0);
                const v1 = pdj(Vec2{ .x = x, .y = genexp.y }, 1.0);
                const v2 = sinusoidal(Vec2{ .x = x, .y = genexp.y }, 2.0);
                const v = Vec2{ .x = (v0.x + v1.x) * v2.x, .y = (v0.y + v1.y) * v2.y };
                gl.vertex2f(v.x + xoff, v.y + yoff);
            }
            genexp.y += step;
        }
        gl.end();
    }
}

fn sinusoidal(v: Vec2, scale: f32) Vec2 {
    return Vec2{ .x = scale * math.cos(v.x), .y = scale * math.sin(-v.y) };
}

fn hyperbolic(v: Vec2, scale: f32) Vec2 {
    const r = v.length() + 0.00001;
    const theta = math.atan2(f32, v.x, v.y);
    const x = scale * math.sin(theta) / r;
    const y = scale * math.cos(theta) * r;
    return Vec2{ .x = x, .y = y };
}

fn pdj(v: Vec2, scale: f32) Vec2 {
    const pdj_a = 0.1;
    //const pdj_b = 1.9;
    //const pdj_c = -0.8;
    const pdj_d = -1.2;
    //const pdj_a = 1.0111;
    const pdj_b = -1.011;
    const pdj_c = 2.08;
    //const pdj_d = 10.2;
    return Vec2{
        .x = scale * (math.sin(pdj_a * v.y) - math.cos(pdj_b * v.x)),
        .y = scale * (math.sin(pdj_c * v.x) - math.cos(pdj_d * v.y)),
    };
}
