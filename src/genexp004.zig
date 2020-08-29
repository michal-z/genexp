const std = @import("std");
const warn = std.debug.warn;
const math = std.math;
const gl = @import("opengl.zig");
usingnamespace @import("util.zig");

pub const window_name = "genexp004";
pub const window_width = 2 * 1024;
pub const window_height = 2 * 1024;

pub const GenerativeExperimentState = struct {
    prng: std.rand.DefaultPrng,
    y: f32 = -3.0,
    fs_count_hits: u32 = 0,
    tex_hits: u32 = 0,
    buf_max_hits: u32 = 0,

    pub fn init() GenerativeExperimentState {
        return GenerativeExperimentState{
            .prng = std.rand.DefaultPrng.init(123),
        };
    }

    pub fn deinit(self: GenerativeExperimentState) void {
        gl.deleteBuffers(1, &self.buf_max_hits);
        gl.deleteTextures(1, &self.tex_hits);
    }
};

pub fn setup(genexp: *GenerativeExperimentState) !void {
    gl.clearBufferfv(gl.COLOR, 0, &[4]f32{ 1.0, 1.0, 1.0, 1.0 });
    gl.pointSize(1.0);
    gl.enable(gl.BLEND);
    gl.blendFunc(gl.ONE, gl.ONE);
    gl.blendEquation(gl.FUNC_REVERSE_SUBTRACT);
    gl.matrixLoadIdentityEXT(gl.PROJECTION);
    gl.matrixOrthoEXT(gl.PROJECTION, -3.0, 3.0, -3.0, 3.0, -1.0, 1.0);

    gl.createBuffers(1, &genexp.buf_max_hits);
    gl.namedBufferStorage(genexp.buf_max_hits, 4, &[1]u32{0}, 0);

    gl.createTextures(gl.TEXTURE_2D, 1, &genexp.tex_hits);
    gl.textureStorage2D(genexp.tex_hits, 1, gl.R32UI, window_width, window_height);
    gl.clearTexImage(genexp.tex_hits, 0, gl.RED_INTEGER, gl.UNSIGNED_INT, null);

    genexp.fs_count_hits = gl.createShaderProgramv(gl.FRAGMENT_SHADER, 1, &@as([*c]const u8,
        \\  #version 460 compatibility
        \\  layout(binding = 0, r32ui) uniform uimage2D hits;
        \\  layout(binding = 1) uniform atomic_uint max_hits;
        \\
        \\  void main() {
        \\      uint v = imageAtomicAdd(hits, ivec2(gl_FragCoord.xy), 1);
        \\      atomicCounterMax(max_hits, v + 1);
        \\  }
    ));
    gl.useProgram(genexp.fs_count_hits);
    gl.useProgram(0);
}

pub fn update(genexp: *GenerativeExperimentState, time: f64, dt: f32) void {
    if (genexp.y <= 3.0) {
        gl.begin(gl.POINTS);
        const step = 0.25 / @intToFloat(f32, window_width);
        var row: u32 = 0;
        while (row < 4) : (row += 1) {
            var x: f32 = -3.0;
            while (x <= 3.0) : (x += step) {
                var v = Vec2{ .x = x, .y = genexp.y };
                var i: u32 = 0;
                while (i < 1) : (i += 1) {
                    const xoff = genexp.prng.random.floatNorm(f32) * 0.005;
                    const yoff = genexp.prng.random.floatNorm(f32) * 0.005;
                    const v0 = hyperbolic(Vec2{ .x = v.x, .y = v.y }, 1.0);
                    const v1 = pdj(Vec2{ .x = v0.x, .y = v0.y }, 1.0);
                    const v2 = sinusoidal(Vec2{ .x = v1.x, .y = v1.y }, 2.0);
                    v = Vec2{ .x = (v0.x + v1.x) - v2.x, .y = (v0.y - v1.y) + v2.y };
                    v = julia(Vec2{ .x = v.x, .y = v.y }, 1.0, genexp.prng.random.float(f32));
                    v = sinusoidal(v, 2.8);
                    gl.color4f(0.0003, 0.0003, 0.0003, 1.0);
                    gl.vertex2f(v.x + xoff, v.y + yoff);
                }
            }
            genexp.y += step;
        }
        gl.end();
    }
}

fn sinusoidal(v: Vec2, scale: f32) Vec2 {
    return Vec2{ .x = scale * math.sin(v.x), .y = scale * math.sin(v.y) };
}

fn hyperbolic(v: Vec2, scale: f32) Vec2 {
    const r = v.length() + 0.0001;
    const theta = math.atan2(f32, v.x, v.y);
    const x = scale * math.sin(theta) / r;
    const y = scale * math.cos(theta) * r;
    return Vec2{ .x = x, .y = y };
}

fn pdj(v: Vec2, scale: f32) Vec2 {
    //const pdj_a = 0.1;
    //const pdj_b = 1.9;
    //const pdj_c = -0.8;
    //const pdj_d = -1.2;
    const pdj_a = 1.0111;
    const pdj_b = -1.011;
    const pdj_c = 2.08;
    const pdj_d = 10.2;
    return Vec2{
        .x = scale * (math.sin(pdj_a * v.y) - math.cos(pdj_b * v.x)),
        .y = scale * (math.sin(pdj_c * v.x) - math.cos(pdj_d * v.y)),
    };
}

fn julia(v: Vec2, scale: f32, rand01: f32) Vec2 {
    const r = scale * math.sqrt(v.length());
    const theta = 0.5 * math.atan2(f32, v.x, v.y) +
        math.pi * @intToFloat(f32, @floatToInt(i32, 2.0 * rand01));
    const x = r * math.cos(theta);
    const y = r * math.sin(theta);
    return Vec2{ .x = x, .y = y };
}
