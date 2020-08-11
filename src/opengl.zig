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

const WCreateContext = fn (?os.windows.HDC) callconv(.Stdcall) ?os.windows.HGLRC;
const WMakeCurrent = fn (?os.windows.HDC, ?os.windows.HGLRC) callconv(.Stdcall) bool;
const WDeleteContext = fn (?os.windows.HGLRC) callconv(.Stdcall) bool;
const WGetProcAddress = fn (os.windows.LPCSTR) callconv(.Stdcall) ?os.windows.FARPROC;
const WSwapIntervalEXT = fn (i32) callconv(.Stdcall) bool;

var wCreateContext: WCreateContext = undefined;
var wDeleteContext: WDeleteContext = undefined;
var wMakeCurrent: WMakeCurrent = undefined;
var wGetProcAddress: WGetProcAddress = undefined;
var wSwapIntervalEXT: WSwapIntervalEXT = undefined;

const ClearBufferfv = fn (Enum, Int, [*c]const Float) callconv(.Stdcall) void;
const MatrixLoadIdentityEXT = fn (Enum) callconv(.Stdcall) void;
const MatrixOrthoEXT = fn (Enum, Double, Double, Double, Double, Double, Double) callconv(.Stdcall) void;
const Enable = fn (Enum) callconv(.Stdcall) void;
const TextureStorage2DMultisample = fn (Uint, Sizei, Enum, Sizei, Sizei, Boolean) callconv(.Stdcall) void;
const CreateTextures = fn (Enum, Sizei, [*c]Uint) callconv(.Stdcall) void;
const DeleteTextures = fn (Sizei, [*c]Uint) callconv(.Stdcall) void;
const CreateFramebuffers = fn (Sizei, [*c]Uint) callconv(.Stdcall) void;
const DeleteFramebuffers = fn (Sizei, [*c]Uint) callconv(.Stdcall) void;
const NamedFramebufferTexture = fn (Uint, Enum, Uint, Int) callconv(.Stdcall) void;
const BlitNamedFramebuffer = fn (Uint, Uint, Int, Int, Int, Int, Int, Int, Int, Int, Bitfield, Enum) callconv(.Stdcall) void;
const BindFramebuffer = fn (Enum, Uint) callconv(.Stdcall) void;
const Begin = fn (Enum) callconv(.Stdcall) void;
const End = fn () callconv(.Stdcall) void;
const GetError = fn () callconv(.Stdcall) Enum;
const PointSize = fn (Float) callconv(.Stdcall) void;
const BlendFunc = fn (Enum, Enum) callconv(.Stdcall) void;
const Vertex2f = fn (Float, Float) callconv(.Stdcall) void;
const Color4f = fn (Float, Float, Float, Float) callconv(.Stdcall) void;

pub var clearBufferfv: ClearBufferfv = undefined;
pub var matrixLoadIdentityEXT: MatrixLoadIdentityEXT = undefined;
pub var matrixOrthoEXT: MatrixOrthoEXT = undefined;
pub var enable: Enable = undefined;
pub var textureStorage2DMultisample: TextureStorage2DMultisample = undefined;
pub var createTextures: CreateTextures = undefined;
pub var deleteTextures: DeleteTextures = undefined;
pub var createFramebuffers: CreateFramebuffers = undefined;
pub var deleteFramebuffers: DeleteFramebuffers = undefined;
pub var namedFramebufferTexture: NamedFramebufferTexture = undefined;
pub var blitNamedFramebuffer: BlitNamedFramebuffer = undefined;
pub var bindFramebuffer: BindFramebuffer = undefined;
pub var begin: Begin = undefined;
pub var end: End = undefined;
pub var getError: GetError = undefined;
pub var pointSize: PointSize = undefined;
pub var blendFunc: BlendFunc = undefined;
pub var vertex2f: Vertex2f = undefined;
pub var color4f: Color4f = undefined;

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
    wCreateContext = opengl32_dll.lookup(WCreateContext, "wglCreateContext").?;
    wDeleteContext = opengl32_dll.lookup(WDeleteContext, "wglDeleteContext").?;
    wMakeCurrent = opengl32_dll.lookup(WMakeCurrent, "wglMakeCurrent").?;
    wGetProcAddress = opengl32_dll.lookup(WGetProcAddress, "wglGetProcAddress").?;

    opengl_context = wCreateContext(hdc);
    if (!wMakeCurrent(hdc, opengl_context)) {
        panic("Failed to create OpenGL context.", .{});
    }

    wSwapIntervalEXT = getProcAddress(WSwapIntervalEXT, "wglSwapIntervalEXT").?;
    _ = wSwapIntervalEXT(1);

    clearBufferfv = getProcAddress(ClearBufferfv, "glClearBufferfv").?;
    matrixLoadIdentityEXT = getProcAddress(MatrixLoadIdentityEXT, "glMatrixLoadIdentityEXT").?;
    matrixOrthoEXT = getProcAddress(MatrixOrthoEXT, "glMatrixOrthoEXT").?;
    enable = getProcAddress(Enable, "glEnable").?;
    textureStorage2DMultisample = getProcAddress(TextureStorage2DMultisample, "glTextureStorage2DMultisample").?;
    createTextures = getProcAddress(CreateTextures, "glCreateTextures").?;
    deleteTextures = getProcAddress(DeleteTextures, "glDeleteTextures").?;
    createFramebuffers = getProcAddress(CreateFramebuffers, "glCreateFramebuffers").?;
    deleteFramebuffers = getProcAddress(DeleteFramebuffers, "glDeleteFramebuffers").?;
    namedFramebufferTexture = getProcAddress(NamedFramebufferTexture, "glNamedFramebufferTexture").?;
    blitNamedFramebuffer = getProcAddress(BlitNamedFramebuffer, "glBlitNamedFramebuffer").?;
    bindFramebuffer = getProcAddress(BindFramebuffer, "glBindFramebuffer").?;
    begin = getProcAddress(Begin, "glBegin").?;
    end = getProcAddress(End, "glEnd").?;
    getError = getProcAddress(GetError, "glGetError").?;
    pointSize = getProcAddress(PointSize, "glPointSize").?;
    blendFunc = getProcAddress(BlendFunc, "glBlendFunc").?;
    vertex2f = getProcAddress(Vertex2f, "glVertex2f").?;
    color4f = getProcAddress(Color4f, "glColor4f").?;
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
