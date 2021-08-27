
// NOTE
// the resolution field is useless

const std = @import("std");

pub const Settings = struct{
    resx: u7 = 60,
    resy: u7 = 20,
    max_fps: u16 = 5,

    key: Keybindings = kb: {
        var value = Keybindings{};
        break :kb value;
    },

    pub fn init(s: *@This()) !void {

        const cwd = std.fs.cwd();
    
        if(try exists("resx_80")) s.resx = 80;
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
