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
    gl.clearBufferfv(gl.COLOR, 0, &[4]f32{ 0.0, 0.0, 0.0, 0.0 });
    gl.pointSize(1.0);
    gl.enable(gl.BLEND);
    gl.blendFunc(gl.ONE, gl.ONE);
    gl.matrixLoadIdentityEXT(gl.PROJECTION);
    gl.matrixOrthoEXT(gl.PROJECTION, -3.0, 3.0, -3.0, 3.0, -1.0, 1.0);
}

pub fn update(genexp: *GenerativeExperimentState, time: f64, dt: f32) void {
    if (genexp.y <= 3.0) {
        gl.color4f(0.01, 0.01, 0.01, 1.0);
        gl.begin(gl.POINTS);
        const step = 1.5 / @intToFloat(f32, window_width);
        var i: u32 = 0;
        while (i < 20) : (i += 1) {
            var x: f32 = -3.0;
            while (x <= 3.0) : (x += step) {
                const xoff = genexp.prng.random.floatNorm(f32) * 0.005;
                const yoff = genexp.prng.random.floatNorm(f32) * 0.005;
                gl.vertex2f(3.0 * math.sin(x) + xoff, 3.0 * math.sin(genexp.y) + yoff);
            }
            genexp.y += step;
        }
        gl.end();
    }
}
