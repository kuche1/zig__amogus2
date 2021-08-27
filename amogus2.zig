
// TODO
// networking
// keypress keyrelease
// custom skins
// custom maps
// rework map
// custom maps
// replace glob
// use display, and not print
// add non-en_US support
// separate model from hitbox?

const version = 0.8;

const std = @import("std");
const print = std.io.getStdOut().writer().print;
const echo = std.debug.print;

const glob = @import("./glob.zig");
const Keyboard = @import("./keyboard.zig").Keyboard;
const Display = @import("./display.zig").Display;
const Clock = @import("./clock.zig").Clock;
const Map = @import("./map.zig").Map;
const Player = @import("./player.zig").Player;

const Settings = @import("./settings.zig").Settings;


pub fn main() !void {

    var allocator = std.heap.GeneralPurposeAllocator(.{}){};
    const aloc = &allocator.allocator;

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
    var settings = Settings{};
    try settings.init();
    defer settings.deinit();
    //
    var display = Display{};
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
    try map.add_obsticle(aloc, .{.y=5, .x=10}, 'S');
    try map.add_obsticle(aloc, .{.y=5, .x=11}, 'U');
    try map.add_obsticle(aloc, .{.y=5, .x=12}, 'S');
    //
    var player = Player{};
    try player.init(aloc);
    defer player.deinit(aloc);
    player.spawn(.{.x=0, .y=0});
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

            if(inp == settings.key.quit){
                running = false;
                continue;
            }
            else if(inp == settings.key.move_left) map.move(&player.phys, 0, -1)
            else if(inp == settings.key.move_right) map.move(&player.phys, 0, 1)
            else if(inp == settings.key.move_up) map.move(&player.phys, -1, 0)
            else if(inp == settings.key.move_down) map.move(&player.phys, 1, 0)
            ;

        }

    }

}
