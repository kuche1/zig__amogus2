
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
    
        const f = cwd.openFile("./settings/resx_80", .{.read=true}) catch |e| {
            switch(e){
                error.FileNotFound => return,
                else => return e,
            }
        };

        s.resx = 80;
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
