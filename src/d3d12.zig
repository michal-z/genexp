const std = @import("std");
const panic = std.debug.panic;
const assert = std.debug.assert;
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
    QueryInterface: fn (*Self, *const win.GUID, **c_void) callconv(.Stdcall) win.HRESULT,
    AddRef: fn (*Self) callconv(.Stdcall) u32,
    Release: fn (*Self) callconv(.Stdcall) u32,
    // ID3DBlob
    GetBufferPointer: fn (*Self) callconv(.Stdcall) *c_void,
    GetBufferSize: fn (*Self) callconv(.Stdcall) u64,
};

pub const Blob = extern struct {
    vtbl: *const BlobVTable,
    const Self = @This();
    // IUnknown
    pub inline fn QueryInterface(self: *Self, guid: *const win.GUID, outobj: **c_void) win.HRESULT {
        return self.vtbl.QueryInterface(self, guid, outobj);
    }
    pub inline fn AddRef(self: *Self) u32 {
        return self.vtbl.AddRef(self);
    }
    pub inline fn Release(self: *Self) u32 {
        return self.vtbl.Release(self);
    }
    // ID3DBlob
    pub inline fn GetBufferPointer(self: *Self) *c_void {
        return self.vtbl.GetBufferPointer(self);
    }
    pub inline fn GetBufferSize(self: *Self) u64 {
        return self.vtbl.GetBufferSize(self);
    }
};

const DebugVTable = extern struct {
    const Self = Debug;
    // IUnknown
    QueryInterface: fn (*Self, *const win.GUID, **c_void) callconv(.Stdcall) win.HRESULT,
    AddRef: fn (*Self) callconv(.Stdcall) u32,
    Release: fn (*Self) callconv(.Stdcall) u32,
    // ID3D12Debug
    EnableDebugLayer: fn (*Self) callconv(.Stdcall) void,
};

pub const Debug = extern struct {
    vtbl: *const DebugVTable,
    const Self = @This();
    // IUnknown
    pub inline fn QueryInterface(self: *Self, guid: *const win.GUID, outobj: **c_void) win.HRESULT {
        return self.vtbl.QueryInterface(self, guid, outobj);
    }
    pub inline fn AddRef(self: *Self) u32 {
        return self.vtbl.AddRef(self);
    }
    pub inline fn Release(self: *Self) u32 {
        return self.vtbl.Release(self);
    }
    // ID3D12Debug
    pub inline fn EnableDebugLayer(self: *Self) void {
        self.vtbl.EnableDebugLayer(self);
    }
};

pub const IID_ID3D12Debug = win.GUID{
    .Data1 = 0x344488b7,
    .Data2 = 0x6846,
    .Data3 = 0x474b,
    .Data4 = .{ 0xb9, 0x89, 0xf0, 0x27, 0x44, 0x82, 0x45, 0xe0 },
};

pub var GetDebugInterface: fn (*const win.GUID, **c_void) callconv(.Stdcall) win.HRESULT = undefined;

pub inline fn vhr(hr: win.HRESULT) void {
    if (hr < 0) {
        panic("D3D12 function failed.", .{});
    }
}

pub fn init() void {
    var d3d12_dll = std.DynLib.open("/windows/system32/d3d12.dll") catch unreachable;
    GetDebugInterface = d3d12_dll.lookup(@TypeOf(GetDebugInterface), "D3D12GetDebugInterface").?;

    var debug: *Debug = undefined;
    vhr(GetDebugInterface(&IID_ID3D12Debug, @ptrCast(**c_void, &debug)));
    debug.EnableDebugLayer();
    _ = debug.Release();
}
