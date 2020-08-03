const builtin = @import("builtin");
const std = @import("std");
const panic = std.debug.panic;
const warn = std.debug.warn;
const assert = std.debug.assert;
const c = @import("c.zig");
const genexp = @import("genexp003.zig");

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

pub fn main() !void {
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
        genexp.window_width,
        genexp.window_height,
        genexp.window_name,
        null,
        null,
    ) orelse {
        panic("Failed to create window.\n", .{});
    };
    defer c.glfwDestroyWindow(window);

    c.glfwMakeContextCurrent(window);
    c.glfwSwapInterval(1);
    c.loadGraphicsEntryPoints();

    if (comptime builtin.mode == builtin.Mode.Debug) {
        c.glDebugMessageCallback(graphicsErrorCallback, null);
        c.glEnable(c.GL_DEBUG_OUTPUT);
    }

    c.glMatrixLoadIdentityEXT(c.GL_PROJECTION);
    c.glMatrixOrthoEXT(
        c.GL_PROJECTION,
        -genexp.window_width * 0.5,
        genexp.window_width * 0.5,
        -genexp.window_height * 0.5,
        genexp.window_height * 0.5,
        -1.0,
        1.0,
    );
    c.glEnable(c.GL_FRAMEBUFFER_SRGB);
    c.glEnable(c.GL_MULTISAMPLE);

    var fbo_texture: c.GLuint = undefined;
    c.glCreateTextures(c.GL_TEXTURE_2D_MULTISAMPLE, 1, &fbo_texture);
    c.glTextureStorage2DMultisample(
        fbo_texture,
        8,
        c.GL_SRGB8_ALPHA8,
        genexp.window_width,
        genexp.window_height,
        c.GL_FALSE,
    );

    var fbo: c.GLuint = undefined;
    c.glCreateFramebuffers(1, &fbo);
    c.glNamedFramebufferTexture(fbo, c.GL_COLOR_ATTACHMENT0, fbo_texture, 0);
    c.glBindFramebuffer(c.GL_DRAW_FRAMEBUFFER, fbo);
    c.glClearBufferfv(c.GL_COLOR, 0, &[4]f32{ 0.0, 0.0, 0.0, 0.0 });

    var genexp_state = genexp.GenerativeExperimentState.init();
    try genexp.setup(&genexp_state);

    c.glBindFramebuffer(c.GL_DRAW_FRAMEBUFFER, 0);

    while (c.glfwWindowShouldClose(window) == c.GLFW_FALSE) {
        c.glBindFramebuffer(c.GL_DRAW_FRAMEBUFFER, fbo);

        const stats = updateFrameStats(window, genexp.window_name);
        genexp.update(&genexp_state, stats.time, stats.delta_time);

        c.glBindFramebuffer(c.GL_DRAW_FRAMEBUFFER, 0);
        c.glBlitNamedFramebuffer(
            fbo,
            0,
            0,
            0,
            genexp.window_width,
            genexp.window_height,
            0,
            0,
            genexp.window_width,
            genexp.window_height,
            c.GL_COLOR_BUFFER_BIT,
            c.GL_NEAREST,
        );
        c.glfwSwapBuffers(window);
        c.glfwPollEvents();
    }

    genexp_state.deinit();
    c.glDeleteFramebuffers(1, &fbo);
    c.glDeleteTextures(1, &fbo_texture);
}
