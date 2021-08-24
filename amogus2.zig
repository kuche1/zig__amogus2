
// TODO
// networking
// keypress keyrelease

const version = 0.8;

const std = @import("std");
const print = std.io.getStdOut().writer().print;
const echo = std.debug.print;

const c = @cImport({
    @cInclude("stdlib.h");
    @cInclude("termios.h");
    @cInclude("unistd.h");
});

const Phys = struct{
    pos: Pos,
    model: Model,
};

const Pos = struct{
    x: i8,
    y: i8,
};

const Model = [][]Limb;

const Limb = u8;
const NOPHYS: Limb = ' ';
const TRANSPARENT: Limb = ' ';

const Pix = u8;

const Settings = @import("./settings.zig").Settings;

pub fn main() !void {

    var allocator = std.heap.GeneralPurposeAllocator(.{}){};
    const aloc = &allocator.allocator;

    var settings = Settings{};

    try print(
        \\Amogus 2 demo v{}
        \\== Patch notes ==
        \\increased SUS
        \\increased player polygons
        \\keyboard binding now in settings
        \\windows disabled
        \\printer enabled
        \\
        ,.{version}
    );

    //
    var keyboard = Keyboard{};
    try keyboard.init();
    defer keyboard.deinit();
    //
    var display = Display{.resx=settings.resx, .resy=settings.resy};
    try display.init(aloc);
    defer display.deinit(aloc);
    //
    var clock = Clock{};
    clock.init(settings.max_fps);
    defer clock.deinit();
    //
    var map = Map{.endy=settings.resy, .endx=settings.resx};
    try map.init(aloc);
    defer map.deinit(aloc);
    try map.add_obsticle(aloc, 5, 10, 'S');
    try map.add_obsticle(aloc, 5, 11, 'U');
    try map.add_obsticle(aloc, 5, 12, 'S');
    //
    var player = Player{};
    try player.init(aloc);
    defer player.deinit(aloc);
    player.spawn(0, 0);
    //

    var running = true;

    while(running){

        display.clear();
        map.draw(&display);
        player.draw(&display);
        try display.draw();


        const dt = clock.tick();


        while(true) {

            const inp = keyboard.read() catch break;

            if(inp == settings.key_quit){
                running = false;
                continue;
            }
            else if(inp == settings.key_move_left) map.move(&player.phys, 0, -1)
            else if(inp == settings.key_move_right) map.move(&player.phys, 0, 1)
            else if(inp == settings.key_move_up) map.move(&player.phys, -1, 0)
            else if(inp == settings.key_move_down) map.move(&player.phys, 1, 0)
            ;

        }

    }

}


const Player = struct{
    phys: Phys = undefined,
    
    fn init(s: *@This(), aloc: *std.mem.Allocator) !void {

        var arr1: []const u8 = "   pussy";
        var arr2: []const u8 = "dest   royer";

        var m0: []const u8 = "  0";
        var m1: []const u8 = " /|\\";
        var m2: []const u8 = "  |";
        var m3: []const u8 = " / \\";

        var ptrs: []*[]const u8 = ([_]*[]const u8{&m0, &m1, &m2, &m3})[0..];

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

    fn deinit(s: *@This(), aloc: *std.mem.Allocator) void {
        for(s.phys.model) |line| {
            aloc.free(line);
        }
        aloc.free(s.phys.model);
    }

    fn spawn(s: *@This(), x: i8, y: i8) void {
        s.phys.pos.x = x;
        s.phys.pos.y = y;
    }

    fn draw(s: *@This(), display: *Display) void {
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

const Map = struct{
    endx: u7,
    endy: u7,
    obsticles: []struct{// hui
        y: i8,
        x: i8,
        model: Limb,
    } = undefined,

    fn init(s: *@This(), aloc: *std.mem.Allocator) !void {
        s.obsticles = try aloc.alloc(@TypeOf(s.obsticles[0]), 0);
        defer aloc.free(s.obsticles);
    }

    fn deinit(s: *@This(), aloc: *std.mem.Allocator) void {
        aloc.free(s.obsticles);
    }

    fn add_obsticle(s: *@This(), aloc: *std.mem.Allocator, y: i8, x: i8, model: Limb) !void {
        if(model == NOPHYS) return;
        s.obsticles = try aloc.realloc(s.obsticles, s.obsticles.len+1);
        s.obsticles[s.obsticles.len-1] = .{.y=y, .x=x, .model=model};
    }

    fn move(s: *@This(), phys: *Phys, y: i8, x: i8) void {// add map resolution, currently inf
    
        var xi: i8 = 0;
        var yi: i8 = 0;

        for(phys.model) |line, li| {
            for(line) |char, ci| {
                if(s.collision(
                                phys.pos.y+y+@intCast(i8, li),
                                phys.pos.x+x+@intCast(i8, ci),
                                char,
                                )) return;
            }
        }

        phys.pos.x += x;
        phys.pos.y += y;

    }

    fn collision(s: *@This(), y: i8, x: i8, limb: Limb) bool {

        if(limb == NOPHYS) return false;

        if(x < 0 or y < 0) return true;
        if(x >= s.endx or y >= s.endy) return true;
    
        for(s.obsticles) |ob| {
            if(ob.y == y and ob.x == x) return true;
        }
        return false;
    }

    fn draw(s: *@This(), display: *Display) void {
        for(s.obsticles) |ob| {
            display.limb(@intCast(usize, ob.y), @intCast(usize, ob.x), ob.model);
        }
    }
};

const Keyboard = struct{

    original_terminal_settings: c.struct_termios = undefined,

    fn init(s: *@This()) !void {

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

    fn deinit(s: *@This()) void {
        const stdin_fileno = std.c.STDIN_FILENO;
        _ = c.tcsetattr(stdin_fileno, c.TCSANOW, &s.original_terminal_settings);
    }

    fn read(s: *@This()) !u8 {
        const stdin = std.io.getStdIn().reader();
        return stdin.readByte();
    }
};

const Clock = struct{

    min_dt: i128 = undefined,
    time: i128 = undefined,

    fn init(s: *@This(), max_fps: u64) void {
        s.min_dt = @divFloor(std.time.ns_per_s, max_fps);
        s.time = std.time.nanoTimestamp();
    }

    fn deinit(s: *@This()) void {
        // empty
    }

    fn tick(s: *@This()) i128 {

        const time = std.time.nanoTimestamp();
        const dt = time - s.time;
        s.time = time;

        const dt_diff = s.min_dt - dt;
        if(dt_diff > 0){
            std.time.sleep(@intCast(u64, dt_diff));
        }

        return dt;

    }

};

const Display = struct{
    resx: u8,
    resy: u8,
    buf: [][]Pix = undefined,

    fn init(s: *@This(), aloc: *std.mem.Allocator) !void {

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

    fn deinit(s: *@This(), aloc: *std.mem.Allocator) void {
        for(s.buf) |line| {
            aloc.free(line);
        }
        aloc.free(s.buf);
    }

    fn clear(s: *@This()) void {
        for(s.buf) |line, y| {
            for(line) |_, x| {
                s.pix(y, x, ' ');
            }
        }
    }

    fn limb(s: *@This(), y: usize, x: usize, v: Limb) void {
        if(v == TRANSPARENT) return;
        s.pix(y, x, v);
    }

    fn pix(s: *@This(), y: usize, x: usize, v: Pix) void {
        s.buf[y][x] = v;
    }

    fn draw(s: *@This()) !void {

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

