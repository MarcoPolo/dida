//! Things we want imported in every module for convenience.

pub const dida = @import("../dida.zig");
pub const builtin = @import("builtin");
pub const std = @import("std");
pub const panic = std.debug.panic;
pub const warn = std.debug.warn;
pub const debug_assert = std.debug.assert;
pub const max = std.math.max;
pub const min = std.math.min;
pub const Allocator = std.mem.Allocator;
pub const ArenaAllocator = std.heap.ArenaAllocator;
pub const ArrayList = std.ArrayList;
pub const HashMap = std.HashMap;
pub const AutoHashMap = std.AutoHashMap;

pub fn assert(condition: bool, comptime message: []const u8, args: anytype) void {
    if (!condition) panic(message, args);
}

pub fn TODO() noreturn {
    panic("TODO", .{});
}

pub fn DeepHashMap(comptime K: type, comptime V: type) type {
    return std.HashMap(K, V, struct {
        fn hash(key: K) u64 {
            return dida.meta.deepHash(key);
        }
    }.hash, struct {
        fn equal(a: K, b: K) bool {
            return dida.meta.deepEqual(a, b);
        }
    }.equal, std.hash_map.DefaultMaxLoadPercentage);
}

pub fn DeepHashSet(comptime K: type) type {
    return DeepHashMap(K, void);
}

pub fn dump(thing: anytype) void {
    const held = std.debug.getStderrMutex().acquire();
    defer held.release();
    const my_stderr = std.io.getStdErr().writer();
    dida.meta.dumpInto(my_stderr, 0, thing) catch return;
    my_stderr.writeAll("\n") catch return;
}

pub fn format(allocator: *Allocator, comptime fmt: []const u8, args: anytype) ![]const u8 {
    var buf = ArrayList(u8).init(allocator);
    var out = buf.outStream();
    try std.fmt.format(out, fmt, args);
    return buf.items;
}

// Chain casts from *T to *[1]T to []T
pub fn ptrToSlice(comptime T: type, input: *const T) []const T {
    const one_input: *const [1]T = input;
    return one_input;
}

pub fn last(comptime T: type, slice: []const T) T {
    assert(slice.len > 0, "Tried to take last item of a 0-length slice", .{});
    return slice[slice.len - 1];
}
