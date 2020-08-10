const std = @import("std");
const os = std.os;
const panic = std.debug.panic;

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

const WCreateContext = fn (?os.windows.HDC) callconv(.Stdcall) ?os.windows.HGLRC;
const WMakeCurrent = fn (?os.windows.HDC, ?os.windows.HGLRC) callconv(.Stdcall) bool;
const WDeleteContext = fn (?os.windows.HGLRC) callconv(.Stdcall) bool;
const WGetProcAddress = fn (os.windows.LPCSTR) callconv(.Stdcall) ?os.windows.FARPROC;

var wCreateContext: WCreateContext = undefined;
var wDeleteContext: WDeleteContext = undefined;
var wMakeCurrent: WMakeCurrent = undefined;
var wGetProcAddress: WGetProcAddress = undefined;

const ClearBufferfv = fn (Enum, Int, [*c]const Float) callconv(.Stdcall) void;
const MatrixLoadIdentityEXT = fn (Enum) callconv(.Stdcall) void;
const MatrixOrthoEXT = fn (Enum, Double, Double, Double, Double, Double, Double) callconv(.Stdcall) void;
const Enable = fn (Enum) callconv(.Stdcall) void;
const TextureStorage2DMultisample = fn (Uint, Sizei, Enum, Sizei, Sizei, Boolean) callconv(.Stdcall) void;
const CreateTextures = fn (Enum, Sizei, [*c]Uint) callconv(.Stdcall) void;
const CreateFramebuffers = fn (Sizei, [*c]Uint) callconv(.Stdcall) void;
const NamedFramebufferTexture = fn (Uint, Enum, Uint, Int) callconv(.Stdcall) void;
const BlitNamedFramebuffer = fn (Uint, Uint, Int, Int, Int, Int, Int, Int, Int, Int, Bitfield, Enum) callconv(.Stdcall) void;
const BindFramebuffer = fn (Enum, Uint) callconv(.Stdcall) void;
const Begin = fn (Enum) callconv(.Stdcall) void;
const End = fn () callconv(.Stdcall) void;

pub var clearBufferfv: ClearBufferfv = undefined;
pub var matrixLoadIdentityEXT: MatrixLoadIdentityEXT = undefined;
pub var matrixOrthoEXT: MatrixOrthoEXT = undefined;
pub var enable: Enable = undefined;
pub var textureStorage2DMultisample: TextureStorage2DMultisample = undefined;
pub var createTextures: CreateTextures = undefined;
pub var createFramebuffers: CreateFramebuffers = undefined;
pub var namedFramebufferTexture: NamedFramebufferTexture = undefined;
pub var blitNamedFramebuffer: BlitNamedFramebuffer = undefined;
pub var bindFramebuffer: BindFramebuffer = undefined;
pub var begin: Begin = undefined;
pub var end: End = undefined;

var opengl32_dll: std.DynLib = undefined;
var hdc: ?os.windows.HDC = null;

pub fn init(window: ?os.windows.HWND) void {
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

    const opengl_context = wCreateContext(hdc);
    if (!wMakeCurrent(hdc, opengl_context)) {
        panic("Failed to create OpenGL context.", .{});
    }

    clearBufferfv = getProcAddress(ClearBufferfv, "glClearBufferfv").?;
    matrixLoadIdentityEXT = getProcAddress(MatrixLoadIdentityEXT, "glMatrixLoadIdentityEXT").?;
    matrixOrthoEXT = getProcAddress(MatrixOrthoEXT, "glMatrixOrthoEXT").?;
    enable = getProcAddress(Enable, "glEnable").?;
    textureStorage2DMultisample = getProcAddress(TextureStorage2DMultisample, "glTextureStorage2DMultisample").?;
    createTextures = getProcAddress(CreateTextures, "glCreateTextures").?;
    createFramebuffers = getProcAddress(CreateFramebuffers, "glCreateFramebuffers").?;
    namedFramebufferTexture = getProcAddress(NamedFramebufferTexture, "glNamedFramebufferTexture").?;
    blitNamedFramebuffer = getProcAddress(BlitNamedFramebuffer, "glBlitNamedFramebuffer").?;
    bindFramebuffer = getProcAddress(BindFramebuffer, "glBindFramebuffer").?;
    begin = getProcAddress(Begin, "glBegin").?;
    end = getProcAddress(End, "glEnd").?;
}

pub fn swapBuffers() void {
    _ = os.windows.gdi32.SwapBuffers(hdc);
}

fn getProcAddress(comptime T: type, name: [:0]const u8) ?T {
    if (wGetProcAddress(name.ptr)) |addr| {
        return @ptrCast(T, addr);
    } else {
        return opengl32_dll.lookup(T, name);
    }
}
