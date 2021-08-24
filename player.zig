
const std = @import("std");

const glob = @import("./glob.zig");
const Settings = @import("./settings.zig").Settings;
const Display = @import("./display.zig").Display;

pub const Player = struct{
    phys: glob.Phys = undefined,

    pub fn init(s: *@This(), aloc: *std.mem.Allocator) !void {

        var arr1: []const u8 = "   pussy";
        var arr2: []const u8 = "dest   royer";

        var m_1:[]const u8 = " ^ ^";
        var m0: []const u8 = "  O";
        var m1: []const u8 = " /|\\";
        var m2: []const u8 = "  |";
        var m3: []const u8 = " / \\";

        var ptrs: []*[]const u8 = ([_]*[]const u8{&m_1, &m0, &m1, &m2, &m3})[0..];

        s.phys.model = try aloc.alloc([]u8, ptrs.len);
        errdefer aloc.free(s.phys.model);

        for(ptrs) |line, li| {

            const model = try aloc.alloc(u8, line.len);
            errdefer aloc.free(model);

            for(line.*) |item, ind| {
                model[ind] = item;
            }

            s.phys.model[li] = model;
        }

    }

    pub fn deinit(s: *@This(), aloc: *std.mem.Allocator) void {
        for(s.phys.model) |line| {
            aloc.free(line);
        }
        aloc.free(s.phys.model);
    }

    pub fn spawn(s: *@This(), x: i8, y: i8) void {
        s.phys.pos.x = x;
        s.phys.pos.y = y;
    }

    pub fn draw(s: *@This(), display: *Display) void {
        for(s.phys.model) |line, li| {
            for(line) |char, ci| {
                display.limb(
                            @intCast(usize, s.phys.pos.y)+li,
                            @intCast(usize, s.phys.pos.x)+ci,
                            char,
                            );
            }
        }
    }

};
