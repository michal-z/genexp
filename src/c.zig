pub usingnamespace @cImport({
    @cDefine("GLFW_INCLUDE_GLEXT", "");
    @cInclude("GLFW/glfw3.h");
});

var glMatrixLoadIdentityEXT_fn: PFNGLMATRIXLOADIDENTITYEXTPROC = undefined;
var glMatrixOrthoEXT_fn: PFNGLMATRIXORTHOEXTPROC = undefined;
var glDebugMessageCallback_fn: PFNGLDEBUGMESSAGECALLBACKPROC = undefined;
var glCreateTextures_fn: PFNGLCREATETEXTURESPROC = undefined;
var glBlitNamedFramebuffer_fn: PFNGLBLITNAMEDFRAMEBUFFERPROC = undefined;
var glTextureStorage2DMultisample_fn: PFNGLTEXTURESTORAGE2DMULTISAMPLEPROC = undefined;
var glNamedFramebufferTexture_fn: PFNGLNAMEDFRAMEBUFFERTEXTUREPROC = undefined;
var glCreateBuffers_fn: PFNGLCREATEBUFFERSPROC = undefined;
var glCreateFramebuffers_fn: PFNGLCREATEFRAMEBUFFERSPROC = undefined;
var glDeleteFramebuffers_fn: PFNGLDELETEFRAMEBUFFERSPROC = undefined;
var glBindFramebuffer_fn: PFNGLBINDFRAMEBUFFERPROC = undefined;

pub fn loadGraphicsEntryPoints() void {
    glMatrixLoadIdentityEXT_fn = @ptrCast(PFNGLMATRIXLOADIDENTITYEXTPROC, glfwGetProcAddress("glMatrixLoadIdentityEXT"));
    glMatrixOrthoEXT_fn = @ptrCast(PFNGLMATRIXORTHOEXTPROC, glfwGetProcAddress("glMatrixOrthoEXT"));
    glDebugMessageCallback_fn = @ptrCast(PFNGLDEBUGMESSAGECALLBACKPROC, glfwGetProcAddress("glDebugMessageCallback"));
    glCreateTextures_fn = @ptrCast(PFNGLCREATETEXTURESPROC, glfwGetProcAddress("glCreateTextures"));
    glBlitNamedFramebuffer_fn = @ptrCast(PFNGLBLITNAMEDFRAMEBUFFERPROC, glfwGetProcAddress("glBlitNamedFramebuffer"));
    glTextureStorage2DMultisample_fn = @ptrCast(PFNGLTEXTURESTORAGE2DMULTISAMPLEPROC, glfwGetProcAddress("glTextureStorage2DMultisample"));
    glNamedFramebufferTexture_fn = @ptrCast(PFNGLNAMEDFRAMEBUFFERTEXTUREPROC, glfwGetProcAddress("glNamedFramebufferTexture"));
    glCreateBuffers_fn = @ptrCast(PFNGLCREATEBUFFERSPROC, glfwGetProcAddress("glCreateBuffers"));
    glCreateFramebuffers_fn = @ptrCast(PFNGLCREATEFRAMEBUFFERSPROC, glfwGetProcAddress("glCreateFramebuffers"));
    glDeleteFramebuffers_fn = @ptrCast(PFNGLDELETEFRAMEBUFFERSPROC, glfwGetProcAddress("glDeleteFramebuffers"));
    glBindFramebuffer_fn = @ptrCast(PFNGLBINDFRAMEBUFFERPROC, glfwGetProcAddress("glBindFramebuffer"));
}

pub inline fn glMatrixLoadIdentityEXT(mode: GLenum) void {
    glMatrixLoadIdentityEXT_fn.?(mode);
}
pub inline fn glMatrixOrthoEXT(mode: GLenum, left: GLdouble, right: GLdouble, bottom: GLdouble, top: GLdouble, zNear: GLdouble, zFar: GLdouble) void {
    glMatrixOrthoEXT_fn.?(mode, left, right, bottom, top, zNear, zFar);
}
pub inline fn glDebugMessageCallback(callback: GLDEBUGPROC, userParam: ?*const c_void) void {
    glDebugMessageCallback_fn.?(callback, userParam);
}
pub inline fn glCreateTextures(target: GLenum, n: GLsizei, textures: [*c]GLuint) void {
    glCreateTextures_fn.?(target, n, textures);
}
pub inline fn glBlitNamedFramebuffer(readFramebuffer: GLuint, drawFramebuffer: GLuint, srcX0: GLint, srcY0: GLint, srcX1: GLint, srcY1: GLint, dstX0: GLint, dstY0: GLint, dstX1: GLint, dstY1: GLint, mask: GLbitfield, filter: GLenum) void {
    glBlitNamedFramebuffer_fn.?(readFramebuffer, drawFramebuffer, srcX0, srcY0, srcX1, srcY1, dstX0, dstY0, dstX1, dstY1, mask, filter);
}
pub inline fn glTextureStorage2DMultisample(texture: GLuint, samples: GLsizei, internalformat: GLenum, width: GLsizei, height: GLsizei, fixedsamplelocations: GLboolean) void {
    glTextureStorage2DMultisample_fn.?(texture, samples, internalformat, width, height, fixedsamplelocations);
}
pub inline fn glNamedFramebufferTexture(framebuffer: GLuint, attachment: GLenum, texture: GLuint, level: GLint) void {
    glNamedFramebufferTexture_fn.?(framebuffer, attachment, texture, level);
}
pub inline fn glCreateBuffers(n: GLsizei, buffers: [*c]GLuint) void {
    glCreateBuffers_fn.?(n, buffers);
}
pub inline fn glCreateFramebuffers(n: GLsizei, framebuffers: [*c]GLuint) void {
    glCreateFramebuffers_fn.?(n, framebuffers);
}
pub inline fn glDeleteFramebuffers(n: GLsizei, framebuffers: [*c]GLuint) void {
    glDeleteFramebuffers_fn.?(n, framebuffers);
}
pub inline fn glBindFramebuffer(target: GLenum, framebuffer: GLuint) void {
    glBindFramebuffer_fn.?(target, framebuffer);
}
