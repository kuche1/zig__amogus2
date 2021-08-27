
// compile with "--library c"

const std = @import("std");
const echo = std.debug.print;

const c = @cImport({
    @cInclude("sys/ioctl.h");
    @cInclude("unistd.h");
});

const glob = @import("./glob.zig");
const Map = @import("./map.zig").Map;

const Pix = u8;
const BORDER_HORIZONTAL: Pix = '-';
const BORDER_VERTICAL: Pix = '|';

pub const Pix_pos = struct{
    x: Pix_axis_pos,
    y: Pix_axis_pos,
};

pub const Pix_axis_pos = u8;


pub const Display = struct{
    res: Pix_pos = .{.x=0, .y=0},
    buf: [][]Pix = undefined,

    pub fn init(s: *@This(), aloc: *std.mem.Allocator) !void {
        s.buf = try aloc.alloc(@TypeOf(s.buf[0]), 0);
    }

    pub fn deinit(s: *@This(), aloc: *std.mem.Allocator) void {
        for(s.buf) |line| {
            aloc.free(line);
        }
        aloc.free(s.buf);
    }

    pub fn autoresize(s: *@This(), aloc: *std.mem.Allocator, map: *Map) !void {

        var size: c.winsize = undefined;
        var res: c_int = c.ioctl(c.STDOUT_FILENO, c.TIOCGWINSZ, &size);
        if(res != 0){
            return error.ioctl_fucked_up_getting_the_display_size;
        }

        if(s.res.x == size.ws_col and s.res.y == size.ws_row) return;

        s.res = .{
                .x=@intCast(@TypeOf(s.res.x), size.ws_col),
                .y=@intCast(@TypeOf(s.res.y), size.ws_row),
                };

        if(s.res.x <= map.endx or s.res.y <= map.endy) return error.map_cant_fit_on_display;
        // <= cuz ofthe borders (or smt)

        for(s.buf) |line| {
            aloc.free(line);
        }
        s.buf.len = 0;
        aloc.free(s.buf);

        s.buf = try aloc.alloc([]u8, s.res.y);
        errdefer aloc.free(s.buf);

        for(s.buf) |_, y| {
            s.buf[y] = try aloc.alloc(u8, s.res.x);
            errdefer {
                for(buf[0..y]) |item| {
                    aloc.free(item);
                }
            }
        }

    }

    pub fn clear(s: *@This(), aloc: *std.mem.Allocator, map: *Map) !void {

        try s.autoresize(aloc, map);
    
        for(s.buf) |line, y| {
            for(line) |_, x| {
                s.pix(.{.x=@intCast(Pix_axis_pos, x), .y=@intCast(Pix_axis_pos, y)}, ' ');
            }
        }

        var i: u8 = 0;

        while(i < map.endy): (i += 1){
            s.pix(.{.x=@intCast(Pix_axis_pos, map.endx), .y=i}, BORDER_VERTICAL);
        }

        i = 0;
        while(i < map.endx): (i += 1){
            s.pix(.{.x=i, .y=@intCast(Pix_axis_pos, map.endy)}, BORDER_HORIZONTAL);
        }
    }

    pub fn limb(s: *@This(), pos: Pix_pos, v: glob.Limb) void {
        if(v == glob.LIMB_TRANSPARENT) return;
        s.pix(pos, v);
    }

    fn pix(s: *@This(), pos: Pix_pos, v: Pix) void {
        s.buf[pos.y][pos.x] = v;
    }

    pub fn draw(s: *@This()) !void {

        for(s.buf)|line, li|{
            for(line)|pixel, pi|{
                try s.prnt("\x1b[{d};{d}H", .{li+1, pi+1});
                try s.prnt("{c}", .{pixel});
            }
        }
    }

    fn prnt(s: *@This(), comptime fmt: []const u8, args: anytype) !void {
        const print = std.io.getStdOut().writer().print;
        return print(fmt, args);
    }

};
