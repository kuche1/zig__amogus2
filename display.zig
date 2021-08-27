
// compile with "--library c"

const std = @import("std");
const print = std.io.getStdOut().writer().print;
const echo = std.debug.print;

const c = @cImport({
    @cInclude("sys/ioctl.h");
    @cInclude("unistd.h");
});

const glob = @import("./glob.zig");

const Pix = u8;

pub const Display = struct{
    resx: u8 = undefined,
    resy: u8 = undefined,
    buf: [][]Pix = undefined,

    pub fn init(s: *@This(), aloc: *std.mem.Allocator) !void {

        var size: c.winsize = undefined;
        var res: c_int = c.ioctl(c.STDOUT_FILENO, c.TIOCGWINSZ, &size);
        if(res != 0){
            return error.ioctl_fucked_up_getting_the_terminal_size;
        }

        s.resx = @intCast(@TypeOf(s.resx), size.ws_col) - 2; // borders
        s.resy = @intCast(@TypeOf(s.resy), size.ws_row) - 4; // borders + space for msgs
        

        s.buf = try aloc.alloc([]u8, s.resy);
        errdefer aloc.free(s.buf);

        for(s.buf) |_, y| {
            s.buf[y] = try aloc.alloc(u8, s.resx);
            errdefer {
                for(buf[0..y]) |item| {
                    aloc.free(item);
                }
            }
        }

    }

    pub fn deinit(s: *@This(), aloc: *std.mem.Allocator) void {
        for(s.buf) |line| {
            aloc.free(line);
        }
        aloc.free(s.buf);
    }

    pub fn clear(s: *@This()) void {
        for(s.buf) |line, y| {
            for(line) |_, x| {
                s.pix(y, x, ' ');
            }
        }
    }

    pub fn limb(s: *@This(), y: usize, x: usize, v: glob.Limb) void {
        if(v == glob.LIMB_TRANSPARENT) return;
        s.pix(y, x, v);
    }

    fn pix(s: *@This(), y: usize, x: usize, v: Pix) void {
        s.buf[y][x] = v;
    }

    pub fn draw(s: *@This()) !void {

        var ind: u8 = 0;
        try print(" ", .{});
        while(ind < s.resx){
            try print("-", .{});
            ind += 1;
        }
        try print("\n", .{});

        for(s.buf)|line|{
            try print("|", .{});
            for(line)|pixel|{
                try print("{c}", .{pixel});
            }
            try print("|\n",.{});
        }

        ind = 0;
        try print(" ", .{});
        while(ind < s.resx){
            try print("-", .{});
            ind += 1;
        }
        try print("\n", .{});

    }

};
