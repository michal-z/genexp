const builtin = @import("builtin");
const std = @import("std");
const math = std.math;
const panic = std.debug.panic;
const warn = std.debug.warn;
const assert = std.debug.assert;
const c = @import("c.zig");

const window_width = 1920;
const window_height = 1080;

fn errorCallback(err: c_int, description: [*c]const u8) callconv(.C) void {
    panic("Error: {}\n", .{@as([*:0]const u8, description)});
}

fn graphicsErrorCallback(
    source: c.GLenum,
    stype: c.GLenum,
    id: c.GLuint,
    severity: c.GLenum,
    length: c.GLsizei,
    message: [*c]const u8,
    param: ?*const c_void,
) callconv(.C) void {
    if (message != null) {
        warn("{}\n", .{@as([*:0]const u8, message)});
    }
}

const Vec3 = struct {
    x: f32,
    y: f32,
    z: f32,

    fn add(a: Vec3, b: Vec3) Vec3 {
        return Vec3{
            .x = a.x + b.x,
            .y = a.y + b.y,
            .z = a.z + b.z,
        };
    }

    fn dot(a: Vec3, b: Vec3) f32 {
        return a.x * b.x + a.y * b.y + a.z * b.z;
    }

    fn length(a: Vec3) f32 {
        return math.sqrt(dot(a, a));
    }
};

test "vec3" {
    var v0 = Vec3{
        .x = 1.0,
        .y = 2.0,
        .z = 3.0,
    };
    var v1 = Vec3{
        .x = 4.0,
        .y = 5.0,
        .z = 6.0,
    };
    v0 = v0.add(v1);
    assert(v0.x == 5.0);
    _ = v1.length();
}

fn updateFrameStats(window: *c.GLFWwindow, name: [*:0]const u8) struct { time: f64, delta_time: f32 } {
    const state = struct {
        var timer: std.time.Timer = undefined;
        var previous_time_ns: u64 = 0;
        var header_refresh_time_ns: u64 = 0;
        var frame_count: u64 = ~@as(u64, 0);
    };

    if (state.frame_count == ~@as(u64, 0)) {
        state.timer = std.time.Timer.start() catch unreachable;
        state.previous_time_ns = 0;
        state.header_refresh_time_ns = 0;
        state.frame_count = 0;
    }

    const now_ns = state.timer.read();
    const time = @intToFloat(f64, now_ns) / std.time.ns_per_s;
    const delta_time = @intToFloat(f32, now_ns - state.previous_time_ns) / std.time.ns_per_s;
    state.previous_time_ns = now_ns;

    if ((now_ns - state.header_refresh_time_ns) >= std.time.ns_per_s) {
        const t = @intToFloat(f64, now_ns - state.header_refresh_time_ns) / std.time.ns_per_s;
        const fps = @intToFloat(f64, state.frame_count) / t;
        const ms = (1.0 / fps) * 1000.0;

        var buffer = [_]u8{0} ** 128;
        const buffer_slice = buffer[0 .. buffer.len - 1];
        const header = std.fmt.bufPrint(
            buffer_slice,
            "[{d:.1} fps  {d:.3} ms] {}",
            .{ fps, ms, name },
        ) catch buffer_slice;

        c.glfwSetWindowTitle(window, header.ptr);

        state.header_refresh_time_ns = now_ns;
        state.frame_count = 0;
    }
    state.frame_count += 1;

    return .{ .time = time, .delta_time = delta_time };
}

pub fn main() void {
    _ = c.glfwSetErrorCallback(errorCallback);
    if (c.glfwInit() == c.GLFW_FALSE) {
        panic("Failed to init GLFW.\n", .{});
    }
    defer c.glfwTerminate();

    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 4);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 6);
    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_COMPAT_PROFILE);
    if (comptime builtin.mode == builtin.Mode.Debug) {
        c.glfwWindowHint(c.GLFW_OPENGL_DEBUG_CONTEXT, c.GLFW_TRUE);
    }
    c.glfwWindowHint(c.GLFW_DEPTH_BITS, 24);
    c.glfwWindowHint(c.GLFW_STENCIL_BITS, 8);
    c.glfwWindowHint(c.GLFW_RESIZABLE, c.GLFW_FALSE);

    const window: *c.GLFWwindow = c.glfwCreateWindow(
        window_width,
        window_height,
        "genexp",
        null,
        null,
    ) orelse {
        panic("Failed to create window.\n", .{});
    };
    defer c.glfwDestroyWindow(window);

    c.glfwMakeContextCurrent(window);
    c.glfwSwapInterval(0);
    c.loadGraphicsEntryPoints();

    if (comptime builtin.mode == builtin.Mode.Debug) {
        c.glDebugMessageCallback(graphicsErrorCallback, null);
        c.glEnable(c.GL_DEBUG_OUTPUT);
    }

    c.glMatrixLoadIdentityEXT(c.GL_PROJECTION);
    c.glMatrixOrthoEXT(
        c.GL_PROJECTION,
        -window_width * 0.5,
        window_width * 0.5,
        -window_height * 0.5,
        window_height * 0.5,
        -1.0,
        1.0,
    );
    c.glLineWidth(3.0);
    c.glPointSize(5.0);
    c.glEnable(c.GL_FRAMEBUFFER_SRGB);
    c.glEnable(c.GL_BLEND);
    c.glBlendFunc(c.GL_SRC_ALPHA, c.GL_ONE_MINUS_SRC_ALPHA);

    var fbo_texture: c.GLuint = undefined;
    c.glCreateTextures(c.GL_TEXTURE_2D_MULTISAMPLE, 1, &fbo_texture);
    c.glTextureStorage2DMultisample(fbo_texture, 8, c.GL_SRGB8_ALPHA8, 1920, 1080, c.GL_FALSE);

    var fbo: c.GLuint = undefined;
    c.glCreateFramebuffers(1, &fbo);
    c.glNamedFramebufferTexture(fbo, c.GL_COLOR_ATTACHMENT0, fbo_texture, 0);

    while (c.glfwWindowShouldClose(window) == c.GLFW_FALSE) {
        const stats = updateFrameStats(window, "genexp");

        c.glBindFramebuffer(c.GL_DRAW_FRAMEBUFFER, fbo);
        c.glClearBufferfv(c.GL_COLOR, 0, &[4]f32{ 1.0, 1.0, 1.0, 1.0 });

        c.glColor4f(0.0, 0.0, 0.0, 1.0);
        c.glBegin(c.GL_LINE_LOOP);

        var phi: f32 = 0.0;
        while (phi < 2.0 * math.pi) {
            const x = 300.0 * math.cos(phi);
            const y = 300.0 * math.sin(phi);
            c.glVertex2f(x, y);
            phi += (2.0 * math.pi) / 16.0;
        }
        c.glEnd();

        c.glBindFramebuffer(c.GL_DRAW_FRAMEBUFFER, 0);
        c.glBlitNamedFramebuffer(
            fbo,
            0,
            0,
            0,
            window_width,
            window_height,
            0,
            0,
            window_width,
            window_height,
            c.GL_COLOR_BUFFER_BIT,
            c.GL_NEAREST,
        );
        c.glfwSwapBuffers(window);
        c.glfwPollEvents();
    }

    c.glDeleteFramebuffers(1, &fbo);
    c.glDeleteTextures(1, &fbo_texture);
}
