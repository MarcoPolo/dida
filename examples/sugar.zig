// TODO this whole file is just speculative atm

const std = @import("std");
const dida = @import("../core/dida.zig");

var gpa = std.heap.GeneralPurposeAllocator(.{
    .safety = true,
    .never_unmap = true,
}){};
var arena = std.heap.ArenaAllocator.init(&gpa.allocator);
const allocator = &arena.allocator;

pub fn main() !void {
    defer {
        arena.deinit();
        _ = gpa.detectLeaks();
    }

    const sugar = dida.sugar.Sugar.init(allocator);
    const main = sugar.main();

    const edges = main.input();
    const reach = main.loop().loopNode();
    reach.fixpoint(reach
        .index()
        .distinct()
        .join(edges.project(.{ 1, 0 }).index(), 1)
        .project(.{ 3, 1 }));
    const out = reach.output();

    sugar.build();

    try edges.push(.{ .{ "a", "b" }, 1, .{0} });
    try edges.push(.{ .{ "b", "c" }, 1, .{0} });
    try edges.push(.{ .{ "c", "d" }, 1, .{0} });
    try edges.push(.{ .{ "c", "a" }, 1, .{0} });
    try edges.push(.{ .{ "b", "c" }, -1, .{1} });
    try edges.flush();

    try edges.advance(.{1});
    try sugar.doAllWork();
    while (out.pop()) |change_batch| {
        dida.common.dump(change_batch);
    }

    std.debug.print("Advancing!\n", .{});

    try edges.advance(.{2});
    try sugar.doAllWork();
    while (out.pop()) |change_batch| {
        dida.common.dump(change_batch);
    }
}
