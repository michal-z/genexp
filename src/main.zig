const builtin = @import("builtin");
const std = @import("std");
const panic = std.debug.panic;
const warn = std.debug.warn;
const assert = std.debug.assert;
const c = @import("c.zig");

fn errorCallback(err: c_int, description: [*c]const u8) callconv(.C) void {
    panic("Error: {}\n", .{@as([*:0]const u8, description)});
}

fn graphicsErrorCallback(source: c.GLenum, stype: c.GLenum, id: c.GLuint, severity: c.GLenum, length: c.GLsizei, message: [*c]const u8, param: ?*const c_void) callconv(.C) void {
    if (message != null) {
        warn("{}\n", .{@as([*:0]const u8, message)});
    }
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
    c.glClearColor(1.0, 1.0, 1.0, 1.0);
    c.glLineWidth(7.0);
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
        c.glBindFramebuffer(c.GL_DRAW_FRAMEBUFFER, fbo);
        c.glClear(c.GL_COLOR_BUFFER_BIT | c.GL_DEPTH_BUFFER_BIT | c.GL_STENCIL_BUFFER_BIT);

        c.glBegin(c.GL_LINES);
        c.glColor4f(0.0, 0.0, 0.0, 1.0);
        c.glVertex2f(0.0, 300.0);
        c.glColor4f(0.0, 0.0, 0.0, 0.0);
        c.glVertex2f(1920.0, 300.0);
        c.glEnd();

        c.glBindFramebuffer(c.GL_DRAW_FRAMEBUFFER, 0);

        c.glBlitNamedFramebuffer(fbo, 0, 0, 0, 1920, 1080, 0, 0, 1920, 1080, c.GL_COLOR_BUFFER_BIT, c.GL_NEAREST);
        c.glfwSwapBuffers(window);
        c.glfwPollEvents();
    }

    c.glDeleteFramebuffers(1, &fbo);
    c.glDeleteTextures(1, &fbo_texture);
}
