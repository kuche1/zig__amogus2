
// NOTE
// the resolution field is useless

const std = @import("std");

const Map_axis_pos = @import("./map.zig").Map_axis_pos;

pub const Settings = struct{

    map_sizex: Map_axis_pos = 60,
    map_sizey: Map_axis_pos = 20,
    max_fps: u16 = 10,

    key: Keybindings = kb: {
        var value = Keybindings{};
        break :kb value;
    },

    pub fn init(s: *@This()) !void {

        const cwd = std.fs.cwd();
    
        if(try exists("resx_80")) s.map_sizex = 80;
    }

    pub fn deinit(s: *@This()) void {
        // empty
    }

};

const Key = u8;

const Keybindings = struct{

    quit: Key = 'q',

    move_left: Key = 'a',
    move_right: Key = 'd',
    move_up: Key = 'w',
    move_down: Key = 's',

};

fn exists(name: []const u8) !bool {
    
    const cwd = std.fs.cwd();

    const set_dir = try cwd.openDir("./settings/", .{});

    const f = set_dir.openFile(name, .{.read=true}) catch |e| {
        switch(e){
            error.FileNotFound => return true,
            else => return e,
        }
    };
    defer f.close();
    return true;
}
