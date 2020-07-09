const builtin = @import("builtin");
const std = @import("std");
const panic = std.debug.panic;
const warn = std.debug.warn;
const assert = std.debug.assert;
const c = @import("c.zig");

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

fn returnData() struct { time: f64, delta_time: f32 } {
    var time: f64 = 1.0;
    var delta_time: f32 = 2.0;
    return .{ .time = time, .delta_time = delta_time };
}

const Vec3 = struct {
    x: f32,
    y: f32,
    z: f32,

    pub fn add(self: *Vec3, other: Vec3) Vec3 {
        self.x += other.x;
        self.y += other.y;
        self.z += other.z;
        return self.*;
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
    const v3 = v0.add(v1).add(v1);
    const r = returnData();
    //assert(v0.x == 9.0 and v3.x == 9.0);
    assert(r.time == 1.0 and r.delta_time == 2.0);
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

pub fn main() anyerror!void {
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

    const window: *c.GLFWwindow = c.glfwCreateWindow(1920, 1080, "genexp", null, null) orelse {
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
    c.glMatrixOrthoEXT(c.GL_PROJECTION, 0.0, 1920.0, 0.0, 1080.0, -1.0, 1.0);
    c.glLineWidth(3.0);
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
        c.glBegin(c.GL_LINE_STRIP);

        var x: f32 = 100.0;
        var y: f32 = 300.0;
        while (x <= 1200.0) {
            c.glVertex2f(x, if (y > 0.0) 300.0 else 100.0);
            y = -y;
            x += 25.0;
        }
        c.glEnd();

        c.glBindFramebuffer(c.GL_DRAW_FRAMEBUFFER, 0);

        c.glBlitNamedFramebuffer(fbo, 0, 0, 0, 1920, 1080, 0, 0, 1920, 1080, c.GL_COLOR_BUFFER_BIT, c.GL_NEAREST);
        c.glfwSwapBuffers(window);
        c.glfwPollEvents();
    }

    c.glDeleteFramebuffers(1, &fbo);
    c.glDeleteTextures(1, &fbo_texture);
}
