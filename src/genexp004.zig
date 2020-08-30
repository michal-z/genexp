const std = @import("std");
const warn = std.debug.warn;
const math = std.math;
const gl = @import("opengl.zig");
usingnamespace @import("util.zig");

pub const window_name = "genexp004";
pub const window_width = 2 * 1024;
pub const window_height = 2 * 1024;

const bounds: f32 = 0.1;

pub const GenerativeExperimentState = struct {
    prng: std.rand.DefaultPrng,
    y: f32 = -bounds,
    fs_count_hits: u32 = 0,
    fs_draw_hits: u32 = 0,
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
        gl.deleteProgram(self.fs_count_hits);
        gl.deleteProgram(self.fs_draw_hits);
    }
};

pub fn setup(genexp: *GenerativeExperimentState) !void {
    gl.clearBufferfv(gl.COLOR, 0, &[4]f32{ 1.0, 1.0, 1.0, 1.0 });
    gl.pointSize(1.0);
    gl.matrixLoadIdentityEXT(gl.PROJECTION);
    gl.matrixOrthoEXT(gl.PROJECTION, -3.0, 3.0, -3.0, 3.0, -1.0, 1.0);

    gl.createBuffers(1, &genexp.buf_max_hits);
    gl.namedBufferStorage(genexp.buf_max_hits, 8, &[1]u32{0}, 0);

    gl.createTextures(gl.TEXTURE_2D, 1, &genexp.tex_hits);
    gl.textureStorage2D(genexp.tex_hits, 1, gl.R32UI, window_width, window_height);
    gl.clearTexImage(genexp.tex_hits, 0, gl.RED_INTEGER, gl.UNSIGNED_INT, null);

    genexp.fs_count_hits = gl.createShaderProgramv(gl.FRAGMENT_SHADER, 1, &@as([*c]const u8,
        \\  #version 460 compatibility
        \\  layout(binding = 0, r32ui) uniform uimage2D num_hits;
        \\  layout(binding = 0, offset = 0) uniform atomic_uint max_num_hits;
        \\
        \\  void main() {
        \\      uint num = imageAtomicAdd(num_hits, ivec2(gl_FragCoord.xy), 1);
        \\      atomicCounterMax(max_num_hits, num + 1);
        \\  }
    ));

    genexp.fs_draw_hits = gl.createShaderProgramv(gl.FRAGMENT_SHADER, 1, &@as([*c]const u8,
        \\  #version 460 compatibility
        \\  layout(binding = 0, r32ui) uniform uimage2D num_hits;
        \\  layout(binding = 0, offset = 0) uniform atomic_uint max_num_hits;
        \\
        \\  void main() {
        \\      float num = float(imageLoad(num_hits, ivec2(gl_FragCoord.xy)).r);
        \\      float max_num = float(atomicCounter(max_num_hits));
        \\      max_num = log(max_num + 1.0);
        \\      num = log(num + 1.0);
        \\      float c = 1.0 - num / max_num;
        \\      gl_FragColor = vec4(c, c, c, 1.0);
        \\  }
    ));
}

pub fn update(genexp: *GenerativeExperimentState, time: f64, dt: f32) void {
    gl.bindImageTexture(0, genexp.tex_hits, 0, gl.FALSE, 0, gl.READ_WRITE, gl.R32UI);
    gl.bindBufferBase(gl.ATOMIC_COUNTER_BUFFER, 0, genexp.buf_max_hits);

    if (genexp.y <= bounds) {
        gl.colorMask(gl.FALSE, gl.FALSE, gl.FALSE, gl.FALSE);
        gl.useProgram(genexp.fs_count_hits);

        gl.begin(gl.POINTS);
        const step: f32 = 0.00003;
        var row: u32 = 0;
        while (row < 4) : (row += 1) {
            var x: f32 = -bounds;
            while (x <= bounds) : (x += step) {
                var v = Vec2{ .x = x, .y = genexp.y };
                var i: u32 = 0;
                while (i < 8) : (i += 1) {
                    const v0 = hyperbolic(Vec2{ .x = v.x, .y = v.y }, 1.0);
                    const v1 = pdj(Vec2{ .x = v0.x, .y = v0.y }, 1.0);
                    const v2 = sinusoidal(Vec2{ .x = v1.x, .y = v1.y }, 2.0);
                    v = Vec2{ .x = (v0.x + v1.x) + v2.x, .y = (v0.y + v1.y) - v2.y };
                    v = julia(Vec2{ .x = v.x, .y = v.y }, 1.0, genexp.prng.random.float(f32));
                    gl.vertex2f(v.x, v.y);
                }
            }
            genexp.y += step;
        }
        gl.end();

        gl.colorMask(gl.TRUE, gl.TRUE, gl.TRUE, gl.TRUE);
        gl.memoryBarrier(gl.SHADER_IMAGE_ACCESS_BARRIER_BIT | gl.ATOMIC_COUNTER_BARRIER_BIT);
    }

    gl.useProgram(genexp.fs_draw_hits);
    gl.begin(gl.QUADS);
    gl.vertex2f(-3.0, -3.0);
    gl.vertex2f(3.0, -3.0);
    gl.vertex2f(3.0, 3.0);
    gl.vertex2f(-3.0, 3.0);
    gl.end();
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
