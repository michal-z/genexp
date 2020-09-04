const std = @import("std");
const warn = std.debug.warn;
const math = std.math;
const gl = @import("opengl.zig");
usingnamespace @import("util.zig");

pub const window_name = "genexp004";
pub const window_width = 2 * 1024;
pub const window_height = 2 * 1024;

const bounds: f64 = 3.0;

pub const GenerativeExperimentState = struct {
    prng: std.rand.DefaultPrng,
    pass: u32 = 0,
    y: f64 = -bounds,
    fs_postprocess: u32 = 0,
    tex_fp32: u32 = 0,
    fbo_fp32: u32 = 0,
    fbo_srgb: u32 = 0,

    pub fn init() GenerativeExperimentState {
        return GenerativeExperimentState{
            .prng = std.rand.DefaultPrng.init(123),
        };
    }

    pub fn deinit(self: GenerativeExperimentState) void {
        gl.deleteTextures(1, &self.tex_fp32);
        gl.deleteProgram(self.fs_postprocess);
    }
};

pub fn setup(genexp: *GenerativeExperimentState) !void {
    gl.getIntegerv(gl.DRAW_FRAMEBUFFER_BINDING, @ptrCast([*c]c_int, &genexp.fbo_srgb));

    gl.clearBufferfv(gl.COLOR, 0, &[_]f32{ 1.0, 1.0, 1.0, 1.0 });
    gl.pointSize(3.0);
    gl.blendFunc(gl.ONE, gl.ONE);
    gl.blendEquation(gl.FUNC_ADD);
    gl.matrixLoadIdentityEXT(gl.PROJECTION);
    gl.matrixOrthoEXT(gl.PROJECTION, -3.0, 3.0, -3.0, 3.0, -1.0, 1.0);

    gl.createTextures(gl.TEXTURE_RECTANGLE, 1, &genexp.tex_fp32);
    gl.textureStorage2D(genexp.tex_fp32, 1, gl.RGBA32F, window_width, window_height);
    gl.clearTexImage(genexp.tex_fp32, 0, gl.RGBA, gl.FLOAT, null);

    gl.createFramebuffers(1, &genexp.fbo_fp32);
    gl.namedFramebufferTexture(genexp.fbo_fp32, gl.COLOR_ATTACHMENT0, genexp.tex_fp32, 0);

    genexp.fs_postprocess = gl.createShaderProgramv(gl.FRAGMENT_SHADER, 1, &@as([*c]const u8,
        \\  #version 460 compatibility
        \\  layout(binding = 0) uniform sampler2DRect tex_fp32;
        \\
        \\  void main() {
        \\      vec3 color = texture(tex_fp32, gl_FragCoord.xy).rgb;
        \\      color = color / (color + 1.0);
        \\      color = 1.0 - color;
        \\      color = pow(color, vec3(2.2));
        \\      gl_FragColor = vec4(color, 1.0);
        \\  }
    ));
}

pub fn update(genexp: *GenerativeExperimentState, time: f64, dt: f32) void {
    gl.enable(gl.BLEND);
    gl.bindFramebuffer(gl.DRAW_FRAMEBUFFER, genexp.fbo_fp32);
    gl.useProgram(0);

    if (genexp.y <= bounds and genexp.pass == 0) {
        gl.begin(gl.POINTS);
        const step: f64 = 0.001;
        var row: u32 = 0;
        while (row < 16) : (row += 1) {
            var x: f64 = -bounds;
            while (x <= bounds) : (x += step) {
                const xoff = genexp.prng.random.floatNorm(f64) * 0.002;
                const yoff = genexp.prng.random.floatNorm(f64) * 0.002;
                gl.color4f(0.002, 0.002, 0.002, 1.0);
                gl.vertex2d(x + xoff, genexp.y + yoff);
            }
            genexp.y += step;
        }
        gl.end();
    } else if (genexp.y <= bounds and genexp.pass == 1) {
        gl.begin(gl.POINTS);
        const step: f64 = 0.001;
        var row: u32 = 0;
        while (row < 4) : (row += 1) {
            var x: f64 = -bounds;
            while (x <= bounds) : (x += step) {
                var v = Vec2d{ .x = x, .y = genexp.y };
                var i: u32 = 0;
                while (i < 4) : (i += 1) {
                    const xoff = genexp.prng.random.floatNorm(f64) * 0.01;
                    const yoff = genexp.prng.random.floatNorm(f64) * 0.01;
                    v = pdj(v, 1.0);
                    v = julia(v, 1.5, genexp.prng.random.float(f64));
                    v = hyperbolic(v, 1.0);
                    v = sinusoidal(v, 2.0);
                    gl.color4f(0.001, 0.001, 0.001, 1.0);
                    gl.vertex2d(v.x + xoff, v.y + yoff);
                }
            }
            genexp.y += step;
        }
        gl.end();
    }

    if (genexp.y >= bounds) {
        genexp.y = -bounds;
        genexp.pass += 1;
    }

    gl.bindFramebuffer(gl.DRAW_FRAMEBUFFER, genexp.fbo_srgb);
    gl.bindTextureUnit(0, genexp.tex_fp32);
    gl.disable(gl.BLEND);
    gl.useProgram(genexp.fs_postprocess);
    gl.begin(gl.QUADS);
    gl.vertex2f(-3.0, -3.0);
    gl.vertex2f(3.0, -3.0);
    gl.vertex2f(3.0, 3.0);
    gl.vertex2f(-3.0, 3.0);
    gl.end();
}

fn sinusoidal(v: Vec2d, scale: f64) Vec2d {
    return Vec2d{ .x = scale * math.sin(v.x), .y = scale * math.sin(v.y) };
}

fn hyperbolic(v: Vec2d, scale: f64) Vec2d {
    const r = v.length() + 0.0001;
    const theta = math.atan2(f64, v.x, v.y);
    const x = scale * math.sin(theta) / r;
    const y = scale * math.cos(theta) * r;
    return Vec2d{ .x = x, .y = y };
}

fn pdj(v: Vec2d, scale: f64) Vec2d {
    const pdj_a = 0.1;
    const pdj_b = 1.9;
    const pdj_c = -0.8;
    const pdj_d = -1.2;
    //const pdj_a = 1.0111;
    //const pdj_b = -1.011;
    //const pdj_c = 2.08;
    //const pdj_d = 10.2;
    return Vec2d{
        .x = scale * (math.sin(pdj_a * v.y) - math.cos(pdj_b * v.x)),
        .y = scale * (math.sin(pdj_c * v.x) - math.cos(pdj_d * v.y)),
    };
}

fn julia(v: Vec2d, scale: f64, rand01: f64) Vec2d {
    const r = scale * math.sqrt(v.length());
    const theta = 0.5 * math.atan2(f64, v.x, v.y) +
        math.pi * @intToFloat(f64, @floatToInt(i32, 2.0 * rand01));
    const x = r * math.cos(theta);
    const y = r * math.sin(theta);
    return Vec2d{ .x = x, .y = y };
}
