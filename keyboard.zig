
const std = @import("std");

const c = @cImport({
    @cInclude("stdlib.h");
    @cInclude("termios.h");
    @cInclude("unistd.h");
});

pub const Keyboard = struct{

    original_terminal_settings: c.struct_termios = undefined,

    pub fn init(s: *@This()) !void {

        const stdin_fileno = std.c.STDIN_FILENO;
    
        if (c.tcgetattr(stdin_fileno, &s.original_terminal_settings) < 0) {
            //std.debug.warn("could not get terminal settings\n", .{});
            //std.os.exit(1);
            return error.cant_get_terminal_settings;
        }

        var raw: c.struct_termios = s.original_terminal_settings;

        raw.c_iflag &= ~@intCast(c_uint, (c.BRKINT | c.ICRNL | c.INPCK | c.ISTRIP | c.IXON));
        raw.c_lflag &= ~@intCast(c_uint, (c.ECHO | c.ICANON | c.IEXTEN | c.ISIG));

        // non-blocking read
        raw.c_cc[c.VMIN] = 0;
        raw.c_cc[c.VTIME] = 0;

        if (c.tcsetattr(stdin_fileno, c.TCSANOW, &raw) < 0) {
            std.debug.warn("could not set new terminal settings\n", .{});
            std.os.exit(1);
        }

        //_ = c.atexit(cleanup_terminal);
    }

    pub fn deinit(s: *@This()) void {
        const stdin_fileno = std.c.STDIN_FILENO;
        _ = c.tcsetattr(stdin_fileno, c.TCSANOW, &s.original_terminal_settings);
    }

    pub fn char(s: *@This()) !u8 {
        const stdin = std.io.getStdIn().reader();
        return stdin.readByte();
    }
};
