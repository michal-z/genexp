const std = @import("std");
const os = std.os;
const panic = std.debug.panic;
const assert = std.debug.assert;

pub const Enum = c_uint;
pub const Uint = c_uint;
pub const Int = c_int;
pub const Sizei = c_int;
pub const Float = f32;
pub const Double = f64;
pub const Char = u8;
pub const Boolean = u8;
pub const Bitfield = c_uint;
pub const Ubyte = u8;

pub const COLOR = 0x1800;
pub const COLOR_ATTACHMENT0 = 0x8CE0;
pub const PROJECTION = 0x1701;
pub const FRAMEBUFFER_SRGB = 0x8DB9;
pub const MULTISAMPLE = 0x809D;
pub const TEXTURE_2D_MULTISAMPLE = 0x9100;
pub const SRGB8_ALPHA8 = 0x8C43;
pub const TRUE = 1;
pub const FALSE = 0;
pub const DRAW_FRAMEBUFFER = 0x8CA9;
pub const COLOR_BUFFER_BIT = 0x00004000;
pub const NEAREST = 0x2600;
pub const LINEAR = 0x2601;
pub const BLEND = 0x0BE2;
pub const POINTS = 0x0000;
pub const LINES = 0x0001;
pub const LINE_LOOP = 0x0002;
pub const LINE_STRIP = 0x0003;
pub const TRIANGLES = 0x0004;
pub const TRIANGLE_STRIP = 0x0005;
pub const TRIANGLE_FAN = 0x0006;
pub const QUADS = 0x0007;
pub const QUAD_STRIP = 0x0008;
pub const POLYGON = 0x0009;
pub const ZERO = 0;
pub const ONE = 1;
pub const SRC_COLOR = 0x0300;
pub const ONE_MINUS_SRC_COLOR = 0x0301;
pub const SRC_ALPHA = 0x0302;
pub const ONE_MINUS_SRC_ALPHA = 0x0303;
pub const DST_ALPHA = 0x0304;
pub const ONE_MINUS_DST_ALPHA = 0x0305;
pub const DST_COLOR = 0x0306;
pub const ONE_MINUS_DST_COLOR = 0x0307;

var wCreateContext: fn (?os.windows.HDC) callconv(.Stdcall) ?os.windows.HGLRC = undefined;
var wDeleteContext: fn (?os.windows.HGLRC) callconv(.Stdcall) bool = undefined;
var wMakeCurrent: fn (?os.windows.HDC, ?os.windows.HGLRC) callconv(.Stdcall) bool = undefined;
var wGetProcAddress: fn (os.windows.LPCSTR) callconv(.Stdcall) ?os.windows.FARPROC = undefined;
var wSwapIntervalEXT: fn (i32) callconv(.Stdcall) bool = undefined;

pub var clearBufferfv: fn (Enum, Int, [*c]const Float) callconv(.Stdcall) void = undefined;
pub var matrixLoadIdentityEXT: fn (Enum) callconv(.Stdcall) void = undefined;
pub var matrixOrthoEXT: fn (Enum, Double, Double, Double, Double, Double, Double) callconv(.Stdcall) void = undefined;
pub var enable: fn (Enum) callconv(.Stdcall) void = undefined;
pub var textureStorage2DMultisample: fn (Uint, Sizei, Enum, Sizei, Sizei, Boolean) callconv(.Stdcall) void = undefined;
pub var createTextures: fn (Enum, Sizei, [*c]Uint) callconv(.Stdcall) void = undefined;
pub var deleteTextures: fn (Sizei, [*c]Uint) callconv(.Stdcall) void = undefined;
pub var createFramebuffers: fn (Sizei, [*c]Uint) callconv(.Stdcall) void = undefined;
pub var deleteFramebuffers: fn (Sizei, [*c]Uint) callconv(.Stdcall) void = undefined;
pub var namedFramebufferTexture: fn (Uint, Enum, Uint, Int) callconv(.Stdcall) void = undefined;
pub var blitNamedFramebuffer: fn (Uint, Uint, Int, Int, Int, Int, Int, Int, Int, Int, Bitfield, Enum) callconv(.Stdcall) void = undefined;
pub var bindFramebuffer: fn (Enum, Uint) callconv(.Stdcall) void = undefined;
pub var begin: fn (Enum) callconv(.Stdcall) void = undefined;
pub var end: fn () callconv(.Stdcall) void = undefined;
pub var getError: fn () callconv(.Stdcall) Enum = undefined;
pub var pointSize: fn (Float) callconv(.Stdcall) void = undefined;
pub var lineWidth: fn (Float) callconv(.Stdcall) void = undefined;
pub var blendFunc: fn (Enum, Enum) callconv(.Stdcall) void = undefined;
pub var vertex2f: fn (Float, Float) callconv(.Stdcall) void = undefined;
pub var vertex2i: fn (Int, Int) callconv(.Stdcall) void = undefined;
pub var color4f: fn (Float, Float, Float, Float) callconv(.Stdcall) void = undefined;
pub var color4ub: fn (Ubyte, Ubyte, Ubyte, Ubyte) callconv(.Stdcall) void = undefined;
pub var pushMatrix: fn () callconv(.Stdcall) void = undefined;
pub var popMatrix: fn () callconv(.Stdcall) void = undefined;
pub var rotatef: fn (Float, Float, Float, Float) callconv(.Stdcall) void = undefined;
pub var scalef: fn (Float, Float, Float) callconv(.Stdcall) void = undefined;
pub var translatef: fn (Float, Float, Float) callconv(.Stdcall) void = undefined;

var opengl32_dll: std.DynLib = undefined;
var opengl_context: ?os.windows.HGLRC = null;
var hdc: ?os.windows.HDC = null;

pub fn init(window: ?os.windows.HWND) void {
    assert(window != null and opengl_context == null);

    hdc = os.windows.user32.GetDC(window);

    var pfd = std.mem.zeroes(os.windows.gdi32.PIXELFORMATDESCRIPTOR);
    pfd.nSize = @sizeOf(os.windows.gdi32.PIXELFORMATDESCRIPTOR);
    pfd.nVersion = 1;
    pfd.dwFlags = os.windows.user32.PFD_SUPPORT_OPENGL +
        os.windows.user32.PFD_DOUBLEBUFFER +
        os.windows.user32.PFD_DRAW_TO_WINDOW;
    pfd.iPixelType = os.windows.user32.PFD_TYPE_RGBA;
    pfd.cColorBits = 32;
    pfd.cDepthBits = 24;
    pfd.cStencilBits = 8;
    const pixel_format = os.windows.gdi32.ChoosePixelFormat(hdc, &pfd);
    if (!os.windows.gdi32.SetPixelFormat(hdc, pixel_format, &pfd)) {
        panic("SetPixelFormat failed.", .{});
    }

    opengl32_dll = std.DynLib.open("/windows/system32/opengl32.dll") catch unreachable;
    wCreateContext = opengl32_dll.lookup(@TypeOf(wCreateContext), "wglCreateContext").?;
    wDeleteContext = opengl32_dll.lookup(@TypeOf(wDeleteContext), "wglDeleteContext").?;
    wMakeCurrent = opengl32_dll.lookup(@TypeOf(wMakeCurrent), "wglMakeCurrent").?;
    wGetProcAddress = opengl32_dll.lookup(@TypeOf(wGetProcAddress), "wglGetProcAddress").?;

    opengl_context = wCreateContext(hdc);
    if (!wMakeCurrent(hdc, opengl_context)) {
        panic("Failed to create OpenGL context.", .{});
    }

    wSwapIntervalEXT = getProcAddress(@TypeOf(wSwapIntervalEXT), "wglSwapIntervalEXT").?;
    _ = wSwapIntervalEXT(1);

    clearBufferfv = getProcAddress(@TypeOf(clearBufferfv), "glClearBufferfv").?;
    matrixLoadIdentityEXT = getProcAddress(@TypeOf(matrixLoadIdentityEXT), "glMatrixLoadIdentityEXT").?;
    matrixOrthoEXT = getProcAddress(@TypeOf(matrixOrthoEXT), "glMatrixOrthoEXT").?;
    enable = getProcAddress(@TypeOf(enable), "glEnable").?;
    textureStorage2DMultisample = getProcAddress(@TypeOf(textureStorage2DMultisample), "glTextureStorage2DMultisample").?;
    createTextures = getProcAddress(@TypeOf(createTextures), "glCreateTextures").?;
    deleteTextures = getProcAddress(@TypeOf(deleteTextures), "glDeleteTextures").?;
    createFramebuffers = getProcAddress(@TypeOf(createFramebuffers), "glCreateFramebuffers").?;
    deleteFramebuffers = getProcAddress(@TypeOf(deleteFramebuffers), "glDeleteFramebuffers").?;
    namedFramebufferTexture = getProcAddress(@TypeOf(namedFramebufferTexture), "glNamedFramebufferTexture").?;
    blitNamedFramebuffer = getProcAddress(@TypeOf(blitNamedFramebuffer), "glBlitNamedFramebuffer").?;
    bindFramebuffer = getProcAddress(@TypeOf(bindFramebuffer), "glBindFramebuffer").?;
    begin = getProcAddress(@TypeOf(begin), "glBegin").?;
    end = getProcAddress(@TypeOf(end), "glEnd").?;
    getError = getProcAddress(@TypeOf(getError), "glGetError").?;
    pointSize = getProcAddress(@TypeOf(pointSize), "glPointSize").?;
    lineWidth = getProcAddress(@TypeOf(lineWidth), "glLineWidth").?;
    blendFunc = getProcAddress(@TypeOf(blendFunc), "glBlendFunc").?;
    vertex2f = getProcAddress(@TypeOf(vertex2f), "glVertex2f").?;
    vertex2i = getProcAddress(@TypeOf(vertex2i), "glVertex2i").?;
    color4f = getProcAddress(@TypeOf(color4f), "glColor4f").?;
    color4ub = getProcAddress(@TypeOf(color4ub), "glColor4ub").?;
    pushMatrix = getProcAddress(@TypeOf(pushMatrix), "glPushMatrix").?;
    popMatrix = getProcAddress(@TypeOf(popMatrix), "glPopMatrix").?;
    rotatef = getProcAddress(@TypeOf(rotatef), "glRotatef").?;
    scalef = getProcAddress(@TypeOf(scalef), "glScalef").?;
    translatef = getProcAddress(@TypeOf(translatef), "glTranslatef").?;
}

pub fn deinit() void {
    assert(hdc != null and opengl_context != null);
    _ = wMakeCurrent(null, null);
    _ = wDeleteContext(opengl_context);
    opengl_context = null;
}

pub fn swapBuffers() void {
    assert(hdc != null and opengl_context != null);
    _ = os.windows.gdi32.SwapBuffers(hdc);
}

fn getProcAddress(comptime T: type, name: [:0]const u8) ?T {
    if (wGetProcAddress(name.ptr)) |addr| {
        return @ptrCast(T, addr);
    } else {
        return opengl32_dll.lookup(T, name);
    }
}
