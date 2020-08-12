const std = @import("std");
const panic = std.debug.panic;
const assert = std.debug.assert;
const os = std.os;
const gl = @import("opengl.zig");
const d3d12 = @import("d3d12.zig");
const genexp = @import("genexp003.zig");

fn updateFrameStats(window: os.windows.HWND, name: [*:0]const u8) struct { time: f64, delta_time: f32 } {
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

        _ = SetWindowTextA(window, @ptrCast(os.windows.LPCSTR, header.ptr));

        state.header_refresh_time_ns = now_ns;
        state.frame_count = 0;
    }
    state.frame_count += 1;

    return .{ .time = time, .delta_time = delta_time };
}

const WS_VISIBLE = 0x10000000;
const VK_ESCAPE = 0x001B;

const RECT = extern struct {
    left: os.windows.LONG,
    top: os.windows.LONG,
    right: os.windows.LONG,
    bottom: os.windows.LONG,
};

extern "kernel32" fn AdjustWindowRect(
    lpRect: ?*RECT,
    dwStyle: os.windows.DWORD,
    bMenu: bool,
) callconv(.Stdcall) bool;

extern "user32" fn SetProcessDPIAware() callconv(.Stdcall) bool;

extern "user32" fn SetWindowTextA(
    hWnd: os.windows.HWND,
    lpString: os.windows.LPCSTR,
) callconv(.Stdcall) bool;

fn processWindowMessage(
    window: os.windows.HWND,
    message: os.windows.UINT,
    wparam: os.windows.WPARAM,
    lparam: os.windows.LPARAM,
) callconv(.Stdcall) os.windows.LRESULT {
    const processed = switch (message) {
        os.windows.user32.WM_DESTROY => blk: {
            os.windows.user32.PostQuitMessage(0);
            break :blk true;
        },
        os.windows.user32.WM_KEYDOWN => blk: {
            if (wparam == VK_ESCAPE) {
                os.windows.user32.PostQuitMessage(0);
                break :blk true;
            }
            break :blk false;
        },
        else => false,
    };
    return if (processed) null else os.windows.user32.DefWindowProcA(window, message, wparam, lparam);
}

pub fn main() !void {
    _ = SetProcessDPIAware();

    var u: *d3d12.Blob = undefined;
    _ = u.AddRef();

    const winclass = os.windows.user32.WNDCLASSEXA{
        .style = 0,
        .lpfnWndProc = processWindowMessage,
        .cbClsExtra = 0,
        .cbWndExtra = 0,
        .hInstance = @ptrCast(os.windows.HINSTANCE, os.windows.kernel32.GetModuleHandleA(null)),
        .hIcon = null,
        .hCursor = null,
        .hbrBackground = null,
        .lpszMenuName = null,
        .lpszClassName = "genexp",
        .hIconSm = null,
    };
    _ = os.windows.user32.RegisterClassExA(&winclass);

    const style = os.windows.user32.WS_OVERLAPPED +
        os.windows.user32.WS_SYSMENU +
        os.windows.user32.WS_CAPTION +
        os.windows.user32.WS_MINIMIZEBOX;

    var rect = RECT{ .left = 0, .top = 0, .right = 1920, .bottom = 1080 };
    _ = AdjustWindowRect(&rect, style, false);

    const window = os.windows.user32.CreateWindowExA(
        0,
        "genexp",
        "genexp",
        style + WS_VISIBLE,
        -1,
        -1,
        rect.right - rect.left,
        rect.bottom - rect.top,
        null,
        null,
        winclass.hInstance,
        null,
    );
    gl.init(window);
    gl.matrixLoadIdentityEXT(gl.PROJECTION);
    gl.matrixOrthoEXT(
        gl.PROJECTION,
        -genexp.window_width * 0.5,
        genexp.window_width * 0.5,
        -genexp.window_height * 0.5,
        genexp.window_height * 0.5,
        -1.0,
        1.0,
    );
    gl.enable(gl.FRAMEBUFFER_SRGB);
    gl.enable(gl.MULTISAMPLE);

    var fbo_texture: gl.Uint = undefined;
    gl.createTextures(gl.TEXTURE_2D_MULTISAMPLE, 1, &fbo_texture);
    gl.textureStorage2DMultisample(
        fbo_texture,
        8,
        gl.SRGB8_ALPHA8,
        genexp.window_width,
        genexp.window_height,
        gl.FALSE,
    );

    var fbo: gl.Uint = undefined;
    gl.createFramebuffers(1, &fbo);
    gl.namedFramebufferTexture(fbo, gl.COLOR_ATTACHMENT0, fbo_texture, 0);
    gl.bindFramebuffer(gl.DRAW_FRAMEBUFFER, fbo);
    gl.clearBufferfv(gl.COLOR, 0, &[4]f32{ 0.0, 0.0, 0.0, 0.0 });

    var genexp_state = genexp.GenerativeExperimentState.init();
    try genexp.setup(&genexp_state);

    gl.bindFramebuffer(gl.DRAW_FRAMEBUFFER, 0);

    while (true) {
        var message = std.mem.zeroes(os.windows.user32.MSG);
        if (os.windows.user32.PeekMessageA(&message, null, 0, 0, os.windows.user32.PM_REMOVE)) {
            _ = os.windows.user32.DispatchMessageA(&message);
            if (message.message == os.windows.user32.WM_QUIT)
                break;
        } else {
            gl.bindFramebuffer(gl.DRAW_FRAMEBUFFER, fbo);

            const stats = updateFrameStats(window.?, genexp.window_name);
            genexp.update(&genexp_state, stats.time, stats.delta_time);

            gl.bindFramebuffer(gl.DRAW_FRAMEBUFFER, 0);
            gl.blitNamedFramebuffer(
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
                gl.COLOR_BUFFER_BIT,
                gl.NEAREST,
            );
            gl.swapBuffers();

            if (gl.getError() != 0) {
                panic("OpenGL error detected.", .{});
            }
        }
    }

    genexp_state.deinit();
    gl.deleteTextures(1, &fbo_texture);
    gl.deleteFramebuffers(1, &fbo);
    gl.deinit();
}
