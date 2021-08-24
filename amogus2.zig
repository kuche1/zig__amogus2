
// TODO
// networking
// keypress keyrelease
// custom skins
// custom maps
// rework map
// custom maps
// replace glob
// use display, and not print

const version = 0.8;

const std = @import("std");
const print = std.io.getStdOut().writer().print;
const echo = std.debug.print;

const glob = @import("./glob.zig");
const Keyboard = @import("./keyboard.zig").Keyboard;
const Display = @import("./display.zig").Display;
const Player = @import("./player.zig").Player;

const Settings = @import("./settings.zig").Settings;


pub fn main() !void {

    var allocator = std.heap.GeneralPurposeAllocator(.{}){};
    const aloc = &allocator.allocator;

    var settings = Settings{};

    try print(
        \\Amogus 2 demo v{}
        \\== Patch notes ==
        \\more modulised
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

            const inp = keyboard.char() catch break;

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


const Map = struct{
    endx: u7,
    endy: u7,
    obsticles: []struct{// hui
        y: i8,
        x: i8,
        model: glob.Limb,
    } = undefined,

    fn init(s: *@This(), aloc: *std.mem.Allocator) !void {
        s.obsticles = try aloc.alloc(@TypeOf(s.obsticles[0]), 0);
        defer aloc.free(s.obsticles);
    }

    fn deinit(s: *@This(), aloc: *std.mem.Allocator) void {
        aloc.free(s.obsticles);
    }

    fn add_obsticle(s: *@This(), aloc: *std.mem.Allocator, y: i8, x: i8, model: glob.Limb) !void {
        if(model == glob.LIMB_NOPHYS) return;
        s.obsticles = try aloc.realloc(s.obsticles, s.obsticles.len+1);
        s.obsticles[s.obsticles.len-1] = .{.y=y, .x=x, .model=model};
    }

    fn move(s: *@This(), phys: *glob.Phys, y: i8, x: i8) void {// add map resolution, currently inf
    
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

    fn collision(s: *@This(), y: i8, x: i8, limb: glob.Limb) bool {

        if(limb == glob.LIMB_NOPHYS) return false;

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
