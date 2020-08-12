const std = @import("std");
const win = std.os.windows;

pub const RESOURCE_BARRIER_ALL_SUBRESOURCES = 0xffffffff;
pub const DEFAULT_DEPTH_BIAS = 0;
pub const DEFAULT_DEPTH_BIAS_CLAMP = 0.0;
pub const DEFAULT_SLOPE_SCALED_DEPTH_BIAS = 0.0;
pub const DEFAULT_STENCIL_READ_MASK = 0xff;
pub const DEFAULT_STENCIL_WRITE_MASK = 0xff;

const BlobVTable = extern struct {
    const Self = Blob;
    // IUnknown
    QueryInterface: fn (self: *Self, *const win.GUID, **c_void) callconv(.Stdcall) win.HRESULT,
    AddRef: fn (self: *Self) callconv(.Stdcall) win.HRESULT,
    Release: fn (self: *Self) callconv(.Stdcall) win.HRESULT,
    // ID3DBlob
    GetBufferPointer: fn (self: *Self) callconv(.Stdcall) *c_void,
    GetBufferSize: fn (self: *Self) callconv(.Stdcall) u64,
};

pub const Blob = extern struct {
    vtbl: *const BlobVTable,
    const Self = @This();

    pub inline fn QueryInterface(self: *Self, guid: *const win.GUID, outobj: **c_void) win.HRESULT {
        return self.vtbl.QueryInterface(self, guid, outobj);
    }
    pub inline fn AddRef(self: *Self) win.HRESULT {
        return self.vtbl.AddRef(self);
    }
};
