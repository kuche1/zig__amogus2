
const std = @import("std");
const echo = std.debug.print;

const glob = @import("./glob.zig");
const Display = @import("./display.zig").Display;
const Pix_axis_pos = @import("./display.zig").Pix_axis_pos;
const Map = @import("./map.zig").Map;
const Pos = @import("./map.zig").Pos;
const Map_axis_pos = @import("./map.zig").Map_axis_pos;

pub const Player = struct{

    phys: glob.Phys = undefined,
    speed: Map_axis_pos = undefined,

    pos_change: Pos = undefined,

    pub fn init(s: *@This(), aloc: *std.mem.Allocator) !void {

        s.speed = 0.000000022;
        //s.speed = 1;
        //s.speed = 1 / @intToFloat(@TypeOf(s.speed), std.time.nanoTimestamp());

        var m_1:[]const u8 = "^ ^";
        var m0: []const u8 = " O";
        var m1: []const u8 = "/|\\";
        var m2: []const u8 = " |";
        var m3: []const u8 = "/ \\";

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

    pub fn spawn(s: *@This(), pos: Pos) void {
        s.pos_change = .{.x=0, .y=0};
        s.phys.pos = pos;
    }

    pub fn move_left(s: *@This()) void {
        if(s.pos_change.x < 0) s.pos_change.x = 0
        else s.pos_change.x = -s.speed;
    }
    pub fn move_right(s: *@This()) void {
        if(s.pos_change.x > 0) s.pos_change.x = 0
        else s.pos_change.x = s.speed;
    }
    pub fn move_up(s: *@This()) void {
        if(s.pos_change.y < 0) s.pos_change.y = 0
        else s.pos_change.y = -s.speed;
    }
    pub fn move_down(s: *@This()) void {
        if(s.pos_change.y > 0) s.pos_change.y = 0
        else s.pos_change.y = s.speed;
    }

    pub fn commit_movement(s: *@This(), dt: i128, map: *Map) void {
        _ = map.move(&s.phys, .{.x=s.pos_change.x * @intToFloat(@TypeOf(s.pos_change.x), dt), .y=0});
        _ = map.move(&s.phys, .{.y=s.pos_change.y * @intToFloat(@TypeOf(s.pos_change.y), dt), .x=0});
    }

    pub fn draw(s: *@This(), display: *Display) void {
        for(s.phys.model) |line, li| {
            for(line) |char, ci| {
                display.limb(
                            .{
                                .x = @floatToInt(Pix_axis_pos, s.phys.pos.x + @intToFloat(Map_axis_pos, ci)),
                                .y = @floatToInt(Pix_axis_pos, s.phys.pos.y + @intToFloat(Map_axis_pos, li)),
                            },
                            char,
                            );
            }
        }
    }

};
