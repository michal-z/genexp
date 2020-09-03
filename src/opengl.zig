const std = @import("std");
const os = std.os;
const panic = std.debug.panic;
const assert = std.debug.assert;

const GLenum = c_uint;
const GLuint = c_uint;
const GLint = c_int;
const GLsizei = c_int;
const GLfloat = f32;
const GLdouble = f64;
const GLchar = u8;
const GLboolean = u8;
const GLbitfield = c_uint;
const GLubyte = u8;
const GLsizeiptr = isize;
const GLintptr = isize;

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
pub const FUNC_REVERSE_SUBTRACT = 0x800B;
pub const FUNC_SUBTRACT = 0x800A;
pub const FUNC_ADD = 0x8006;
pub const FRAGMENT_SHADER = 0x8B30;
pub const VERTEX_SHADER = 0x8B31;
pub const TEXTURE_2D = 0x0DE1;
pub const RG = 0x8227;
pub const RG_INTEGER = 0x8228;
pub const R8 = 0x8229;
pub const R16 = 0x822A;
pub const RG8 = 0x822B;
pub const RG16 = 0x822C;
pub const R16F = 0x822D;
pub const R32F = 0x822E;
pub const RG16F = 0x822F;
pub const RG32F = 0x8230;
pub const R8I = 0x8231;
pub const R8UI = 0x8232;
pub const R16I = 0x8233;
pub const R16UI = 0x8234;
pub const R32I = 0x8235;
pub const R32UI = 0x8236;
pub const RG8I = 0x8237;
pub const RG8UI = 0x8238;
pub const RG16I = 0x8239;
pub const RG16UI = 0x823A;
pub const RG32I = 0x823B;
pub const RG32UI = 0x823C;
pub const RGBA32F = 0x8814;
pub const RGB32F = 0x8815;
pub const RGBA16F = 0x881A;
pub const RGB16F = 0x881B;
pub const RGBA32UI = 0x8D70;
pub const RGB32UI = 0x8D71;
pub const RGBA16UI = 0x8D76;
pub const RGB16UI = 0x8D77;
pub const RGBA8UI = 0x8D7C;
pub const RGB8UI = 0x8D7D;
pub const RGBA32I = 0x8D82;
pub const RGB32I = 0x8D83;
pub const RGBA16I = 0x8D88;
pub const RGB16I = 0x8D89;
pub const RGBA8I = 0x8D8E;
pub const RGB8I = 0x8D8F;
pub const RED_INTEGER = 0x8D94;
pub const GREEN_INTEGER = 0x8D95;
pub const BLUE_INTEGER = 0x8D96;
pub const RGB_INTEGER = 0x8D98;
pub const RGBA_INTEGER = 0x8D99;
pub const BGR_INTEGER = 0x8D9A;
pub const BGRA_INTEGER = 0x8D9B;
pub const BYTE = 0x1400;
pub const UNSIGNED_BYTE = 0x1401;
pub const SHORT = 0x1402;
pub const UNSIGNED_SHORT = 0x1403;
pub const INT = 0x1404;
pub const UNSIGNED_INT = 0x1405;
pub const FLOAT = 0x1406;
pub const READ_ONLY = 0x88B8;
pub const WRITE_ONLY = 0x88B9;
pub const READ_WRITE = 0x88BA;
pub const ATOMIC_COUNTER_BUFFER = 0x92C0;
pub const VERTEX_ATTRIB_ARRAY_BARRIER_BIT = 0x00000001;
pub const ELEMENT_ARRAY_BARRIER_BIT = 0x00000002;
pub const UNIFORM_BARRIER_BIT = 0x00000004;
pub const TEXTURE_FETCH_BARRIER_BIT = 0x00000008;
pub const SHADER_IMAGE_ACCESS_BARRIER_BIT = 0x00000020;
pub const COMMAND_BARRIER_BIT = 0x00000040;
pub const PIXEL_BUFFER_BARRIER_BIT = 0x00000080;
pub const TEXTURE_UPDATE_BARRIER_BIT = 0x00000100;
pub const BUFFER_UPDATE_BARRIER_BIT = 0x00000200;
pub const FRAMEBUFFER_BARRIER_BIT = 0x00000400;
pub const TRANSFORM_FEEDBACK_BARRIER_BIT = 0x00000800;
pub const ATOMIC_COUNTER_BARRIER_BIT = 0x00001000;
pub const ALL_BARRIER_BITS = 0xFFFFFFFF;
pub const FRAMEBUFFER_BINDING = 0x8CA6;
pub const DRAW_FRAMEBUFFER_BINDING = 0x8CA6;
pub const RENDERBUFFER_BINDING = 0x8CA7;
pub const READ_FRAMEBUFFER = 0x8CA8;
pub const READ_FRAMEBUFFER_BINDING = 0x8CAA;
pub const STENCIL_INDEX = 0x1901;
pub const DEPTH_COMPONENT = 0x1902;
pub const RED = 0x1903;
pub const GREEN = 0x1904;
pub const BLUE = 0x1905;
pub const ALPHA = 0x1906;
pub const RGB = 0x1907;
pub const RGBA = 0x1908;
pub const TEXTURE_RECTANGLE = 0x84F5;

var wCreateContext: fn (?os.windows.HDC) callconv(.Stdcall) ?os.windows.HGLRC = undefined;
var wDeleteContext: fn (?os.windows.HGLRC) callconv(.Stdcall) bool = undefined;
var wMakeCurrent: fn (?os.windows.HDC, ?os.windows.HGLRC) callconv(.Stdcall) bool = undefined;
var wGetProcAddress: fn (os.windows.LPCSTR) callconv(.Stdcall) ?os.windows.FARPROC = undefined;
var wSwapIntervalEXT: fn (i32) callconv(.Stdcall) bool = undefined;

pub var clearBufferfv: fn (GLenum, GLint, [*c]const GLfloat) callconv(.Stdcall) void = undefined;
pub var matrixLoadIdentityEXT: fn (GLenum) callconv(.Stdcall) void = undefined;
pub var matrixOrthoEXT: fn (GLenum, GLdouble, GLdouble, GLdouble, GLdouble, GLdouble, GLdouble) callconv(.Stdcall) void = undefined;
pub var enable: fn (GLenum) callconv(.Stdcall) void = undefined;
pub var disable: fn (GLenum) callconv(.Stdcall) void = undefined;
pub var textureStorage2DMultisample: fn (GLuint, GLsizei, GLenum, GLsizei, GLsizei, GLboolean) callconv(.Stdcall) void = undefined;
pub var textureStorage2D: fn (GLuint, GLsizei, GLenum, GLsizei, GLsizei) callconv(.Stdcall) void = undefined;
pub var createTextures: fn (GLenum, GLsizei, [*c]GLuint) callconv(.Stdcall) void = undefined;
pub var deleteTextures: fn (GLsizei, [*c]const GLuint) callconv(.Stdcall) void = undefined;
pub var createFramebuffers: fn (GLsizei, [*c]GLuint) callconv(.Stdcall) void = undefined;
pub var deleteFramebuffers: fn (GLsizei, [*c]const GLuint) callconv(.Stdcall) void = undefined;
pub var namedFramebufferTexture: fn (GLuint, GLenum, GLuint, GLint) callconv(.Stdcall) void = undefined;
pub var blitNamedFramebuffer: fn (GLuint, GLuint, GLint, GLint, GLint, GLint, GLint, GLint, GLint, GLint, GLbitfield, GLenum) callconv(.Stdcall) void = undefined;
pub var bindFramebuffer: fn (GLenum, GLuint) callconv(.Stdcall) void = undefined;
pub var begin: fn (GLenum) callconv(.Stdcall) void = undefined;
pub var end: fn () callconv(.Stdcall) void = undefined;
pub var getError: fn () callconv(.Stdcall) GLenum = undefined;
pub var pointSize: fn (GLfloat) callconv(.Stdcall) void = undefined;
pub var lineWidth: fn (GLfloat) callconv(.Stdcall) void = undefined;
pub var blendFunc: fn (GLenum, GLenum) callconv(.Stdcall) void = undefined;
pub var blendEquation: fn (GLenum) callconv(.Stdcall) void = undefined;
pub var vertex2f: fn (GLfloat, GLfloat) callconv(.Stdcall) void = undefined;
pub var vertex2d: fn (GLdouble, GLdouble) callconv(.Stdcall) void = undefined;
pub var vertex2i: fn (GLint, GLint) callconv(.Stdcall) void = undefined;
pub var color4f: fn (GLfloat, GLfloat, GLfloat, GLfloat) callconv(.Stdcall) void = undefined;
pub var color4ub: fn (GLubyte, GLubyte, GLubyte, GLubyte) callconv(.Stdcall) void = undefined;
pub var pushMatrix: fn () callconv(.Stdcall) void = undefined;
pub var popMatrix: fn () callconv(.Stdcall) void = undefined;
pub var rotatef: fn (GLfloat, GLfloat, GLfloat, GLfloat) callconv(.Stdcall) void = undefined;
pub var scalef: fn (GLfloat, GLfloat, GLfloat) callconv(.Stdcall) void = undefined;
pub var translatef: fn (GLfloat, GLfloat, GLfloat) callconv(.Stdcall) void = undefined;
pub var createShaderProgramv: fn (GLenum, GLsizei, [*c]const [*c]const GLchar) callconv(.Stdcall) GLuint = undefined;
pub var useProgram: fn (GLuint) callconv(.Stdcall) void = undefined;
pub var bindBuffer: fn (GLenum, GLuint) callconv(.Stdcall) void = undefined;
pub var bindBufferRange: fn (GLenum, GLuint, GLuint, GLintptr, GLsizeiptr) callconv(.Stdcall) void = undefined;
pub var bindBufferBase: fn (GLenum, GLuint, GLuint) callconv(.Stdcall) void = undefined;
pub var createBuffers: fn (GLsizei, [*c]GLuint) callconv(.Stdcall) void = undefined;
pub var deleteBuffers: fn (GLsizei, [*c]const GLuint) callconv(.Stdcall) void = undefined;
pub var namedBufferStorage: fn (GLuint, GLsizeiptr, ?*const c_void, GLbitfield) callconv(.Stdcall) void = undefined;
pub var clearTexImage: fn (GLuint, GLint, GLenum, GLenum, ?*const c_void) callconv(.Stdcall) void = undefined;
pub var bindImageTexture: fn (GLuint, GLuint, GLint, GLboolean, GLint, GLenum, GLenum) callconv(.Stdcall) void = undefined;
pub var deleteProgram: fn (GLuint) callconv(.Stdcall) void = undefined;
pub var memoryBarrier: fn (GLbitfield) callconv(.Stdcall) void = undefined;
pub var colorMask: fn (GLboolean, GLboolean, GLboolean, GLboolean) void = undefined;
pub var getIntegerv: fn (GLenum, [*c]GLint) void = undefined;
pub var bindTextureUnit: fn (GLuint, GLuint) callconv(.Stdcall) void = undefined;

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
    disable = getProcAddress(@TypeOf(disable), "glDisable").?;
    textureStorage2DMultisample = getProcAddress(@TypeOf(textureStorage2DMultisample), "glTextureStorage2DMultisample").?;
    textureStorage2D = getProcAddress(@TypeOf(textureStorage2D), "glTextureStorage2D").?;
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
    blendEquation = getProcAddress(@TypeOf(blendEquation), "glBlendEquation").?;
    vertex2f = getProcAddress(@TypeOf(vertex2f), "glVertex2f").?;
    vertex2d = getProcAddress(@TypeOf(vertex2d), "glVertex2d").?;
    vertex2i = getProcAddress(@TypeOf(vertex2i), "glVertex2i").?;
    color4f = getProcAddress(@TypeOf(color4f), "glColor4f").?;
    color4ub = getProcAddress(@TypeOf(color4ub), "glColor4ub").?;
    pushMatrix = getProcAddress(@TypeOf(pushMatrix), "glPushMatrix").?;
    popMatrix = getProcAddress(@TypeOf(popMatrix), "glPopMatrix").?;
    rotatef = getProcAddress(@TypeOf(rotatef), "glRotatef").?;
    scalef = getProcAddress(@TypeOf(scalef), "glScalef").?;
    translatef = getProcAddress(@TypeOf(translatef), "glTranslatef").?;
    createShaderProgramv = getProcAddress(@TypeOf(createShaderProgramv), "glCreateShaderProgramv").?;
    useProgram = getProcAddress(@TypeOf(useProgram), "glUseProgram").?;
    bindBuffer = getProcAddress(@TypeOf(bindBuffer), "glBindBuffer").?;
    bindBufferRange = getProcAddress(@TypeOf(bindBufferRange), "glBindBufferRange").?;
    bindBufferBase = getProcAddress(@TypeOf(bindBufferBase), "glBindBufferBase").?;
    createBuffers = getProcAddress(@TypeOf(createBuffers), "glCreateBuffers").?;
    deleteBuffers = getProcAddress(@TypeOf(deleteBuffers), "glDeleteBuffers").?;
    namedBufferStorage = getProcAddress(@TypeOf(namedBufferStorage), "glNamedBufferStorage").?;
    clearTexImage = getProcAddress(@TypeOf(clearTexImage), "glClearTexImage").?;
    bindImageTexture = getProcAddress(@TypeOf(bindImageTexture), "glBindImageTexture").?;
    deleteProgram = getProcAddress(@TypeOf(deleteProgram), "glDeleteProgram").?;
    memoryBarrier = getProcAddress(@TypeOf(memoryBarrier), "glMemoryBarrier").?;
    colorMask = getProcAddress(@TypeOf(colorMask), "glColorMask").?;
    getIntegerv = getProcAddress(@TypeOf(getIntegerv), "glGetIntegerv").?;
    bindTextureUnit = getProcAddress(@TypeOf(bindTextureUnit), "glBindTextureUnit").?;
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
